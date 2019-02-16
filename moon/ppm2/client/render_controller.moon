
--
-- Copyright (C) 2017-2019 DBot

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


import PPM2 from _G

ENABLE_FLASHLIGHT_PASS = CreateConVar('ppm2_flashlight_pass', '1', {FCVAR_ARCHIVE}, 'Enable flashlight render pass. This kills FPS.')
ENABLE_LEGS = CreateConVar('ppm2_draw_legs', '1', {FCVAR_ARCHIVE}, 'Draw pony legs.')
USE_RENDER_OVERRIDE = CreateConVar('ppm2_legs_new', '1', {FCVAR_ARCHIVE}, 'Use RenderOverride function for legs drawing')
LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {FCVAR_ARCHIVE}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')
ENABLE_STARE = CreateConVar('ppm2_render_stare', '1', {FCVAR_ARCHIVE}, 'Make eyes follow players and move when idling')

class PonyRenderController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	CompileTextures: => @GetTextureController()\CompileTextures() if @GetTextureController and @GetTextureController()
	new: (controller) =>
		super(controller)
		@hideModels = false
		@modelCached = controller\GetModel()
		@IGNORE_DRAW = false
		@CompileTextures() if @GetEntity()\IsValid()
		@CreateLegs() if @GetEntity() == LocalPlayer()
		@socksModel = controller\GetSocksModel()
		@socksModel\SetNoDraw(false) if IsValid(@socksModel)
		@newSocksModel = controller\GetNewSocksModel()
		@newSocksModel\SetNoDraw(false) if IsValid(@newSocksModel)
		@lastStareUpdate = 0
		@staringAt = NULL
		@rotatedHeadTarget = false
		@idleEyes = true
		@idleEyesActive = false
		@nextRollEyes = 0
		if @GetEntity()\IsValid()
			@CreateFlexController()
			@CreateEmotesController()

	GetModel: => @controller\GetModel()

	GetLegs: =>
		return NULL if not @isValid
		return NULL if @GetEntity() ~= LocalPlayer()
		@CreateLegs() if not IsValid()
		return @legsModel

	CreateLegs: =>
		return NULL if not @isValid
		return NULL if @GetEntity() ~= LocalPlayer()
		for _, ent in ipairs ents.GetAll()
			if ent.isPonyLegsModel
				ent\Remove()

		with @legsModel = ClientsideModel(@modelCached)
			.isPonyLegsModel = true
			.lastRedrawFix = 0
			\SetNoDraw(true)
			.__PPM2_PonyData = @GetData()
			--\PPMBonesModifier()

		@GetData()\GetWeightController()\UpdateWeight(@legsModel)

		@lastLegUpdate = CurTimeL()
		@legClipPlanePos = Vector(0, 0, 0)
		@legBGSetup = CurTimeL()
		@legUpdateFrame = 0
		@legClipDot = 0
		@duckOffsetHack = @@LEG_CLIP_OFFSET_STAND
		@legsClipPlane = @@LEG_CLIP_VECTOR
		return @legsModel

	@LEG_SHIFT_CONST = 24
	@LEG_SHIFT_CONST_VEHICLE = 14
	@LEG_Z_CONST = 0
	@LEG_Z_CONST_VEHICLE = 20
	@LEG_ANIM_SPEED_CONST = 1
	@LEG_CLIP_OFFSET_STAND = 28
	@LEG_CLIP_OFFSET_DUCK = 12
	@LEG_CLIP_OFFSET_VEHICLE = 11

	UpdateLegs: =>
		return if not @isValid
		return if not ENABLE_LEGS\GetBool()
		return unless IsValid(@legsModel)
		return if @legUpdateFrame == FrameNumberL()
		@legUpdateFrame = FrameNumberL()
		ctime = CurTimeL()
		ply = @GetEntity()
		seq = ply\GetSequence()
		legsModel = @legsModel

		with @legsModel
			PPM2.EntityBonesModifier.ThinkObject(ply.__ppmBonesModifiers) if ply.__ppmBonesModifiers

			for boneid = 0, ply\GetBoneCount() - 1
				\ManipulateBonePosition(0, ply\GetManipulateBonePosition(0))
				\ManipulateBoneAngles(0, ply\GetManipulateBoneAngles(0))
				\ManipulateBoneScale(0, ply\GetManipulateBoneScale(0))

			if seq ~= @legSeq
				@legSeq = seq
				\ResetSequence(seq)

			if @legBGSetup < ctime
				@legBGSetup = ctime + 1
				for _, group in ipairs ply\GetBodyGroups()
					\SetBodygroup(group.id, ply\GetBodygroup(group.id))

			\FrameAdvance(ctime - @lastLegUpdate)
			\SetPlaybackRate(@@LEG_ANIM_SPEED_CONST * ply\GetPlaybackRate())
			@lastLegUpdate = ctime
			\SetPoseParameter('move_x',       (ply\GetPoseParameter('move_x')     * 2) - 1)
			\SetPoseParameter('move_y',       (ply\GetPoseParameter('move_y')     * 2) - 1)
			\SetPoseParameter('move_yaw',     (ply\GetPoseParameter('move_yaw')   * 360) - 180)
			\SetPoseParameter('body_yaw',     (ply\GetPoseParameter('body_yaw')   * 180) - 90)
			\SetPoseParameter('spine_yaw',    (ply\GetPoseParameter('spine_yaw')  * 180) - 90)

		if ply\InVehicle()
			local bonePos

			if bone = @legsModel\LookupBone('LrigNeck1')
				if boneData = @legsModel\GetBonePosition(bone)
					bonePos = boneData

			veh = ply\GetVehicle()
			vehAng = veh\GetAngles()
			eyepos = EyePos()
			vehAng\RotateAroundAxis(vehAng\Up(), 90)

			clipAng = Angle(vehAng.p, vehAng.y, vehAng.r)
			clipAng\RotateAroundAxis(clipAng\Right(), -90)

			@legsClipPlane = clipAng\Forward()
			@legsModel\SetRenderAngles(vehAng)

			drawPos = Vector(@@LEG_SHIFT_CONST_VEHICLE, 0, @@LEG_Z_CONST_VEHICLE)
			drawPos\Rotate(vehAng)
			@legsModel\SetPos(eyepos - drawPos)
			@legsModel\SetRenderOrigin(eyepos - drawPos)

			if not bonePos
				legClipPlanePos = Vector(0, 0, @@LEG_CLIP_OFFSET_VEHICLE)
				legClipPlanePos\Rotate(vehAng)
				@legClipPlanePos = eyepos - legClipPlanePos
			else
				@legClipPlanePos = bonePos

		else
			@legsClipPlane = @@LEG_CLIP_VECTOR
			eangles = EyeAngles()
			yaw = eangles.y - ply\GetPoseParameter('head_yaw') * 180 + 90
			newAng = Angle(0, yaw, 0)
			rad = math.rad(yaw)
			sin, cos = math.sin(rad), math.cos(rad)
			pos = ply\GetPos()
			{:x, :y, :z} = pos
			newPos = Vector(x - cos * @@LEG_SHIFT_CONST, y - sin * @@LEG_SHIFT_CONST, z + @@LEG_Z_CONST)
			if ply\Crouching()
				@duckOffsetHack = @@LEG_CLIP_OFFSET_DUCK
			else
				@duckOffsetHack = Lerp(0.1, @duckOffsetHack, @@LEG_CLIP_OFFSET_STAND)

			@legsModel\SetRenderAngles(newAng)
			@legsModel\SetAngles(newAng)
			@legsModel\SetRenderOrigin(newPos)
			@legsModel\SetPos(newPos)

			if bone = @legsModel\LookupBone('LrigNeck1')
				if boneData = @legsModel\GetBonePosition(bone)
					@legClipPlanePos = boneData
				else
					@legClipPlanePos = Vector(x, y, z + @duckOffsetHack)
			else
				@legClipPlanePos = Vector(x, y, z + @duckOffsetHack)


		@legClipDot = @legsClipPlane\Dot(@legClipPlanePos)

	@LEG_CLIP_VECTOR = Vector(0, 0, -1)
	@LEGS_MAX_DISTANCE = 60 ^ 2
	DrawLegs: (start3D = false) =>
		return if not @isValid
		return if not ENABLE_LEGS\GetBool()
		return if not @GetEntity()\Alive()
		return if @GetEntity()\InVehicle() and EyeAngles().p < 30
		return if not @GetEntity()\InVehicle() and EyeAngles().p < 60
		@CreateLegs() unless IsValid(@legsModel)
		return unless IsValid(@legsModel)
		return if @GetEntity()\ShouldDrawLocalPlayer()
		return if (@GetEntity()\GetPos() + @GetEntity()\GetViewOffset())\DistToSqr(EyePos()) > @@LEGS_MAX_DISTANCE

		if USE_RENDER_OVERRIDE\GetBool()
			@legsModel\SetNoDraw(false)
			rTime = RealTimeL()
			if @legsModel.lastRedrawFix < rTime
				@legsModel\DrawModel()
				@legsModel.lastRedrawFix = rTime + 5
			if not @legsModel.RenderOverride
				@legsModel.RenderOverride = -> @DrawLegsOverride()
				@legsModel\DrawModel()
			return
		else
			@legsModel\SetNoDraw(true)

		@UpdateLegs()

		oldClip = render.EnableClipping(true)
		render.PushCustomClipPlane(@legsClipPlane, @legClipDot)
		cam.Start3D() if start3D

		@GetTextureController()\PreDrawLegs(@legsModel)
		@legsModel\DrawModel()
		@GetTextureController()\PostDrawLegs(@legsModel)

		if LEGS_RENDER_TYPE\GetBool() and ENABLE_FLASHLIGHT_PASS\GetBool()
			render.PushFlashlightMode(true)
			@GetTextureController()\PreDrawLegs(@legsModel)
			if sizes = @GetData()\GetSizeController()
				sizes\ModifyNeck(@legsModel)
				sizes\ModifyLegs(@legsModel)
				sizes\ModifyScale(@legsModel)
			@legsModel\DrawModel()
			@GetTextureController()\PostDrawLegs(@legsModel)
			render.PopFlashlightMode()

		render.PopCustomClipPlane()
		cam.End3D() if start3D
		render.EnableClipping(oldClip)

	DrawLegsOverride: =>
		return if not @isValid
		return if not ENABLE_LEGS\GetBool()
		return if not @GetEntity()\Alive()
		return if @GetEntity()\InVehicle() and EyeAngles().p < 30
		return if not @GetEntity()\InVehicle() and EyeAngles().p < 60
		return if @GetEntity()\ShouldDrawLocalPlayer()
		return if (@GetEntity()\GetPos() + @GetEntity()\GetViewOffset())\DistToSqr(EyePos()) > @@LEGS_MAX_DISTANCE
		@UpdateLegs()

		oldClip = render.EnableClipping(true)
		render.PushCustomClipPlane(@legsClipPlane, @legClipDot)

		@GetTextureController()\PreDrawLegs(@legsModel)
		@legsModel\DrawModel()
		@GetTextureController()\PostDrawLegs(@legsModel)

		render.PopCustomClipPlane()
		render.EnableClipping(oldClip)

	DrawLegsDepth: (start3D = false) =>
		return if not @isValid
		return if not ENABLE_LEGS\GetBool()
		return if not @GetEntity()\Alive()
		return if @GetEntity()\InVehicle() and EyeAngles().p < 30
		return if not @GetEntity()\InVehicle() and EyeAngles().p < 60
		@CreateLegs() unless IsValid(@legsModel)
		return unless IsValid(@legsModel)
		return if @GetEntity()\ShouldDrawLocalPlayer()
		return if (@GetEntity()\GetPos() + @GetEntity()\GetViewOffset())\DistToSqr(EyePos()) > @@LEGS_MAX_DISTANCE
		@UpdateLegs()

		oldClip = render.EnableClipping(true)
		render.PushCustomClipPlane(@legsClipPlane, @legClipDot)
		cam.Start3D() if start3D

		@GetTextureController()\PreDrawLegs(@legsModel)
		if sizes = @GetData()\GetSizeController()
			sizes\ModifyNeck(@legsModel)
			sizes\ModifyLegs(@legsModel)
			sizes\ModifyScale(@legsModel)
		@legsModel\DrawModel()
		@GetTextureController()\PostDrawLegs()

		render.PopCustomClipPlane()
		cam.End3D() if start3D
		render.EnableClipping(oldClip)

	IsValid: => IsValid(@GetEntity()) and @isValid

	Reset: =>
		@flexes\Reset() if @flexes and @flexes.Reset
		@emotes\Reset() if @emotes and @emotes.Reset
		@GetTextureController()\Reset() if @GetTextureController and @GetTextureController() and @GetTextureController().Reset
		@GetTextureController()\ResetTextures() if @GetTextureController and @GetTextureController()

	Remove: =>
		@flexes\Remove() if @flexes
		@emotes\Remove() if @emotes
		@GetTextureController()\Remove() if @GetTextureController and @GetTextureController()
		@isValid = false

	PlayerDeath: =>
		return if not @isValid
		if @emotes
			@emotes\Remove()
			@emotes = nil
		@HideModels(true)
		@GetTextureController()\ResetTextures() if @GetTextureController() and @GetEntity()\IsPony()

	PlayerRespawn: =>
		return if not @isValid
		@GetEmotesController()
		@HideModels(false) if @GetEntity()\IsPony()
		@flexes\PlayerRespawn() if @flexes
		@GetTextureController()\ResetTextures() if @GetTextureController()

	DrawModels: =>
		@socksModel\DrawModel() if IsValid(@socksModel)
		@newSocksModel\DrawModel() if IsValid(@newSocksModel)

	ShouldHideModels: => @hideModels or @GetEntity()\GetNoDraw()

	DoHideModels: (status) =>
		@socksModel\SetNoDraw(status) if IsValid(@socksModel)
		@newSocksModel\SetNoDraw(status) if IsValid(@newSocksModel)

	HideModels: (status = true) =>
		return if @hideModels == status
		@DoHideModels(status)
		@hideModels = status

	CheckTarget: (epos, pos) =>
		return not util.TraceLine({
			start: epos,
			endpos: pos,
			filter: @GetEntity(),
			mask: MASK_BLOCKLOS
		}).Hit

	UpdateStare: =>
		ctime = RealTimeL()
		return if @lastStareUpdate > ctime

		if (not @idleEyes or not ENABLE_STARE\GetBool()) and @idleEyesActive
			@staringAt = NULL
			@GetEntity()\SetEyeTarget(Vector())
			@idleEyesActive = false
			return

		return if not @idleEyes or not ENABLE_STARE\GetBool()
		@idleEyesActive = true
		@lastStareUpdate = ctime + 0.2
		lpos = @GetEntity()\EyePos()

		if IsValid(@staringAt)
			trNew = util.TraceLine({
				start: lpos,
				endpos: lpos + @GetEntity()\EyeAnglesFixed()\Forward() * 270,
				filter: @GetEntity(),
			})

			if trNew.Entity\IsValid() and trNew.Entity\IsPlayer()
				@staringAt = trNew.Entity

			epos = @staringAt\EyePos()
			if epos\Distance(lpos) < 300 and DLib.combat.inPVS(@GetEntity(), @staringAt) and @CheckTarget(lpos, epos)
				@GetEntity()\SetEyeTarget(epos)
				return
			@staringAt = NULL
			@GetEntity()\SetEyeTarget(Vector())

		if player.GetCount() ~= 1
			local last
			max = 300
			local lastpos
			for _, ply in ipairs player.GetAll()
				if @GetEntity() ~= ply
					epos = ply\EyePos()
					dist = epos\Distance(lpos)
					if dist < max and DLib.combat.inPVS(@GetEntity(), ply) and @CheckTarget(lpos, epos)
						max = dist
						last = ply
						lastpos = epos
			if last
				@GetEntity()\SetEyeTarget(lastpos)
				@staringAt = last
				return

		return if @nextRollEyes > ctime
		@nextRollEyes = ctime + math.random(4, 16) / 6
		ang = @GetEntity()\EyeAnglesFixed()
		@eyeRollTargetPos = Vector(math.random(200, 400), math.random(-80, 80), math.random(-20, 20))
		@prevRollTargetPos = @prevRollTargetPos or @eyeRollTargetPos
		-- @GetEntity()\SetEyeTarget(@prevRollTargetPos)

	UpdateEyeRoll: =>
		return if not ENABLE_STARE\GetBool() or not @idleEyes or not @eyeRollTargetPos or IsValid(@staringAt)
		@prevRollTargetPos = LerpVector(FrameTime() * 6, @prevRollTargetPos, @eyeRollTargetPos)
		roll = Vector(@prevRollTargetPos)
		roll\Rotate(@GetEntity()\EyeAnglesFixed())
		@GetEntity()\SetEyeTarget(@GetEntity()\EyePos() + roll)

	PreDraw: (ent = @GetEntity(), drawingNewTask = false) =>
		return if not @isValid

		with @GetTextureController()
			\PreDraw(ent, drawingNewTask)

		if drawingNewTask
			with bones = ent\PPMBonesModifier()
				ent\ResetBoneManipCache()
				\ResetBones()
				hook.Call('PPM2.SetupBones', nil, ent, @controller)
				\Think(true)
				ent.__ppmBonesModified = true
				ent\ApplyBoneManipulations()

		@flexes\Think(ent) if @flexes
		@emotes\Think(ent) if @emotes
		if @GetEntity()\IsPlayer()
			@UpdateStare()
			@UpdateEyeRoll()

		if ent.RenderOverride and not ent.__ppm2RenderOverride and @GrabData('HideManes') and @GrabData('HideManesSocks')
			@socksModel\SetNoDraw(true) if IsValid(@socksModel)
			@newSocksModel\SetNoDraw(true) if IsValid(@newSocksModel)
		else
			@socksModel\SetNoDraw(@ShouldHideModels()) if IsValid(@socksModel)
			@newSocksModel\SetNoDraw(@ShouldHideModels()) if IsValid(@newSocksModel)

	PostDraw: (ent = @GetEntity(), drawingNewTask = false) =>
		return if not @isValid
		@GetTextureController()\PostDraw(ent, drawingNewTask)

	@ARMS_MATERIAL_INDEX = 0
	PreDrawArms: (ent) =>
		return if not @isValid
		if ent and not @armsWeightSetup
			@armsWeightSetup = true
			weight = 1 + (@GetData()\GetWeight() - 1) * 0.4
			vec = LVector(weight, weight, weight)
			ent\ManipulateBoneScale2Safe(i, vec) for i = 1, 13
		ent\SetSubMaterial(@@ARMS_MATERIAL_INDEX, @GetTextureController()\GetBodyName())
	PostDrawArms: (ent) =>
		return if not @isValid
		ent\SetSubMaterial(@@ARMS_MATERIAL_INDEX, '')

	DataChanges: (state) =>
		return if not @isValid
		return if not @GetEntity()
		@GetTextureController()\DataChanges(state)
		@flexes\DataChanges(state) if @flexes
		@emotes\DataChanges(state) if @emotes
		switch state\GetKey()
			when 'Weight'
				@armsWeightSetup = false
				@GetData()\GetWeightController()\UpdateWeight(@legsModel) if IsValid(@legsModel)
			when 'SocksModel'
				@socksModel = @GetData()\GetSocksModel()
				@socksModel\SetNoDraw(@ShouldHideModels()) if IsValid(@socksModel)
				@GetTextureController()\UpdateSocks(@GetEntity(), @socksModel) if @GetTextureController() and IsValid(@socksModel)
			when 'NewSocksModel'
				@newSocksModel = @GetData()\GetNewSocksModel()
				@newSocksModel\SetNoDraw(@ShouldHideModels()) if IsValid(@newSocksModel)
				@GetTextureController()\UpdateNewSocks(@GetEntity(), @newSocksModel) if @GetTextureController() and IsValid(@newSocksModel)
			when 'NoFlex'
				if state\GetValue()
					@flexes\ResetSequences() if @flexes
					@flexes = nil
				else
					@CreateFlexController()
	GetTextureController: =>
		return @renderController if not @isValid
		if not @renderController
			cls = PPM2.GetTextureController(@modelCached)
			@renderController = cls(@)
		@renderController.ent = @GetEntity()
		return @renderController

	CreateFlexController: =>
		return @flexes if not @isValid
		return if @GetData()\GetNoFlex()
		if not @flexes
			cls = PPM2.GetFlexController(@modelCached)
			return if not cls
			@flexes = cls(@)
		@flexes.ent = @GetEntity()
		return @flexes

	CreateEmotesController: =>
		return @emotes if not @isValid
		if not @emotes or not @emotes\IsValid()
			cls = PPM2.GetPonyExpressionsController(@modelCached)
			return if not cls
			@emotes = cls(@)
		@emotes.ent = @GetEntity()
		return @emotes

	GetFlexController: => @flexes
	GetEmotesController: => @emotes

