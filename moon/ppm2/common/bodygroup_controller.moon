
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
	for ent in *ents.GetAll()
		if ent.isPonyLegsModel
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

	for i = 1, 8
		@['BONE_MANE_' .. i] = 29 + i

	@BONE_TAIL_1 = 38
	@BONE_TAIL_2 = 39
	@BONE_TAIL_3 = 40

	@BONE_SPINE_ROOT = 0
	@BONE_SPINE = 2

	new: (controller) =>
		@isValid = true
		@ent = controller.ent
		@entID = controller.entID
		@controller = controller
		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0
		PPM2.DebugPrint('Created new bodygroups controller for ', @ent, ' as part of ', controller, '; internal ID is ', @objID)

	__tostring: => "[#{@@__name}:#{@objID}|#{@ent}]"
	IsValid: => @isValid
	GetData: => @controller
	GrabData: (str, ...) => @controller['Get' .. str](@controller, ...)
	GetEntity: => @ent
	GetEntityID: => @entID
	GetDataID: => @entID

	@ATTACHMENT_EYES = 4
	@ATTACHMENT_EYES_NAME = 'eyes'

	CreateSocksModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		return @socksModel if IsValid(@socksModel)
		for ent in *ents_GetAll()
			if ent.isPonyPropModel and ent.isSocks and ent.manePlayer == @ent
				@socksModel = ent
				@GetData()\SetSocksModel(@socksModel)
				PPM2.DebugPrint('Resuing ', @socksModel, ' as socks model for ', @ent)
				return ent

		with @socksModel = ClientsideModel('models/props_pony/ppm/cosmetics/ppm_socks.mdl')
			.isPonyPropModel = true
			.isSocks = true
			.manePlayer = @ent
			\DrawShadow(true)
			\SetPos(@ent\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true)
			\SetParent(@ent\GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new socks model for ', @ent, ' as ', @socksModel)
		@GetData()\SetSocksModel(@socksModel)
		return @socksModel

	CreateNewSocksModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		return @newSocksModel if IsValid(@newSocksModel)
		for ent in *ents_GetAll()
			if ent.isPonyPropModel and ent.isNewSocks and ent.manePlayer == @ent
				@newSocksModel = ent
				@GetData()\SetNewSocksModel(@newSocksModel)
				PPM2.DebugPrint('Resuing ', @newSocksModel, ' as socks model for ', @ent)
				return ent

		with @newSocksModel = ClientsideModel('models/props_pony/ppm/cosmetics/ppm2_socks.mdl')
			.isPonyPropModel = true
			.isNewSocks = true
			.manePlayer = @ent
			\DrawShadow(true)
			\SetPos(@ent\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true)
			\SetParent(@ent\GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new socks model for ', @ent, ' as ', @newSocksModel)
		@GetData()\SetNewSocksModel(@newSocksModel)
		return @newSocksModel

	CreateNewSocksModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		@CreateNewSocksModel(force) if not IsValid(@newSocksModel)
		return NULL if not IsValid(@newSocksModel)
		@newSocksModel\SetParent(@ent\GetEntity()) if IsValid(@ent)
		@GetData()\SetNewSocksModel(@newSocksModel)
		return @newSocksModel

	CreateSocksModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		@CreateSocksModel(force) if not IsValid(@socksModel)
		return NULL if not IsValid(@socksModel)
		@socksModel\SetParent(@ent\GetEntity()) if IsValid(@ent)
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
		return NULL if not IsValid(@ent)
		with @ent
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
		with @ent
			\ManipulateBoneScale2Safe(@@BONE_TAIL_1, Vector(1, 1, 1))
			\ManipulateBoneScale2Safe(@@BONE_TAIL_2, Vector(1, 1, 1))
			\ManipulateBoneScale2Safe(@@BONE_TAIL_3, Vector(1, 1, 1))
			\ManipulateBoneAngles2Safe(@@BONE_TAIL_1, Angle(0, 0, 0))
			\ManipulateBoneAngles2Safe(@@BONE_TAIL_2, Angle(0, 0, 0))
			\ManipulateBoneAngles2Safe(@@BONE_TAIL_3, Angle(0, 0, 0))
			\ManipulateBonePosition2Safe(@@BONE_TAIL_1, Vector(0, 0, 0))
			\ManipulateBonePosition2Safe(@@BONE_TAIL_2, Vector(0, 0, 0))
			\ManipulateBonePosition2Safe(@@BONE_TAIL_3, Vector(0, 0, 0))

	ResetBack: =>
		return if not CLIENT
		with @ent
			\ManipulateBoneScale2Safe(@@BONE_SPINE_ROOT, Vector(1, 1, 1))
			\ManipulateBoneScale2Safe(@@BONE_SPINE, Vector(1, 1, 1))
			\ManipulateBoneAngles2Safe(@@BONE_SPINE_ROOT, Angle(0, 0, 0))
			\ManipulateBoneAngles2Safe(@@BONE_SPINE, Angle(0, 0, 0))
			\ManipulateBonePosition2Safe(@@BONE_SPINE_ROOT, Vector(0, 0, 0))
			\ManipulateBonePosition2Safe(@@BONE_SPINE, Vector(0, 0, 0))

	ResetMane: =>
		return if not CLIENT
		vec1, ang, vec2 = Vector(1, 1, 1), Angle(0, 0, 0), Vector(0, 0, 0)
		with @ent
			for i = 1, 7
				\ManipulateBoneScale2Safe(@@['BONE_MANE_' .. i], vec1)
				\ManipulateBoneAngles2Safe(@@['BONE_MANE_' .. i], ang)
				\ManipulateBonePosition2Safe(@@['BONE_MANE_' .. i], vec2)

	ResetBodygroups: =>
		return unless @isValid
		return unless IsValid(@ent)
		return unless @ent\GetBodyGroups()
		for grp in *@ent\GetBodyGroups()
			@ent\SetBodygroup(grp.id, 0)
		if @lastPAC3BoneReset < RealTimeL()
			@ResetTail()
			@ResetMane()
			@ResetBack()

	Reset: => @ResetBodygroups()
	RemoveModels: =>
		@socksModel\Remove() if IsValid(@socksModel)
		@newSocksModel\Remove() if IsValid(@newSocksModel)

	UpdateTailSize: (ent = @ent) =>
		return if not CLIENT
		size = @GetData()\GetTailSize()
		size *= @GetData()\GetPonySize() if not ent\IsRagdoll() and not ent\IsNJPony()
		vec = Vector(1, 1, 1)
		vecTail = vec * size
		vecTailPos = Vector((size - 1) * 8, 0, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyVector = Vector(0, 0, 0)

		with ent
			\ManipulateBoneScale2Safe(@@BONE_TAIL_1, vecTail)
			\ManipulateBoneScale2Safe(@@BONE_TAIL_2, vecTail)
			\ManipulateBoneScale2Safe(@@BONE_TAIL_3, vecTail)

			--\ManipulateBonePosition2Safe(@@BONE_TAIL_1, vecTail + (boneAnimTable[@@BONE_TAIL_1] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_TAIL_2, vecTailPos + (boneAnimTable[@@BONE_TAIL_2] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_TAIL_3, vecTailPos + (boneAnimTable[@@BONE_TAIL_3] or emptyVector))

	UpdateManeSize: (ent = @ent) =>
		return if not CLIENT
		return if ent\IsRagdoll()
		return if ent\IsNJPony()
		size = @GetData()\GetPonySize()
		vecMane = Vector(1, 1, 1) * size

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyVector = Vector(0, 0, 0)

		with ent
			\ManipulateBoneScale2Safe(@@BONE_MANE_1, vecMane)
			\ManipulateBoneScale2Safe(@@BONE_MANE_2, vecMane)
			\ManipulateBoneScale2Safe(@@BONE_MANE_3, vecMane)
			\ManipulateBoneScale2Safe(@@BONE_MANE_4, vecMane)
			\ManipulateBoneScale2Safe(@@BONE_MANE_5, vecMane)
			\ManipulateBoneScale2Safe(@@BONE_MANE_6, vecMane)
			\ManipulateBoneScale2Safe(@@BONE_MANE_7, vecMane)
			\ManipulateBoneScale2Safe(@@BONE_MANE_8, vecMane)

			\ManipulateBonePosition2Safe(@@BONE_MANE_1, Vector(-(size - 1) * 4, (1 - size) * 3, 0) + (boneAnimTable[@@BONE_MANE_1] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_MANE_2, Vector(-(size - 1) * 4, (size - 1) * 2, 1) + (boneAnimTable[@@BONE_MANE_2] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_MANE_3, Vector((size - 1) * 2, 0, 0) +               (boneAnimTable[@@BONE_MANE_3] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_MANE_4, Vector(1 - size, (1 - size) * 4, 1 - size) + (boneAnimTable[@@BONE_MANE_4] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_MANE_5, Vector((size - 1) * 4, (1 - size) * 2, (size - 1) * 3) + (boneAnimTable[@@BONE_MANE_5] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_MANE_6, Vector(0, 0, -(size - 1) * 2) +              (boneAnimTable[@@BONE_MANE_6] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_MANE_7, Vector(0, 0, -(size - 1) * 2) +              (boneAnimTable[@@BONE_MANE_7] or emptyVector))

	UpdateBack: (ent = @ent) =>
		return if not CLIENT
		return if ent\IsRagdoll()
		return if ent\IsNJPony()
		vecModify = Vector(-(@GetData()\GetBackSize() - 1) * 2, 0, 0)
		vecModify2 = Vector((@GetData()\GetBackSize() - 1) * 5, 0, 0)

		boneAnimTable = ent.pac_boneanim and ent.pac_boneanim.positions or {}
		emptyVector = Vector(0, 0, 0)

		with ent
			\ManipulateBonePosition2Safe(@@BONE_SPINE_ROOT, vecModify + (boneAnimTable[@@BONE_SPINE_ROOT] or emptyVector))
			\ManipulateBonePosition2Safe(@@BONE_SPINE, vecModify2 + (boneAnimTable[@@BONE_SPINE] or emptyVector))

	SlowUpdate: (createModels = CLIENT, ent = @ent, force = false) =>
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
		return if not IsValid(@ent)
		@ResetBodygroups()
		return if not @ent\IsPony()
		@SlowUpdate(createModels, force)

	Remove: =>
		@RemoveModels()
		@ResetBodygroups()
		@isValid = false

	@TAIL_BONE1 = 38
	@TAIL_BONE2 = 39
	@TAIL_BONE3 = 40
	DataChanges: (state) =>
		return unless @isValid
		return if not IsValid(@ent)
		switch state\GetKey()
			when 'ManeType'
				@ent\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GetData()\GetManeType())
			when 'ManeTypeLower'
				@ent\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GetData()\GetManeTypeLower())
			when 'TailType'
				@ent\SetBodygroup(@@BODYGROUP_TAIL, @GetData()\GetTailType())
			when 'TailSize', 'PonySize'
				@UpdateTailSize()
			when 'EyelashType'
				@ent\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
			when 'Gender'
				@ent\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
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
				@ent\SetBodygroup(@@BODYGROUP_HORN, 1)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, 1)
			when PPM2.RACE_PEGASUS
				@ent\SetBodygroup(@@BODYGROUP_HORN, 1)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, 0)
			when PPM2.RACE_UNICORN
				@ent\SetBodygroup(@@BODYGROUP_HORN, 0)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, 1)
			when PPM2.RACE_ALICORN
				@ent\SetBodygroup(@@BODYGROUP_HORN, 2)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, 3)

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
-- 42	right_hand
-- 43	Tail01
-- 44	Tail02
-- 45	Tail03
-- 46	wing_l
-- 47	wing_r
-- 48	wing_l_bat
-- 49	wing_r_bat
-- 50	wing_open_l
-- 51	wing_open_r
--

class NewBodygroupController extends DefaultBodygroupController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	@BODYGROUP_SKELETON = 0
	@BODYGROUP_GENDER = -1
	@BODYGROUP_HORN = 1
	@BODYGROUP_WINGS = 2

	@EAR_L = 31
	@EAR_R = 32

	@BONE_TAIL_1 = 43
	@BONE_TAIL_2 = 44
	@BONE_TAIL_3 = 45

	@WING_LEFT_1 = 46
	@WING_LEFT_2 = 48
	@WING_RIGHT_1 = 47
	@WING_RIGHT_2 = 49

	@WING_OPEN_LEFT = 50
	@WING_OPEN_RIGHT = 51

	@BONE_SPINE = 11

	@BONE_MANE_1 = 40
	@BONE_MANE_2 = 33
	@BONE_MANE_3 = 34
	@BONE_MANE_4 = 36
	@BONE_MANE_5 = 37
	@BONE_MANE_6 = 38
	@BONE_MANE_7 = 39
	@BONE_MANE_8 = 35

	__tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"

	new: (...) =>
		super(...)

	CreateUpperManeModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		return @maneModelUP if IsValid(@maneModelUP)
		for ent in *ents_GetAll()
			if ent.isPonyPropModel and ent.upperMane and ent.manePlayer == @ent
				@maneModelUP = ent
				@GetData()\SetUpperManeModel(@maneModelUP)
				PPM2.DebugPrint('Resuing ', @maneModelUP, ' as upper mane model for ', @ent)
				return ent

		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
		modelID = "0" .. modelID if modelID < 10
		with @maneModelUP = ClientsideModel("models/ppm/hair/ppm_manesetupper#{modelID}.mdl")
			.isPonyPropModel = true
			.upperMane = true
			.manePlayer = @ent
			\DrawShadow(true) if CLIENT
			\SetPos(@ent\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true) if CLIENT
			\SetBodygroup(1, bodygroupID)
			\SetParent(@ent\GetEntity())
			\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new upper mane model for ', @ent, ' as ', @maneModelUP)

		if SERVER
			timer.Simple .5, ->
				return unless @isValid
				return unless IsValid(@maneModelUP)
				@GetData()\SetUpperManeModel(@maneModelUP)
		else
			@GetData()\SetUpperManeModel(@maneModelUP)

		return @maneModelUP

	CreateLowerManeModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		return @maneModelLower if IsValid(@maneModelLower)
		for ent in *ents_GetAll()
			if ent.isPonyPropModel and ent.lowerMane and ent.manePlayer == @ent
				@maneModelLower = ent
				@GetData()\SetLowerManeModel(@maneModelLower)
				PPM2.DebugPrint('Resuing ', @maneModelLower, ' as lower mane model for ', @ent)
				return ent

		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
		modelID = "0" .. modelID if modelID < 10
		with @maneModelLower = ClientsideModel("models/ppm/hair/ppm_manesetlower#{modelID}.mdl")
			.isPonyPropModel = true
			.lowerMane = true
			.manePlayer = @ent
			\DrawShadow(true)
			\SetPos(@ent\EyePos())
			\Spawn()
			\Activate()
			\SetBodygroup(1, bodygroupID)
			\SetNoDraw(true)
			\SetParent(@ent\GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new lower mane model for ', @ent, ' as ', @maneModelLower)
		@GetData()\SetLowerManeModel(@maneModelLower)
		return @maneModelLower

	CreateTailModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		return @tailModel if IsValid(@tailModel)
		for ent in *ents_GetAll()
			if ent.isPonyPropModel and ent.isTail and ent.manePlayer == @ent
				@tailModel = ent
				@GetData()\SetTailModel(@tailModel)
				PPM2.DebugPrint('Resuing ', @tailModel, ' as tail model for ', @ent)
				return ent

		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
		modelID = "0" .. modelID if modelID < 10

		with @tailModel = ClientsideModel("models/ppm/hair/ppm_tailset#{modelID}.mdl")
			.isPonyPropModel = true
			.isTail = true
			.manePlayer = @ent
			\DrawShadow(true)
			\SetPos(@ent\EyePos())
			\Spawn()
			\Activate()
			\SetNoDraw(true)
			\SetBodygroup(1, bodygroupID)
			\SetParent(@ent\GetEntity())
			\AddEffects(EF_BONEMERGE)

		PPM2.DebugPrint('Creating new tail model for ', @ent, ' as ', @tailModel)
		@GetData()\SetTailModel(@tailModel)
		return @tailModel

	CreateUpperManeModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not @ent\IsPony()
		@CreateUpperManeModel(force) if not IsValid(@maneModelUP)
		@GetData()\SetUpperManeModel(@maneModelUP) if IsValid(@maneModelUP)
		return @maneModelUP

	CreateLowerManeModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not @ent\IsPony()
		@CreateLowerManeModel(force) if not IsValid(@maneModelLower)
		@GetData()\SetLowerManeModel(@maneModelLower) if IsValid(@maneModelLower)
		return @maneModelLower

	CreateTailModelIfNotExists: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not @ent\IsPony()
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
		for e in *{@CreateUpperManeModelIfNotExists(true), @CreateLowerManeModelIfNotExists(true), @CreateTailModelIfNotExists(true)}
			e\SetParent(targetEnt) if IsValid(e)

	UpdateUpperMane: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		@CreateUpperManeModelIfNotExists(force)
		return NULL if not IsValid(@maneModelUP)
		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
		modelID = "0" .. modelID if modelID < 10
		model = "models/ppm/hair/ppm_manesetupper#{modelID}.mdl"
		with @maneModelUP
			\SetModel(model) if model ~= \GetModel()
			\SetBodygroup(1, bodygroupID) if \GetBodygroup(1) ~= bodygroupID
			\SetParent(@ent\GetEntity()) if \GetParent() ~= @ent and IsValid(@ent)
		@GetData()\SetUpperManeModel(@maneModelUP)
		return @maneModelUP

	UpdateLowerMane: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		@CreateLowerManeModelIfNotExists(force)
		return NULL if not IsValid(@maneModelLower)
		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
		modelID = "0" .. modelID if modelID < 10
		model = "models/ppm/hair/ppm_manesetlower#{modelID}.mdl"
		with @maneModelLower
			\SetModel(model) if model ~= \GetModel()
			\SetBodygroup(1, bodygroupID) if \GetBodygroup(1) ~= bodygroupID
			\SetParent(@ent\GetEntity()) if IsValid(@ent)
		@GetData()\SetLowerManeModel(@maneModelLower)
		return @maneModelLower

	UpdateTailModel: (force = false) =>
		return NULL if SERVER or not @isValid or not IsValid(@ent) or not force and @ent\IsDormant() or not @ent\IsPony()
		@CreateTailModelIfNotExists(force)
		return NULL if not IsValid(@tailModel)
		modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
		modelID = "0" .. modelID if modelID < 10
		model = "models/ppm/hair/ppm_tailset#{modelID}.mdl"
		with @tailModel
			\SetModel(model) if model ~= \GetModel()
			\SetBodygroup(1, bodygroupID) if \GetBodygroup(1) ~= bodygroupID
			\SetParent(@ent\GetEntity()) if IsValid(@ent)
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
		ang, vec1, vec2 = Angle(0, 0, 0), Vector(1, 1, 1), Vector(0, 0, 0)
		for wing in *{@@WING_LEFT_1, @@WING_LEFT_2, @@WING_RIGHT_1, @@WING_RIGHT_2, @@WING_OPEN_LEFT, @@WING_OPEN_RIGHT}
			with @ent
				\ManipulateBoneAngles2Safe(wing, ang)
				\ManipulateBoneScale2Safe(wing, vec1)
				\ManipulateBonePosition2Safe(wing, vec2)

	UpdateWings: =>
		return if SERVER
		left = @GetData()\GetLWingSize() * Vector(1, 1, 1)
		leftX = @GetData()\GetLWingX()
		leftY = @GetData()\GetLWingY()
		leftZ = @GetData()\GetLWingZ()
		right = @GetData()\GetRWingSize() * Vector(1, 1, 1)
		rightX = @GetData()\GetRWingX()
		rightY = @GetData()\GetRWingY()
		rightZ = @GetData()\GetRWingZ()
		leftPos = Vector(leftX, leftY, leftZ)
		rightPos = Vector(rightX, rightY, rightZ)

		with @ent
			\ManipulateBoneScale2Safe(@@WING_LEFT_1, left)
			\ManipulateBoneScale2Safe(@@WING_LEFT_2, left)
			\ManipulateBoneScale2Safe(@@WING_OPEN_LEFT, left)
			\ManipulateBoneScale2Safe(@@WING_RIGHT_1, right)
			\ManipulateBoneScale2Safe(@@WING_RIGHT_2, right)
			\ManipulateBoneScale2Safe(@@WING_OPEN_RIGHT, right)

			\ManipulateBonePosition2Safe(@@WING_LEFT_1, leftPos)
			\ManipulateBonePosition2Safe(@@WING_LEFT_2, leftPos)
			\ManipulateBonePosition2Safe(@@WING_OPEN_LEFT, leftPos)
			\ManipulateBonePosition2Safe(@@WING_RIGHT_1, rightPos)
			\ManipulateBonePosition2Safe(@@WING_RIGHT_2, rightPos)
			\ManipulateBonePosition2Safe(@@WING_OPEN_RIGHT, rightPos)

	UpdateEars: =>
		vec = Vector(1, 1, 1) * @GrabData('EarsSize')
		@ent\ManipulateBoneScale2Safe(@@EAR_L, vec)
		@ent\ManipulateBoneScale2Safe(@@EAR_R, vec)

	ResetEars: =>
		ang, vec1, vec2 = Angle(0, 0, 0), Vector(1, 1, 1), Vector(0, 0, 0)
		for part in *{@@EAR_L, @@EAR_R}
			with @ent
				\ManipulateBoneAngles2Safe(part, ang)
				\ManipulateBoneScale2Safe(part, vec1)
				\ManipulateBonePosition2Safe(part, vec2)

	ResetBodygroups: =>
		return unless @isValid
		return unless IsValid(@ent)
		@ent\SetFlexWeight(@@FLEX_ID_EYELASHES, 0)
		@ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
		@ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
		@ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, 0)
		@ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, 0)
		@ent\SetFlexWeight(@@FLEX_ID_FANGS, 0)
		@ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, 0)
		@ResetWings()
		@ResetEars()
		super()

	SlowUpdate: (createModels = CLIENT, force = false) =>
		return if not IsValid(@ent)
		return if not @ent\IsPony()
		@ent\SetFlexWeight(@@FLEX_ID_EYELASHES,     @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
		maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0

		if @GetData()\GetNewMuzzle()
			@ent\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
			@ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
		else
			@ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
			@ent\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)

		@ent\SetFlexWeight(@@FLEX_ID_MALE_BODY,     maleModifier * @GetData()\GetMaleBuff())

		@ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GrabData('BatPonyEars') and @GrabData('BatPonyEarsStrength') or 0)
		@ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH,    @GrabData('ClawTeeth') and @GrabData('ClawTeethStrength') or 0)
		@ent\SetFlexWeight(@@FLEX_ID_HOOF_FLUFF,    @GrabData('HoofFluffers') and @GrabData('HoofFluffersStrength') or 0)

		if @GrabData('Fangs')
			if @GrabData('AlternativeFangs')
				@ent\SetFlexWeight(@@FLEX_ID_FANGS, 0)
				@ent\SetFlexWeight(@@FLEX_ID_FANGS2, @GrabData('FangsStrength'))
			else
				@ent\SetFlexWeight(@@FLEX_ID_FANGS, @GrabData('FangsStrength'))
				@ent\SetFlexWeight(@@FLEX_ID_FANGS2, 0)
		else
			@ent\SetFlexWeight(@@FLEX_ID_FANGS, 0)
			@ent\SetFlexWeight(@@FLEX_ID_FANGS2, 0)

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
		return if not IsValid(@ent)
		@ResetBodygroups()
		return @RemoveModels() if not @ent\IsPony()
		@SlowUpdate(createModels, force)

	@NOCLIP_ANIMATIONS = {9, 10, 11}

	SelectWingsType: =>
		wtype = @GetData()\GetWingsType()
		if (@GetData()\GetFly() or @ent.GetMoveType and @ent\GetMoveType() == MOVETYPE_NOCLIP) and (not @ent.InVehicle or not @ent\InVehicle())
			wtype += PPM2.MAX_WINGS + 1
		return wtype

	ApplyRace: =>
		return unless @isValid
		return if not IsValid(@ent)
		switch @GetData()\GetRace()
			when PPM2.RACE_EARTH
				@ent\SetBodygroup(@@BODYGROUP_HORN, 1)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
			when PPM2.RACE_PEGASUS
				@ent\SetBodygroup(@@BODYGROUP_HORN, 1)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, @SelectWingsType())
			when PPM2.RACE_UNICORN
				@ent\SetBodygroup(@@BODYGROUP_HORN, 0)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS * 2 + 2)
			when PPM2.RACE_ALICORN
				@ent\SetBodygroup(@@BODYGROUP_HORN, 0)
				@ent\SetBodygroup(@@BODYGROUP_WINGS, @SelectWingsType())

	DataChanges: (state) =>
		return unless @isValid
		return if not IsValid(@ent)
		switch state\GetKey()
			when 'EyelashType'
				@ent\SetFlexWeight(@@FLEX_ID_EYELASHES, @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
			when 'Gender'
				maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
				if @GetData()\GetNewMuzzle()
					@ent\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
					@ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
				else
					@ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
					@ent\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)
				@ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
			when 'Fly'
				@ApplyRace()
			when 'NewMuzzle'
				maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
				if @GetData()\GetNewMuzzle()
					@ent\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
					@ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
				else
					@ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
					@ent\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)
				@ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
			when 'BatPonyEars', 'BatPonyEarsStrength'
				@ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GrabData('BatPonyEars') and @GrabData('BatPonyEarsStrength') or 0)
			when 'Fangs', 'AlternativeFangs', 'FangsStrength'
				if @GrabData('Fangs')
					if @GrabData('AlternativeFangs')
						@ent\SetFlexWeight(@@FLEX_ID_FANGS, 0)
						@ent\SetFlexWeight(@@FLEX_ID_FANGS2, @GrabData('FangsStrength'))
					else
						@ent\SetFlexWeight(@@FLEX_ID_FANGS, @GrabData('FangsStrength'))
						@ent\SetFlexWeight(@@FLEX_ID_FANGS2, 0)
				else
					@ent\SetFlexWeight(@@FLEX_ID_FANGS, 0)
					@ent\SetFlexWeight(@@FLEX_ID_FANGS2, 0)
			when 'EarFluffers', 'EarFluffersStrength'
				@UpdateEars()
			when 'HoofFluffers', 'HoofFluffersStrength'
				@ent\SetFlexWeight(@@FLEX_ID_HOOF_FLUFF, @GrabData('HoofFluffers') and @GrabData('HoofFluffersStrength') or 0)
			when 'ClawTeeth', 'ClawTeethStrength'
				@ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, @GrabData('ClawTeeth') and @GrabData('ClawTeethStrength') or 0)
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
				@ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
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
		for ply in *player.GetAll()
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
