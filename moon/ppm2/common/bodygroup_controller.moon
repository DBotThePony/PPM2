
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

diff = (num) ->
	num = num\abs()
	num < 0.99 or num > 1.01

vector_one = Vector(1, 1, 1)
empty = {}

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

	@_BONE_REMAP_R = {
		'BONE_SPINE_ROOT'
		'BONE_TAIL_1', 'BONE_TAIL_2', 'BONE_TAIL_3'
		'BONE_SPINE', 'BONE_MANE_1', 'BONE_MANE_2'
		'BONE_MANE_3', 'BONE_MANE_4', 'BONE_MANE_5'
		'BONE_MANE_6', 'BONE_MANE_7', 'BONE_MANE_8'
	}

	Remap: =>
		@validSkeleton = true

		for _, name in ipairs @@_BONE_REMAP_R
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

	CreateGenericModel: (force, fModelIndex, mIndex, mName, mTranslateModelName, mCallType) =>
		return @[mIndex] or NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		return @[mIndex] if IsValid(@[mIndex])

		for _, ent in ipairs ents_GetAll()
			if ent.isPonyPropModel and ent[fModelIndex] and ent.manePlayer == @GetEntity()
				@[mIndex] = ent
				@SetData(mName, @[mIndex])
				PPM2.DebugPrint('Resuing ', @[mIndex], ' as ', mName, ' for ', @GetEntity())
				return ent

		model, modelID, bodygroupID = mTranslateModelName(@GrabData(mCallType)) if mCallType
		model = mTranslateModelName() if not mCallType
		with @[mIndex] = ClientsideModel(model)
			.isPonyPropModel = true
			.manePlayer = @GetEntity()
			\DrawShadow(true)
			\SetPos(@GetEntity()\EyePos())
			\SetBodygroup(1, bodygroupID) if bodygroupID
			\Spawn()
			\Activate()
			\SetNoDraw(true)
			\SetParent(@GetEntity())
			\AddEffects(EF_BONEMERGE)

		@[mIndex][fModelIndex] = true

		PPM2.DebugPrint('Creating new ', mName, ' for ', @GetEntity(), ' as ', @[mIndex])
		@SetData(mName, @[mIndex])
		return @[mIndex]

	UpdateGenericModel: (force, fcallNone, mIndex, mName, mTranslateModelName, mCallType) =>
		return @[mIndex] or NULL if SERVER or not @isValid or not IsValid(@GetEntity()) or not force and @GetEntity()\IsDormant() or not @GetEntity()\IsPony()
		@[mIndex] = @[fcallNone](@, force) if not IsValid(@[mIndex])
		return NULL if not IsValid(@[mIndex])

		model, modelID, bodygroupID = mTranslateModelName(@GrabData(mCallType)) if mCallType
		model, modelID, bodygroupID = mTranslateModelName() if not mCallType
		with @[mIndex]
			\SetModel(model) if model ~= \GetModel()
			\SetBodygroup(1, bodygroupID) if bodygroupID and \GetBodygroup(1) ~= bodygroupID
			\SetParent(@GetEntity()) if \GetParent() ~= @GetEntity() and IsValid(@GetEntity())

		@SetData(mName, @[mIndex])
		return @[mIndex]

	UpdateHornModel: (force = false) => @UpdateGenericModel(force, 'CreateHornModel', 'hornModel', 'HornModel', PPM2.GetHornModelName, 'NewHornType')
	UpdateSocksModel: (force = false) => @UpdateGenericModel(force, 'CreateSocksModel', 'socksModel', 'SocksModel', @_SocksModelName)
	UpdateNewSocksModel: (force = false) => @UpdateGenericModel(force, 'CreateNewSocksModel', 'newSocksModel', 'NewSocksModel', @_NewSocksModelName)

	_SocksModelName: => 'models/props_pony/ppm/cosmetics/ppm_socks.mdl'
	_NewSocksModelName: => 'models/props_pony/ppm/cosmetics/ppm2_socks.mdl'
	_ClothesModelname: => 'models/ppm/player_default_clothes1.mdl'

	CreateSocksModel: (force = false) => @CreateGenericModel(force, 'isSocks', 'socksModel', 'SocksModel', @_SocksModelName)
	CreateNewSocksModel: (force = false) => @CreateGenericModel(force, 'isNewSocks', 'newSocksModel', 'NewSocksModel', @_NewSocksModelName)
	CreateHornModel: (force = false) => @CreateGenericModel(force, 'isHornModel', 'hornModel', 'HornModel', PPM2.GetHornModelName, 'NewHornType')
	CreateClothesModel: (force = false) => @CreateGenericModel(force, 'isClothesModel', 'clothesModel', 'ClothesModel', @_ClothesModelname)

	CreateClothesModelIfNotExist: (force = false) =>
		return @clothesModel if IsValid(@clothesModel)
		return @CreateClothesModel(force)

	CreateNewSocksModelIfNotExists: (force = false) =>
		return @newSocksModel if IsValid(@newSocksModel)
		return @CreateNewSocksModel(force)

	CreateSocksModelIfNotExists: (force = false) =>
		return @socksModel if IsValid(@socksModel)
		return @CreateSocksModel(force)

	CreateHornModelIfNotExists: (force = false) =>
		return @hornModel if IsValid(@hornModel)
		return @CreateHornModel(force)

	UpdateClothesModel: (force = false) =>
		@CreateClothesModelIfNotExist(force)
		return NULL if not IsValid(@clothesModel)
		@clothesModel\SetParent(@GetEntity()) if IsValid(@GetEntity())

		with @clothesModel
			\SetBodygroup(1, @GrabData('HeadClothes'))
			\SetBodygroup(2, @GrabData('NeckClothes'))
			\SetBodygroup(3, @GrabData('BodyClothes'))
			\SetBodygroup(8, @GrabData('EyeClothes'))

	MergeModels: (targetEnt = NULL) =>
		return if SERVER or not @isValid or not IsValid(targetEnt)

		socks = @CreateSocksModelIfNotExists(true) if @GrabData('SocksAsModel')
		socks2 = @CreateNewSocksModelIfNotExists(true) if @GrabData('SocksAsNewModel')
		horn = @CreateHornModelIfNotExists(true) if @GrabData('UseNewHorn')
		clothesModel = @CreateClothesModelIfNotExist(true)

		if IsValid(clothesModel)
			clothesModel\SetParent(targetEnt)

		if IsValid(horn)
			horn\SetParent(targetEnt)

		if IsValid(socks)
			socks\SetParent(targetEnt)

		if IsValid(socks2)
			socks2\SetParent(targetEnt)

	GetSocks: => @socksModel or NULL

	ApplyRace: =>
		return unless @isValid
		return NULL if not IsValid(@GetEntity())
		with @GetEntity()
			switch @GrabData('Race')
				when PPM2.RACE_EARTH
					\SetBodygroup(@@BODYGROUP_HORN, 1)
					\SetBodygroup(@@BODYGROUP_WINGS, 1)
				when PPM2.RACE_PEGASUS
					\SetBodygroup(@@BODYGROUP_HORN, 1)
					\SetBodygroup(@@BODYGROUP_WINGS, 0)
				when PPM2.RACE_UNICORN
					\SetBodygroup(@@BODYGROUP_HORN, @GrabData('UseNewHorn') and 1 or 0)
					\SetBodygroup(@@BODYGROUP_WINGS, 1)
				when PPM2.RACE_ALICORN
					\SetBodygroup(@@BODYGROUP_HORN, @GrabData('UseNewHorn') and 1 or 0)
					\SetBodygroup(@@BODYGROUP_WINGS, 0)

	ResetTail: =>
		return if not CLIENT
		return if not @validSkeleton
		with @GetEntity()
			\ManipulateBoneScale(@BONE_TAIL_1, vector_one)
			\ManipulateBoneScale(@BONE_TAIL_2, vector_one)
			\ManipulateBoneScale(@BONE_TAIL_3, vector_one)
			\ManipulateBoneAngles(@BONE_TAIL_1, Angle(0, 0, 0))
			\ManipulateBoneAngles(@BONE_TAIL_2, Angle(0, 0, 0))
			\ManipulateBoneAngles(@BONE_TAIL_3, Angle(0, 0, 0))
			\ManipulateBonePosition(@BONE_TAIL_1, vector_origin)
			\ManipulateBonePosition(@BONE_TAIL_2, vector_origin)
			\ManipulateBonePosition(@BONE_TAIL_3, vector_origin)

	ResetBack: =>
		return if not CLIENT
		return if not @validSkeleton
		with @GetEntity()
			\ManipulateBoneScale(@BONE_SPINE_ROOT, vector_one)
			\ManipulateBoneScale(@BONE_SPINE, vector_one)
			\ManipulateBoneAngles(@BONE_SPINE_ROOT, Angle(0, 0, 0))
			\ManipulateBoneAngles(@BONE_SPINE, Angle(0, 0, 0))
			\ManipulateBonePosition(@BONE_SPINE_ROOT, vector_origin)
			\ManipulateBonePosition(@BONE_SPINE, vector_origin)

	ResetMane: =>
		return if not CLIENT
		return if not @validSkeleton

		vec1, ang, vec2 = vector_one, Angle(0, 0, 0), vector_origin

		with @GetEntity()
			for i = 1, 7
				\ManipulateBoneScale(@['BONE_MANE_' .. i], vec1)
				\ManipulateBoneAngles(@['BONE_MANE_' .. i], ang)
				\ManipulateBonePosition(@['BONE_MANE_' .. i], vec2)

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
		@hornModel\Remove() if IsValid(@hornModel)
		@clothesModel\Remove() if IsValid(@clothesModel)

	UpdateTailSize: (ent = @GetEntity()) =>
		return if not CLIENT
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		return if not @validSkeleton
		size = @GrabData('TailSize')
		size *= @GrabData('PonySize') if not ent\IsRagdoll() and not ent\IsNJPony()
		return if not diff(size)
		vecTail = vector_one * size
		vecTailPos = Vector((size - 1) * 8, 0, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or empty

		with ent
			\ManipulateBoneScale(@BONE_TAIL_1, vecTail)
			\ManipulateBoneScale(@BONE_TAIL_2, vecTail)
			\ManipulateBoneScale(@BONE_TAIL_3, vecTail)

			--\ManipulateBonePosition(@BONE_TAIL_1, vecTail + (boneAnimTable[@BONE_TAIL_1] or vector_origin))
			\ManipulateBonePosition(@BONE_TAIL_2, vecTailPos + (boneAnimTable[@BONE_TAIL_2] or vector_origin))
			\ManipulateBonePosition(@BONE_TAIL_3, vecTailPos + (boneAnimTable[@BONE_TAIL_3] or vector_origin))

	UpdateManeSize: (ent = @GetEntity()) =>
		return if not CLIENT
		return if ent\IsRagdoll()
		return if ent\IsNJPony()
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		return if not @validSkeleton
		size = @GrabData('PonySize')
		return if not diff(size)
		vecMane = vector_one * size

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or empty

		with ent
			\ManipulateBoneScale(@BONE_MANE_1, vecMane)
			\ManipulateBoneScale(@BONE_MANE_2, vecMane)
			\ManipulateBoneScale(@BONE_MANE_3, vecMane)
			\ManipulateBoneScale(@BONE_MANE_4, vecMane)
			\ManipulateBoneScale(@BONE_MANE_5, vecMane)
			\ManipulateBoneScale(@BONE_MANE_6, vecMane)
			\ManipulateBoneScale(@BONE_MANE_7, vecMane)
			\ManipulateBoneScale(@BONE_MANE_8, vecMane)

			\ManipulateBonePosition(@BONE_MANE_1, Vector(-(size - 1) * 4, (1 - size) * 3, 0) + (boneAnimTable[@BONE_MANE_1] or vector_origin))
			\ManipulateBonePosition(@BONE_MANE_2, Vector(-(size - 1) * 4, (size - 1) * 2, 1) + (boneAnimTable[@BONE_MANE_2] or vector_origin))
			\ManipulateBonePosition(@BONE_MANE_3, Vector((size - 1) * 2, 0, 0) +               (boneAnimTable[@BONE_MANE_3] or vector_origin))
			\ManipulateBonePosition(@BONE_MANE_4, Vector(1 - size, (1 - size) * 4, 1 - size) + (boneAnimTable[@BONE_MANE_4] or vector_origin))
			\ManipulateBonePosition(@BONE_MANE_5, Vector((size - 1) * 4, (1 - size) * 2, (size - 1) * 3) + (boneAnimTable[@BONE_MANE_5] or vector_origin))
			\ManipulateBonePosition(@BONE_MANE_6, Vector(0, 0, -(size - 1) * 2) +              (boneAnimTable[@BONE_MANE_6] or vector_origin))
			\ManipulateBonePosition(@BONE_MANE_7, Vector(0, 0, -(size - 1) * 2) +              (boneAnimTable[@BONE_MANE_7] or vector_origin))

	UpdateBack: (ent = @GetEntity()) =>
		return if not CLIENT
		return if ent\IsRagdoll()
		return if ent\IsNJPony()
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		return if not @validSkeleton
		return if not diff(@GrabData('BackSize'))

		vecModify = Vector(-(@GrabData('BackSize') - 1) * 2, 0, 0)
		vecModify2 = Vector((@GrabData('BackSize') - 1) * 5, 0, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or empty

		with ent
			\ManipulateBonePosition(@BONE_SPINE_ROOT, vecModify + (boneAnimTable[@BONE_SPINE_ROOT] or vector_origin))
			\ManipulateBonePosition(@BONE_SPINE, vecModify2 + (boneAnimTable[@BONE_SPINE] or vector_origin))

	SlowUpdate: (createModels = CLIENT, ent = @GetEntity(), force = false) =>
		return if not IsValid(ent)
		return if not ent\IsPony()
		with ent
			\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GrabData('ManeType'))
			\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GrabData('ManeTypeLower'))
			\SetBodygroup(@@BODYGROUP_TAIL, @GrabData('TailType'))
			\SetBodygroup(@@BODYGROUP_EYELASH, @GrabData('EyelashType'))
			\SetBodygroup(@@BODYGROUP_GENDER, @GrabData('Gender'))

		@ApplyRace()
		if createModels
			@UpdateClothesModel()
			@UpdateHornModel(force) if @GrabData('UseNewHorn')
			@UpdateSocksModel(force) if @GrabData('SocksAsModel')
			@UpdateNewSocksModel(force) if @GrabData('SocksAsNewModel')

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
			when 'HeadClothes', 'NeckClothes', 'BodyClothes', 'EyeClothes'
				@UpdateClothesModel()
			when 'ManeType'
				@GetEntity()\SetBodygroup(@@BODYGROUP_MANE_UPPER, state\GetValue())
			when 'ManeTypeLower'
				@GetEntity()\SetBodygroup(@@BODYGROUP_MANE_LOWER, state\GetValue())
			when 'TailType'
				@GetEntity()\SetBodygroup(@@BODYGROUP_TAIL, state\GetValue())
			when 'TailSize', 'PonySize'
				@UpdateTailSize()
			when 'EyelashType'
				@GetEntity()\SetBodygroup(@@BODYGROUP_EYELASH, state\GetValue())
			when 'Gender'
				@GetEntity()\SetBodygroup(@@BODYGROUP_GENDER, state\GetValue())
			when 'SocksAsModel'
				if state\GetValue()
					@UpdateSocksModel()
				else
					@socksModel\Remove() if IsValid(@socksModel)
			when 'UseNewHorn'
				if state\GetValue()
					@CreateHornModelIfNotExists()
				else
					@hornModel\Remove() if IsValid(@hornModel)

				@ApplyRace()
			when 'SocksAsNewModel'
				if state\GetValue()
					@UpdateNewSocksModel()
				else
					@newSocksModel\Remove() if IsValid(@newSocksModel)
			when 'Race'
				@ApplyRace()

