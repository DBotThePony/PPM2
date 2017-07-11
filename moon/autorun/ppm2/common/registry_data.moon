
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

FLOAT_FIXER = (def = 1, min = 0, max = 1) ->
    return (arg = def) -> math.Clamp(tonumber(arg) or def, min, max)

PPM2.PonyDataRegistry = {
    'age': {
        default: -> PPM2.AGE_ADULT
        getFunc: 'Age'
        enum: {'FILLY', 'ADULT', 'MATURE'}
        fix: (arg = PPM2.AGE_ADULT) -> math.Clamp(tonumber(arg) or PPM2.AGE_ADULT, 0, 2)
        min: 0
        max: 2
    }
    
    'race': {
        default: -> PPM2.RACE_EARTH
        getFunc: 'Race'
        enum: [arg for arg in *PPM2.RACE_ENUMS]
        fix: (arg = PPM2.RACE_EARTH) -> math.Clamp(tonumber(arg) or PPM2.RACE_EARTH, 0, 3)
        min: 0
        max: 3
    }
    
    'wings_type': {
        default: -> 0
        getFunc: 'WingsType'
        enum: [arg for arg in *PPM2.AvaliablePonyWings]
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_WINGS, PPM2.MAX_WINGS)
        min: PPM2.MIN_WINGS
        max: PPM2.MAX_WINGS
    }

    'gender': {
        default: -> PPM2.GENDER_FEMALE
        getFunc: 'Gender'
        enum: [arg for arg in *PPM2.AGE_ENUMS]
        fix: (arg = PPM2.GENDER_FEMALE) -> math.Clamp(tonumber(arg) or PPM2.GENDER_FEMALE, 0, 1)
        min: 0
        max: 1
    }

    'weight': {
        default: -> 1
        getFunc: 'Weight'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_WEIGHT, PPM2.MAX_WEIGHT)
        min: PPM2.MIN_WEIGHT
        max: PPM2.MAX_WEIGHT
    }

    'ponysize': {
        default: -> 1
        getFunc: 'PonySize'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_SCALE, PPM2.MAX_SCALE)
        min: PPM2.MIN_SCALE
        max: PPM2.MAX_SCALE
    }

    'necksize': {
        default: -> 1
        getFunc: 'NeckSize'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_NECK, PPM2.MAX_NECK)
        min: PPM2.MIN_NECK
        max: PPM2.MAX_NECK
    }

    'legssize': {
        default: -> 1
        getFunc: 'LegsSize'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_LEGS, PPM2.MAX_LEGS)
        min: PPM2.MIN_LEGS
        max: PPM2.MAX_LEGS
    }

    'male_buff': {
        default: -> PPM2.DEFAULT_MALE_BUFF
        getFunc: 'MaleBuff'
        fix: (arg = PPM2.DEFAULT_MALE_BUFF) -> math.Clamp(tonumber(arg) or PPM2.DEFAULT_MALE_BUFF, PPM2.MIN_MALE_BUFF, PPM2.MAX_MALE_BUFF)
        min: PPM2.MIN_MALE_BUFF
        max: PPM2.MAX_MALE_BUFF
    }

    'eyelash': {
        default: -> 0
        getFunc: 'EyelashType'
        enum: [arg for arg in *PPM2.EyelashTypes]
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_EYELASHES, PPM2.MAX_EYELASHES)
        min: PPM2.MIN_EYELASHES
        max: PPM2.MAX_EYELASHES
    }
    
    'tail': {
        default: -> 0
        getFunc: 'TailType'
        enum: [arg for arg in *PPM2.AvaliableTails] -- fast copy
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_TAILS, PPM2.MAX_TAILS)
        min: PPM2.MIN_TAILS
        max: PPM2.MAX_TAILS
    }
    
    'tail_new': {
        default: -> 0
        getFunc: 'TailTypeNew'
        enum: [arg for arg in *PPM2.AvaliableTailsNew] -- fast copy
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_TAILS_NEW, PPM2.MAX_TAILS_NEW)
        min: PPM2.MIN_TAILS_NEW
        max: PPM2.MAX_TAILS_NEW
    }

    'mane': {
        default: -> 0
        getFunc: 'ManeType'
        enum: [arg for arg in *PPM2.AvaliableUpperManes] -- fast copy
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_UPPER_MANES, PPM2.MAX_UPPER_MANES)
        min: PPM2.MIN_UPPER_MANES
        max: PPM2.MAX_UPPER_MANES
    }

    'mane_new': {
        default: -> 0
        getFunc: 'ManeTypeNew'
        enum: [arg for arg in *PPM2.AvaliableUpperManesNew] -- fast copy
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_UPPER_MANES_NEW, PPM2.MAX_UPPER_MANES_NEW)
        min: PPM2.MIN_UPPER_MANES_NEW
        max: PPM2.MAX_UPPER_MANES_NEW
    }

    'manelower': {
        default: -> 0
        getFunc: 'ManeTypeLower'
        enum: [arg for arg in *PPM2.AvaliableLowerManes] -- fast copy
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_LOWER_MANES, PPM2.MAX_LOWER_MANES)
        min: PPM2.MIN_LOWER_MANES
        max: PPM2.MAX_LOWER_MANES
    }

    'manelower_new': {
        default: -> 0
        getFunc: 'ManeTypeLowerNew'
        enum: [arg for arg in *PPM2.AvaliableLowerManesNew] -- fast copy
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_LOWER_MANES_NEW, PPM2.MAX_LOWER_MANES_NEW)
        min: PPM2.MIN_LOWER_MANES_NEW
        max: PPM2.MAX_LOWER_MANES_NEW
    }

    'socks_texture': {
        default: -> 0
        getFunc: 'SocksTexture'
        enum: [arg for arg in *PPM2.SocksTypes] -- fast copy
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_SOCKS, PPM2.MAX_SOCKS)
        min: PPM2.MIN_SOCKS
        max: PPM2.MAX_SOCKS
    }

    'socks_texture_url': {
        default: -> ''
        getFunc: 'SocksTextureURL'
        fix: URL_FIXER
    }

    'tailsize': {
        default: -> 1
        getFunc: 'TailSize'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE)
        min: PPM2.MIN_TAIL_SIZE
        max: PPM2.MAX_TAIL_SIZE
    }

    'cmark': {
        default: -> true
        getFunc: 'CMark'
        fix: (arg = true) -> tobool(arg)
    }

    'cmark_size': {
        default: -> 1
        getFunc: 'CMarkSize'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, 0, 1)
        min: 0
        max: 1
    }

    'cmark_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'CMarkColor'
        fix: COLOR_FIXER()
    }

    'fangs': {
        default: -> false
        getFunc: 'Fangs'
        fix: (arg = false) -> tobool(arg)
    }

    'bat_pony_ears': {
        default: -> false
        getFunc: 'BatPonyEars'
        fix: (arg = false) -> tobool(arg)
    }

    'claw_teeth': {
        default: -> false
        getFunc: 'ClawTeeth'
        fix: (arg = false) -> tobool(arg)
    }

    'cmark_type': {
        default: -> 4
        getFunc: 'CMarkType'
        enum: [arg for arg in *PPM2.DefaultCutiemarks]
        fix: (arg = 4) -> math.Clamp(tonumber(arg) or 4, PPM2.MIN_CMARK, PPM2.MAX_CMARK)
        min: PPM2.MIN_CMARK
        max: PPM2.MAX_CMARK
    }

    'cmark_url': {
        default: -> ''
        getFunc: 'CMarkURL'
        fix: URL_FIXER
    }

    'body': {
        default: -> Color(255, 255, 255)
        getFunc: 'BodyColor'
        fix: COLOR_FIXER()
    }

    'horn_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'HornColor'
        fix: COLOR_FIXER()
    }

    'wings_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'WingsColor'
        fix: COLOR_FIXER()
    }

    'separate_wings': {
        default: -> false
        getFunc: 'SeparateWings'
        fix: (arg = false) -> tobool(arg)
    }

    'separate_horn': {
        default: -> false
        getFunc: 'SeparateHorn'
        fix: (arg = false) -> tobool(arg)
    }

    'use_horn_detail': {
        default: -> false
        getFunc: 'UseHornDetail'
        fix: (arg = false) -> tobool(arg)
    }

    'horn_glow': {
        default: -> false
        getFunc: 'HornGlow'
        fix: (arg = false) -> tobool(arg)
    }

    'horn_glow_strength': {
        default: -> 1
        getFunc: 'HornGlowSrength'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 0, 0, 1)
        min: 0
        max: 1
    }

    'horn_detail_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'HornDetailColor'
        fix: COLOR_FIXER()
    }

    'separate_eyes': {
        default: -> false
        getFunc: 'SeparateEyes'
        fix: (arg = false) -> tobool(arg)
    }

    'separate_mane': {
        default: -> false
        getFunc: 'SeparateMane'
        fix: (arg = false) -> tobool(arg)
    }

    'socks': {
        default: -> false
        getFunc: 'Socks'
        fix: (arg = false) -> tobool(arg)
    }

    'new_male_muzzle': {
        default: -> true
        getFunc: 'NewMuzzle'
        fix: (arg = true) -> tobool(arg)
    }

    'noflex': {
        default: -> false
        getFunc: 'NoFlex'
        fix: (arg = false) -> tobool(arg)
    }

    'socks_model': {
        default: -> false
        getFunc: 'SocksAsModel'
        fix: (arg = false) -> tobool(arg)
    }

    'socks_model_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'SocksColor'
        fix: COLOR_FIXER()
    }

    'suit': {
        default: -> 0
        getFunc: 'Bodysuit'
        enum: [arg for arg in *PPM2.AvaliablePonySuits]
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_SUIT, PPM2.MAX_SUIT)
        min: PPM2.MIN_SUIT
        max: PPM2.MAX_SUIT
    }

    'left_wing_size': {
        default: -> 1
        getFunc: 'LWingSize'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_WING, PPM2.MAX_WING)
        min: PPM2.MIN_WING
        max: PPM2.MAX_WING
    }

    'left_wing_x': {
        default: -> 0
        getFunc: 'LWingX'
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_WINGX, PPM2.MAX_WINGX)
        min: PPM2.MIN_WINGX
        max: PPM2.MAX_WINGX
    }

    'left_wing_y': {
        default: -> 0
        getFunc: 'LWingY'
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_WINGY, PPM2.MAX_WINGY)
        min: PPM2.MIN_WINGY
        max: PPM2.MAX_WINGY
    }

    'left_wing_z': {
        default: -> 0
        getFunc: 'LWingZ'
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_WINGZ, PPM2.MAX_WINGZ)
        min: PPM2.MIN_WINGZ
        max: PPM2.MAX_WINGZ
    }

    'right_wing_size': {
        default: -> 1
        getFunc: 'RWingSize'
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_WING, PPM2.MAX_WING)
        min: PPM2.MIN_WING
        max: PPM2.MAX_WING
    }

    'right_wing_x': {
        default: -> 0
        getFunc: 'RWingX'
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_WINGX, PPM2.MAX_WINGX)
        min: PPM2.MIN_WINGX
        max: PPM2.MAX_WINGX
    }

    'right_wing_y': {
        default: -> 0
        getFunc: 'RWingY'
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_WINGY, PPM2.MAX_WINGY)
        min: PPM2.MIN_WINGY
        max: PPM2.MAX_WINGY
    }

    'right_wing_z': {
        default: -> 0
        getFunc: 'RWingZ'
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_WINGZ, PPM2.MAX_WINGZ)
        min: PPM2.MIN_WINGZ
        max: PPM2.MAX_WINGZ
    }

    'teeth_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'TeethColor'
        fix: COLOR_FIXER()
    }

    'mouth_color': {
        default: -> Color(219, 65, 155)
        getFunc: 'MouthColor'
        fix: COLOR_FIXER(219, 65, 155)
    }

    'tongue_color': {
        default: -> Color(235, 131, 59)
        getFunc: 'TongueColor'
        fix: COLOR_FIXER(235, 131, 59)
    }

    'bat_wing_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'BatWingColor'
        fix: COLOR_FIXER()
    }

    'bat_wing_skin_color': {
        default: -> Color(255, 255, 255)
        getFunc: 'BatWingSkinColor'
        fix: COLOR_FIXER()
    }

    'separate_horn_phong': {
        default: -> false
        getFunc: 'SeparateHornPhong'
        fix: (arg = false) -> tobool(arg)
    }

    'separate_wings_phong': {
        default: -> false
        getFunc: 'SeparateWingsPhong'
        fix: (arg = false) -> tobool(arg)
    }

    'separate_mane_phong': {
        default: -> false
        getFunc: 'SeparateManePhong'
        fix: (arg = false) -> tobool(arg)
    }

    'separate_tail_phong': {
        default: -> false
        getFunc: 'SeparateTailPhong'
        fix: (arg = false) -> tobool(arg)
    }

    'alternative_fangs': {
        default: -> false
        getFunc: 'AlternativeFangs'
        fix: (arg = false) -> tobool(arg)
    }

    'hoof_fluffers': {
        default: -> false
        getFunc: 'HoofFluffers'
        fix: (arg = false) -> tobool(arg)
    }

    'hoof_fluffers_strength': {
        default: -> 1
        getFunc: 'HoofFluffersStrength'
        fix: FLOAT_FIXER(1)
        min: 0
        max: 1
    }

    'ears_size': {
        default: -> 1
        getFunc: 'EarsSize'
        fix: FLOAT_FIXER(1, 0.1, 2)
        min: 0.1
        max: 2
    }

    'bat_pony_ears_strength': {
        default: -> 1
        getFunc: 'BatPonyEarsStrength'
        fix: FLOAT_FIXER(1)
        min: 0
        max: 1
    }

    'fangs_strength': {
        default: -> 1
        getFunc: 'FangsStrength'
        fix: FLOAT_FIXER(1)
        min: 0
        max: 1
    }

    'clawteeth_strength': {
        default: -> 1
        getFunc: 'ClawTeethStrength'
        fix: FLOAT_FIXER(1)
        min: 0
        max: 1
    }
}

