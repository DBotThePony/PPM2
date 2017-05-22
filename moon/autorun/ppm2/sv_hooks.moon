
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

PPM2.PLAYER_VIEW_OFFSET = 64 * .7
PPM2.PLAYER_VIEW_OFFSET_DUCK = 28 * 1.2

hook.Add 'PostPlayerDeath', 'PPM2.Hooks', =>
    return if not @GetPonyData()
    data = @GetPonyData()
    bgController = data\GetBodygroupController()
    rag = @GetRagdollEntity()
    return if not IsValid(rag)
    bgController\MergeModels(rag) if bgController.MergeModels

hook.Add 'EntityTakeDamage', 'PPM2.Hooks', (ent, dmg) ->
    do
        self = ent
        if @IsPlayer()
            @__ppm2_last_hurt_anim = @__ppm2_last_hurt_anim or 0
            if @__ppm2_last_hurt_anim < CurTime()
                @__ppm2_last_hurt_anim = CurTime() + 1
                net.Start('PPM2.DamageAnimation', true)
                net.WriteEntity(@)
                net.Broadcast()
    do
        self = dmg\GetAttacker()
        if @IsPlayer() and IsValid(ent) and (ent\IsNPC() or ent\IsPlayer())
            @__ppm2_last_anger_anim = @__ppm2_last_anger_anim or 0
            if @__ppm2_last_anger_anim < CurTime()
                @__ppm2_last_anger_anim = CurTime() + 1
                net.Start('PPM2.AngerAnimation', true)
                net.WriteEntity(@)
                net.Broadcast()

killGrin = =>
    return if not IsValid(@)
    return if not @IsPlayer()
    @__ppm2_grin_hurt_anim = @__ppm2_grin_hurt_anim or 0
    return if @__ppm2_grin_hurt_anim > CurTime()
    @__ppm2_grin_hurt_anim = CurTime() + 1
    net.Start('PPM2.KillAnimation', true)
    net.WriteEntity(@)
    net.Broadcast()

hook.Add 'OnNPCKilled', 'PPM2.Hooks', (npc = NULL, attacker = NULL, weapon = NULL) => killGrin(attacker)
hook.Add 'DoPlayerDeath', 'PPM2.Hooks', (ply = NULL, attacker = NULL) => killGrin(attacker)

hook.Add 'PlayerSpawn', 'PPM2.Hooks', =>
    for ent in *ents.GetAll()
        if ent.isPonyPropModel and ent.manePlayer == @
            ent\Remove()

    timer.Simple 0.5, ->
        return unless @IsValid()
        return unless @IsPony()

        @SetViewOffset(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET))
        @SetViewOffsetDucked(Vector(0, 0, PPM2.PLAYER_VIEW_OFFSET_DUCK))
        if @GetPonyData()
            @GetPonyData()\ApplyBodygroups()
            net.Start('PPM2.PlayerRespawn')
            net.WriteEntity(@)
            net.Broadcast()
            return
        
        timer.Simple 0.5, ->
            net.Start('PPM2.RequestPonyData')
            net.Send(@)

hook.Add 'PlayerInitialSpawn', 'PPM2.Hooks', =>
    timer.Simple 0.5, ->
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
        print '[PPM2] Networking Error: ', err
        print debug.traceback()

    timer.Create 'PPM2.Require', 1, 0, -> xpcall(safeSendFunction, errorTrack)
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
