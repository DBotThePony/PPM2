
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


-- 0    LrigPelvis
-- 1    LrigSpine1
-- 2    LrigSpine2
-- 3    LrigRibcage
-- 4    LrigNeck1
-- 5    LrigNeck2
-- 6    LrigNeck3
-- 7    LrigScull
-- 8    Lrig_LEG_BL_Femur
-- 9    Lrig_LEG_BL_Tibia
-- 10   Lrig_LEG_BL_LargeCannon
-- 11   Lrig_LEG_BL_PhalanxPrima
-- 12   Lrig_LEG_BL_RearHoof
-- 13   Lrig_LEG_BR_Femur
-- 14   Lrig_LEG_BR_Tibia
-- 15   Lrig_LEG_BR_LargeCannon
-- 16   Lrig_LEG_BR_PhalanxPrima
-- 17   Lrig_LEG_BR_RearHoof
-- 18   Lrig_LEG_FL_Scapula
-- 19   Lrig_LEG_FL_Humerus
-- 20   Lrig_LEG_FL_Radius
-- 21   Lrig_LEG_FL_Metacarpus
-- 22   Lrig_LEG_FL_PhalangesManus
-- 23   Lrig_LEG_FL_FrontHoof
-- 24   Lrig_LEG_FR_Scapula
-- 25   Lrig_LEG_FR_Humerus
-- 26   Lrig_LEG_FR_Radius
-- 27   Lrig_LEG_FR_Metacarpus
-- 28   Lrig_LEG_FR_PhalangesManus
-- 29   Lrig_LEG_FR_FrontHoof
-- 30   Mane01
-- 31   Mane02
-- 32   Mane03
-- 33   Mane04
-- 34   Mane05
-- 35   Mane06
-- 36   Mane07
-- 37   Mane03_tip
-- 38   Tail01
-- 39   Tail02
-- 40   Tail03

