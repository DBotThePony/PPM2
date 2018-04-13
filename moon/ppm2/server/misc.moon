
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

util.AddNetworkString('PPM2.RequestPonyData')
util.AddNetworkString('PPM2.PlayerRespawn')
util.AddNetworkString('PPM2.PlayerDeath')
util.AddNetworkString('PPM2.PostPlayerDeath')
util.AddNetworkString('PPM2.Require')
util.AddNetworkString('PPM2.EditorStatus')
util.AddNetworkString('PPM2.NotifyDisconnect')
util.AddNetworkString('PPM2.PonyDataRemove')
util.AddNetworkString('PPM2.RagdollEdit')
util.AddNetworkString('PPM2.RagdollEditFlex')
util.AddNetworkString('PPM2.RagdollEditEmote')

CreateConVar('ppm2_sv_draw_hands', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Should draw hooves as viewmodel')
CreateConVar('ppm2_sv_editor_dist', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Distance limit in PPM/2 Editor/2')
resource.AddWorkshop('933203381')
