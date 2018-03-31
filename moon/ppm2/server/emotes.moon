
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

util.AddNetworkString('PPM2.DamageAnimation')
util.AddNetworkString('PPM2.KillAnimation')
util.AddNetworkString('PPM2.AngerAnimation')
util.AddNetworkString('PPM2.PlayEmote')

hook.Add 'EntityTakeDamage', 'PPM2.Emotes', (ent, dmg) ->
	do
		self = ent
		if @GetPonyData()
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