USE_NEW_HULL = CreateConVar('ppm2_sv_newhull', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Use proper collision box for ponies. Slightly affects jump mechanics. When disabled, unexpected behaviour could happen.')
ALLOW_TO_MODIFY_SCALE = PPM2.ALLOW_TO_MODIFY_SCALE

class PonySizeController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	@NECK_BONE_1 = 'LrigNeck1'
	@NECK_BONE_2 = 'LrigNeck2'
	@NECK_BONE_3 = 'LrigNeck3'
	@NECK_BONE_4 = 'LrigScull'

	@LEGS_BONE_ROOT = 'LrigPelvis'

	@LEGS_FRONT_1 = 'Lrig_LEG_FL_FrontHoof'
	@LEGS_FRONT_2 = 'Lrig_LEG_FR_FrontHoof'

	@LEGS_FRONT_3 = 'Lrig_LEG_FL_Metacarpus'
	@LEGS_FRONT_4 = 'Lrig_LEG_FR_Metacarpus'

	@LEGS_FRONT_5 = 'Lrig_LEG_FL_Radius'
	@LEGS_FRONT_6 = 'Lrig_LEG_FR_Radius'

	@LEGS_BEHIND_1_1 = 'Lrig_LEG_BR_Tibia'
	@LEGS_BEHIND_2_1 = 'Lrig_LEG_BR_PhalanxPrima'
	@LEGS_BEHIND_3_1 = 'Lrig_LEG_BR_LargeCannon'

	@LEGS_BEHIND_1_2 = 'Lrig_LEG_BL_Tibia'
	@LEGS_BEHIND_2_2 = 'Lrig_LEG_BL_PhalanxPrima'
	@LEGS_BEHIND_3_2 = 'Lrig_LEG_BL_LargeCannon'

	@NEXT_OBJ_ID = 0

	Remap: =>
		mapping = {
			'NECK_BONE_1'
			'NECK_BONE_2'
			'NECK_BONE_3'
			'NECK_BONE_4'
			'LEGS_BONE_ROOT'
			'LEGS_FRONT_1'
			'LEGS_FRONT_2'
			'LEGS_FRONT_3'
			'LEGS_FRONT_4'
			'LEGS_FRONT_5'
			'LEGS_FRONT_6'
			'LEGS_BEHIND_1_1'
			'LEGS_BEHIND_2_1'
			'LEGS_BEHIND_3_1'
			'LEGS_BEHIND_1_2'
			'LEGS_BEHIND_2_2'
			'LEGS_BEHIND_3_2'
		}

		@validSkeleton = true

		for _, name in ipairs mapping
			@[name] = @GetEntity()\LookupBone(@@[name])
			@validSkeleton = false if not @[name]

	new: (controller) =>
		super(controller)
		@isValid = true
		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0
		@Remap()
		PPM2.DebugPrint('Created new size controller for ', @GetEntity(), ' as part of ', controller, '; internal ID is ', @objID)
		@GetEntity()\SetModelScale(1) if not @GetEntity()\IsPlayer() and @GetEntity()\GetModelScale() ~= 1

	IsValid: => @controller\IsValid()
	GetEntity: => @controller\GetEntity()
	IsNetworked: => @controller\IsNetworked()
	AllowResize: => not @controller\IsNetworked() or ALLOW_TO_MODIFY_SCALE\GetBool()

	@STEP_SIZE = 20
	@PONY_HULL = 17
	@HULL_MINS = Vector(-@PONY_HULL, -@PONY_HULL, 0)
	@HULL_MAXS = Vector(@PONY_HULL, @PONY_HULL, 72 * PPM2.PONY_HEIGHT_MODIFIER)
	@HULL_MAXS_DUCK = Vector(@PONY_HULL, @PONY_HULL, 36 * PPM2.PONY_HEIGHT_MODIFIER_DUCK_HULL)

	@DEFAULT_HULL_MINS = Vector(-16, -16, 0)
	@DEFAULT_HULL_MAXS = Vector(16, 16, 72)
	@DEFAULT_HULL_MAXS_DUCK = Vector(16, 16, 36)
	@DEF_SCALE = Vector(1, 1, 1)

	DataChanges: (state) =>
		return if not IsValid(@GetEntity())
		return if not @GetEntity()\IsPony()
		@Remap()
		@GetEntity()\SetModelScale(1) if not @GetEntity()\IsPlayer() and @GetEntity()\GetModelScale() ~= 1

		if state\GetKey() == 'PonySize'
			@ModifyScale()

		if state\GetKey() == 'NeckSize'
			@ModifyNeck()
			@ModifyViewOffset()

		if state\GetKey() == 'LegsSize'
			@ModifyLegs()
			@ModifyHull()
			@ModifyViewOffset()

	ResetViewOffset: (ent = @GetEntity()) =>
		ent\SetViewOffset(PPM2.PLAYER_VIEW_OFFSET_ORIGINAL) if ent.SetViewOffset
		ent\SetViewOffsetDucked(PPM2.PLAYER_VIEW_OFFSET_DUCK_ORIGINAL) if ent.SetViewOffsetDucked

	ResetHulls: (ent = @GetEntity()) =>
		ent\ResetHull() if ent.ResetHull
		ent\SetStepSize(@@STEP_SIZE) if ent.SetStepSize
		ent.__ppm2_modified_hull = false

	ResetJumpHeight: (ent = @GetEntity()) =>
		return if CLIENT
		return if not ent.SetJumpPower
		return if not ent.__ppm2_modified_jump
		ent\SetJumpPower(ent\GetJumpPower() / PPM2.PONY_JUMP_MODIFIER)
		ent.__ppm2_modified_jump = false

	ResetModelScale: (ent = @GetEntity()) =>
		if SERVER
			--ent\SetModelScale(1)
			return
		mat = Matrix()
		mat\Scale(@@DEF_SCALE)
		ent\EnableMatrix('RenderMultiply', mat)

	ResetScale: (ent = @GetEntity()) =>
		return if not IsValid(ent)

		if USE_NEW_HULL\GetBool() or ent.__ppm2_modified_hull
			@ResetHulls(ent)
			@ResetJumpHeight(ent)

		@ResetViewOffset(ent)
		@ResetModelScale(ent)
		if @validSkeleton
			@ResetNeck(ent)
			@ResetLegs(ent)

	ResetNeck: (ent = @GetEntity()) =>
		return if not CLIENT
		return if not IsValid(@GetEntity())
		return if not @validSkeleton
		with ent
			\ManipulateBoneScale(@NECK_BONE_1, Vector(1, 1, 1))
			\ManipulateBoneScale(@NECK_BONE_2, Vector(1, 1, 1))
			\ManipulateBoneScale(@NECK_BONE_3, Vector(1, 1, 1))
			\ManipulateBoneScale(@NECK_BONE_4, Vector(1, 1, 1))
			\ManipulateBoneAngles(@NECK_BONE_1, Angle(0, 0, 0))
			\ManipulateBoneAngles(@NECK_BONE_2, Angle(0, 0, 0))
			\ManipulateBoneAngles(@NECK_BONE_3, Angle(0, 0, 0))
			\ManipulateBoneAngles(@NECK_BONE_4, Angle(0, 0, 0))
			\ManipulateBonePosition(@NECK_BONE_1, Vector(0, 0, 0))
			\ManipulateBonePosition(@NECK_BONE_2, Vector(0, 0, 0))
			\ManipulateBonePosition(@NECK_BONE_3, Vector(0, 0, 0))
			\ManipulateBonePosition(@NECK_BONE_4, Vector(0, 0, 0))

	ResetLegs: (ent = @GetEntity()) =>
		return if not CLIENT
		return if not IsValid(ent)
		return if not @validSkeleton

		vec1 = Vector(1, 1, 1)
		vec2 = Vector(0, 0, 0)
		ang = Angle(0, 0, 0)

		with ent
			\ManipulateBoneScale(@LEGS_BONE_ROOT, vec1)
			\ManipulateBoneScale(@LEGS_FRONT_1, vec1)
			\ManipulateBoneScale(@LEGS_FRONT_2, vec1)
			\ManipulateBoneScale(@LEGS_BEHIND_1_1, vec1)
			\ManipulateBoneScale(@LEGS_BEHIND_2_1, vec1)
			\ManipulateBoneScale(@LEGS_BEHIND_3_1, vec1)
			\ManipulateBoneScale(@LEGS_BEHIND_1_2, vec1)
			\ManipulateBoneScale(@LEGS_BEHIND_2_2, vec1)
			\ManipulateBoneScale(@LEGS_BEHIND_3_2, vec1)

			\ManipulateBoneAngles(@LEGS_BONE_ROOT, ang)
			\ManipulateBoneAngles(@LEGS_FRONT_1, ang)
			\ManipulateBoneAngles(@LEGS_FRONT_2, ang)
			\ManipulateBoneAngles(@LEGS_BEHIND_1_1, ang)
			\ManipulateBoneAngles(@LEGS_BEHIND_2_1, ang)
			\ManipulateBoneAngles(@LEGS_BEHIND_3_1, ang)
			\ManipulateBoneAngles(@LEGS_BEHIND_1_2, ang)
			\ManipulateBoneAngles(@LEGS_BEHIND_2_2, ang)
			\ManipulateBoneAngles(@LEGS_BEHIND_3_2, ang)

			\ManipulateBonePosition(@LEGS_BONE_ROOT, vec2)
			\ManipulateBonePosition(@LEGS_FRONT_1, vec2)
			\ManipulateBonePosition(@LEGS_FRONT_2, vec2)
			\ManipulateBonePosition(@LEGS_BEHIND_1_1, vec2)
			\ManipulateBonePosition(@LEGS_BEHIND_2_1, vec2)
			\ManipulateBonePosition(@LEGS_BEHIND_3_1, vec2)
			\ManipulateBonePosition(@LEGS_BEHIND_1_2, vec2)
			\ManipulateBonePosition(@LEGS_BEHIND_2_2, vec2)
			\ManipulateBonePosition(@LEGS_BEHIND_3_2, vec2)

	Remove: => @ResetScale()
	Reset: =>
		@ResetScale()
		@ResetNeck()
		@ResetLegs()
		@ModifyScale()

	GetLegsSize: => @GrabData('LegsSize')
	GetLegsScale: => @GrabData('LegsSize')
	GetNeckSize: => @GrabData('NeckSize')
	GetNeckScale: => @GrabData('NeckSize')
	GetPonySize: => @GrabData('PonySize')
	GetPonyScale: => @GrabData('PonySize')

	PlayerDeath: =>
		@ResetScale()
		@ResetNeck()
		@ResetLegs()
		@Remap()

	PlayerRespawn: =>
		@Remap()
		@ResetScale()
		@ModifyScale()

	SlowUpdate: =>
		@Remap()
		@ModifyScale()

	CalculatePonyHeight: => (@@HULL_MAXS.z - @@HULL_MINS.z) * @GetLegsModifier() * @GetPonySize()
	CalculatePonyHeightFull: => (@@HULL_MAXS.z - @@HULL_MINS.z) * @GetLegsModifier() * @GetPonySize() * @GetNeckModifier() * 1.17
	CalculatePonyWidth: => (@@HULL_MAXS.x - @@HULL_MINS.x) * @GetLegsModifier() * @GetPonySize()

	ModifyHull: (ent = @GetEntity()) =>
		ent.__ppm2_modified_hull = true
		size = @GetPonySize()
		legssize = @GetLegsModifier()

		HULL_MINS = Vector(@@HULL_MINS)
		HULL_MAXS = Vector(@@HULL_MAXS)
		HULL_MAXS_DUCK = Vector(@@HULL_MAXS_DUCK)

		if @AllowResize()
			HULL_MINS *= size
			HULL_MAXS *= size
			HULL_MAXS_DUCK *= size

			HULL_MINS.z *= legssize
			HULL_MAXS.z *= legssize
			HULL_MAXS_DUCK.z *= legssize

		with ent
			if .SetHull
				cmins, cmaxs = \GetHull()
				\SetHull(HULL_MINS, HULL_MAXS) if cmins ~= HULL_MINS or cmaxs ~= HULL_MAXS

			if .SetHullDuck
				cmins, cmaxs = \GetHullDuck()
				\SetHullDuck(HULL_MINS, HULL_MAXS_DUCK) if cmins ~= HULL_MINS or cmaxs ~= HULL_MAXS_DUCK

			if .SetStepSize
				newsize = @@STEP_SIZE * size * @GetLegsModifier(1.2)
				\SetStepSize(newsize) if \GetStepSize() ~= newsize

	ModifyJumpHeight: (ent = @GetEntity()) =>
		return if CLIENT
		return if not @GetEntity().SetJumpPower
		return if ent.__ppm2_modified_jump
		ent\SetJumpPower(ent\GetJumpPower() * PPM2.PONY_JUMP_MODIFIER)
		ent.__ppm2_modified_jump = true

	GetLegsModifier: (mult = 0.4) =>
		if @AllowResize()
			1 + (@GetLegsSize() - 1) * mult
		else
			1

	GetNeckModifier: (mult = 0.6) =>
		if @AllowResize()
			1 + (@GetNeckSize() - 1) * mult
		else
			1

	ModifyViewOffset: (ent = @GetEntity()) =>
		size = @GetPonySize()
		necksize = 1 + (@GetNeckSize() - 1) * .3
		legssize = @GetLegsModifier()

		PLAYER_VIEW_OFFSET = Vector(PPM2.PLAYER_VIEW_OFFSET)
		PLAYER_VIEW_OFFSET_DUCK = Vector(PPM2.PLAYER_VIEW_OFFSET_DUCK)

		if @AllowResize()
			PLAYER_VIEW_OFFSET *= size * necksize
			PLAYER_VIEW_OFFSET_DUCK *= size * necksize

			PLAYER_VIEW_OFFSET.z *= legssize
			PLAYER_VIEW_OFFSET_DUCK.z *= legssize

		ent\SetViewOffset(PLAYER_VIEW_OFFSET) if ent.SetViewOffset
		ent\SetViewOffsetDucked(PLAYER_VIEW_OFFSET_DUCK) if ent.SetViewOffsetDucked

	ModifyModelScale: (ent = @GetEntity()) =>
		return if not @AllowResize()
		-- https://github.com/Facepunch/garrysmod-issues/issues/2193
		if SERVER
			if not ent\IsPlayer()
				newscale = (@GetPonySize() * 100)\floor() / 100
				currscale = (ent\GetModelScale() * 100)\floor() / 100
				if currscale ~= newscale
					if type(ent) == 'NPC' or type(NPC) == 'NextBot'
						ent\SetPreventTransmit(ply, true) for _, ply in ipairs player.GetAll()
						ent\SetModelScale(newscale)
						ent\SetPreventTransmit(ply, false) for _, ply in ipairs player.GetAll()
					else
						ent\SetModelScale(newscale)
			return
		--return if not ent\IsClientsideEntity()
		return if ent.RenderOverride -- PAC3 and other stuff that can change this value
		mat = Matrix()
		mat\Scale(@@DEF_SCALE * @GetPonySize())
		ent\EnableMatrix('RenderMultiply', mat)

	ModifyScale: (ent = @GetEntity()) =>
		return if not IsValid(ent)
		return if not ent\IsPony()
		return if ent.Alive and not ent\Alive()

		if USE_NEW_HULL\GetBool()
			@ModifyHull(ent)
			@ModifyJumpHeight(ent)

		@ModifyViewOffset(ent)
		@ModifyModelScale(ent)

		if CLIENT and @lastPAC3BoneReset < RealTimeL()
			@ModifyNeck(ent)
			@ModifyLegs(ent)

	ModifyNeck: (ent = @GetEntity()) =>
		return if not IsValid(ent)
		return if not @AllowResize()
		return if not @validSkeleton
		size = (@GetNeckSize() - 1) * 3
		return if size\abs() * 4 <= 0.05
		vec = Vector(size, -size, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyVector = Vector(0, 0, 0)

		with ent
			\ManipulateBonePosition(@NECK_BONE_1, vec + (boneAnimTable[@NECK_BONE_1] or emptyVector))
			\ManipulateBonePosition(@NECK_BONE_2, vec + (boneAnimTable[@NECK_BONE_2] or emptyVector))
			\ManipulateBonePosition(@NECK_BONE_3, vec + (boneAnimTable[@NECK_BONE_3] or emptyVector))
			\ManipulateBonePosition(@NECK_BONE_4, vec + (boneAnimTable[@NECK_BONE_4] or emptyVector))

	ModifyLegs: (ent = @GetEntity()) =>
		return if not IsValid(ent)
		return if not @AllowResize()
		return if not @validSkeleton
		realSizeModify = @GetLegsSize() - 1
		return if realSizeModify\abs() * 4 <= 0.05
		size = realSizeModify * 3

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyVector = Vector(0, 0, 0)

		with ent
			\ManipulateBonePosition(@LEGS_BONE_ROOT, Vector(0, 0, size * 5) + \GetManipulateBonePosition(@LEGS_BONE_ROOT))

			\ManipulateBonePosition(@LEGS_FRONT_1, Vector(size * 1.5, 0, 0) + (boneAnimTable[@LEGS_FRONT_1] or emptyVector))
			\ManipulateBonePosition(@LEGS_FRONT_2, Vector(size * 1.5, 0, 0) + (boneAnimTable[@LEGS_FRONT_2] or emptyVector))

			\ManipulateBonePosition(@LEGS_FRONT_3, Vector(size, 0, 0) + (boneAnimTable[@LEGS_FRONT_3] or emptyVector))
			\ManipulateBonePosition(@LEGS_FRONT_4, Vector(size, 0, 0) + (boneAnimTable[@LEGS_FRONT_4] or emptyVector))

			\ManipulateBonePosition(@LEGS_FRONT_5, Vector(size, size, 0) + (boneAnimTable[@LEGS_FRONT_5] or emptyVector))
			\ManipulateBonePosition(@LEGS_FRONT_6, Vector(size, size, 0) + (boneAnimTable[@LEGS_FRONT_6] or emptyVector))

			\ManipulateBonePosition(@LEGS_BEHIND_1_1, Vector(size, -size * 0.5, 0) + (boneAnimTable[@LEGS_BEHIND_1_1] or emptyVector))
			\ManipulateBonePosition(@LEGS_BEHIND_1_2, Vector(size, -size * 0.5, 0) + (boneAnimTable[@LEGS_BEHIND_1_2] or emptyVector))

			\ManipulateBonePosition(@LEGS_BEHIND_2_1, Vector(size, 0, 0) + (boneAnimTable[@LEGS_BEHIND_2_1] or emptyVector))
			\ManipulateBonePosition(@LEGS_BEHIND_2_2, Vector(size, 0, 0) + (boneAnimTable[@LEGS_BEHIND_2_2] or emptyVector))

			\ManipulateBonePosition(@LEGS_BEHIND_3_1, Vector(size * 2, 0, 0) + (boneAnimTable[@LEGS_BEHIND_3_1] or emptyVector))
			\ManipulateBonePosition(@LEGS_BEHIND_3_2, Vector(size * 2, 0, 0) + (boneAnimTable[@LEGS_BEHIND_3_2] or emptyVector))

-- 0    LrigPelvis
-- 1    Lrig_LEG_BL_Femur
-- 2    Lrig_LEG_BL_Tibia
-- 3    Lrig_LEG_BL_LargeCannon
-- 4    Lrig_LEG_BL_PhalanxPrima
-- 5    Lrig_LEG_BL_RearHoof
-- 6    Lrig_LEG_BR_Femur
-- 7    Lrig_LEG_BR_Tibia
-- 8    Lrig_LEG_BR_LargeCannon
-- 9    Lrig_LEG_BR_PhalanxPrima
-- 10   Lrig_LEG_BR_RearHoof
-- 11   LrigSpine1
-- 12   LrigSpine2
-- 13   LrigRibcage
-- 14   Lrig_LEG_FL_Scapula
-- 15   Lrig_LEG_FL_Humerus
-- 16   Lrig_LEG_FL_Radius
-- 17   Lrig_LEG_FL_Metacarpus
-- 18   Lrig_LEG_FL_PhalangesManus
-- 19   Lrig_LEG_FL_FrontHoof
-- 20   Lrig_LEG_FR_Scapula
-- 21   Lrig_LEG_FR_Humerus
-- 22   Lrig_LEG_FR_Radius
-- 23   Lrig_LEG_FR_Metacarpus
-- 24   Lrig_LEG_FR_PhalangesManus
-- 25   Lrig_LEG_FR_FrontHoof
-- 26   LrigNeck1
-- 27   LrigNeck2
-- 28   LrigNeck3
-- 29   LrigScull
-- 30   Jaw
-- 31   Ear_L
-- 32   Ear_R
-- 33   Mane02
-- 34   Mane03
-- 35   Mane03_tip
-- 36   Mane04
-- 37   Mane05
-- 38   Mane06
-- 39   Mane07
-- 40   Mane01
-- 41   Lrigweaponbone
-- 42   right_hand
-- 43   wing_l
-- 44   wing_r
-- 45   Tail01
-- 46   Tail02
-- 47   Tail03
-- 48   wing_l_bat
-- 49   wing_r_bat
-- 50   wing_open_l
-- 51   wing_open_r

PPM2.PonySizeController = PonySizeController

class NewPonySizeContoller extends PonySizeController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	@NECK_BONE_1 = 'LrigNeck1'
	@NECK_BONE_2 = 'LrigNeck2'
	@NECK_BONE_3 = 'LrigNeck3'
	@NECK_BONE_4 = 'LrigScull'

	@LEGS_FRONT_1 = 'Lrig_LEG_FL_FrontHoof'
	@LEGS_FRONT_2 = 'Lrig_LEG_FR_FrontHoof'

	@LEGS_FRONT_3 = 'Lrig_LEG_FL_Metacarpus'
	@LEGS_FRONT_4 = 'Lrig_LEG_FR_Metacarpus'

	@LEGS_FRONT_5 = 'Lrig_LEG_FL_Radius'
	@LEGS_FRONT_6 = 'Lrig_LEG_FR_Radius'

	@LEGS_BEHIND_1_1 = 'Lrig_LEG_BL_Tibia'
	@LEGS_BEHIND_1_2 = 'Lrig_LEG_BR_Tibia'

	@LEGS_BEHIND_2_1 = 'Lrig_LEG_BL_PhalanxPrima'
	@LEGS_BEHIND_2_2 = 'Lrig_LEG_BR_PhalanxPrima'

	@LEGS_BEHIND_3_1 = 'Lrig_LEG_BL_LargeCannon'
	@LEGS_BEHIND_3_2 = 'Lrig_LEG_BR_LargeCannon'

	new: (...) =>
		super(...)

PPM2.NewPonySizeContoller = NewPonySizeContoller

hook.Add 'PPM2.SetupBones', 'PPM2.Size', (ent, data) ->
	if sizes = data\GetSizeController()
		sizes.ent = ent
		sizes\ModifyNeck()
		sizes\ModifyLegs()
		sizes.lastPAC3BoneReset = RealTimeL() + 1

ppm2_sv_allow_resize = ->
	for _, ply in ipairs player.GetAll()
		if data = ply\GetPonyData()
			if scale = data\GetSizeController()
				scale\Reset()

cvars.AddChangeCallback 'ppm2_sv_allow_resize', ppm2_sv_allow_resize, 'PPM2.Scale'

PPM2.GetSizeController = (model = 'models/ppm/player_default_base.mdl') -> PonySizeController.AVALIABLE_CONTROLLERS[model\lower()] or PonySizeController
