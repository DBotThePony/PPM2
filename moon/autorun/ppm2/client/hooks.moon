
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

TASK_RENDER_TYPE = CreateConVar('ppm2_task_render_type', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Task rendering type (e.g. pony ragdolls and NPCs). 1 - better render; less conflicts; more FPS. 0 - "old-style" render; possible conflicts;')

timer.Create 'PPM2.ModelChecks', 1, 0, ->
    for task in *PPM2.NetworkedPonyData.RenderTasks
        ent = task.ent
        if IsValid(ent)
            ent.__cachedIsPony = ent\IsPony()
    
    for ply in *player.GetAll()
        ply.__cachedIsPony = ply\IsPony()

        if ply.__cachedIsPony
            for wep in *ply\GetWeapons()
                continue if not wep
                wep\SetNoDraw(true)
                wep.__ppm2_weapon_hit = true
        else
            for wep in *ply\GetWeapons()
                continue if not wep
                continue if not wep.__ppm2_weapon_hit
                wep\SetNoDraw(false)
                ply.__ppm2_weapon_hit = false

ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_new_ragdolls', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable new ragdolls')

PPM2.PostDrawOpaqueRenderables = (a, b) ->
    return if a or b

    for task in *PPM2.NetworkedPonyData.RenderTasks
        ent = task.ent
        if IsValid(ent)
            if ent.__cachedIsPony
                if not TASK_RENDER_TYPE\GetBool()
                    ent\SetNoDraw(true)
                    ent.__ppm2_task_hit = true
                    renderController = task\GetRenderController()
                    renderController\PreDraw(ent)
                    ent\DrawModel()
                    renderController\PostDraw(ent)
                else
                    if ent.__ppm2_task_hit
                        ent.__ppm2_task_hit = false
                        ent\SetNoDraw(false)
                    renderController = task\GetRenderController()
                    renderController\PreDraw(ent)
                    renderController\PostDraw(ent)
            else
                if ent.__ppm2_task_hit
                    ent.__ppm2_task_hit = false
                    ent\SetNoDraw(false)
                    task\Reset()
    
    if not ENABLE_NEW_RAGDOLLS\GetBool()
        for ply in *player.GetAll()
            alive = ply\Alive()
            ply.__ppm2_last_dead = RealTime() + 2 if not alive
            if ply.__cachedIsPony
                if ply\GetPonyData() and not alive
                    data = ply\GetPonyData()
                    rag = ply\GetRagdollEntity()
                    if IsValid(rag)
                        renderController = data\GetRenderController()
                        data\DoRagdollMerge()
                        if renderController
                            renderController\PreDraw(rag)
                            rag\DrawModel()
                            renderController\PostDraw(rag)

PPM2.PrePlayerDraw = =>
    return unless @GetPonyData()
    @__cachedIsPony = @IsPony()
    return if not @__cachedIsPony
    return if @__ppm2_last_draw == FrameNumber()
    @__ppm2_last_draw = FrameNumber()
    return if @IsDormant()
    @__ppm2_last_dead = @__ppm2_last_dead or 0
    return if @__ppm2_last_dead > RealTime()
    data = @GetPonyData()
    renderController = data\GetRenderController()
    status = renderController\PreDraw() if renderController
    data\GetWeightController()\UpdateWeight() if data\GetOverrideBones() and data\GetWeightController()
PPM2.PostPlayerDraw = =>
    return unless @GetPonyData()
    return unless @__cachedIsPony
    data = @GetPonyData()
    renderController = data\GetRenderController()
    renderController\PostDraw() if renderController

hook.Add 'PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw, 2
hook.Add 'PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw, 2
hook.Add 'PostDrawOpaqueRenderables', 'PPM2.PostDrawOpaqueRenderables', PPM2.PostDrawOpaqueRenderables, 2
hook.Add 'RenderScreenspaceEffects', 'PPM2.RenderScreenspaceEffects', ->
    self = LocalPlayer()

    if @__cachedIsPony and @GetPonyData() and @Alive()
        @GetPonyData()\GetRenderController()\DrawLegs()

SHOULD_DRAW_VIEWMODEL = CreateConVar('cl_ppm2_draw_hands', '1', {FCVAR_ARCHIVE}, 'Should draw hooves as viewmodel')

