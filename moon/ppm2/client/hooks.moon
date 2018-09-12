
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

hook.Add 'HUDPaint', 'PPM2.EditorStatus', ->
	lply = LocalPlayer()
	lpos = lply\EyePos()
	for _, ply in ipairs player.GetAll()
		if ply ~= lply
			if ply\GetDLibVar('PPM2.InEditor')
				pos = ply\EyePos()
				dist = pos\Distance(lpos)
				if dist < 250
					pos.z += 10
					alpha = math.Clamp(1.3 - dist / 250, 0.1, 1) * 255
					{:x, :y} = pos\ToScreen()
					draw.DrawText('In PPM/2 Editor', 'HudHintTextLarge', x + 1, y + 1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
					draw.DrawText('In PPM/2 Editor', 'HudHintTextLarge', x, y, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)

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
