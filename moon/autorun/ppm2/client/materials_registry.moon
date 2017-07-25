
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

PPM2.USE_HIGHRES_BODY = CreateConVar('ppm2_cl_hires_body', '0', {FCVAR_ACRHIVE}, 'Use high resoluation when rendering pony bodies. AFFECTS ONLY TEXTURE COMPILATION TIME (increases lag spike on pony data load)')
PPM2.USE_HIGHRES_TEXTURES = CreateConVar('ppm2_cl_hires_generic', '0', {FCVAR_ACRHIVE}, 'Create 1024x1024 textures instead of 512x512 on texture compiling')

RELOADABLE_MATERIALS = {}
PPM2.RELOADABLE_MATERIALS = RELOADABLE_MATERIALS
concommand.Add 'ppm2_reload_materials', ->
    cTime = SysTime()
    for mat in *RELOADABLE_MATERIALS
        if texname = mat\GetString('$basetexture')
            mat\SetTexture('$basetexture', texname)
        if texture = mat\GetTexture('$basetexture')
            texture\Download()
        mat\Recompute()
    PPM2.PonyTextureController.URL_MATERIAL_CACHE = {}
    PPM2.Message('Reloaded textures in ', math.floor((SysTime() - cTime) * 100000) / 100, ' milliseconds. Do not forget to ppm2_reload and ppm2_require now!')

_Material = Material
_CreateMaterial = CreateMaterial
Material = (path) ->
    matNew, time = _Material(path)
    table.insert(RELOADABLE_MATERIALS, matNew)
    return matNew, time

CreateMaterial = (name, shader, data) ->
    matNew, time = _CreateMaterial(name, shader, data)
    table.insert(RELOADABLE_MATERIALS, matNew)
    return matNew, time