for {internal, publicName} in *{{'_left', 'Left'}, {'_right', 'Right'}, {'', ''}}
    PPM2.PonyDataRegistry["eye_url#{internal}"] = {
        default: -> ''
        getFunc: "EyeURL#{publicName}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["eye_bg#{internal}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "EyeBackground#{publicName}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["eye_hole#{internal}"] = {
        default: -> Color(0, 0, 0)
        getFunc: "EyeHole#{publicName}"
        fix: COLOR_FIXER(0, 0, 0)
    }

    PPM2.PonyDataRegistry["eye_iris1#{internal}"] = {
        default: -> Color(200, 200, 200)
        getFunc: "EyeIrisTop#{publicName}"
        fix: COLOR_FIXER(200, 200, 200)
    }

    PPM2.PonyDataRegistry["eye_iris2#{internal}"] = {
        default: -> Color(200, 200, 200)
        getFunc: "EyeIrisBottom#{publicName}"
        fix: COLOR_FIXER(200, 200, 200)
    }

    PPM2.PonyDataRegistry["eye_irisline1#{internal}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "EyeIrisLine1#{publicName}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["eye_irisline2#{internal}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "EyeIrisLine2#{publicName}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["eye_reflection#{internal}"] = {
        default: -> Color(255, 255, 255, 127)
        getFunc: "EyeReflection#{publicName}"
        fix: COLOR_FIXER(255, 255, 255, 127)
    }

    PPM2.PonyDataRegistry["eye_effect#{internal}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "EyeEffect#{publicName}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["eye_lines#{internal}"] = {
        default: -> true
        getFunc: "EyeLines#{publicName}"
        fix: (arg = true) -> tobool(arg)
    }

    PPM2.PonyDataRegistry["eye_iris_size#{internal}"] = {
        default: -> 1
        getFunc: "IrisSize#{publicName}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_IRIS, PPM2.MAX_IRIS)
        min: PPM2.MIN_IRIS
        max: PPM2.MAX_IRIS
    }

    PPM2.PonyDataRegistry["eye_derp#{internal}"] = {
        default: -> false
        getFunc: "DerpEyes#{publicName}"
        fix: (arg = true) -> tobool(arg)
    }

    PPM2.PonyDataRegistry["eye_derp_strength#{internal}"] = {
        default: -> 1
        getFunc: "DerpEyesStrength#{publicName}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_DERP_STRENGTH, PPM2.MAX_DERP_STRENGTH)
        min: PPM2.MIN_DERP_STRENGTH
        max: PPM2.MAX_DERP_STRENGTH
    }

    PPM2.PonyDataRegistry["eye_type#{internal}"] = {
        default: -> 0
        getFunc: "EyeType#{publicName}"
        enum: [arg for arg in *PPM2.AvaliableEyeTypes]
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_EYE_TYPE, PPM2.MAX_EYE_TYPE)
        min: PPM2.MIN_EYE_TYPE
        max: PPM2.MAX_EYE_TYPE
    }

    PPM2.PonyDataRegistry["hole_width#{internal}"] = {
        default: -> 1
        getFunc: "HoleWidth#{publicName}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
        min: PPM2.MIN_PUPIL_SIZE
        max: PPM2.MAX_PUPIL_SIZE
    }

    PPM2.PonyDataRegistry["hole_height#{internal}"] = {
        default: -> 1
        getFunc: "HoleHeight#{publicName}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
        min: PPM2.MIN_PUPIL_SIZE
        max: PPM2.MAX_PUPIL_SIZE
    }

    PPM2.PonyDataRegistry["iris_width#{internal}"] = {
        default: -> 1
        getFunc: "IrisWidth#{publicName}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
        min: PPM2.MIN_PUPIL_SIZE
        max: PPM2.MAX_PUPIL_SIZE
    }

    PPM2.PonyDataRegistry["iris_height#{internal}"] = {
        default: -> 1
        getFunc: "IrisHeight#{publicName}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
        min: PPM2.MIN_PUPIL_SIZE
        max: PPM2.MAX_PUPIL_SIZE
    }

    PPM2.PonyDataRegistry["hole_shiftx#{internal}"] = {
        default: -> 0
        getFunc: "HoleShiftX#{publicName}"
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_HOLE_SHIFT, PPM2.MAX_HOLE_SHIFT)
        min: PPM2.MIN_HOLE_SHIFT
        max: PPM2.MAX_HOLE_SHIFT
    }

    PPM2.PonyDataRegistry["hole_shifty#{internal}"] = {
        default: -> 0
        getFunc: "HoleShiftY#{publicName}"
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_HOLE_SHIFT, PPM2.MAX_HOLE_SHIFT)
        min: PPM2.MIN_HOLE_SHIFT
        max: PPM2.MAX_HOLE_SHIFT
    }

    PPM2.PonyDataRegistry["eye_hole_size#{internal}"] = {
        default: -> .8
        getFunc: "HoleSize#{publicName}"
        fix: (arg = .8) -> math.Clamp(tonumber(arg) or .8, PPM2.MIN_HOLE, PPM2.MAX_HOLE)
        min: PPM2.MIN_HOLE
        max: PPM2.MAX_HOLE
    }

    PPM2.PonyDataRegistry["eye_rotation#{internal}"] = {
        default: -> 0
        getFunc: "EyeRotation#{publicName}"
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_EYE_ROTATION, PPM2.MAX_EYE_ROTATION)
        min: PPM2.MIN_EYE_ROTATION
        max: PPM2.MAX_EYE_ROTATION
    }

