
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

class BonesSequence extends PPM2.SequenceBase
	new: (controller, data) =>
		super(controller, data)

		{
			'bones': @bonesNames
			'numid': @numid
		} = data

		@modifierID = controller\GetModifierID(@name .. '_sequence')
		@bonesFuncsPos = ['SetModifier' .. boneName .. 'Position' for boneName in *@bonesNames]
		@bonesFuncsScale = ['SetModifier' .. boneName .. 'Scale' for boneName in *@bonesNames]
		@bonesFuncsAngles = ['SetModifier' .. boneName .. 'Angles' for boneName in *@bonesNames]
		@ent = controller.ent
		@controller = controller
		@Launch()

	GetController: => @controller
	GetEntity: => @ent

	Think: (delta = 0) =>
		@ent = @controller.ent
		return false if not IsValid(@ent)
		super(delta)

	Stop: =>
		super()
		@controller\ResetModifiers(@name .. '_sequence')

	SetBonePosition: (id = 1, val = Vector(0, 0, 0)) => @controller[@bonesFuncsPos[id]] and @controller[@bonesFuncsPos[id]](@controller, @modifierID, val)
	SetBoneScale: (id = 1, val = 0) => @controller[@bonesFuncsScale[id]] and @controller[@bonesFuncsScale[id]](@controller, @modifierID, val)
	SetBoneAngles: (id = 1, val = Angles(0, 0, 0)) => @controller[@bonesFuncsAngles[id]] and @controller[@bonesFuncsAngles[id]](@controller, @modifierID, val)

PPM2.BonesSequence = BonesSequence

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

RESET_BONE_POS = Vector(0, 0, 0)
RESET_BONE_ANGLES = Angle(0, 0, 0)
RESET_BONE_SCALE = Vector(1, 1, 1)
resetBones = (ent) ->
	for i = 0, ent\GetBoneCount() - 1
		ent\ManipulateBonePosition(i, RESET_BONE_POS)
		ent\ManipulateBoneScale(i, RESET_BONE_SCALE)
		ent\ManipulateBoneAngles(i, RESET_BONE_ANGLES)

