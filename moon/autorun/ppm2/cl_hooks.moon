
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

WATCH_WEAPONS = {}

timer.Create 'PPM2.ModelChecks', 1, 0, ->
    for ply in *player.GetAll()
        ply.__cachedIsPony = ply\IsPony()
        if ply.__ppm2_weapon_hit and not ply.__cachedIsPony
            wep\SetNoDraw(false) for wep in *ply\GetWeapons()
            ply.__ppm2_weapon_hit = false
    
    for i, wep in pairs WATCH_WEAPONS
        if not IsValid(wep)
            WATCH_WEAPONS[wep] = nil
            continue
        if not IsValid(wep\GetOwner())
            WATCH_WEAPONS[wep] = nil
            wep\SetNoDraw(false)

PPM2.PostDrawOpaqueRenderables = (a, b) ->
    return if a or b
    lply = LocalPlayer()

    for ply in *player.GetAll()
        if ply.__cachedIsPony
            wep = ply\GetActiveWeapon()
            if IsValid(wep)
                ply.__ppm2_weapon_hit = true
                wep\SetNoDraw(ply ~= lply or lply\ShouldDrawLocalPlayer())
                WATCH_WEAPONS[wep\EntIndex()] = wep

            if ply\GetPonyData() and not ply\Alive()
                data = ply\GetPonyData()
                rag = ply\GetRagdollEntity()
                if IsValid(rag)
                    rag\SetNoDraw(true)
                    renderController = data\GetRenderController()
                    if renderController
                        renderController\PreDraw()
                        rag\DrawModel()
                        renderController\PostDraw()

PPM2.PrePlayerDraw = =>
    return unless @GetPonyData()
    return unless @__cachedIsPony
    data = @GetPonyData()
    renderController = data\GetRenderController()
    renderController\PreDraw() if renderController
PPM2.PostPlayerDraw = =>
    return unless @GetPonyData()
    return unless @__cachedIsPony
    data = @GetPonyData()
    renderController = data\GetRenderController()
    renderController\PostDraw() if renderController

hook.Add 'PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw, -2
hook.Add 'PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw, -2
hook.Add 'PostDrawOpaqueRenderables', 'PPM2.PostDrawOpaqueRenderables', PPM2.PostDrawOpaqueRenderables, 2
hook.Add 'RenderScreenspaceEffects', 'PPM2.RenderScreenspaceEffects', ->
    self = LocalPlayer()

    if @__cachedIsPony and @GetPonyData() and @Alive()
        @GetPonyData()\GetRenderController()\DrawLegs()


RequestPonyData = ->
    instance = PPM2.GetMainData()
    newData = PPM2.NetworkedPonyData(nil, LocalPlayer())
    newData\SetEntity(LocalPlayer())
    for key, value in pairs instance\GetAsNetworked()
        newData["Set#{key}"](newData, value)
    newData\Create()
    instance\SetNetworkData(newData)

net.Receive 'PPM2.RequestPonyData', RequestPonyData

