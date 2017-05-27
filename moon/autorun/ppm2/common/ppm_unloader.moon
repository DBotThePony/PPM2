
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

timer.Simple 0, ->
    timer.Simple 1, ->
        timer.Simple 1, ->
            timer.Simple 1, ->
                return if not PPM
                oldhooks = {
                    {'PlayerDeath', 'ponyPlayerDeath'}
                    {'InitPostEntity', 'pony_initpostentity'}
                    {'EntityRemoved', 'pony_entityremoved'}
                    {'PlayerDisconnected', 'pony_playerdisconnected'}
                    {'PopulateToolMenu', 'ppm_menu'}
                    {'OnEntityCreated', 'pony_spawnent'}
                    {'PlayerSpawnedRagdoll', 'pony_spawnragdoll'}

                    {'HUDPaint', 'pony_render_textures'}
                    {'PlayerSpawn', 'pony_spawn'}
                    {'PostDrawOpaqueRenderables', 'test_Redraw'}
                    {'PrePlayerDraw', 'pony_draw'} 
                    {'PostPlayerDraw', 'pony_postdraw'}
                    {'OnReloaded', 'pony_reload'}

                    {'PlayerSetModel', 'items_Flush'}
                    {'PlayerSwitchWeapon', 'pony_weapons_autohide'}
                    {'PlayerLeaveVehicle', 'pony_fixclothes'}

                    {'PPM.Loaded', 'BodytexEditor3'}
                    {'PrePlayerDraw', 'pony_draw'}
                    {'PostPlayerDraw', 'pony_postdraw'}
                    {'PostDrawPlayerHands', 'DrawHands'}
                    {'EntityRemoved', 'PPM_RemoveData'}
                    {'EntityNetworkedVarChanged', 'PPMHook#1'}
                    {'NotifyShouldTransmit', 'CreatingTex'}
                    {'OnEntityCreated', 'EntitySpawn'}
                    {'InitPostEntity', 'PPM'}
                    {'OnReloaded', 'PPM.Reload'}
                    {'PopulateToolMenu', 'ppm_menu'}
                    {'PPM.Loaded', 'InitBodydetails'}
                    {'PlayerLeaveVehicle', 'pony_leave_vehicle'}
                    {'PPM_CheckNewModel', 'items_Flush'}
                    {'PlayerSwitchWeapon', 'pony_weapons_autohide'}
                    {'PlayerSpawnedRagdoll', 'pony_spawnragdoll'}
                    {'PlayerSpawn', 'pony_spawn'}
                    {'PostPlayerDeath', 'pony_death'}

                    -- CPPM hooks
                    {'UpdateAnimation', 'CPPMHook#1'}
                    {'PlayerTick', 'CPPMHook#1'}
                    {'UpdateAnimation', 'CPPMHook#2'}
                    {'NotifyShouldTransmit', 'CPPMHook#2'}
                    {'PlayerTick', 'CPPMHook#2'}
                    {'KeyPress', 'CPPMHook#3'}
                    {'EntityNetworkedVarChanged', 'CPPMHook#3'}
                    {'PlayerTick', 'CPPMHook#4'}
                    {'PreDrawPlayerHands', 'CPPMHook#4'}
                }

                hook.Remove event, id for {event, id} in *oldhooks
                timer.Remove('PPMStartTimer')

                title = 'CONFLICT!'
                text = 'AN CONFLICT HAS BEEN DETECTED?
When happened? - You have both PPM and PPM/2 installed!
PPM/2 is a rewrite, not an addon or something to
original PPM, you dumbass.
In order to reduce your stupid and dumb bug reports,
PPM/2 has disabled PPM functionality by removing it\'s hooks'

                PPM2.Message(title)
                PPM2.Message(text)

                return if not CLIENT

                Derma_Message(text, title, 'Kill yourself')
                