
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

PPM2.ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_phys_ragdolls', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable physics ragdolls (Pre March 2020 gmod update workaround)')
ENABLE_NEW_RAGDOLLS = PPM2.ENABLE_NEW_RAGDOLLS
RAGDOLL_COLLISIONS = CreateConVar('ppm2_sv_ragdolls_collisions', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable ragdolls collisions')
BOTS_ARE_PONIES = CreateConVar('ppm2_bots', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Whatever spawn bots as ponies')

hook.Add 'PlayerSpawn', 'PPM2.Hooks', =>
	if IsValid(@__ppm2_ragdoll)
		@__ppm2_ragdoll\Remove()
		@UnSpectate()

	timer.Simple 0, ->
		return unless @IsValid()

		if data = @GetPonyData()
			data\PlayerRespawn()
			net.Start('PPM2.PlayerRespawn')
			net.WriteUInt32(data\NetworkID())
			net.Broadcast()

net.ReceiveAntispam('PPM2.Require', 4)

net.Receive 'PPM2.Require', (len = 0, ply = NULL) ->
	return if not IsValid(ply)

	for _, ent in ipairs ents.GetAll()
		data = ent\GetPonyData()
		data\NetworkTo(ply) if data and ent ~= ply

createPlayerRagdoll = =>
	@__ppm2_ragdoll\Remove() if IsValid(@__ppm2_ragdoll)
	@__ppm2_ragdoll = ents.Create('prop_ragdoll')
	rag = @GetRagdollEntity()
	rag\Remove() if IsValid(rag)
	with @__ppm2_ragdoll
		\SetModel(@GetModel())
		\SetPos(@GetPos())
		\SetAngles(@EyeAngles())
		\SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS) if RAGDOLL_COLLISIONS\GetBool()
		\SetCollisionGroup(COLLISION_GROUP_WORLD) if not RAGDOLL_COLLISIONS\GetBool()
		\Spawn()
		\Activate()
		hook.Run 'PlayerSpawnedRagdoll', @, @GetModel(), @__ppm2_ragdoll
		.__ppm2_ragdoll_parent = @
		\SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
		\SetNWBool('PPM2.IsDeathRagdoll', true)
		vel = @GetVelocity()
		\SetVelocity(vel)
		\SetAngles(@EyeAngles())
		@Spectate(OBS_MODE_CHASE)
		@SpectateEntity(@__ppm2_ragdoll)
		for boneID = 0, @__ppm2_ragdoll\GetBoneCount() - 1
			physobjID = @__ppm2_ragdoll\TranslateBoneToPhysBone(boneID)
			pos, ang = @GetBonePosition(boneID)
			physobj = @__ppm2_ragdoll\GetPhysicsObjectNum(physobjID)
			physobj\SetVelocity(vel)
			physobj\SetMass(300) -- lol
			physobj\SetPos(pos, true) if pos
			physobj\SetAngles(ang) if ang
		copy = @GetPonyData()\Clone(@__ppm2_ragdoll)
		copy\Create()
		@SetNWEntity('PPM2.DeathRagdoll', @__ppm2_ragdoll)

ALLOW_RAGDOLL_DAMAGE = CreateConVar('ppm2_sv_ragdoll_damage', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Should death ragdoll cause damage?')

hook.Add 'EntityTakeDamage', 'PPM2.DeathRagdoll', (dmg) =>
	attacker = dmg\GetAttacker()
	return if not IsValid(attacker)

	if attacker.__ppm2_ragdoll_parent
		dmg\SetAttacker(attacker.__ppm2_ragdoll_parent)

		if not ALLOW_RAGDOLL_DAMAGE\GetBool()
			dmg\SetDamage(0)
			dmg\SetMaxDamage(0)

hook.Add 'PostPlayerDeath', 'PPM2.Hooks', =>
	data = @GetPonyData()
	return if not data
	data\PlayerDeath()

	net.Start('PPM2.PlayerDeath')
	net.WriteUInt32(data\NetworkID())
	net.Broadcast()

	createPlayerRagdoll(@) if ENABLE_NEW_RAGDOLLS\GetBool() and @IsPony()
	return

hook.Add 'PlayerDeath', 'PPM2.Hooks', =>
	createPlayerRagdoll(@) if @GetPonyData() and ENABLE_NEW_RAGDOLLS\GetBool() and @IsPony()
	return

hook.Add 'EntityRemoved', 'PPM2.PonyDataRemove', =>
	data = @GetPonyData()
	data\Remove() if data
	return

hook.Add 'PlayerDisconnected', 'PPM2.NotifyClients', =>
	@__ppm2_ragdoll\Remove() if IsValid(@__ppm2_ragdoll)

hook.Add 'PlayerSetModel', 'PPM2.Bots', =>
	return if not BOTS_ARE_PONIES\GetBool() or not @IsBot()
	@SetModel('models/ppm/player_default_base_new.mdl')
	return true

PlayerSpawnBot = =>
	return if not BOTS_ARE_PONIES\GetBool() or not @IsBot()

	timer.Simple 1, ->
		return if not IsValid(@)

		@SetViewOffset(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET))
		@SetViewOffsetDucked(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET_DUCK))

		if not @GetPonyData()
			data = PPM2.NetworkedPonyData(nil, @)
			PPM2.Randomize(data)
			data\Create()

hook.Add 'PlayerSpawn', 'PPM2.Bots', PlayerSpawnBot
timer.Simple 0, -> PlayerSpawnBot(ply) for _, ply in ipairs player.GetAll()
