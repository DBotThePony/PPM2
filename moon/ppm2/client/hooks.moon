
--
-- Copyright (C) 2017-2019 DBot

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


DLib.RegisterAddonName('PPM/2')

mat_dxlevel = GetConVar('mat_dxlevel')

timer.Create 'PPM2.Unsupported', 600, 4, ->
	if mat_dxlevel\GetInt() >= 90
		timer.Remove 'PPM2.Unsupported'
		return

	Derma_Message('gui.ppm2.dxlevel.not_supported', 'gui.ppm2.dxlevel.toolow')

timer.Create 'PPM2.ModelChecks', 1, 0, ->
	for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
		ent = task.ent
		if IsValid(ent)
			ent.__cachedIsPony = ent\IsPony()

	for _, ply in ipairs player.GetAll()
		if not ply\IsDormant()
			ply.__cachedIsPony = ply\IsPony()
			ponydata = ply\GetPonyData()

			if ply.__cachedIsPony
				if (not ponydata or ponydata\GetHideWeapons()) and not hook.Run('SuppressPonyWeaponsHide', ply) and not ply.RenderOverride
					for _, wep in ipairs ply\GetWeapons()
						if wep
							if not hook.Run('ShouldDrawPonyWeapon', ply, wep) and (not wep.ShouldPonyDraw or not wep\ShouldPonyDraw(ply))
								wep\SetNoDraw(true)
								wep.__ppm2_weapon_hit = true
							elseif wep.__ppm2_weapon_hit
								wep\SetNoDraw(false)
								ply.__ppm2_weapon_hit = false
				else
					for _, wep in ipairs ply\GetWeapons()
						if wep and wep.__ppm2_weapon_hit
							wep\SetNoDraw(false)
							ply.__ppm2_weapon_hit = false

PlayerRespawn = ->
	ent = net.ReadEntity()
	return if not IsValid(ent)
	return if not ent\GetPonyData()
	ent\GetPonyData()\PlayerRespawn()

PlayerDeath = ->
	ent = net.ReadEntity()
	return if not IsValid(ent)
	return if not ent\GetPonyData()
	ent\GetPonyData()\PlayerDeath()

lastDataSend = 0
lastDataReceived = 0

net.Receive 'PPM2.PlayerRespawn', PlayerRespawn
net.Receive 'PPM2.PlayerDeath', PlayerDeath

concommand.Add 'ppm2_require', ->
	net.Start('PPM2.Require')
	net.SendToServer()
	PPM2.Message 'Requesting pony data...'

concommand.Add 'ppm2_reload', ->
	return if lastDataSend > RealTimeL()
	lastDataSend = RealTimeL() + 10
	instance = PPM2.GetMainData()
	newData = instance\CreateNetworkObject()
	newData\Create()
	instance\SetNetworkData(newData)
	PPM2.Message 'Sending pony data to server...'

if not IsValid(LocalPlayer())
	times = 0
	hook.Add 'Think', 'PPM2.RequireData', ->
		ply = LocalPlayer()
		return if not IsValid(ply)
		times += 1 if ply\GetVelocity()\Length() > 5

		return if times < 200
		hook.Remove 'Think', 'PPM2.RequireData'
		hook.Add 'KeyPress', 'PPM2.RequireData', ->
			hook.Remove 'KeyPress', 'PPM2.RequireData'
			RunConsoleCommand('ppm2_reload')
			timer.Simple 3, -> RunConsoleCommand('ppm2_require')
else
	timer.Simple 0, ->
		RunConsoleCommand('ppm2_reload')
		timer.Simple 3, -> RunConsoleCommand('ppm2_require')

PPM_HINT_COLOR_FIRST = Color(255, 255, 255)
PPM_HINT_COLOR_SECOND = Color(0, 0, 0)

net.receive 'PPM2.EditorCamPos', ->
	ply = net.ReadPlayer()
	return if not ply\IsValid()
	ply.__ppm2_campos, ply.__ppm2_camang = LocalToWorld(net.ReadVector(), net.ReadAngle(), ply\GetPos(), ply\EyeAngles())

	if not IsValid(ply.__ppm2_cam)
		ply.__ppm2_cam = ClientsideModel('models/tools/camera/camera.mdl', RENDERGROUP_BOTH)
		ply.__ppm2_cam\SetModelScale(0.4)
		ply.__ppm2_cam.RenderOverride = =>
			render.DrawLine(ply.__ppm2_campos_lerp, ply\EyePos(), color_white, true)
			@DrawModel()

		hook.Add 'Think', ply.__ppm2_cam, =>
			return @Remove() if not IsValid(ply) or not ply\GetNWBool('PPM2.InEditor')
			ply.__ppm2_campos_lerp = Lerp(RealFrameTime() * 22, ply.__ppm2_campos_lerp or ply.__ppm2_campos, ply.__ppm2_campos)
			@SetPos(ply.__ppm2_campos_lerp)
			@SetAngles(ply.__ppm2_camang)

hook.Add 'HUDPaint', 'PPM2.EditorStatus', ->
	lply = LocalPlayer()
	lpos = lply\EyePos()

	editortext = DLib.i18n.localize('tip.ppm2.in_editor')

	for ply in *player.GetAll()
		if ply ~= lply and ply\GetNWBool('PPM2.InEditor')
			pos = ply\EyePos()
			dist = pos\Distance(lpos)

			if dist < 250
				pos.z += 10
				alpha = (1 - dist\progression(0, 250))\max(0.1) * 255
				{:x, :y} = pos\ToScreen()
				draw.DrawText(editortext, 'HudHintTextLarge', x, y, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
				draw.DrawText(editortext, 'HudHintTextLarge', x + 1, y + 1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)

			if ply.__ppm2_campos
				pos = Vector(ply.__ppm2_campos)
				dist = pos\Distance(lpos)

				if dist < 250
					pos.z += 9
					alpha = (1 - dist\progression(0, 250))\max(0.1) * 255
					{:x, :y} = pos\ToScreen()
					text = DLib.i18n.localize('tip.ppm2.camera', ply\Nick())
					draw.DrawText(text, 'HudHintTextLarge', x, y, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)
					draw.DrawText(text, 'HudHintTextLarge', x + 1, y + 1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)

concommand.Add 'ppm2_cleanup', ->
	for _, ent in ipairs ents.GetAll()
		if ent.isPonyPropModel and not IsValid(ent.manePlayer)
			ent\Remove()
	PPM2.Message('All unused models were removed')

timer.Create 'PPM2.ModelCleanup', 60, 0, ->
	for _, ent in ipairs ents.GetAll()
		if ent.isPonyPropModel and not IsValid(ent.manePlayer)
			ent\Remove()

cvars.AddChangeCallback('mat_picmip', (->
	timer.Simple 0, (->
		RunConsoleCommand('ppm2_require')
		RunConsoleCommand('ppm2_reload')
	)
), 'ppm2')

cvars.AddChangeCallback('ppm2_cl_hires_generic', (->
	timer.Simple 0, (->
		RunConsoleCommand('ppm2_require')
		RunConsoleCommand('ppm2_reload')
	)
), 'ppm2')

cvars.AddChangeCallback('ppm2_cl_hires_body', (->
	timer.Simple 0, (->
		RunConsoleCommand('ppm2_require')
		RunConsoleCommand('ppm2_reload')
	)
), 'ppm2')

return
