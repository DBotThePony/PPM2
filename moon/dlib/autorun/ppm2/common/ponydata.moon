
--
-- Copyright (C) 2017-2018 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

for ply in *player.GetAll()
	ply.__PPM2_PonyData\Remove() if ply.__PPM2_PonyData

wUInt = (def = 0, size = 8) ->
	return (arg = def) -> net.WriteUInt(arg, size)

wInt = (def = 0, size = 8) ->
	return (arg = def) -> net.WriteInt(arg, size)

rUInt = (size = 8, min = 0, max = 255) ->
	return -> math.Clamp(net.ReadUInt(size), min, max)

rInt = (size = 8, min = -128, max = 127) ->
	return -> math.Clamp(net.ReadInt(size), min, max)

rFloat = (min = 0, max = 255) ->
	return -> math.Clamp(net.ReadFloat(), min, max)

wFloat = net.WriteFloat
rSEnt = net.ReadStrongEntity
wSEnt = net.WriteStrongEntity
rBool = net.ReadBool
wBool = net.WriteBool
rColor = net.ReadColor
wColor = net.WriteColor
rString = net.ReadString
wString = net.WriteString

class NetworkedPonyData extends DLib.NetworkedData
	@NW_ClientsideCreation = true
	@RenderTasks = {}

	@Setup()
	@NetworkVar('Entity',           rSEnt, wSEnt, StrongEntity(-1), ((newValue) => IsValid(@GetOwner()) and StrongEntity(@GetOwner()\EntIndex()) or newValue))
	@NetworkVar('UpperManeModel',   rSEnt, wSEnt, StrongEntity(-1), nil, false)
	@NetworkVar('LowerManeModel',   rSEnt, wSEnt, StrongEntity(-1), nil, false)
	@NetworkVar('TailModel',        rSEnt, wSEnt, StrongEntity(-1), nil, false)
	@NetworkVar('SocksModel',       rSEnt, wSEnt, StrongEntity(-1), nil, false)
	@NetworkVar('NewSocksModel',    rSEnt, wSEnt, StrongEntity(-1), nil, false)

	@NetworkVar('Fly',                  rBool,   wBool,                 false)
	@NetworkVar('DisableTask',          rBool,   wBool,                 false)
	@NetworkVar('UseFlexLerp',          rBool,   wBool,                  true)
	@NetworkVar('FlexLerpMultiplier',   rFloat(0, 10),  wFloat,             1)

	@SetupModifiers: =>
		for key, value in pairs PPM2.PonyDataRegistry
			if value.modifiers
				@RegisterModifier(value.getFunc, 0, 0)
				@SetModifierMinMaxFinal(value.getFunc, value.min, value.max) if value.min or value.max
				@SetupLerpTables(value.getFunc)
				strName = '_NW_' .. value.getFunc
				funcLerp = 'Calculate' .. value.getFunc
				@__base['Get' .. value.getFunc] = => @[funcLerp](@, @[strName])

	for key, value in pairs PPM2.PonyDataRegistry
		@NetworkVar(value.getFunc, value.read, value.write, value.default)

	new: (netID, ent) =>
		@recomputeTextures = true
		@isValid = true
		super(netID)
		if ent
			@modelCached = ent\GetModel()
			@SetEntity(ent)
			@SetupEntity(ent)

	IsValid: => @isValid
	GetModel: => @modelCached
	EntIndex: => @entID

	Clone: (target = @ent) =>
		copy = @@(nil, target)
		@ApplyDataToObject(copy)
		return copy

	SetupEntity: (ent) =>
		if ent.__PPM2_PonyData
			return if ent.__PPM2_PonyData\GetOwner() and IsValid(ent.__PPM2_PonyData\GetOwner()) and StrongEntity(ent.__PPM2_PonyData\GetOwner()) ~= StrongEntity(@GetOwner())
			ent.__PPM2_PonyData\Remove() if ent.__PPM2_PonyData.Remove and ent.__PPM2_PonyData ~= @
		ent.__PPM2_PonyData = @
		@ent = ent
		@entTable = @ent\GetTable()
		return unless IsValid(ent)
		@modelCached = ent\GetModel()
		@ent = ent
		ent\PPMBonesModifier() if CLIENT
		@flightController = PPM2.PonyflyController(@)
		@entID = ent\EntIndex()
		@lastLerpThink = RealTime()
		@ModelChanges(@modelCached, @modelCached)
		@Reset()
		timer.Simple(0, -> @GetRenderController()\CompileTextures() if @GetRenderController()) if CLIENT
		PPM2.DebugPrint('Ponydata ', @, ' was updated to use for ', @ent)
		@@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]

	ModelChanges: (old = @ent\GetModel(), new = old) =>
		@modelCached = new
		@SetFly(false) if SERVER
		timer.Simple 0.5, ->
			return unless IsValid(@ent)
			@Reset()

	GenericDataChange: (state) =>
		hook.Run 'PPM2_PonyDataChanges', @ent, @, state
		if state\GetKey() == 'Entity' and IsValid(@GetEntity())
			@SetupEntity(@GetEntity())

		if state\GetKey() == 'Fly' and @flightController
			@flightController\Switch(state\GetValue())

		if state\GetKey() == 'DisableTask'
			@@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]

		@GetSizeController()\DataChanges(state) if @ent and @GetBodygroupController()
		@GetBodygroupController()\DataChanges(state) if @ent and @GetBodygroupController()

		if CLIENT and @ent
			@GetWeightController()\DataChanges(state) if @GetWeightController()
			@GetRenderController()\DataChanges(state) if @GetRenderController()

	ResetScale: =>
		if scale = @GetSizeController()
			scale\ResetScale()

	ModifyScale: =>
		if scale = @GetSizeController()
			scale\ModifyScale()

	Reset: =>
		if scale = @GetSizeController()
			scale\Reset()
		if CLIENT
			@GetWeightController()\Reset() if @GetWeightController().Reset
			@GetRenderController()\Reset() if @GetRenderController().Reset
			@GetBodygroupController()\Reset() if @GetBodygroupController().Reset

	PlayerRespawn: =>
		return if not IsValid(@ent)
		@entTable.__cachedIsPony = @ent\IsPony()
		if not @entTable.__cachedIsPony
			return if @alreadyCalledRespawn
			@alreadyCalledRespawn = true
			@alreadyCalledDeath = true
		else
			@alreadyCalledRespawn = false
			@alreadyCalledDeath = false
		@ApplyBodygroups(CLIENT, true)
		@SetFly(false) if SERVER

		if scale = @GetSizeController()
			scale\PlayerRespawn()

		if CLIENT
			@deathRagdollMerged = false
			@GetWeightController()\UpdateWeight() if @GetWeightController()
			@GetRenderController()\PlayerRespawn() if @GetRenderController()
			@GetBodygroupController()\MergeModels(@ent) if IsValid(@ent) and @GetBodygroupController().MergeModels

	PlayerDeath: =>
		return if not IsValid(@ent)
		@entTable.__cachedIsPony = @ent\IsPony()
		if not @entTable.__cachedIsPony
			return if @alreadyCalledDeath
			@alreadyCalledDeath = true
		else
			@alreadyCalledDeath = false
		@SetFly(false) if SERVER

		if scale = @GetSizeController()
			scale\PlayerDeath()

		if CLIENT
			@DoRagdollMerge()
			@GetRenderController()\PlayerDeath() if @GetRenderController()

	DoRagdollMerge: =>
		return if @deathRagdollMerged
		bgController = @GetBodygroupController()
		rag = @ent\GetRagdollEntity()
		if not bgController.MergeModels
			@deathRagdollMerged = true
		elseif IsValid(rag)
			@deathRagdollMerged = true
			bgController\MergeModels(rag)

	ApplyBodygroups: (updateModels = CLIENT) => @GetBodygroupController()\ApplyBodygroups(updateModels) if @ent
	SetLocalChange: (state) => @GenericDataChange(state)
	NetworkDataChanges: (state) => @GenericDataChange(state)

	SlowUpdate: =>
		@GetBodygroupController()\SlowUpdate() if @GetBodygroupController()
		@GetWeightController()\SlowUpdate() if @GetWeightController()
		if scale = @GetSizeController()
			scale\SlowUpdate()

	Think: =>
	RenderScreenspaceEffects: =>
		time = RealTime()
		delta = time - @lastLerpThink
		@lastLerpThink = time
		if @isValid and IsValid(@ent)
			for change in *@TriggerLerpAll(delta * 5)
				state = DLib.NetworkChangeState('_NW_' .. change[1], change[1], change[2] + @['_NW_' .. change[1]], @)
				state\SetCantApply(true)
				@GenericDataChange(state)

	GetFlightController: => @flightController

	GetRenderController: =>
		return if SERVER
		return @renderController if not @isValid
		if not @renderController or @modelCached ~= @modelRender
			@modelRender = @modelCached
			cls = PPM2.GetRenderController(@modelCached)
			if @renderController and cls == @renderController.__class
				@renderController.ent = @ent
				PPM2.DebugPrint('Skipping render controller recreation for ', @ent, ' as part of ', @)
				return @renderController
			@renderController\Remove() if @renderController
			@renderController = cls(@)
		@renderController.ent = @ent
		return @renderController

	GetWeightController: =>
		return if SERVER
		return @weightController if not @isValid
		if not @weightController or @modelCached ~= @modelWeight
			@modelCached = @modelCached or @ent\GetModel()
			@modelWeight = @modelCached
			cls = PPM2.GetPonyWeightController(@modelCached)
			if @weightController and cls == @weightController.__class
				@weightController.ent = @ent
				PPM2.DebugPrint('Skipping weight controller recreation for ', @ent, ' as part of ', @)
				return @weightController
			@weightController\Remove() if @weightController
			@weightController = cls(@)
		@weightController.ent = @ent
		return @weightController

	GetSizeController: =>
		return @scaleController if not @isValid
		if not @scaleController or @modelCached ~= @modelScale
			@modelCached = @modelCached or @ent\GetModel()
			@modelScale = @modelCached
			cls = PPM2.GetSizeController(@modelCached)
			if @scaleController and cls == @scaleController.__class
				@scaleController.ent = @ent
				PPM2.DebugPrint('Skipping size controller recreation for ', @ent, ' as part of ', @)
				return @scaleController
			@scaleController\Remove() if @scaleController
			@scaleController = cls(@)
		@scaleController.ent = @ent
		return @scaleController
	GetScaleController: => @GetSizeController()

	GetBodygroupController: =>
		return @bodygroups if not @isValid
		if not @bodygroups or @modelBodygroups ~= @modelCached
			@modelCached = @modelCached or @ent\GetModel()
			@modelBodygroups = @modelCached
			cls = PPM2.GetBodygroupController(@modelCached)
			if @bodygroups and cls == @bodygroups.__class
				@bodygroups.ent = @ent
				PPM2.DebugPrint('Skipping bodygroup controller recreation for ', @ent, ' as part of ', @)
				return @bodygroups
			@bodygroups\Remove() if @bodygroups
			@bodygroups = cls(@)
		@bodygroups.ent = @ent
		return @bodygroups

	Remove: (byClient = false) =>
		@@NW_Objects[@netID] = nil if @NETWORKED
		@isValid = false
		@ent = @GetEntity() if not IsValid(@ent)
		@entTable.__PPM2_PonyData = nil if IsValid(@ent) and @ent.__PPM2_PonyData == @
		if CLIENT
			@GetWeightController()\Remove() if @GetWeightController()
			@GetRenderController()\Remove() if @GetRenderController()
			if IsValid(@ent) and @ent.__ppm2_task_hit
				@entTable.__ppm2_task_hit = false
				@ent\SetNoDraw(false)
		@GetBodygroupController()\Remove() if @GetBodygroupController()
		@GetSizeController()\Remove() if @GetSizeController()
		@flightController\Switch(false) if @flightController
		@@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]

	__tostring: => "[#{@@__name}:#{@netID}|#{@ent}]"