class NewPonyRenderController extends PonyRenderController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	new: (data) =>
		super(data)
		@upperManeModel = data\GetUpperManeModel()
		@lowerManeModel = data\GetLowerManeModel()
		@tailModel = data\GetTailModel()
		@upperManeModel\SetNoDraw(@ShouldHideModels()) if IsValid(@upperManeModel)
		@lowerManeModel\SetNoDraw(@ShouldHideModels()) if IsValid(@lowerManeModel)
		@tailModel\SetNoDraw(@ShouldHideModels()) if IsValid(@tailModel)
	__tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"

	DataChanges: (state) =>
		return if not @GetEntity()
		return if not @isValid
		switch state\GetKey()
			when 'UpperManeModel'
				@upperManeModel = @GetData()\GetUpperManeModel()
				@upperManeModel\SetNoDraw(@ShouldHideModels()) if IsValid(@upperManeModel)
				@GetTextureController()\UpdateUpperMane(@GetEntity(), @upperManeModel) if @GetTextureController() and IsValid(@upperManeModel)
			when 'LowerManeModel'
				@lowerManeModel = @GetData()\GetLowerManeModel()
				@lowerManeModel\SetNoDraw(@ShouldHideModels()) if IsValid(@lowerManeModel)
				@GetTextureController()\UpdateLowerMane(@GetEntity(), @lowerManeModel) if @GetTextureController() and IsValid(@lowerManeModel)
			when 'TailModel'
				@tailModel = @GetData()\GetTailModel()
				@tailModel\SetNoDraw(@ShouldHideModels()) if IsValid(@tailModel)
				@GetTextureController()\UpdateTail(@GetEntity(), @tailModel) if @GetTextureController() and IsValid(@tailModel)
		super(state)

	DrawModels: =>
		@upperManeModel\DrawModel() if IsValid(@upperManeModel)
		@lowerManeModel\DrawModel() if IsValid(@lowerManeModel)
		@tailModel\DrawModel() if IsValid(@tailModel)
		super()

	DoHideModels: (status) =>
		super(status)
		@upperManeModel\SetNoDraw(status) if IsValid(@upperManeModel)
		@lowerManeModel\SetNoDraw(status) if IsValid(@lowerManeModel)
		@tailModel\SetNoDraw(status) if IsValid(@tailModel)

	PreDraw: (ent = @GetEntity(), drawingNewTask = false) =>
		super(ent, drawingNewTask)

		if ent.RenderOverride and not ent.__ppm2RenderOverride and @GrabData('HideManes')
			@upperManeModel\SetNoDraw(true) if IsValid(@upperManeModel) and @GrabData('HideManesMane')
			@lowerManeModel\SetNoDraw(true) if IsValid(@lowerManeModel) and @GrabData('HideManesMane')
			@tailModel\SetNoDraw(true) if IsValid(@tailModel) and @GrabData('HideManesTail')
		else
			@upperManeModel\SetNoDraw(@ShouldHideModels()) if IsValid(@upperManeModel)
			@lowerManeModel\SetNoDraw(@ShouldHideModels()) if IsValid(@lowerManeModel)
			@tailModel\SetNoDraw(@ShouldHideModels()) if IsValid(@tailModel)

hook.Add 'NotifyShouldTransmit', 'PPM2.RenderController', (should) =>
	if data = @GetPonyData()
		if renderer = data\GetRenderController()
			renderer\HideModels(not should)

PPM2.PonyRenderController = PonyRenderController
PPM2.NewPonyRenderController = NewPonyRenderController
PPM2.GetPonyRenderController = (model = 'models/ppm/player_default_base.mdl') -> PonyRenderController.AVALIABLE_CONTROLLERS[model\lower()] or PonyRenderController
PPM2.GetPonyRendererController = PPM2.GetPonyRenderController
PPM2.GetRenderController = PPM2.GetPonyRenderController
PPM2.GetRendererController = PPM2.GetPonyRenderController
