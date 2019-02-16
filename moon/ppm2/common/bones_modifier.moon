
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


class BonesSequence extends PPM2.SequenceBase
	new: (controller, data) =>
		super(controller, data)

		{
			'bones': @bonesNames
			'numid': @numid
		} = data

		@modifierID = controller\GetModifierID(@name .. '_sequence')
		@bonesFuncsPos = ['SetModifier' .. boneName .. 'Position' for _, boneName in ipairs @bonesNames]
		@bonesFuncsScale = ['SetModifier' .. boneName .. 'Scale' for _, boneName in ipairs @bonesNames]
		@bonesFuncsAngles = ['SetModifier' .. boneName .. 'Angles' for _, boneName in ipairs @bonesNames]
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

	SetBonePosition: (id = 1, val = LVector(0, 0, 0)) => @controller[@bonesFuncsPos[id]] and @controller[@bonesFuncsPos[id]](@controller, @modifierID, val)
	SetBoneScale: (id = 1, val = 0) => @controller[@bonesFuncsScale[id]] and @controller[@bonesFuncsScale[id]](@controller, @modifierID, val)
	SetBoneAngles: (id = 1, val = Angle(0, 0, 0)) => @controller[@bonesFuncsAngles[id]] and @controller[@bonesFuncsAngles[id]](@controller, @modifierID, val)

PPM2.BonesSequence = BonesSequence

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

RESET_BONE_POS = LVector(0, 0, 0)
RESET_BONE_ANGLES = Angle(0, 0, 0)
RESET_BONE_SCALE = LVector(1, 1, 1)
resetBones = (ent) ->
	for i = 0, ent\GetBoneCount() - 1
		ent\ManipulateBonePosition2Safe(i, RESET_BONE_POS)
		ent\ManipulateBoneScale2Safe(i, RESET_BONE_SCALE)
		ent\ManipulateBoneAngles2Safe(i, RESET_BONE_ANGLES)

