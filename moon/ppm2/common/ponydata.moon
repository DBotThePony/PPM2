
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

do
	nullify = ->
		ProtectedCall ->
			for _, ent in ipairs ents.GetAll()
				ent.__PPM2_PonyData\Remove() if ent.__PPM2_PonyData

		for _, ent in ipairs ents.GetAll()
			ent.__PPM2_PonyData = nil

	nullify()
	timer.Simple 0, -> timer.Simple 0, -> timer.Simple 0, nullify
	hook.Add 'InitPostEntity', 'PPM2.FixSingleplayer', nullify

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
			nevVal = onSet(@, val)
			@[strName] = nevVal
			state = PPM2.NetworkChangeState(strName, getName, nevVal, @)
			state.networkChange = false
			@SetLocalChange(state)
			return unless networkNow and @NETWORKED and (CLIENT and @ent == LocalPlayer() or SERVER)
			net.Start(@@NW_Modify)
			net.WriteUInt(@GetNetworkID(), 16)
			net.WriteUInt(id, 16)
			writeFunc(nevVal)
			net.SendToServer() if CLIENT
			net.Broadcast() if SERVER

	@NetworkVar = (...) => @AddNetworkVar(...)
	@GetSet = (fname, fvalue) =>
		@__base["Get#{fname}"] = => @[fvalue]
		@__base["Set#{fname}"] = (fnewValue = @[fvalue]) =>
			oldVal = @[fvalue]
			@[fvalue] = fnewValue
			state = PPM2.NetworkChangeState(fvalue, fname, fnewValue, @)
			state.networkChange = false
			@SetLocalChange(state)

	@NW_WAIT = {}

	if CLIENT
		hook.Add 'OnEntityCreated', 'PPM2.NW_WAIT', (ent) -> timer.Simple 0, ->
			return if not IsValid(ent)

			dirty = false
			entid = ent\EntIndex()
			ttl = RealTimeL()

			for controller in *@NW_WAIT
				if controller.removed
					controller.isNWWaiting = false
					dirty = true
				elseif controller.waitEntID == entid
					controller.isNWWaiting = false
					controller.ent = ent
					controller.modelCached = ent\GetModel()
					controller\SetupEntity(ent)
					--print('FOUND', ent)
					dirty = true
				elseif controller.waitTTL < ttl
					dirty = true
					controller.isNWWaiting = false

			if dirty
				@NW_WAIT = [controller for controller in *@NW_WAIT when controller.isNWWaiting]

		hook.Add 'NotifyShouldTransmit', 'PPM2.NW_WAIT', (ent, should) -> timer.Simple 0, ->
			return if not IsValid(ent)

			dirty = false
			entid = ent\EntIndex()
			ttl = RealTimeL()

			for controller in *@NW_WAIT
				if controller.removed
					controller.isNWWaiting = false
					dirty = true
				elseif controller.waitEntID == entid
					controller.isNWWaiting = false
					controller.ent = ent
					controller.modelCached = ent\GetModel()
					controller\SetupEntity(ent)
					--print('FOUND', ent)
					dirty = true
				elseif controller.waitTTL < ttl
					dirty = true
					controller.isNWWaiting = false

			if dirty
				@NW_WAIT = [controller for controller in *@NW_WAIT when controller.isNWWaiting]

	@OnNetworkedCreated = (ply = NULL, len = 0, nwobj) =>
		if CLIENT
			netID = net.ReadUInt16()
			entid = net.ReadUInt16()
			obj = @NW_Objects[netID] or @(netID, entid)
			obj.NETWORKED = true
			obj.CREATED_BY_SERVER = true
			obj.NETWORKED_PREDICT = true
			obj\ReadNetworkData()
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

			waitID = net.ReadUInt16()
			obj = @(nil, ply)
			obj.NETWORKED_PREDICT = true
			obj\ReadNetworkData()
			obj\Create()
			timer.Simple 0.5, ->
				return if not IsValid(ply)
				net.Start(@NW_ReceiveID)
				net.WriteUInt(waitID, 16)
				net.WriteUInt(obj.netID, 16)
				net.Send(ply)

	@OnNetworkedModify = (ply = NULL, len = 0) =>
		id = net.ReadUInt16()
		obj = @NW_Objects[id]

		unless obj
			return if CLIENT
			net.Start(@NW_Rejected)
			net.WriteUInt(id, 16)
			net.Send(ply)
			return

		if IsValid(ply) and obj.ent ~= ply
			error('Invalid realm for player being specified. If you are running on your own net.* library, check up your code') if CLIENT
			net.Start(@NW_Rejected)
			net.WriteUInt(id, 16)
			net.Send(ply)
			return

		varID = net.ReadUInt16()
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

	@OnNetworkedDelete = (ply = NULL, len = 0) =>
		id = net.ReadUInt16()
		obj = @NW_Objects[id]
		return unless obj
		obj\Remove(true)

	@ReadNetworkData = =>
		output = {strName, {getName, readFunc()} for _, {:getName, :strName, :readFunc} in ipairs @NW_Vars}
		return output

	@RenderTasks = {}
	@CheckTasks = {}

	@NW_Vars = {}
	@NW_VarsTable = {}
	@NW_Objects = {}
	@O_Slots = {} if CLIENT
	@NW_Waiting = {}
	@NW_WaitID = -1
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
	@NW_NextObjectID = 0
	@NW_NextObjectID_CL = 0x60000

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
		waitID = net.ReadUInt16()
		netID = net.ReadUInt16()
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
		netID = net.ReadUInt16()
		obj = @NW_Objects[netID]
		return unless obj
		return if obj.__LastReject and obj.__LastReject > RealTimeL()
		obj.__LastReject = RealTimeL() + 3
		obj.NETWORKED = false
		obj\Create()

	net.Receive @NW_Broadcast, (len = 0, ply = NULL) ->
		return if SERVER
		netID = net.ReadUInt16()
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

		@m_upperManeModel = Entity(-1)
		@m_lowerManeModel = Entity(-1)
		@m_tailModel = Entity(-1)
		@m_socksModel = Entity(-1)
		@m_newSocksModel = Entity(-1)

		@recomputeTextures = true
		@isValid = true
		@removed = false
		@valid = true
		@NETWORKED = false
		@NETWORKED_PREDICT = false

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

			if not @slotID
				error('dafuq? No empty slots are available')

		@isNWWaiting = false

		if type(ent) == 'number'
			entid = ent
			@waitEntID = entid
			ent = Entity(entid)
			--print(ent, entid)

			if not IsValid(ent)
				@isNWWaiting = true
				@waitTTL = RealTimeL() + 3600
				table.insert(@@NW_WAIT, @)
				PPM2.LMessage('message.ppm2.debug.race_condition')
				--print('WAITING ON ', entid)
				return

		return if not IsValid(ent)
		@ent = ent
		@modelCached = ent\GetModel() if IsValid(ent)
		@SetupEntity(ent)

	GetEntity: => @ent
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
		if ent.__PPM2_PonyData
			return if ent.__PPM2_PonyData\GetOwner() and IsValid(ent.__PPM2_PonyData\GetOwner()) and ent.__PPM2_PonyData\GetOwner() ~= @GetOwner()
			ent.__PPM2_PonyData\Remove() if ent.__PPM2_PonyData.Remove and ent.__PPM2_PonyData ~= @

		ent.__PPM2_PonyData = @
		@entTable = @ent\GetTable()
		return unless IsValid(ent)
		@modelCached = ent\GetModel()
		ent\PPMBonesModifier()
		@flightController = PPM2.PonyflyController(@)
		@entID = ent\EntIndex()
		@lastLerpThink = RealTimeL()
		@ModelChanges(@modelCached, @modelCached)
		@Reset()
		timer.Simple(0, -> @GetRenderController()\CompileTextures() if @GetRenderController()) if CLIENT
		PPM2.DebugPrint('Ponydata ', @, ' was updated to use for ', @ent)
		@@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]
		@@CheckTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task\GetDisableTask()]

	ModelChanges: (old = @ent\GetModel(), new = old) =>
		@modelCached = new
		@SetFly(false) if SERVER
		timer.Simple 0.5, ->
			return unless IsValid(@ent)
			@Reset()

	GenericDataChange: (state) =>
		hook.Run 'PPM2_PonyDataChanges', @ent, @, state

		if state\GetKey() == 'Fly' and @flightController
			@flightController\Switch(state\GetValue())

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
		@SetFly(false) if SERVER

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

		@SetFly(false) if SERVER

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
		@removed = true
		@@NW_Objects[@netID] = nil if SERVER or @NETWORKED
		@@O_Slots[@slotID] = nil if @slotID
		@isValid = false
		@ent = @GetEntity() if not IsValid(@ent)
		@entTable.__PPM2_PonyData = nil if IsValid(@ent) and @ent.__PPM2_PonyData == @
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

	__tostring: => "[#{@@__name}:#{@netID}|#{@ent}]"

	GetOwner: => @ent
	IsNetworked: => @NETWORKED
	IsGoingToNetwork: => @NETWORKED_PREDICT
	SetIsGoingToNetwork: (val = @NETWORKED) => @NETWORKED_PREDICT = val
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

	NetworkedIterable: (grabEntities = true) =>
		data = [{getName, @[strName]} for _, {:strName, :getName} in ipairs @@NW_Vars when grabEntities or not isentity(@[strName])]
		return data

	ApplyDataToObject: (target, applyEntities = false) =>
		target["Set#{key}"](target, value) for {key, value} in *@NetworkedIterable(applyEntities) when target["Set#{key}"]
		return target

	WriteNetworkData: => writeFunc(@[strName]) for _, {:strName, :writeFunc} in ipairs @@NW_Vars

	ReBroadcast: =>
		return false if not @NETWORKED
		return false if CLIENT
		net.Start(@@NW_Broadcast)
		net.WriteUInt16(@netID)
		@WriteNetworkData()
		net.Broadcast()
		return true

	Create: =>
		return if @NETWORKED
		return if CLIENT and @CREATED_BY_SERVER -- wtf
		@NETWORKED = true if SERVER
		@NETWORKED_PREDICT = true

		if SERVER
			net.Start(@@NW_Create)
			net.WriteUInt16(@netID)
			net.WriteEntity(@ent)
			@WriteNetworkData()
			filter = RecipientFilter()
			filter\AddAllPlayers()
			filter\RemovePlayer(@ent) if IsValid(@ent) and @ent\IsPlayer()
			net.Send(filter)
		else
			@@NW_WaitID += 1
			@waitID = @@NW_WaitID

			net.Start(@@NW_Create)
			before = net.BytesWritten()

			net.WriteUInt16(@waitID)
			@WriteNetworkData()
			after = net.BytesWritten()

			net.SendToServer()
			@@NW_Waiting[@waitID] = @
			return after - before

	NetworkTo: (targets = {}) =>
		net.Start(@@NW_Create)
		net.WriteUInt16(@netID)
		net.WriteEntity(@ent)
		@WriteNetworkData()
		net.Send(targets)

