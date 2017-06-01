
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

ALLOW_ONLY_RAGDOLLS = CreateConVar('ppm2_sv_edit_ragdolls_only', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to edit only ragdolls')

applyPonyData = {
	MenuLabel: 'Apply pony data...'
	Order: 2500
	MenuIcon: 'icon16/user.png'

	MenuOpen: (menu, ent, tr) =>
        with menu\AddSubMenu()
            \AddOption 'Use Local data', ->
                net.Start('PPM2.RagdollEdit')
                net.WriteEntity(ent)
                net.WriteBool(true)
                net.SendToServer()
            \AddSpacer()
            for fil in *PPM2.PonyDataInstance\FindFiles()
                \AddOption "Use '#{fil}' data", ->
                    net.Start('PPM2.RagdollEdit')
                    net.WriteEntity(ent)
                    net.WriteBool(false)
                    data = PPM2.PonyDataInstance(fil, nil, true, true, false)
                    data\WriteNetworkData()
                    net.SendToServer()
	Filter: (ent = NULL, ply = NULL) =>
        return false if not IsValid(ent)
        return false if not IsValid(ply)
        return false if not ent\IsPony()
        return false if ALLOW_ONLY_RAGDOLLS\GetBool() and ent\GetClass() ~= 'prop_ragdoll'
        return false if not ply\GetPonyData()
        return false if not hook.Run('CanProperty', ply, 'ponydata', ent)
        return false if not hook.Run('CanTool', ply, {Entity: ent, HitPos: ent\GetPos(), HitNormal: Vector()}, 'ponydata')
        return true
	Action: ->
}

properties.Add('ppm2.applyponydata', applyPonyData)
