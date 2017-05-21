
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

return if not VLL
VLL.LoadGMA('ppm2')

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
}

hook.Remove event, id for {event, id} in *oldhooks
timer.Remove('PPMStartTimer')
