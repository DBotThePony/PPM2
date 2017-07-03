
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

-- Texture indexes (-1)
-- 1    =   models/ppm/base/eye_l
-- 2    =   models/ppm/base/eye_r
-- 3    =   models/ppm/base/body
-- 4    =   models/ppm/base/horn
-- 5    =   models/ppm/base/wings
-- 6    =   models/ppm/base/hair_color_1
-- 7    =   models/ppm/base/hair_color_2
-- 8    =   models/ppm/base/tail_color_1
-- 9    =   models/ppm/base/tail_color_2
-- 10   =   models/ppm/base/cmark
-- 11   =   models/ppm/base/eyelashes

DrawTexturedRectRotated = (x = 0, y = 0, width = 0, height = 0, rotation = 0) -> surface.DrawTexturedRectRotated(x + width / 2, y + height / 2, width, height, rotation)

USE_HIGHRES_BODY = CreateConVar('ppm2_cl_hires_body', '0', {FCVAR_ACRHIVE}, 'Use high resoluation when rendering pony bodies. AFFECTS ONLY TEXTURE COMPILATION TIME (increases lag spike on pony data load)')
USE_HIGHRES_TEXTURES = CreateConVar('ppm2_cl_hires_generic', '0', {FCVAR_ACRHIVE}, 'Create 1024x1024 textures instead of 512x512 on texture compiling')

RELOADABLE_MATERIALS = {}

PPM2.BodyDetailsMaterials = {
    Material('models/ppm/partrender/body_leggrad1')
    Material('models/ppm/partrender/body_lines1')
    Material('models/ppm/partrender/body_stripes1')
    Material('models/ppm/partrender/body_headstripes1') 
    Material('models/ppm/partrender/body_freckles')
    Material('models/ppm/partrender/body_hooves1')
    Material('models/ppm/partrender/body_hooves2')
    Material('models/ppm/partrender/body_headmask1')
    Material('models/ppm/partrender/body_hooves1_crit')
    Material('models/ppm/partrender/body_hooves2_crit')
    Material('models/ppm/partrender/body_spots1')
    Material('models/ppm/partrender/body_robotic')
    Material('models/ppm/partrender/dash-e')
    Material('models/ppm/partrender/eye_scar')
    Material('models/ppm/partrender/eye_wound')
    Material('models/ppm/partrender/body_scar')
    Material('models/ppm/partrender/gear_socks')
    Material('models/ppm/partrender/sharp_hooves')
    Material('models/ppm/partrender/sharp_hooves2')
    Material('models/ppm/partrender/separated_muzzle')
    Material('models/ppm/partrender/eye_scar_left')
    Material('models/ppm/partrender/eye_scar_right')
}

PPM2.UpperManeDetailsMaterials = {
    [4]: {Material('models/ppm/partrender/upmane_5_mask0')}
    [5]: {Material('models/ppm/partrender/upmane_6_mask0')}
    [7]: {Material('models/ppm/partrender/upmane_8_mask0'), Material('models/ppm/partrender/upmane_8_mask1')}
    [8]: {Material('models/ppm/partrender/upmane_9_mask0'), Material('models/ppm/partrender/upmane_9_mask1'), Material('models/ppm/partrender/upmane_9_mask2')}
    [9]: {Material('models/ppm/partrender/upmane_10_mask0')}
    [10]: {Material('models/ppm/partrender/upmane_11_mask0'), Material('models/ppm/partrender/upmane_11_mask1'), Material('models/ppm/partrender/upmane_11_mask2')}
    [11]: {Material('models/ppm/partrender/upmane_12_mask0')}
    [12]: {Material('models/ppm/partrender/upmane_13_mask0')}
    [13]: {Material('models/ppm/partrender/upmane_14_mask0')}
    [14]: {Material('models/ppm/partrender/upmane_15_mask0')}
}

PPM2.DownManeDetailsMaterials = {
    [4]: {Material('models/ppm/partrender/dnmane_5_mask0')}
    [7]: {Material('models/ppm/partrender/dnmane_8_mask0'), Material('models/ppm/partrender/dnmane_8_mask1')}
    [8]: {Material('models/ppm/partrender/dnmane_9_mask0'), Material('models/ppm/partrender/dnmane_9_mask1')}
    [9]: {Material('models/ppm/partrender/dnmane_10_mask0'), Material('models/ppm/partrender/dnmane_10_mask1'), Material('models/ppm/partrender/dnmane_10_mask2')}
    [10]: {Material('models/ppm/partrender/dnmane_11_mask0'), Material('models/ppm/partrender/dnmane_11_mask1')}
    [11]: {Material('models/ppm/partrender/dnmane_12_mask0')}
}

PPM2.TailDetailsMaterials = {
    [4]: {Material('models/ppm/partrender/tail_5_mask0')}
    [7]: {Material('models/ppm/partrender/tail_8_mask0'), Material('models/ppm/partrender/tail_8_mask1'), Material('models/ppm/partrender/tail_8_mask2'), Material('models/ppm/partrender/tail_8_mask3'), Material('models/ppm/partrender/tail_8_mask4')}
    [9]: {Material('models/ppm/partrender/tail_10_mask0')}
    [10]: {Material('models/ppm/partrender/tail_11_mask0'), Material('models/ppm/partrender/tail_11_mask1'), Material('models/ppm/partrender/tail_11_mask2')}
    [11]: {Material('models/ppm/partrender/tail_12_mask0'), Material('models/ppm/partrender/tail_12_mask1')}
    [12]: {Material('models/ppm/partrender/tail_13_mask0')}
    [13]: {Material('models/ppm/partrender/tail_14_mask0')}
}

PPM2.SocksMaterials = {
    'models/props_pony/ppm/ppm_socks/socks_striped_unlit'
    'models/props_pony/ppm/ppm_socks/custom/geometric1_1'
    'models/props_pony/ppm/ppm_socks/custom/geometric2_1'
    'models/props_pony/ppm/ppm_socks/custom/geometric3_1'
    'models/props_pony/ppm/ppm_socks/custom/geometric4_1'
    'models/props_pony/ppm/ppm_socks/custom/geometric5_1'
    'models/props_pony/ppm/ppm_socks/custom/geometric6_1'
    'models/props_pony/ppm/ppm_socks/custom/geometric7_1'
    'models/props_pony/ppm/ppm_socks/custom/geometric8_1'
    'models/props_pony/ppm/ppm_socks/custom_textured/dark1'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers10'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers11'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers12'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers13'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers14'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers15'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers16'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers17'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers18'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers19'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers2'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers20'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers3'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers4'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers5'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers6'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers7'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers8'
    'models/props_pony/ppm/ppm_socks/custom_textured/flowers9'
    'models/props_pony/ppm/ppm_socks/custom_textured/grey1'
    'models/props_pony/ppm/ppm_socks/custom_textured/grey2'
    'models/props_pony/ppm/ppm_socks/custom_textured/grey3'
    'models/props_pony/ppm/ppm_socks/custom_textured/hearts1'
    'models/props_pony/ppm/ppm_socks/custom_textured/hearts2'
    'models/props_pony/ppm/ppm_socks/custom_textured/snow1'
    'models/props_pony/ppm/ppm_socks/custom_textured/wallpaper1'
    'models/props_pony/ppm/ppm_socks/custom_textured/wallpaper2'
    'models/props_pony/ppm/ppm_socks/custom_textured/wallpaper3'
}

PPM2.SocksMaterialsComp = [Material(id) for id in *PPM2.SocksMaterials]

PPM2.SocksDetails = {
    [2]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric1_4'
        'models/props_pony/ppm/ppm_socks/custom/geometric1_5'
        'models/props_pony/ppm/ppm_socks/custom/geometric1_6'
    }

    [3]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric2_3'
        'models/props_pony/ppm/ppm_socks/custom/geometric2_4'
    }

    [4]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric3_2'
        'models/props_pony/ppm/ppm_socks/custom/geometric3_3'
        'models/props_pony/ppm/ppm_socks/custom/geometric3_5'
    }

    [5]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric4_2'
        'models/props_pony/ppm/ppm_socks/custom/geometric4_3'
        'models/props_pony/ppm/ppm_socks/custom/geometric4_4'
    }

    [6]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric5_4'
        'models/props_pony/ppm/ppm_socks/custom/geometric5_5'
        'models/props_pony/ppm/ppm_socks/custom/geometric5_6'
    }

    [7]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric6_2'
        'models/props_pony/ppm/ppm_socks/custom/geometric6_3'
        'models/props_pony/ppm/ppm_socks/custom/geometric6_4'
    }

    [8]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric7_3'
        'models/props_pony/ppm/ppm_socks/custom/geometric7_4'
    }

    [9]: {
        'models/props_pony/ppm/ppm_socks/custom/geometric8_2'
        'models/props_pony/ppm/ppm_socks/custom/geometric8_3'
    }
}

PPM2.SocksDetailsComp = {i, [Material(mat) for mat in *data] for i, data in pairs PPM2.SocksDetails}
PPM2.DefaultCutiemarksMaterials = [CreateMaterial("PPM2_CMarkDraw_#{mark}", 'UnlitGeneric', {'$basetexture': "models/ppm/cmarks/#{mark}", '$ignorez': 1, '$vertexcolor': 1, '$vertexalpha': 1, '$nolod': 1}) for mark in *PPM2.DefaultCutiemarks]

table.insert(RELOADABLE_MATERIALS, mat) for mat in *PPM2.BodyDetailsMaterials when type(mat) ~= 'number'
table.insert(RELOADABLE_MATERIALS, mat) for i, data in pairs PPM2.UpperManeDetailsMaterials for mat in *data when type(mat) ~= 'number'
table.insert(RELOADABLE_MATERIALS, mat) for i, data in pairs PPM2.DownManeDetailsMaterials for mat in *data when type(mat) ~= 'number'
table.insert(RELOADABLE_MATERIALS, mat) for i, data in pairs PPM2.TailDetailsMaterials for mat in *data when type(mat) ~= 'number'
table.insert(RELOADABLE_MATERIALS, mat) for mat in *PPM2.SocksMaterialsComp when type(mat) ~= 'number'
table.insert(RELOADABLE_MATERIALS, mat) for mat in *PPM2.DefaultCutiemarksMaterials when type(mat) ~= 'number'
table.insert(RELOADABLE_MATERIALS, mat) for i, data in pairs PPM2.SocksDetailsComp for mat in *data when type(mat) ~= 'number'

PPM2.AvaliablePonySuitsMaterials = [Material("models/ppm/texclothes/#{mat}") for mat in *{
    'clothes_royalguard', 'clothes_sbs_full'
    'clothes_sbs_light', 'clothes_wbs_full'
    'clothes_wbs_light', 'spidermane_light'
    'spidermane_full'
}]

