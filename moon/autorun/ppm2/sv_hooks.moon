
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

net.Receive 'PPM2.Require', (len = 0, ply = NULL) ->
    return if not IsValid(ply)
    for ent in *ents.GetAll()
        data = ent\GetPonyData()
        continue if not data
        data\NetworkTo(ply)

net.Receive 'PPM2.EditorStatus', (len = 0, ply = NULL) ->
    return if not IsValid(ply)
    ply\SetNWBool('PPM2.InEditor', net.ReadBool())
