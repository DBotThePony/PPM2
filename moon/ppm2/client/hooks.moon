
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

net = DLib.net

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

net.Receive 'PPM2.PlayerRespawn', -> assert(PPM2.NetworkedPonyData\Get(net.ReadUInt32()), 'pony data is missing')\PlayerRespawn()
net.Receive 'PPM2.PlayerDeath', -> assert(PPM2.NetworkedPonyData\Get(net.ReadUInt32()), 'pony data is missing')\PlayerDeath()
net.Receive 'ppm2_force_wear', ->
	instance = PPM2.GetMainData()
	newData = instance\CreateNetworkObject()
	newData\Create()
	instance\SetNetworkObject(newData)

concommand.Add 'ppm2_require', ->
	net.Start('PPM2.Require')
	net.SendToServer()
	PPM2.Message 'Requesting pony data...'

concommand.Add 'ppm2_reload', ->
	instance = PPM2.GetMainData()
	newData = instance\CreateNetworkObject()
	newData\Create()
	instance\SetNetworkObject(newData)
	PPM2.Message 'Sending pony data to server...'

if IsValid(LocalPlayer())
	RunConsoleCommand('ppm2_reload')
	RunConsoleCommand('ppm2_require')
else
	hook.Add 'InitPostEntity', 'PPM2.LocalPonydataInit', ->
		RunConsoleCommand('ppm2_reload')
		RunConsoleCommand('ppm2_require')

net.receive 'PPM2.EditorCamPos', ->
	ply = net.ReadPlayer()
	return if not ply\IsValid()
	pVector, pAngle = net.ReadVector(), net.ReadAngle()

	if not IsValid(ply.__ppm2_cam)
		ply.__ppm2_cam = ClientsideModel('models/tools/camera/camera.mdl', RENDERGROUP_BOTH)
		ply.__ppm2_cam\SetModelScale(0.4)
		ply.__ppm2_cam.RenderOverride = =>
			return if not ply.__ppm2_campos_lerp
			render.DrawLine(ply.__ppm2_campos_lerp, ply\EyePos(), color_white, true)
			@DrawModel()

		hook.Add 'Think', ply.__ppm2_cam, =>
			return @Remove() if not IsValid(ply) or not ply\GetNWBool('PPM2.InEditor')
			findPos, findAng = LocalToWorld(pVector, pAngle, ply\GetPos(), ply\EyeAngles())
			ply.__ppm2_campos_lerp = Lerp(RealFrameTime() * 22, ply.__ppm2_campos_lerp or findPos, findPos)
			@SetPos(ply.__ppm2_campos_lerp)
			@SetAngles(findAng)

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

hook.Add 'PACChooseDeathRagdoll', 'PPM2.DeathRagdoll', (ragdoll) => @GetNWEntity('PPM2.DeathRagdoll') if IsValid(@GetNWEntity('PPM2.DeathRagdoll'))

concommand.Add 'ppm2_cleanup', ->
	for _, ent in ipairs ents.GetAll()
		if ent.isPonyPropModel and not IsValid(ent.manePlayer)
			ent\Remove()
	PPM2.Message('All unused models were removed')

timer.Create 'PPM2.ModelCleanup', 60, 0, -> ent\Remove() for ent in *ents.GetAll() when ent.isPonyPropModel and not IsValid(ent.manePlayer)

cvars.AddChangeCallback('mat_picmip', (->
	timer.Simple 0, (->
		RunConsoleCommand('ppm2_require')
		RunConsoleCommand('ppm2_reload')
	)
), 'ppm2')

cvars.AddChangeCallback('ppm2_cl_hires', (->
	timer.Simple 0, (->
		RunConsoleCommand('ppm2_require')
		RunConsoleCommand('ppm2_reload')
	)
), 'ppm2')

-- Jazztronauts cutscenes support
timer.Simple 0, ->
	if dialog and dialog.CreatePlayerProxy
		if info = debug.getinfo(dialog.CreatePlayerProxy)
			if info.short_src and (info.short_src\find('jazztronauts') or info.short_src\find('ppm2'))
				dialog._PPM2_CreatePlayerProxy = dialog._PPM2_CreatePlayerProxy or dialog.CreatePlayerProxy
				dialog.CreatePlayerProxy = (...) ->
					ent = dialog._PPM2_CreatePlayerProxy(...)

					if IsValid(ent)
						if data = LocalPonyData()
							ment = ent.Get and ent\Get() or ent
							newdata = PPM2.NetworkedPonyData(nil, ment) if not ment\GetPonyData()
							newdata = ment\GetPonyData() if ment\GetPonyData()
							ment.__ppm2RenderOverride = nil
							ment.__ppm2_oldRenderOverride = nil
							data\ApplyDataToObject(newdata)
							newdata\SetHideManes(false)
							newdata\SetHideManesSocks(false)

					return ent
return