table.insert(RELOADABLE_MATERIALS, mat) for mat in *PPM2.AvaliablePonySuitsMaterials when type(mat) ~= 'number'

PPM2.ApplyMaterialData = (mat, matData) ->
    for k, v in pairs matData
        switch type(v)
            when 'string'
                mat\SetString(k, v)
            when 'number'
                mat\SetInt(k, v) if math.floor(v) == v
                mat\SetFloat(k, v) if math.floor(v) ~= v

class PonyTextureController
    @AVALIABLE_CONTROLLERS = {}
    @MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}
    @__inherited: (child) =>
        child.MODELS_HASH = {mod, true for mod in *child.MODELS}
        @AVALIABLE_CONTROLLERS[mod] = child for mod in *child.MODELS
    @__inherited(@)

    @UPPER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs PPM2.UpperManeDetailsMaterials}
    @LOWER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs PPM2.DownManeDetailsMaterials}
    @TAIL_DETAIL_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs PPM2.TailDetailsMaterials}

    @SessionID = math.random(1, 1000)

    @MAT_INDEX_EYE_LEFT = 0
    @MAT_INDEX_EYE_RIGHT = 1
    @MAT_INDEX_BODY = 2
    @MAT_INDEX_HORN = 3
    @MAT_INDEX_WINGS = 4
    @MAT_INDEX_HAIR_COLOR1 = 5
    @MAT_INDEX_HAIR_COLOR2 = 6
    @MAT_INDEX_TAIL_COLOR1 = 7
    @MAT_INDEX_TAIL_COLOR2 = 8
    @MAT_INDEX_CMARK = 9
    @MAT_INDEX_EYELASHES = 10

    @HAIR_MATERIAL_COLOR = CreateMaterial('PPM2.ManeTextureBase', 'UnlitGeneric', {
        '$basetexture': 'models/debug/debugwhite'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    table.insert(RELOADABLE_MATERIALS, @HAIR_MATERIAL_COLOR)

    @TAIL_MATERIAL_COLOR = CreateMaterial('PPM2.TailTextureBase', 'UnlitGeneric', {
        '$basetexture': 'models/debug/debugwhite'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    table.insert(RELOADABLE_MATERIALS, @TAIL_MATERIAL_COLOR)

    @WINGS_MATERIAL_COLOR = CreateMaterial('PPM2.WingsMaterialBase', 'UnlitGeneric', {
        '$basetexture': 'models/debug/debugwhite'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    table.insert(RELOADABLE_MATERIALS, @WINGS_MATERIAL_COLOR)

    @HORN_MATERIAL_COLOR = CreateMaterial('PPM2.HornMaterialBase', 'UnlitGeneric', {
        '$basetexture': 'models/ppm/base/horn'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    @HORN_DETAIL_COLOR = Material('models/ppm/base/horn_detail')

    @BODY_MATERIAL_MALE = CreateMaterial('PPM2.MaleDrawtexture', 'UnlitGeneric', {
        '$basetexture': 'models/ppm/base/bodym'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    @BODY_MATERIAL_FEMALE = CreateMaterial('PPM2.FemaleDrawtexture', 'UnlitGeneric', {
        '$basetexture': 'models/ppm/base/body'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    table.insert(RELOADABLE_MATERIALS, @HORN_MATERIAL_COLOR)
    table.insert(RELOADABLE_MATERIALS, @HORN_DETAIL_COLOR)

    @EYE_OVAL = Material('models/ppm/partrender/eye_oval')

    @EYE_OVALS = {
        Material('models/ppm/partrender/eye_oval')
        Material('models/ppm/partrender/eye_oval_aperture')
    }

    @EYE_GRAD = Material('models/ppm/partrender/eye_grad')
    @EYE_EFFECT = Material('models/ppm/partrender/eye_effect')
    @EYE_REFLECTION = Material('models/ppm/partrender/eye_reflection')

    @EYE_LINE_L_1 = Material('models/ppm/partrender/eye_line_l1')
    @EYE_LINE_R_1 = Material('models/ppm/partrender/eye_line_r1')

    @EYE_LINE_L_2 = Material('models/ppm/partrender/eye_line_l2')
    @EYE_LINE_R_2 = Material('models/ppm/partrender/eye_line_r2')

    @PONY_SOCKS = Material('models/ppm/texclothes/pony_socks')

    table.insert(RELOADABLE_MATERIALS, @EYE_GRAD)
    table.insert(RELOADABLE_MATERIALS, @EYE_EFFECT)
    table.insert(RELOADABLE_MATERIALS, @EYE_REFLECTION)
    table.insert(RELOADABLE_MATERIALS, @EYE_LINE_L_1)
    table.insert(RELOADABLE_MATERIALS, @EYE_LINE_R_1)
    table.insert(RELOADABLE_MATERIALS, @EYE_LINE_L_2)
    table.insert(RELOADABLE_MATERIALS, @EYE_LINE_R_2)
    table.insert(RELOADABLE_MATERIALS, @PONY_SOCKS)

    @NEXT_GENERATED_ID = 10000

    @MANE_UPDATE_TRIGGER = {'ManeType': true, 'ManeTypeLower': true}
    @TAIL_UPDATE_TRIGGER = {'TailType': true}
    @EYE_UPDATE_TRIGGER = {'SeparateEyes': true}
    @PHONG_UPDATE_TRIGGER = {}

    for ttype in *{'Body', 'Horn', 'Wings', 'BatWingsSkin', 'Socks'}
        @PHONG_UPDATE_TRIGGER[ttype .. 'PhongExponent'] = true
        @PHONG_UPDATE_TRIGGER[ttype .. 'PhongBoost'] = true
        @PHONG_UPDATE_TRIGGER[ttype .. 'PhongTint'] = true
        @PHONG_UPDATE_TRIGGER[ttype .. 'PhongFront'] = true
        @PHONG_UPDATE_TRIGGER[ttype .. 'PhongMiddle'] = true
        @PHONG_UPDATE_TRIGGER[ttype .. 'PhongSliding'] = true

    for publicName in *{'', 'Left', 'Right'}
        @EYE_UPDATE_TRIGGER["EyeType#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["HoleWidth#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["IrisSize#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeLines#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["HoleSize#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeBackground#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeIrisTop#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeIrisBottom#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeIrisLine1#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeIrisLine2#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeHole#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["DerpEyesStrength#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["DerpEyes#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeReflection#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeEffect#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeURL#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["IrisWidth#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["IrisHeight#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["HoleHeight#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["HoleShiftX#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["HoleShiftY#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["EyeRotation#{publicName}"] = true
        @EYE_UPDATE_TRIGGER["PonySize#{publicName}"] = true

    for i = 1, 6
        @MANE_UPDATE_TRIGGER["ManeColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["ManeDetailColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["ManeURLColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["ManeURL#{i}"] = true
        @MANE_UPDATE_TRIGGER["TailURL#{i}"] = true
        @MANE_UPDATE_TRIGGER["TailURLColor#{i}"] = true

        @TAIL_UPDATE_TRIGGER["TailColor#{i}"] = true
        @TAIL_UPDATE_TRIGGER["TailDetailColor#{i}"] = true
    
    @BODY_UPDATE_TRIGGER = {}
    for i = 1, PPM2.MAX_BODY_DETAILS
        @BODY_UPDATE_TRIGGER["BodyDetail#{i}"] = true
        @BODY_UPDATE_TRIGGER["BodyDetailColor#{i}"] = true
        @BODY_UPDATE_TRIGGER["BodyDetailURLColor#{i}"] = true
        @BODY_UPDATE_TRIGGER["BodyDetailURL#{i}"] = true
        @BODY_UPDATE_TRIGGER["BodyDetailGlow#{i}"] = true
        @BODY_UPDATE_TRIGGER["BodyDetailGlowStrength#{i}"] = true
    
    DelayCompile: (func = '', ...) =>
        return if not @[func]
        args = {...}
        for data in *@delayCompilation
            if data.func == func and #args == #data.args
                hit = false
                for i = 1, #args
                    if args[i] ~= data.args[i]
                        hit = true
                        break
                for i = 1, #data.args
                    if args[i] ~= data.args[i]
                        hit = true
                        break
                return if not hit
        
        table.insert(@delayCompilation, {:func, :args})
        timer.Create "#{@}_DelayCompile", 0, 1, ->
            return if not @IsValid()
            return if not IsValid(@ent)
            for data in *@delayCompilation
                @[data.func](@, unpack(data.args))
            @delayCompilation = {}
    
    DataChanges: (state) =>
        return unless @isValid
        return if not @ent
        key = state\GetKey()
        switch key
            when 'BodyColor'
                @DelayCompile('CompileBody')
                @DelayCompile('CompileWings')
                @DelayCompile('CompileHorn')
            when 'Socks', 'Bodysuit'
                @DelayCompile('CompileBody')
            when 'CMark', 'CMarkType', 'CMarkURL', 'CMarkColor', 'CMarkSize'
                @DelayCompile('CompileCMark')
            when 'SocksColor', 'SocksTextureURL', 'SocksTexture', 'SocksDetailColor1', 'SocksDetailColor2', 'SocksDetailColor3', 'SocksDetailColor4', 'SocksDetailColor5', 'SocksDetailColor6'
                @DelayCompile('CompileSocks')
            when 'HornURL1', 'SeparateHorn', 'HornColor', 'HornURL2', 'HornURL3', 'HornURLColor1', 'HornURLColor2', 'HornURLColor3', 'UseHornDetail', 'HornGlow', 'HornGlowSrength', 'HornDetailColor'
                @DelayCompile('CompileHorn')
            when 'WingsURL1', 'WingsURL2', 'WingsURL3', 'WingsURLColor1', 'WingsURLColor2', 'WingsURLColor3', 'SeparateWings', 'WingsColor'
                @DelayCompile('CompileWings')
            else
                if @@MANE_UPDATE_TRIGGER[key]
                    @DelayCompile('CompileHair')
                elseif @@TAIL_UPDATE_TRIGGER[key]
                    @DelayCompile('CompileTail')
                elseif @@EYE_UPDATE_TRIGGER[key]
                    @DelayCompile('CompileEye', true)
                    @DelayCompile('CompileEye', false)
                elseif @@BODY_UPDATE_TRIGGER[key]
                    @DelayCompile('CompileBody')
                elseif @@PHONG_UPDATE_TRIGGER[key]
                    @UpdatePhongData()
        
    @HTML_MATERIAL_QUEUE = {}
    @URL_MATERIAL_CACHE = {}
    @ALREADY_DOWNLOADING = {}
    @FAILED_TO_DOWNLOAD = {}
    @LoadURL: (url, width = @QUAD_SIZE_CONST, height = @QUAD_SIZE_CONST, callback = (->)) =>
        error('Must specify URL') if not url or url == ''
        @URL_MATERIAL_CACHE[width] = @URL_MATERIAL_CACHE[width] or {}
        @URL_MATERIAL_CACHE[width][height] = @URL_MATERIAL_CACHE[width][height] or {}
        @ALREADY_DOWNLOADING[width] = @ALREADY_DOWNLOADING[width] or {}
        @ALREADY_DOWNLOADING[width][height] = @ALREADY_DOWNLOADING[width][height] or {}
        @FAILED_TO_DOWNLOAD[width] = @FAILED_TO_DOWNLOAD[width] or {}
        @FAILED_TO_DOWNLOAD[width][height] = @FAILED_TO_DOWNLOAD[width][height] or {}
        if @FAILED_TO_DOWNLOAD[width][height][url]
            callback(@FAILED_TO_DOWNLOAD[width][height][url].texture, nil, @FAILED_TO_DOWNLOAD[width][height][url].material)
            return
        if @ALREADY_DOWNLOADING[width][height][url]
            for data in *@HTML_MATERIAL_QUEUE
                if data.url == url
                    table.insert(data.callbacks, callback)
                    break
            return
        if @URL_MATERIAL_CACHE[width][height][url]
            callback(@URL_MATERIAL_CACHE[width][height][url].texture, nil, @URL_MATERIAL_CACHE[width][height][url].material)
            return
        @ALREADY_DOWNLOADING[width][height][url] = true
        table.insert(@HTML_MATERIAL_QUEUE, {:url, :width, :height, callbacks: {callback}})
        --PPM2.Message 'Queuing to download ', url
    @BuildURLHTML = (url = 'https://dbot.serealia.ca/illuminati.jpg', width = @QUAD_SIZE_CONST, height = @QUAD_SIZE_CONST) =>
        url = url\Replace('%', '%25')\Replace(' ', '%20')\Replace('"', '%22')\Replace("'", '%27')\Replace('#', '%23')\Replace('<', '%3C')\Replace('=', '%3D')\Replace('>', '%3E')
        return "<html>
                    <head>
                        <style>
                            html, body {
                                background: transparent;
                                margin: 0;
                                padding: 0;
                                overflow: hidden;
                            }

                            #mainimage {
                                max-width: #{width};
                                height: auto;
                                width: 100%;
                                margin: 0;
                                padding: 0;
                                max-height: #{height};
                            }

                            #imgdiv {
                                width: #{width};
                                height: #{height};
                                overflow: hidden;
                                margin: 0;
                                padding: 0;
                                text-align: center;
                            }
                        </style>
                        <script>
                            window.onload = function() {
                                var img = document.getElementById('mainimage');
                                if (img.naturalWidth < img.naturalHeight) {
                                    img.style.setProperty('height', '100%');
                                    img.style.setProperty('width', 'auto');
                                }

                                img.style.setProperty('margin-top', (#{height} - img.height) / 2);
                                
                                setInterval(function() {
                                    console.log('FRAME');
                                }, 50);
                            };
                        </script>
                    </head>
                    <body>
                        <div id='imgdiv'>
                            <img src='#{url}' id='mainimage' />
                        </div>
                    </body>
                </html>"
    
    @SHOULD_WAIT_WEB = false
    hook.Add 'Think', 'PPM2.WebMaterialThink', ->
        return if @SHOULD_WAIT_WEB
        data = @HTML_MATERIAL_QUEUE[1]
        return if not data
        if IsValid(data.panel)
            panel = data.panel
            return if panel\IsLoading()
            if data.timerid
                timer.Remove(data.timerid)
                data.timerid = nil
            return if data.frame < 20
            @SHOULD_WAIT_WEB = true
            timer.Simple 1, ->
                @SHOULD_WAIT_WEB = false
                return unless IsValid(panel)
                panel\UpdateHTMLTexture()
                htmlmat = panel\GetHTMLMaterial()
                return if not htmlmat
                texture = htmlmat\GetTexture('$basetexture')
                texture\Download()
                newMat = CreateMaterial("PPM2.URLMaterial.#{texture\GetName()}_#{math.random(1, 100000)}", 'UnlitGeneric', {
                    '$basetexture': 'models/debug/debugwhite'
                    '$ignorez': 1
                    '$vertexcolor': 1
                    '$vertexalpha': 1
                    '$nolod': 1
                })

                newMat\SetTexture('$basetexture', texture)
                @URL_MATERIAL_CACHE[data.width] = @URL_MATERIAL_CACHE[data.width] or {}
                @URL_MATERIAL_CACHE[data.width][data.height] = @URL_MATERIAL_CACHE[data.width][data.height] or {}
                @URL_MATERIAL_CACHE[data.width][data.height][data.url] = {
                    texture: texture
                    material: newMat
                }

                @ALREADY_DOWNLOADING[data.width][data.height][data.url] = false
                --PPM2.Message 'Finished downloading ', data.url

                for callback in *data.callbacks
                    callback(texture, panel, newMat)
                table.remove(@HTML_MATERIAL_QUEUE, 1)
                timer.Simple 0, -> panel\Remove() if IsValid(panel)
            return
        data.frame = 0
        panel = vgui.Create('DHTML')
        data.timerid = "PPM2.TextureMaterialTimeout.#{math.random(1, 100000)}"
        timer.Create data.timerid, 8, 1, ->
            return unless IsValid(panel)
            panel\Remove()
            --PPM2.Message 'Failed to download', data.url, '!'
            newMat = CreateMaterial("PPM2.URLMaterial_Failed_#{math.random(1, 100000)}", 'UnlitGeneric', {
                '$basetexture': 'models/ppm/partrender/null'
                '$ignorez': 1
                '$vertexcolor': 1
                '$vertexalpha': 1
                '$nolod': 1
                '$translucent': 1
            })

            @FAILED_TO_DOWNLOAD[data.width][data.height][data.url] = {
                texture: newMat\GetTexture('$basetexture')
                material: newMat
            }

            for callback in *data.callbacks
                callback(newMat\GetTexture('$basetexture'), nil, newMat)
        panel\SetVisible(false)
        panel\SetSize(data.width, data.height)
        panel\SetHTML(@BuildURLHTML(data.url, data.width, data.height))
        panel\Refresh()
        panel.ConsoleMessage = (pnl, msg) ->
            if msg == 'FRAME'
                data.frame += 1
        data.panel = panel
        --PPM2.Message 'Downloading ', data.url

    new: (controller, compile = true) =>
        @isValid = true
        @ent = controller\GetEntity()
        @cachedENT = controller\GetEntity()
        @networkedData = controller\GetData()
        @id = @ent\EntIndex()
        if @id == -1
            @clientsideID = true
            @id = @@NEXT_GENERATED_ID
            @@NEXT_GENERATED_ID += 1
        @compiled = false
        @lastMaterialUpdate = 0
        @lastMaterialUpdateEnt = NULL
        @delayCompilation = {}
        @CompileTextures() if compile
        PPM2.DebugPrint('Created new texture controller for ', @ent, ' as part of ', controller, '; internal ID is ', @id)
    __tostring: => "[#{@@__name}:#{@id}|#{@GetData()}]"
    Remove: =>
        @isValid = false
        @ResetTextures()
    IsValid: => IsValid(@ent) and @isValid and @compiled
    GetID: =>
        return @id if @clientsideID
        if @ent ~= @cachedENT
            @cachedENT = @ent
            @id = @ent\EntIndex()
            if @id == -1
                @id = @@NEXT_GENERATED_ID
                @@NEXT_GENERATED_ID += 1
        return @id
    GetData: =>
        @ent = @networkedData\GetEntity()
        return @networkedData
    GrabData: (str, ...) => @GetData()['Get' .. str](@GetData(), ...)
    GetEntity: => @ent
    GetBody: =>
        if @GetData()\GetGender() == PPM2.GENDER_FEMALE
            return @FemaleMaterial
        else
            return @MaleMaterial
    GetBodyName: =>
        if @GetData()\GetGender() == PPM2.GENDER_FEMALE
            return @FemaleMaterialName
        else
            return @MaleMaterialName
    GetSocks: => @SocksMaterial
    GetSocksName: => @SocksMaterialName
    GetCMark: => @CMarkTexture
    GetCMarkName: => @CMarkTextureName
    GetGUICMark: => @CMarkTextureGUI
    GetGUICMarkName: => @CMarkTextureGUIName
    GetCMarkGUI: => @CMarkTextureGUI
    GetCMarkGUIName: => @CMarkTextureGUIName
    GetHair: (index = 1) =>
        if index == 2
            return @HairColor2Material
        else
            return @HairColor1Material
    GetHairName: (index = 1) =>
        if index == 2
            return @HairColor2MaterialName
        else
            return @HairColor1MaterialName
    GetMane: (index = 1) =>
        if index == 2
            return @HairColor2Material
        else
            return @HairColor1Material
    GetManeName: (index = 1) =>
        if index == 2
            return @HairColor2MaterialName
        else
            return @HairColor1MaterialName
    GetTail: (index = 1) =>
        if index == 2
            return @TailColor2Material
        else
            return @TailColor1Material
    GetTailName: (index = 1) =>
        if index == 2
            return @TailColor2MaterialName
        else
            return @TailColor1MaterialName
    GetEye: (left = false) =>
        if left
            return @EyeMaterialL
        else
            return @EyeMaterialR
    GetEyeName: (left = false) =>
        if left
            return @EyeMaterialLName
        else
            return @EyeMaterialRName
    GetHorn: => @HornMaterial
    GetHornName: => @HornMaterialName
    GetWings: => @WingsMaterial
    GetWingsName: => @WingsMaterialName
    CompileTextures: =>
        @CompileBody()
        @CompileHair()
        @CompileTail()
        @CompileHorn()
        @CompileWings()
        @CompileCMark()
        @CompileSocks()
        @CompileEye(false)
        @CompileEye(true)
        @compiled = true
    
    PreDraw: (ent = @ent) =>
        return unless @compiled
        return unless @isValid
        if @lastMaterialUpdate < RealTime() or @lastMaterialUpdateEnt ~= ent or PPM2.ALTERNATIVE_RENDER\GetBool()
            @lastMaterialUpdateEnt = ent
            @lastMaterialUpdate = RealTime() + 1
            ent\SetSubMaterial(@@MAT_INDEX_EYE_LEFT, @GetEyeName(true))
            ent\SetSubMaterial(@@MAT_INDEX_EYE_RIGHT, @GetEyeName(false))
            ent\SetSubMaterial(@@MAT_INDEX_BODY, @GetBodyName())
            ent\SetSubMaterial(@@MAT_INDEX_HORN, @GetHornName())
            ent\SetSubMaterial(@@MAT_INDEX_WINGS, @GetWingsName())
            ent\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetHairName(1))
            ent\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetHairName(2))
            ent\SetSubMaterial(@@MAT_INDEX_TAIL_COLOR1, @GetTailName(1))
            ent\SetSubMaterial(@@MAT_INDEX_TAIL_COLOR2, @GetTailName(2))
            ent\SetSubMaterial(@@MAT_INDEX_CMARK, @GetCMarkName())
            ent\SetSubMaterial(@@MAT_INDEX_EYELASHES)
        if PPM2.ALTERNATIVE_RENDER\GetBool()
            render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT, @GetEye(true))
            render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT, @GetEye(false))
            render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
            render.MaterialOverrideByIndex(@@MAT_INDEX_HORN, @GetHorn())
            render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS, @GetWings())
            render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR1, @GetHair(1))
            render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR2, @GetHair(2))
            render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR1, @GetTail(1))
            render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR2, @GetTail(2))
            render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK, @GetCMark())
            render.MaterialOverrideByIndex(@@MAT_INDEX_EYELASHES)
    
    PostDraw: (ent = @ent) =>
        return unless @compiled
        return unless @isValid
        return if not PPM2.ALTERNATIVE_RENDER\GetBool()
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN)
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR1)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR2)
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR1)
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR2)
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK)
    
    ResetTextures: (ent = @ent) =>
        return if not IsValid(ent)
        @lastMaterialUpdateEnt = NULL
        @lastMaterialUpdate = 0
        ent\SetSubMaterial(@@MAT_INDEX_EYE_LEFT)
        ent\SetSubMaterial(@@MAT_INDEX_EYE_RIGHT)
        ent\SetSubMaterial(@@MAT_INDEX_BODY)
        ent\SetSubMaterial(@@MAT_INDEX_HORN)
        ent\SetSubMaterial(@@MAT_INDEX_WINGS)
        ent\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1)
        ent\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2)
        ent\SetSubMaterial(@@MAT_INDEX_TAIL_COLOR1)
        ent\SetSubMaterial(@@MAT_INDEX_TAIL_COLOR2)
        ent\SetSubMaterial(@@MAT_INDEX_CMARK)
        ent\SetSubMaterial(@@MAT_INDEX_EYELASHES)
    
    PreDrawLegs: (ent = @ent) =>
        return unless @compiled
        return unless @isValid
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN, @GetHorn())
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS, @GetWings())
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK, @GetCMark())

    PostDrawLegs: (ent = @ent) =>
        return unless @compiled
        return unless @isValid
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN)
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS)
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK)
    
    @MAT_INDEX_SOCKS = 0

    UpdateSocks: (ent = @ent, socksEnt) =>
        return unless @compiled
        return unless @isValid
        socksEnt\SetSubMaterial(@@MAT_INDEX_SOCKS, @GetSocksName())

    @QUAD_SIZE_EYES = 256
    @QUAD_SIZE_EYES_HIRES = 512

    @QUAD_SIZE_SOCKS = 512
    @QUAD_SIZE_SOCKS_HIRES = 1024

    @QUAD_SIZE_CMARK = 256
    @QUAD_SIZE_CMARK_HIRES = 512

    @QUAD_SIZE_WING = 128
    @QUAD_SIZE_WING_HIRES = 256

    @QUAD_SIZE_HORN = 128
    @QUAD_SIZE_HORN_HIRES = 256

    @QUAD_SIZE_HAIR = 256
    @QUAD_SIZE_HAIR_HIRES = 512

    @QUAD_SIZE_TAIL = 256
    @QUAD_SIZE_TAIL_HIRES = 512

    @QUAD_SIZE_CONST = 512
    @QUAD_SIZE_CONST_HIRES = 1024

    @QUAD_SIZE_BODY = 1024
    @QUAD_SIZE_BODY_HIRES = 2048
    @QUAD_SIZE_BODY_HIRES2 = 4096

    @GetTextureSize = => USE_HIGHRES_TEXTURES\GetBool() and @QUAD_SIZE_CONST_HIRES or @QUAD_SIZE_CONST

    GetPhongData: (prefix = 'Body') =>
        PhongExponent = @GrabData(prefix .. 'PhongExponent')
        PhongBoost = @GrabData(prefix .. 'PhongBoost')
        PhongTint = @GrabData(prefix .. 'PhongTint')
        PhongFront = @GrabData(prefix .. 'PhongFront')
        PhongMiddle = @GrabData(prefix .. 'PhongMiddle')
        PhongSliding = @GrabData(prefix .. 'PhongSliding')
        {:r, :g, :b} = PhongTint
        r /= 255
        g /= 255
        b /= 255
        PhongTint = Vector(r, g, b)
        PhongFresnel = Vector(PhongFront, PhongMiddle, PhongSliding)
        return PhongExponent, PhongBoost, PhongTint, PhongFresnel

    GetBodyPhongMaterials: (output = {}) =>
        table.insert(output, @MaleMaterial) if @MaleMaterial
        table.insert(output, @FemaleMaterial) if @FemaleMaterial
        table.insert(output, @HornMaterial) if @HornMaterial and not @GrabData('SeparateHornPhong')
        table.insert(output, @WingsMaterial) if @WingsMaterial and not @GrabData('SeparateWingsPhong')

    UpdatePhongData: =>
        PhongExponent, PhongBoost, PhongTint, PhongFresnel = @GetPhongData()
        proceed = {}
        @GetBodyPhongMaterials(proceed)
        for mat in *proceed
            mat\SetFloat('$phongexponent', PhongExponent)
            mat\SetFloat('$phongboost', PhongBoost)
            mat\SetVector('$phongtint', PhongTint)
            mat\SetVector('$phongfresnelranges', PhongFresnel)
        
        if @GrabData('SeparateHornPhong') and @HornMaterial
            PhongExponent, PhongBoost, PhongTint, PhongFresnel = @GetPhongData('Horn')
            with @HornMaterial
                \SetFloat('$phongexponent', PhongExponent)
                \SetFloat('$phongboost', PhongBoost)
                \SetVector('$phongtint', PhongTint)
                \SetVector('$phongfresnelranges', PhongFresnel)
        
        if @GrabData('SeparateWingsPhong') and @WingsMaterial
            PhongExponent, PhongBoost, PhongTint, PhongFresnel = @GetPhongData('Wings')
            with @WingsMaterial
                \SetFloat('$phongexponent', PhongExponent)
                \SetFloat('$phongboost', PhongBoost)
                \SetVector('$phongtint', PhongTint)
                \SetVector('$phongfresnelranges', PhongFresnel)
        
        if @SocksMaterial
            PhongExponent, PhongBoost, PhongTint, PhongFresnel = @GetPhongData('Socks')
            with @SocksMaterial
                \SetFloat('$phongexponent', PhongExponent)
                \SetFloat('$phongboost', PhongBoost)
                \SetVector('$phongtint', PhongTint)
                \SetVector('$phongfresnelranges', PhongFresnel)
    
    __compileBodyInternal: (bType = false) =>
        return unless @isValid
        prefix = bType and 'Female' or 'Male'
        prefixUP = bType and 'FEMALE' or 'MALE'
        urlTextures = {}
        left = 0
        bodysize = USE_HIGHRES_BODY\GetBool() and @@QUAD_SIZE_BODY_HIRES2 or USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_BODY_HIRES or @@QUAD_SIZE_BODY

        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Body_#{prefix}"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/ppm/base/bodym'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'
                '$selfillum': '1'
                '$selfillummask': 'models/ppm/partrender/null'

                '$color': '{255 255 255}'
                '$color2': '{255 255 255}'
                '$model': '1'
                '$phong': '1'
                '$basemapalphaphongmask': '1'
                '$phongexponent': '3'
                '$phongboost': '0.15'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                
                '$rimlight': '1'
                '$rimlightexponent': '2'
                '$rimlightboost': '1'
            }
        }

        textureData.data['$basetexture'] = 'models/ppm/base/body' if not bType

        @["#{prefix}MaterialName"] = "!#{textureData.name\lower()}"
        @["#{prefix}Material"] = CreateMaterial(textureData.name, textureData.shader, textureData.data)

        continueCompilation = ->
            return unless @isValid
            {:r, :g, :b} = @GetData()\GetBodyColor()
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{@GetID()}_Body_#{prefix}_rt_#{USE_HIGHRES_BODY\GetBool() and 'hd' or USE_HIGHRES_TEXTURES\GetBool() and 'hq' or 'normal'}", bodysize, bodysize, false)
            rt\Download()

            render.PushRenderTarget(rt)

            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.DisableClipping(true)
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, bodysize, bodysize)

            surface.SetMaterial(@@["BODY_MATERIAL_#{prefixUP}"])
            surface.DrawTexturedRect(0, 0, bodysize, bodysize)

            for i = 1, PPM2.MAX_BODY_DETAILS
                detailID = @GetData()["GetBodyDetail#{i}"](@GetData())
                if mat = PPM2.BodyDetailsMaterials[detailID]
                    surface.SetDrawColor(@GetData()["GetBodyDetailColor#{i}"](@GetData()))
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, bodysize, bodysize)
            
            surface.SetDrawColor(255, 255, 255)

            for i, mat in pairs urlTextures
                {:r, :g, :b, :a} = @GetData()["GetBodyDetailURLColor#{i}"](@GetData())
                surface.SetDrawColor(r, g, b, a)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, bodysize, bodysize)
            
            suitType = @GetData()\GetBodysuit()
            if PPM2.AvaliablePonySuitsMaterials[suitType]
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(PPM2.AvaliablePonySuitsMaterials[suitType])
                surface.DrawTexturedRect(0, 0, bodysize, bodysize)
            
            if @GetData()\GetSocks()
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(@@PONY_SOCKS)
                surface.DrawTexturedRect(0, 0, bodysize, bodysize)

            surface.DisableClipping(false)
            cam.End2D()
            render.PopRenderTarget()

            @["#{prefix}Material"]\SetTexture('$basetexture', rt)

            rtIllum = GetRenderTarget("PPM2_#{@@SessionID}_#{@GetID()}_Body_#{prefix}_rtIllum_#{USE_HIGHRES_BODY\GetBool() and 'hd' or USE_HIGHRES_TEXTURES\GetBool() and 'hq' or 'normal'}", bodysize, bodysize, false)
            rtIllum\Download()

            render.PushRenderTarget(rtIllum)

            r, g, b = 0, 0, 0
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.DisableClipping(true)
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, bodysize, bodysize)

            surface.SetDrawColor(255, 255, 255)

            for i = 1, PPM2.MAX_BODY_DETAILS
                if mat = PPM2.BodyDetailsMaterials[@GetData()["GetBodyDetail#{i}"](@GetData())]
                    alpha = @GetData()["GetBodyDetailGlowStrength#{i}"](@GetData())
                    
                    if @GetData()["GetBodyDetailGlow#{i}"](@GetData())
                        surface.SetDrawColor(255, 255, 255, alpha * 255)
                        surface.SetMaterial(mat)
                        surface.DrawTexturedRect(0, 0, bodysize, bodysize)
                    else
                        surface.SetDrawColor(0, 0, 0, alpha * 255)
                        surface.SetMaterial(mat)
                        surface.DrawTexturedRect(0, 0, bodysize, bodysize)

            surface.DisableClipping(false)
            cam.End2D()
            render.PopRenderTarget()

            @["#{prefix}Material"]\SetTexture('$selfillummask', rtIllum)

            PPM2.DebugPrint('Compiled body texture for ', @ent, ' as part of ', @)
        
        data = @GetData()
        validURLS = for i = 1, PPM2.MAX_BODY_DETAILS
            detailURL = data["GetBodyDetailURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, bodysize, bodysize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        
        if left == 0
            continueCompilation()
        return @["#{prefix}Material"]
    CompileBody: =>
        return unless @isValid
        @__compileBodyInternal(true)
        @__compileBodyInternal(false)
        @UpdatePhongData()
    CompileHorn: =>
        return unless @isValid
        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Horn"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/ppm/base/horn'
                '$selfillum': '1'
                '$selfillummask': 'models/ppm/partrender/null'

                '$model': '1'
                '$phong': '1'
                '$phongexponent': '3'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                '$alpha': '1'
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_HORN_HIRES or @@QUAD_SIZE_HORN
        urlTextures = {}
        left = 0

        @HornMaterialName = "!#{textureData.name\lower()}"
        @HornMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @UpdatePhongData()

        continueCompilation = ->
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Horn_rt", texSize, texSize, false)
            rt\Download()
            
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)
            {:r, :g, :b} = @GetData()\GetBodyColor()
            {:r, :g, :b} = @GetData()\GetHornColor() if @GetData()\GetSeparateHorn()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            surface.SetMaterial(@@HORN_MATERIAL_COLOR)
            surface.DrawTexturedRect(0, 0, texSize, texSize)

            if @GetData()\GetUseHornDetail()
                {:r, :g, :b} = @GetData()\GetHornDetailColor()
                surface.SetDrawColor(r, g, b)
                surface.SetMaterial(@@HORN_DETAIL_COLOR)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            for i, mat in pairs urlTextures
                {:r, :g, :b, :a} = @GetData()["GetHornURLColor#{i}"](@GetData())
                surface.SetDrawColor(r, g, b, a)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            @HornMaterial\SetTexture('$basetexture', rt)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()

            rtIllum = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Horn_rtIllum", texSize, texSize, false)
            rtIllum\Download()

            render.PushRenderTarget(rtIllum)

            r, g, b = 0, 0, 0
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.DisableClipping(true)
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            if @GetData()\GetHornGlow()
                surface.SetDrawColor(255, 255, 255, @GetData()\GetHornGlowSrength() * 255)
                surface.SetMaterial(@@HORN_DETAIL_COLOR)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            surface.DisableClipping(false)
            cam.End2D()
            render.PopRenderTarget()

            @HornMaterial\SetTexture('$selfillummask', rtIllum)

            PPM2.DebugPrint('Compiled Horn texture for ', @ent, ' as part of ', @)

        data = @GetData()
        validURLS = for i = 1, 3
            detailURL = data["GetHornURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, texSize, texSize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        if left == 0
            continueCompilation()
        return @HornMaterial
    CompileSocks: =>
        return unless @isValid
        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Socks"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/props_pony/ppm/ppm_socks/socks_striped'

                '$model': '1'
                '$ambientocclusion': '1'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$phong': '1'
                '$phongexponent': '6'
                '$phongboost': '0.1'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[1 5 10]'
                '$rimlight': '1'
                '$rimlightexponent': '4.0'
                '$rimlightboost': '2'
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
                '$cloakPassEnabled': '1'
            }
        }

        @SocksMaterialName = "!#{textureData.name\lower()}"
        @SocksMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @UpdatePhongData()
        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_SOCKS_HIRES or @@QUAD_SIZE_SOCKS

        {:r, :g, :b} = @GetData()\GetSocksColor()
        @SocksMaterial\SetFloat('$alpha', 1)

        url = @GetData()\GetSocksTextureURL()
        if url == '' or not url\find('^https?://')
            @SocksMaterial\SetVector('$color', Vector(1, 1, 1))
            @SocksMaterial\SetVector('$color2', Vector(1, 1, 1))
            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Socks_rt", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            socksType = @GetData()\GetSocksTexture() + 1
            surface.SetMaterial(PPM2.SocksMaterialsComp[socksType] or PPM2.SocksMaterialsComp[1])
            surface.DrawTexturedRect(0, 0, texSize, texSize)

            if PPM2.SocksDetailsComp[socksType]
                for i, id in pairs PPM2.SocksDetailsComp[socksType]
                    {:r, :g, :b} = @GetData()['GetSocksDetailColor' .. i](@GetData())
                    surface.SetDrawColor(r, g, b)
                    surface.SetMaterial(id)
                    surface.DrawTexturedRect(0, 0, texSize, texSize)

            cam.End2D()
            render.PopRenderTarget()

            @SocksMaterial\SetTexture('$basetexture', rt)

            PPM2.DebugPrint('Compiled socks texture for ', @ent, ' as part of ', @)
        else
            @@LoadURL url, texSize, texSize, (texture, panel, material) ->
                @SocksMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
                @SocksMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))
                @SocksMaterial\SetTexture('$basetexture', texture)

        return @SocksMaterial
    CompileWings: =>
        return unless @isValid
        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Wings"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite'

                '$model': '1'
                '$phong': '1'
                '$phongexponent': '3'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                '$alpha': '1'
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        urlTextures = {}
        left = 0
        @WingsMaterialName = "!#{textureData.name\lower()}"
        @WingsMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @UpdatePhongData()

        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_WING_HIRES or @@QUAD_SIZE_WING

        continueCompilation = ->
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Wings_rt", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)
            {:r, :g, :b} = @GetData()\GetBodyColor()
            {:r, :g, :b} = @GetData()\GetWingsColor() if @GetData()\GetSeparateWings()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            surface.SetMaterial(@@WINGS_MATERIAL_COLOR)
            surface.DrawTexturedRect(0, 0, texSize, texSize)

            for i, mat in pairs urlTextures
                {:r, :g, :b, :a} = @GetData()["GetWingsURLColor#{i}"](@GetData())
                surface.SetDrawColor(r, g, b, a)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            @WingsMaterial\SetTexture('$basetexture', rt)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()

            PPM2.DebugPrint('Compiled wings texture for ', @ent, ' as part of ', @)

        data = @GetData()
        validURLS = for i = 1, 3
            detailURL = data["GetWingsURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, texSize, texSize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        if left == 0
            continueCompilation()

        return @WingsMaterial
    
    GetManeType: => @GetData()\GetManeType()
    GetManeTypeLower: => @GetData()\GetManeTypeLower()
    GetTailType: => @GetData()\GetTailType()
    CompileHair: =>
        return unless @isValid
        textureFirst = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Mane_1"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'
                '$model': '1'
                '$phong': '1'
                '$basemapalphaphongmask': '1'
                '$phongexponent': '6'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                
                '$rimlight': 1
                '$rimlightexponent': 2
                '$rimlightboost': 1
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        textureSecond = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Mane_2"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureFirst.data}
        }

        @HairColor1MaterialName = "!#{textureFirst.name\lower()}"
        @HairColor2MaterialName = "!#{textureSecond.name\lower()}"
        @HairColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
        @HairColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)

        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_HAIR_HIRES or @@QUAD_SIZE_HAIR

        urlTextures = {}
        left = 0

        continueCompilation = ->
            return unless @isValid
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Mane_rt_1", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)

            -- First mane pass
            {:r, :g, :b} = @GetData()\GetManeColor1()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            maneTypeUpper = @GetManeType()
            if @@UPPER_MANE_MATERIALS[maneTypeUpper]
                i = 1
                for mat in *@@UPPER_MANE_MATERIALS[maneTypeUpper]
                    continue if type(mat) == 'number'
                    {:r, :g, :b, :a} = @GetData()["GetManeDetailColor#{i}"](@GetData())
                    surface.SetDrawColor(r, g, b, a)
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, texSize, texSize)
                    i += 1

            for i, mat in pairs urlTextures
                surface.SetDrawColor(@GetData()["GetManeURLColor#{i}"](@GetData()))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()
            @HairColor1Material\SetTexture('$basetexture', rt)

            -- Second mane pass
            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Mane_rt_2", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)

            {:r, :g, :b} = @GetData()\GetManeColor2()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            maneTypeLower = @GetManeTypeLower()
            if @@LOWER_MANE_MATERIALS[maneTypeLower]
                i = 1
                for mat in *@@LOWER_MANE_MATERIALS[maneTypeLower]
                    continue if type(mat) == 'number'
                    {:r, :g, :b, :a} = @GetData()["GetManeDetailColor#{i}"](@GetData())
                    surface.SetDrawColor(r, g, b, a)
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, texSize, texSize)
                    i += 1
            
            for i, mat in pairs urlTextures
                surface.SetDrawColor(@GetData()["GetManeURLColor#{i}"](@GetData()))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()
            @HairColor2Material\SetTexture('$basetexture', rt)

            PPM2.DebugPrint('Compiled mane textures for ', @ent, ' as part of ', @)

        data = @GetData()
        validURLS = for i = 1, 6
            detailURL = data["GetManeURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, texSize, texSize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        if left == 0
            continueCompilation()
        return @HairColor1Material, @HairColor2Material
    CompileTail: =>
        return unless @isValid
        textureFirst = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Tail_1"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'
                '$model': '1'
                '$phong': '1'
                '$basemapalphaphongmask': '1'
                '$phongexponent': '6'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                
                '$rimlight': 1
                '$rimlightexponent': 2
                '$rimlightboost': 1
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        textureSecond = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Tail_2"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureFirst.data}
        }

        @TailColor1MaterialName = "!#{textureFirst.name\lower()}"
        @TailColor2MaterialName = "!#{textureSecond.name\lower()}"
        @TailColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
        @TailColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)

        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_TAIL_HIRES or @@QUAD_SIZE_TAIL

        urlTextures = {}
        left = 0

        continueCompilation = ->
            return unless @isValid
            oldW, oldH = ScrW(), ScrH()

            -- First tail pass
            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Tail_rt_1", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)

            {:r, :g, :b} = @GetData()\GetTailColor1()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            surface.SetMaterial(@@HAIR_MATERIAL_COLOR)
            surface.DrawTexturedRect(0, 0, texSize, texSize)

            tailType = @GetTailType()
            if @@TAIL_DETAIL_MATERIALS[tailType]
                i = 1
                for mat in *@@TAIL_DETAIL_MATERIALS[tailType]
                    continue if type(mat) == 'number'
                    surface.SetMaterial(mat)
                    surface.SetDrawColor(@GetData()["GetTailDetailColor#{i}"](@GetData()))
                    surface.DrawTexturedRect(0, 0, texSize, texSize)
                    i += 1

            for i, mat in pairs urlTextures
                surface.SetDrawColor(@GetData()["GetTailURLColor#{i}"](@GetData()))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()
            @TailColor1Material\SetTexture('$basetexture', rt)

            -- Second tail pass
            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Tail_rt_2", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)

            {:r, :g, :b} = @GetData()\GetTailColor2()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            surface.SetMaterial(@@HAIR_MATERIAL_COLOR)
            surface.DrawTexturedRect(0, 0, texSize, texSize)

            if @@TAIL_DETAIL_MATERIALS[tailType]
                i = 1
                for mat in *@@TAIL_DETAIL_MATERIALS[tailType]
                    continue if type(mat) == 'number'
                    surface.SetMaterial(mat)
                    surface.SetDrawColor(@GetData()["GetTailDetailColor#{i}"](@GetData()))
                    surface.DrawTexturedRect(0, 0, texSize, texSize)
                    i += 1

            for i, mat in pairs urlTextures
                surface.SetDrawColor(@GetData()["GetTailURLColor#{i}"](@GetData()))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()
            @TailColor2Material\SetTexture('$basetexture', rt)

            PPM2.DebugPrint('Compiled tail textures for ', @ent, ' as part of ', @)

        data = @GetData()
        validURLS = for i = 1, 6
            detailURL = data["GetTailURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, texSize, texSize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        if left == 0
            continueCompilation()
        return @TailColor1Material, @TailColor2Material
    CompileEye: (left = false) =>
        return unless @isValid
        prefix = left and 'l' or 'r'
        prefixUpper = left and 'L' or 'R'

        separated = @GetData()\GetSeparateEyes()
        prefixData = ''
        prefixData = left and 'Left' or 'Right' if separated

        EyeType =           @GetData()["GetEyeType#{prefixData}"](@GetData())
        EyeBackground =     @GetData()["GetEyeBackground#{prefixData}"](@GetData())
        EyeHole =           @GetData()["GetEyeHole#{prefixData}"](@GetData())
        HoleWidth =         @GetData()["GetHoleWidth#{prefixData}"](@GetData())
        IrisSize =          @GetData()["GetIrisSize#{prefixData}"](@GetData()) * .75
        EyeIris1 =          @GetData()["GetEyeIrisTop#{prefixData}"](@GetData())
        EyeIris2 =          @GetData()["GetEyeIrisBottom#{prefixData}"](@GetData())
        EyeIrisLine1 =      @GetData()["GetEyeIrisLine1#{prefixData}"](@GetData())
        EyeIrisLine2 =      @GetData()["GetEyeIrisLine2#{prefixData}"](@GetData())
        EyeLines =          @GetData()["GetEyeLines#{prefixData}"](@GetData())
        HoleSize =          @GetData()["GetHoleSize#{prefixData}"](@GetData())
        EyeReflection =     @GetData()["GetEyeReflection#{prefixData}"](@GetData())
        EyeEffect =         @GetData()["GetEyeEffect#{prefixData}"](@GetData())
        DerpEyes =          @GetData()["GetDerpEyes#{prefixData}"](@GetData())
        DerpEyesStrength =  @GetData()["GetDerpEyesStrength#{prefixData}"](@GetData())
        EyeURL =            @GetData()["GetEyeURL#{prefixData}"](@GetData())
        IrisWidth =         @GetData()["GetIrisWidth#{prefixData}"](@GetData())
        IrisHeight =        @GetData()["GetIrisHeight#{prefixData}"](@GetData())
        HoleHeight =        @GetData()["GetHoleHeight#{prefixData}"](@GetData())
        HoleShiftX =        @GetData()["GetHoleShiftX#{prefixData}"](@GetData())
        HoleShiftY =        @GetData()["GetHoleShiftY#{prefixData}"](@GetData())
        EyeRotation =       @GetData()["GetEyeRotation#{prefixData}"](@GetData())
        PonySize =          @GetData()\GetPonySize()
        PonySize = 1 if IsValid(@ent) and @ent\IsRagdoll()
        
        oldW, oldH = ScrW(), ScrH()

        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_EYES_HIRES or @@QUAD_SIZE_EYES

        shiftX, shiftY = (1 - IrisWidth) * texSize / 2, (1 - IrisHeight) * texSize / 2
        shiftY += DerpEyesStrength * .15 * texSize if DerpEyes and left
        shiftY -= DerpEyesStrength * .15 * texSize if DerpEyes and not left

        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Eye_#{prefix}"
            'shader': 'eyes'
            'data': {
                '$iris': 'models/ppm/base/face/p_base'
                '$irisframe': '0'
                
                '$ambientoccltexture': 'models/ppm/partrender/null'
                --'$envmap': 'models/ppm/partrender/null'
                '$corneatexture': 'models/ppm/partrender/null'
                '$lightwarptexture': 'models/ppm/clothes/lightwarp'
                
                '$eyeballradius': '3.7'
                '$ambientocclcolor': '[0.3 0.3 0.3]'
                '$dilation': '0.5'
                '$glossiness': '1'
                '$parallaxstrength': '0.1'
                '$corneabumpstrength': '0.1'

                '$halflambert': '1'
                '$nodecal': '1'

                '$raytracesphere': '0'
                '$spheretexkillcombo': '0'
                '$eyeorigin': '[0 0 0]'
                '$irisu': '[0 1 0 0]'
                '$irisv': '[0 0 1 0]'
                '$entityorigin': '1.0'
            }
        }

        @["EyeMaterial#{prefixUpper}Name"] = "!#{textureData.name\lower()}"
        createdMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @["EyeMaterial#{prefixUpper}"] = createdMaterial

        if EyeURL == '' or not EyeURL\find('^https?://')
            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Eye_#{prefix}", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)

            {:r, :g, :b, :a} = EyeBackground
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            surface.SetDrawColor(EyeIris1)
            surface.SetMaterial(@@EYE_OVALS[EyeType + 1] or @EYE_OVAL)
            IrisPos = texSize / 2 - texSize * IrisSize * PonySize / 2
            IrisQuadSize = texSize * IrisSize * PonySize
            DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

            surface.SetDrawColor(EyeIris2)
            surface.SetMaterial(@@EYE_GRAD)
            DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

            if EyeLines
                surface.SetDrawColor(EyeIrisLine1)
                surface.SetMaterial(@@["EYE_LINE_#{prefixUpper}_1"])
                DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

                surface.SetDrawColor(EyeIrisLine2)
                surface.SetMaterial(@@["EYE_LINE_#{prefixUpper}_2"])
                DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)
            
            surface.SetDrawColor(EyeHole)
            surface.SetMaterial(@@EYE_OVALS[EyeType + 1] or @EYE_OVAL)
            HoleQuadSize = texSize * IrisSize * HoleSize * PonySize
            HolePos = texSize / 2
            do
                holeX = HoleQuadSize * HoleWidth / 2
                holeY = texSize * (IrisSize * HoleSize * HoleHeight * PonySize) / 2
                cx = HolePos - holeX + holeX * HoleShiftX + shiftX
                cy = HolePos - holeY + holeY * HoleShiftY + shiftY
                DrawTexturedRectRotated(cx, cy, HoleQuadSize * HoleWidth * IrisWidth, HoleQuadSize * HoleHeight * IrisHeight, EyeRotation)

            surface.SetDrawColor(EyeEffect)
            surface.SetMaterial(@@EYE_EFFECT)
            DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

            surface.SetDrawColor(EyeReflection)
            surface.SetMaterial(@@EYE_REFLECTION)
            DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()
            @["EyeMaterial#{prefixUpper}"]\SetTexture('$iris', rt)

            PPM2.DebugPrint('Compiled eyes texture for ', @ent, ' as part of ', @)
        else
            @@LoadURL EyeURL, texSize, texSize, (texture, panel, material) ->
                @["EyeMaterial#{prefixUpper}"]\SetTexture('$iris', texture)
        return @["EyeMaterial#{prefixUpper}"]
    CompileCMark: =>
        return unless @isValid
        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_CMark"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/ppm/partrender/null'
                '$translucent': '1'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'
            }
        }

        textureDataGUI = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_CMark_GUI"
            'shader': 'UnlitGeneric'
            'data': {
                '$basetexture': 'models/ppm/partrender/null'
                '$translucent': '1'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'
            }
        }

        @CMarkTextureName = "!#{textureData.name\lower()}"
        @CMarkTexture = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @CMarkTextureGUIName = "!#{textureDataGUI.name\lower()}"
        @CMarkTextureGUI = CreateMaterial(textureDataGUI.name, textureDataGUI.shader, textureDataGUI.data)

        unless @GetData()\GetCMark()
            @CMarkTexture\SetTexture('$basetexture', 'models/ppm/partrender/null')
            @CMarkTextureGUI\SetTexture('$basetexture', 'models/ppm/partrender/null')
            return @CMarkTexture, @CMarkTextureGUI
        
        URL = @GetData()\GetCMarkURL()
        size = @GetData()\GetCMarkSize()
        
        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_CMARK_HIRES or @@QUAD_SIZE_CMARK
        sizeQuad = texSize * size
        shift = (texSize - sizeQuad) / 2

        if URL == '' or not URL\find('^https?://')
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_CMark", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)
            render.Clear(0, 0, 0, 0, true, true)
            cam.Start2D()

            mark = PPM2.DefaultCutiemarksMaterials[@GetData()\GetCMarkType() + 1]
            if mark
                surface.SetDrawColor(@GetData()\GetCMarkColor())
                surface.SetMaterial(mark)
                surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)
            
            cam.End2D()
            render.PopRenderTarget()
            render.SetViewPort(0, 0, oldW, oldH)

            @CMarkTexture\SetTexture('$basetexture', rt)
            @CMarkTextureGUI\SetTexture('$basetexture', rt)

            PPM2.DebugPrint('Compiled cutiemark texture for ', @ent, ' as part of ', @)
        else
            @@LoadURL URL, texSize, texSize, (texture, panel, material) ->
                oldW, oldH = ScrW(), ScrH()

                rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_CMark", texSize, texSize, false)
                rt\Download()
                render.PushRenderTarget(rt)
                render.SetViewPort(0, 0, texSize, texSize)
                render.Clear(0, 0, 0, 0, true, true)
                cam.Start2D()

                surface.SetDrawColor(@GetData()\GetCMarkColor())
                surface.SetMaterial(material)
                surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)
                
                cam.End2D()
                render.PopRenderTarget()
                render.SetViewPort(0, 0, oldW, oldH)

                @CMarkTexture\SetTexture('$basetexture', rt)
                @CMarkTextureGUI\SetTexture('$basetexture', rt)

                PPM2.DebugPrint('Compiled cutiemark texture for ', @ent, ' as part of ', @)
        
        return @CMarkTexture, @CMarkTextureGUI

