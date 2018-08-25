
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

import FrameNumberL, RealTimeL, StrongEntity, PPM2 from _G
import ALTERNATIVE_RENDER from PPM2
import GetPonyData, IsDormant, PPMBonesModifier, IsPony from FindMetaTable('Entity')

RENDER_HORN_GLOW = CreateConVar('ppm2_horn_glow', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn glow when player uses physgun')
HORN_PARTICLES = CreateConVar('ppm2_horn_particles', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn particles when player uses physgun')
HORN_FP = CreateConVar('ppm2_horn_firstperson', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn effetcs in first person')
HORN_HIDE_BEAM = CreateConVar('ppm2_horn_nobeam', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Hide physgun beam')
TASK_RENDER_TYPE = CreateConVar('ppm2_task_render_type', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Task rendering type (e.g. pony ragdolls and NPCs). 1 - better render; less conflicts; more FPS. 0 - "old-style" render; possible conflicts;')
DRAW_LEGS_DEPTH = CreateConVar('ppm2_render_legsdepth', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Render legs in depth pass. Useful with Boken DoF enabled')
LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')
ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_new_ragdolls', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable new ragdolls')
SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_cl_draw_hands', '1', {FCVAR_ARCHIVE}, 'Should draw hooves as viewmodel')
SV_SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_sv_draw_hands', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Should draw hooves as viewmodel')

hook.Add 'PreDrawPlayerHands', 'PPM2.ViewModel', (arms = NULL, viewmodel = NULL, ply = LocalPlayer(), weapon = NULL) ->
	return if PPM2.__RENDERING_REFLECTIONS
	return unless IsValid(arms)
	return unless ply.__cachedIsPony
	return true unless SV_SHOULD_DRAW_VIEWMODEL\GetBool()
	return true unless SHOULD_DRAW_VIEWMODEL\GetBool()
	return unless ply\Alive()
	arms\SetPos(ply\EyePos() + Vector(0, 0, 100))
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

mat_dxlevel = GetConVar('mat_dxlevel')

timer.Create 'PPM2.CheckDXLevel', 180, 0, ->
	if mat_dxlevel\GetInt() > 90
		timer.Remove 'PPM2.CheckDXLevel'
		return

	PPM2.Message('Direct3D Level is LESS THAN 9.1! This will not work!')

IN_DRAW = false
MARKED_FOR_DRAW = {}

PPM2.PreDrawOpaqueRenderables = (bDrawingDepth, bDrawingSkybox) ->
	return if IN_DRAW or PPM2.__RENDERING_REFLECTIONS

	MARKED_FOR_DRAW = {}

	if not ALTERNATIVE_RENDER\GetBool()
		for _, ply in ipairs player.GetAll()
			if not IsDormant(ply)
				p = IsPony(ply)
				ply.__cachedIsPony = p
				if p
					data = GetPonyData(ply)
					if data
						renderController = data\GetRenderController()
						if renderController
							renderController\PreDraw()
							table.insert(MARKED_FOR_DRAW, renderController)

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

PPM2.PostDrawTranslucentRenderables = (bDrawingDepth, bDrawingSkybox) ->
	if not ALTERNATIVE_RENDER\GetBool() and not bDrawingDepth and not bDrawingSkybox
		for _, draw in ipairs MARKED_FOR_DRAW
			draw\PostDraw()

PPM2.PostDrawOpaqueRenderables = (bDrawingDepth, bDrawingSkybox) ->
	return if IN_DRAW or PPM2.__RENDERING_REFLECTIONS

	if bDrawingDepth and DRAW_LEGS_DEPTH\GetBool()
		with LocalPlayer()
			if .__cachedIsPony and \Alive()
				if data = \GetPonyData()
					IN_DRAW = true
					data\GetRenderController()\DrawLegsDepth()
					IN_DRAW = false

	return if bDrawingDepth or bDrawingSkybox

	if not TASK_RENDER_TYPE\GetBool()
		for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
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
		for _, ply in ipairs player.GetAll()
			alive = ply\Alive()
			ply.__ppm2_last_dead = RealTimeL() + 2 if not alive
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

Think = ->
	if TASK_RENDER_TYPE\GetBool()
		for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
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

PPM2.PrePlayerDraw = =>
	return if PPM2.__RENDERING_REFLECTIONS
	if ALTERNATIVE_RENDER\GetBool()
		with data = GetPonyData(@)
			return if not data
			@__cachedIsPony = IsPony(@)
			return if not @__cachedIsPony
			f = FrameNumberL()
			return if @__ppm2_last_draw == f
			@__ppm2_last_draw = f
			@__ppm2_last_dead = @__ppm2_last_dead or 0
			return if @__ppm2_last_dead > RealTimeL()
			bones = PPMBonesModifier(@)
			if data and bones\CanThink()
				@ResetBoneManipCache()
				bones\ResetBones()
				hook.Call('PPM2.SetupBones', nil, StrongEntity(@), data) if data
				bones\Think()
				@ApplyBoneManipulations()
				@_ppmBonesModified = true
			renderController = data\GetRenderController()
			status = renderController\PreDraw() if renderController
	else
		with data = GetPonyData(@)
			return if not data
			@__cachedIsPony = IsPony(@)
			return if not @__cachedIsPony
			f = FrameNumberL()
			return if @__ppm2_last_draw == f
			@__ppm2_last_draw = f
			bones = PPMBonesModifier(@)
			if data and bones\CanThink()
				@ResetBoneManipCache()
				bones\ResetBones()
				hook.Call('PPM2.SetupBones', nil, StrongEntity(@), data) if data
				bones\Think()
				@ApplyBoneManipulations()
				@_ppmBonesModified = true

PPM2.PostPlayerDraw = =>
	return if not ALTERNATIVE_RENDER\GetBool() or PPM2.__RENDERING_REFLECTIONS
	with data = GetPonyData(@)
		return if not data or not @__cachedIsPony
		renderController = data\GetRenderController()
		renderController\PostDraw() if renderController

do
	hornGlowStatus = {}
	smokeMaterial = 'ppm2/hornsmoke'
	fireMat = 'particle/fire'
	hornShift = Vector(1, 0.15, 14.5)

	hook.Add 'PreDrawHalos', 'PPM2.HornEffects', =>
		return if not HORN_HIDE_BEAM\GetBool()
		frame = FrameNumberL()
		cTime = (RealTimeL() % 20) * 4
		for ent, status in pairs hornGlowStatus
			if IsValid(ent) and status.frame == frame and IsValid(status.target)
				additional = math.sin(cTime / 2 + status.haloSeed * 3) * 40
				newCol = DLib.AddColor(status.color, Color(additional, additional, additional))
				halo.Add({status.target}, newCol, math.sin(cTime + status.haloSeed) * 4 + 8, math.cos(cTime + status.haloSeed) * 4 + 8, 2)

	hook.Add 'Think', 'PPM2.HornEffects', =>
		frame = FrameNumberL()
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
					if status.isEnabled and IsValid(status.emmiter) and status.nextSmokeParticle < RealTimeL()
						status.nextSmokeParticle = RealTimeL() + math.Rand(0.1, 0.2)
						for i = 1, math.random(1, 4)
							vec = VectorRand()
							calcPos = Pos + grabHornPos + vec
							with particle = status.emmiter\Add(smokeMaterial, calcPos)
								\SetRollDelta(math.rad(math.random(0, 360)))
								\SetPos(calcPos)
								life = math.Rand(0.6, 0.9)
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
								\SetVelocity(ent\GetVelocity() + vecRand * status.data\GetPonySize() * 2)
								\SetCollide(false)
					if status.isEnabled and IsValid(status.emmiterProp) and status.nextGrabParticle < RealTimeL() and status.mins and status.maxs
						status.nextGrabParticle = RealTimeL() + math.Rand(0.05, 0.3)
						status.emmiterProp\SetPos(status.tpos)
						for i = 1, math.random(2, 6)
							calcPos = Vector(math.Rand(status.mins.x, status.maxs.x), math.Rand(status.mins.y, status.maxs.y), math.Rand(status.mins.z, status.maxs.z))
							with particle = status.emmiterProp\Add(fireMat, calcPos)
								\SetRollDelta(math.rad(math.random(0, 360)))
								\SetPos(calcPos)
								life = math.Rand(0.5, 0.9)
								\SetStartAlpha(math.random(130, 230))
								\SetDieTime(life)
								\SetColor(status.color.r, status.color.g, status.color.b)
								\SetEndAlpha(0)
								\SetEndSize(0)
								\SetStartSize(math.Rand(2, 6))
								\SetGravity(Vector())
								\SetAirResistance(15)
								\SetVelocity(VectorRand() * 6)
								\SetCollide(false)

	hook.Add 'DrawPhysgunBeam', 'PPM2.HornEffects', (physgun = NULL, isEnabled = false, target = NULL, bone = 0, hitPos = Vector()) =>
		return if not @IsPony() or not HORN_FP\GetBool() and @ == LocalPlayer() and not @ShouldDrawLocalPlayer()
		data = @GetPonyData()
		return if not data
		return if data\GetRace() ~= PPM2.RACE_UNICORN and data\GetRace() ~= PPM2.RACE_ALICORN
		if not hornGlowStatus[@]
			hornGlowStatus[@] = {
				frame: FrameNumberL()
				prevStatus: data\GetHornGlow()
				:data, :isEnabled, :hitPos, :target, :bone
				tpos: @GetPos()
				attach: @LookupAttachment('eyes')
				nextSmokeParticle: 0
				nextGrabParticle: 0
			}

			with hornGlowStatus[@]
				if HORN_PARTICLES\GetBool()
					.emmiter = ParticleEmitter(EyePos())
					.emmiterProp = ParticleEmitter(EyePos())

				.color = data\GetHornMagicColor()
				.haloSeed = math.rad(math.random(-1000, 1000))

				if not data\GetSeparateMagicColor()
					if not data\GetSeparateEyes()
						.color = DLib.LerpColor(0.5, data\GetEyeIrisTop(), data\GetEyeIrisBottom())
					else
						lerpLeft = DLib.LerpColor(0.5, data\GetEyeIrisTopLeft(), data\GetEyeIrisBottomLeft())
						lerpRight = DLib.LerpColor(0.5, data\GetEyeIrisTopRight(), data\GetEyeIrisBottomRight())
						.color = DLib.LerpColor(0.5, lerpLeft, lerpRight)
		else
			with hornGlowStatus[@]
				.frame = FrameNumberL()
				.isEnabled = isEnabled
				.target = target
				.bone = bone
				.hitPos = hitPos
				if IsValid(target)
					.tpos = target\GetPos() + hitPos
					center = target\WorldSpaceCenter()
					.center = center
					mins, maxs = target\WorldSpaceAABB()
					.mins = center + (mins - center) * 1.2
					.maxs = center + (maxs - center) * 1.2
		return false if HORN_HIDE_BEAM\GetBool() and IsValid(target)

hook.Add 'PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw, -2
hook.Add 'PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw, -2
hook.Add 'PostDrawOpaqueRenderables', 'PPM2.PostDrawOpaqueRenderables', PPM2.PostDrawOpaqueRenderables, -2
hook.Add 'Think', 'PPM2.UpdateRenderTasks', Think, -2
hook.Add 'PreDrawOpaqueRenderables', 'PPM2.PreDrawOpaqueRenderables', PPM2.PreDrawOpaqueRenderables, -2
hook.Add 'PostDrawTranslucentRenderables', 'PPM2.PostDrawTranslucentRenderables', PPM2.PostDrawTranslucentRenderables, -2