PPM2.NetworkedPonyData = NetworkedPonyData

if CLIENT
	net.Receive 'PPM2.NotifyDisconnect', ->
		netID = net.ReadUInt16()
		data = NetworkedPonyData.NW_Objects[netID]
		return if not data
		data\Remove()

	net.Receive 'PPM2.PonyDataRemove', ->
		netID = net.ReadUInt16()
		data = NetworkedPonyData.NW_Objects[netID]
		return if not data
		data\Remove()
else
	hook.Add 'PlayerJoinTeam', 'PPM2.TeamWaypoint', (ply, new) ->
		ply.__ppm2_modified_jump = false
	hook.Add 'OnPlayerChangedTeam', 'PPM2.TeamWaypoint', (ply, old, new) ->
		ply.__ppm2_modified_jump = false

_G.LocalPonyData = () -> LocalPlayer()\GetPonyData()
_G.LocalPonydata = () -> LocalPlayer()\GetPonyData()

entMeta = FindMetaTable('Entity')
entMeta.GetPonyData = =>
	self2 = @
	self = entMeta.GetTable(@)
	return if not @
	if @__PPM2_PonyData and @__PPM2_PonyData.ent ~= self2
		@__PPM2_PonyData.ent = self2
		@__PPM2_PonyData\SetupEntity(self2) if CLIENT
	return @__PPM2_PonyData
