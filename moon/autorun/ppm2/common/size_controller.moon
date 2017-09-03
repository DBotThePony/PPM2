
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

-- 0	LrigPelvis
-- 1	LrigSpine1
-- 2	LrigSpine2
-- 3	LrigRibcage
-- 4	LrigNeck1
-- 5	LrigNeck2
-- 6	LrigNeck3
-- 7	LrigScull
-- 8	Lrig_LEG_BL_Femur
-- 9	Lrig_LEG_BL_Tibia
-- 10	Lrig_LEG_BL_LargeCannon
-- 11	Lrig_LEG_BL_PhalanxPrima
-- 12	Lrig_LEG_BL_RearHoof
-- 13	Lrig_LEG_BR_Femur
-- 14	Lrig_LEG_BR_Tibia
-- 15	Lrig_LEG_BR_LargeCannon
-- 16	Lrig_LEG_BR_PhalanxPrima
-- 17	Lrig_LEG_BR_RearHoof
-- 18	Lrig_LEG_FL_Scapula
-- 19	Lrig_LEG_FL_Humerus
-- 20	Lrig_LEG_FL_Radius
-- 21	Lrig_LEG_FL_Metacarpus
-- 22	Lrig_LEG_FL_PhalangesManus
-- 23	Lrig_LEG_FL_FrontHoof
-- 24	Lrig_LEG_FR_Scapula
-- 25	Lrig_LEG_FR_Humerus
-- 26	Lrig_LEG_FR_Radius
-- 27	Lrig_LEG_FR_Metacarpus
-- 28	Lrig_LEG_FR_PhalangesManus
-- 29	Lrig_LEG_FR_FrontHoof
-- 30	Mane01
-- 31	Mane02
-- 32	Mane03
-- 33	Mane04
-- 34	Mane05
-- 35	Mane06
-- 36	Mane07
-- 37	Mane03_tip
-- 38	Tail01
-- 39	Tail02
-- 40	Tail03

