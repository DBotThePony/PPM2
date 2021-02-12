
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


import FrameNumberL, RealTimeL, PPM2 from _G
import GetPonyData, IsDormant, PPMBonesModifier, IsPony from FindMetaTable('Entity')

RENDER_HORN_GLOW = CreateConVar('ppm2_horn_glow', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn glow when player uses physgun')
HORN_PARTICLES = CreateConVar('ppm2_horn_particles', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn particles when player uses physgun')
HORN_FP = CreateConVar('ppm2_horn_firstperson', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Visual horn effetcs in first person')
HORN_HIDE_BEAM = CreateConVar('ppm2_horn_nobeam', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Hide physgun beam')
DRAW_LEGS_DEPTH = CreateConVar('ppm2_render_legsdepth', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'Render legs in depth pass. Useful with Boken DoF enabled')
LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')
PPM2.ENABLE_NEW_RAGDOLLS = CreateConVar('ppm2_sv_phys_ragdolls', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Enable physics ragdolls (Pre March 2020 gmod update workaround)')
ENABLE_NEW_RAGDOLLS = PPM2.ENABLE_NEW_RAGDOLLS
SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_cl_draw_hands', '1', {FCVAR_ARCHIVE}, 'Should draw hooves as viewmodel')
SV_SHOULD_DRAW_VIEWMODEL = CreateConVar('ppm2_sv_draw_hands', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Should draw hooves as viewmodel')

VM_MAGIC = CreateConVar('ppm2_cl_vm_magic', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Modify viewmodel when pony has horn for more immersion. Has no effect when ppm2_cl_vm_magic_hands is on')
VM_MAGIC_HANDS = CreateConVar('ppm2_cl_vm_magic_hands', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_USERINFO}, 'Use magic hands when pony has horn. Due to gmod behavior, sometimes this does not work')

PPM2.VM_MAGIC = VM_MAGIC
PPM2.VM_MAGIC_HANDS = VM_MAGIC_HANDS

validHands = (hands) -> hands == 'models/ppm/c_arms_pony.mdl'

hook.Add 'PreDrawPlayerHands', 'PPM2.ViewModel', (arms = NULL, viewmodel = NULL, ply = LocalPlayer(), weapon = NULL) ->
	return if PPM2.__RENDERING_REFLECTIONS or not IsValid(arms) or not ply.__cachedIsPony
	observer = ply\GetObserverTarget()
	return if IsValid(observer) and not observer.__cachedIsPony
	return true if not SV_SHOULD_DRAW_VIEWMODEL\GetBool() or not SHOULD_DRAW_VIEWMODEL\GetBool()

	if IsValid(observer)
		return if not observer\Alive()
	else
		return if not ply\Alive()

	arms\SetPos(ply\EyePos() + Vector(0, 0, 100))
	wep = ply\GetActiveWeapon()

	return true if IsValid(wep) and wep.UseHands == false
	amodel = arms\GetModel()
	return if not validHands(amodel)

	data = ply\GetPonyData()
	return unless data

	return true if data\GetPonyRaceFlags()\band(PPM2.RACE_HAS_HORN) ~= 0 and VM_MAGIC\GetBool() and not VM_MAGIC_HANDS\GetBool()

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

local lastPos, lastAng

CalcViewModelView = (weapon, vm, oldPos, oldAng, pos, ang) ->
	return if not VM_MAGIC\GetBool() or VM_MAGIC_HANDS\GetBool()
	ply = LocalPlayer()
	return if PPM2.__RENDERING_REFLECTIONS or not IsValid(vm) or not ply.__cachedIsPony
	observer = ply\GetObserverTarget()
	return if IsValid(observer) and not observer.__cachedIsPony
	return if not SV_SHOULD_DRAW_VIEWMODEL\GetBool() or not SHOULD_DRAW_VIEWMODEL\GetBool()

	if IsValid(observer)
		return if not observer\Alive()
	else
		return if not ply\Alive()

	return if ply\GetPonyRaceFlags()\band(PPM2.RACE_HAS_HORN) == 0
	return if IsValid(weapon) and weapon.UseHands == false
	shouldShift = not (weapon.IsTFA and weapon\IsTFA() and weapon.IronSightsProgress > 0.6)
	-- since pos and ang never get refreshed, i would modify those to get desired results
	-- with other addons installed

	if shouldShift
		fwd = ply\EyeAngles()\Forward()
		right = ply\EyeAngles()\Right()
		pos2 = pos + fwd * math.sin(CurTimeL()) + right * math.cos(CurTimeL() + 1.2) + right * 4 - fwd * 2
		ang2 = Angle(ang)
		pos.z -= 4
		ang2\RotateAroundAxis(ang\Forward(), -30)
		lastPos = pos2
		lastAng = ang2
	else
		lastPos = LerpVector(FrameTime() * 11, lastPos or pos, pos)
		lastAng = LerpAngle(FrameTime() * 11, lastAng or ang, ang)

	pos.x, pos.y, pos.z = lastPos.x, lastPos.y, lastPos.z
	ang.p, ang.y, ang.r = lastAng.p, lastAng.y, lastAng.r

hook.Add 'CalcViewModelView', 'PPM2.ViewModel', CalcViewModelView, -3

-- indraw = false
--
-- magicMat = CreateMaterial('ppm2_magic_material', 'UnlitGeneric', {
--  '$basetexture': 'models/debug/debugwhite'
--  '$ignorez': 1
--  '$vertexcolor': 1
--  '$vertexalpha': 1
--  '$nolod': 1
--  '$color2': '{255 255 255}'
-- })

-- hook.Add 'PostDrawViewModel', 'PPM2.ViewModel', (vm, ply, weapon) ->
--  return if indraw
--  return if not VM_MAGIC\GetBool() or VM_MAGIC_HANDS\GetBool()
--  return if not IsValid(vm) or not IsValid(ply) or not IsValid(weapon)
--  return if PPM2.__RENDERING_REFLECTIONS or not IsValid(vm) or not ply.__cachedIsPony
--  observer = ply\GetObserverTarget()
--  return if IsValid(observer) and not observer.__cachedIsPony
--  return if not SV_SHOULD_DRAW_VIEWMODEL\GetBool() or not SHOULD_DRAW_VIEWMODEL\GetBool()
--  return if IsValid(weapon) and weapon.UseHands == false
--
--  if IsValid(observer)
--      return if not observer\Alive()
--  else
--      return if not ply\Alive()
--
--  return if ply\GetPonyRaceFlags()\band(PPM2.RACE_HAS_HORN) == 0
--  data = ply\GetPonyData()
--  return if not data
--
--  indraw = true
--  color = data\ComputeMagicColor()
--
--  magicMat\SetVector('$color2', color\ToVector())
--  render.MaterialOverride(magicMat)
--  render.ModelMaterialOverride(magicMat)
--
--  cam.IgnoreZ(true)
--
--  mat = Matrix()
--  mat\Scale(Vector(1.1, 1.1, 1.1))
--  vm\EnableMatrix('RenderMultiply', mat)
--
--  ply\DrawModel()
--  vm\DisableMatrix('RenderMultiply')
--
--  cam.IgnoreZ(false)
--
--  render.MaterialOverride()
--  render.ModelMaterialOverride()
--  indraw = false

mat_dxlevel = GetConVar('mat_dxlevel')

timer.Create 'PPM2.CheckDXLevel', 180, 0, ->
	if mat_dxlevel\GetInt() > 90
		timer.Remove 'PPM2.CheckDXLevel'
		return

	PPM2.Message('Direct3D Level is LESS THAN 9.1! This will not work!')

IN_DRAW = false
MARKED_FOR_DRAW = {}

player_GetAll = player.GetAll

PPM2.PreDrawOpaqueRenderables = (bDrawingDepth, bDrawingSkybox) ->
	return if IN_DRAW or PPM2.__RENDERING_REFLECTIONS

	MARKED_FOR_DRAW = {}

	for ply in *player_GetAll()
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
	if not bDrawingDepth and not bDrawingSkybox
		for _, draw in ipairs MARKED_FOR_DRAW
			draw\PostDraw()

	if LEGS_RENDER_TYPE\GetBool()
		with LocalPlayer()
			if .__cachedIsPony and \Alive()
				if data = \GetPonyData()
					IN_DRAW = true
					data\GetRenderController()\DrawLegs()
					IN_DRAW = false

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

Think = ->
	for _, task in ipairs PPM2.NetworkedPonyData.RenderTasks
		ent = task.ent
		if IsValid(ent) and ent.__cachedIsPony
			if ent.__ppm2_task_hit
				ent.__ppm2_task_hit = false
				ent\SetNoDraw(false)

			if not ent.__ppm2RenderOverride
				ent = ent
				ent.__ppm2_oldRenderOverride = ent.RenderOverride
				ent.__ppm2RenderOverride = ->
					renderController = task\GetRenderController()
					renderController\PreDraw(ent, true)

					if ent.__ppm2_oldRenderOverride
						ent.__ppm2_oldRenderOverride(ent)
					else
						ent\DrawModel()

					renderController\PostDraw(ent, true)
				ent.RenderOverride = ent.__ppm2RenderOverride

PPM2.PrePlayerDraw = =>
	return if PPM2.__RENDERING_REFLECTIONS

	with data = GetPonyData(@)
		return if not data
		@__cachedIsPony = IsPony(@)
		return if not @__cachedIsPony
		f = FrameNumberL()
		return if @__ppm2_last_draw == f
		@__ppm2_last_draw = f
		bones = PPMBonesModifier(@)
		if data and bones\CanThink()
			bones\ResetBones()
			hook.Call('PPM2.SetupBones', nil, @, data) if data
			bones\Think()
			@_ppmBonesModified = true

PPM2.PostPlayerDraw = =>
	return if PPM2.__RENDERING_REFLECTIONS
	with data = GetPonyData(@)
		return if not data or not @__cachedIsPony
		renderController = data\GetRenderController()
		renderController\PostDraw() if renderController
		return

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
				newCol = status.color + Color(additional, additional, additional)
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
		return if @GetPonyRaceFlags()\band(PPM2.RACE_HAS_HORN) == 0
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

				.color = data\ComputeMagicColor()
				.haloSeed = math.rad(math.random(-1000, 1000))
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

import ScrWL, ScrHL from _G
import HUDCommons from DLib
color_black = Color(color_black)

hook.Add 'HUDPaint', 'PPM2.LoadingDisplay', ->
	lply = LocalPlayer()
	lpos = EyePos()

	for task in *PPM2.NetworkedPonyData.CheckTasks
		if ent = task\GetEntity()
			if IsValid(ent) and ent\IsPony() and not ent\IsRagdoll() and (ent ~= lply or lply\ShouldDrawLocalPlayer()) and (not ent.Alive or ent\Alive())
				if renderer = task\GetRenderController()
					if textures = renderer\GetTextureController()
						if textures\IsBeingProcessed()
							pos = ent\GetPos()
							pos\Add(ent\OBBCenter())
							dist = pos\Distance(lpos)

							if dist < 384
								{:x, :y, :visible} = pos\ToScreen()

								if visible and x > -100 and x < ScrWL() + 100 and y > -100 and y < ScrHL() + 100
									color = task\ComputeMagicColor()
									color.a = 255 - dist\progression(128, 384) * 255
									color_black.a = color.a
									size = (200 * (1 - dist\progression(0, 300))) * task\GetPonySize() * task\GetLegsSize() * task\GetNeckSize() * task\GetBackSize()
									sizeh = size / 2

									HUDCommons.DrawLoading(x + 2 - sizeh, y + 2 - sizeh, size, color_black)
									HUDCommons.DrawLoading(x - sizeh, y - sizeh, size, color)

hook.Add 'PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw, -2
hook.Add 'PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw, -2
hook.Add 'PostDrawOpaqueRenderables', 'PPM2.PostDrawOpaqueRenderables', PPM2.PostDrawOpaqueRenderables, -2
hook.Add 'Think', 'PPM2.UpdateRenderTasks', Think, -2
hook.Add 'PreDrawOpaqueRenderables', 'PPM2.PreDrawOpaqueRenderables', PPM2.PreDrawOpaqueRenderables, -2
hook.Add 'PostDrawTranslucentRenderables', 'PPM2.PostDrawTranslucentRenderables', PPM2.PostDrawTranslucentRenderables, -2
