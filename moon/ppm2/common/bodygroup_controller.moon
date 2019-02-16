
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


import PPM2, ents, LocalPlayer, SERVER, NULL, CLIENT, EF_BONEMERGE from _G

ALLOW_TO_MODIFY_SCALE = PPM2.ALLOW_TO_MODIFY_SCALE

TRACKED_ENTS = {}
TRACKED_ENTS_FRAME = 0
ents_GetAll = ->
	if TRACKED_ENTS_FRAME ~= FrameNumberL()
		TRACKED_ENTS = ents.GetAll()
		TRACKED_ENTS_FRAME = FrameNumberL()
	return TRACKED_ENTS

if CLIENT
	for _, ent in ipairs ents.GetAll()
		if ent.isPonyLegsModel or ent.isPonyPropModel
			ent\Remove()

PPM2.BODYGROUP_SKELETON = 0
PPM2.BODYGROUP_GENDER = 1
PPM2.BODYGROUP_HORN = 2
PPM2.BODYGROUP_WINGS = 3
PPM2.BODYGROUP_MANE_UPPER = 4
PPM2.BODYGROUP_MANE_LOWER = 5
PPM2.BODYGROUP_TAIL = 6
PPM2.BODYGROUP_CMARK = 7
PPM2.BODYGROUP_EYELASH = 8

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

