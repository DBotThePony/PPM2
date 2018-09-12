
--
-- Copyright (C) 2017-2018 DBot

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
