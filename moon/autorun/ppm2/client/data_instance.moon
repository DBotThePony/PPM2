
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

class PonyDataInstance
    @DATA_DIR = "ppm2/"
    @DATA_DIR_BACKUP = "ppm2/backups/"
    @PONY_DATA = {
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
            default: -> 1
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

        'tailsize': {
            default: -> 1
            getFunc: 'TailSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE)
            min: PPM2.MIN_TAIL_SIZE
            max: PPM2.MAX_TAIL_SIZE
        }

        'eye_iris_size': {
            default: -> 1
            getFunc: 'IrisSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_IRIS, PPM2.MAX_IRIS)
            min: PPM2.MIN_IRIS
            max: PPM2.MAX_IRIS
        }

        'hole_width': {
            default: -> 1
            getFunc: 'HoleWidth'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
            min: PPM2.MIN_PUPIL_SIZE
            max: PPM2.MAX_PUPIL_SIZE
        }

        'eye_hole_size': {
            default: -> .8
            getFunc: 'HoleSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or .8, PPM2.MIN_HOLE, PPM2.MAX_HOLE)
            min: PPM2.MIN_HOLE
            max: PPM2.MAX_HOLE
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

        'eye_url': {
            default: -> ''
            getFunc: 'EyeURL'
            fix: URL_FIXER
        }

        'eye_derp': {
            default: -> false
            getFunc: 'DerpEyes'
            fix: (arg = true) -> tobool(arg)
        }

        'eye_derp_strength': {
            default: -> 1
            getFunc: 'DerpEyesStrength'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_DERP_STRENGTH, PPM2.MAX_DERP_STRENGTH)
            min: PPM2.MIN_DERP_STRENGTH
            max: PPM2.MAX_DERP_STRENGTH
        }

        'eye_type': {
            default: -> 0
            getFunc: 'EyeType'
            enum: [arg for arg in *PPM2.AvaliableEyeTypes]
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_EYE_TYPE, PPM2.MAX_EYE_TYPE)
            min: PPM2.MIN_EYE_TYPE
            max: PPM2.MAX_EYE_TYPE
        }

        'eye_bg': {
            default: -> Color(255, 255, 255)
            getFunc: 'EyeBackground'
            fix: COLOR_FIXER()
        }

        'eye_hole': {
            default: -> Color(0, 0, 0)
            getFunc: 'EyeHole'
            fix: COLOR_FIXER(0, 0, 0)
        }

        'eye_iris1': {
            default: -> Color(200, 200, 200)
            getFunc: 'EyeIrisTop'
            fix: COLOR_FIXER(200, 200, 200)
        }

        'eye_iris2': {
            default: -> Color(200, 200, 200)
            getFunc: 'EyeIrisBottom'
            fix: COLOR_FIXER(200, 200, 200)
        }

        'eye_irisline1': {
            default: -> Color(255, 255, 255)
            getFunc: 'EyeIrisLine1'
            fix: COLOR_FIXER()
        }

        'eye_irisline2': {
            default: -> Color(255, 255, 255)
            getFunc: 'EyeIrisLine2'
            fix: COLOR_FIXER()
        }

        'eye_reflection': {
            default: -> Color(255, 255, 255, 127)
            getFunc: 'EyeReflection'
            fix: COLOR_FIXER(255, 255, 255, 127)
        }

        'eye_effect': {
            default: -> Color(255, 255, 255)
            getFunc: 'EyeEffect'
            fix: COLOR_FIXER()
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

        'eye_lines': {
            default: -> true
            getFunc: 'EyeLines'
            fix: (arg = true) -> tobool(arg)
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

        'pac3_bones': {
            default: -> false
            getFunc: 'PAC3Bones'
            fix: (arg = false) -> tobool(arg)
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
    }

    for {internal, publicName} in *{{'left', 'Left'}, {'right', 'Right'}}
        @PONY_DATA["eye_url_#{internal}"] = {
            default: -> ''
            getFunc: "EyeURL#{publicName}"
            fix: URL_FIXER
        }

        @PONY_DATA["eye_bg_#{internal}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "EyeBackground#{publicName}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["eye_hole_#{internal}"] = {
            default: -> Color(0, 0, 0)
            getFunc: "EyeHole#{publicName}"
            fix: COLOR_FIXER(0, 0, 0)
        }

        @PONY_DATA["eye_iris1_#{internal}"] = {
            default: -> Color(200, 200, 200)
            getFunc: "EyeIrisTop#{publicName}"
            fix: COLOR_FIXER(200, 200, 200)
        }

        @PONY_DATA["eye_iris2_#{internal}"] = {
            default: -> Color(200, 200, 200)
            getFunc: "EyeIrisBottom#{publicName}"
            fix: COLOR_FIXER(200, 200, 200)
        }

        @PONY_DATA["eye_irisline1_#{internal}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "EyeIrisLine1#{publicName}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["eye_irisline2_#{internal}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "EyeIrisLine2#{publicName}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["eye_reflection_#{internal}"] = {
            default: -> Color(255, 255, 255, 127)
            getFunc: "EyeReflection#{publicName}"
            fix: COLOR_FIXER(255, 255, 255, 127)
        }

        @PONY_DATA["eye_effect_#{internal}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "EyeEffect#{publicName}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["eye_lines_#{internal}"] = {
            default: -> true
            getFunc: "EyeLines#{publicName}"
            fix: (arg = true) -> tobool(arg)
        }

        @PONY_DATA["eye_iris_size_#{internal}"] = {
            default: -> 1
            getFunc: "IrisSize#{publicName}"
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_IRIS, PPM2.MAX_IRIS)
            min: PPM2.MIN_IRIS
            max: PPM2.MAX_IRIS
        }

        @PONY_DATA["eye_derp_#{internal}"] = {
            default: -> false
            getFunc: "DerpEyes#{publicName}"
            fix: (arg = true) -> tobool(arg)
        }

        @PONY_DATA["eye_derp_strength_#{internal}"] = {
            default: -> 1
            getFunc: "DerpEyesStrength#{publicName}"
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_DERP_STRENGTH, PPM2.MAX_DERP_STRENGTH)
            min: PPM2.MIN_DERP_STRENGTH
            max: PPM2.MAX_DERP_STRENGTH
        }

        @PONY_DATA["eye_type_#{internal}"] = {
            default: -> 0
            getFunc: "EyeType#{publicName}"
            enum: [arg for arg in *PPM2.AvaliableEyeTypes]
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_EYE_TYPE, PPM2.MAX_EYE_TYPE)
            min: PPM2.MIN_EYE_TYPE
            max: PPM2.MAX_EYE_TYPE
        }

        @PONY_DATA["hole_width_#{internal}"] = {
            default: -> 1
            getFunc: "HoleWidth#{publicName}"
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
            min: PPM2.MIN_PUPIL_SIZE
            max: PPM2.MAX_PUPIL_SIZE
        }

        @PONY_DATA["eye_hole_size#{internal}"] = {
            default: -> .8
            getFunc: "HoleSize#{publicName}"
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or .8, PPM2.MIN_HOLE, PPM2.MAX_HOLE)
            min: PPM2.MIN_HOLE
            max: PPM2.MAX_HOLE
        }

    for i = 1, 3
        @PONY_DATA["horn_url_#{i}"] = {
            default: -> ''
            getFunc: "HornURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["bat_wing_url_#{i}"] = {
            default: -> ''
            getFunc: "BatWingURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["bat_wing_skin_url_#{i}"] = {
            default: -> ''
            getFunc: "BatWingSkinURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["wings_url_#{i}"] = {
            default: -> ''
            getFunc: "WingsURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["horn_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "HornURLColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["bat_wing_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "BatWingURLColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["bat_wing_skin_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "BatWingSkinURLColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["wings_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "WingsURLColor#{i}"
            fix: COLOR_FIXER()
        }

    for i = 1, 6
        @PONY_DATA["mane_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "ManeColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["mane_detail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "ManeDetailColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["mane_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "ManeURLColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["mane_url_#{i}"] = {
            default: -> ''
            getFunc: "ManeURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["tail_detail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "TailDetailColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["tail_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "TailURLColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["tail_url_#{i}"] = {
            default: -> ''
            getFunc: "TailURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["tail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "TailColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["lower_mane_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "LowerManeColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["lower_mane_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "LowerManeURLColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["lower_mane_url_#{i}"] = {
            default: -> ''
            getFunc: "LowerManeURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["upper_mane_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "UpperManeColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["upper_mane_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "UpperManeURLColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["upper_mane_url_#{i}"] = {
            default: -> ''
            getFunc: "UpperManeURL#{i}"
            fix: URL_FIXER
        }

        @PONY_DATA["lower_mane_detail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "LowerManeDetailColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["upper_mane_detail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "UpperManeDetailColor#{i}"
            fix: COLOR_FIXER()
        }
    
    for i = 1, PPM2.MAX_BODY_DETAILS
        @PONY_DATA["body_detail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "BodyDetailColor#{i}"
            fix: COLOR_FIXER()
        }

        @PONY_DATA["body_detail_#{i}"] = {
            default: -> 0
            getFunc: "BodyDetail#{i}"
            enum: [arg for arg in *PPM2.BodyDetailsEnum]
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_DETAIL, PPM2.MAX_DETAIL)
            min: PPM2.MIN_DETAIL
            max: PPM2.MAX_DETAIL
        }

        @PONY_DATA["body_detail_url_#{i}"] = {
            default: -> ''
            getFunc: "BodyDetailURL#{i}"
            fix: (arg = '') ->
                arg = tostring(arg)
                if arg\find('^https?://')
                    return arg
                else
                    return ''
        }

        @PONY_DATA["body_detail_url_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "BodyDetailURLColor#{i}"
            fix: COLOR_FIXER()
        }

    for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
        continue if not active
        @PONY_DATA["flex_disable_#{flex\lower()}"] = {
            default: -> false
            getFunc: "DisableFlex#{flex}"
            fix: (arg = false) -> tobool(arg)
        }
    
    @PONY_DATA_MAPPING = {getFunc\lower(), key for key, {:getFunc} in pairs @PONY_DATA}
    @PONY_DATA_MAPPING[key] = key for key, value in pairs @PONY_DATA

    for key, data in pairs @PONY_DATA
        continue unless data.enum
        data.enum = [arg\upper() for arg in *data.enum]
        data.enumMapping = {}
        data.enumMappingBackward = {}
        i = -1
        for enumVal in *data.enum
            i += 1
            data.enumMapping[i] = enumVal
            data.enumMappingBackward[enumVal] = i
    for key, {:getFunc, :fix, :enumMappingBackward, :enumMapping, :enum, :min, :max} in pairs @PONY_DATA
        @__base["Get#{getFunc}"] = => @dataTable[key]
        @__base["GetMin#{getFunc}"] = => min if min
        @__base["GetMax#{getFunc}"] = => max if max
        @__base["Enum#{getFunc}"] = => enum if enum
        @__base["Get#{getFunc}Types"] = => enum if enum

        @["GetMin#{getFunc}"] = => min if min
        @["GetMax#{getFunc}"] = => max if max
        @["GetEnum#{getFunc}"] = => enum if enum
        @["Enum#{getFunc}"] = => enum if enum

        if enumMapping
            @__base["Get#{getFunc}Enum"] = => enumMapping[@dataTable[key]] or enumMapping[0] or @dataTable[key]
            @__base["GetEnum#{getFunc}"] = @__base["Get#{getFunc}Enum"]
		@__base["Set#{getFunc}"] = (val = defValue, ...) =>
            if type(val) == 'string' and enumMappingBackward
                newVal = enumMappingBackward[val\upper()]
                val = newVal if newVal
            newVal = fix(val)
			oldVal = @dataTable[key]
			@dataTable[key] = newVal
            @ValueChanges(key, oldVal, newVal, ...)

    Copy: (fileName = @filename) =>
        copyOfData = {}
        for key, val in pairs @dataTable
            switch type(val)
                when 'number'
                    copyOfData[key] = val
                when 'string'
                    copyOfData[key] = val
                when 'boolean'
                    copyOfData[key] = val
                when 'table'
                    {:r, :g, :b} = val
                    if r and g and b
                        copyOfData[key] = Color(r, g, b)
        newData = @@(fileName, copyOfData, false)
        return newData
    CreateCustomNetworkObject: (ply = LocalPlayer(), ...) =>
        newData = PPM2.NetworkedPonyData(nil, ply)
        newData\SetEntity(ply)
        @ApplyDataToObject(newData, ...)
        return newData
    CreateNetworkObject: (gointToNetwork = true, ...) =>
        newData = PPM2.NetworkedPonyData(nil, LocalPlayer())
        newData\SetIsGoingToNetwork(gointToNetwork)
        newData\SetEntity(LocalPlayer())
        @ApplyDataToObject(newData, ...)
        return newData
    ApplyDataToObject: (target, ...) =>
        for key, value in pairs @GetAsNetworked()
            target["Set#{key}"](target, value, ...)
    UpdateController: (...) => @ApplyDataToObject(@nwObj, ...)
    CreateController: (...) => @CreateNetworkObject(false, ...)
    CreateCustomController: (...) => @CreateCustomNetworkObject(false, ...)

    new: (filename, data, readIfExists = true, force = false, doBackup = true) =>
        @SetFilename(filename)
        @valid = @isOpen
        @rawData = data
        @dataTable = {k, default() for k, {:default} in pairs @@PONY_DATA}
        @saveOnChange = true
        if data
            @SetupData(data, true)
        elseif @exists and readIfExists
            @ReadFromDisk(force, doBackup)
    
    @ERR_MISSING_PARAMETER = 4
    @ERR_MISSING_CONTENT = 5

    GetSaveOnChange: => @saveOnChange
    SaveOnChange: => @saveOnChange
    SetSaveOnChange: (val = true) => @saveOnChange = val
    SetupData: (data, force = false, doBackup = false) =>
        if doBackup or not force
            makeBackup = false
            for key, value in pairs data
                key = key\lower()
                map = @@PONY_DATA_MAPPING[key]
                if not map
                    return @@ERR_MISSING_PARAMETER if not force
                    makeBackup = true
                    break
                mapData = @@PONY_DATA[map]
                if mapData.enum
                    if type(value) == 'string' and not mapData.enumMappingBackward[value\upper()] or type(value) == 'number' and not mapData.enumMapping[value]
                        return @@ERR_MISSING_CONTENT if not force
                        makeBackup = true
                        break
            if doBackup and makeBackup and @exists
                bkName = "#{@@DATA_DIR_BACKUP}#{@filename}_bak_#{os.date('%S_%M_%H-%d_%m_%Y', os.time())}.txt"
                fRead = file.Read(@fpath, 'DATA')
                file.Write(bkName, fRead)
        
        for key, value in pairs data
            key = key\lower()
            map = @@PONY_DATA_MAPPING[key]
            continue unless map
            mapData = @@PONY_DATA[map]
            if mapData.enum and type(value) == 'string'
                @dataTable[key] = mapData.fix(mapData.enumMappingBackward[value\upper()])
            else
                @dataTable[key] = mapData.fix(value)
    ValueChanges: (key, oldVal, newVal, saveNow = @exists and @saveOnChange) =>
        if @nwObj
            {:getFunc} = @@PONY_DATA[key]
            @nwObj["Set#{getFunc}"](@nwObj, newVal)
        @Save() if saveNow
    SetFilename: (filename) =>
        @filename = filename
        @filenameFull = "#{filename}.txt"
        @fpath = "#{@@DATA_DIR}#{filename}.txt"
        @fpathBackup = "#{@@DATA_DIR}#{filename}.bak.txt"
        @fpathFull = "data/#{@@DATA_DIR}#{filename}.txt"
        @isOpen = @filename ~= nil
        @exists = file.Exists(@fpath, 'DATA')
        return @exists
    SetNetworkData: (nwObj) => @nwObj = nwObj
    SetPonyData: (nwObj) => @nwObj = nwObj
    SetPonyDataController: (nwObj) => @nwObj = nwObj
    SetPonyController: (nwObj) => @nwObj = nwObj
    SetController: (nwObj) => @nwObj = nwObj
    SetDataController: (nwObj) => @nwObj = nwObj

    GetNetworkData: => @nwObj
    GetPonyData: => @nwObj
    GetPonyDataController: => @nwObj
    GetPonyController: => @nwObj
    GetController: => @nwObj
    GetDataController: => @nwObj

    IsValid: => @valid
    Exists: => @exists
    FileExists: => @exists
    IsExists: => @exists
    GetFileName: => @filename
    GetFilename: => @filename
    GetFileNameFull: => @filenameFull
    GetFilenameFull: => @filenameFull
    GetFilePath: => @fpath
    GetFullFilePath: => @fpathFull
    SerealizeValue: (valID = '') =>
        map = @@PONY_DATA[valID]
        return unless map
        val = @dataTable[valID]
        if map.enum
            return map.enumMapping[val] or map.enumMapping[map.default()]
        elseif map.serealize
            return map.serealize(val)
        else
            return val
    Serealize: (prettyPrint = true) =>
        serTab = {key, @SerealizeValue(key) for key, val in pairs @dataTable}
        util.TableToJSON(serTab, prettyPrint)
    GetAsNetworked: => {getFunc, @dataTable[k] for k, {:getFunc} in pairs @@PONY_DATA}

    @READ_SUCCESS = 0
    @ERR_FILE_NOT_EXISTS = 1
    @ERR_FILE_EMPTY = 2
    @ERR_FILE_CORRUPT = 3
    ReadFromDisk: (force = false, doBackup = true) =>
        return @@ERR_FILE_NOT_EXISTS unless @exists
        fRead = file.Read(@fpath, 'DATA')
        return @@ERR_FILE_EMPTY if not fRead or fRead == ''
        readTable = util.JSONToTable(fRead)
        return @@ERR_FILE_CORRUPT unless readTable
        return @SetupData(readTable, force, doBackup) or @@READ_SUCCESS
    SaveAs: (path = @fpath) =>
        fCreate = @Serealize()
        file.Write(path, fCreate)
    Save: (doBackup = true) =>
        if doBackup and @exists
            fRead = file.Read(@fpath, 'DATA')
            file.Write(@fpathBackup, fRead)
        @SaveAs(@fpath)
        @exists = true

do
    PARSE_VECTOR = (str = '1.0 1.0 1.0', X = 1, Y = 1, Z = 1) ->
        return Vector(X, Y, Z) if str == ''
        x, y, z = str\match('([0-9.]+) ([0-9.]+) ([0-9.]+)')
        return Vector(tonumber(x) or X, tonumber(y) or Y, tonumber(z) or Z)

    PARSE_COLOR = (str = '1.0 1.0 1.0', r = 255, g = 255, b = 255) ->
        return Color(r, g, b) if str == ''
        {x, y, z} = PARSE_VECTOR(str, r / 255, g / 255, b / 255)
        return Color(x * 255, y * 255, z * 255)
    
    IMPORT_TABLE = {
        'gender': {
            name: 'Gender'
            func: (arg = 0) ->
                num = tonumber(arg)
                return num == 0 and 'MALE' or 'FEMALE'
        }

        'coatcolor': {
            name: 'BodyColor'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_bg': {
            name: 'EyeBackground'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_grad': {
            name: 'EyeIrisBottom'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_iris': {
            name: 'EyeIrisTop'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_line1': {
            name: 'EyeIrisLine1'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_line2': {
            name: 'EyeIrisLine2'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'haircolor1': {
            name: {'ManeColor1', 'TailColor1'}
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'haircolor2': {
            name: {'ManeColor2', 'TailColor2'}
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyejholerssize': {
            name: 'HoleWidth'
            func: (arg = '1') -> tonumber(arg) or 1
        }

        'eyeirissize': {
            name: 'IrisSize'
            func: (arg = '1') -> tonumber(arg) or 1
        }

        'eyeholesize': {
            name: 'HoleSize'
            func: (arg = '0.8') -> tonumber(arg) or 0.8
        }

        'bodyweight': {
            name: 'Weight'
            func: (arg = 1) -> tonumber(arg) or 1
        }

        'mane': {
            name: {'ManeType', 'ManeTypeNew'}
            func: (arg = 0) -> (tonumber(arg) or 0) - 1
        }

        'manel': {
            name: {'ManeTypeLower', 'ManeTypeLowerNew'}
            func: (arg = 0) -> (tonumber(arg) or 0) - 1
        }

        'tail': {
            name: {'TailType', 'TailTypeNew'}
            func: (arg = 0) -> (tonumber(arg) or 0) - 1
        }

        'tailsize': {
            name: 'TailSize'
            func: (arg = 1) -> tonumber(arg) or 1
        }

        'cmark': {
            name: 'CMarkType'
            func: (arg = 1) -> (tonumber(arg) or 1) - 1
        }

        'cmark_enabled': {
            name: 'CMark'
            func: (arg = '1') -> arg == '1' or arg == '2'
        }
    }

    for i = 1, 8
        IMPORT_TABLE["bodydetail#{i}"] = {
            name: "BodyDetail#{i}"
            func: (arg = 1) -> (tonumber(arg) or 1) - 1
        }

        IMPORT_TABLE["bodydetail#{i}_c"] = {
            name: "BodyDetailColor#{i}"
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

    for i = 3, 6
        IMPORT_TABLE["haircolor#{i}"] = {
            name: {"ManeDetailColor#{i - 2}", "TailDetailColor#{i - 2}"}
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

    PPM2.ReadFromOldData = (filename = '_current') ->
        read = file.Read("ppm/#{filename}.txt", 'DATA')
        return false if read == ''
        split = [str\Trim() for str in *string.Explode('\n', read\Replace('\r', ''))]
        outputData = {}
        
        for line in *split
            varID = line\match('([a-zA-Z0-9_]+)')
            continue if not varID or varID == ''
            continue if not IMPORT_TABLE[varID]
            dt = IMPORT_TABLE[varID]
            value = line\sub(#varID + 2)
            if type(dt.name) ~= 'table'
                outputData[dt.name] = dt.func(value)
            else
                get = dt.func(value)
                outputData[name] = get for name in *dt.name
        
        data = PonyDataInstance("#{filename}_imported", nil, false)
        for key, value in pairs outputData
            data["Set#{key}"](data, value, false)
        return data, outputData

PPM2.PonyDataInstance = PonyDataInstance

PPM2.MainDataInstance = nil
PPM2.GetMainData = ->
    if not PPM2.MainDataInstance
        PPM2.MainDataInstance = PonyDataInstance('_current', nil, true, true)
        if not PPM2.MainDataInstance\FileExists()
            PPM2.MainDataInstance\Save()
    return PPM2.MainDataInstance
