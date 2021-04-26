
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

net = DLib.net

wUInt = (def = 0, size = 8) ->
	return (arg = def) -> net.WriteUInt(arg, size)

wInt = (def = 0, size = 8) ->
	return (arg = def) -> net.WriteInt(arg, size)

rUInt = (size = 8, min = 0, max = 255) ->
	return -> math.Clamp(net.ReadUInt(size), min, max)

rInt = (size = 8, min = -128, max = 127) ->
	return -> math.Clamp(net.ReadInt(size), min, max)

rFloat = (min = 0, max = 255) ->
	return -> math.Clamp(net.ReadDouble(), min, max)

wFloat = net.WriteDouble
rBool = net.ReadBool
wBool = net.WriteBool
rColor = net.ReadColor
wColor = net.WriteColor
rString = net.ReadString
wString = net.WriteString

COLOR_FIXER = (r = 255, g = 255, b = 255, a = 255) ->
	func = (arg = Color(r, g, b, a)) ->
		if not IsColor(arg)
			return Color()
		else
			{:r, :g, :b, :a} = arg
			if r and g and b and a
				return Color(r, g, b, a)
			else
				return Color()
	return func

URL_FIXER = (arg = '') ->
	arg = tostring(arg)
	if arg\find('^https?://')
		return arg
	else
		return ''

rURL = -> URL_FIXER(rString())

FLOAT_FIXER = (def = 1, min = 0, max = 1) ->
	defFunc = -> def if type(def) ~= 'function'
	defFunc = def if type(def) == 'function'
	return (arg = defFunc()) -> math.Clamp(tonumber(arg) or defFunc(), min, max)

INT_FIXER = (def = 1, min = 0, max = 1) ->
	defFunc = -> def if type(def) ~= 'function'
	defFunc = def if type(def) == 'function'
	return (arg = defFunc()) -> math.floor(math.Clamp(tonumber(arg) or defFunc(), min, max))