for i = 1, 3
    PPM2.PonyDataRegistry["horn_url_#{i}"] = {
        default: -> ''
        getFunc: "HornURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["bat_wing_url_#{i}"] = {
        default: -> ''
        getFunc: "BatWingURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["bat_wing_skin_url_#{i}"] = {
        default: -> ''
        getFunc: "BatWingSkinURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["wings_url_#{i}"] = {
        default: -> ''
        getFunc: "WingsURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["horn_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "HornURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["bat_wing_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "BatWingURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["bat_wing_skin_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "BatWingSkinURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["wings_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "WingsURLColor#{i}"
        fix: COLOR_FIXER()
    }

for i = 1, 6
    PPM2.PonyDataRegistry["socks_detail_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "SocksDetailColor#{i}"
        fix: COLOR_FIXER()
    }
    
    PPM2.PonyDataRegistry["mane_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "ManeColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["mane_detail_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "ManeDetailColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["mane_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "ManeURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["mane_url_#{i}"] = {
        default: -> ''
        getFunc: "ManeURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["tail_detail_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "TailDetailColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["tail_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "TailURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["tail_url_#{i}"] = {
        default: -> ''
        getFunc: "TailURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["tail_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "TailColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["lower_mane_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "LowerManeColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["lower_mane_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "LowerManeURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["lower_mane_url_#{i}"] = {
        default: -> ''
        getFunc: "LowerManeURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["upper_mane_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "UpperManeColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["upper_mane_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "UpperManeURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["upper_mane_url_#{i}"] = {
        default: -> ''
        getFunc: "UpperManeURL#{i}"
        fix: URL_FIXER
    }

    PPM2.PonyDataRegistry["lower_mane_detail_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "LowerManeDetailColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["upper_mane_detail_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "UpperManeDetailColor#{i}"
        fix: COLOR_FIXER()
    }

for i = 1, PPM2.MAX_BODY_DETAILS
    PPM2.PonyDataRegistry["body_detail_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "BodyDetailColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["body_detail_#{i}"] = {
        default: -> 0
        getFunc: "BodyDetail#{i}"
        enum: [arg for arg in *PPM2.BodyDetailsEnum]
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_DETAIL, PPM2.MAX_DETAIL)
        min: PPM2.MIN_DETAIL
        max: PPM2.MAX_DETAIL
    }

    PPM2.PonyDataRegistry["body_detail_url_#{i}"] = {
        default: -> ''
        getFunc: "BodyDetailURL#{i}"
        fix: (arg = '') ->
            arg = tostring(arg)
            if arg\find('^https?://')
                return arg
            else
                return ''
    }

    PPM2.PonyDataRegistry["body_detail_url_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "BodyDetailURLColor#{i}"
        fix: COLOR_FIXER()
    }

    PPM2.PonyDataRegistry["body_detail_glow_#{i}"] = {
        default: -> false
        getFunc: "BodyDetailGlow#{i}"
        fix: (arg = false) -> tobool(arg)
    }

    PPM2.PonyDataRegistry["body_detail_glow_strength_#{i}"] = {
        default: -> 1
        getFunc: "BodyDetailGlowStrength#{i}"
        fix: FLOAT_FIXER(1, 0, 1)
        min: 0
        max: 1
    }

for i = 1, PPM2.MAX_TATTOOS
    PPM2.PonyDataRegistry["tattoo_type_#{i}"] = {
        default: -> 0
        getFunc: "TattooType#{i}"
        enum: [arg for arg in *PPM2.TATTOOS_REGISTRY]
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, 0, PPM2.MAX_TATTOOS)
        min: 0
        max: PPM2.MAX_TATTOOS
    }
    
    PPM2.PonyDataRegistry["tattoo_posx_#{i}"] = {
        default: -> 0
        getFunc: "TattooPosX#{i}"
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, -100, 100)
        min: -100
        max: 100
    }
    
    PPM2.PonyDataRegistry["tattoo_posy_#{i}"] = {
        default: -> 0
        getFunc: "TattooPosY#{i}"
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, -100, 100)
        min: -100
        max: 100
    }
    
    PPM2.PonyDataRegistry["tattoo_rotate_#{i}"] = {
        default: -> 0
        getFunc: "TattooRotate#{i}"
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, -180, 180)
        min: -180
        max: 180
    }
    
    PPM2.PonyDataRegistry["tattoo_scalex_#{i}"] = {
        default: -> 1
        getFunc: "TattooScaleX#{i}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, 0, 10)
        min: 0
        max: 10
    }
    
    PPM2.PonyDataRegistry["tattoo_glow_strength_#{i}"] = {
        default: -> 1
        getFunc: "TattooGlowStrength#{i}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, 0, 1)
        min: 0
        max: 1
    }
    
    PPM2.PonyDataRegistry["tattoo_scaley_#{i}"] = {
        default: -> 1
        getFunc: "TattooScaleY#{i}"
        fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, 0, 10)
        min: 0
        max: 10
    }
    
    PPM2.PonyDataRegistry["tattoo_glow_#{i}"] = {
        default: -> false
        getFunc: "TattooGlow#{i}"
        fix: (arg = false) -> tobool(arg)
    }
    
    PPM2.PonyDataRegistry["tattoo_over_detail_#{i}"] = {
        default: -> false
        getFunc: "TattooOverDetail#{i}"
        fix: (arg = false) -> tobool(arg)
    }
    
    PPM2.PonyDataRegistry["tattoo_color_#{i}"] = {
        default: -> Color(255, 255, 255)
        getFunc: "TattooColor#{i}"
        fix: COLOR_FIXER()
    }

