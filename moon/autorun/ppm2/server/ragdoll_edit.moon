
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

util.AddNetworkString('PPM2.RagdollEdit')

net.Receive 'PPM2.RagdollEdit', (len = 0, ply = NULL) ->
    return if not IsValid(ply)
    ent = net.ReadEntity()
    return if not IsValid(ent)
    return if ent\GetClass() ~= 'prop_ragdoll'
    return if not ent\IsPony()
    return if not hook.Run('CanTool', ply, {Entity: ent, HitPos: ent\GetPos(), HitNormal: Vector()}, 'ponydata')
    return if not hook.Run('CanProperty', ply, 'ponydata', ent)
    useLocal = net.ReadBool()

    if useLocal
        return if not ply\GetPonyData()
        if not ent\GetPonyData()
            data = PPM2.NetworkedPonyData(nil, ent)
        
        data = ent\GetPonyData()
        plydata = ply\GetPonyData()
        plydata\ApplyDataToObject(data)

        data\Create() if not data\IsNetworked()
    else
        if not ent\GetPonyData()
            data = PPM2.NetworkedPonyData(nil, ent)
        
        data = ent\GetPonyData()
        data\ReadNetworkData(len, ply, false, false)
        data\Create() if not data\IsNetworked()