class DefaultBodygroupController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl'}

	@BODYGROUP_SKELETON = 0
	@BODYGROUP_GENDER = 1
	@BODYGROUP_HORN = 2
	@BODYGROUP_WINGS = 3
	@BODYGROUP_MANE_UPPER = 4
	@BODYGROUP_MANE_LOWER = 5
	@BODYGROUP_TAIL = 6
	@BODYGROUP_CMARK = 7
	@BODYGROUP_EYELASH = 8

	@NEXT_OBJ_ID = 0

	@COOLDOWN_TIME = 5
	@COOLDOWN_MAX_COUNT = 4

	@BONE_MANE_1 = 'Mane01'
	@BONE_MANE_2 = 'Mane02'
	@BONE_MANE_3 = 'Mane03'
	@BONE_MANE_4 = 'Mane04'
	@BONE_MANE_5 = 'Mane05'
	@BONE_MANE_6 = 'Mane06'
	@BONE_MANE_7 = 'Mane07'
	@BONE_MANE_8 = 'Mane03_tip'

	@BONE_TAIL_1 = 'Tail01'
	@BONE_TAIL_2 = 'Tail02'
	@BONE_TAIL_3 = 'Tail03'

	@BONE_SPINE_ROOT = 'LrigPelvis'
	@BONE_SPINE = 'LrigSpine2'

	Remap: =>
		mapping = {
			'BONE_SPINE_ROOT'
			'BONE_TAIL_1', 'BONE_TAIL_2', 'BONE_TAIL_3'
			'BONE_SPINE', 'BONE_MANE_1', 'BONE_MANE_2'
			'BONE_MANE_3', 'BONE_MANE_4', 'BONE_MANE_5'
			'BONE_MANE_6', 'BONE_MANE_7', 'BONE_MANE_8'
		}

		@validSkeleton = true

		for _, name in ipairs mapping
			@[name] = @GetEntity()\LookupBone(@@[name])

			if not @[name]
				@validSkeleton = false

	new: (controller) =>
		super(controller)
		@isValid = true
		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0
		@Remap()

		PPM2.DebugPrint('Created new bodygroups controller for ', @GetEntity(), ' as part of ', controller, '; internal ID is ', @objID)

	IsValid: => @isValid

	@ATTACHMENT_EYES = 4
	@ATTACHMENT_EYES_NAME = 'eyes'

	CreateSocksModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		return @socksModel if IsValid(@socksModel)
		for _, ent in ipairs ents_GetAll()
			if ent.isPonyPropModel and ent.isSocks and ent.manePlayer == @GetEntity()
				@socksModel = ent
				@GetData()\SetSocksModel(@socksModel)
				PPM2.DebugPrint('Resuing ', @socksModel, ' as socks model for ', @GetEntity())
				return ent

		with @socksModel = ClientsideModel('models/props_pony/ppm/cosmetics/ppm_socks.mdl')
			.isPonyPropModel = true
			.isSocks = true
			.manePlayer = @GetEntity()
			\DrawShadow(true)
			\SetPos(@GetEntity()\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true)
			\SetParent(@GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new socks model for ', @GetEntity(), ' as ', @socksModel)
		@GetData()\SetSocksModel(@socksModel)
		return @socksModel

	CreateNewSocksModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		return @newSocksModel if IsValid(@newSocksModel)
		for _, ent in ipairs ents_GetAll()
			if ent.isPonyPropModel and ent.isNewSocks and ent.manePlayer == @GetEntity()
				@newSocksModel = ent
				@GetData()\SetNewSocksModel(@newSocksModel)
				PPM2.DebugPrint('Resuing ', @newSocksModel, ' as socks model for ', @GetEntity())
				return ent

		with @newSocksModel = ClientsideModel('models/props_pony/ppm/cosmetics/ppm2_socks.mdl')
			.isPonyPropModel = true
			.isNewSocks = true
			.manePlayer = @GetEntity()
			\DrawShadow(true)
			\SetPos(@GetEntity()\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true)
			\SetParent(@GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new socks model for ', @GetEntity(), ' as ', @newSocksModel)
		@GetData()\SetNewSocksModel(@newSocksModel)
		return @newSocksModel

	CreateNewSocksModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		@CreateNewSocksModel(force) if not IsValid(@newSocksModel)
		return NULL if not IsValid(@newSocksModel)
		@newSocksModel\SetParent(@GetEntity()) if IsValid(@GetEntity())
		@GetData()\SetNewSocksModel(@newSocksModel)
		return @newSocksModel

	CreateSocksModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		@CreateSocksModel(force) if not IsValid(@socksModel)
		return NULL if not IsValid(@socksModel)
		@socksModel\SetParent(@GetEntity()) if IsValid(@GetEntity())
		@GetData()\SetSocksModel(@socksModel)
		return @socksModel

	MergeModels: (targetEnt = NULL) =>
		return if SERVER or not @isValid or not IsValid(targetEnt)
		socks = @CreateSocksModelIfNotExists(true) if @GetData()\GetSocksAsModel()
		socks2 = @CreateNewSocksModelIfNotExists(true) if @GetData()\GetSocksAsNewModel()
		if IsValid(socks)
			socks\SetParent(targetEnt)
		if IsValid(socks2)
			socks2\SetParent(targetEnt)

	GetSocks: => @socksModel or NULL

	ApplyRace: =>
		return unless @isValid
		return NULL if not IsValid(@GetEntity())
		with @GetEntity()
			switch @GetData()\GetRace()
				when PPM2.RACE_EARTH
					\SetBodygroup(@@BODYGROUP_HORN, 1)
					\SetBodygroup(@@BODYGROUP_WINGS, 1)
				when PPM2.RACE_PEGASUS
					\SetBodygroup(@@BODYGROUP_HORN, 1)
					\SetBodygroup(@@BODYGROUP_WINGS, 0)
				when PPM2.RACE_UNICORN
					\SetBodygroup(@@BODYGROUP_HORN, 0)
					\SetBodygroup(@@BODYGROUP_WINGS, 1)
				when PPM2.RACE_ALICORN
					\SetBodygroup(@@BODYGROUP_HORN, 0)
					\SetBodygroup(@@BODYGROUP_WINGS, 0)

	ResetTail: =>
		return if not CLIENT
		return if not @validSkeleton
		with @GetEntity()
			\ManipulateBoneScale2Safe(@BONE_TAIL_1, LVector(1, 1, 1))
			\ManipulateBoneScale2Safe(@BONE_TAIL_2, LVector(1, 1, 1))
			\ManipulateBoneScale2Safe(@BONE_TAIL_3, LVector(1, 1, 1))
			\ManipulateBoneAngles2Safe(@BONE_TAIL_1, Angle(0, 0, 0))
			\ManipulateBoneAngles2Safe(@BONE_TAIL_2, Angle(0, 0, 0))
			\ManipulateBoneAngles2Safe(@BONE_TAIL_3, Angle(0, 0, 0))
			\ManipulateBonePosition2Safe(@BONE_TAIL_1, LVector(0, 0, 0))
			\ManipulateBonePosition2Safe(@BONE_TAIL_2, LVector(0, 0, 0))
			\ManipulateBonePosition2Safe(@BONE_TAIL_3, LVector(0, 0, 0))

	ResetBack: =>
		return if not CLIENT
		return if not @validSkeleton
		with @GetEntity()
			\ManipulateBoneScale2Safe(@BONE_SPINE_ROOT, LVector(1, 1, 1))
			\ManipulateBoneScale2Safe(@BONE_SPINE, LVector(1, 1, 1))
			\ManipulateBoneAngles2Safe(@BONE_SPINE_ROOT, Angle(0, 0, 0))
			\ManipulateBoneAngles2Safe(@BONE_SPINE, Angle(0, 0, 0))
			\ManipulateBonePosition2Safe(@BONE_SPINE_ROOT, LVector(0, 0, 0))
			\ManipulateBonePosition2Safe(@BONE_SPINE, LVector(0, 0, 0))

	ResetMane: =>
		return if not CLIENT
		return if not @validSkeleton
		vec1, ang, vec2 = LVector(1, 1, 1), Angle(0, 0, 0), LVector(0, 0, 0)
		with @GetEntity()
			for i = 1, 7
				\ManipulateBoneScale2Safe(@['BONE_MANE_' .. i], vec1)
				\ManipulateBoneAngles2Safe(@['BONE_MANE_' .. i], ang)
				\ManipulateBonePosition2Safe(@['BONE_MANE_' .. i], vec2)

	ResetBodygroups: =>
		return unless @isValid
		return unless IsValid(@GetEntity())
		return unless @GetEntity()\GetBodyGroups()
		return if not @validSkeleton

		for _, grp in ipairs @GetEntity()\GetBodyGroups()
			@GetEntity()\SetBodygroup(grp.id, 0)

		if @lastPAC3BoneReset < RealTimeL()
			@ResetTail()
			@ResetMane()
			@ResetBack()

	Reset: => @ResetBodygroups()
	RemoveModels: =>
		@socksModel\Remove() if IsValid(@socksModel)
		@newSocksModel\Remove() if IsValid(@newSocksModel)

	UpdateTailSize: (ent = @GetEntity()) =>
		return if not CLIENT
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		return if not @validSkeleton
		size = @GetData()\GetTailSize()
		size *= @GetData()\GetPonySize() if not ent\IsRagdoll() and not ent\IsNJPony()
		vec = LVector(1, 1, 1)
		vecTail = vec * size
		vecTailPos = LVector((size - 1) * 8, 0, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyLVector = LVector(0, 0, 0)

		with ent
			\ManipulateBoneScale2Safe(@BONE_TAIL_1, vecTail)
			\ManipulateBoneScale2Safe(@BONE_TAIL_2, vecTail)
			\ManipulateBoneScale2Safe(@BONE_TAIL_3, vecTail)

			--\ManipulateBonePosition2Safe(@BONE_TAIL_1, vecTail + (boneAnimTable[@BONE_TAIL_1] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_TAIL_2, vecTailPos + (boneAnimTable[@BONE_TAIL_2] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_TAIL_3, vecTailPos + (boneAnimTable[@BONE_TAIL_3] or emptyLVector))

	UpdateManeSize: (ent = @GetEntity()) =>
		return if not CLIENT
		return if ent\IsRagdoll()
		return if ent\IsNJPony()
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		return if not @validSkeleton
		size = @GetData()\GetPonySize()
		vecMane = LVector(1, 1, 1) * size

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyLVector = LVector(0, 0, 0)

		with ent
			\ManipulateBoneScale2Safe(@BONE_MANE_1, vecMane)
			\ManipulateBoneScale2Safe(@BONE_MANE_2, vecMane)
			\ManipulateBoneScale2Safe(@BONE_MANE_3, vecMane)
			\ManipulateBoneScale2Safe(@BONE_MANE_4, vecMane)
			\ManipulateBoneScale2Safe(@BONE_MANE_5, vecMane)
			\ManipulateBoneScale2Safe(@BONE_MANE_6, vecMane)
			\ManipulateBoneScale2Safe(@BONE_MANE_7, vecMane)
			\ManipulateBoneScale2Safe(@BONE_MANE_8, vecMane)

			\ManipulateBonePosition2Safe(@BONE_MANE_1, LVector(-(size - 1) * 4, (1 - size) * 3, 0) + (boneAnimTable[@BONE_MANE_1] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_MANE_2, LVector(-(size - 1) * 4, (size - 1) * 2, 1) + (boneAnimTable[@BONE_MANE_2] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_MANE_3, LVector((size - 1) * 2, 0, 0) +               (boneAnimTable[@BONE_MANE_3] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_MANE_4, LVector(1 - size, (1 - size) * 4, 1 - size) + (boneAnimTable[@BONE_MANE_4] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_MANE_5, LVector((size - 1) * 4, (1 - size) * 2, (size - 1) * 3) + (boneAnimTable[@BONE_MANE_5] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_MANE_6, LVector(0, 0, -(size - 1) * 2) +              (boneAnimTable[@BONE_MANE_6] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_MANE_7, LVector(0, 0, -(size - 1) * 2) +              (boneAnimTable[@BONE_MANE_7] or emptyLVector))

	UpdateBack: (ent = @GetEntity()) =>
		return if not CLIENT
		return if ent\IsRagdoll()
		return if ent\IsNJPony()
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		return if not @validSkeleton

		vecModify = LVector(-(@GetData()\GetBackSize() - 1) * 2, 0, 0)
		vecModify2 = LVector((@GetData()\GetBackSize() - 1) * 5, 0, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyLVector = LVector(0, 0, 0)

		with ent
			\ManipulateBonePosition2Safe(@BONE_SPINE_ROOT, vecModify + (boneAnimTable[@BONE_SPINE_ROOT] or emptyLVector))
			\ManipulateBonePosition2Safe(@BONE_SPINE, vecModify2 + (boneAnimTable[@BONE_SPINE] or emptyLVector))

	SlowUpdate: (createModels = CLIENT, ent = @GetEntity(), force = false) =>
		return if not IsValid(ent)
		return if not ent\IsPony()
		with ent
			\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GetData()\GetManeType())
			\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GetData()\GetManeTypeLower())
			\SetBodygroup(@@BODYGROUP_TAIL, @GetData()\GetTailType())
			\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
			\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())

		@ApplyRace()
		if createModels
			@CreateSocksModelIfNotExists(force) if @GetData()\GetSocksAsModel()
			@CreateNewSocksModelIfNotExists(force) if @GetData()\GetSocksAsNewModel()

	ApplyBodygroups: (createModels = CLIENT, force = false) =>
		return unless @isValid
		return if not IsValid(@GetEntity())
		@ResetBodygroups()
		return if not @GetEntity()\IsPony()
		@SlowUpdate(createModels, force)

	Remove: =>
		@RemoveModels()
		@ResetBodygroups()
		@isValid = false

	DataChanges: (state) =>
		return unless @isValid
		return if not IsValid(@GetEntity())
		@Remap()

		switch state\GetKey()
			when 'ManeType'
				@GetEntity()\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GetData()\GetManeType())
			when 'ManeTypeLower'
				@GetEntity()\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GetData()\GetManeTypeLower())
			when 'TailType'
				@GetEntity()\SetBodygroup(@@BODYGROUP_TAIL, @GetData()\GetTailType())
			when 'TailSize', 'PonySize'
				@UpdateTailSize()
			when 'EyelashType'
				@GetEntity()\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
			when 'Gender'
				@GetEntity()\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
			when 'SocksAsModel'
				if state\GetValue()
					@CreateSocksModelIfNotExists()
				else
					@socksModel\Remove() if IsValid(@socksModel)
			when 'SocksAsNewModel'
				if state\GetValue()
					@CreateNewSocksModelIfNotExists()
				else
					@newSocksModel\Remove() if IsValid(@newSocksModel)
			when 'Race'
				@ApplyRace()

class CPPMBodygroupController extends DefaultBodygroupController
	@MODELS = {'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	new: (...) => super(...)

	ApplyRace: =>
		return unless @isValid
		switch @GetData()\GetRace()
			when PPM2.RACE_EARTH
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 1)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, 1)
			when PPM2.RACE_PEGASUS
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 1)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, 0)
			when PPM2.RACE_UNICORN
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 0)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, 1)
			when PPM2.RACE_ALICORN
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 2)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, 3)

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

