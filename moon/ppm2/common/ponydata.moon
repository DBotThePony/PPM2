
--
-- Copyright (C) 2017-2020 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

net = DLib.net

class PPM2.NetworkChangeState
	new: (key = '', keyValid = '', newValue, obj, len = 24, ply = NULL) =>
		@key = key
		@keyValid = keyValid
		@oldValue = obj[key]
		@newValue = newValue
		@ply = ply
		@time = CurTimeL()
		@rtime = RealTimeL()
		@stime = SysTime()
		@obj = obj
		@objID = obj.netID
		@len = len
		@rlen = len - 24 -- ID - 16 bits, variable id - 8 bits
		@cantApply = false
		@networkChange = true

	GetPlayer: => @ply
	ChangedByClient: => not @networkChange or IsValid(@ply)
	ChangedByPlayer: => not @networkChange or IsValid(@ply)
	ChangedByServer: => not @networkChange or not IsValid(@ply)
	GetKey: => @keyValid
	GetVariable: => @keyValid
	GetVar: => @keyValid
	GetKeyInternal: => @key
	GetVariableInternal: => @key
	GetVarInternal: => @key
	GetNewValue: => @newValue
	GetValue: => @newValue
	GetCantApply: => @cantApply
	SetCantApply: (val) => @cantApply = val
	NewValue: => @newValue
	GetOldValue: => @oldValue
	OldValue: => @oldValue
	CurTime: => @time
	GetCurTime: => @time
	GetReceiveTime: => @time
	GetReceiveStamp: => @time
	RealTimeL: => @rtime
	GetRealTimeL: => @rtime
	SysTime: => @stime
	GetSysTime: => @stime
	GetObject: => @obj
	GetNWObject: => @obj
	GetNetworkedObject: => @obj
	GetLength: => @rlen
	GetRealLength: => @len
	ChangedByNetwork: => @networkChange

	Revert: => @obj[@key] = @oldValue if not @cantApply
	Apply: => @obj[@key] = @newValue if not @cantApply

	Notify: =>
		return unless @obj.NETWORKED and (CLIENT and @obj.ent == LocalPlayer() or SERVER)
		net.Start(PPM2.NetworkedPonyData.NW_Modify)
		net.WriteUInt32(@obj\GetNetworkID())
		{:id, :writeFunc} = PPM2.NetworkedPonyData\GetVarInfo(@key)
		net.WriteUInt16(id)
		writeFunc(@newValue)
		net.SendToServer() if CLIENT
		net.Broadcast() if SERVER

rFloat = (min = 0, max = 255) ->
	return -> math.Clamp(net.ReadFloat(), min, max)

wFloat = net.WriteFloat
rBool = net.ReadBool
wBool = net.WriteBool

if PPM2.NetworkedPonyData and PPM2.NetworkedPonyData.REGISTRY
	REGISTRY = PPM2.NetworkedPonyData.REGISTRY

	nullify = ->
		for _, ent in ipairs ents.GetAll()
			if ent.__PPM2_PonyData and ent.__PPM2_PonyData.Remove
				ProtectedCall -> ent.__PPM2_PonyData\Remove()

		for _, ent in ipairs ents.GetAll()
			ent.__PPM2_PonyData = nil

		for key, obj in pairs(REGISTRY)
			if obj.Remove
				ProtectedCall -> obj\Remove()

	nullify()

_NW_NextObjectID = PPM2.NetworkedPonyData and PPM2.NetworkedPonyData.NW_NextObjectID or 0
_NW_NextObjectID_CL = PPM2.NetworkedPonyData and PPM2.NetworkedPonyData.NW_NextObjectID_CL or 0x70000000
_NW_WaitID = PPM2.NetworkedPonyData and PPM2.NetworkedPonyData.NW_WaitID or -1