for _, ent in ipairs ents.GetAll()
	ent.__ppmBonesModifiers = nil

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
				@SetBoneAngles(1, Angle(0, -12 * timeOfAnim, math.sin(CurTimeL() * 4) * 20))
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
			'name': 'neck_twitch'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'LrigNeck3'}
			'func': (delta, timeOfAnim) =>
				@SetBoneAngles(1, Angle(0, math.cos(CurTimeL() * 4) * 20, 0))
		}

		{
			'name': 'neck_twitch_fast'
			'autostart': false
			'repeat': false
			'time': 5
			'bones': {'LrigNeck3'}
			'func': (delta, timeOfAnim) =>
				@SetBoneAngles(1, Angle(0, math.cos(CurTimeL() * 8) * 20, 0))
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

	if CLIENT
		PreDrawOpaqueRenderables = (a, b) ->
			for _, obj in ipairs @OBJECTS
				if not obj\IsValid()
					oldObjects = @OBJECTS
					@OBJECTS = {}
					for _, obj2 in ipairs oldObjects
						if obj2\IsValid()
							table.insert(@OBJECTS, obj2)
						else
							lent = obj2.ent
							obj2.invalidate = true
							if IsValid(lent)
								lent.__ppmBonesModifiers = nil
					return

				if obj.ent\IsPony() and (not obj.ent\IsPlayer() and not obj.ent.__ppm2RenderOverride or obj.ent == LocalPlayer())
					if obj\CanThink() and not obj.ent\IsDormant() and not obj.ent\GetNoDraw()
						obj.ent\ResetBoneManipCache()
						resetBones(obj.ent)
						data = obj.ent\GetPonyData()
						hook.Call('PPM2.SetupBones', nil, obj.ent, data) if data
						obj\Think()
						obj.ent.__ppmBonesModified = true
						obj.ent\ApplyBoneManipulations()
				elseif obj.ent.__ppmBonesModified and not obj.ent\IsPlayer() and not obj.ent.__ppm2RenderOverride
					resetBones(obj.ent)
					obj.ent.__ppmBonesModified = false

		hook.Add 'PreDrawOpaqueRenderables', 'PPM2.EntityBonesModifier', PreDrawOpaqueRenderables, -5
	else
		timer.Create 'PPM2.ThinkBoneModifiers', 1, 0, ->
			for _, obj in ipairs @OBJECTS
				if not obj\IsValid()
					oldObjects = @OBJECTS
					@OBJECTS = {}
					for _, obj2 in ipairs oldObjects
						if obj2\IsValid()
							table.insert(@OBJECTS, obj2)
						else
							lent = obj2.ent
							obj2.invalidate = true
							if IsValid(lent)
								if lent.__ppmBonesModifiers
									resetBones(lent)
								lent.__ppmBonesModifiers = nil
					return

				if obj.ent\IsPony() and obj\CanThink()
					PPM2.EntityBonesModifier.ThinkObject(obj)
				elseif obj.ent.__ppmBonesModified
					resetBones(obj.ent)
					obj.ent.__ppmBonesModified = false

	@ThinkObject = (obj) ->
		obj.ent\ResetBoneManipCache()
		resetBones(obj.ent)
		data = obj.ent\GetPonyData()
		hook.Call('PPM2.SetupBones', nil, obj.ent, data) if data
		obj\Think()
		obj.ent.__ppmBonesModified = true
		obj.ent\ApplyBoneManipulations()

	new: (ent = NULL) =>
		super()
		@fullBoneMove = SERVER or ent\GetClass() ~= 'prop_ragdoll'
		@ent = ent
		@isLocalPlayer = CLIENT and ent == LocalPlayer()
		@bonesMappingID = {}
		@bonesMappingName = {}
		@bonesMapping = {}
		@bonesMappingForName = {}
		@bonesMappingForID = {}
		@bonesIterable = {}
		@boneCount = 0
		@isValid = false
		table.insert(@@OBJECTS, @)
		@lastCall = RealTimeL()
		@Setup() if IsValid(ent)

	Setup: (ent = @ent) =>
		return false if not IsValid(ent)
		@lastModel = ent\GetModel()
		@isLocalPlayer = CLIENT and ent == LocalPlayer()
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
			@RegisterModifier(name .. 'Position', (-> LVector(0, 0, 0)), (-> LVector(0, 0, 0)))
			@RegisterModifier(name .. 'Scale', (-> LVector(0, 0, 0)), (-> LVector(0, 0, 0)))
			@RegisterModifier(name .. 'Angles', (-> Angle(0, 0, 0)), (-> Angle(0, 0, 0)))
			@SetupLerpTables(name .. 'Position')
			@SetupLerpTables(name .. 'Scale')
			@SetupLerpTables(name .. 'Angles')
			@SetLerpFunc(name .. 'Position', Lerp)
			@SetLerpFunc(name .. 'Scale', Lerp)
			@SetLerpFunc(name .. 'Angles', LerpAngle)
			--@RegisterModifier(name .. 'Jiggle', 0)
			{i, name, 'Calculate' .. name .. 'Position', 'Calculate' .. name .. 'Scale', 'Calculate' .. name .. 'Angles'}

	CanThink: =>
		return true if SERVER
		return false if @isLocalPlayer and not @ent\ShouldDrawLocalPlayer()
		return @callFrame ~= FrameNumberL() and (not @defferReset or @defferReset < RealTimeL())

	Think: (force = false) =>
		return if not super() or not force and CLIENT and @callFrame == FrameNumberL()
		@callFrame = FrameNumberL() if CLIENT

		--if SERVER
		--  print(@ent, debug.traceback())

		with @ent
			calcBonesPos = {}
			calcBonesAngles = {}
			calcBonesScale = {}

			for id = 0, @boneCount - 1
				calcBonesPos[id] = \GetManipulateBonePosition2Safe(id) if @fullBoneMove
				calcBonesPos[id] = Vector() if not @fullBoneMove
				calcBonesAngles[id] = \GetManipulateBoneAngles2Safe(id) if @fullBoneMove
				calcBonesAngles[id] = Angle() if not @fullBoneMove
				calcBonesScale[id] = \GetManipulateBoneScale2Safe(id)

			for i, data in ipairs @bonesIterable
				id = data[1]
				calcBonesPos[id] += @[data[3]](@) if @fullBoneMove
				calcBonesScale[id] += @[data[4]](@)

			if @fullBoneMove
				calcBonesAngles[data[1]] += @[data[5]](@) for i, data in ipairs @bonesIterable

			for id = 0, @boneCount - 1
				\ManipulateBonePosition2Safe(id, calcBonesPos[id]\ToNative()) if @fullBoneMove
				\ManipulateBoneScale2Safe(id, calcBonesScale[id]\ToNative())
				\ManipulateBoneAngles2Safe(id, calcBonesAngles[id]) if @fullBoneMove

	ResetBones: =>
		return if @defferReset and @defferReset > RealTimeL()
		resetBones(@ent)

	IsValid: => @isValid and @ent\IsValid()
	GetEntity: => @ent

	Remove: =>
		return if not @isValid
		@ClearModifiers()
		super()
		@ent.__ppmBonesModifiers = nil if IsValid(@ent)

with FindMetaTable('Entity')
	.PPMBonesModifier = =>
		with t = .GetTable(@)
			return if not t
			return .__ppmBonesModifiers if IsValid(.__ppmBonesModifiers) and not .__ppmBonesModifiers.invalidate
			.__ppmBonesModifiers = PPM2.EntityBonesModifier(@)
			.__ppmBonesModifiers.ent = @
			.__ppmBonesModifiers\Setup(@) if .__ppmBonesModifiers.lastModel ~= @GetModel()
			return .__ppmBonesModifiers

if CLIENT
	hook.Add 'PAC3ResetBones', 'PPM2.EntityBonesModifier', =>
		return if not @IsPony()
		data = @GetPonyData()
		@ResetBoneManipCache()
		hook.Call('PPM2.SetupBones', nil, data.ent, data) if data
		if @__ppmBonesModifiers
			@__ppmBonesModifiers\Think(true)
			@__ppmBonesModifiers.defferReset = RealTimeL() + 0.2
		@ApplyBoneManipulations()

ent.__ppmBonesModifiers = nil for _, ent in ipairs ents.GetAll()
