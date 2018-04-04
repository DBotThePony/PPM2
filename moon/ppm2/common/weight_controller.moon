
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

-- it is defined shared, but used clientside only

import PPM2 from _G

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

class PonyWeightController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}
	@HARD_LIMIT_MINIMAL = 0.1
	@HARD_LIMIT_MAXIMAL = 3

	@DEFAULT_BONE_SIZE = Vector(1, 1, 1)
	@NEXT_OBJ_ID = 0

	new: (data, applyWeight = true) =>
		@isValid = true
		@networkedData = data
		@ent = data.ent
		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0
		@scale = 1
		@SetWeight(data\GetWeight())
		@UpdateWeight() if IsValid(@ent) and applyWeight
		PPM2.DebugPrint('Created new weight controller for ', @ent, ' as part of ', data, '; internal ID is ', @objID)

	__tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"
	IsValid: => IsValid(@ent) and @isValid
	GetEntity: => @ent
	GetData: => @networkedData
	GetController: => @networkedData
	GetModel: => @networkedData\GetModel()

	@WEIGHT_BONES = {
		{id: 0, scale: 1.1}
		{id: 1, scale: 0.7}
		{id: 2, scale: 0.7}
		{id: 3, scale: 0.7}
	}

	table.insert(@WEIGHT_BONES, {id: i, scale: 1}) for i = 8, 29

	DataChanges: (state) =>
		return if not IsValid(@ent) or not @isValid

		if state\GetKey() == 'Weight'
			@SetWeight(state\GetValue())

		if state\GetKey() == 'PonySize'
			@SetSize(state\GetValue())

	SetWeight: (weight = 1) => @weight = math.Clamp(weight, @@HARD_LIMIT_MINIMAL, @@HARD_LIMIT_MAXIMAL)
	SetSize: (scale = 1) => @scale = math.Clamp(math.sqrt(scale), @@HARD_LIMIT_MINIMAL, @@HARD_LIMIT_MAXIMAL)
	SlowUpdate: =>

	ResetBones: (ent = @ent) =>
		return if not IsValid(ent) or not @isValid
		for {:id} in *@@WEIGHT_BONES
			ent\ManipulateBoneScale2Safe(id, @@DEFAULT_BONE_SIZE)

	Reset: => @ResetBones()

	UpdateWeight: (ent = @ent) =>
		return if not IsValid(ent) or not @isValid
		return if not @ent\IsPony()

		for {:id, :scale} in *@@WEIGHT_BONES
			delta = 1 + (@weight * @scale - 1) * scale
			ent\ManipulateBoneScale2Safe(id, Vector(delta, delta, delta))

	Remove: =>
		@isValid = false

if CLIENT
	reset = (ent, data) ->
		if weight = data\GetWeightController()
			weight.ent = ent
			weight\UpdateWeight()

	hook.Add 'PPM2.SetupBones', 'PPM2.Weight', reset, -2

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

class NewPonyWeightController extends PonyWeightController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	__tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"

	@WEIGHT_BONES = {
		{id: 0, scale: 1.1}
		{id: 1, scale: 0.7}
		{id: 6, scale: 0.7}
		{id: 11, scale: 0.7}
		{id: 12, scale: 0.7}
		{id: 13, scale: 0.7}
		{id: 14, scale: 0.7}
		{id: 20, scale: 0.7}

		{id: 5, scale: 0.9}
		{id: 10, scale: 0.9}
		{id: 19, scale: 0.9}
		{id: 25, scale: 0.9}
	}

	table.insert(@WEIGHT_BONES, {id: i, scale: 1}) for i = 1, 10
	table.insert(@WEIGHT_BONES, {id: i, scale: 1}) for i = 14, 28

PPM2.PonyWeightController = PonyWeightController
PPM2.NewPonyWeightController = NewPonyWeightController
PPM2.GetPonyWeightController = (model = '') -> PonyWeightController.AVALIABLE_CONTROLLERS[model] or PonyWeightController

