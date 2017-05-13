
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http\//www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

class NetworkChangeState
	new: (key = '', newValue, obj, len = 24, ply = NULL) =>
		@key = key
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
	GetPlayer: => @ply
	ChangedByClient: => IsValid(@ply)
	ChangedByPlayer: => IsValid(@ply)
	GetKey: => @key
	GetVariable: => @key
	GetVar: => @key
	GetNewValue: => @newValue
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

	Revert: => @obj[@key] = @oldValue
	Apply: => @obj[@key] = @newValue

class NetworkedObject
	@Setup = =>
		@NW_Vars = {}
		@NW_VarsTable = {}
		@NW_Objects = {}
		@NW_Setup = true
		@NW_NextVarID = -1
		@NW_Create = "PPM2.NW.Created.#{@__name}"
		@NW_Modify = "PPM2.NW.Modified.#{@__name}"
		@NW_NextObjectID = -1

		if SERVER
			util.AddNetworkString(@NW_Create)
			util.AddNetworkString(@NW_Modify)
		
		net.Receive @NW_Create, (len = 0, ply = NULL) -> @OnNetworkedCreated(ply, len)
		net.Receive @NW_Modify, (len = 0, ply = NULL) -> @OnNetworkedModify(ply, len)
	@__inherited = (child) => child.Setup(child)
	@Setup()

	@AddNetworkVar = (strName = 'var', readFunc = (->), writeFunc = (->)) =>
		@NW_NextVarID += 1
		tab = {:strName, :readFunc, :writeFunc, id: @NW_NextVarID}
		table.insert(@NW_Vars, tab)
		@NW_VarsTable[@NW_NextVarID] = tab
	
	@NW_ClientsideCreation = false
	@NW_RemoveOnPlayerLeave = true
	@OnNetworkedCreated = (ply = NULL, len = 0) =>
		return if not @NW_ClientsideCreation and IsValid(ply)
		@OnNetworkedCreatedCallback(ply, len)
	@OnNetworkedCreatedCallback = (ply = NULL, len = 0) => -- Override

	@OnNetworkedModify = (ply = NULL, len = 0) =>
		return if not @NW_ClientsideCreation and IsValid(ply)
		id = net.ReadUInt(16)
		obj = @NW_Objects[id]
		return unless obj
		return if IsValid(ply) and obj.NW_Player ~= ply
		varID = net.ReadUInt(8)
		varData = @NW_VarsTable[varID]
		return unless varData
		{:strName, :readFunc} = varData
		newVal = readFunc()
		state = NetworkChangeState(strName, newVal, obj, len, ply)
		state\Apply()
		obj\NetworkDataChanges(state)
		@OnNetworkedModifyCallback(state)
	@OnNetworkedModifyCallback = (state) => -- Override
	
	@ReadNetworkData = =>
		output = {strName, readFunc() for {:strName, :readFunc} in *@NW_Vars}
		return output

	new: (netID = @@NW_NextObjectID) =>
		@valid = true

		if SERVER
			@netID = @@NW_NextObjectID
			@@NW_NextObjectID += 1
		else
			@netID = netID
		
		@@NW_Objects[@netID] = @
	
	IsValid: => @valid
	Remove: =>
		@@NW_Objects[@netID] = nil
		@valid = false
	
	NetworkDataChanges: (state) => -- Override
	ReadNetworkData: (len = 24, ply = NULL, silent = false) =>
		data = @@ReadNetworkData()
		oldData = [{k, @[k], v} for k, v in pairs data]
		states = [NetworkChangeState(key, newVal, @, len, ply) for {key, oldVal, newVal} in *oldData]
		for state in *states
			state\Apply()
			@NetworkDataChanges(state) unless silent

PPM2.NetworkedObject = NetworkedObject
