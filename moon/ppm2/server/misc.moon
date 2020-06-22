
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


net.pool('PPM2.RequestPonyData')
net.pool('PPM2.PlayerRespawn')
net.pool('PPM2.PlayerDeath')
net.pool('PPM2.PostPlayerDeath')
net.pool('PPM2.Require')
net.pool('PPM2.EditorStatus')
net.pool('PPM2.NotifyDisconnect')
net.pool('PPM2.PonyDataRemove')
net.pool('PPM2.RagdollEdit')
net.pool('PPM2.RagdollEditFlex')
net.pool('PPM2.RagdollEditEmote')
net.pool('PPM2.EditorCamPos')

CreateConVar('ppm2_sv_draw_hands', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Should draw hooves as viewmodel')
CreateConVar('ppm2_sv_editor_dist', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED, FCVAR_ARCHIVE}, 'Distance limit in PPM/2 Editor/2')

resource.AddWorkshop('933203381')

net.receive 'PPM2.EditorCamPos', (len = 0, ply = NULL) ->
	return if not ply\IsValid()
	return if ply.__ppm2_lcpt and ply.__ppm2_lcpt > RealTime()
	ply.__ppm2_lcpt = RealTime() + 0.1
	camPos, camAng = net.ReadVector(), net.ReadAngle()

	filter = RecipientFilter()
	filter\AddPVS(ply\GetPos())
	filter\RemovePlayer(ply)

	return if filter\GetCount() == 0

	net.Start('PPM2.EditorCamPos')
	net.WritePlayer(ply)
	net.WriteVector(camPos)
	net.WriteAngle(camAng)
	net.Send(filter)

net.Receive 'PPM2.EditorStatus', (len = 0, ply = NULL) ->
	return if not IsValid(ply)
	ply\SetNWBool('PPM2.InEditor', net.ReadBool())
