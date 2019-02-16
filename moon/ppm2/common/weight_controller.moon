
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


-- it is defined shared, but used clientside only

import PPM2 from _G

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

class PonyWeightController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}
	@HARD_LIMIT_MINIMAL = 0.1
	@HARD_LIMIT_MAXIMAL = 3

	@DEFAULT_BONE_SIZE = LVector(1, 1, 1)
	@NEXT_OBJ_ID = 0

	Remap: =>
		@WEIGHT_BONES = [{id: @GetEntity()\LookupBone(id), scale: scale} for _, {:id, :scale} in ipairs @@WEIGHT_BONES]

		@validSkeleton = true
		for _, {:id} in ipairs @WEIGHT_BONES
			if not id
				@validSkeleton = false
				break

	new: (controller, applyWeight = true) =>
		@isValid = true
		@controller = controller
		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0
		@scale = 1
		@SetWeight(controller\GetWeight())
		@Remap()
		@UpdateWeight() if IsValid(@GetEntity()) and applyWeight
		PPM2.DebugPrint('Created new weight controller for ', @GetEntity(), ' as part of ', data, '; internal ID is ', @objID)

	__tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"
	IsValid: => IsValid(@GetEntity()) and @isValid
	GetEntity: => @controller\GetEntity()
	GetData: => @controller
	GetController: => @controller
	GetModel: => @controller\GetModel()

	PlayerDeath: =>
		@ResetBones()
		@Remap()

	PlayerRespawn: =>
		@Remap()
		@UpdateWeight()

	@WEIGHT_BONES = {
		{id: 'LrigPelvis', scale: 1.1}
		{id: 'LrigSpine1', scale: 0.7}
		{id: 'LrigSpine2', scale: 0.7}
		{id: 'LrigRibcage', scale: 0.7}
	}

	extrabones = {
		'Lrig_LEG_BL_Femur'
		'Lrig_LEG_BL_Tibia'
		'Lrig_LEG_BL_LargeCannon'
		'Lrig_LEG_BL_PhalanxPrima'
		'Lrig_LEG_BL_RearHoof'
		'Lrig_LEG_BR_Femur'
		'Lrig_LEG_BR_Tibia'
		'Lrig_LEG_BR_LargeCannon'
		'Lrig_LEG_BR_PhalanxPrima'
		'Lrig_LEG_BR_RearHoof'
		'Lrig_LEG_FL_Scapula'
		'Lrig_LEG_FL_Humerus'
		'Lrig_LEG_FL_Radius'
		'Lrig_LEG_FL_Metacarpus'
		'Lrig_LEG_FL_PhalangesManus'
		'Lrig_LEG_FL_FrontHoof'
		'Lrig_LEG_FR_Scapula'
		'Lrig_LEG_FR_Humerus'
		'Lrig_LEG_FR_Radius'
		'Lrig_LEG_FR_Metacarpus'
		'Lrig_LEG_FR_PhalangesManus'
		'Lrig_LEG_FR_FrontHoof'
	}

	table.insert(@WEIGHT_BONES, {id: name, scale: 1}) for _, name in ipairs extrabones

	DataChanges: (state) =>
		return if not IsValid(@GetEntity()) or not @isValid
		@Remap()

		if state\GetKey() == 'Weight'
			@SetWeight(state\GetValue())

		if state\GetKey() == 'PonySize'
			@SetSize(state\GetValue())

	SetWeight: (weight = 1) => @weight = math.Clamp(weight, @@HARD_LIMIT_MINIMAL, @@HARD_LIMIT_MAXIMAL)
	SetSize: (scale = 1) => @scale = math.Clamp(math.sqrt(scale), @@HARD_LIMIT_MINIMAL, @@HARD_LIMIT_MAXIMAL)
	SlowUpdate: =>

	ResetBones: (ent = @GetEntity()) =>
		return if not IsValid(ent) or not @isValid
		return if not @validSkeleton
		for _, {:id} in ipairs @WEIGHT_BONES
			ent\ManipulateBoneScale2Safe(id, @@DEFAULT_BONE_SIZE)

	Reset: => @ResetBones()

	UpdateWeight: (ent = @GetEntity()) =>
		return if not IsValid(ent) or not @isValid
		return if not @GetEntity()\IsPony()
		return if @GetEntity().Alive and not @GetEntity()\Alive()
		return if not @validSkeleton

		for _, {:id, :scale} in ipairs @WEIGHT_BONES
			delta = 1 + (@weight * @scale - 1) * scale
			ent\ManipulateBoneScale2Safe(id, LVector(delta, delta, delta))

	Remove: =>
		@isValid = false

do
	reset = (ent, data) ->
		if weight = data\GetWeightController()
			weight.ent = ent
			weight\UpdateWeight()

	hook.Add 'PPM2.SetupBones', 'PPM2.Weight', reset, -2

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

class NewPonyWeightController extends PonyWeightController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	__tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"

	@WEIGHT_BONES = {
		{id: 'LrigPelvis', scale: 1.1}
		{id: 'Lrig_LEG_BL_Femur', scale: 0.7}
		{id: 'Lrig_LEG_BR_Femur', scale: 0.7}
		{id: 'LrigSpine1', scale: 0.7}
		{id: 'LrigSpine2', scale: 0.7}
		{id: 'LrigRibcage', scale: 0.7}
		{id: 'Lrig_LEG_FL_Scapula', scale: 0.7}
		{id: 'Lrig_LEG_FR_Scapula', scale: 0.7}

		{id: 'Lrig_LEG_BL_RearHoof', scale: 0.9}
		{id: 'Lrig_LEG_BR_RearHoof', scale: 0.9}
		{id: 'Lrig_LEG_FL_FrontHoof', scale: 0.9}
		{id: 'Lrig_LEG_FR_FrontHoof', scale: 0.9}

		{id: 'Lrig_LEG_BL_Tibia', scale: 1}
		{id: 'Lrig_LEG_BL_LargeCannon', scale: 1}
		{id: 'Lrig_LEG_BL_PhalanxPrima', scale: 1}
		{id: 'Lrig_LEG_BR_Femur', scale: 1}
		{id: 'Lrig_LEG_BR_Tibia', scale: 1}
		{id: 'Lrig_LEG_BR_LargeCannon', scale: 1}
		{id: 'Lrig_LEG_BR_PhalanxPrima', scale: 1}

		{id: 'Lrig_LEG_FL_Humerus', scale: 1}
		{id: 'Lrig_LEG_FL_Radius', scale: 1}
		{id: 'Lrig_LEG_FL_Metacarpus', scale: 1}
		{id: 'Lrig_LEG_FL_PhalangesManus', scale: 1}
		{id: 'Lrig_LEG_FR_Humerus', scale: 1}
		{id: 'Lrig_LEG_FR_Radius', scale: 1}
		{id: 'Lrig_LEG_FR_Metacarpus', scale: 1}
		{id: 'Lrig_LEG_FR_PhalangesManus', scale: 1}
		{id: 'LrigNeck1', scale: 1}
		{id: 'LrigNeck2', scale: 1}
		{id: 'LrigNeck3', scale: 1}
	}


PPM2.PonyWeightController = PonyWeightController
PPM2.NewPonyWeightController = NewPonyWeightController
PPM2.GetPonyWeightController = (model = '') -> PonyWeightController.AVALIABLE_CONTROLLERS[model] or PonyWeightController

