
--
-- Copyright (C) 2017 DBot
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

PPM2.PLAYER_VIEW_OFFSET = Vector(0, 0, 64 * .7)
PPM2.PLAYER_VIEW_OFFSET_DUCK = Vector(0, 0, 28 * 1.2)

PPM2.PLAYER_VIEW_OFFSET_ORIGINAL = Vector(0, 0, 64)
PPM2.PLAYER_VIEW_OFFSET_DUCK_ORIGINAL = Vector(0, 0, 28)

hook.Add 'PlayerSpawn', 'PPM2.Hooks', =>
    if IsValid(@__ppm2_ragdoll)
        @__ppm2_ragdoll\Remove()
        @UnSpectate()
    timer.Simple 0, ->
        return unless @IsValid()
        if @GetPonyData()
            @GetPonyData()\PlayerRespawn()
            net.Start('PPM2.PlayerRespawn')
            net.WriteEntity(@)
            net.Broadcast()
        
        if @IsPony()
            @__ppm2_pony_view_offset = true
            @SetViewOffset(PPM2.PLAYER_VIEW_OFFSET)
            @SetViewOffsetDucked(PPM2.PLAYER_VIEW_OFFSET_DUCK)
            
            return if @GetPonyData()
            timer.Simple 0.5, ->
                net.Start('PPM2.RequestPonyData')
                net.Send(@)
        else
            if @__ppm2_pony_view_offset
                @__ppm2_pony_view_offset = false
                @SetViewOffset(PPM2.PLAYER_VIEW_OFFSET_ORIGINAL)
                @SetViewOffsetDucked(PPM2.PLAYER_VIEW_OFFSET_DUCK_ORIGINAL)

hook.Add 'PlayerInitialSpawn', 'PPM2.Hooks', =>
    timer.Simple 0, ->
        return unless @IsValid()
        return unless @IsPony()

        timer.Simple 10, ->
            net.Start('PPM2.RequestPonyData')
            net.Send(@)

do
    REQUIRE_CLIENTS = {}

    safeSendFunction = ->
        for ply, data in pairs REQUIRE_CLIENTS
            if not IsValid(ply)
                REQUIRE_CLIENTS[ply] = nil
                continue
            
            ent = table.remove(data, 1)
            if not ent
                REQUIRE_CLIENTS[ply] = nil
                continue
            
            data = ent\GetPonyData()
            continue if not data
            data\NetworkTo(ply)
    
    errorTrack = (err) ->
        PPM2.Message 'Networking Error: ', err
        PPM2.Message debug.traceback()

    timer.Create 'PPM2.Require', 0.25, 0, -> xpcall(safeSendFunction, errorTrack)
    net.Receive 'PPM2.Require', (len = 0, ply = NULL) ->
        return if not IsValid(ply)
        REQUIRE_CLIENTS[ply] = for ent in *ents.GetAll()
            continue if ent == ply
            data = ent\GetPonyData()
            continue if not data
            ent

net.Receive 'PPM2.EditorStatus', (len = 0, ply = NULL) ->
    return if not IsValid(ply)
    ply\SetNWBool('PPM2.InEditor', net.ReadBool())

ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_new_ragdolls', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable new ragdolls')

createPlayerRagdoll = =>
    @__ppm2_ragdoll\Remove() if IsValid(@__ppm2_ragdoll)
    @__ppm2_ragdoll = ents.Create('prop_ragdoll')
    rag = @GetRagdollEntity()
    rag\Remove() if IsValid(rag)
    with @__ppm2_ragdoll
        \SetModel(@GetModel())
        \SetPos(@GetPos())
        \SetAngles(@EyeAngles())
        \SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
        \Spawn()
        \Activate()
        .__ppm2_ragdoll_parent = @
        \SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
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
        timer.Simple 0.5, -> copy\Create() if IsValid(@__ppm2_ragdoll)

hook.Add 'EntityTakeDamage', 'PPM2.DeathRagdoll', (dmg) =>
    attacker = dmg\GetAttacker()
    return if not IsValid(attacker)
    if attacker.__ppm2_ragdoll_parent
        dmg\SetAttacker(attacker.__ppm2_ragdoll_parent)

hook.Add 'PostPlayerDeath', 'PPM2.Hooks', =>
    return if not @GetPonyData()
    @GetPonyData()\PlayerDeath()
    net.Start('PPM2.PlayerDeath')
    net.WriteEntity(@)
    net.Broadcast()
    if ENABLE_NEW_RAGDOLLS\GetBool()
        createPlayerRagdoll(@)

hook.Add 'EntityRemoved', 'PPM2.PonyDataRemove', =>
    return if @IsPlayer()
    return if not @GetPonyData()
    with @GetPonyData()
        net.Start('PPM2.PonyDataRemove')
        net.WriteUInt(.netID, 16)
        net.Broadcast()
        \Remove()

hook.Add 'PlayerDisconnected', 'PPM2.NotifyClients', =>
    data = @GetPonyData()
    return if not data
    net.Start('PPM2.NotifyDisconnect')
    net.WriteUInt(data.netID, 16)
    net.Broadcast()

BOTS_ARE_PONIES = CreateConVar('ppm2_bots', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Whatever spawn bots as ponies')

hook.Add 'PlayerSetModel', 'PPM2.Bots', =>
    return if not BOTS_ARE_PONIES\GetBool()
    return if not @IsBot()
    @SetModel('models/ppm/player_default_base_new.mdl')
    return true

hook.Add 'PlayerSpawn', 'PPM2.Bots', =>
    return if not BOTS_ARE_PONIES\GetBool()
    return if not @IsBot()
    timer.Simple 1, ->
        return if not IsValid(@)
        @SetViewOffset(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET))
        @SetViewOffsetDucked(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET_DUCK))
        if not @GetPonyData()
            data = PPM2.NetworkedPonyData(nil, @)
            PPM2.Randomize(data)
            data\Create()
