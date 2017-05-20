
--
-- Copyright (C) 2017 DBot
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

class NetworkChangeState
	new: (key = '', keyValid = '', newValue, obj, len = 24, ply = NULL) =>
		@key = key
		@keyValid = keyValid
		@oldValue = obj[key]
		@newValue = newValue
		@ply = ply
		@time = CurTime()
		@rtime = RealTime()
		@stime = SysTime()
		@obj = obj
		@objID = obj.netID
		@len = len
		@rlen = len - 24 -- ID - 16 bits, variable id - 8 bits
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
	NewValue: => @newValue
	GetOldValue: => @oldValue
	OldValue: => @oldValue
	CurTime: => @time
	GetCurTime: => @time
	GetReceiveTime: => @time
	GetReceiveStamp: => @time
	RealTime: => @rtime
	GetRealTime: => @rtime
	SysTime: => @stime
	GetSysTime: => @stime
	GetObject: => @obj
	GetNWObject: => @obj
	GetNetworkedObject: => @obj
	GetLength: => @rlen
	GetRealLength: => @len
	ChangedByNetwork: => @networkChange

	Revert: => @obj[@key] = @oldValue
	Apply: => @obj[@key] = @newValue

class NetworkedObject
	@Setup = =>
		@NW_Vars = {} if @NW_Vars == nil
		@NW_VarsTable = {}
		@NW_Objects = {}
		@NW_Waiting = {}
		@NW_WaitID = -1
		@NW_Setup = true
		@NW_NextVarID = -1 if @NW_NextVarID == nil
		@NW_Create = "PPM2.NW.Created.#{@__name}"
		@NW_Modify = "PPM2.NW.Modified.#{@__name}"
		@NW_Remove = "PPM2.NW.Removed.#{@__name}"
		@NW_Rejected = "PPM2.NW.Rejected.#{@__name}"
		@NW_ReceiveID = "PPM2.NW.ReceiveID.#{@__name}"
		@NW_NextObjectID = 0
		@NW_NextObjectID_CL = 2 ^ 28

		if SERVER
			util.AddNetworkString(@NW_Create)
			util.AddNetworkString(@NW_Modify)
			util.AddNetworkString(@NW_Remove)
			util.AddNetworkString(@NW_ReceiveID)
		
		net.Receive @NW_Create, (len = 0, ply = NULL) -> @OnNetworkedCreated(ply, len)
		net.Receive @NW_Modify, (len = 0, ply = NULL) -> @OnNetworkedModify(ply, len)
		net.Receive @NW_Remove, (len = 0, ply = NULL) -> @OnNetworkedDelete(ply, len)
		net.Receive @NW_ReceiveID, (len = 0, ply = NULL) ->
			return if SERVER
			waitID = net.ReadUInt(16)
			netID = net.ReadUInt(16)
			obj = @NW_Waiting[netID]
			@NW_Waiting[netID] = nil
			return unless obj
			obj.NETWORKED = true
			@NW_Objects[obj.netID] = nil
			obj.netID = netID
			@NW_Objects[netID] = obj
		net.Receive @NW_Rejected, (len = 0, ply = NULL) ->
			return if SERVER
			netID = net.ReadUInt(16)
			obj = @NW_Objects[netID]
			return unless obj
			obj.NETWORKED = false
			obj\Create()
	-- @__inherited = (child) => child.Setup(child)

	@AddNetworkVar = (getName = 'Var', readFunc = (->), writeFunc = (->), defValue) =>
		strName = "_NW_#{getName}"
		error("No more free slots! Can't add #{getName} to the table") if @NW_NextVarID > 254
		@NW_NextVarID += 1
		id = @NW_NextVarID
		tab = {:strName, :readFunc, :getName, :writeFunc, :defValue, :id}
		table.insert(@NW_Vars, tab)
		@NW_VarsTable[id] = tab
		@__base[strName] = defValue
		@__base["Get#{getName}"] = => @[strName]
		@__base["Set#{getName}"] = (val = defValue, networkNow = true) =>
			oldVal = @[strName]
			@[strName] = val
			state = NetworkChangeState(strName, getName, val, @)
			state.networkChange = false
			@SetLocalChange(state)
			if networkNow and @NETWORKED and (CLIENT and @@NW_ClientsideCreation or SERVER)
				net.Start(@@NW_Modify)
				net.WriteUInt(@GetNetworkID(), 16)
				net.WriteUInt(id, 8)
				writeFunc(@[strName])
				if CLIENT
					net.SendToServer()
				else
					net.Broadcast()
	@NetworkVar = (...) => @AddNetworkVar(...)
	
	@NW_ClientsideCreation = false
	@NW_RemoveOnPlayerLeave = true
	@OnNetworkedCreated = (ply = NULL, len = 0) =>
		return if SERVER and not @NW_ClientsideCreation
		if CLIENT
			netID = net.ReadUInt(16)
			obj = @NW_Objects[netID] or @(netID)
			obj.NETWORKED = true
			obj.NETWORKED_PREDICT = true
			obj\ReadNetworkData()
			@OnNetworkedCreatedCallback(obj, ply, len)
		else
			waitID = net.ReadUInt(16)
			obj = @()
			obj.NW_Player = ply
			obj.NETWORKED_PREDICT = true
			obj\ReadNetworkData()
			obj\Create()
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
			net.Start(@NW_Rejected)
			net.WriteUInt(id, 16)
			net.Send(ply)
			return
		return if IsValid(ply) and obj.NW_Player ~= ply
		varID = net.ReadUInt(8)
		varData = @NW_VarsTable[varID]
		return unless varData
		{:strName, :getName, :readFunc, :writeFunc} = varData
		newVal = readFunc()
		state = NetworkChangeState(strName, getName, newVal, obj, len, ply)
		state\Apply()
		obj\NetworkDataChanges(state)
		if SERVER
			net.Start(@NW_Modify)
			net.WriteUInt(id, 16)
			net.WriteUInt(varID, 8)
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

	new: (netID, localObject = false) =>
		@valid = true
		@NETWORKED = false
		@NETWORKED_PREDICT = false

		if SERVER
			@netID = @@NW_NextObjectID
			@@NW_NextObjectID += 1
		else
			netID = -1 if netID == nil
			@netID = netID
		
		@@NW_Objects[@netID] = @
		@NW_Player = NULL
		@isLocal = localObject
		@NW_Player = LocalPlayer() if localObject
	
	IsValid: => @valid
	IsNetworked: => @NETWORKED
	IsGoingToNetwork: => @NETWORKED_PREDICT
	SetIsGoingToNetwork: (val = @NETWORKED) => @NETWORKED_PREDICT = val
	IsLocal: => @isLocal
	IsLocalObject: => @isLocal
	GetNetworkID: => @netID
	NetworkID: => @netID
	NetID: => @netID
	Remove: (byClient = false) =>
		@@NW_Objects[@netID] = nil
		@valid = false
		if CLIENT and @isLocal and @NETWORKED and @@NW_ClientsideCreation
			net.Start(@@NW_Remove)
			net.WriteUInt(@netID, 16)
			net.SendToServer()
		elseif SERVER and @NETWORKED
			net.Start(@@NW_Remove)
			net.WriteUInt(@netID, 16)
			if not IsValid(@NW_Player) or not byClient
				net.Broadcast()
			else
				net.SendOmit(@NW_Player)
	
	NetworkDataChanges: (state) => -- Override
	SetLocalChange: (state) => -- Override
	ReadNetworkData: (len = 24, ply = NULL, silent = false) =>
		data = @@ReadNetworkData()
		states = [NetworkChangeState(key, keyValid, newVal, @, len, ply) for key, {keyValid, newVal} in pairs data]
		for state in *states
			state\Apply()
			@NetworkDataChanges(state) unless silent
	
	WriteNetworkData: => writeFunc(@[strName]) for {:strName, :writeFunc} in *@@NW_Vars

	SendVar: (Var = '') =>
		return if @[Var] == nil
	
	Create: =>
		return if @NETWORKED
		return if CLIENT and not @@NW_ClientsideCreation
		@NETWORKED = true
		@NETWORKED_PREDICT = true
		if SERVER
			net.Start(@@NW_Create)
			net.WriteUInt(@netID, 16)
			@WriteNetworkData()
			filter = RecipientFilter()
			filter\AddAllPlayers()
			filter\RemovePlayer(@NW_Player) if IsValid(@NW_Player)
			net.Send(filter)
		else
			@@NW_WaitID += 1
			net.Start(@@NW_Create)
			net.WriteUInt(@@NW_WaitID, 16)
			@WriteNetworkData()
			net.SendToServer()
			@@NW_Waiting[@@NW_WaitID] = @
	NetworkTo: (targets = {}) =>
		net.Start(@@NW_Create)
		net.WriteUInt(@netID, 16)
		@WriteNetworkData()
		net.Send(targets)

PPM2.NetworkedObject = NetworkedObject