for ttype in *{'Body', 'Horn', 'Wings', 'BatWingsSkin', 'Socks', 'Mane', 'Tail', 'UpperMane', 'LowerMane'}
    PPM2.PonyDataRegistry[ttype\lower() .. '_phong_exponent'] = {
        default: -> 3
        getFunc: ttype .. 'PhongExponent'
        fix: FLOAT_FIXER(3, 0.04, 10)
        min: 0.04
        max: 10
    }
    
    PPM2.PonyDataRegistry[ttype\lower() .. '_phong_boost'] = {
        default: -> 0.09
        getFunc: ttype .. 'PhongBoost'
        fix: FLOAT_FIXER(0.09, 0.01, 1)
        min: 0.01
        max: 1
    }
    
    PPM2.PonyDataRegistry[ttype\lower() .. '_phong_front'] = {
        default: -> 1
        getFunc: ttype .. 'PhongFront'
        fix: FLOAT_FIXER(1, 0, 20)
        min: 0
        max: 20
    }
    
    PPM2.PonyDataRegistry[ttype\lower() .. '_phong_middle'] = {
        default: -> 5
        getFunc: ttype .. 'PhongMiddle'
        fix: FLOAT_FIXER(5, 0, 20)
        min: 0
        max: 20
    }
    
    PPM2.PonyDataRegistry[ttype\lower() .. '_phong_sliding'] = {
        default: -> 10
        getFunc: ttype .. 'PhongSliding'
        fix: FLOAT_FIXER(10, 0, 20)
        min: 0
        max: 20
    }
    
    PPM2.PonyDataRegistry[ttype\lower() .. '_phong_tint'] = {
        default: -> Color(255, 200, 200)
        getFunc: ttype .. 'PhongTint'
        fix: COLOR_FIXER(255, 200, 200)
    }

    PPM2.PonyDataRegistry[ttype\lower() .. '_lightwarp_texture'] = {
        default: -> 0
        getFunc: ttype .. 'Lightwarp'
        enum: [arg for arg in *PPM2.AvaliableLightwarps]
        fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, 0, PPM2.MAX_LIGHTWARP)
        min: 0
        max: PPM2.MAX_LIGHTWARP
    }
    
    PPM2.PonyDataRegistry[ttype\lower() .. '_lightwarp_texture_url'] = {
        default: -> ''
        getFunc: ttype .. 'LightwarpURL'
        fix: URL_FIXER
    }

for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
    continue if not active
    PPM2.PonyDataRegistry["flex_disable_#{flex\lower()}"] = {
        default: -> false
        getFunc: "DisableFlex#{flex}"
        fix: (arg = false) -> tobool(arg)
    }
