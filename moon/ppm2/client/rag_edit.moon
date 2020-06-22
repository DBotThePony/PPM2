
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
			for _, fil in ipairs PPM2.PonyDataInstance\FindFiles()
				\AddOption "Use '#{fil}' data", ->
					net.Start('PPM2.RagdollEdit')
					net.WriteEntity(ent)
					net.WriteBool(false)
					data = PPM2.PonyDataInstance(fil, nil, true, true)
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
			for _, {:name, :sequence, :id, :time} in ipairs PPM2.AVALIABLE_EMOTES
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
