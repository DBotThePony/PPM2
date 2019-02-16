
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


ENABLE_SCAILING = CreateConVar('ppm2_sv_dmg', '1', {FCVAR_NOTIFY}, 'Enable hitbox damage scailing')
HEAD = CreateConVar('ppm2_sv_dmg_head', '2', {FCVAR_NOTIFY}, 'Damage scale when pony-player got shot in head')
CHEST = CreateConVar('ppm2_sv_dmg_chest', '1', {FCVAR_NOTIFY}, 'Damage scale when pony-player got shot in chest')
STOMACH = CreateConVar('ppm2_sv_dmg_stomach', '1', {FCVAR_NOTIFY}, 'Damage scale when pony-player got shot in stomach')
LEFTARM = CreateConVar('ppm2_sv_dmg_lfhoof', '0.75', {FCVAR_NOTIFY}, 'Damage scale when pony-player got shot in left-forward hoof')
RIGHTARM = CreateConVar('ppm2_sv_dmg_rfhoof', '0.75', {FCVAR_NOTIFY}, 'Damage scale when pony-player got shot in right-forward hoof')
LEFTLEG = CreateConVar('ppm2_sv_dmg_lbhoof', '0.75', {FCVAR_NOTIFY}, 'Damage scale when pony-player got shot in back-forward hoof')
RIGHTLEG = CreateConVar('ppm2_sv_dmg_rbhoof', '0.75', {FCVAR_NOTIFY}, 'Damage scale when pony-player got shot in back-forward hoof')

sk_player_head = GetConVar('sk_player_head')
sk_player_chest = GetConVar('sk_player_chest')
sk_player_stomach = GetConVar('sk_player_stomach')
sk_player_arm = GetConVar('sk_player_arm')
sk_player_leg = GetConVar('sk_player_leg')

hook.Add 'ScalePlayerDamage', 'PPM2.PlayerDamage', (group = HITGROUP_GENERIC, dmg) =>
	return if not @IsPonyCached()
	return if not ENABLE_SCAILING\GetBool()

	-- Reset damage to its original value
	-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/game/server/player.cpp#L180-L184
	-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/game/server/player.cpp#L923-L946

	--switch group
	--	when HITGROUP_HEAD
	--		dmg\ScaleDamage(1 / sk_player_head\GetFloat())
	--	when HITGROUP_CHEST
	--		dmg\ScaleDamage(1 / sk_player_chest\GetFloat())
	--	when HITGROUP_STOMACH
	--		dmg\ScaleDamage(1 / sk_player_stomach\GetFloat())
	--	when HITGROUP_RIGHTARM
	--		dmg\ScaleDamage(1 / sk_player_arm\GetFloat())
	--	when HITGROUP_RIGHTLEG
	--		dmg\ScaleDamage(1 / sk_player_leg\GetFloat())

	-- but fuck gmod
	-- https://github.com/Facepunch/garrysmod/blob/cf725f3f66072c83e4d96674814670c97eebb43d/garrysmod/gamemodes/base/gamemode/player.lua#L510

	switch group
		when HITGROUP_HEAD
			dmg\ScaleDamage(0.5)
		when HITGROUP_LEFTARM, HITGROUP_RIGHTARM, HITGROUP_LEFTLEG, HITGROUP_RIGHTLEG, HITGROUP_GEAR
			dmg\ScaleDamage(4)

	switch group
		when HITGROUP_HEAD
			dmg\ScaleDamage(HEAD\GetFloat())
		when HITGROUP_CHEST
			dmg\ScaleDamage(CHEST\GetFloat())
		when HITGROUP_STOMACH
			dmg\ScaleDamage(STOMACH\GetFloat())
		when HITGROUP_LEFTARM
			dmg\ScaleDamage(LEFTARM\GetFloat())
		when HITGROUP_RIGHTARM
			dmg\ScaleDamage(RIGHTARM\GetFloat())
		when HITGROUP_LEFTLEG
			dmg\ScaleDamage(RIGHTLEG\GetFloat())
		when HITGROUP_RIGHTLEG
			dmg\ScaleDamage(RIGHTLEG\GetFloat())
		when HITGROUP_GEAR
			dmg\ScaleDamage(CHEST\GetFloat())
		else
			dmg\ScaleDamage(1)