USE_NEW_HULL = CreateConVar('ppm2_sv_newhull', '1', {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Use proper collision box for ponies. Slightly affects jump mechanics. When disabled, unexpected behaviour could happen.')
ALLOW_TO_MODIFY_SCALE = PPM2.ALLOW_TO_MODIFY_SCALE

class PonySizeController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	@NECK_BONE_1 = 4
	@NECK_BONE_2 = 5
	@NECK_BONE_3 = 6
	@NECK_BONE_4 = 7

	@LEGS_BONE_ROOT = 0

	@LEGS_FRONT_1 = 23
	@LEGS_FRONT_2 = 29

	@LEGS_FRONT_3 = 21
	@LEGS_FRONT_4 = 27

	@LEGS_FRONT_5 = 20
	@LEGS_FRONT_6 = 26

	@LEGS_BEHIND_1_1 = 14
	@LEGS_BEHIND_2_1 = 16
	@LEGS_BEHIND_3_1 = 15

	@LEGS_BEHIND_1_2 = 9
	@LEGS_BEHIND_2_2 = 11
	@LEGS_BEHIND_3_2 = 10

	@NEXT_OBJ_ID = 0

	new: (controller) =>
		@isValid = true
		@ent = controller.ent
		@entID = controller.entID
		@controller = controller
		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0
		PPM2.DebugPrint('Created new size controller for ', @ent, ' as part of ', controller, '; internal ID is ', @objID)

	__tostring: => "[#{@@__name}:#{@objID}|#{@ent}]"
	IsValid: => @isValid
	GetData: => @controller
	GetEntity: => @ent
	GetEntityID: => @entID
	GetDataID: => @entID
	IsNetworked: => @controller\IsNetworked()
	AllowResize: => not @controller\IsNetworked() or ALLOW_TO_MODIFY_SCALE\GetBool()

	@STEP_SIZE = 18
	@PONY_HULL = 19
	@HULL_MINS = Vector(-@PONY_HULL, -@PONY_HULL, 0)
	@HULL_MAXS = Vector(@PONY_HULL, @PONY_HULL, 72 * PPM2.PONY_HEIGHT_MODIFIER)
	@HULL_MAXS_DUCK = Vector(@PONY_HULL, @PONY_HULL, 36 * PPM2.PONY_HEIGHT_MODIFIER_DUCK_HULL)

	@DEFAULT_HULL_MINS = Vector(-16, -16, 0)
	@DEFAULT_HULL_MAXS = Vector(16, 16, 72)
	@DEFAULT_HULL_MAXS_DUCK = Vector(16, 16, 36)
	@DEF_SCALE = Vector(1, 1, 1)

	DataChanges: (state) =>
		return if not IsValid(@ent)
		return if not @ent\IsPony()
		if state\GetKey() == 'PonySize'
			@ModifyScale()

		if state\GetKey() == 'NeckSize'
			@ModifyNeck()
			@ModifyViewOffset()

		if state\GetKey() == 'LegsSize'
			@ModifyLegs()
			@ModifyHull()
			@ModifyViewOffset()

	ResetViewOffset: (ent = @ent) =>
		ent\SetViewOffset(PPM2.PLAYER_VIEW_OFFSET_ORIGINAL) if ent.SetViewOffset
		ent\SetViewOffsetDucked(PPM2.PLAYER_VIEW_OFFSET_DUCK_ORIGINAL) if ent.SetViewOffsetDucked

	ResetHulls: (ent = @ent) =>
		ent\ResetHull() if ent.ResetHull
		ent\SetStepSize(@@STEP_SIZE) if ent.SetStepSize
		ent.__ppm2_modified_hull = false

	ResetJumpHeight: (ent = @ent) =>
		return if CLIENT
		return if not ent.SetJumpPower
		return if not ent.__ppm2_modified_jump
		ent\SetJumpPower(ent\GetJumpPower() / PPM2.PONY_JUMP_MODIFIER)
		ent.__ppm2_modified_jump = false

	ResetDrawMatrix: (ent = @ent) =>
		return if SERVER
		mat = Matrix()
		mat\Scale(@@DEF_SCALE)
		ent\EnableMatrix('RenderMultiply', mat)

	ResetScale: (ent = @ent) =>
		return if not IsValid(ent)

		if USE_NEW_HULL\GetBool() or ent.__ppm2_modified_hull
			@ResetHulls(ent)
			@ResetJumpHeight(ent)

		@ResetViewOffset(ent)
		@ResetDrawMatrix(ent)
		@ResetNeck(ent)
		@ResetLegs(ent)

	ResetNeck: (ent = @ent) =>
		return if not CLIENT
		return if not IsValid(@ent)
		with ent
			\ManipulateBoneScale(@@NECK_BONE_1, Vector(1, 1, 1))
			\ManipulateBoneScale(@@NECK_BONE_2, Vector(1, 1, 1))
			\ManipulateBoneScale(@@NECK_BONE_3, Vector(1, 1, 1))
			\ManipulateBoneScale(@@NECK_BONE_4, Vector(1, 1, 1))
			\ManipulateBoneAngles(@@NECK_BONE_1, Angle(0, 0, 0))
			\ManipulateBoneAngles(@@NECK_BONE_2, Angle(0, 0, 0))
			\ManipulateBoneAngles(@@NECK_BONE_3, Angle(0, 0, 0))
			\ManipulateBoneAngles(@@NECK_BONE_4, Angle(0, 0, 0))
			\ManipulateBonePosition(@@NECK_BONE_1, Vector(0, 0, 0))
			\ManipulateBonePosition(@@NECK_BONE_2, Vector(0, 0, 0))
			\ManipulateBonePosition(@@NECK_BONE_3, Vector(0, 0, 0))
			\ManipulateBonePosition(@@NECK_BONE_4, Vector(0, 0, 0))

	ResetLegs: (ent = @ent) =>
		return if not CLIENT
		return if not IsValid(ent)

		vec1 = Vector(1, 1, 1)
		vec2 = Vector(0, 0, 0)
		ang = Angle(0, 0, 0)

		with ent
			\ManipulateBoneScale(@@LEGS_BONE_ROOT, vec1)
			\ManipulateBoneScale(@@LEGS_FRONT_1, vec1)
			\ManipulateBoneScale(@@LEGS_FRONT_2, vec1)
			\ManipulateBoneScale(@@LEGS_BEHIND_1_1, vec1)
			\ManipulateBoneScale(@@LEGS_BEHIND_2_1, vec1)
			\ManipulateBoneScale(@@LEGS_BEHIND_3_1, vec1)
			\ManipulateBoneScale(@@LEGS_BEHIND_1_2, vec1)
			\ManipulateBoneScale(@@LEGS_BEHIND_2_2, vec1)
			\ManipulateBoneScale(@@LEGS_BEHIND_3_2, vec1)

			\ManipulateBoneAngles(@@LEGS_BONE_ROOT, ang)
			\ManipulateBoneAngles(@@LEGS_FRONT_1, ang)
			\ManipulateBoneAngles(@@LEGS_FRONT_2, ang)
			\ManipulateBoneAngles(@@LEGS_BEHIND_1_1, ang)
			\ManipulateBoneAngles(@@LEGS_BEHIND_2_1, ang)
			\ManipulateBoneAngles(@@LEGS_BEHIND_3_1, ang)
			\ManipulateBoneAngles(@@LEGS_BEHIND_1_2, ang)
			\ManipulateBoneAngles(@@LEGS_BEHIND_2_2, ang)
			\ManipulateBoneAngles(@@LEGS_BEHIND_3_2, ang)

			\ManipulateBonePosition(@@LEGS_BONE_ROOT, vec2)
			\ManipulateBonePosition(@@LEGS_FRONT_1, vec2)
			\ManipulateBonePosition(@@LEGS_FRONT_2, vec2)
			\ManipulateBonePosition(@@LEGS_BEHIND_1_1, vec2)
			\ManipulateBonePosition(@@LEGS_BEHIND_2_1, vec2)
			\ManipulateBonePosition(@@LEGS_BEHIND_3_1, vec2)
			\ManipulateBonePosition(@@LEGS_BEHIND_1_2, vec2)
			\ManipulateBonePosition(@@LEGS_BEHIND_2_2, vec2)
			\ManipulateBonePosition(@@LEGS_BEHIND_3_2, vec2)

	Remove: => @ResetScale()
	Reset: =>
		@ResetScale()
		@ResetNeck()
		@ResetLegs()
		@ModifyScale()

	GetLegsSize: => @GetData()\GetLegsSize()
	GetLegsScale: => @GetData()\GetLegsSize()
	GetNeckSize: => @GetData()\GetNeckSize()
	GetNeckScale: => @GetData()\GetNeckSize()
	GetPonySize: => @GetData()\GetPonySize()
	GetPonyScale: => @GetData()\GetPonySize()

	PlayerDeath: =>
		@ResetScale()
		@ResetNeck()
		@ResetLegs()
	PlayerRespawn: =>
		@ResetScale()
		@ModifyScale()

	SlowUpdate: =>
		@ModifyScale()

	ModifyHull: (ent = @ent) =>
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
			\SetHull(HULL_MINS, HULL_MAXS) if .SetHull
			\SetHullDuck(HULL_MINS, HULL_MAXS_DUCK) if .SetHullDuck
			\SetStepSize(@@STEP_SIZE * size * @GetLegsModifier(1.2)) if .SetStepSize

	ModifyJumpHeight: (ent = @ent) =>
		return if CLIENT
		return if not @ent.SetJumpPower
		return if ent.__ppm2_modified_jump
		ent\SetJumpPower(ent\GetJumpPower() * PPM2.PONY_JUMP_MODIFIER)
		ent.__ppm2_modified_jump = true

	GetLegsModifier: (mult = 0.4) =>
		if @AllowResize()
			1 + (@GetLegsSize() - 1) * mult
		else
			1

	ModifyViewOffset: (ent = @ent) =>
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

	ModifyDrawMatrix: (ent = @ent) =>
		return if SERVER
		return if not @AllowResize()
		return if ent.RenderOverride -- PAC3 and other stuff that can change this value
		mat = Matrix()
		mat\Scale(@@DEF_SCALE * @GetPonySize())
		ent\EnableMatrix('RenderMultiply', mat)

	ModifyScale: (ent = @ent) =>
		return if not IsValid(ent)
		return if not ent\IsPony()
		return if ent.Alive and not ent\Alive()

		if USE_NEW_HULL\GetBool()
			@ModifyHull(ent)
			@ModifyJumpHeight(ent)

		@ModifyViewOffset(ent)
		@ModifyDrawMatrix(ent)
		if @lastPAC3BoneReset < RealTime()
			@ModifyNeck(ent)
			@ModifyLegs(ent)

	ModifyNeck: (ent = @ent) =>
		return if SERVER
		return if not IsValid(ent)
		return if not @AllowResize()
		size = (@GetNeckSize() - 1) * 3
		vec = Vector(size, -size, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyVector = Vector(0, 0, 0)

		with ent
			\ManipulateBonePosition(@@NECK_BONE_1, vec + (boneAnimTable[@@NECK_BONE_1] or emptyVector))
			\ManipulateBonePosition(@@NECK_BONE_2, vec + (boneAnimTable[@@NECK_BONE_2] or emptyVector))
			\ManipulateBonePosition(@@NECK_BONE_3, vec + (boneAnimTable[@@NECK_BONE_3] or emptyVector))
			\ManipulateBonePosition(@@NECK_BONE_4, vec + (boneAnimTable[@@NECK_BONE_4] or emptyVector))

	ModifyLegs: (ent = @ent) =>
		return if SERVER
		return if not IsValid(ent)
		return if not @AllowResize()
		realSizeModify = @GetLegsSize() - 1
		size = realSizeModify * 3

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyVector = Vector(0, 0, 0)

		with ent
			\ManipulateBonePosition(@@LEGS_BONE_ROOT, Vector(0, 0, size * 5) + (boneAnimTable[@@LEGS_BONE_ROOT] or emptyVector))
			\ManipulateBonePosition(@@LEGS_FRONT_1, Vector(size * 1.5, 0, 0) + (boneAnimTable[@@LEGS_FRONT_1] or emptyVector))
			\ManipulateBonePosition(@@LEGS_FRONT_2, Vector(size * 1.5, 0, 0) + (boneAnimTable[@@LEGS_FRONT_2] or emptyVector))

			\ManipulateBonePosition(@@LEGS_FRONT_3, Vector(size, 0, 0) + (boneAnimTable[@@LEGS_FRONT_3] or emptyVector))
			\ManipulateBonePosition(@@LEGS_FRONT_4, Vector(size, 0, 0) + (boneAnimTable[@@LEGS_FRONT_4] or emptyVector))

			\ManipulateBonePosition(@@LEGS_FRONT_5, Vector(size, size, 0) + (boneAnimTable[@@LEGS_FRONT_5] or emptyVector))
			\ManipulateBonePosition(@@LEGS_FRONT_6, Vector(size, size, 0) + (boneAnimTable[@@LEGS_FRONT_6] or emptyVector))

			\ManipulateBonePosition(@@LEGS_BEHIND_1_1, Vector(size, -size * 0.5, 0) + (boneAnimTable[@@LEGS_BEHIND_1_1] or emptyVector))
			\ManipulateBonePosition(@@LEGS_BEHIND_1_2, Vector(size, -size * 0.5, 0) + (boneAnimTable[@@LEGS_BEHIND_1_2] or emptyVector))

			\ManipulateBonePosition(@@LEGS_BEHIND_2_1, Vector(size, 0, 0) + (boneAnimTable[@@LEGS_BEHIND_2_1] or emptyVector))
			\ManipulateBonePosition(@@LEGS_BEHIND_2_2, Vector(size, 0, 0) + (boneAnimTable[@@LEGS_BEHIND_2_2] or emptyVector))

			\ManipulateBonePosition(@@LEGS_BEHIND_3_1, Vector(size * 2, 0, 0) + (boneAnimTable[@@LEGS_BEHIND_3_1] or emptyVector))
			\ManipulateBonePosition(@@LEGS_BEHIND_3_2, Vector(size * 2, 0, 0) + (boneAnimTable[@@LEGS_BEHIND_3_2] or emptyVector))

--
-- 0	LrigPelvis
-- 1	Lrig_LEG_BL_Femur
-- 2	Lrig_LEG_BL_Tibia
-- 3	Lrig_LEG_BL_LargeCannon
-- 4	Lrig_LEG_BL_PhalanxPrima
-- 5	Lrig_LEG_BL_RearHoof
-- 6	Lrig_LEG_BR_Femur
-- 7	Lrig_LEG_BR_Tibia
-- 8	Lrig_LEG_BR_LargeCannon
-- 9	Lrig_LEG_BR_PhalanxPrima
-- 10	Lrig_LEG_BR_RearHoof
-- 11	LrigSpine1
-- 12	LrigSpine2
-- 13	LrigRibcage
-- 14	Lrig_LEG_FL_Scapula
-- 15	Lrig_LEG_FL_Humerus
-- 16	Lrig_LEG_FL_Radius
-- 17	Lrig_LEG_FL_Metacarpus
-- 18	Lrig_LEG_FL_PhalangesManus
-- 19	Lrig_LEG_FL_FrontHoof
-- 20	Lrig_LEG_FR_Scapula
-- 21	Lrig_LEG_FR_Humerus
-- 22	Lrig_LEG_FR_Radius
-- 23	Lrig_LEG_FR_Metacarpus
-- 24	Lrig_LEG_FR_PhalangesManus
-- 25	Lrig_LEG_FR_FrontHoof
-- 26	LrigNeck1
-- 27	LrigNeck2
-- 28	LrigNeck3
-- 29	LrigScull
-- 30	Jaw
-- 31	Ear_L
-- 32	Ear_R
-- 33	Mane02
-- 34	Mane03
-- 35	Mane03_tip
-- 36	Mane04
-- 37	Mane05
-- 38	Mane06
-- 39	Mane07
-- 40	Mane01
-- 41	Lrigweaponbone
-- 42	Tail01
-- 43	Tail02
-- 44	Tail03
--

class NewPonySizeContoller extends PonySizeController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	@NECK_BONE_1 = 26
	@NECK_BONE_2 = 27
	@NECK_BONE_3 = 28
	@NECK_BONE_4 = 29

	@LEGS_FRONT_1 = 19
	@LEGS_FRONT_2 = 25

	@LEGS_FRONT_3 = 17
	@LEGS_FRONT_4 = 23

	@LEGS_FRONT_5 = 16
	@LEGS_FRONT_6 = 22

	@LEGS_BEHIND_1_1 = 2
	@LEGS_BEHIND_1_2 = 7

	@LEGS_BEHIND_2_1 = 4
	@LEGS_BEHIND_2_2 = 9

	@LEGS_BEHIND_3_1 = 3
	@LEGS_BEHIND_3_2 = 8

	new: (...) =>
		super(...)

if CLIENT
	hook.Add 'PPM2.SetupBones', 'PPM2.Size', (ent, data) ->
		if sizes = data\GetSizeController()
			sizes.ent = ent
			sizes\ModifyNeck()
			sizes\ModifyLegs()
			sizes.lastPAC3BoneReset = RealTime() + 1

ppm2_sv_allow_resize = ->
	for ply in *player.GetAll()
		if data = ply\GetPonyData()
			if scale = data\GetSizeController()
				scale\Reset()

cvars.AddChangeCallback 'ppm2_sv_allow_resize', ppm2_sv_allow_resize, 'PPM2.Scale'

PPM2.GetSizeController = (model = 'models/ppm/player_default_base.mdl') -> PonySizeController.AVALIABLE_CONTROLLERS[model\lower()] or PonySizeController