class CPPMBodygroupController extends DefaultBodygroupController
	@MODELS = {'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	new: (...) => super(...)

	ApplyRace: =>
		return unless @isValid
		switch @GrabData('Race')
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

	@_BONE_REMAP = {
		'EAR_L', 'EAR_R'
		'WING_LEFT_1', 'WING_LEFT_2', 'WING_RIGHT_1'
		'WING_RIGHT_2', 'WING_OPEN_LEFT', 'WING_OPEN_RIGHT'
	}

	Remap: =>
		super!

		for _, name in ipairs @@_BONE_REMAP
			@[name] = @GetEntity()\LookupBone(@@[name])

			if not @[name]
				@validSkeleton = false

	CreateUpperManeModel: (force = false) => @CreateGenericModel(force, 'isUpperMane', 'maneModelUpper', 'UpperManeModel', PPM2.GetUpperManeModelName, 'ManeTypeNew')
	CreateLowerManeModel: (force = false) => @CreateGenericModel(force, 'isLowerMane', 'maneModelLower', 'LowerManeModel', PPM2.GetLowerManeModelName, 'ManeTypeLowerNew')
	CreateTailModel: (force = false) => @CreateGenericModel(force, 'isTailModel', 'tailModel', 'TailModel', PPM2.GetTailModelName, 'TailTypeNew')

	CreateUpperManeModelIfNotExists: (force = false) =>
		return @maneModelUpper if IsValid(@maneModelUpper)
		return @CreateUpperManeModel()

	CreateLowerManeModelIfNotExists: (force = false) =>
		return @maneModelLower if IsValid(@maneModelLower)
		return @CreateLowerManeModel()

	CreateTailModelIfNotExists: (force = false) =>
		return @tailModel if IsValid(@tailModel)
		return @CreateTailModel()

	UpdateUpperMane: (force = false) => @UpdateGenericModel(force, 'CreateUpperManeModel', 'maneModelUpper', 'UpperManeModel', PPM2.GetUpperManeModelName, 'ManeTypeNew')
	UpdateLowerMane: (force = false) => @UpdateGenericModel(force, 'CreateLowerManeModel', 'maneModelLower', 'LowerManeModel', PPM2.GetLowerManeModelName, 'ManeTypeLowerNew')
	UpdateTailModel: (force = false) => @UpdateGenericModel(force, 'CreateTailModel', 'tailModel', 'TailModel', PPM2.GetTailModelName, 'TailTypeNew')

	GetUpperMane: => @maneModelUpper or NULL
	GetLowerMane: => @maneModelLower or NULL
	GetTail: => @tailModel or NULL

	MergeModels: (targetEnt = NULL) =>
		return unless @isValid
		super(targetEnt)
		return unless IsValid(targetEnt)
		for _, e in ipairs {@CreateUpperManeModelIfNotExists(true), @CreateLowerManeModelIfNotExists(true), @CreateTailModelIfNotExists(true)}
			e\SetParent(targetEnt) if IsValid(e)

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
		ang, vec1, vec2 = Angle(0, 0, 0), vector_one, vector_origin
		for _, wing in ipairs {@WING_LEFT_1, @WING_LEFT_2, @WING_RIGHT_1, @WING_RIGHT_2, @WING_OPEN_LEFT, @WING_OPEN_RIGHT}
			with @GetEntity()
				\ManipulateBoneAngles(wing, ang)
				\ManipulateBoneScale(wing, vec1)
				\ManipulateBonePosition(wing, vec2)

	UpdateWings: =>
		return if SERVER
		return if not @validSkeleton
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		left = @GrabData('LWingSize')

		if diff(left)
			left = left * vector_one
		else
			left = nil

		leftX = @GrabData('LWingX')
		leftY = @GrabData('LWingY')
		leftZ = @GrabData('LWingZ')
		right = @GrabData('RWingSize')

		if diff(right)
			right = right * vector_one
		else
			right = nil

		rightX = @GrabData('RWingX')
		rightY = @GrabData('RWingY')
		rightZ = @GrabData('RWingZ')

		leftPos = Vector(leftX, leftY, leftZ) if diff(leftX) or diff(leftY) or diff(leftZ)
		rightPos = Vector(rightX, rightY, rightZ) if diff(rightX) or diff(rightY) or diff(rightZ)

		with @GetEntity()
			if left
				\ManipulateBoneScale(@WING_LEFT_1, left)
				\ManipulateBoneScale(@WING_LEFT_2, left)
				\ManipulateBoneScale(@WING_OPEN_LEFT, left)

			if right
				\ManipulateBoneScale(@WING_RIGHT_1, right)
				\ManipulateBoneScale(@WING_RIGHT_2, right)
				\ManipulateBoneScale(@WING_OPEN_RIGHT, right)

			if leftPos
				\ManipulateBonePosition(@WING_LEFT_1, leftPos)
				\ManipulateBonePosition(@WING_LEFT_2, leftPos)
				\ManipulateBonePosition(@WING_OPEN_LEFT, leftPos)

			if rightPos
				\ManipulateBonePosition(@WING_RIGHT_1, rightPos)
				\ManipulateBonePosition(@WING_RIGHT_2, rightPos)
				\ManipulateBonePosition(@WING_OPEN_RIGHT, rightPos)

	UpdateEars: =>
		size = @GrabData('EarsSize')
		if diff(size)
			vec = vector_one * size
			@GetEntity()\ManipulateBoneScale(@EAR_L, vec)
			@GetEntity()\ManipulateBoneScale(@EAR_R, vec)

	ResetEars: =>
		ang, vec1, vec2 = Angle(0, 0, 0), vector_one, vector_origin
		for _, part in ipairs {@EAR_L, @EAR_R}
			with @GetEntity()
				\ManipulateBoneAngles(part, ang)
				\ManipulateBoneScale(part, vec1)
				\ManipulateBonePosition(part, vec2)

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

	_UpdateMaleBuff: =>
		maleModifier = @GrabData('Gender') == PPM2.GENDER_MALE and 1 or 0

		if @GrabData('NewMuzzle')
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, 0)
		else
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
			@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)

		@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_BODY,     maleModifier * @GrabData('MaleBuff'))

	SlowUpdate: (createModels = CLIENT, force = false) =>
		return if not IsValid(@GetEntity())
		return if not @GetEntity()\IsPony()
		@GetEntity()\SetFlexWeight(@@FLEX_ID_EYELASHES,     @GrabData('EyelashType') == PPM2.EYELASHES_NONE and 1 or 0)
		@_UpdateMaleBuff()

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
			@UpdateClothesModel()
			@UpdateUpperMane(force)
			@UpdateLowerMane(force)
			@UpdateTailModel(force)
			@UpdateHornModel(force) if @GrabData('UseNewHorn')
			@UpdateSocksModel(force) if @GrabData('SocksAsModel')
			@UpdateNewSocksModel(force) if @GrabData('SocksAsNewModel')

	RemoveModels: =>
		@maneModelUpper\Remove() if IsValid(@maneModelUpper)
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
		wtype = @GrabData('WingsType')
		if (@GrabData('Fly') or @GetEntity().GetMoveType and @GetEntity()\GetMoveType() == MOVETYPE_NOCLIP) and (not @GetEntity().InVehicle or not @GetEntity()\InVehicle())
			wtype += PPM2.MAX_WINGS + 1
		return wtype

	ApplyRace: =>
		return unless @isValid
		return if not IsValid(@GetEntity())
		switch @GrabData('Race')
			when PPM2.RACE_EARTH
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 1)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
			when PPM2.RACE_PEGASUS
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, 1)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, @SelectWingsType())
			when PPM2.RACE_UNICORN
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, @GrabData('UseNewHorn') and 1 or 0)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
			when PPM2.RACE_ALICORN
				@GetEntity()\SetBodygroup(@@BODYGROUP_HORN, @GrabData('UseNewHorn') and 1 or 0)
				@GetEntity()\SetBodygroup(@@BODYGROUP_WINGS, @SelectWingsType())

	DataChanges: (state) =>
		return unless @isValid
		return if not IsValid(@GetEntity())
		@Remap()
		switch state\GetKey()
			when 'HeadClothes', 'NeckClothes', 'BodyClothes', 'EyeClothes'
				@UpdateClothesModel()
			when 'EyelashType'
				@GetEntity()\SetFlexWeight(@@FLEX_ID_EYELASHES, state\GetValue() == PPM2.EYELASHES_NONE and 1 or 0)
			when 'Gender', 'NewMuzzle'
				@_UpdateMaleBuff()
			when 'Fly'
				@ApplyRace()
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
			when 'UseNewHorn'
				if state\GetValue()
					@CreateHornModelIfNotExists()
				else
					@hornModel\Remove() if IsValid(@hornModel)

				@ApplyRace()
			when 'Race'
				@ApplyRace()
			when 'WingsType'
				@ApplyRace()
			when 'LWingSize', 'RWingSize', 'LWingX', 'RWingX', 'LWingY', 'RWingY', 'LWingZ', 'RWingZ'
				@UpdateWings()
			when 'MaleBuff'
				maleModifier = @GrabData('Gender') == PPM2.GENDER_MALE and 1 or 0
				@GetEntity()\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GrabData('MaleBuff'))
			when 'SocksAsModel'
				return if SERVER
				if state\GetValue()
					@UpdateSocksModel()
				else
					@socksModel\Remove() if IsValid(@socksModel)
			when 'SocksAsNewModel'
				if state\GetValue()
					@UpdateNewSocksModel()
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