class PPM2.NetworkedPonyData extends PPM2.ModifierBase
	@REGISTRY = {}

	@GetVarInfo: (strName) => @NW_VarsTable[strName] or false

	@AddNetworkVar = (getName = 'Var', readFunc = (->), writeFunc = (->), defValue, enum_runtime_map) =>
		defFunc = defValue
		defFunc = (-> defValue) if type(defValue) ~= 'function'
		strName = "_NW_#{getName}"
		@NW_NextVarID += 1
		id = @NW_NextVarID
		tab = {:strName, :readFunc, :getName, :writeFunc, :defValue, :defFunc, :id}
		table.insert(@NW_Vars, tab)
		@NW_VarsTable[id] = tab
		@NW_VarsTable[strName] = tab
		@__base[strName] = defFunc()

		@__base["Get#{getName}"] = => @[strName]

		--if enum_runtime_map
			--@__base["Get#{getName}"] = => enum_runtime_map[@[strName]]

		@__base["Set#{getName}"] = (val = defFunc(), networkNow = networkByDefault) =>
			if enum_runtime_map
				if isstring(val)
					i = val
					val = enum_runtime_map[val]
					error('No such enum value ' .. i) if val == nil

				if isnumber(val)
					error('No such enum index ' .. val) if enum_runtime_map[val] == nil

			oldVal = @[strName]
			@[strName] = val
			state = PPM2.NetworkChangeState(strName, getName, val, @)
			state.networkChange = false
			@SetLocalChange(state)
			return unless networkNow and @NETWORKED and (CLIENT and @ent == LocalPlayer() or SERVER)
			net.Start(@@NW_Modify)
			net.WriteUInt32(@GetNetworkID())
			net.WriteUInt16(id)
			writeFunc(val)
			net.SendToServer() if CLIENT
			net.Broadcast() if SERVER

	@GetSet = (fname, fvalue) =>
		@__base["Get#{fname}"] = => @[fvalue]
		@__base["Set#{fname}"] = (fnewValue = @[fvalue]) =>
			oldVal = @[fvalue]
			@[fvalue] = fnewValue
			state = PPM2.NetworkChangeState(fvalue, fname, fnewValue, @)
			state.networkChange = false
			@SetLocalChange(state)

	if CLIENT
		hook.Add 'OnEntityCreated', 'PPM2.NW_WAIT', (ent) -> timer.Simple 0, ->
			return if not IsValid(ent)
			return if not @REGISTRY[ent\EntIndex()]
			return if @REGISTRY[ent\EntIndex()].done_setup or IsValid(@REGISTRY[ent\EntIndex()].ent)
			@REGISTRY[ent\EntIndex()]\SetupEntity(ent)

		hook.Add 'NotifyShouldTransmit', 'PPM2.NW_WAIT', (ent, should) ->
			return if not should
			return if not @REGISTRY[ent\EntIndex()]
			return if @REGISTRY[ent\EntIndex()].done_setup or IsValid(@REGISTRY[ent\EntIndex()].ent)
			@REGISTRY[ent\EntIndex()]\SetupEntity(ent)

		-- clientside entities
		hook.Add 'EntityRemoved', 'PPM2.NW_WAIT', (ent) -> @REGISTRY[ent]\Remove() if @REGISTRY[ent]

	@OnNetworkedCreated = (ply = NULL, len = 0, nwobj) =>
		if CLIENT
			netID = net.ReadUInt32()
			entid = net.ReadUInt16()
			obj = @Get(netID) or @(netID, entid)
			@REGISTRY[entid] = obj
			obj.NETWORKED = true
			obj.CREATED_BY_SERVER = true
			obj.SHOULD_NETWORK = true
			obj\ReadNetworkData()
			return

		ply[@NW_CooldownTimer] = ply[@NW_CooldownTimer] or 0
		ply[@NW_CooldownTimerCount] = ply[@NW_CooldownTimerCount] or 0

		if ply[@NW_CooldownTimer] < RealTimeL()
			ply[@NW_CooldownTimerCount] = 1
			ply[@NW_CooldownTimer] = RealTimeL() + 10
		else
			ply[@NW_CooldownTimerCount] += 1

		if ply[@NW_CooldownTimerCount] >= 3
			ply[@NW_CooldownMessage] = ply[@NW_CooldownMessage] or 0
			if ply[@NW_CooldownMessage] < RealTimeL()
				PPM2.Message 'Player ', ply, " is creating #{@__name} too quickly!"
				ply[@NW_CooldownMessage] = RealTimeL() + 1
			return

		waitID = net.ReadUInt32()

		obj = @(nil, ply)
		obj.SHOULD_NETWORK = true
		obj\ReadNetworkData()
		obj\Create()

		net.Start(@NW_ReceiveID)
		net.WriteUInt32(waitID)
		net.WriteUInt32(obj.netID)
		net.Send(ply)

	@OnNetworkedModify = (ply = NULL, len = 0) =>
		id = net.ReadUInt32()
		obj = @Get(id)

		if not obj or IsValid(ply) and obj.ent ~= ply
			return if CLIENT
			net.Start(@NW_Rejected)
			net.WriteUInt32(id)
			net.Send(ply)
			return

		varID = net.ReadUInt16()
		varData = @NW_VarsTable[varID]
		return unless varData

		{:strName, :getName, :readFunc, :writeFunc} = varData
		newVal = readFunc()
		return if newVal == obj["Get#{getName}"](obj)

		state = PPM2.NetworkChangeState(strName, getName, newVal, obj, len, ply)
		state\Apply()
		obj\NetworkDataChanges(state)

		return if CLIENT

		net.Start(@NW_Modify)
		net.WriteUInt32(id)
		net.WriteUInt16(varID)
		writeFunc(newVal)
		net.SendOmit(ply)

	@OnNetworkedDelete = (ply = NULL, len = 0) =>
		id = net.ReadUInt32()
		obj = @Get(id)
		return unless obj
		obj\Remove(true)

	@ReadNetworkData = =>
		output = {strName, {getName, readFunc()} for _, {:getName, :strName, :readFunc} in ipairs @NW_Vars}
		return output

	@RenderTasks = {}
	@CheckTasks = {}

	@Get = (nwID) => @NW_Objects[nwID] or false

	@NW_Vars = {}
	@NW_VarsTable = {}
	@NW_Objects = {}
	@O_Slots = {} if CLIENT
	@NW_Waiting = {}
	@NW_WaitID = _NW_WaitID
	@NW_NextVarID = -1
	@NW_Create = 'PPM2.NW.Created'
	@NW_Modify = 'PPM2.NW.Modified'
	@NW_Broadcast = 'PPM2.NW.ModifiedBroadcast'
	@NW_Remove = 'PPM2.NW.Removed'
	@NW_Rejected = 'PPM2.NW.Rejected'
	@NW_ReceiveID = 'PPM2.NW.ReceiveID'
	@NW_CooldownTimerCount = 'ppm2_NW_CooldownTimerCount'
	@NW_CooldownTimer = 'ppm2_NW_CooldownTimer'
	@NW_CooldownMessage = 'ppm2_NW_CooldownMessage'
	@NW_NextObjectID = _NW_NextObjectID
	@NW_NextObjectID_CL = _NW_NextObjectID_CL

	if SERVER
		net.pool(@NW_Create)
		net.pool(@NW_Modify)
		net.pool(@NW_Remove)
		net.pool(@NW_ReceiveID)
		net.pool(@NW_Rejected)
		net.pool(@NW_Broadcast)

	net.Receive @NW_Create, (len = 0, ply = NULL, obj) -> @OnNetworkedCreated(ply, len, obj)
	net.Receive @NW_Modify, (len = 0, ply = NULL, obj) -> @OnNetworkedModify(ply, len, obj)
	net.Receive @NW_Remove, (len = 0, ply = NULL, obj) -> @OnNetworkedDelete(ply, len, obj)

	if SERVER
		net.ReceiveAntispam(@NW_Create)
		net.ReceiveAntispam(@NW_Remove)

	net.Receive @NW_ReceiveID, (len = 0, ply = NULL) ->
		return if SERVER
		waitID = net.ReadUInt32()
		netID = net.ReadUInt32()
		obj = @NW_Waiting[waitID]
		@NW_Waiting[waitID] = nil
		return unless obj
		obj.NETWORKED = true
		@NW_Objects[obj.netID] = nil
		obj.netID = netID
		obj.waitID = nil
		@NW_Objects[netID] = obj

	net.Receive @NW_Rejected, (len = 0, ply = NULL) ->
		return if SERVER
		netID = net.ReadUInt32()
		obj = @Get(netID)
		return if not obj or obj.__LastReject and obj.__LastReject > RealTimeL()
		obj.__LastReject = RealTimeL() + 3
		obj.NETWORKED = false
		obj\Create()

	net.Receive @NW_Broadcast, (len = 0, ply = NULL) ->
		return if SERVER
		netID = net.ReadUInt32()
		obj = @NW_Objects[netID]
		return unless obj
		obj\ReadNetworkData(len, ply)

	@GetSet('UpperManeModel', 'm_upperManeModel')
	@GetSet('LowerManeModel', 'm_lowerManeModel')
	@GetSet('TailModel', 'm_tailModel')
	@GetSet('SocksModel', 'm_socksModel')
	@GetSet('HornModel', 'm_hornmodel')
	@GetSet('ClothesModel', 'm_clothesmodel')
	@GetSet('NewSocksModel', 'm_newSocksModel')

	@AddNetworkVar('DisableTask',          rBool,   wBool,                 false)
	@AddNetworkVar('UseFlexLerp',          rBool,   wBool,                  true)
	@AddNetworkVar('FlexLerpMultiplier',   rFloat(0, 10),  wFloat,             1)

	@SetupModifiers: =>
		for key, value in SortedPairs PPM2.PonyDataRegistry
			if value.modifiers
				@RegisterModifier(key, 0, 0)
				@SetModifierMinMaxFinal(key, value.min, value.max) if value.min or value.max
				@SetupLerpTables(key)
				strName = '_NW_' .. key
				funcLerp = 'Calculate' .. key
				@__base['Get' .. key] = => @[funcLerp](@, @[strName])

	for key, value in SortedPairs PPM2.PonyDataRegistry
		@AddNetworkVar(key, value.read, value.write, value.default, value.enum_runtime_map)

	new: (netID, ent) =>
		super()

		@m_upperManeModel       = NULL
		@m_lowerManeModel       = NULL
		@m_tailModel            = NULL
		@m_socksModel           = NULL
		@m_newSocksModel        = NULL

		@lastLerpThink = RealTimeL()

		@recomputeTextures = true
		@isValid = true
		@removed = false
		@valid = true
		@NETWORKED = false
		@SHOULD_NETWORK = false

		@[data.strName] = data.defFunc() for _, data in ipairs @@NW_Vars when data.defFunc

		if SERVER
			@netID = @@NW_NextObjectID
			@@NW_NextObjectID += 1
		else
			netID = -1 if netID == nil
			@netID = netID

		@@NW_Objects[@netID] = @

		if CLIENT
			for i = 1, 1024
				if not @@O_Slots[i]
					@slotID = i
					@@O_Slots[i] = @
					break

			error('no more free pony data edicts') if not @slotID

		@entID = isnumber(ent) and ent or ent\EntIndex()
		ent = Entity(ent) if isnumber(ent)
		@SetupEntity(ent) if IsValid(ent)

	GetEntity: => @ent or NULL
	IsValid: => @isValid
	GetModel: => @modelCached
	EntIndex: => @entID
	ObjectSlot: => @slotID
	GetObjectSlot: => @slotID

	Clone: (target = @ent) =>
		copy = @@(nil, target)
		@ApplyDataToObject(copy)
		return copy

	SetupEntity: (ent) =>
		if getdata = @@REGISTRY[ent]
			return if getdata\GetOwner() and IsValid(getdata\GetOwner()) and getdata\GetOwner() ~= ent
			getdata\Remove() if getdata.Remove and getdata ~= @

		return unless IsValid(ent)

		if getdata = @@REGISTRY[ent\EntIndex()]
			return if getdata\GetOwner() and IsValid(getdata\GetOwner()) and getdata\GetOwner() ~= ent
			getdata\Remove() if getdata.Remove and getdata ~= @

		@ent = ent
		@done_setup = true
		ent\SetPonyData(@)
		@entTable = @ent\GetTable()

		@modelCached = ent\GetModel()
		ent\PPMBonesModifier()
		@flightController = PPM2.PonyflyController(@) if not @flightController
		@entID = ent\EntIndex()
		@lastLerpThink = RealTimeL()

		@ModelChanges(@modelCached, @modelCached)
		@Reset()

		timer.Simple(0, -> @GetRenderController()\CompileTextures() if @GetRenderController()) if CLIENT

		@@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]
		@@CheckTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task\GetDisableTask()]

	ModelChanges: (old = @ent\GetModel(), new = old) =>
		@modelCached = new

		@ent\SetNW2Bool('ppm2_fly', false)

		timer.Simple 0.5, ->
			return unless IsValid(@ent)
			@Reset()

	GenericDataChange: (state) =>
		hook.Run 'PPM2_PonyDataChanges', @ent, @, state

		if state\GetKey() == 'DisableTask'
			@@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]
			@@CheckTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task\GetDisableTask()]

		@GetSizeController()\DataChanges(state) if @ent and @GetBodygroupController()
		@GetBodygroupController()\DataChanges(state) if @ent and @GetBodygroupController()

		@GetWeightController()\DataChanges(state) if @ent and @GetWeightController()

		if CLIENT and @ent
			@GetRenderController()\DataChanges(state) if @GetRenderController()

	ResetScale: =>
		if scale = @GetSizeController()
			scale\ResetScale()

	ModifyScale: =>
		if scale = @GetSizeController()
			scale\ModifyScale()

	GetIsEditor: => @is_editor_data or false
	SetIsEditor: (value = false) => @is_editor_data = value

	Reset: =>
		if scale = @GetSizeController()
			scale\Reset()
		if CLIENT
			@GetWeightController()\Reset() if @GetWeightController() and @GetWeightController().Reset
			@GetRenderController()\Reset() if @GetRenderController() and @GetRenderController().Reset
			@GetBodygroupController()\Reset() if @GetBodygroupController() and @GetBodygroupController().Reset

	GetHoofstepVolume: =>
		return 0.8 if @ShouldMuffleHoosteps()
		return 1

	ShouldMuffleHoosteps: =>
		return @GetSocksAsModel() or @GetSocksAsNewModel()

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

		@ent\SetNW2Bool('ppm2_fly', false)

		@ent\PPMBonesModifier()

		if scale = @GetSizeController()
			scale\PlayerRespawn()

		if weight = @GetWeightController()
			weight\PlayerRespawn()

		if CLIENT
			@deathRagdollMerged = false
			@GetRenderController()\PlayerRespawn() if @GetRenderController()
			@GetBodygroupController()\MergeModels(@ent) if IsValid(@ent) and @GetBodygroupController().MergeModels

	PlayerDeath: =>
		return if not IsValid(@ent)

		if @ent.__ppmBonesModifiers
			@ent.__ppmBonesModifiers\Remove()

		@entTable.__cachedIsPony = @ent\IsPony()

		if not @entTable.__cachedIsPony
			return if @alreadyCalledDeath
			@alreadyCalledDeath = true
		else
			@alreadyCalledDeath = false

		@ent\SetNW2Bool('ppm2_fly', false)

		if scale = @GetSizeController()
			scale\PlayerDeath()

		if weight = @GetWeightController()
			weight\PlayerDeath()

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

	GetPonyRaceFlags: =>
		switch @GetRace()
			when PPM2.RACE_EARTH
				return 0
			when PPM2.RACE_PEGASUS
				return PPM2.RACE_HAS_WINGS
			when PPM2.RACE_UNICORN
				return PPM2.RACE_HAS_HORN
			when PPM2.RACE_ALICORN
				return PPM2.RACE_HAS_HORN + PPM2.RACE_HAS_WINGS

	SlowUpdate: =>
		@GetBodygroupController()\SlowUpdate() if @GetBodygroupController()
		@GetWeightController()\SlowUpdate() if @GetWeightController()

		if scale = @GetSizeController()
			scale\SlowUpdate()

		if SERVER and IsValid(@ent) and @ent\IsPlayer()
			arms = @ent\GetHands()

			if IsValid(arms)
				cond = @GetPonyRaceFlags()\band(PPM2.RACE_HAS_HORN) ~= 0 and @ent\GetInfoBool('ppm2_cl_vm_magic_hands', true) and PPM2.HAND_BODYGROUP_MAGIC or PPM2.HAND_BODYGROUP_HOOVES
				arms\SetBodygroup(PPM2.HAND_BODYGROUP_ID, cond)

	Think: =>

	RenderScreenspaceEffects: =>
		time = RealTimeL()

		delta = time - @lastLerpThink
		@lastLerpThink = time

		if @isValid and IsValid(@ent)
			for _, change in ipairs @TriggerLerpAll(delta * 5)
				state = PPM2.NetworkChangeState('_NW_' .. change[1], change[1], change[2] + @['_NW_' .. change[1]], @)
				state\SetCantApply(true)
				@GenericDataChange(state)

	GetFlightController: => @flightController

	GetRenderController: =>
		return @renderController if SERVER or not @isValid or not @modelCached

		if not @renderController or @modelRender ~= @modelCached
			@modelRender = @modelCached

			cls = PPM2.GetRenderController(@modelCached)
			return @renderController if @renderController and cls == @renderController.__class

			@renderController\Remove() if @renderController
			@renderController = cls(@)

		return @renderController

	GetWeightController: =>
		return @weightController if not @isValid or not @modelCached

		if not @weightController or @modelWeight ~= @modelCached
			@modelWeight = @modelCached

			cls = PPM2.GetPonyWeightController(@modelCached)
			return @weightController if @weightController and cls == @weightController.__class

			@weightController\Remove() if @weightController
			@weightController = cls(@)

		return @weightController

	GetSizeController: =>
		return @scaleController if not @isValid or not @modelCached

		if not @scaleController or @modelScale ~= @modelCached
			@modelScale = @modelCached

			cls = PPM2.GetSizeController(@modelCached)
			return @scaleController if @scaleController and cls == @scaleController.__class

			@scaleController\Remove() if @scaleController
			@scaleController = cls(@)

		return @scaleController

	GetScaleController: => @GetSizeController()

	GetBodygroupController: =>
		return @bodygroups if not @isValid or not @modelCached

		if not @bodygroups or @modelBodygroups ~= @modelCached
			@modelBodygroups = @modelCached

			cls = PPM2.GetBodygroupController(@modelCached)
			return @bodygroups if @bodygroups and cls == @bodygroups.__class

			@bodygroups\Remove() if @bodygroups
			@bodygroups = cls(@)

		@bodygroups.ent = @ent
		return @bodygroups

	Remove: (byClient = false) =>
		@removed = true
		@@NW_Objects[@netID] = nil if SERVER or @NETWORKED
		@@O_Slots[@slotID] = nil if @slotID and @@O_Slots[@slotID] == @
		@isValid = false
		@ent = @GetEntity() if not IsValid(@ent)
		@@REGISTRY[@ent] = nil if IsValid(@ent) and @@REGISTRY[@ent] == @
		@@REGISTRY[@entID] = nil if @@REGISTRY[@entID] == @
		@GetWeightController()\Remove() if @GetWeightController()

		if CLIENT
			@GetRenderController()\Remove() if @GetRenderController()

			if IsValid(@ent) and @ent.__ppm2_task_hit
				@entTable.__ppm2_task_hit = false
				@ent\SetNoDraw(false)

		@GetBodygroupController()\Remove() if @GetBodygroupController()
		@GetSizeController()\Remove() if @GetSizeController()

		@flightController\Switch(false) if @flightController
		@@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]
		@@CheckTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task\GetDisableTask()]

		if SERVER and @NETWORKED
			net.Start('PPM2.PonyDataRemove')
			net.WriteUInt32(@netID)
			net.Broadcast()

	__tostring: => "[#{@@__name}:#{@netID}|#{@ent}]"

	GetOwner: => @ent
	IsNetworked: => @NETWORKED
	ShouldNetwork: => @SHOULD_NETWORK
	SetShouldNetwork: (val = @NETWORKED) => @SHOULD_NETWORK = val
	IsLocal: => @isLocal
	IsLocalObject: => @isLocal
	GetNetworkID: => @netID
	NetworkID: => @netID
	NetID: => @netID

	ComputeMagicColor: =>
		color = @GetHornMagicColor()

		if not @GetSeparateMagicColor()
			if not @GetSeparateEyes()
				color = @GetEyeIrisTop()\Lerp(0.5, @GetEyeIrisBottom())
			else
				lerpLeft = @GetEyeIrisTopLeft()\Lerp(0.5, @GetEyeIrisBottomLeft())
				lerpRight = @GetEyeIrisTopRight()\Lerp(0.5, @GetEyeIrisBottomRight())
				color = lerpLeft\Lerp(0.5, lerpRight)

		return color

	ReadNetworkData: (len = 24, ply = NULL, silent = false, applyEntities = true) =>
		data = @@ReadNetworkData()
		validPly = IsValid(ply)
		states = [PPM2.NetworkChangeState(key, keyValid, newVal, @, len, ply) for key, {keyValid, newVal} in pairs data]

		for _, state in ipairs states
			if not validPly or applyEntities or not isentity(state\GetValue())
				state\Apply()
				@NetworkDataChanges(state) unless silent

	ReadNetworkDataNotify: (len = 24, ply = NULL, silent = false, applyEntities = true) =>
		data = @@ReadNetworkData()
		validPly = IsValid(ply)
		states = [PPM2.NetworkChangeState(key, keyValid, newVal, @, len, ply) for key, {keyValid, newVal} in pairs data]

		for _, state in ipairs states
			if not validPly or applyEntities or not isentity(state\GetValue())
				state\Apply()
				@NetworkDataChanges(state) unless silent
				state\Notify()

	NetworkedIterable: (grabEntities = true) =>
		data = [{getName, @[strName]} for _, {:strName, :getName} in ipairs @@NW_Vars when grabEntities or not isentity(@[strName])]
		return data

	ApplyDataToObject: (target, applyEntities = false) =>
		target["Set#{key}"](target, value) for {key, value} in *@NetworkedIterable(applyEntities) when target["Set#{key}"]
		return target

	WriteNetworkData: => writeFunc(@[strName]) for _, {:strName, :writeFunc} in ipairs @@NW_Vars

	Create: =>
		return if @NETWORKED
		return if CLIENT and @CREATED_BY_SERVER -- wtf

		@NETWORKED = true if SERVER
		@SHOULD_NETWORK = true

		if SERVER
			net.Start(@@NW_Create)
			net.WriteUInt32(@netID)
			net.WriteEntity(@ent)
			@WriteNetworkData()

			if IsValid(@ent) and @ent\IsPlayer()
				net.SendOmit(@ent)
			else
				net.Broadcast()

			return

		@@NW_WaitID += 1
		@waitID = @@NW_WaitID
		@@NW_Waiting[@waitID] = @

		net.Start(@@NW_Create)
		net.WriteUInt32(@waitID)
		@WriteNetworkData()
		net.SendToServer()

	NetworkTo: (targets = {}) =>
		net.Start(@@NW_Create)
		net.WriteUInt32(@netID)
		net.WriteEntity(@ent)
		@WriteNetworkData()
		net.Send(targets)

	NetworkAll: =>
		net.Start(@@NW_Create)
		net.WriteUInt32(@netID)
		net.WriteEntity(@ent)
		@WriteNetworkData()
		net.Broadcast()

