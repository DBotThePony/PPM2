
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

genericUsageCheck = (ply, ent) ->
	return false if not IsValid(ply)
	return false if not IsValid(ent)
	return false if ALLOW_ONLY_RAGDOLLS\GetBool() and ent\GetClass() ~= 'prop_ragdoll'
	return false if DISALLOW_PLAYERS\GetBool() and ent\IsPlayer()
	return false if not ent\IsPony()
	return false if not hook.Run('CanTool', ply, {Entity: ent, HitPos: ent\GetPos(), HitNormal: Vector()}, 'ponydata')
	return false if not hook.Run('CanProperty', ply, 'ponydata', ent)
	return true

net.Receive 'PPM2.RagdollEdit', (len = 0, ply = NULL) ->
	ent = net.ReadEntity()
	useLocal = net.ReadBool()
	return if not genericUsageCheck(ply, ent)

	if useLocal
		return if not ply\GetPonyData()
		if not ent\GetPonyData()
			data = PPM2.NetworkedPonyData(nil, ent)

		data = ent\GetPonyData()
		plydata = ply\GetPonyData()
		plydata\ApplyDataToObject(data)

		data\Create() if not data\IsNetworked()
	else
		if not ent\GetPonyData()
			data = PPM2.NetworkedPonyData(nil, ent)

		data = ent\GetPonyData()
		data\ReadNetworkData(len, ply, false, false)
		data\ReBroadcast()
		data\Create() if not data\IsNetworked()

	duplicator.StoreEntityModifier(ent, 'ppm2_ragdolledit', ent\GetPonyData()\NetworkedIterable(false))

net.Receive 'PPM2.RagdollEditFlex', (len = 0, ply = NULL) ->
	ent = net.ReadEntity()
	status = net.ReadBool()
	return if not genericUsageCheck(ply, ent)

	if not ent\GetPonyData()
		data = PPM2.NetworkedPonyData(nil, ent)

	data = ent\GetPonyData()
	data\SetNoFlex(status)
	data\Create() if not data\IsNetworked()

net.Receive 'PPM2.RagdollEditEmote', (len = 0, ply = NULL) ->
	ent = net.ReadEntity()
	return if not genericUsageCheck(ply, ent)
	self = ply
	emoteID = net.ReadUInt(8)
	return if not PPM2.AVALIABLE_EMOTES[emoteID]
	@__ppm2_last_played_emote = @__ppm2_last_played_emote or 0
	return if @__ppm2_last_played_emote > RealTimeL()
	@__ppm2_last_played_emote = RealTimeL() + 1
	net.Start('PPM2.PlayEmote')
	net.WriteUInt(emoteID, 8)
	net.WriteEntity(ent)
	net.SendOmit(ply)

duplicator.RegisterEntityModifier 'ppm2_ragdolledit', (ply = NULL, ent = NULL, storeddata = {}) ->
	return if not IsValid(ent)
	if not ent\GetPonyData()
		data = PPM2.NetworkedPonyData(nil, ent)

	data = ent\GetPonyData()
	data["Set#{key}"](data, value, false) for {key, value} in *storeddata when data["Set#{key}"]
	data\ReBroadcast()
	timer.Simple 0.5, -> data\Create() if not data\IsNetworked()
