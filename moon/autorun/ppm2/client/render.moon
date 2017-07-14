
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
DRAW_LEGS_DEPTH = CreateConVar('ppm2_render_legsdepth', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Render legs in depth pass. Useful with Boken DoF enabled')
LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')
ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_new_ragdolls', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable new ragdolls')
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

IN_DRAW = false

PPM2.PreDrawOpaqueRenderables = (bDrawingDepth, bDrawingSkybox) ->
    return if IN_DRAW
    if bDrawingDepth and DRAW_LEGS_DEPTH\GetBool()
        with LocalPlayer()
            if .__cachedIsPony and \Alive()
                if data = \GetPonyData()
                    IN_DRAW = true
                    data\GetRenderController()\DrawLegsDepth()
                    IN_DRAW = false

    return if bDrawingDepth or bDrawingSkybox

    if not LEGS_RENDER_TYPE\GetBool()
        with LocalPlayer()
            if .__cachedIsPony and \Alive()
                if data = \GetPonyData()
                    IN_DRAW = true
                    data\GetRenderController()\DrawLegs()
                    IN_DRAW = false

PPM2.PostDrawOpaqueRenderables = (bDrawingDepth, bDrawingSkybox) ->
    return if IN_DRAW
    if bDrawingDepth and DRAW_LEGS_DEPTH\GetBool()
        with LocalPlayer()
            if .__cachedIsPony and \Alive()
                if data = \GetPonyData()
                    IN_DRAW = true
                    data\GetRenderController()\DrawLegsDepth()
                    IN_DRAW = false

    return if bDrawingDepth or bDrawingSkybox

    for task in *PPM2.NetworkedPonyData.RenderTasks
        ent = task.ent
        if IsValid(ent)
            if ent.__cachedIsPony
                if not TASK_RENDER_TYPE\GetBool()
                    ent\SetNoDraw(true)
                    ent.__ppm2_task_hit = true
                    renderController = task\GetRenderController()
                    renderController\PreDraw(ent)
                    IN_DRAW = true
                    ent\DrawModel()
                    IN_DRAW = false
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
                            IN_DRAW = true
                            rag\DrawModel()
                            IN_DRAW = false
                            renderController\PostDraw(rag)

    if LEGS_RENDER_TYPE\GetBool()
        with LocalPlayer()
            if .__cachedIsPony and \Alive()
                if data = \GetPonyData()
                    IN_DRAW = true
                    data\GetRenderController()\DrawLegs()
                    IN_DRAW = false

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

PPM2.PostPlayerDraw = =>
    return unless @GetPonyData()
    return unless @__cachedIsPony
    data = @GetPonyData()
    renderController = data\GetRenderController()
    renderController\PostDraw() if renderController

hook.Add 'PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw, 2
hook.Add 'PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw, 2
hook.Add 'PostDrawOpaqueRenderables', 'PPM2.PostDrawOpaqueRenderables', PPM2.PostDrawOpaqueRenderables, 2
hook.Add 'PreDrawOpaqueRenderables', 'PPM2.PreDrawOpaqueRenderables', PPM2.PreDrawOpaqueRenderables, 2