PPM2.NetworkedPonyData = NetworkedPonyData

if CLIENT
	net.Receive 'PPM2.NotifyDisconnect', ->
		netID = net.ReadUInt(16)
		data = NetworkedPonyData.NW_Objects[netID]
		return if not data
		data\Remove()

	net.Receive 'PPM2.PonyDataRemove', ->
		netID = net.ReadUInt(16)
		data = NetworkedPonyData.NW_Objects[netID]
		return if not data
		data\Remove()

	hook.Add 'StrongEntityLinkUpdates', 'PPM2.NetworkedObjectCheck', =>
		if @__PPM2_PonyData
			@__PPM2_PonyData\SetEntity(@GetEntity())
			@__PPM2_PonyData\SetupEntity(@)
else
	hook.Add 'PlayerJoinTeam', 'PPM2.TeamWaypoint', (ply, new) ->
		ply.__ppm2_modified_jump = false
	hook.Add 'OnPlayerChangedTeam', 'PPM2.TeamWaypoint', (ply, old, new) ->
		ply.__ppm2_modified_jump = false

entMeta = FindMetaTable('Entity')
entMeta.GetPonyData = =>
	self2 = @
	self = entMeta.GetTable(@)
	return if not @
	if @__PPM2_PonyData and StrongEntity(@__PPM2_PonyData\GetEntity()) ~= StrongEntity(self2)
		@__PPM2_PonyData\SetEntity(self2)
		@__PPM2_PonyData\SetupEntity(self2) if CLIENT
	return @__PPM2_PonyData