PPM2.PonyDataRegistry = {
	'Age': {
		old: 'age'
		default: -> 'ADULT'
		enum: {'FILLY', 'ADULT', 'MATURE'}
	}

	'Race': {
		old: 'race'
		default: -> 'EARTH'
		enum: [arg for _, arg in ipairs PPM2.RACE_ENUMS]
	}

	'WingsType': {
		old: 'wings_type'
		default: -> 0
		enum: [arg for _, arg in ipairs PPM2.AvaliablePonyWings]
	}

	'Gender': {
		old: 'gender'
		default: -> PPM2.GENDER_FEMALE
		type: 'BOOLEAN'
		fix: (value) -> value == true or isstring(value) and value ~= 'FILLY' or value == 1
	}

	'Weight': {
		old: 'weight'
		default: -> 1
		min: PPM2.MIN_WEIGHT
		max: PPM2.MAX_WEIGHT
		type: 'FLOAT'
	}

	'PonySize': {
		old: 'ponysize'
		default: -> 1
		min: PPM2.MIN_SCALE
		max: PPM2.MAX_SCALE
		type: 'FLOAT'
	}

	'NeckSize': {
		old: 'necksize'
		default: -> 1
		min: PPM2.MIN_NECK
		max: PPM2.MAX_NECK
		type: 'FLOAT'
	}

	'LegsSize': {
		old: 'legssize'
		default: -> 1
		min: PPM2.MIN_LEGS
		max: PPM2.MAX_LEGS
		type: 'FLOAT'
	}

	'BackSize': {
		old: 'spinesize'
		default: -> 1
		min: PPM2.MIN_SPINE
		max: PPM2.MAX_SPINE
		type: 'FLOAT'
	}

	'MaleBuff': {
		old: 'male_buff'
		default: -> PPM2.DEFAULT_MALE_BUFF
		min: PPM2.MIN_MALE_BUFF
		max: PPM2.MAX_MALE_BUFF
		type: 'FLOAT'
	}

	'HeadClothes': {
		old: 'clothes_head'
		default: -> 0
		enum: [piece for piece in *PPM2.AvailableClothesHead]
	}

	'NeckClothes': {
		old: 'clothes_neck'
		default: -> 0
		enum: [piece for piece in *PPM2.AvailableClothesNeck]
	}

	'BodyClothes': {
		old: 'clothes_body'
		default: -> 0
		enum: [piece for piece in *PPM2.AvailableClothesBody]
	}

	'EyeClothes': {
		old: 'clothes_eye'
		default: -> 0
		enum: [piece for piece in *PPM2.AvailableClothesEye]
	}

	'EyelashType': {
		old: 'eyelash'
		default: -> 0
		enum: [arg for _, arg in ipairs PPM2.EyelashTypes]
	}

	'TailType': {
		old: 'tail'
		default: -> 2
		enum: [arg for _, arg in ipairs PPM2.AvaliableTails]
	}

	'TailTypeNew': {
		old: 'tail_new'
		default: -> 2
		enum: [arg for _, arg in ipairs PPM2.AvaliableTailsNew]
	}

	'ManeType': {
		old: 'mane'
		default: -> 2
		enum: [arg for _, arg in ipairs PPM2.AvaliableUpperManes]
	}

	'ManeTypeNew': {
		old: 'mane_new'
		default: -> 2
		enum: [arg for _, arg in ipairs PPM2.AvaliableUpperManesNew]
	}

	'ManeTypeLower': {
		old: 'manelower'
		default: -> 2
		enum: [arg for _, arg in ipairs PPM2.AvaliableLowerManes]
	}

	'ManeTypeLowerNew': {
		old: 'manelower_new'
		default: -> 2
		enum: [arg for _, arg in ipairs PPM2.AvaliableLowerManesNew]
	}

	'SocksTexture': {
		old: 'socks_texture'
		default: -> 0
		enum: [arg for _, arg in ipairs PPM2.SocksTypes]
	}

	'SocksTextureURL': {
		old: 'socks_texture_url'
		default: -> ''
		type: 'URL'
	}

	'TailSize': {
		old: 'tailsize'
		default: -> 1
		min: PPM2.MIN_TAIL_SIZE
		max: PPM2.MAX_TAIL_SIZE
		type: 'FLOAT'
	}

	'CMark': {
		old: 'cmark'
		default: -> true
		type: 'BOOLEAN'
	}

	'CMarkSize': {
		old: 'cmark_size'
		default: -> 1
		min: 0.1
		max: 1
		type: 'FLOAT'
	}

	'CMarkColor': {
		old: 'cmark_color'
		default: -> Color()
		type: 'COLOR'
	}

	'EyelashesColor': {
		old: 'eyelash_color'
		default: -> Color(0, 0, 0)
		type: 'COLOR'
	}

	'SeparateEyelashesPhong': {
		old: 'eyelashes_phong_separate'
		default: -> false
		type: 'BOOLEAN'
	}

	'Fangs': {
		old: 'fangs'
		default: -> false
		type: 'BOOLEAN'
	}

	'BatPonyEars': {
		old: 'bat_pony_ears'
		default: -> false
		type: 'BOOLEAN'
	}

	'ClawTeeth': {
		old: 'claw_teeth'
		default: -> false
		type: 'BOOLEAN'
	}

	'CMarkType': {
		old: 'cmark_type'
		default: -> 4
		enum: [arg for _, arg in ipairs PPM2.DefaultCutiemarks]
	}

	'CMarkURL': {
		old: 'cmark_url'
		default: -> ''
		type: 'URL'
	}

	'BodyColor': {
		old: 'body'
		default: -> Color(0xEE321F)
		type: 'COLOR'
	}

	'BodyBumpStrength': {
		old: 'body_bump'
		default: -> 0.5
		type: 'FLOAT'
		min: 0
		max: 1
	}

	'EyebrowsColor': {
		old: 'eyebrows'
		default: -> Color(0, 0, 0)
		type: 'COLOR'
	}

	'GlowingEyebrows': {
		old: 'eyebrows_glow'
		default: -> false
		type: 'BOOLEAN'
	}

	'EyebrowsGlowStrength': {
		old: 'eyebrows_glow_strength'
		default: -> 1
		type: 'FLOAT'
		min: 0
		max: 1
	}

	'HideManes': {
		old: 'hide_manes'
		default: -> true
		type: 'BOOLEAN'
	}

	'HideManesSocks': {
		old: 'hide_manes_socks'
		default: -> true
		type: 'BOOLEAN'
	}

	'HideManesMane': {
		old: 'hide_manes_mane'
		default: -> true
		type: 'BOOLEAN'
	}

	'HideManesTail': {
		old: 'hide_manes_tail'
		default: -> true
		type: 'BOOLEAN'
	}

	'UseNewHorn': {
		old: 'new_horn'
		default: -> false
		type: 'BOOLEAN'
	}

	'NewHornType': {
		old: 'new_horn_type'
		default: -> 2
		enum: [type for type in *PPM2.AvailableHorns]
	}

	'HornColor': {
		old: 'horn_color'
		default: -> Color()
		type: 'COLOR'
	}

	'WingsColor': {
		old: 'wings_color'
		default: -> Color()
		type: 'COLOR'
	}

	'SeparateWings': {
		old: 'separate_wings'
		default: -> false
		type: 'BOOLEAN'
	}

	'SeparateHorn': {
		old: 'separate_horn'
		default: -> false
		type: 'BOOLEAN'
	}

	'SeparateMagicColor': {
		old: 'separate_magic_color'
		default: -> false
		type: 'BOOLEAN'
	}

	'HornMagicColor': {
		old: 'horn_magic_color'
		default: -> Color()
		type: 'COLOR'
	}

	'HornGlow': {
		old: 'horn_glow'
		default: -> false
		type: 'BOOLEAN'
	}

	'HornGlowSrength': {
		old: 'horn_glow_strength'
		default: -> 1
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'HornDetailColor': {
		old: 'horn_detail_color'
		default: -> Color(90, 90, 90)
		type: 'COLOR'
	}

	'SeparateEyes': {
		old: 'separate_eyes'
		default: -> false
		type: 'BOOLEAN'
	}

	'SeparateMane': {
		old: 'separate_mane'
		default: -> false
		type: 'BOOLEAN'
	}

	'CallPlayerFootstepHook': {
		old: 'call_playerfootstep'
		default: -> true
		type: 'BOOLEAN'
	}

	'DisableHoofsteps': {
		old: 'disable_hoofsteps'
		default: -> false
		type: 'BOOLEAN'
	}

	'DisableWanderSounds': {
		old: 'disable_wander_sounds'
		default: -> false
		type: 'BOOLEAN'
	}

	'DisableStepSounds': {
		old: 'disable_new_step_sounds'
		default: -> false
		type: 'BOOLEAN'
	}

	'DisableJumpSound': {
		old: 'disable_jump_sound'
		default: -> false
		type: 'BOOLEAN'
	}

	'DisableFalldownSound': {
		old: 'disable_falldown_sound'
		default: -> false
		type: 'BOOLEAN'
	}

	'Socks': {
		old: 'socks'
		default: -> false
		type: 'BOOLEAN'
	}

	'NewMuzzle': {
		old: 'new_male_muzzle'
		default: -> true
		type: 'BOOLEAN'
	}

	'NoFlex': {
		old: 'noflex'
		default: -> false
		type: 'BOOLEAN'
	}

	'SocksAsModel': {
		old: 'socks_model'
		default: -> false
		type: 'BOOLEAN'
	}

	'SocksAsNewModel': {
		old: 'socks_model_new'
		default: -> false
		type: 'BOOLEAN'
	}

	'SocksColor': {
		old: 'socks_model_color'
		default: -> Color()
		type: 'COLOR'
	}

	'NewSocksColor1': {
		old: 'socks_new_model_color1'
		default: -> Color()
		type: 'COLOR'
	}

	'NewSocksColor2': {
		old: 'socks_new_model_color2'
		default: -> Color(0, 0, 0)
		type: 'COLOR'
	}

	'NewSocksColor3': {
		old: 'socks_new_model_color3'
		default: -> Color(0, 0, 0)
		type: 'COLOR'
	}

	'NewSocksTextureURL': {
		old: 'socks_new_texture_url'
		default: -> ''
		type: 'URL'
	}

	'Bodysuit': {
		old: 'suit'
		default: -> 0
		enum: [arg for _, arg in ipairs PPM2.AvaliablePonySuits]
	}

	'LWingSize': {
		old: 'left_wing_size'
		default: -> 1
		min: PPM2.MIN_WING
		max: PPM2.MAX_WING
		type: 'FLOAT'
	}

	'LWingX': {
		old: 'left_wing_x'
		default: -> 0
		min: PPM2.MIN_WINGX
		max: PPM2.MAX_WINGX
		type: 'FLOAT'
	}

	'LWingY': {
		old: 'left_wing_y'
		default: -> 0
		min: PPM2.MIN_WINGY
		max: PPM2.MAX_WINGY
		type: 'FLOAT'
	}

	'LWingZ': {
		old: 'left_wing_z'
		default: -> 0
		min: PPM2.MIN_WINGZ
		max: PPM2.MAX_WINGZ
		type: 'FLOAT'
	}

	'RWingSize': {
		old: 'right_wing_size'
		default: -> 1
		min: PPM2.MIN_WING
		max: PPM2.MAX_WING
		type: 'FLOAT'
	}

	'RWingX': {
		old: 'right_wing_x'
		default: -> 0
		min: PPM2.MIN_WINGX
		max: PPM2.MAX_WINGX
		type: 'FLOAT'
	}

	'RWingY': {
		old: 'right_wing_y'
		default: -> 0
		min: PPM2.MIN_WINGY
		max: PPM2.MAX_WINGY
		type: 'FLOAT'
	}

	'RWingZ': {
		old: 'right_wing_z'
		default: -> 0
		min: PPM2.MIN_WINGZ
		max: PPM2.MAX_WINGZ
		type: 'FLOAT'
	}

	'TeethColor': {
		old: 'teeth_color'
		default: -> Color()
		type: 'COLOR'
	}

	'MouthColor': {
		old: 'mouth_color'
		default: -> Color(219, 65, 155)
		type: 'COLOR'
	}

	'TongueColor': {
		old: 'tongue_color'
		default: -> Color(235, 131, 59)
		type: 'COLOR'
	}

	'BatWingColor': {
		old: 'bat_wing_color'
		default: -> Color()
		type: 'COLOR'
	}

	'BatWingSkinColor': {
		old: 'bat_wing_skin_color'
		default: -> Color()
		type: 'COLOR'
	}

	'SeparateHornPhong': {
		old: 'separate_horn_phong'
		default: -> false
		type: 'BOOLEAN'
	}

	'SeparateWingsPhong': {
		old: 'separate_wings_phong'
		default: -> false
		type: 'BOOLEAN'
	}

	'SeparateManePhong': {
		old: 'separate_mane_phong'
		default: -> false
		type: 'BOOLEAN'
	}

	'SeparateTailPhong': {
		old: 'separate_tail_phong'
		default: -> false
		type: 'BOOLEAN'
	}

	'AlternativeFangs': {
		old: 'alternative_fangs'
		default: -> false
		type: 'BOOLEAN'
	}

	'HoofFluffers': {
		old: 'hoof_fluffers'
		default: -> false
		type: 'BOOLEAN'
	}

	'HoofFluffersStrength': {
		old: 'hoof_fluffers_strength'
		default: -> 1
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'EarsSize': {
		old: 'ears_size'
		default: -> 1
		min: 0.1
		max: 2
		type: 'FLOAT'
	}

	'BatPonyEarsStrength': {
		old: 'bat_pony_ears_strength'
		default: -> 1
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'FangsStrength': {
		old: 'fangs_strength'
		default: -> 1
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'ClawTeethStrength': {
		old: 'clawteeth_strength'
		default: -> 1
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'LipsColorInherit': {
		old: 'lips_color_inherit'
		default: -> true
		type: 'BOOLEAN'
	}

	'NoseColorInherit': {
		old: 'nose_color_inherit'
		default: -> true
		type: 'BOOLEAN'
	}

	'LipsColor': {
		old: 'lips_color'
		default: -> Color(172, 92, 92)
		type: 'COLOR'
	}

	'NoseColor': {
		old: 'nose_color'
		default: -> Color(77, 84, 83)
		type: 'COLOR'
	}

	'HideWeapons': {
		old: 'weapon_hide'
		default: -> true
		type: 'BOOLEAN'
	}
}

for {internal, publicName} in *{{'_head', 'Head'}, {'_neck', 'Neck'}, {'_body', 'Body'}, {'_eye', 'Eye'}}
	PPM2.PonyDataRegistry["#{publicName}ClothesUseColor"] = {
		old: "clothes#{internal}_color_nil"
		default: -> false
		type: 'BOOLEAN'
	}

	for i = 1, PPM2.MAX_CLOTHES_URLS
		PPM2.PonyDataRegistry["#{publicName}ClothesURL#{i}"] = {
			old: "clothes#{internal}_url_#{i}"
			default: -> ''
			type: 'URL'
		}

	for num = 1, PPM2.MAX_CLOTHES_COLORS
		PPM2.PonyDataRegistry["#{publicName}ClothesColor#{num}"] = {
			old: "clothes#{internal}_color_#{num}"
			default: -> Color()
			type: 'COLOR'
		}

for _, {internal, publicName} in ipairs {{'_left', 'Left'}, {'_right', 'Right'}, {'', ''}}
	PPM2.PonyDataRegistry["EyeURL#{publicName}"] = {
		default: -> ''
		old: "eye_url#{internal}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["EyeBackground#{publicName}"] = {
		default: -> Color()
		old: "eye_bg#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeHole#{publicName}"] = {
		default: -> Color(0, 0, 0)
		old: "eye_hole#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeIrisTop#{publicName}"] = {
		default: -> Color(0xEE9620)
		old: "eye_iris1#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeIrisBottom#{publicName}"] = {
		default: -> Color(0xEE9620)
		old: "eye_iris2#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeIrisLine1#{publicName}"] = {
		default: -> Color()
		old: "eye_irisline1#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeLineDirection#{publicName}"] = {
		default: -> false
		old: "eye_irisline_direction#{internal}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["EyeIrisLine2#{publicName}"] = {
		default: -> Color()
		old: "eye_irisline2#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeReflection#{publicName}"] = {
		default: -> Color(255, 255, 255, 127)
		old: "eye_reflection#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeEffect#{publicName}"] = {
		default: -> Color()
		old: "eye_effect#{internal}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["EyeLines#{publicName}"] = {
		default: -> true
		old: "eye_lines#{internal}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["IrisSize#{publicName}"] = {
		default: -> 1
		old: "eye_iris_size#{internal}"
		min: PPM2.MIN_IRIS
		max: PPM2.MAX_IRIS
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["DerpEyes#{publicName}"] = {
		default: -> false
		old: "eye_derp#{internal}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["EyeRefract#{publicName}"] = {
		default: -> true
		old: "eye_use_refract#{internal}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["EyeCornerA#{publicName}"] = {
		default: -> false
		old: "eye_cornera#{internal}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["DerpEyesStrength#{publicName}"] = {
		default: -> 1
		old: "eye_derp_strength#{internal}"
		min: PPM2.MIN_DERP_STRENGTH
		max: PPM2.MAX_DERP_STRENGTH
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["EyeType#{publicName}"] = {
		default: -> 0
		old: "eye_type#{internal}"
		enum: [arg for _, arg in ipairs PPM2.AvaliableEyeTypes]
	}

	PPM2.PonyDataRegistry["EyeReflectionType#{publicName}"] = {
		default: -> 0
		old: "eye_reflection_type#{internal}"
		enum: [arg for _, arg in ipairs PPM2.AvaliableEyeReflections]
	}

	PPM2.PonyDataRegistry["HoleWidth#{publicName}"] = {
		default: -> 1
		old: "hole_width#{internal}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["HoleHeight#{publicName}"] = {
		default: -> 1
		old: "hole_height#{internal}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["IrisWidth#{publicName}"] = {
		default: -> 1
		old: "iris_width#{internal}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["IrisHeight#{publicName}"] = {
		default: -> 1
		old: "iris_height#{internal}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["EyeGlossyStrength#{publicName}"] = {
		default: -> 0.4
		old: "eye_glossy_reflection#{internal}"
		min: -4
		max: 4
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["HoleShiftX#{publicName}"] = {
		default: -> 0
		old: "hole_shiftx#{internal}"
		min: PPM2.MIN_HOLE_SHIFT
		max: PPM2.MAX_HOLE_SHIFT
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["HoleShiftY#{publicName}"] = {
		default: -> 0
		old: "hole_shifty#{internal}"
		min: PPM2.MIN_HOLE_SHIFT
		max: PPM2.MAX_HOLE_SHIFT
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["HoleSize#{publicName}"] = {
		default: -> .8
		old: "eye_hole_size#{internal}"
		min: PPM2.MIN_HOLE
		max: PPM2.MAX_HOLE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["EyeRotation#{publicName}"] = {
		default: -> 0
		old: "eye_rotation#{internal}"
		min: PPM2.MIN_EYE_ROTATION
		max: PPM2.MAX_EYE_ROTATION
		type: 'INT'
	}

for i = 1, 3
	PPM2.PonyDataRegistry["HornURL#{i}"] = {
		default: -> ''
		old: "horn_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["BatWingURL#{i}"] = {
		default: -> ''
		old: "bat_wing_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["BatWingSkinURL#{i}"] = {
		default: -> ''
		old: "bat_wing_skin_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["WingsURL#{i}"] = {
		default: -> ''
		old: "wings_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["HornURLColor#{i}"] = {
		default: -> Color()
		old: "horn_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["BatWingURLColor#{i}"] = {
		default: -> Color()
		old: "bat_wing_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["BatWingSkinURLColor#{i}"] = {
		default: -> Color()
		old: "bat_wing_skin_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["WingsURLColor#{i}"] = {
		default: -> Color()
		old: "wings_url_color_#{i}"
		type: 'COLOR'
	}

for i = 1, 6
	PPM2.PonyDataRegistry["SocksDetailColor#{i}"] = {
		default: -> Color()
		old: "socks_detail_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["ManeColor#{i}"] = {
		default: -> i == 1 and Color(0xFFD117) or i == 2 and Color(0xE3C23C) or Color()
		old: "mane_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["ManeDetailColor#{i}"] = {
		default: -> i == 1 and Color(0xFFD117) or i == 2 and Color(0xE3C23C) or Color()
		old: "mane_detail_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["ManeURLColor#{i}"] = {
		default: -> Color()
		old: "mane_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["ManeURL#{i}"] = {
		default: -> ''
		old: "mane_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["TailDetailColor#{i}"] = {
		default: -> i == 1 and Color(0xFFD117) or i == 2 and Color(0xE3C23C) or Color()
		old: "tail_detail_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["TailURLColor#{i}"] = {
		default: -> Color()
		old: "tail_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["TailURL#{i}"] = {
		default: -> ''
		old: "tail_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["TailColor#{i}"] = {
		default: -> i == 1 and Color(0xFFD117) or i == 2 and Color(0xE3C23C) or Color()
		old: "tail_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["LowerManeColor#{i}"] = {
		default: -> i == 1 and Color(0xFFD117) or i == 2 and Color(0xE3C23C) or Color()
		old: "lower_mane_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["LowerManeURLColor#{i}"] = {
		default: -> Color()
		old: "lower_mane_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["LowerManeURL#{i}"] = {
		default: -> ''
		old: "lower_mane_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["UpperManeColor#{i}"] = {
		default: -> i == 1 and Color(0xFFD117) or i == 2 and Color(0xE3C23C) or Color()
		old: "upper_mane_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["UpperManeURLColor#{i}"] = {
		default: -> Color()
		old: "upper_mane_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["UpperManeURL#{i}"] = {
		default: -> ''
		old: "upper_mane_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["LowerManeDetailColor#{i}"] = {
		default: -> Color()
		old: "lower_mane_detail_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["UpperManeDetailColor#{i}"] = {
		default: -> Color()
		old: "upper_mane_detail_color_#{i}"
		type: 'COLOR'
	}

for i = 1, PPM2.MAX_BODY_DETAILS
	PPM2.PonyDataRegistry["BodyDetailColor#{i}"] = {
		default: -> Color()
		old: "body_detail_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["BodyDetail#{i}"] = {
		default: -> 0
		old: "body_detail_#{i}"
		enum: [arg for _, arg in ipairs PPM2.BodyDetailsEnum]
	}

	PPM2.PonyDataRegistry["BodyDetailFirst#{i}"] = {
		default: -> false
		old: "body_detail_#{i}_first"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["BodyDetailURLFirst#{i}"] = {
		default: -> false
		old: "body_url_detail_#{i}_first"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["BodyDetailURL#{i}"] = {
		default: -> ''
		old: "body_detail_url_#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["BodyDetailURLColor#{i}"] = {
		default: -> Color()
		old: "body_detail_url_color_#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["BodyDetailGlow#{i}"] = {
		default: -> false
		old: "body_detail_glow_#{i}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["BodyDetailGlowStrength#{i}"] = {
		default: -> 1
		old: "body_detail_glow_strength_#{i}"
		type: 'FLOAT'
		min: 0
		max: 1
	}

for i = 1, PPM2.MAX_TATTOOS
	PPM2.PonyDataRegistry["TattooType#{i}"] = {
		default: -> 0
		old: "tattoo_type_#{i}"
		enum: [arg for _, arg in ipairs PPM2.TATTOOS_REGISTRY]
	}

	PPM2.PonyDataRegistry["TattooPosX#{i}"] = {
		default: -> 0
		old: "tattoo_posx_#{i}"
		min: -100
		max: 100
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["TattooPosY#{i}"] = {
		default: -> 0
		old: "tattoo_posy_#{i}"
		fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, -100, 100)
		min: -100
		max: 100
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["TattooRotate#{i}"] = {
		default: -> 0
		old: "tattoo_rotate_#{i}"
		min: -180
		max: 180
		type: 'INT'
	}

	PPM2.PonyDataRegistry["TattooScaleX#{i}"] = {
		default: -> 1
		old: "tattoo_scalex_#{i}"
		min: 0
		max: 10
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["TattooGlowStrength#{i}"] = {
		default: -> 1
		old: "tattoo_glow_strength_#{i}"
		min: 0
		max: 1
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["TattooScaleY#{i}"] = {
		default: -> 1
		old: "tattoo_scaley_#{i}"
		min: 0
		max: 10
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["TattooGlow#{i}"] = {
		default: -> false
		old: "tattoo_glow_#{i}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["TattooOverDetail#{i}"] = {
		default: -> false
		old: "tattoo_over_detail_#{i}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["TattooColor#{i}"] = {
		default: -> Color()
		old: "tattoo_color_#{i}"
		type: 'COLOR'
	}

for _, ttype in ipairs {'Body', 'Horn', 'Wings', 'BatWingsSkin', 'Socks', 'Mane', 'Tail', 'UpperMane', 'LowerMane', 'LEye', 'REye', 'BEyes', 'Eyelashes', 'Mouth', 'Teeth', 'Tongue'}
	PPM2.PonyDataRegistry[ttype .. 'PhongExponent'] = {
		default: -> 3
		old: "#{ttype\lower()}_phong_exponent"
		min: 0.04
		max: 10
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype .. 'PhongBoost'] = {
		default: -> 0.09
		old: "#{ttype\lower()}_phong_boost"
		min: 0.01
		max: 1
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype .. 'PhongFront'] = {
		default: -> 1
		old: "#{ttype\lower()}_phong_front"
		min: 0
		max: 20
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype .. 'PhongMiddle'] = {
		default: -> 5
		old: "#{ttype\lower()}_phong_middle"
		min: 0
		max: 20
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype .. 'PhongSliding'] = {
		default: -> 10
		old: "#{ttype\lower()}_phong_sliding"
		min: 0
		max: 20
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype .. 'PhongTint'] = {
		default: -> Color(255, 200, 200)
		old: "#{ttype\lower()}_phong_tint"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry[ttype .. 'Lightwarp'] = {
		default: -> 0
		old: "#{ttype\lower()}_lightwarp_texture"
		enum: [arg for _, arg in ipairs PPM2.AvaliableLightwarps]
	}

	PPM2.PonyDataRegistry[ttype .. 'LightwarpURL'] = {
		default: -> ''
		old: "#{ttype\lower()}_lightwarp_texture_url"
		type: 'URL'
	}

	PPM2.PonyDataRegistry[ttype .. 'BumpmapURL'] = {
		default: -> ''
		old: "#{ttype\lower()}_bumpmap_texture_url"
		type: 'URL'
	}

for _, {:flex, :active} in ipairs PPM2.PonyFlexController.FLEX_LIST
	continue if not active
	PPM2.PonyDataRegistry["DisableFlex#{flex}"] = {
		default: -> false
		old: "flex_disable_#{flex\lower()}"
		type: 'BOOLEAN'
	}

for key, value in pairs PPM2.PonyDataRegistry
	if value.enum
		value.enum = [arg\upper() for _, arg in ipairs value.enum]
		value.enum_runtime_map = {}

		for i, enumVal in ipairs value.enum
			value.enum_runtime_map[i - 1] = enumVal
			value.enum_runtime_map[enumVal] = i - 1

		value.min = 0
		value.max = #value.enum - 1
		value.type = 'INT'

		def_old = value.default()
		_def_old = def_old
		def_old = value.enum_runtime_map[def_old] if isstring(def_old)
		error("Invalid value #{_def_old} for enum of #{key}") if not isnumber(def_old)
		value.default = -> def_old

	switch value.type
		when 'INT'
			error("Variable #{key} has invalid minimal value (#{type(value.min)})") if not isnumber(value.min)
			error("Variable #{max} has invalid maximal value (#{type(value.max)})") if not isnumber(value.max)

			value.fix = INT_FIXER(value.default, value.min, value.max)

			if value.min >= 0
				selectBits = net.ChooseOptimalBits(value.max - value.min)
				value.read = rUInt(selectBits, value.min, value.max)
				value.write = wUInt(value.default(), selectBits)
			else
				selectBits = net.ChooseOptimalBits(math.abs(value.max - value.min))
				value.read = rInt(selectBits, value.min, value.max)
				value.write = wInt(value.default(), selectBits)

		when 'FLOAT'
			error("Variable #{key} has invalid minimal value (#{type(value.min)})") if not isnumber(value.min)
			error("Variable #{max} has invalid maximal value (#{type(value.max)})") if not isnumber(value.max)

			value.fix = FLOAT_FIXER(value.default, value.min, value.max)
			value.read = rFloat(value.min, value.max)
			value.write = (arg = value.default()) -> wFloat(arg)
		when 'URL'
			value.fix = URL_FIXER
			value.read = rURL
			value.write = wString
		when 'BOOLEAN'
			if not value.fix
				value.fix = (arg = value.default()) -> tobool(arg)
			value.read = rBool
			value.write = wBool
		when 'COLOR'
			{:r, :g, :b, :a} = value.default()
			value.fix = COLOR_FIXER(r, g, b, a)
			value.read = rColor
			value.write = wColor
		else
			error("Unknown variable type - #{value.type} for #{key}")

for key, value in pairs PPM2.PonyDataRegistry
	error("Data has no fix function: #{key}") if not value.fix