module = {
    BODY_DETAILS: {
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

    UPPER_MANE_DETAILS: {
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

    LOWER_MANE_DETAILS: {
        [4]: {Material('models/ppm/partrender/dnmane_5_mask0')}
        [7]: {Material('models/ppm/partrender/dnmane_8_mask0'), Material('models/ppm/partrender/dnmane_8_mask1')}
        [8]: {Material('models/ppm/partrender/dnmane_9_mask0'), Material('models/ppm/partrender/dnmane_9_mask1')}
        [9]: {Material('models/ppm/partrender/dnmane_10_mask0'), Material('models/ppm/partrender/dnmane_10_mask1'), Material('models/ppm/partrender/dnmane_10_mask2')}
        [10]: {Material('models/ppm/partrender/dnmane_11_mask0'), Material('models/ppm/partrender/dnmane_11_mask1')}
        [11]: {Material('models/ppm/partrender/dnmane_12_mask0')}
    }

    TAIL_DETAILS: {
        [4]: {Material('models/ppm/partrender/tail_5_mask0')}
        [7]: {Material('models/ppm/partrender/tail_8_mask0'), Material('models/ppm/partrender/tail_8_mask1'), Material('models/ppm/partrender/tail_8_mask2'), Material('models/ppm/partrender/tail_8_mask3'), Material('models/ppm/partrender/tail_8_mask4')}
        [9]: {Material('models/ppm/partrender/tail_10_mask0')}
        [10]: {Material('models/ppm/partrender/tail_11_mask0'), Material('models/ppm/partrender/tail_11_mask1'), Material('models/ppm/partrender/tail_11_mask2')}
        [11]: {Material('models/ppm/partrender/tail_12_mask0'), Material('models/ppm/partrender/tail_12_mask1')}
        [12]: {Material('models/ppm/partrender/tail_13_mask0')}
        [13]: {Material('models/ppm/partrender/tail_14_mask0')}
    }

    SOCKS_PATCHS: {
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

    SOCKS_DETAILS_PATCHS: {
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
}

module.SOCKS_MATERIALS = [Material(id) for id in *module.SOCKS_PATCHS]
module.SOCKS_DETAILS = [Material(id) for id in *module.SOCKS_DETAILS_PATCHS]
module.CUTIEMARKS = [CreateMaterial("PPM2_CMarkDraw_#{mark}", 'UnlitGeneric', {'$basetexture': "models/ppm/cmarks/#{mark}", '$ignorez': 1, '$vertexcolor': 1, '$vertexalpha': 1, '$nolod': 1}) for mark in *PPM2.DefaultCutiemarks]
module.SUITS = [Material("models/ppm/texclothes/#{mat}") for mat in *{
    'clothes_royalguard', 'clothes_sbs_full'
    'clothes_sbs_light', 'clothes_wbs_full'
    'clothes_wbs_light', 'spidermane_light'
    'spidermane_full'
}]

additionTable = (...) ->
    tab = {'$ignorez': 1, '$vertexcolor': 1, '$vertexalpha': 1, '$nolod': 1}
    args = {...}
    for i = 1, #args, 2
        key, val = args[i], args[i + 1]
        tab[key] = val
    return tab

module.TATTOOS = [Material("models/ppm/partrender/tattoo/#{fil\lower()}") for fil in *PPM2.TATTOOS_REGISTRY when fil ~= 'NONE']
debugwhite = {
    '$basetexture': 'models/debug/debugwhite'
    '$ignorez': 1
    '$vertexcolor': 1
    '$vertexalpha': 1
    '$nolod': 1
}

module.EYE_OVALS = {
    Material('models/ppm/partrender/eye_oval')
    Material('models/ppm/partrender/eye_oval_aperture')
}

module.DEBUGWHITE = CreateMaterial('PPM2.Debugwhite', 'UnlitGeneric', debugwhite)
module.HAIR_MATERIAL_COLOR = CreateMaterial('PPM2.ManeTextureBase', 'UnlitGeneric', debugwhite)
module.TAIL_MATERIAL_COLOR = CreateMaterial('PPM2.TailTextureBase', 'UnlitGeneric', debugwhite)
module.WINGS_MATERIAL_COLOR = CreateMaterial('PPM2.WingsMaterialBase', 'UnlitGeneric', debugwhite)
module.HORN_MATERIAL_COLOR = CreateMaterial('PPM2.HornMaterialBase', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm/base/horn'))
module.BODY_MATERIAL = CreateMaterial('PPM2.BodyTexture', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm/base/body'))
module.HORN_DETAIL_BUMP = CreateMaterial('PPM2.HornBumpMapRenderer', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm/base/horn_normal'))
module.HORN_DETAIL_COLOR = Material('models/ppm/partrender/horn_detail')
module.EYE_OVAL = Material('models/ppm/partrender/eye_oval')
module.EYE_GRAD = Material('models/ppm/partrender/eye_grad')
module.EYE_EFFECT = Material('models/ppm/partrender/eye_effect')
module.EYE_REFLECTION = Material('models/ppm/partrender/eye_reflection')
module.EYE_LINE_L_1 = Material('models/ppm/partrender/eye_line_l1')
module.EYE_LINE_R_1 = Material('models/ppm/partrender/eye_line_r1')
module.EYE_LINE_L_2 = Material('models/ppm/partrender/eye_line_l2')
module.EYE_LINE_R_2 = Material('models/ppm/partrender/eye_line_r2')
module.PONY_SOCKS = Material('models/ppm/texclothes/pony_socks')

module.LIPS = Material('models/ppm/partrender/lips')
module.NOSE = Material('models/ppm/partrender/nose')

module.EYE_CORNERA = Material('models/ppm/eyes/eye_cornea')
module.EYE_CORNERA_OVAL = Material('models/ppm/eyes/eye_cornea_oval')
module.EYE_EXTRA = Material('models/ppm/eyes/eye_extra')
module.EYE_EXTRA2 = Material('models/ppm/eyes/eye_extra2')
module.EYE_LIGHTWARP = Material('models/ppm/eyes/eye_lightwarp')
module.EYE_REFLECTION2 = Material('models/ppm/eyes/eye_reflection')

PPM2.MaterialsRegistry = module
return module