class PPM2.EntityBonesModifier extends PPM2.SequenceHolder
	@OBJECTS = {}
	@resetBones = resetBones

	@SEQUENCES = {
		{
			'name': 'floppy_ears'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'Ear_L', 'Ear_R'}
			'reset': =>
				@SetBoneAngles(1, Angle(0, -84, -40))
				@SetBoneAngles(2, Angle(0, 84, -40))
			'func': (delta, timeOfAnim) =>
		}

		{
			'name': 'floppy_ears_weak'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'Ear_L', 'Ear_R'}
			'reset': =>
				@SetBoneAngles(1, Angle(0, -20, -20))
				@SetBoneAngles(2, Angle(0, 20, -20))
			'func': (delta, timeOfAnim) =>
		}

		{
			'name': 'forward_ears'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'Ear_L', 'Ear_R'}
			'reset': =>
				@SetBoneAngles(1, Angle(0, -15, -27))
				@SetBoneAngles(2, Angle(0, 15, -27))
			'func': (delta, timeOfAnim) =>
		}

		{
			'name': 'neck_flopping_backward'
			'autostart': false
			'repeat': false
			'time': 3
			'bones': {'LrigNeck3'}
			'reset': =>
			'func': (delta, timeOfAnim) =>
				@SetBoneAngles(1, Angle(0, -12 * timeOfAnim, math.sin(RealTime() * 4) * 20))
		}

		{
			'name': 'neck_backward'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'LrigNeck3'}
			'reset': => @SetBoneAngles(1, Angle(0, -12, 0))
		}

		{
			'name': 'neck_left'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'LrigNeck3'}
			'reset': => @SetBoneAngles(1, Angle(14, 0, 12))
		}

		{
			'name': 'neck_right'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'LrigNeck3'}
			'reset': => @SetBoneAngles(1, Angle(-14, 0, -12))
		}

		{
			'name': 'forward_left'
			'autostart': false
			'repeat': false
			'time': 3
			'bones': {'LrigNeck3'}
			'reset': =>
				@SetBoneAngles(1, Angle(10, 12, -9))
		}

		{
			'name': 'forward_right'
			'autostart': false
			'repeat': false
			'time': 3
			'bones': {'LrigNeck3'}
			'reset': =>
				@SetBoneAngles(1, Angle(-10, 12, 9))
		}
	}

	@SequenceObject = BonesSequence

	hook.Add 'PreDrawOpaqueRenderables', 'PPM2.EntityBonesModifier', (a, b) ->
		return if a or b
		frame = FrameNumber()
		rtime = RealTime()
		for obj in *@OBJECTS
			if not obj\IsValid()
				@OBJECTS = [obj for obj in *@OBJECTS when obj\IsValid()]
				return
			if obj.callFrame ~= frame and (not obj.pac3Last or obj.pac3Last < rtime) and not obj.ent\IsDormant() and not obj.ent\GetNoDraw()
				resetBones(obj.ent)
				data = obj.ent\GetPonyData()
				hook.Call('PPM2.SetupBones', nil, StrongEntity(obj.ent), data) if data
				obj\Think()

	new: (ent = NULL) =>
		super()
		@ent = ent
		@bonesMappingID = {}
		@bonesMappingName = {}
		@bonesMapping = {}
		@bonesMappingForName = {}
		@bonesMappingForID = {}
		@bonesIterable = {}
		@boneCount = 0
		@isValid = false
		table.insert(@@OBJECTS, @)
		@lastCall = RealTime()
		@Setup() if IsValid(ent)

	Setup: (ent = @ent) =>
		return false if not IsValid(ent)
		@lastModel = ent\GetModel()
		@ClearModifiers()
		@isValid = true
		@ent = ent
		@bonesMappingID = {}
		@bonesMappingName = {}
		@boneCount = ent\GetBoneCount()
		@bonesIterable = for i = 0, @boneCount - 1
			name = ent\GetBoneName(i)
			@bonesMappingID[i] = name
			@bonesMapping[i] = name
			@bonesMappingName[name] = i
			@bonesMapping[name] = i
			@bonesMappingForName[name] = name
			@bonesMappingForName[i] = name
			@bonesMappingForID[name] = i
			@bonesMappingForID[i] = i
			@RegisterModifier(name .. 'Position', (-> Vector(0, 0, 0)), (-> Vector(0, 0, 0)))
			@RegisterModifier(name .. 'Scale', (-> Vector(0, 0, 0)), (-> Vector(0, 0, 0)))
			@RegisterModifier(name .. 'Angles', (-> Angle(0, 0, 0)), (-> Angle(0, 0, 0)))
			@SetupLerpTables(name .. 'Position')
			@SetupLerpTables(name .. 'Scale')
			@SetupLerpTables(name .. 'Angles')
			@SetLerpFunc(name .. 'Position', LerpVector)
			@SetLerpFunc(name .. 'Scale', LerpVector)
			@SetLerpFunc(name .. 'Angles', LerpAngle)
			--@RegisterModifier(name .. 'Jiggle', 0)
			{i, name, 'Calculate' .. name .. 'Position', 'Calculate' .. name .. 'Scale', 'Calculate' .. name .. 'Angles'}

	Think: (force = false) =>
		return if not super() or not force and @callFrame == FrameNumber()
		@callFrame = FrameNumber()
		for data in *@bonesIterable
			id = data[1]
			name = data[2]
			calc = data[3]
			calcScale = data[4]
			calcAngles = data[5]
			with @ent
				\ManipulateBonePosition(id, \GetManipulateBonePosition(id) + @[calc](@))
				\ManipulateBoneScale(id, \GetManipulateBoneScale(id) + @[calcScale](@))
				\ManipulateBoneAngles(id, \GetManipulateBoneAngles(id) + @[calcAngles](@))

	IsValid: => @isValid and @ent\IsValid()
	GetEntity: => @ent

with FindMetaTable('Entity')
	.PPMBonesModifier = =>
		return @__ppmBonesModifiers if IsValid(@__ppmBonesModifiers)
		@__ppmBonesModifiers = PPM2.EntityBonesModifier(@)
		@__ppmBonesModifiers.ent = @
		@__ppmBonesModifiers\Setup(@) if @__ppmBonesModifiers.lastModel ~= @GetModel()
		return @__ppmBonesModifiers

hook.Add 'PAC3ResetBones', 'PPM2.EntityBonesModifier', =>
	data = @GetPonyData()
	hook.Call('PPM2.SetupBones', nil, StrongEntity(@), data) if data
	if @__ppmBonesModifiers
		@__ppmBonesModifiers\Think()
		@__ppmBonesModifiers.pac3Last = RealTime() + 0.2

ent.__ppmBonesModifiers = nil for ent in *ents.GetAll()