-- [ 1] = "models/ppm/base/cmark"
-- [ 2] = "models/ppm/base/eyelashes"
-- [ 3] = "models/ppm/base/tongue"
-- [ 4] = "models/ppm/base/body"
-- [ 5] = "models/ppm/base/teeth"
-- [ 6] = "models/ppm/base/eye_l"
-- [ 7] = "models/ppm/base/eye_r"
-- [ 8] = "models/ppm/base/mouth"
-- [ 9] = "models/ppm/base/horn"
-- [10] = "models/ppm/base/wings"

class NewPonyTextureController extends PonyTextureController
    @MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

    @UPPER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs @UPPER_MANE_MATERIALS}
    @LOWER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs @LOWER_MANE_MATERIALS}
    @TAIL_DETAIL_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs @TAIL_DETAIL_MATERIALS}

    @MAT_INDEX_CMARK = 0
    @MAT_INDEX_EYELASHES = 1
    @MAT_INDEX_TONGUE = 2
    @MAT_INDEX_BODY = 3
    @MAT_INDEX_TEETH = 4
    @MAT_INDEX_EYE_LEFT = 5
    @MAT_INDEX_EYE_RIGHT = 6
    @MAT_INDEX_MOUTH = 7
    @MAT_INDEX_HORN = 8
    @MAT_INDEX_WINGS = 9
    @MAT_INDEX_WINGS_BAT = 10
    @MAT_INDEX_WINGS_BAT_SKIN = 11

    @MAT_INDEX_HAIR_COLOR1 = 0
    @MAT_INDEX_HAIR_COLOR2 = 1

    @MAT_INDEX_TAIL_COLOR1 = 0
    @MAT_INDEX_TAIL_COLOR2 = 1

    @MANE_UPDATE_TRIGGER = {key, value for key, value in pairs @MANE_UPDATE_TRIGGER}
    @MANE_UPDATE_TRIGGER['ManeTypeNew'] = true
    @MANE_UPDATE_TRIGGER['SeparateMane'] = true
    @MANE_UPDATE_TRIGGER['ManeTypeLowerNew'] = true
    
    for i = 1, 6
        @MANE_UPDATE_TRIGGER["LowerManeColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["UpperManeColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["LowerManeDetailColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["UpperManeDetailColor#{i}"] = true

        @MANE_UPDATE_TRIGGER["LowerManeURL#{i}"] = true
        @MANE_UPDATE_TRIGGER["LowerManeURLColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["UpperManeURL#{i}"] = true
        @MANE_UPDATE_TRIGGER["UpperManeURLColor#{i}"] = true
    
    __tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"

    DataChanges: (state) =>
        return unless @isValid
        super(state)
        switch state\GetKey()
            when 'ManeTypeNew', 'ManeTypeLowerNew', 'TailTypeNew'
                @DelayCompile('CompileHair')

            when 'TeethColor', 'MouthColor', 'TongueColor'
                @DelayCompile('CompileMouth')

            when 'SeparateWings'
                @DelayCompile('CompileBatWings')
                @DelayCompile('CompileBatWingsSkin')
            
            when 'BatWingColor', 'BatWingURL1', 'BatWingURL2', 'BatWingURL3', 'BatWingURLColor1', 'BatWingURLColor2', 'BatWingURLColor3'
                @DelayCompile('CompileBatWings')
            
            when 'BatWingSkinColor', 'BatWingSkinURL1', 'BatWingSkinURL2', 'BatWingSkinURL3', 'BatWingSkinURLColor1', 'BatWingSkinURLColor2', 'BatWingSkinURLColor3'
                @DelayCompile('CompileBatWingsSkin')

    GetManeType: => @GetData()\GetManeTypeNew()
    GetManeTypeLower: => @GetData()\GetManeTypeLowerNew()
    GetTailType: => @GetData()\GetTailTypeNew()

    CompileHairInternal: (prefix = 'Upper') =>
        return unless @isValid
        textureFirst = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Mane_1_#{prefix}"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'
                '$model': '1'
                '$phong': '1'
                '$basemapalphaphongmask': '1'
                '$phongexponent': '6'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                
                '$rimlight': 1
                '$rimlightexponent': 2
                '$rimlightboost': 1
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        textureSecond = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_Mane_2_#{prefix}"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureFirst.data}
        }

        HairColor1MaterialName = "!#{textureFirst.name\lower()}"
        HairColor2MaterialName = "!#{textureSecond.name\lower()}"
        HairColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
        HairColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)

        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_HAIR_HIRES or @@QUAD_SIZE_HAIR
        
        urlTextures = {}
        left = 0

        continueCompilation = ->
            return unless @isValid
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Mane_rt_1_#{prefix}", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)

            -- First mane pass
            {:r, :g, :b} = @GetData()["Get#{prefix}ManeColor1"](@GetData())
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            maneTypeUpper = @GetManeType()
            if @@UPPER_MANE_MATERIALS[maneTypeUpper]
                i = 1
                for mat in *@@UPPER_MANE_MATERIALS[maneTypeUpper]
                    continue if type(mat) == 'number'
                    {:r, :g, :b, :a} = @GetData()["Get#{prefix}ManeDetailColor#{i}"](@GetData())
                    surface.SetDrawColor(r, g, b, a)
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, texSize, texSize)
                    i += 1

            for i, mat in pairs urlTextures
                surface.SetDrawColor(@GetData()["Get#{prefix}ManeURLColor#{i}"](@GetData()))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()
            HairColor1Material\SetTexture('$basetexture', rt)

            -- Second mane pass
            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_Mane_rt_2_#{prefix}", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)

            {:r, :g, :b} = @GetData()["Get#{prefix}ManeColor2"](@GetData())
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            maneTypeLower = @GetManeTypeLower()
            if @@LOWER_MANE_MATERIALS[maneTypeLower]
                i = 1
                for mat in *@@LOWER_MANE_MATERIALS[maneTypeLower]
                    continue if type(mat) == 'number'
                    {:r, :g, :b, :a} = @GetData()["Get#{prefix}ManeDetailColor#{i}"](@GetData())
                    surface.SetDrawColor(r, g, b, a)
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, texSize, texSize)
                    i += 1

            for i, mat in pairs urlTextures
                surface.SetDrawColor(@GetData()["Get#{prefix}ManeURLColor#{i}"](@GetData()))
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()
            HairColor2Material\SetTexture('$basetexture', rt)

            PPM2.DebugPrint('Compiled mane textures for ', @ent, ' as part of ', @)

        data = @GetData()
        validURLS = for i = 1, 6
            detailURL = data["Get#{prefix}ManeURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, texSize, texSize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        if left == 0
            continueCompilation()
        return HairColor1Material, HairColor2Material, HairColor1MaterialName, HairColor2MaterialName
    
    GetBodyPhongMaterials: (output = {}) =>
        super(output)
        if not @GrabData('SeparateWingsPhong')
            table.insert(output, @BatWingsMaterial) if @BatWingsMaterial
            table.insert(output, @BatWingsSkinMaterial) if @BatWingsSkinMaterial

    UpdatePhongData: =>
        super()
        if @GrabData('SeparateWingsPhong')
            if @BatWingsMaterial
                PhongExponent, PhongBoost, PhongTint, PhongFresnel = @GetPhongData('Wings')
                with @BatWingsMaterial
                    \SetFloat('$phongexponent', PhongExponent)
                    \SetFloat('$phongboost', PhongBoost)
                    \SetVector('$phongtint', PhongTint)
                    \SetVector('$phongfresnelranges', PhongFresnel)
            
            if @BatWingsSkinMaterial
                PhongExponent, PhongBoost, PhongTint, PhongFresnel = @GetPhongData('BatWingsSkin')
                with @BatWingsSkinMaterial
                    \SetFloat('$phongexponent', PhongExponent)
                    \SetFloat('$phongboost', PhongBoost)
                    \SetVector('$phongtint', PhongTint)
                    \SetVector('$phongfresnelranges', PhongFresnel)

    CompileBatWings: =>
        return unless @isValid
        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_BatWings"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'

                '$model': '1'
                '$phong': '1'
                '$phongexponent': '0.1'
                '$phongboost': '0.1'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                '$alpha': '1'
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        urlTextures = {}
        left = 0
        @BatWingsMaterialName = "!#{textureData.name\lower()}"
        @BatWingsMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @UpdatePhongData()
        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_WING_HIRES or @@QUAD_SIZE_WING

        continueCompilation = ->
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_BatWings_rt", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)
            {:r, :g, :b} = @GetData()\GetBodyColor()
            {:r, :g, :b} = @GetData()\GetBatWingColor() if @GetData()\GetSeparateWings()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            surface.SetMaterial(@@WINGS_MATERIAL_COLOR)
            surface.DrawTexturedRect(0, 0, texSize, texSize)

            for i, mat in pairs urlTextures
                {:r, :g, :b, :a} = @GetData()["GetBatWingURLColor#{i}"](@GetData())
                surface.SetDrawColor(r, g, b, a)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            @BatWingsMaterial\SetTexture('$basetexture', rt)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()

            PPM2.DebugPrint('Compiled Bat Wings texture for ', @ent, ' as part of ', @)

        data = @GetData()
        validURLS = for i = 1, 3
            detailURL = data["GetBatWingURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, texSize, texSize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        if left == 0
            continueCompilation()

        return @BatWingsMaterial

    CompileBatWingsSkin: =>
        return unless @isValid
        textureData = {
            'name': "PPM2_#{@@SessionID}_#{@GetID()}_BatWingsSkin"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite'
                '$lightwarptexture': 'models/ppm/base/lightwrap'
                '$halflambert': '1'

                '$model': '1'
                '$phong': '1'
                '$phongexponent': '0.1'
                '$phongboost': '0.1'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                '$alpha': '1'
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        urlTextures = {}
        left = 0
        @BatWingsSkinMaterialName = "!#{textureData.name\lower()}"
        @BatWingsSkinMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @UpdatePhongData()
        texSize = USE_HIGHRES_TEXTURES\GetBool() and @@QUAD_SIZE_WING_HIRES or @@QUAD_SIZE_WING

        continueCompilation = ->
            oldW, oldH = ScrW(), ScrH()

            rt = GetRenderTarget("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_BatWingsSkin_rt", texSize, texSize, false)
            rt\Download()
            render.PushRenderTarget(rt)
            render.SetViewPort(0, 0, texSize, texSize)
            {:r, :g, :b} = @GetData()\GetBodyColor()
            {:r, :g, :b} = @GetData()\GetBatWingSkinColor() if @GetData()\GetSeparateWings()
            render.Clear(r, g, b, 255, true, true)
            cam.Start2D()
            surface.SetDrawColor(r, g, b)
            surface.DrawRect(0, 0, texSize, texSize)

            surface.SetMaterial(@@WINGS_MATERIAL_COLOR)
            surface.DrawTexturedRect(0, 0, texSize, texSize)

            for i, mat in pairs urlTextures
                {:r, :g, :b, :a} = @GetData()["GetBatWingSkinURLColor#{i}"](@GetData())
                surface.SetDrawColor(r, g, b, a)
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, texSize, texSize)

            @BatWingsSkinMaterial\SetTexture('$basetexture', rt)

            cam.End2D()
            render.SetViewPort(0, 0, oldW, oldH)
            render.PopRenderTarget()

            PPM2.DebugPrint('Compiled Bat Wings skin texture for ', @ent, ' as part of ', @)

        data = @GetData()
        validURLS = for i = 1, 3
            detailURL = data["GetBatWingSkinURL#{i}"](data)
            continue if detailURL == '' or not detailURL\find('^https?://')
            left += 1
            {detailURL, i}
        
        for {url, i} in *validURLS
            @@LoadURL url, texSize, texSize, (texture, panel, mat) ->
                left -= 1
                urlTextures[i] = mat
                if left == 0
                    continueCompilation()
        if left == 0
            continueCompilation()

        return @BatWingsSkinMaterial
        
    CompileHair: =>
        return unless @isValid
        return super() if not @GetData()\GetSeparateMane()
        mat1, mat2, name1, name2 = @CompileHairInternal('Upper')
        mat3, mat4, name3, name4 = @CompileHairInternal('Lower')
        @UpperManeColor1, @UpperManeColor2 = mat1, mat2
        @LowerManeColor1, @LowerManeColor2 = mat3, mat4
        @UpperManeColor1Name, @UpperManeColor2Name = name1, name2
        @LowerManeColor1Name, @LowerManeColor2Name = name3, name4
        return mat1, mat2, mat3, mat4
    
    CompileMouth: =>
        textureData = {
            '$basetexture': 'models/debug/debugwhite'
            '$lightwarptexture': 'models/ppm/base/lightwrap'
            '$halflambert': '1'
            '$phong': '1'
            '$phongexponent': '20'
            '$phongboost': '.1'	
            '$phongfresnelranges': '[.3 1 8]'
            '$halflambert': '0'
            '$basemapalphaphongmask': '1'

            '$rimlight': '1'
            '$rimlightexponent': '4'	
            '$rimlightboost': '2'
            '$color': '[1 1 1]'
            '$color2': '[1 1 1]'

            '$ambientocclusion': '1'
        }

        {:r, :g, :b} = @GetData()\GetTeethColor()
        @TeethMaterialName = "!ppm2_#{@GetID()}_teeth"
        @TeethMaterial = CreateMaterial("PPM2_#{@@SessionID}_#{@GetID()}_Teeth", 'VertexLitGeneric', textureData)
        @TeethMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
        @TeethMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

        {:r, :g, :b} = @GetData()\GetMouthColor()
        @MouthMaterialName = "!ppm2_#{@GetID()}_mouth"
        @MouthMaterial = CreateMaterial("PPM2_#{@@SessionID}_#{@GetID()}_Mouth", 'VertexLitGeneric', textureData)
        @MouthMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
        @MouthMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

        {:r, :g, :b} = @GetData()\GetTongueColor()
        @TongueMaterialName = "!ppm2_#{@GetID()}_tongue"
        @TongueMaterial = CreateMaterial("PPM2_#{@@SessionID}_#{@GetID()}_Tongue", 'VertexLitGeneric', textureData)
        @TongueMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
        @TongueMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

        PPM2.DebugPrint('Compiled mouth textures for ', @ent, ' as part of ', @)

        return @TeethMaterial, @MouthMaterial, @TongueMaterial
    
    CompileTextures: =>
        super()
        @CompileMouth()
        @CompileBatWingsSkin()
        @CompileBatWings()
    
    GetTeeth: => @TeethMaterial
    GetMouth: => @MouthMaterial
    GetTongue: => @TongueMaterial
    GetBatWings: => @BatWingsMaterial
    GetBatWingsSkin: => @BatWingsSkinMaterial

    GetBatWingsName: => @BatWingsMaterialName
    GetBatWingsSkinName: => @BatWingsSkinMaterialName
    GetTeethName: => @TeethMaterialName
    GetMouthName: => @MouthMaterialName
    GetTongueName: => @TongueMaterialName
    
    GetUpperHair: (index = 1) =>
        if index == 2
            return @UpperManeColor2
        else
            return @UpperManeColor1
    GetLowerHair: (index = 1) =>
        if index == 2
            return @LowerManeColor2
        else
            return @LowerManeColor1
    
    GetUpperHairName: (index = 1) =>
        if index == 2
            return @UpperManeColor2Name
        else
            return @UpperManeColor1Name
    GetLowerHairName: (index = 1) =>
        if index == 2
            return @LowerManeColor2Name
        else
            return @LowerManeColor1Name

    UpdateUpperMane: (ent = @ent, entMane) =>
        return unless @isValid
        return unless @compiled

        if not @GetData()\GetSeparateMane()
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetManeName(1))
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetManeName(2))
        else
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetUpperHairName(1))
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetUpperHairName(2))
    
    UpdateLowerMane: (ent = @ent, entMane) =>
        return unless @compiled
        return unless @isValid

        if not @GetData()\GetSeparateMane()
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetManeName(1))
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetManeName(2))
        else
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetLowerHairName(1))
            entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetLowerHairName(2))

    UpdateTail: (ent = @ent, entTail) =>
        return unless @compiled
        return unless @isValid
        entTail\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetTailName(1))
        entTail\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetTailName(2))

    PreDraw: (ent = @ent) =>
        return unless @compiled
        return unless @isValid
        if @lastMaterialUpdate < RealTime() or @lastMaterialUpdateEnt ~= ent or PPM2.ALTERNATIVE_RENDER\GetBool()
            @lastMaterialUpdateEnt = ent
            @lastMaterialUpdate = RealTime() + 1
            ent\SetSubMaterial(@@MAT_INDEX_EYE_LEFT, @GetEyeName(true))
            ent\SetSubMaterial(@@MAT_INDEX_EYE_RIGHT, @GetEyeName(false))
            ent\SetSubMaterial(@@MAT_INDEX_TONGUE, @GetTongueName())
            ent\SetSubMaterial(@@MAT_INDEX_TEETH, @GetTeethName())
            ent\SetSubMaterial(@@MAT_INDEX_MOUTH, @GetMouthName())
            ent\SetSubMaterial(@@MAT_INDEX_BODY, @GetBodyName())
            ent\SetSubMaterial(@@MAT_INDEX_HORN, @GetHornName())
            ent\SetSubMaterial(@@MAT_INDEX_WINGS, @GetWingsName())
            ent\SetSubMaterial(@@MAT_INDEX_CMARK, @GetCMarkName())
            ent\SetSubMaterial(@@MAT_INDEX_EYELASHES)
            ent\SetSubMaterial(@@MAT_INDEX_WINGS_BAT, @GetBatWingsName())
            ent\SetSubMaterial(@@MAT_INDEX_WINGS_BAT_SKIN, @GetBatWingsSkinName())
        if PPM2.ALTERNATIVE_RENDER\GetBool()
            render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT, @GetEye(true))
            render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT, @GetEye(false))
            render.MaterialOverrideByIndex(@@MAT_INDEX_TONGUE, @GetTongue())
            render.MaterialOverrideByIndex(@@MAT_INDEX_TEETH, @GetTeeth())
            render.MaterialOverrideByIndex(@@MAT_INDEX_MOUTH, @GetMouth())
            render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
            render.MaterialOverrideByIndex(@@MAT_INDEX_HORN, @GetHorn())
            render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS, @GetWings())
            render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK, @GetCMark())
            render.MaterialOverrideByIndex(@@MAT_INDEX_EYELASHES)
            render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS_BAT, @GetBatWings())
            render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS_BAT_SKIN, @GetBatWingsSkin())
    PostDraw: (ent = @ent) =>
        return unless @compiled
        return unless @isValid
        return if not PPM2.ALTERNATIVE_RENDER\GetBool()
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_TONGUE)
        render.MaterialOverrideByIndex(@@MAT_INDEX_TEETH)
        render.MaterialOverrideByIndex(@@MAT_INDEX_MOUTH)
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN)
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS)
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK)
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYELASHES)
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS_BAT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS_BAT_SKIN)
    ResetTextures: (ent = @ent) =>
        return if not IsValid(ent)
        @lastMaterialUpdateEnt = NULL
        @lastMaterialUpdate = 0
        ent\SetSubMaterial(@@MAT_INDEX_EYE_LEFT)
        ent\SetSubMaterial(@@MAT_INDEX_EYE_RIGHT)
        ent\SetSubMaterial(@@MAT_INDEX_TONGUE)
        ent\SetSubMaterial(@@MAT_INDEX_TEETH)
        ent\SetSubMaterial(@@MAT_INDEX_MOUTH)
        ent\SetSubMaterial(@@MAT_INDEX_BODY)
        ent\SetSubMaterial(@@MAT_INDEX_HORN)
        ent\SetSubMaterial(@@MAT_INDEX_WINGS)
        ent\SetSubMaterial(@@MAT_INDEX_CMARK)
        ent\SetSubMaterial(@@MAT_INDEX_EYELASHES)
        ent\SetSubMaterial(@@MAT_INDEX_WINGS_BAT)
        ent\SetSubMaterial(@@MAT_INDEX_WINGS_BAT_SKIN)

concommand.Add 'ppm2_reload_materials', ->
    cTime = SysTime()
    for mat in *RELOADABLE_MATERIALS
        if texname = mat\GetString('$basetexture')
            mat\SetTexture('$basetexture', texname)
        if texture = mat\GetTexture('$basetexture')
            texture\Download()
        mat\Recompute()
    PonyTextureController.URL_MATERIAL_CACHE = {}
    PPM2.Message('Reloaded textures in ', math.floor((SysTime() - cTime) * 100000) / 100, ' milliseconds. Do not forget to ppm2_reload and ppm2_require now!')

PPM2.NewPonyTextureController = NewPonyTextureController
PPM2.PonyTextureController = PonyTextureController
PPM2.GetTextureController = (model = 'models/ppm/player_default_base.mdl') -> PonyTextureController.AVALIABLE_CONTROLLERS[model\lower()] or PonyTextureController
