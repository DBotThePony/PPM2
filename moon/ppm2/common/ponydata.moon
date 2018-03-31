
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

checkForEntity = (ent) -> isentity(ent) or type(ent) == 'table' and ent.GetEntity and isentity(ent\GetEntity())

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
	CurTimeL: => @time
	GetCurTimeL: => @time
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

class NetworkedPonyData extends PPM2.ModifierBase
	@AddNetworkVar = (getName = 'Var', readFunc = (->), writeFunc = (->), defValue, onSet = ((val) => val), networkByDefault = true) =>
		defFunc = defValue
		defFunc = (-> defValue) if type(defValue) ~= 'function'
		strName = "_NW_#{getName}"
		@NW_NextVarID += 1
		id = @NW_NextVarID
		tab = {:strName, :readFunc, :getName, :writeFunc, :defValue, :defFunc, :id, :onSet}
		table.insert(@NW_Vars, tab)
		@NW_VarsTable[id] = tab
		@__base[strName] = defFunc()
		@__base["Get#{getName}"] = => @[strName]
		@__base["Set#{getName}"] = (val = defFunc(), networkNow = networkByDefault) =>
			oldVal = @[strName]
			@[strName] = val
			nevVal = onSet(@, val)
			state = PPM2.NetworkChangeState(strName, getName, nevVal, @)
			state.networkChange = false
			@SetLocalChange(state)
			if networkNow and @NETWORKED and (CLIENT and @@NW_ClientsideCreation and @GetOwner() == LocalPlayer() or SERVER)
				net.Start(@@NW_Modify)
				net.WriteUInt(@GetNetworkID(), 16)
				net.WriteUInt(id, 16)
				writeFunc(nevVal)
				if CLIENT
					net.SendToServer()
				else
					net.Broadcast()
	@NetworkVar = (...) => @AddNetworkVar(...)

	@OnNetworkedCreated = (ply = NULL, len = 0, nwobj) =>
		return if SERVER and not @NW_ClientsideCreation
		if CLIENT
			netID = net.ReadUInt(16)
			creator = NULL
			creator = net.ReadStrongEntity() if net.ReadBool()
			obj = @NW_Objects[netID] or @(netID)
			obj.NW_Player = creator
			obj.NETWORKED = true
			obj.CREATED_BY_SERVER = true
			obj.NETWORKED_PREDICT = true
			obj\ReadNetworkData()
			@OnNetworkedCreatedCallback(obj, ply, len)
		else
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

			waitID = net.ReadUInt(16)
			obj = @()
			obj.NW_Player = ply
			obj.NETWORKED_PREDICT = true
			obj\ReadNetworkData()
			obj\Create()
			timer.Simple 0.5, ->
				return if not IsValid(ply)
				net.Start(@NW_ReceiveID)
				net.WriteUInt(waitID, 16)
				net.WriteUInt(obj.netID, 16)
				net.Send(ply)
			@OnNetworkedCreatedCallback(obj, ply, len)
	@OnNetworkedCreatedCallback = (obj, ply = NULL, len = 0) => -- Override

	@OnNetworkedModify = (ply = NULL, len = 0) =>
		return if not @NW_ClientsideCreation and IsValid(ply)
		id = net.ReadUInt(16)
		obj = @NW_Objects[id]
		unless obj
			if SERVER
				net.Start(@NW_Rejected)
				net.WriteUInt(id, 16)
				net.Send(ply)
			return
		return if IsValid(ply) and obj.NW_Player ~= ply
		varID = net.ReadUInt(16)
		varData = @NW_VarsTable[varID]
		return unless varData
		{:strName, :getName, :readFunc, :writeFunc, :onSet} = varData
		newVal = onSet(obj, readFunc())
		return if newVal == obj["Get#{getName}"](obj)
		state = PPM2.NetworkChangeState(strName, getName, newVal, obj, len, ply)
		state\Apply()
		obj\NetworkDataChanges(state)
		if SERVER
			net.Start(@NW_Modify)
			net.WriteUInt(id, 16)
			net.WriteUInt(varID, 16)
			writeFunc(newVal)
			net.SendOmit(ply)
		@OnNetworkedModifyCallback(state)
	@OnNetworkedModifyCallback = (state) => -- Override

	@OnNetworkedDelete = (ply = NULL, len = 0) =>
		return if not @NW_ClientsideCreation and IsValid(ply)
		id = net.ReadUInt(16)
		obj = @NW_Objects[id]
		return unless obj
		obj\Remove(true)
		@OnNetworkedDeleteCallback(obj, ply, len)
	@OnNetworkedDeleteCallback = (obj, ply = NULL, len = 0) => -- Override

	@ReadNetworkData = =>
		output = {strName, {getName, readFunc()} for {:getName, :strName, :readFunc} in *@NW_Vars}
		return output

	@NW_RemoveOnPlayerLeave = true
	@NW_ClientsideCreation = true
	@RenderTasks = {}

	@NW_Vars = {}
	@NW_VarsTable = {}
	@NW_Objects = {}
	@NW_Waiting = {}
	@NW_WaitID = -1
	@NW_NextVarID = -1 if @NW_NextVarID == nil
	@NW_Create = "PPM2.NW.Created.#{@__name}"
	@NW_Modify = "PPM2.NW.Modified.#{@__name}"
	@NW_Broadcast = "PPM2.NW.ModifiedBroadcast.#{@__name}"
	@NW_Remove = "PPM2.NW.Removed.#{@__name}"
	@NW_Rejected = "PPM2.NW.Rejected.#{@__name}"
	@NW_ReceiveID = "PPM2.NW.ReceiveID.#{@__name}"
	@NW_CooldownTimerCount = "ppm2_NW_CooldownTimerCount_#{@__name}"
	@NW_CooldownTimer = "ppm2_NW_CooldownTimer_#{@__name}"
	@NW_CooldownMessage = "ppm2_NW_CooldownMessage_#{@__name}"
	@NW_NextObjectID = 0
	@NW_NextObjectID_CL = 2 ^ 28

	if SERVER
		net.pool(@NW_Create)
		net.pool(@NW_Modify)
		net.pool(@NW_Remove)
		net.pool(@NW_ReceiveID)
		net.pool(@NW_Rejected)
		net.pool(@NW_Broadcast)

	net.BindMessageGroup(@NW_Create, 'ppm2nwobject')
	net.BindMessageGroup(@NW_Modify, 'ppm2nwobject')
	net.BindMessageGroup(@NW_Remove, 'ppm2nwobject')
	net.BindMessageGroup(@NW_ReceiveID, 'ppm2nwobject')
	net.BindMessageGroup(@NW_Rejected, 'ppm2nwobject')
	net.BindMessageGroup(@NW_Broadcast, 'ppm2nwobject')

	net.Receive @NW_Create, (len = 0, ply = NULL, obj) -> @OnNetworkedCreated(ply, len, obj)
	net.Receive @NW_Modify, (len = 0, ply = NULL, obj) -> @OnNetworkedModify(ply, len, obj)
	net.Receive @NW_Remove, (len = 0, ply = NULL, obj) -> @OnNetworkedDelete(ply, len, obj)
	net.Receive @NW_ReceiveID, (len = 0, ply = NULL) ->
		return if SERVER
		waitID = net.ReadUInt(16)
		netID = net.ReadUInt(16)
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
		netID = net.ReadUInt(16)
		obj = @NW_Objects[netID]
		return unless obj
		return if obj.__LastReject and obj.__LastReject > RealTimeL()
		obj.__LastReject = RealTimeL() + 3
		obj.NETWORKED = false
		obj\Create()
	net.Receive @NW_Broadcast, (len = 0, ply = NULL) ->
		return if SERVER
		netID = net.ReadUInt(16)
		obj = @NW_Objects[netID]
		return unless obj
		obj\ReadNetworkData(len, ply)

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
		super()
		@recomputeTextures = true
		@isValid = true
		@valid = true
		@NETWORKED = false
		@NETWORKED_PREDICT = false

		@[data.strName] = data.defFunc() for data in *@@NW_Vars when data.defFunc

		if SERVER
			@netID = @@NW_NextObjectID
			@@NW_NextObjectID += 1
		else
			netID = -1 if netID == nil
			@netID = netID

		@@NW_Objects[@netID] = @
		@NW_Player = NULL if SERVER
		@NW_Player = LocalPlayer() if CLIENT
		@isLocal = localObject
		@NW_Player = LocalPlayer() if localObject
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
				state = PPM2.NetworkChangeState('_NW_' .. change[1], change[1], change[2] + @['_NW_' .. change[1]], @)
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

	GetOwner: => @NW_Player
	IsNetworked: => @NETWORKED
	IsGoingToNetwork: => @NETWORKED_PREDICT
	SetIsGoingToNetwork: (val = @NETWORKED) => @NETWORKED_PREDICT = val
	IsLocal: => @isLocal
	IsLocalObject: => @isLocal
	GetNetworkID: => @netID
	NetworkID: => @netID
	NetID: => @netID

	ReadNetworkData: (len = 24, ply = NULL, silent = false, applyEntities = true) =>
		data = @@ReadNetworkData()
		validPly = IsValid(ply)
		states = [PPM2.NetworkChangeState(key, keyValid, newVal, @, len, ply) for key, {keyValid, newVal} in pairs data]
		for state in *states
			if not validPly or applyEntities or not isentity(state\GetValue())
				state\Apply()
				@NetworkDataChanges(state) unless silent

	NetworkedIterable: (grabEntities = true) =>
		data = [{getName, @[strName]} for {:strName, :getName} in *@@NW_Vars when grabEntities or not checkForEntity(@[strName])]
		return data

	ApplyDataToObject: (target, applyEntities = false) =>
		for {key, value} in *@NetworkedIterable(applyEntities)
			target["Set#{key}"](target, value) if target["Set#{key}"]
		return target

	WriteNetworkData: => writeFunc(@[strName]) for {:strName, :writeFunc} in *@@NW_Vars

	ReBroadcast: =>
		return false if not @NETWORKED
		return false if CLIENT
		net.Start(@@NW_Broadcast)
		net.WriteUInt(@netID, 16)
		@WriteNetworkData()
		net.Broadcast()
		return true

	Create: =>
		return if @NETWORKED
		return if CLIENT and (not @@NW_ClientsideCreation or @CREATED_BY_SERVER)
		@NETWORKED = true if SERVER
		@NETWORKED_PREDICT = true
		if SERVER
			net.Start(@@NW_Create)
			net.WriteUInt(@netID, 16)
			net.WriteBool(IsValid(@NW_Player))
			net.WriteStrongEntity(@NW_Player) if IsValid(@NW_Player)
			@WriteNetworkData()
			net.CompressOngoing()
			filter = RecipientFilter()
			filter\AddAllPlayers()
			filter\RemovePlayer(@NW_Player) if IsValid(@NW_Player)
			net.Send(filter)
		else
			@@NW_WaitID += 1
			@waitID = @@NW_WaitID
			net.Start(@@NW_Create)
			before = net.BytesWritten()
			net.WriteUInt(@waitID, 16)
			@WriteNetworkData()
			net.CompressOngoing()
			after = net.BytesWritten()
			net.SendToServer()
			@@NW_Waiting[@waitID] = @
			return after - before
	NetworkTo: (targets = {}) =>
		net.Start(@@NW_Create)
		net.WriteUInt(@netID, 16)
		net.WriteBool(IsValid(@NW_Player))
		net.WriteStrongEntity(@NW_Player) if IsValid(@NW_Player)
		@WriteNetworkData()
		net.CompressOngoing()
		net.Send(targets)

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
