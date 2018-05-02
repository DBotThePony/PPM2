
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

wUInt = (def = 0, size = 8) ->
	return (arg = def) -> net.WriteUInt(arg, size)

wInt = (def = 0, size = 8) ->
	return (arg = def) -> net.WriteInt(arg, size)

rUInt = (size = 8, min = 0, max = 255) ->
	return -> math.Clamp(net.ReadUInt(size), min, max)

rInt = (size = 8, min = -128, max = 127) ->
	return -> math.Clamp(net.ReadInt(size), min, max)

rFloat = (min = 0, max = 255) ->
	return -> math.Clamp(net.ReadFloat(), min, max)

wFloat = net.WriteFloat
rSEnt = net.ReadStrongEntity
wSEnt = net.WriteStrongEntity
rBool = net.ReadBool
wBool = net.WriteBool
rColor = net.ReadColor
wColor = net.WriteColor
rString = net.ReadString
wString = net.WriteString

COLOR_FIXER = (r = 255, g = 255, b = 255, a = 255) ->
	func = (arg = Color(r, g, b, a)) ->
		if type(arg) ~= 'table'
			return Color(255, 255, 255)
		else
			{:r, :g, :b, :a} = arg
			if r and g and b and a
				return Color(r, g, b, a)
			else
				return Color(255, 255, 255)
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
	'age': {
		default: -> PPM2.AGE_ADULT
		getFunc: 'Age'
		enum: {'FILLY', 'ADULT', 'MATURE'}
	}

	'race': {
		default: -> PPM2.RACE_EARTH
		getFunc: 'Race'
		enum: [arg for arg in *PPM2.RACE_ENUMS]
	}

	'wings_type': {
		default: -> 0
		getFunc: 'WingsType'
		enum: [arg for arg in *PPM2.AvaliablePonyWings]
	}

	'gender': {
		default: -> PPM2.GENDER_FEMALE
		getFunc: 'Gender'
		enum: [arg for arg in *PPM2.AGE_ENUMS]
	}

	'weight': {
		default: -> 1
		getFunc: 'Weight'
		min: PPM2.MIN_WEIGHT
		max: PPM2.MAX_WEIGHT
		type: 'FLOAT'
	}

	'ponysize': {
		default: -> 1
		getFunc: 'PonySize'
		min: PPM2.MIN_SCALE
		max: PPM2.MAX_SCALE
		type: 'FLOAT'
	}

	'necksize': {
		default: -> 1
		getFunc: 'NeckSize'
		min: PPM2.MIN_NECK
		max: PPM2.MAX_NECK
		type: 'FLOAT'
	}

	'legssize': {
		default: -> 1
		getFunc: 'LegsSize'
		min: PPM2.MIN_LEGS
		max: PPM2.MAX_LEGS
		type: 'FLOAT'
	}

	'spinesize': {
		default: -> 1
		getFunc: 'BackSize'
		min: PPM2.MIN_SPINE
		max: PPM2.MAX_SPINE
		type: 'FLOAT'
	}

	'male_buff': {
		default: -> PPM2.DEFAULT_MALE_BUFF
		getFunc: 'MaleBuff'
		min: PPM2.MIN_MALE_BUFF
		max: PPM2.MAX_MALE_BUFF
		type: 'FLOAT'
	}

	'eyelash': {
		default: -> 0
		getFunc: 'EyelashType'
		enum: [arg for arg in *PPM2.EyelashTypes]
	}

	'tail': {
		default: -> 0
		getFunc: 'TailType'
		enum: [arg for arg in *PPM2.AvaliableTails]
	}

	'tail_new': {
		default: -> 0
		getFunc: 'TailTypeNew'
		enum: [arg for arg in *PPM2.AvaliableTailsNew]
	}

	'mane': {
		default: -> 0
		getFunc: 'ManeType'
		enum: [arg for arg in *PPM2.AvaliableUpperManes]
	}

	'mane_new': {
		default: -> 0
		getFunc: 'ManeTypeNew'
		enum: [arg for arg in *PPM2.AvaliableUpperManesNew]
	}

	'manelower': {
		default: -> 0
		getFunc: 'ManeTypeLower'
		enum: [arg for arg in *PPM2.AvaliableLowerManes]
	}

	'manelower_new': {
		default: -> 0
		getFunc: 'ManeTypeLowerNew'
		enum: [arg for arg in *PPM2.AvaliableLowerManesNew]
	}

	'socks_texture': {
		default: -> 0
		getFunc: 'SocksTexture'
		enum: [arg for arg in *PPM2.SocksTypes]
	}

	'socks_texture_url': {
		default: -> ''
		getFunc: 'SocksTextureURL'
		type: 'URL'
	}

	'tailsize': {
		default: -> 1
		getFunc: 'TailSize'
		min: PPM2.MIN_TAIL_SIZE
		max: PPM2.MAX_TAIL_SIZE
		type: 'FLOAT'
	}

	'cmark': {
		default: -> true
		getFunc: 'CMark'
		type: 'BOOLEAN'
	}

	'cmark_size': {
		default: -> 1
		getFunc: 'CMarkSize'
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'cmark_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'CMarkColor'
		type: 'COLOR'
	}

	'eyelash_color': {
		default: -> Color(0, 0, 0)
		getFunc: 'EyelashesColor'
		type: 'COLOR'
	}

	'eyelashes_phong_separate': {
		default: -> false
		getFunc: 'SeparateEyelashesPhong'
		type: 'BOOLEAN'
	}

	'fangs': {
		default: -> false
		getFunc: 'Fangs'
		type: 'BOOLEAN'
	}

	'bat_pony_ears': {
		default: -> false
		getFunc: 'BatPonyEars'
		type: 'BOOLEAN'
	}

	'claw_teeth': {
		default: -> false
		getFunc: 'ClawTeeth'
		type: 'BOOLEAN'
	}

	'cmark_type': {
		default: -> 4
		getFunc: 'CMarkType'
		enum: [arg for arg in *PPM2.DefaultCutiemarks]
	}

	'cmark_url': {
		default: -> ''
		getFunc: 'CMarkURL'
		type: 'URL'
	}

	'body': {
		default: -> Color(255, 255, 255)
		getFunc: 'BodyColor'
		type: 'COLOR'
	}

	'eyebrows': {
		default: -> Color(0, 0, 0)
		getFunc: 'EyebrowsColor'
		type: 'COLOR'
	}

	'eyebrows_glow': {
		default: -> false
		getFunc: 'GlowingEyebrows'
		type: 'BOOLEAN'
	}

	'eyebrows_glow_strength': {
		default: -> 1
		getFunc: 'EyebrowsGlowStrength'
		type: 'FLOAT'
		min: 0
		max: 1
	}

	'hide_manes': {
		default: -> true
		getFunc: 'HideManes'
		type: 'BOOLEAN'
	}

	'hide_manes_socks': {
		default: -> true
		getFunc: 'HideManesSocks'
		type: 'BOOLEAN'
	}

	'hide_manes_mane': {
		default: -> true
		getFunc: 'HideManesMane'
		type: 'BOOLEAN'
	}

	'hide_manes_tail': {
		default: -> true
		getFunc: 'HideManesTail'
		type: 'BOOLEAN'
	}

	'horn_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'HornColor'
		type: 'COLOR'
	}

	'wings_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'WingsColor'
		type: 'COLOR'
	}

	'separate_wings': {
		default: -> false
		getFunc: 'SeparateWings'
		type: 'BOOLEAN'
	}

	'separate_horn': {
		default: -> false
		getFunc: 'SeparateHorn'
		type: 'BOOLEAN'
	}

	'separate_magic_color': {
		default: -> false
		getFunc: 'SeparateMagicColor'
		type: 'BOOLEAN'
	}

	'horn_magic_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'HornMagicColor'
		type: 'COLOR'
	}

	'horn_glow': {
		default: -> false
		getFunc: 'HornGlow'
		type: 'BOOLEAN'
	}

	'horn_glow_strength': {
		default: -> 1
		getFunc: 'HornGlowSrength'
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'horn_detail_color': {
		default: -> Color(90, 90, 90)
		getFunc: 'HornDetailColor'
		type: 'COLOR'
	}

	'separate_eyes': {
		default: -> false
		getFunc: 'SeparateEyes'
		type: 'BOOLEAN'
	}

	'separate_mane': {
		default: -> false
		getFunc: 'SeparateMane'
		type: 'BOOLEAN'
	}

	'socks': {
		default: -> false
		getFunc: 'Socks'
		type: 'BOOLEAN'
	}

	'new_male_muzzle': {
		default: -> true
		getFunc: 'NewMuzzle'
		type: 'BOOLEAN'
	}

	'noflex': {
		default: -> false
		getFunc: 'NoFlex'
		type: 'BOOLEAN'
	}

	'socks_model': {
		default: -> false
		getFunc: 'SocksAsModel'
		type: 'BOOLEAN'
	}

	'socks_model_new': {
		default: -> false
		getFunc: 'SocksAsNewModel'
		type: 'BOOLEAN'
	}

	'socks_model_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'SocksColor'
		type: 'COLOR'
	}

	'socks_new_model_color1': {
		default: -> Color(255, 255, 255)
		getFunc: 'NewSocksColor1'
		type: 'COLOR'
	}

	'socks_new_model_color2': {
		default: -> Color(0, 0, 0)
		getFunc: 'NewSocksColor2'
		type: 'COLOR'
	}

	'socks_new_model_color3': {
		default: -> Color(0, 0, 0)
		getFunc: 'NewSocksColor3'
		type: 'COLOR'
	}

	'socks_new_texture_url': {
		default: -> ''
		getFunc: 'NewSocksTextureURL'
		type: 'URL'
	}

	'suit': {
		default: -> 0
		getFunc: 'Bodysuit'
		enum: [arg for arg in *PPM2.AvaliablePonySuits]
	}

	'left_wing_size': {
		default: -> 1
		getFunc: 'LWingSize'
		min: PPM2.MIN_WING
		max: PPM2.MAX_WING
		type: 'FLOAT'
	}

	'left_wing_x': {
		default: -> 0
		getFunc: 'LWingX'
		min: PPM2.MIN_WINGX
		max: PPM2.MAX_WINGX
		type: 'FLOAT'
	}

	'left_wing_y': {
		default: -> 0
		getFunc: 'LWingY'
		min: PPM2.MIN_WINGY
		max: PPM2.MAX_WINGY
		type: 'FLOAT'
	}

	'left_wing_z': {
		default: -> 0
		getFunc: 'LWingZ'
		min: PPM2.MIN_WINGZ
		max: PPM2.MAX_WINGZ
		type: 'FLOAT'
	}

	'right_wing_size': {
		default: -> 1
		getFunc: 'RWingSize'
		min: PPM2.MIN_WING
		max: PPM2.MAX_WING
		type: 'FLOAT'
	}

	'right_wing_x': {
		default: -> 0
		getFunc: 'RWingX'
		min: PPM2.MIN_WINGX
		max: PPM2.MAX_WINGX
		type: 'FLOAT'
	}

	'right_wing_y': {
		default: -> 0
		getFunc: 'RWingY'
		min: PPM2.MIN_WINGY
		max: PPM2.MAX_WINGY
		type: 'FLOAT'
	}

	'right_wing_z': {
		default: -> 0
		getFunc: 'RWingZ'
		min: PPM2.MIN_WINGZ
		max: PPM2.MAX_WINGZ
		type: 'FLOAT'
	}

	'teeth_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'TeethColor'
		type: 'COLOR'
	}

	'mouth_color': {
		default: -> Color(219, 65, 155)
		getFunc: 'MouthColor'
		type: 'COLOR'
	}

	'tongue_color': {
		default: -> Color(235, 131, 59)
		getFunc: 'TongueColor'
		type: 'COLOR'
	}

	'bat_wing_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'BatWingColor'
		type: 'COLOR'
	}

	'bat_wing_skin_color': {
		default: -> Color(255, 255, 255)
		getFunc: 'BatWingSkinColor'
		type: 'COLOR'
	}

	'separate_horn_phong': {
		default: -> false
		getFunc: 'SeparateHornPhong'
		type: 'BOOLEAN'
	}

	'separate_wings_phong': {
		default: -> false
		getFunc: 'SeparateWingsPhong'
		type: 'BOOLEAN'
	}

	'separate_mane_phong': {
		default: -> false
		getFunc: 'SeparateManePhong'
		type: 'BOOLEAN'
	}

	'separate_tail_phong': {
		default: -> false
		getFunc: 'SeparateTailPhong'
		type: 'BOOLEAN'
	}

	'alternative_fangs': {
		default: -> false
		getFunc: 'AlternativeFangs'
		type: 'BOOLEAN'
	}

	'hoof_fluffers': {
		default: -> false
		getFunc: 'HoofFluffers'
		type: 'BOOLEAN'
	}

	'hoof_fluffers_strength': {
		default: -> 1
		getFunc: 'HoofFluffersStrength'
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'ears_size': {
		default: -> 1
		getFunc: 'EarsSize'
		min: 0.1
		max: 2
		type: 'FLOAT'
	}

	'bat_pony_ears_strength': {
		default: -> 1
		getFunc: 'BatPonyEarsStrength'
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'fangs_strength': {
		default: -> 1
		getFunc: 'FangsStrength'
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'clawteeth_strength': {
		default: -> 1
		getFunc: 'ClawTeethStrength'
		min: 0
		max: 1
		type: 'FLOAT'
	}

	'lips_color_inherit': {
		default: -> true
		getFunc: 'LipsColorInherit'
		type: 'BOOLEAN'
	}

	'nose_color_inherit': {
		default: -> true
		getFunc: 'NoseColorInherit'
		type: 'BOOLEAN'
	}

	'lips_color': {
		default: -> Color(172, 92, 92)
		getFunc: 'LipsColor'
		type: 'COLOR'
	}

	'nose_color': {
		default: -> Color(77, 84, 83)
		getFunc: 'NoseColor'
		type: 'COLOR'
	}

	'weapon_hide': {
		default: -> true
		getFunc: 'HideWeapons'
		type: 'BOOLEAN'
	}
}

for {internal, publicName} in *{{'_left', 'Left'}, {'_right', 'Right'}, {'', ''}}
	PPM2.PonyDataRegistry["eye_url#{internal}"] = {
		default: -> ''
		getFunc: "EyeURL#{publicName}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["eye_bg#{internal}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "EyeBackground#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_hole#{internal}"] = {
		default: -> Color(0, 0, 0)
		getFunc: "EyeHole#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_iris1#{internal}"] = {
		default: -> Color(200, 200, 200)
		getFunc: "EyeIrisTop#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_iris2#{internal}"] = {
		default: -> Color(200, 200, 200)
		getFunc: "EyeIrisBottom#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_irisline1#{internal}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "EyeIrisLine1#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_irisline_direction#{internal}"] = {
		default: -> false
		getFunc: "EyeLineDirection#{publicName}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["eye_irisline2#{internal}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "EyeIrisLine2#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_reflection#{internal}"] = {
		default: -> Color(255, 255, 255, 127)
		getFunc: "EyeReflection#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_effect#{internal}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "EyeEffect#{publicName}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["eye_lines#{internal}"] = {
		default: -> true
		getFunc: "EyeLines#{publicName}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["eye_iris_size#{internal}"] = {
		default: -> 1
		getFunc: "IrisSize#{publicName}"
		min: PPM2.MIN_IRIS
		max: PPM2.MAX_IRIS
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["eye_derp#{internal}"] = {
		default: -> false
		getFunc: "DerpEyes#{publicName}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["eye_use_refract#{internal}"] = {
		default: -> false
		getFunc: "EyeRefract#{publicName}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["eye_cornera#{internal}"] = {
		default: -> false
		getFunc: "EyeCornerA#{publicName}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["eye_derp_strength#{internal}"] = {
		default: -> 1
		getFunc: "DerpEyesStrength#{publicName}"
		min: PPM2.MIN_DERP_STRENGTH
		max: PPM2.MAX_DERP_STRENGTH
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["eye_type#{internal}"] = {
		default: -> 0
		getFunc: "EyeType#{publicName}"
		enum: [arg for arg in *PPM2.AvaliableEyeTypes]
	}

	PPM2.PonyDataRegistry["eye_reflection_type#{internal}"] = {
		default: -> 0
		getFunc: "EyeReflectionType#{publicName}"
		enum: [arg for arg in *PPM2.AvaliableEyeReflections]
	}

	PPM2.PonyDataRegistry["hole_width#{internal}"] = {
		default: -> 1
		getFunc: "HoleWidth#{publicName}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["hole_height#{internal}"] = {
		default: -> 1
		getFunc: "HoleHeight#{publicName}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["iris_width#{internal}"] = {
		default: -> 1
		getFunc: "IrisWidth#{publicName}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["iris_height#{internal}"] = {
		default: -> 1
		getFunc: "IrisHeight#{publicName}"
		min: PPM2.MIN_PUPIL_SIZE
		max: PPM2.MAX_PUPIL_SIZE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["eye_glossy_reflection#{internal}"] = {
		default: -> 0.16
		getFunc: "EyeGlossyStrength#{publicName}"
		min: 0
		max: 1
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["hole_shiftx#{internal}"] = {
		default: -> 0
		getFunc: "HoleShiftX#{publicName}"
		min: PPM2.MIN_HOLE_SHIFT
		max: PPM2.MAX_HOLE_SHIFT
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["hole_shifty#{internal}"] = {
		default: -> 0
		getFunc: "HoleShiftY#{publicName}"
		min: PPM2.MIN_HOLE_SHIFT
		max: PPM2.MAX_HOLE_SHIFT
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["eye_hole_size#{internal}"] = {
		default: -> .8
		getFunc: "HoleSize#{publicName}"
		min: PPM2.MIN_HOLE
		max: PPM2.MAX_HOLE
		type: 'FLOAT'
		modifiers: true
	}

	PPM2.PonyDataRegistry["eye_rotation#{internal}"] = {
		default: -> 0
		getFunc: "EyeRotation#{publicName}"
		min: PPM2.MIN_EYE_ROTATION
		max: PPM2.MAX_EYE_ROTATION
		type: 'INT'
	}

for i = 1, 3
	PPM2.PonyDataRegistry["horn_url_#{i}"] = {
		default: -> ''
		getFunc: "HornURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["bat_wing_url_#{i}"] = {
		default: -> ''
		getFunc: "BatWingURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["bat_wing_skin_url_#{i}"] = {
		default: -> ''
		getFunc: "BatWingSkinURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["wings_url_#{i}"] = {
		default: -> ''
		getFunc: "WingsURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["horn_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "HornURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["bat_wing_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "BatWingURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["bat_wing_skin_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "BatWingSkinURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["wings_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "WingsURLColor#{i}"
		type: 'COLOR'
	}

for i = 1, 6
	PPM2.PonyDataRegistry["socks_detail_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "SocksDetailColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["mane_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "ManeColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["mane_detail_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "ManeDetailColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["mane_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "ManeURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["mane_url_#{i}"] = {
		default: -> ''
		getFunc: "ManeURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["tail_detail_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "TailDetailColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["tail_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "TailURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["tail_url_#{i}"] = {
		default: -> ''
		getFunc: "TailURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["tail_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "TailColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["lower_mane_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "LowerManeColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["lower_mane_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "LowerManeURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["lower_mane_url_#{i}"] = {
		default: -> ''
		getFunc: "LowerManeURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["upper_mane_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "UpperManeColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["upper_mane_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "UpperManeURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["upper_mane_url_#{i}"] = {
		default: -> ''
		getFunc: "UpperManeURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["lower_mane_detail_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "LowerManeDetailColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["upper_mane_detail_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "UpperManeDetailColor#{i}"
		type: 'COLOR'
	}

for i = 1, PPM2.MAX_BODY_DETAILS
	PPM2.PonyDataRegistry["body_detail_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "BodyDetailColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["body_detail_#{i}"] = {
		default: -> 0
		getFunc: "BodyDetail#{i}"
		enum: [arg for arg in *PPM2.BodyDetailsEnum]
	}

	PPM2.PonyDataRegistry["body_detail_url_#{i}"] = {
		default: -> ''
		getFunc: "BodyDetailURL#{i}"
		type: 'URL'
	}

	PPM2.PonyDataRegistry["body_detail_url_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "BodyDetailURLColor#{i}"
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry["body_detail_glow_#{i}"] = {
		default: -> false
		getFunc: "BodyDetailGlow#{i}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["body_detail_glow_strength_#{i}"] = {
		default: -> 1
		getFunc: "BodyDetailGlowStrength#{i}"
		type: 'FLOAT'
		min: 0
		max: 1
	}

for i = 1, PPM2.MAX_TATTOOS
	PPM2.PonyDataRegistry["tattoo_type_#{i}"] = {
		default: -> 0
		getFunc: "TattooType#{i}"
		enum: [arg for arg in *PPM2.TATTOOS_REGISTRY]
	}

	PPM2.PonyDataRegistry["tattoo_posx_#{i}"] = {
		default: -> 0
		getFunc: "TattooPosX#{i}"
		min: -100
		max: 100
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["tattoo_posy_#{i}"] = {
		default: -> 0
		getFunc: "TattooPosY#{i}"
		fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, -100, 100)
		min: -100
		max: 100
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["tattoo_rotate_#{i}"] = {
		default: -> 0
		getFunc: "TattooRotate#{i}"
		min: -180
		max: 180
		type: 'INT'
	}

	PPM2.PonyDataRegistry["tattoo_scalex_#{i}"] = {
		default: -> 1
		getFunc: "TattooScaleX#{i}"
		min: 0
		max: 10
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["tattoo_glow_strength_#{i}"] = {
		default: -> 1
		getFunc: "TattooGlowStrength#{i}"
		min: 0
		max: 1
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["tattoo_scaley_#{i}"] = {
		default: -> 1
		getFunc: "TattooScaleY#{i}"
		min: 0
		max: 10
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry["tattoo_glow_#{i}"] = {
		default: -> false
		getFunc: "TattooGlow#{i}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["tattoo_over_detail_#{i}"] = {
		default: -> false
		getFunc: "TattooOverDetail#{i}"
		type: 'BOOLEAN'
	}

	PPM2.PonyDataRegistry["tattoo_color_#{i}"] = {
		default: -> Color(255, 255, 255)
		getFunc: "TattooColor#{i}"
		type: 'COLOR'
	}

for ttype in *{'Body', 'Horn', 'Wings', 'BatWingsSkin', 'Socks', 'Mane', 'Tail', 'UpperMane', 'LowerMane', 'LEye', 'REye', 'BEyes', 'Eyelashes', 'Mouth', 'Teeth', 'Tongue'}
	PPM2.PonyDataRegistry[ttype\lower() .. '_phong_exponent'] = {
		default: -> 3
		getFunc: ttype .. 'PhongExponent'
		min: 0.04
		max: 10
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_phong_boost'] = {
		default: -> 0.09
		getFunc: ttype .. 'PhongBoost'
		min: 0.01
		max: 1
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_phong_front'] = {
		default: -> 1
		getFunc: ttype .. 'PhongFront'
		min: 0
		max: 20
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_phong_middle'] = {
		default: -> 5
		getFunc: ttype .. 'PhongMiddle'
		min: 0
		max: 20
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_phong_sliding'] = {
		default: -> 10
		getFunc: ttype .. 'PhongSliding'
		min: 0
		max: 20
		type: 'FLOAT'
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_phong_tint'] = {
		default: -> Color(255, 200, 200)
		getFunc: ttype .. 'PhongTint'
		type: 'COLOR'
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_lightwarp_texture'] = {
		default: -> 0
		getFunc: ttype .. 'Lightwarp'
		enum: [arg for arg in *PPM2.AvaliableLightwarps]
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_lightwarp_texture_url'] = {
		default: -> ''
		getFunc: ttype .. 'LightwarpURL'
		type: 'URL'
	}

	PPM2.PonyDataRegistry[ttype\lower() .. '_bumpmap_texture_url'] = {
		default: -> ''
		getFunc: ttype .. 'BumpmapURL'
		type: 'URL'
	}

for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
	continue if not active
	PPM2.PonyDataRegistry["flex_disable_#{flex\lower()}"] = {
		default: -> false
		getFunc: "DisableFlex#{flex}"
		type: 'BOOLEAN'
	}

testMinimalBits = 0

for key, value in pairs PPM2.PonyDataRegistry
	if value.enum
		value.min = 0
		value.max = #value.enum - 1
		value.type = 'INT'

	switch value.type
		when 'INT'
			error("Variable #{key} has invalid minimal value (#{type(value.min)})") if type(value.min) ~= 'number'
			error("Variable #{max} has invalid maximal value (#{type(value.max)})") if type(value.max) ~= 'number'
			value.fix = INT_FIXER(value.default, value.min, value.max)
			if value.min >= 0
				selectBits = net.ChooseOptimalBits(value.max - value.min)
				testMinimalBits += selectBits
				value.read = rUInt(selectBits, value.min, value.max)
				value.write = wUInt(value.default(), selectBits)
			else
				selectBits = net.ChooseOptimalBits(math.max(math.abs(value.max), math.abs(value.min)))
				testMinimalBits += selectBits
				value.read = rInt(selectBits, value.min, value.max)
				value.write = wInt(value.default(), selectBits)
		when 'FLOAT'
			error("Variable #{key} has invalid minimal value (#{type(value.min)})") if type(value.min) ~= 'number'
			error("Variable #{max} has invalid maximal value (#{type(value.max)})") if type(value.max) ~= 'number'
			value.fix = FLOAT_FIXER(value.default, value.min, value.max)
			value.read = rFloat(value.min, value.max)
			value.write = (arg = value.default()) -> wFloat(arg)
			testMinimalBits += 32
		when 'URL'
			value.fix = URL_FIXER
			value.read = rURL
			value.write = wString
			testMinimalBits += 8
		when 'BOOLEAN'
			value.fix = (arg = value.default()) -> tobool(arg)
			value.read = rBool
			value.write = wBool
			testMinimalBits += 1
		when 'COLOR'
			{:r, :g, :b, :a} = value.default()
			value.fix = COLOR_FIXER(r, g, b, a)
			value.read = rColor
			value.write = wColor
			testMinimalBits += 32
		else
			error("Unknown variable type - #{value.type} for #{key}")

-- print('Minimal required bits - ' .. testMinimalBits)
PPM2.testMinimalBits = testMinimalBits

for key, value in pairs PPM2.PonyDataRegistry
	error("Data has no fix function: #{key}") if not value.fix
