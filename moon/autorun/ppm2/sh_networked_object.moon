
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

class NetworkedObject
	@Setup = =>
		@NW_Vars = {}
		@NW_Setup = true
		@NW_NextVarID = -1
		@NW_Create = "PPM2.NW.Created.#{@__name}"
		@NW_Modify = "PPM2.NW.Modified.#{@__name}"
		@NW_NextObjectID = -1

		if SERVER
			util.AddNetworkString(@NW_Create)
			util.AddNetworkString(@NW_Modify)
		
		net.Receive @NW_Create, (len = 0, ply = NULL) -> @OnNetworkedCreated(ply, len)
		net.Receive @NW_Modify, (len = 0, ply = NULL) ->

			@OnNetworkedModify(ply, len)

	@__inherited = (child) => child.Setup(child)
	@Setup()

	@AddNetworkVar = (strName = 'var', readFunc = (->), writeFunc = (->)) => table.insert(@NWVars, {:strName, :readFunc, :writeFunc})
	@OnNetworkedCreated = (ply = NULL, len = 0) =>
		-- Override
	@OnNetworkedModify = (ply = NULL, len = 0) =>
		-- Override
	
	@ReadNetworkData = =>
		

	new: (netID = @@NW_NextObjectID) =>
		if SERVER
			@netID = @@NW_NextObjectID
			@@NW_NextObjectID += 1
		else
			@netID = netID


PPM2.NetworkedObject = NetworkedObject