class NewBodygroupController extends DefaultBodygroupController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	@BODYGROUP_SKELETON = 0
	@BODYGROUP_GENDER = -1
	@BODYGROUP_HORN = 1
	@BODYGROUP_WINGS = 2

	@EAR_L = 'Ear_L'
	@EAR_R = 'Ear_R'

	@WING_LEFT_1 = 'wing_l'
	@WING_LEFT_2 = 'wing_l_bat'
	@WING_RIGHT_1 = 'wing_r'
	@WING_RIGHT_2 = 'wing_r_bat'

	@WING_OPEN_LEFT = 'wing_open_l'
	@WING_OPEN_RIGHT = 'wing_open_r'

	@BONE_SPINE = 'LrigSpine1'

	Remap: =>
		super!
		mapping = {
			'EAR_L', 'EAR_R'
			'WING_LEFT_1', 'WING_LEFT_2', 'WING_RIGHT_1'
			'WING_RIGHT_2', 'WING_OPEN_LEFT', 'WING_OPEN_RIGHT'
		}

		for _, name in ipairs mapping
			@[name] = @GetEntity()\LookupBone(@@[name])

			if not @[name]
				@validSkeleton = false

	CreateUpperManeModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		return @maneModelUP if IsValid(@maneModelUP)

		for _, ent in ipairs ents_GetAll()
			if ent.isPonyPropModel and ent.upperMane and ent.manePlayer == @GetEntity()
				@maneModelUP = ent
				@GetData()\SetUpperManeModel(@maneModelUP)
				PPM2.DebugPrint('Resuing ', @maneModelUP, ' as upper mane model for ', @GetEntity())
				return ent

		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
		modelID = "0" .. modelID if modelID < 10
		with @maneModelUP = ClientsideModel("models/ppm/hair/ppm_manesetupper#{modelID}.mdl")
			.isPonyPropModel = true
			.upperMane = true
			.manePlayer = @GetEntity()
			\DrawShadow(true) if CLIENT
			\SetPos(@GetEntity()\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true) if CLIENT
			\SetBodygroup(1, bodygroupID)
			\SetParent(@GetEntity())
			\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new upper mane model for ', @GetEntity(), ' as ', @maneModelUP)

		if SERVER
			timer.Simple .5, ->
				return unless @isValid
				return unless IsValid(@maneModelUP)
				@GetData()\SetUpperManeModel(@maneModelUP)
		else
			@GetData()\SetUpperManeModel(@maneModelUP)

		return @maneModelUP

	CreateLowerManeModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		return @maneModelLower if IsValid(@maneModelLower)
		for _, ent in ipairs ents_GetAll()
			if ent.isPonyPropModel and ent.lowerMane and ent.manePlayer == @GetEntity()
				@maneModelLower = ent
				@GetData()\SetLowerManeModel(@maneModelLower)
				PPM2.DebugPrint('Resuing ', @maneModelLower, ' as lower mane model for ', @GetEntity())
				return ent

		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
		modelID = "0" .. modelID if modelID < 10
		with @maneModelLower = ClientsideModel("models/ppm/hair/ppm_manesetlower#{modelID}.mdl")
			.isPonyPropModel = true
			.lowerMane = true
			.manePlayer = @GetEntity()
			\DrawShadow(true)
			\SetPos(@GetEntity()\EyePos())
			\Spawn()
			\Activate()
			\SetBodygroup(1, bodygroupID)
			\SetNoDraw(true)
			\SetParent(@GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new lower mane model for ', @GetEntity(), ' as ', @maneModelLower)
		@GetData()\SetLowerManeModel(@maneModelLower)
		return @maneModelLower

	CreateTailModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		return @tailModel if IsValid(@tailModel)
		for _, ent in ipairs ents_GetAll()
			if ent.isPonyPropModel and ent.isTail and ent.manePlayer == @GetEntity()
				@tailModel = ent
				@GetData()\SetTailModel(@tailModel)
				PPM2.DebugPrint('Resuing ', @tailModel, ' as tail model for ', @GetEntity())
				return ent

		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
		modelID = "0" .. modelID if modelID < 10

		with @tailModel = ClientsideModel("models/ppm/hair/ppm_tailset#{modelID}.mdl")
			.isPonyPropModel = true
			.isTail = true
			.manePlayer = @GetEntity()
			\DrawShadow(true)
			\SetPos(@GetEntity()\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true)
			\SetBodygroup(1, bodygroupID)
			\SetParent(@GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new tail model for ', @GetEntity(), ' as ', @tailModel)
		@GetData()\SetTailModel(@tailModel)
		return @tailModel

	CreateUpperManeModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not @GetEntity()\IsPony()
		@CreateUpperManeModel(force) if not IsValid(@maneModelUP)
		@GetData()\SetUpperManeModel(@maneModelUP) if IsValid(@maneModelUP)
		return @maneModelUP

	CreateLowerManeModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not @GetEntity()\IsPony()
		@CreateLowerManeModel(force) if not IsValid(@maneModelLower)
		@GetData()\SetLowerManeModel(@maneModelLower) if IsValid(@maneModelLower)
		return @maneModelLower

	CreateTailModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not @GetEntity()\IsPony()
		@CreateTailModel(force) if not IsValid(@tailModel)
		@GetData()\SetTailModel(@tailModel) if IsValid(@tailModel)
		return @tailModel

	GetUpperMane: => @maneModelUP or NULL
	GetLowerMane: => @maneModelLower or NULL
	GetTail: => @tailModel or NULL

	MergeModels: (targetEnt = NULL) =>
		return unless @isValid
		super(targetEnt)
		return unless IsValid(targetEnt)
		for _, e in ipairs {@CreateUpperManeModelIfNotExists(true), @CreateLowerManeModelIfNotExists(true), @CreateTailModelIfNotExists(true)}
			e\SetParent(targetEnt) if IsValid(e)

	UpdateUpperMane: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		@CreateUpperManeModelIfNotExists(force)
		return NULL if not IsValid(@maneModelUP)
		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
		modelID = "0" .. modelID if modelID < 10
		model = "models/ppm/hair/ppm_manesetupper#{modelID}.mdl"
		with @maneModelUP
			\SetModel(model) if model ~= \GetModel()
			\SetBodygroup(1, bodygroupID) if \GetBodygroup(1) ~= bodygroupID
			\SetParent(@GetEntity()) if \GetParent() ~= @GetEntity() and IsValid(@GetEntity())
		@GetData()\SetUpperManeModel(@maneModelUP)
		return @maneModelUP

	UpdateLowerMane: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		@CreateLowerManeModelIfNotExists(force)
		return NULL if not IsValid(@maneModelLower)
		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
		modelID = "0" .. modelID if modelID < 10
		model = "models/ppm/hair/ppm_manesetlower#{modelID}.mdl"
		with @maneModelLower
			\SetModel(model) if model ~= \GetModel()
			\SetBodygroup(1, bodygroupID) if \GetBodygroup(1) ~= bodygroupID
			\SetParent(@GetEntity()) if IsValid(@GetEntity())
		@GetData()\SetLowerManeModel(@maneModelLower)
		return @maneModelLower

	UpdateTailModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		@CreateTailModelIfNotExists(force)
		return NULL if not IsValid(@tailModel)
		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
		modelID = "0" .. modelID if modelID < 10
		model = "models/ppm/hair/ppm_tailset#{modelID}.mdl"
		with @tailModel
			\SetModel(model) if model ~= \GetModel()
			\SetBodygroup(1, bodygroupID) if \GetBodygroup(1) ~= bodygroupID
			\SetParent(@GetEntity()) if IsValid(@GetEntity())
		@GetData()\SetTailModel(@tailModel)
		return @tailModel

	@FLEX_ID_EYELASHES = 16
	@FLEX_ID_MALE = 25
	@FLEX_ID_MALE_2 = 35
	@FLEX_ID_MALE_BODY = 36
	@FLEX_ID_BAT_PONY_EARS = 28
	@FLEX_ID_FANGS = 31
	@FLEX_ID_FANGS2 = 29
	@FLEX_ID_CLAW_TEETH = 30
	@FLEX_ID_HOOF_FLUFF = 26

	ResetWings: =>
		return if SERVER
		return if not @validSkeleton
		ang, vec1, vec2 = Angle(0, 0, 0), LVector(1, 1, 1), LVector(0, 0, 0)
		for _, wing in ipairs {@WING_LEFT_1, @WING_LEFT_2, @WING_RIGHT_1, @WING_RIGHT_2, @WING_OPEN_LEFT, @WING_OPEN_RIGHT}
			with @GetEntity()
				\ManipulateBoneAngles2Safe(wing, ang)
				\ManipulateBoneScale2Safe(wing, vec1)
				\ManipulateBonePosition2Safe(wing, vec2)

	UpdateWings: =>
		return if SERVER
		return if not @validSkeleton
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		left = @GetData()\GetLWingSize() * LVector(1, 1, 1)
		leftX = @GetData()\GetLWingX()
		leftY = @GetData()\GetLWingY()
		leftZ = @GetData()\GetLWingZ()
		right = @GetData()\GetRWingSize() * LVector(1, 1, 1)
		rightX = @GetData()\GetRWingX()
		rightY = @GetData()\GetRWingY()
		rightZ = @GetData()\GetRWingZ()
		leftPos = LVector(leftX, leftY, leftZ)
		rightPos = LVector(rightX, rightY, rightZ)

		with @GetEntity()
			\ManipulateBoneScale2Safe(@WING_LEFT_1, left)
			\ManipulateBoneScale2Safe(@WING_LEFT_2, left)
			\ManipulateBoneScale2Safe(@WING_OPEN_LEFT, left)
			\ManipulateBoneScale2Safe(@WING_RIGHT_1, right)
			\ManipulateBoneScale2Safe(@WING_RIGHT_2, right)
			\ManipulateBoneScale2Safe(@WING_OPEN_RIGHT, right)

			\ManipulateBonePosition2Safe(@WING_LEFT_1, leftPos)
			\ManipulateBonePosition2Safe(@WING_LEFT_2, leftPos)
			\ManipulateBonePosition2Safe(@WING_OPEN_LEFT, leftPos)
			\ManipulateBonePosition2Safe(@WING_RIGHT_1, rightPos)
			\ManipulateBonePosition2Safe(@WING_RIGHT_2, rightPos)
			\ManipulateBonePosition2Safe(@WING_OPEN_RIGHT, rightPos)

	UpdateEars: =>
		vec = LVector(1, 1, 1) * @GrabData('EarsSize')
		@GetEntity()\ManipulateBoneScale2Safe(@EAR_L, vec)
		@GetEntity()\ManipulateBoneScale2Safe(@EAR_R, vec)

	ResetEars: =>
		ang, vec1, vec2 = Angle(0, 0, 0), LVector(1, 1, 1), LVector(0, 0, 0)
		for _, part in ipairs {@EAR_L, @EAR_R}
			with @GetEntity()
				\ManipulateBoneAngles2Safe(part, ang)
				\ManipulateBoneScale2Safe(part, vec1)
				\ManipulateBonePosition2Safe(part, vec2)

	ResetBodygroups: =>
		return unless @isValid
		return unless IsValid(@GetEntity())
		@GetEntity()\SetFlexWeight(@@FLEX_ID_EYELASHES, 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_BODY, 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS, 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, 0)
		@ResetWings()
		@ResetEars()
		super()

	SlowUpdate: (createModels = CLIENT, force = false) =>
		return if not IsValid(@GetEntity())
		return if not @GetEntity()\IsPony()
		@GetEntity()\SetFlexWeight(@@FLEX_ID_EYELASHES,     @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
		maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0

		if @GetData()\GetNewMuzzle()
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, 0)
		else
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)

		@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_BODY,     maleModifier * @GetData()\GetMaleBuff())

		@GetEntity()\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GrabData('BatPonyEars') and @GrabData('BatPonyEarsStrength') or 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_CLAW_TEETH,    @GrabData('ClawTeeth') and @GrabData('ClawTeethStrength') or 0)
		@GetEntity()\SetFlexWeight(@@FLEX_ID_HOOF_FLUFF,    @GrabData('HoofFluffers') and @GrabData('HoofFluffersStrength') or 0)

		if @GrabData('Fangs')
			if @GrabData('AlternativeFangs')
				@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS, 0)
				@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS2, @GrabData('FangsStrength'))
			else
				@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS, @GrabData('FangsStrength'))
				@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS2, 0)
		else
			@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS, 0)
			@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS2, 0)

		@ApplyRace()
		if createModels
			@UpdateUpperMane(force)
			@UpdateLowerMane(force)
			@UpdateTailModel(force)
			@CreateSocksModelIfNotExists(force) if createModels and @GetData()\GetSocksAsModel()
			@CreateNewSocksModelIfNotExists(force) if createModels and @GetData()\GetSocksAsNewModel()

	RemoveModels: =>
		@maneModelUP\Remove() if IsValid(@maneModelUP)
		@maneModelLower\Remove() if IsValid(@maneModelLower)
		@tailModel\Remove() if IsValid(@tailModel)
		super()
	ApplyBodygroups: (createModels = CLIENT, force = false) =>
		return unless @isValid
		return if not IsValid(@GetEntity())
		@ResetBodygroups()
		return @RemoveModels() if not @GetEntity()\IsPony()
		@SlowUpdate(createModels, force)

	@NOCLIP_ANIMATIONS = {9, 10, 11}

	SelectWingsType: =>
		wtype = @GetData()\GetWingsType()
		if (@GetData()\GetFly() or @GetEntity().GetMoveType and @GetEntity()\GetMoveType() == MOVETYPE_NOCLIP) and (not @GetEntity().InVehicle or not @GetEntity()\InVehicle())
			wtype += PPM2.MAX_WINGS + 1
		return wtype

	ApplyRace: =>
		return unless @isValid
		return if not IsValid(@GetEntity())
		switch @GetData()\GetRace()
			when PPM2.RACE_EARTH
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 1)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
			when PPM2.RACE_PEGASUS
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 1)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, @SelectWingsType())
			when PPM2.RACE_UNICORN
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 0)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
			when PPM2.RACE_ALICORN
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 0)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, @SelectWingsType())

	DataChanges: (state) =>
		return unless @isValid
		return if not IsValid(@GetEntity())
		@Remap()
		switch state\GetKey()
			when 'EyelashType'
				@GetEntity()\SetFlexWeight(@@FLEX_ID_EYELASHES, @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
			when 'Gender'
				maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
				if @GetData()\GetNewMuzzle()
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, 0)
				else
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)
				@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
			when 'Fly'
				@ApplyRace()
			when 'NewMuzzle'
				maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
				if @GetData()\GetNewMuzzle()
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, 0)
				else
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
					@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)
				@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
			when 'BatPonyEars', 'BatPonyEarsStrength'
				@GetEntity()\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GrabData('BatPonyEars') and @GrabData('BatPonyEarsStrength') or 0)
			when 'Fangs', 'AlternativeFangs', 'FangsStrength'
				if @GrabData('Fangs')
					if @GrabData('AlternativeFangs')
						@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS, 0)
						@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS2, @GrabData('FangsStrength'))
					else
						@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS, @GrabData('FangsStrength'))
						@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS2, 0)
				else
					@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS, 0)
					@GetEntity()\SetFlexWeight(@@FLEX_ID_FANGS2, 0)
			when 'EarFluffers', 'EarFluffersStrength'
				@UpdateEars()
			when 'HoofFluffers', 'HoofFluffersStrength'
				@GetEntity()\SetFlexWeight(@@FLEX_ID_HOOF_FLUFF, @GrabData('HoofFluffers') and @GrabData('HoofFluffersStrength') or 0)
			when 'ClawTeeth', 'ClawTeethStrength'
				@GetEntity()\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, @GrabData('ClawTeeth') and @GrabData('ClawTeethStrength') or 0)
			when 'ManeTypeNew'
				@UpdateUpperMane() if CLIENT
			when 'ManeTypeLowerNew'
				@UpdateLowerMane() if CLIENT
			when 'TailSize', 'TailTypeNew'
				@UpdateTailModel()
				@UpdateTailSize()
			when 'PonySize'
				@UpdateTailSize()
			when 'Race'
				@ApplyRace()
			when 'WingsType'
				@ApplyRace()
			when 'LWingSize', 'RWingSize', 'LWingX', 'RWingX', 'LWingY', 'RWingY', 'LWingZ', 'RWingZ'
				@UpdateWings()
			when 'MaleBuff'
				maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
				@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
			when 'SocksAsModel'
				return if SERVER
				if state\GetValue()
					@CreateSocksModelIfNotExists()
				else
					@socksModel\Remove() if IsValid(@socksModel)
			when 'SocksAsNewModel'
				if state\GetValue()
					@CreateNewSocksModelIfNotExists()
				else
					@newSocksModel\Remove() if IsValid(@newSocksModel)

