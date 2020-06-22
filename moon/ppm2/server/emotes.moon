
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


util.AddNetworkString('PPM2.DamageAnimation')
util.AddNetworkString('PPM2.KillAnimation')
util.AddNetworkString('PPM2.AngerAnimation')
util.AddNetworkString('PPM2.PlayEmote')

hook.Add 'EntityTakeDamage', 'PPM2.Emotes', (ent, dmg) ->
	do
		self = ent
		if not @__ppm2_ragdoll_parent and @GetPonyData()
			@__ppm2_last_hurt_anim = @__ppm2_last_hurt_anim or 0
			if @__ppm2_last_hurt_anim < CurTimeL()
				@__ppm2_last_hurt_anim = CurTimeL() + 1
				net.Start('PPM2.DamageAnimation', true)
				net.WriteEntity(@)
				net.Broadcast()
	do
		self = dmg\GetAttacker()
		if @GetPonyData() and IsValid(ent) and (ent\IsNPC() or ent\IsPlayer() or ent.Type == 'nextbot')
			@__ppm2_last_anger_anim = @__ppm2_last_anger_anim or 0
			if @__ppm2_last_anger_anim < CurTimeL()
				@__ppm2_last_anger_anim = CurTimeL() + 1
				net.Start('PPM2.AngerAnimation', true)
				net.WriteEntity(@)
				net.Broadcast()

killGrin = =>
	return if not IsValid(@)
	return if not @GetPonyData()
	@__ppm2_grin_hurt_anim = @__ppm2_grin_hurt_anim or 0
	return if @__ppm2_grin_hurt_anim > CurTimeL()
	@__ppm2_grin_hurt_anim = CurTimeL() + 1
	net.Start('PPM2.KillAnimation', true)
	net.WriteEntity(@)
	net.Broadcast()

hook.Add 'OnNPCKilled', 'PPM2.Emotes', (npc = NULL, attacker = NULL, weapon = NULL) => killGrin(attacker)
hook.Add 'DoPlayerDeath', 'PPM2.Emotes', (ply = NULL, attacker = NULL) => killGrin(attacker)

net.Receive 'PPM2.PlayEmote', (len = 0, ply = NULL) ->
	return if not IsValid(ply)
	self = ply
	emoteID = net.ReadUInt(8)
	isEndless = net.ReadBool()
	shouldStop = net.ReadBool()
	return if not PPM2.AVALIABLE_EMOTES[emoteID]
	@__ppm2_last_played_emote = @__ppm2_last_played_emote or 0
	return if @__ppm2_last_played_emote > RealTimeL()
	@__ppm2_last_played_emote = RealTimeL() + 1
	net.Start('PPM2.PlayEmote')
	net.WriteUInt(emoteID, 8)
	net.WriteEntity(ply)
	net.WriteBool(isEndless)
	net.WriteBool(shouldStop)
	net.SendOmit(ply)