hook.Add 'PreDrawPlayerHands', 'PPM2.ViewModel', (arms = NULL, viewmodel = NULL, ply = LocalPlayer(), weapon = NULL) ->
    return true unless SHOULD_DRAW_VIEWMODEL\GetBool()
    return unless IsValid(arms)
    return unless ply.__cachedIsPony
    return unless ply\Alive()
    arms\SetPos(LocalPlayer()\EyePos() + Vector(0, 0, 100))
    wep = ply\GetActiveWeapon()
    if IsValid(wep) and wep.UseHands == false
        return true -- Dafuck?
    return if arms\GetModel() ~= 'models/cppm/pony_arms.mdl'
    data = ply\GetPonyData()
    return unless data
    status = data\GetRenderController()\PreDrawArms(arms)
    return status if status ~= nil
    arms.__ppm2_draw = true

hook.Add 'PostDrawPlayerHands', 'PPM2.ViewModel', (arms = NULL, viewmodel = NULL, ply = LocalPlayer(), weapon = NULL) ->
    return unless IsValid(arms)
    return unless arms.__ppm2_draw
    data = ply\GetPonyData()
    return unless data
    data\GetRenderController()\PostDrawArms(arms)
    arms.__ppm2_draw = false

PlayerRespawn = ->
    ent = net.ReadEntity()
    return if not IsValid(ent)
    return if not ent\GetPonyData()
    ent\GetPonyData()\PlayerRespawn()

PlayerDeath = ->
    ent = net.ReadEntity()
    return if not IsValid(ent)
    return if not ent\GetPonyData()
    ent\GetPonyData()\PlayerDeath()

lastDataSend = 0
lastDataReceived = 0
net.Receive 'PPM2.RequestPonyData', ->
    return if lastDataReceived > RealTime()
    lastDataReceived = RealTime() + 10
    RunConsoleCommand('ppm2_reload')

net.Receive 'PPM2.PlayerRespawn', PlayerRespawn
net.Receive 'PPM2.PlayerDeath', PlayerDeath

concommand.Add 'ppm2_require', ->
    net.Start('PPM2.Require')
    net.SendToServer()
    PPM2.Message 'Requesting pony data...'

concommand.Add 'ppm2_reload', ->
    return if lastDataSend > RealTime()
    lastDataSend = RealTime() + 10
    instance = PPM2.GetMainData()
    newData = instance\CreateNetworkObject()
    newData\Create()
    instance\SetNetworkData(newData)
    PPM2.Message 'Sending pony data to server...'

hook.Add 'KeyPress', 'PPM2.RequireData', ->
    hook.Remove 'KeyPress', 'PPM2.RequireData'
    RunConsoleCommand('ppm2_reload')
    timer.Simple 3, -> RunConsoleCommand('ppm2_require')

PPM_HINT_COLOR_FIRST = Color(255, 255, 255)
PPM_HINT_COLOR_SECOND = Color(0, 0, 0)

hook.Add 'HUDPaint', 'PPM2.EditorStatus', ->
    lply = LocalPlayer()
    lpos = lply\EyePos()
    for ply in *player.GetAll()
        if ply ~= lply
            if ply\GetNWBool('PPM2.InEditor')
                pos = ply\EyePos()
                dist = pos\Distance(lpos)
                if dist < 250
                    pos.z += 10
                    alpha = math.Clamp(1 - dist / 250, 0.1, 1)
                    {:x, :y} = pos\ToScreen()
                    draw.DrawText('In PPM/2 Editor', 'HudHintTextLarge', x + 1, y + 1, PPM_HINT_COLOR_SECOND, TEXT_ALIGN_CENTER)
                    draw.DrawText('In PPM/2 Editor', 'HudHintTextLarge', x, y, PPM_HINT_COLOR_FIRST, TEXT_ALIGN_CENTER)

concommand.Add 'ppm2_cleanup', ->
    for ent in *ents.GetAll()
        if ent.isPonyPropModel and not IsValid(ent.manePlayer)
            ent\Remove()
    PPM2.Message('All unused models were removed')

timer.Create 'PPM2.ModelCleanup', 60, 0, ->
    for ent in *ents.GetAll()
        if ent.isPonyPropModel and not IsValid(ent.manePlayer)
            ent\Remove()