if CLIENT
	hook.Add 'PPM2.SetupBones', 'PPM2.Bodygroups', (ent, data) ->
		if bodygroup = data\GetBodygroupController()
			bodygroup.ent = ent
			bodygroup\UpdateBack()
			bodygroup\UpdateTailSize()
			bodygroup\UpdateManeSize()
			bodygroup\UpdateWings() if bodygroup.UpdateWings
			bodygroup\UpdateEars() if bodygroup.UpdateEars
			bodygroup.lastPAC3BoneReset = RealTimeL() + 1

	ppm2_sv_allow_resize = ->
		for _, ply in ipairs player.GetAll()
			if data = ply\GetPonyData()
				if bodygroup = data\GetBodygroupController()
					bodygroup\ResetTail()
					bodygroup\ResetMane()
					bodygroup\ResetBack()

	cvars.AddChangeCallback 'ppm2_sv_allow_resize', ppm2_sv_allow_resize, 'PPM2.Bodygroups'
else
	hook.Add 'PlayerNoClip', 'PPM2.WingsCheck', =>
		timer.Simple 0, ->
			return if not IsValid(@)
			if data = @GetPonyData()
				if bg = data\GetBodygroupController()
					bg\SlowUpdate()

PPM2.CPPMBodygroupController = CPPMBodygroupController
PPM2.DefaultBodygroupController = DefaultBodygroupController

PPM2.GetBodygroupController = (model = 'models/ppm/player_default_base.mdl') -> DefaultBodygroupController.AVALIABLE_CONTROLLERS[model\lower()] or DefaultBodygroupController
