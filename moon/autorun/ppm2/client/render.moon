
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

RENDER_HORN_GLOW = CreateConVar('ppm2_horn_glow', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn glow when player uses physgun')
HORN_PARTICLES = CreateConVar('ppm2_horn_particles', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn particles when player uses physgun')
HORN_FP = CreateConVar('ppm2_horn_firstperson', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn effetcs in first person')
HORN_HIDE_BEAM = CreateConVar('ppm2_horn_nobeam', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Hide physgun beam')
TASK_RENDER_TYPE = CreateConVar('ppm2_task_render_type', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Task rendering type (e.g. pony ragdolls and NPCs). 1 - better render; less conflicts; more FPS. 0 - "old-style" render; possible conflicts;')
DRAW_LEGS_DEPTH = CreateConVar('ppm2_render_legsdepth', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Render legs in depth pass. Useful with Boken DoF enabled')
LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')
ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_new_ragdolls', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable new ragdolls')
SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_cl_draw_hands', '1', {FCVAR_ARCHIVE}, 'Should draw hooves as viewmodel')
SV_SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_sv_draw_hands', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Should draw hooves as viewmodel')

hook.Add 'PreDrawPlayerHands', 'PPM2.ViewModel', (arms = NULL, viewmodel = NULL, ply = LocalPlayer(), weapon = NULL) ->
    return if PPM2.__RENDERING_REFLECTIONS
    return true unless SV_SHOULD_DRAW_VIEWMODEL\GetBool()
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
    return if PPM2.__RENDERING_REFLECTIONS
    return unless IsValid(arms)
    return unless arms.__ppm2_draw
    data = ply\GetPonyData()
    return unless data
    data\GetRenderController()\PostDrawArms(arms)
    arms.__ppm2_draw = false

IN_DRAW = false

PPM2.PreDrawOpaqueRenderables = (bDrawingDepth, bDrawingSkybox) ->
    return if IN_DRAW
    return if PPM2.__RENDERING_REFLECTIONS
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

Think = ->
    if TASK_RENDER_TYPE\GetBool()
        for task in *PPM2.NetworkedPonyData.RenderTasks
            ent = task.ent
            if IsValid(ent) and ent.__cachedIsPony
                if ent.__ppm2_task_hit
                    ent.__ppm2_task_hit = false
                    ent\SetNoDraw(false)

                if not ent.__ppm2RenderOverride
                    ent = ent\GetEntity()
                    ent.__ppm2_oldRenderOverride = ent.RenderOverride
                    ent.__ppm2RenderOverride = ->
                        renderController = task\GetRenderController()
                        renderController\PreDraw(ent, true)
                        ent\DrawModel()
                        renderController\PostDraw(ent, true)
                        ent.__ppm2_oldRenderOverride(ent) if ent.__ppm2_oldRenderOverride
                    ent.RenderOverride = ent.__ppm2RenderOverride

PPM2.PostDrawOpaqueRenderables = (bDrawingDepth, bDrawingSkybox) ->
    return if IN_DRAW
    return if PPM2.__RENDERING_REFLECTIONS
    if bDrawingDepth and DRAW_LEGS_DEPTH\GetBool()
        with LocalPlayer()
            if .__cachedIsPony and \Alive()
                if data = \GetPonyData()
                    IN_DRAW = true
                    data\GetRenderController()\DrawLegsDepth()
                    IN_DRAW = false

    return if bDrawingDepth or bDrawingSkybox

    if not TASK_RENDER_TYPE\GetBool()
        for task in *PPM2.NetworkedPonyData.RenderTasks
            ent = task.ent
            if IsValid(ent)
                if ent.__cachedIsPony
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
    return if PPM2.__RENDERING_REFLECTIONS
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
    return if PPM2.__RENDERING_REFLECTIONS
    return unless @GetPonyData()
    return unless @__cachedIsPony
    data = @GetPonyData()
    renderController = data\GetRenderController()
    renderController\PostDraw() if renderController

do
    hornGlowStatus = {}
    smokeMaterial = 'ppm/hornsmoke'
    fireMat = 'particle/fire'
    hornShift = Vector(1, 0.15, 14.5)

    hook.Add 'Think', 'PPM2.HornEffects', =>
        frame = FrameNumber()
        for ent, status in pairs hornGlowStatus
            if not IsValid(ent)
                status.emmiter\Finish() if IsValid(status.emmiter)
                status.emmiterProp\Finish() if IsValid(status.emmiterProp)
                hornGlowStatus[ent] = nil
            elseif status.frame ~= frame
                status.data\SetHornGlow(status.prevStatus)
                status.emmiter\Finish() if IsValid(status.emmiter)
                status.emmiterProp\Finish() if IsValid(status.emmiterProp)
                hornGlowStatus[ent] = nil
            else
                if not status.prevStatus and RENDER_HORN_GLOW\GetBool() and status.data\GetHornGlow() ~= status.isEnabled
                    status.data\SetHornGlow(status.isEnabled)
                if status.attach and IsValid(status.target)
                    grabHornPos = Vector(hornShift) * status.data\GetPonySize()
                    {:Pos, :Ang} = ent\GetAttachment(status.attach)
                    grabHornPos\Rotate(Ang)
                    if status.isEnabled and IsValid(status.emmiter) and status.nextSmokeParticle < RealTime()
                        status.nextSmokeParticle = RealTime() + math.Rand(0.1, 0.5)
                        for i = 1, math.random(1, 4)
                            vec = VectorRand()
                            calcPos = Pos + grabHornPos + vec
                            with particle = status.emmiter\Add(smokeMaterial, calcPos)
                                \SetRollDelta(math.rad(math.random(0, 360)))
                                \SetPos(calcPos)
                                life = math.Rand(0.9, 3)
                                \SetStartAlpha(math.random(80, 170))
                                \SetDieTime(life)
                                \SetColor(status.color.r, status.color.g, status.color.b)
                                \SetEndAlpha(0)
                                size = math.Rand(2, 3)
                                \SetEndSize(math.Rand(2, size))
                                \SetStartSize(size)
                                \SetGravity(Vector())
                                \SetAirResistance(10)
                                vecRand = VectorRand()
                                vecRand.z *= 2
                                \SetVelocity(vecRand * status.data\GetPonySize() * 2)
                                \SetCollide(false)
                        for i = 1, math.random(2, 4)
                            vec = VectorRand() * 3
                            calcPos = Pos + grabHornPos + vec
                            with particle = status.emmiter\Add(fireMat, calcPos)
                                \SetRollDelta(math.rad(math.random(0, 360)))
                                \SetPos(calcPos)
                                life = math.Rand(0.9, 6)
                                \SetStartAlpha(math.random(80, 170))
                                \SetDieTime(life)
                                \SetColor(status.color2.r, status.color2.g, status.color2.b)
                                \SetEndAlpha(0)
                                \SetEndSize(0)
                                \SetStartSize(math.Rand(2, 3))
                                \SetGravity(Vector())
                                \SetAirResistance(0)
                                calcVel = calcPos - status.tpos
                                calcVel\Normalize()
                                calcVel *= calcPos\Distance(status.tpos) * .2
                                \SetVelocity(-calcVel)
                                \SetCollide(false)
                    if status.isEnabled and IsValid(status.emmiterProp) and status.nextGrabParticle < RealTime() and status.mins and status.maxs
                        status.nextGrabParticle = RealTime() + math.Rand(0.2, 0.9)
                        status.emmiterProp\SetPos(status.tpos)
                        for i = 1, math.random(5, 10)
                            calcPos = Vector(math.Rand(status.mins.x, status.maxs.x), math.Rand(status.mins.y, status.maxs.y), math.Rand(status.mins.z, status.maxs.z))
                            with particle = status.emmiterProp\Add(fireMat, calcPos)
                                \SetRollDelta(math.rad(math.random(0, 360)))
                                \SetPos(calcPos)
                                life = math.Rand(0.9, 6)
                                \SetStartAlpha(math.random(130, 230))
                                \SetDieTime(life)
                                \SetColor(status.bcolor.r, status.bcolor.g, status.bcolor.b)
                                \SetEndAlpha(0)
                                \SetEndSize(math.Rand(5, 15))
                                \SetStartSize(0)
                                \SetGravity(Vector(0, 0, -math.Rand(5, 15)))
                                \SetAirResistance(15)
                                \SetVelocity(VectorRand())
                                \SetCollide(false)

    hook.Add 'DrawPhysgunBeam', 'PPM2.HornEffects', (physgun = NULL, isEnabled = false, target = NULL, bone = 0, hitPos = Vector()) =>
        return if not HORN_FP\GetBool() and @ == LocalPlayer() and not @ShouldDrawLocalPlayer()
        data = @GetPonyData()
        return if not data
        return if data\GetRace() ~= PPM2.RACE_UNICORN and data\GetRace() ~= PPM2.RACE_ALICORN
        if not hornGlowStatus[@]
            hornGlowStatus[@] = {
                frame: FrameNumber()
                prevStatus: data\GetHornGlow()
                :data, :isEnabled, :hitPos, :target, :bone
                tpos: @GetPos()
                attach: @LookupAttachment('eyes')
                nextSmokeParticle: 0
                nextGrabParticle: 0
            }

            if HORN_PARTICLES\GetBool()
                hornGlowStatus[@].emmiter = ParticleEmitter(EyePos())
                hornGlowStatus[@].emmiterProp = ParticleEmitter(EyePos())

            hornGlowStatus[@].color = data\GetBodyColor()
            hornGlowStatus[@].color2 = data\GetHornDetailColor()

            if data\GetSeparateHorn()
                hornGlowStatus[@].color = data\GetHornColor()
                hornGlowStatus[@].bcolor = data\GetHornMagicColor()
            else
                hornGlowStatus[@].bcolor = hornGlowStatus[@].color
        else
            hornGlowStatus[@].frame = FrameNumber()
            hornGlowStatus[@].isEnabled = isEnabled
            hornGlowStatus[@].target = target
            hornGlowStatus[@].bone = bone
            hornGlowStatus[@].hitPos = hitPos
            if IsValid(target)
                hornGlowStatus[@].tpos = target\GetPos() + hitPos
                hornGlowStatus[@].mins, hornGlowStatus[@].maxs = target\WorldSpaceAABB()
        return not IsValid(target) if HORN_HIDE_BEAM\GetBool()

hook.Add 'PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw, 2
hook.Add 'PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw, 2
hook.Add 'PostDrawOpaqueRenderables', 'PPM2.PostDrawOpaqueRenderables', PPM2.PostDrawOpaqueRenderables, 2
hook.Add 'Think', 'PPM2.UpdateRenderTasks', Think, 2
hook.Add 'PreDrawOpaqueRenderables', 'PPM2.PreDrawOpaqueRenderables', PPM2.PreDrawOpaqueRenderables, 2