if CLIENT
	net.Receive 'PPM2.PonyDataRemove', ->
		readid = net.ReadUInt32()
		assert(PPM2.NetworkedPonyData\Get(readid), 'unknown ponydata ' .. readid .. ' to remove')\Remove()
else
	hook.Add 'PlayerJoinTeam', 'PPM2.TeamWaypoint', (ply, new) ->
		ply.__ppm2_modified_jump = false

	hook.Add 'OnPlayerChangedTeam', 'PPM2.TeamWaypoint', (ply, old, new) ->
		ply.__ppm2_modified_jump = false

_G.LocalPonyData = () -> LocalPlayer()\GetPonyData()
_G.LocalPonydata = () -> LocalPlayer()\GetPonyData()

do
	REGISTRY = PPM2.NetworkedPonyData.REGISTRY

	entMeta = FindMetaTable('Entity')
	EntIndex = entMeta.EntIndex

	entMeta.GetPonyData = =>
		index = EntIndex(@)
		return REGISTRY[index] if index > 0
		return REGISTRY[@]

	entMeta.SetPonyData = (data) =>
		index = EntIndex(@)

		if index > 0
			REGISTRY[index] = data
			return

		REGISTRY[@] = data

if SERVER
	net.pool('ppm2_force_wear')

	if player.GetCount() ~= 0
		for ply in *player.GetHumans()
			net.Start('ppm2_force_wear')
			net.Send(ply)
