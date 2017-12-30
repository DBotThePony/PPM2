
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

ALLOW_ONLY_RAGDOLLS = CreateConVar('ppm2_sv_edit_ragdolls_only', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to edit only ragdolls')
DISALLOW_PLAYERS = CreateConVar('ppm2_sv_edit_no_players', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'When unrestricted edit allowed, do not allow to edit players.')

genericEditFilter = (ent = NULL, ply = NULL) =>
	return false if not IsValid(ent)
	return false if not IsValid(ply)
	return false if not ent\IsPony()
	return false if ALLOW_ONLY_RAGDOLLS\GetBool() and ent\GetClass() ~= 'prop_ragdoll'
	return false if DISALLOW_PLAYERS\GetBool() and ent\IsPlayer()
	return false if not ply\GetPonyData()
	return false if not hook.Run('CanProperty', ply, 'ponydata', ent)
	return false if not hook.Run('CanTool', ply, {Entity: ent, HitPos: ent\GetPos(), HitNormal: Vector()}, 'ponydata')
	return true

applyPonyData = {
	MenuLabel: 'Apply pony data...'
	Order: 2500
	MenuIcon: 'icon16/user.png'

	MenuOpen: (menu, ent = NULL, tr) =>
		return if not IsValid(ent)
		with menu\AddSubMenu()
			\AddOption 'Use Local data', ->
				net.Start('PPM2.RagdollEdit')
				net.WriteEntity(ent)
				net.WriteBool(true)
				net.SendToServer()
			\AddSpacer()
			for fil in *PPM2.PonyDataInstance\FindFiles()
				\AddOption "Use '#{fil}' data", ->
					net.Start('PPM2.RagdollEdit')
					net.WriteEntity(ent)
					net.WriteBool(false)
					data = PPM2.PonyDataInstance(fil, nil, true, true, false)
					data\WriteNetworkData()
					net.SendToServer()
	Filter: genericEditFilter
	Action: (ent = NULL) =>
}

ponyDataFlexEnable = {
	MenuLabel: 'Enable flexes'
	Order: 2501
	MenuIcon: 'icon16/emoticon_smile.png'

	MenuOpen: (menu, ent = NULL, tr) =>
	Filter: (ent = NULL, ply = NULL) =>
		return false if not genericEditFilter(@, ent, ply)
		return false if not ent\GetPonyData()
		return false if not ent\GetPonyData()\GetNoFlex()
		return true
	Action: (ent = NULL) =>
		return if not IsValid(ent)
		net.Start 'PPM2.RagdollEditFlex'
		net.WriteEntity(ent)
		net.WriteBool(false)
		net.SendToServer()
}

ponyDataFlexDisable = {
	MenuLabel: 'Disable flexes'
	Order: 2501
	MenuIcon: 'icon16/emoticon_unhappy.png'

	MenuOpen: (menu, ent = NULL, tr) =>
	Filter: (ent = NULL, ply = NULL) =>
		return false if not genericEditFilter(@, ent, ply)
		return false if not ent\GetPonyData()
		return false if ent\GetPonyData()\GetNoFlex()
		return true
	Action: (ent = NULL) =>
		return if not IsValid(ent)
		net.Start 'PPM2.RagdollEditFlex'
		net.WriteEntity(ent)
		net.WriteBool(true)
		net.SendToServer()
}

playEmote = {
	MenuLabel: 'Play pony emote'
	Order: 2502
	MenuIcon: 'icon16/emoticon_wink.png'

	MenuOpen: (menu, ent = NULL, tr) =>
		return if not IsValid(ent)
		with menu\AddSubMenu()
			for {:name, :sequence, :id, :time} in *PPM2.AVALIABLE_EMOTES
					\AddOption "Play '#{name}' emote", ->
						net.Start('PPM2.RagdollEditEmote')
						net.WriteEntity(ent)
						net.WriteUInt(id, 8)
						net.SendToServer()
						hook.Call('PPM2_EmoteAnimation', nil, ent, sequence, time)
	Filter: (ent = NULL, ply = NULL) =>
		return false if not genericEditFilter(@, ent, ply)
		return false if not ent\GetPonyData()
		return false if ent\GetPonyData()\GetNoFlex()
		return true
	Action: (ent = NULL) =>
}

properties.Add('ppm2.applyponydata', applyPonyData)
properties.Add('ppm2.enableflex', ponyDataFlexEnable)
properties.Add('ppm2.disableflex', ponyDataFlexDisable)
properties.Add('ppm2.playemote', playEmote)
