
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

ENABLE_FLASHLIGHT_PASS = CreateConVar('ppm2_flashlight_pass', '1', {FCVAR_ARCHIVE}, 'Enable flashlight render pass. This kills FPS.')
ENABLE_LEGS = CreateConVar('ppm2_draw_legs', '1', {FCVAR_ARCHIVE}, 'Draw pony legs.')
USE_RENDER_OVERRIDE = CreateConVar('ppm2_legs_new', '1', {FCVAR_ARCHIVE}, 'Use RenderOverride function for legs drawing')
LEGS_RENDER_TYPE = CreateConVar('ppm2_render_legstype', '0', {FCVAR_ARCHIVE, FCVAR_NOTIFY}, 'When render legs. 0 - Before Opaque renderables; 1 - after Translucent renderables')

class PonyRenderController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	CompileTextures: => @GetTextureController()\CompileTextures() if @GetTextureController and @GetTextureController()
	new: (data) =>
		super(data)
		@hideModels = false
		@modelCached = data\GetModel()
		@IGNORE_DRAW = false
		@CompileTextures() if @ent
		@CreateLegs() if @ent == LocalPlayer()
		@socksModel = data\GetSocksModel()
		@socksModel\SetNoDraw(false) if IsValid(@socksModel)
		@newSocksModel = data\GetNewSocksModel()
		@newSocksModel\SetNoDraw(false) if IsValid(@newSocksModel)
		if @ent
			@CreateFlexController()
			@CreateEmotesController()

	GetEntity: => @ent
	GetModel: => @controller\GetModel()

	GetLegs: =>
		return NULL if not @isValid
		return NULL if @ent ~= LocalPlayer()
		@CreateLegs() if not IsValid()
		return @legsModel
	CreateLegs: =>
		return NULL if not @isValid
		return NULL if @ent ~= LocalPlayer()
		for ent in *ents.GetAll()
			if ent.isPonyLegsModel
				ent\Remove()
		@legsModel = ClientsideModel(@modelCached)
		with @legsModel
			.isPonyLegsModel = true
			.lastRedrawFix = 0
			\SetNoDraw(true)
			.__PPM2_PonyData = @GetData()

		@GetData()\GetWeightController()\UpdateWeight(@legsModel)

		@lastLegUpdate = CurTime()
		@legClipPlanePos = Vector(0, 0, 0)
		@legBGSetup = CurTime()
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
		return if @legUpdateFrame == FrameNumber()
		@legUpdateFrame = FrameNumber()
		ctime = CurTime()
		ply = @ent
		seq = ply\GetSequence()

		if seq ~= @legSeq
			@legSeq = seq
			@legsModel\ResetSequence(seq)

		if @legBGSetup < ctime
			@legBGSetup = ctime + 1
			for group in *ply\GetBodyGroups()
				@legsModel\SetBodygroup(group.id, ply\GetBodygroup(group.id))

		with @legsModel
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
		@CreateLegs() unless IsValid(@legsModel)
		return unless IsValid(@legsModel)
		return if @ent\ShouldDrawLocalPlayer()
		return if (@ent\GetPos() + @ent\GetViewOffset())\DistToSqr(EyePos()) > @@LEGS_MAX_DISTANCE
		if USE_RENDER_OVERRIDE\GetBool()
			@legsModel\SetNoDraw(false)
			rTime = RealTime()
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
		if sizes = @GetData()\GetSizeController()
			sizes\ModifyNeck(@legsModel)
			sizes\ModifyLegs(@legsModel)
			sizes\ModifyScale(@legsModel)
		@legsModel\DrawModel()
		@GetTextureController()\PostDrawLegs(@legsModel)

		if LEGS_RENDER_TYPE\GetBool() and NABLE_FLASHLIGHT_PASS\GetBool()
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
		return if not @ent\Alive()
		return if @ent\ShouldDrawLocalPlayer()
		return if (@ent\GetPos() + @ent\GetViewOffset())\DistToSqr(EyePos()) > @@LEGS_MAX_DISTANCE
		@UpdateLegs()

		oldClip = render.EnableClipping(true)
		render.PushCustomClipPlane(@legsClipPlane, @legClipDot)

		@GetTextureController()\PreDrawLegs(@legsModel)
		if sizes = @GetData()\GetSizeController()
			sizes\ModifyNeck(@legsModel)
			sizes\ModifyLegs(@legsModel)
			sizes\ModifyScale(@legsModel)
		@legsModel\DrawModel()
		@GetTextureController()\PostDrawLegs(@legsModel)

		render.PopCustomClipPlane()
		render.EnableClipping(oldClip)

	DrawLegsDepth: (start3D = false) =>
		return if not @isValid
		return if not ENABLE_LEGS\GetBool()
		@CreateLegs() unless IsValid(@legsModel)
		return unless IsValid(@legsModel)
		return if @ent\ShouldDrawLocalPlayer()
		return if (@ent\GetPos() + @ent\GetViewOffset())\DistToSqr(EyePos()) > @@LEGS_MAX_DISTANCE
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

	IsValid: => IsValid(@ent) and @isValid
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
		@HideModels(true)
		@GetTextureController()\ResetTextures() if @GetTextureController() and @ent\IsPony()

	PlayerRespawn: =>
		return if not @isValid
		@HideModels(false) if @ent\IsPony()
		@flexes\PlayerRespawn() if @flexes
		@GetTextureController()\ResetTextures() if @GetTextureController()

	DrawModels: =>
		@socksModel\DrawModel() if IsValid(@socksModel)
		@newSocksModel\DrawModel() if IsValid(@newSocksModel)
	HideModels: (status = true) =>
		return if @hideModels == status
		@socksModel\SetNoDraw(status) if IsValid(@socksModel)
		@newSocksModel\SetNoDraw(status) if IsValid(@newSocksModel)
		@hideModels = status

	PreDraw: (ent = @ent, drawingNewTask = false) =>
		return if not @isValid
		with @GetTextureController()
			\PreDraw(ent, drawingNewTask)
			if PPM2.ALTERNATIVE_RENDER\GetBool() or drawingNewTask
				\UpdateSocks(@ent, @socksModel) if IsValid(@socksModel)
				\UpdateNewSocks(@ent, @newSocksModel) if IsValid(@newSocksModel)
		@flexes\Think(ent) if @flexes
		@emotes\Think(ent) if @emotes
	PostDraw: (ent = @ent, drawingNewTask = false) =>
		return if not @isValid
		@GetTextureController()\PostDraw(ent)

	@ARMS_MATERIAL_INDEX = 0
	PreDrawArms: (ent) =>
		return if not @isValid
		if ent and not @armsWeightSetup
			@armsWeightSetup = true
			weight = @GetData()\GetWeight()
			vec = Vector(weight, weight, weight)
			for i = 1, 13
				ent\ManipulateBoneScale(i, vec)
		render.MaterialOverrideByIndex(@@ARMS_MATERIAL_INDEX, @GetTextureController()\GetBody())
	PostDrawArms: (ent) =>
		return if not @isValid
		render.MaterialOverrideByIndex(@@ARMS_MATERIAL_INDEX)

	DataChanges: (state) =>
		return if not @isValid
		return if not @ent
		@GetTextureController()\DataChanges(state)
		@flexes\DataChanges(state) if @flexes
		@emotes\DataChanges(state) if @emotes
		switch state\GetKey()
			when 'Weight'
				@armsWeightSetup = false
				@GetData()\GetWeightController()\UpdateWeight(@legsModel) if IsValid(@legsModel)
			when 'SocksModel'
				@socksModel = @GetData()\GetSocksModel()
				@socksModel\SetNoDraw(@hideModels) if IsValid(@socksModel)
				@GetTextureController()\UpdateSocks(@ent, @socksModel) if @GetTextureController() and IsValid(@socksModel)
			when 'NewSocksModel'
				@newSocksModel = @GetData()\GetNewSocksModel()
				@newSocksModel\SetNoDraw(@hideModels) if IsValid(@newSocksModel)
				@GetTextureController()\UpdateNewSocks(@ent, @newSocksModel) if @GetTextureController() and IsValid(@newSocksModel)
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
		@renderController.ent = @ent
		return @renderController

	CreateFlexController: =>
		return @flexes if not @isValid
		return if @GetData()\GetNoFlex()
		if not @flexes
			cls = PPM2.GetFlexController(@modelCached)
			return if not cls
			@flexes = cls(@)
		@flexes.ent = @ent
		return @flexes

	CreateEmotesController: =>
		return @emotes if not @isValid
		if not @emotes
			cls = PPM2.GetPonyExpressionsController(@modelCached)
			return if not cls
			@emotes = cls(@)
		@emotes.ent = @ent
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
		@upperManeModel\SetNoDraw(@hideModels) if IsValid(@upperManeModel)
		@lowerManeModel\SetNoDraw(@hideModels) if IsValid(@lowerManeModel)
		@tailModel\SetNoDraw(@hideModels) if IsValid(@tailModel)
	__tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"

	DataChanges: (state) =>
		return if not @ent
		return if not @isValid
		switch state\GetKey()
			when 'UpperManeModel'
				@upperManeModel = @GetData()\GetUpperManeModel()
				@upperManeModel\SetNoDraw(@hideModels) if IsValid(@upperManeModel)
				@GetTextureController()\UpdateUpperMane(@ent, @upperManeModel) if @GetTextureController() and IsValid(@upperManeModel)
			when 'LowerManeModel'
				@lowerManeModel = @GetData()\GetLowerManeModel()
				@lowerManeModel\SetNoDraw(@hideModels) if IsValid(@lowerManeModel)
				@GetTextureController()\UpdateLowerMane(@ent, @lowerManeModel) if @GetTextureController() and IsValid(@lowerManeModel)
			when 'TailModel'
				@tailModel = @GetData()\GetTailModel()
				@tailModel\SetNoDraw(@hideModels) if IsValid(@tailModel)
				@GetTextureController()\UpdateTail(@ent, @tailModel) if @GetTextureController() and IsValid(@tailModel)
		super(state)

	DrawModels: =>
		@upperManeModel\DrawModel() if IsValid(@upperManeModel)
		@lowerManeModel\DrawModel() if IsValid(@lowerManeModel)
		@tailModel\DrawModel() if IsValid(@tailModel)
		super()
	HideModels: (status = true) =>
		return if @hideModels == status
		@upperManeModel\SetNoDraw(status) if IsValid(@upperManeModel)
		@lowerManeModel\SetNoDraw(status) if IsValid(@lowerManeModel)
		@tailModel\SetNoDraw(status) if IsValid(@tailModel)
		super(status)

	PreDraw: (ent = @ent, drawingNewTask = false) =>
		super(ent, drawingNewTask)
		if PPM2.ALTERNATIVE_RENDER\GetBool() or drawingNewTask
			textures = @GetTextureController()
			return if not textures
			textures\UpdateUpperMane(@ent, @upperManeModel) if IsValid(@upperManeModel)
			textures\UpdateLowerMane(@ent, @lowerManeModel) if IsValid(@lowerManeModel)
			textures\UpdateTail(@ent, @tailModel) if IsValid(@tailModel)

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
