
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

timer.Create 'PPM2.ModelChecks', 1, 0, ->
	for task in *PPM2.NetworkedPonyData.RenderTasks
		ent = task.ent
		if IsValid(ent)
			ent.__cachedIsPony = ent\IsPony()

	for ply in *player.GetAll()
		if not ply\IsDormant()
			ply.__cachedIsPony = ply\IsPony()
			ponydata = ply\GetPonyData()

			if ply.__cachedIsPony
				if (not ponydata or ponydata\GetHideWeapons()) and not hook.Run('SuppressPonyWeaponsHide', ply) and not ply.RenderOverride
					for wep in *ply\GetWeapons()
						if wep
							if not hook.Run('ShouldDrawPonyWeapon', ply, wep) and (not wep.ShouldPonyDraw or not wep\ShouldPonyDraw(ply))
								wep\SetNoDraw(true)
								wep.__ppm2_weapon_hit = true
							elseif wep.__ppm2_weapon_hit
								wep\SetNoDraw(false)
								ply.__ppm2_weapon_hit = false
				else
					for wep in *ply\GetWeapons()
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
	return if lastDataSend > RealTime()
	lastDataSend = RealTime() + 10
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
	for ply in *player.GetAll()
		if ply ~= lply
			if ply\GetNWBool('PPM2.InEditor')
				pos = ply\EyePos()
				dist = pos\Distance(lpos)
				if dist < 250
					pos.z += 10
					alpha = math.Clamp(1.3 - dist / 250, 0.1, 1) * 255
					{:x, :y} = pos\ToScreen()
					draw.DrawText('In PPM/2 Editor', 'HudHintTextLarge', x + 1, y + 1, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
					draw.DrawText('In PPM/2 Editor', 'HudHintTextLarge', x, y, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER)

concommand.Add 'ppm2_cleanup', ->
	for ent in *ents.GetAll()
		if ent.isPonyPropModel and not IsValid(ent.manePlayer)
			ent\Remove()
	PPM2.Message('All unused models were removed')

timer.Create 'PPM2.ModelCleanup', 60, 0, ->
	for ent in *ents.GetAll()
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
