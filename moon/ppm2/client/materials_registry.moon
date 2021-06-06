
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

PPM2.USE_HIGHRES_TEXTURES = CreateConVar('ppm2_cl_hires', '0', {FCVAR_ARCHIVE}, 'Double the texture resolution. Can take ages at texture encoding if CPU is slow, and require a lot of RAM for encoding and a lot of VRAM for textures!')
PPM2.NO_COMPRESSION = CreateConVar('ppm2_cl_use_rgba', '0', {FCVAR_ARCHIVE}, 'Use RGB888/RGBA8888 instead of DXT1/DXT5. This option is experimental and is VERY memory/video memory hungry!')
PPM2.NO_ENCODING = CreateConVar('ppm2_cl_disable_encoding', '0', {FCVAR_ARCHIVE}, 'Disable texture encoding completely. This is same as ppm2_cl_use_rgba, except it will use even more video memory! This option is unsupported and will break some features.')
PPM2.FORCE_PRECACHE = CreateConVar('ppm2_cl_force_precache', '0', {FCVAR_ARCHIVE}, 'Force precache render textures instead of precaching them when required')

_Material = Material

Material = (path) ->
	return path if not PPM2.FORCE_PRECACHE\GetBool()
	matNew = _Material(path) if not path\find('png')
	matNew = _Material(path, 'smooth ignorez') if path\find('png')
	return matNew

module = {
	BODY_DETAILS: {
		'GRADIENT':             Material('models/ppm2/partrender/body_leggrad1.png')
		'LINES':                Material('models/ppm2/partrender/body_lines1.png')
		'STRIPES':              Material('models/ppm2/partrender/body_stripes1.png')
		'HSTRIPES':             Material('models/ppm2/partrender/body_headstripes1.png')
		'FRECKLES':             Material('models/ppm2/partrender/body_freckles.png')
		'HOOF_BIG':             Material('models/ppm2/partrender/body_hooves1.png')
		'HOOF_SMALL':           Material('models/ppm2/partrender/body_hooves2.png')
		'LAYER':                Material('models/ppm2/partrender/body_headmask1.png')
		'HOOF_BIG_ROUND':       Material('models/ppm2/partrender/body_hooves1_crit.png')
		'HOOF_SMALL_ROUND':     Material('models/ppm2/partrender/body_hooves2_crit.png')
		'SPOTS':                Material('models/ppm2/partrender/body_spots1.png')
		'ROBOTIC':              Material('models/ppm2/partrender/body_robotic.png')
		'DASH_E':               Material('models/ppm2/partrender/dash-e.png')
		'EYE_SCAR':             Material('models/ppm2/partrender/eye_scar.png')
		'EYE_WOUND':            Material('models/ppm2/partrender/eye_wound.png')
		'SCARS':                Material('models/ppm2/partrender/body_scar.png')
		'MGS_SOCKS':            Material('models/ppm2/partrender/gear_socks.png')
		'SHARP_HOOVES':         Material('models/ppm2/partrender/sharp_hooves.png')
		'SHARP_HOOVES_2':       Material('models/ppm2/partrender/sharp_hooves2.png')
		'MUZZLE':               Material('models/ppm2/partrender/separated_muzzle.png')
		'EYE_SCAR_LEFT':        Material('models/ppm2/partrender/eye_scar_left.png')
		'EYE_SCAR_RIGHT':       Material('models/ppm2/partrender/eye_scar_right.png')
		'ALBEDO_ANDROID':       Material('models/ppm2/partrender/android_albedo.png')
		'PAINT_ANDROID':        Material('models/ppm2/partrender/android_paint.png')
		'ALBEDO_ANDROID_STRIP': Material('models/ppm2/partrender/android_albedo_strip.png')
		'PAINT_ANDROID_STRIP':  Material('models/ppm2/partrender/android_paint_strip.png')
		'COW':                  Material('models/ppm2/partrender/cow_paint.png')
		'DEER':                 Material('models/ppm2/partrender/deer_paint.png')
		'DEER_EXTENDED':        Material('models/ppm2/partrender/deer_extended_paint.png')
		'DEMONIC':              Material('models/ppm2/partrender/demonic_paint.png')
		'EAR_INNER':            Material('models/ppm2/partrender/ear_inner_paint.png')
		'ZEBRA_DETAILS':        Material('models/ppm2/partrender/zebra_detail_paint.png')
	}

	UPPER_MANE_DETAILS: {
		['ASSERTIVE']: {Material('models/ppm2/partrender/upmane_5_mask0.png')}
		['BOLD']: {Material('models/ppm2/partrender/upmane_6_mask0.png')}
		['SPEEDSTER']: {Material('models/ppm2/partrender/upmane_8_mask0.png'), Material('models/ppm2/partrender/upmane_8_mask1.png')}
		['RADICAL']: {Material('models/ppm2/partrender/upmane_9_mask0.png'), Material('models/ppm2/partrender/upmane_9_mask1.png'), Material('models/ppm2/partrender/upmane_9_mask2.png')}
		['SPIKED']: {Material('models/ppm2/partrender/upmane_10_mask0.png')}
		['BOOKWORM']: {Material('models/ppm2/partrender/upmane_11_mask0.png'), Material('models/ppm2/partrender/upmane_11_mask1.png'), Material('models/ppm2/partrender/upmane_11_mask2.png')}
		['BUMPKIN']: {Material('models/ppm2/partrender/upmane_12_mask0.png')}
		['POOFEH']: {Material('models/ppm2/partrender/upmane_13_mask0.png')}
		['CURLY']: {Material('models/ppm2/partrender/upmane_14_mask0.png')}
		['INSTRUCTOR']: {Material('models/ppm2/partrender/upmane_15_mask0.png')}
		['SECRETARY']: {Material('models/ppm2/partrender/mane_secretary_mask_01.png')}
		['BRAIDS']: {Material('models/ppm2/partrender/mane_braids_mask_01.png')}
		['GLASS']: {Material('models/ppm2/partrender/mane_glass_mask_01.png')}
	}

	LOWER_MANE_DETAILS: {
		['ASSERTIVE']: {Material('models/ppm2/partrender/dnmane_5_mask0.png')}
		['HIPPIE']: {Material('models/ppm2/partrender/dnmane_8_mask0.png'), Material('models/ppm2/partrender/dnmane_8_mask1.png')}
		['SPEEDSTER']: {Material('models/ppm2/partrender/dnmane_9_mask0.png'), Material('models/ppm2/partrender/dnmane_9_mask1.png')}
		['BOOKWORM']: {Material('models/ppm2/partrender/dnmane_10_mask0.png'), Material('models/ppm2/partrender/dnmane_10_mask1.png'), Material('models/ppm2/partrender/dnmane_10_mask2.png')}
		['BUMPKIN']: {Material('models/ppm2/partrender/dnmane_11_mask0.png'), Material('models/ppm2/partrender/dnmane_11_mask1.png')}
		['CURLY']: {Material('models/ppm2/partrender/dnmane_12_mask0.png')}
		['BRAIDS']: {Material('models/ppm2/partrender/mane_braids_mask_01.png')}
		['GLASS']: {Material('models/ppm2/partrender/mane_glass_mask_01.png')}
	}

	TAIL_DETAILS: {
		['ASSERTIVE']: {Material('models/ppm2/partrender/tail_5_mask0.png')}
		['SPEEDSTER']: {Material('models/ppm2/partrender/tail_8_mask0.png'), Material('models/ppm2/partrender/tail_8_mask1.png'), Material('models/ppm2/partrender/tail_8_mask2.png'), Material('models/ppm2/partrender/tail_8_mask3.png'), Material('models/ppm2/partrender/tail_8_mask4.png')}
		['RADICAL']: {Material('models/ppm2/partrender/tail_10_mask0.png')}
		['BOOKWORM']: {Material('models/ppm2/partrender/tail_11_mask0.png'), Material('models/ppm2/partrender/tail_11_mask1.png'), Material('models/ppm2/partrender/tail_11_mask2.png')}
		['BUMPKIN']: {Material('models/ppm2/partrender/tail_12_mask0.png'), Material('models/ppm2/partrender/tail_12_mask1.png')}
		['POOFEH']: {Material('models/ppm2/partrender/tail_13_mask0.png')}
		['CURLY']: {Material('models/ppm2/partrender/tail_14_mask0.png')}
	}

	SOCKS_MATERIALS: {
		'DEFAULT':    Material('models/props_pony/ppm/ppm_socks/socks_striped_unlit')
		'GEOMETRIC1': Material('models/props_pony/ppm2/ppm_socks/custom/geometric1_1.png')
		'GEOMETRIC2': Material('models/props_pony/ppm2/ppm_socks/custom/geometric2_1.png')
		'GEOMETRIC3': Material('models/props_pony/ppm2/ppm_socks/custom/geometric3_1.png')
		'GEOMETRIC4': Material('models/props_pony/ppm2/ppm_socks/custom/geometric4_1.png')
		'GEOMETRIC5': Material('models/props_pony/ppm2/ppm_socks/custom/geometric5_1.png')
		'GEOMETRIC6': Material('models/props_pony/ppm2/ppm_socks/custom/geometric6_1.png')
		'GEOMETRIC7': Material('models/props_pony/ppm2/ppm_socks/custom/geometric7_1.png')
		'GEOMETRIC8': Material('models/props_pony/ppm2/ppm_socks/custom/geometric8_1.png')
		'DARK1':      Material('models/props_pony/ppm2/ppm_socks/custom_textured/dark1.png')
		'FLOWERS10':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers10.png')
		'FLOWERS11':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers11.png')
		'FLOWERS12':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers12.png')
		'FLOWERS13':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers13.png')
		'FLOWERS14':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers14.png')
		'FLOWERS15':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers15.png')
		'FLOWERS16':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers16.png')
		'FLOWERS17':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers17.png')
		'FLOWERS18':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers18.png')
		'FLOWERS19':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers19.png')
		'FLOWERS2':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers2.png')
		'FLOWERS20':  Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers20.png')
		'FLOWERS3':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers3.png')
		'FLOWERS4':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers4.png')
		'FLOWERS5':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers5.png')
		'FLOWERS6':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers6.png')
		'FLOWERS7':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers7.png')
		'FLOWERS8':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers8.png')
		'FLOWERS9':   Material('models/props_pony/ppm2/ppm_socks/custom_textured/flowers9.png')
		'GREY1':      Material('models/props_pony/ppm2/ppm_socks/custom_textured/grey1.png')
		'GREY2':      Material('models/props_pony/ppm2/ppm_socks/custom_textured/grey2.png')
		'GREY3':      Material('models/props_pony/ppm2/ppm_socks/custom_textured/grey3.png')
		'HEARTS1':    Material('models/props_pony/ppm2/ppm_socks/custom_textured/hearts1.png')
		'HEARTS2':    Material('models/props_pony/ppm2/ppm_socks/custom_textured/hearts2.png')
		'SNOW1':      Material('models/props_pony/ppm2/ppm_socks/custom_textured/snow1.png')
		'WALLPAPER1': Material('models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper1.png')
		'WALLPAPER2': Material('models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper2.png')
		'WALLPAPER3': Material('models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper3.png')
	}

	SOCKS_DETAILS: {
		'GEOMETRIC1': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric1_4.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric1_5.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric1_6.png')
		}

		'GEOMETRIC2': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric2_3.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric2_4.png')
		}

		'GEOMETRIC3': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric3_2.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric3_3.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric3_5.png')
		}

		'GEOMETRIC4': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric4_2.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric4_3.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric4_4.png')
		}

		'GEOMETRIC5': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric5_4.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric5_5.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric5_6.png')
		}

		'GEOMETRIC6': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric6_2.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric6_3.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric6_4.png')
		}

		'GEOMETRIC7': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric7_3.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric7_4.png')
		}

		'GEOMETRIC8': {
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric8_2.png')
			Material('models/props_pony/ppm2/ppm_socks/custom/geometric8_3.png')
		}
	}
}

additionTable = (...) ->
	tab = {'$ignorez': 1, '$vertexcolor': 1, '$vertexalpha': 1, '$nolod': 1}
	args = {...}
	for i = 1, #args, 2
		key, val = args[i], args[i + 1]
		tab[key] = val
	return tab

module.CUTIEMARKS = {mark, Material("models/ppm2/cmarks/#{mark\lower()}.png") for mark in *PPM2.DefaultCutiemarks}

module.SUITS = {a, Material("models/ppm2/texclothes/#{b}.png") for a, b in pairs {
	'ROYAL_GUARD': 'clothes_royalguard'
	'SHADOWBOLTS_FULL': 'clothes_sbs_full'
	'SHADOWBOLTS_LIGHT': 'clothes_sbs_light'
	'WONDERBOLTS_FULL': 'clothes_wbs_full'
	'WONDERBOLTS_LIGHT': 'clothes_wbs_light'
	'SPIDERMANE_LIGHT': 'spidermane_light'
	'SPIDERMANE_FULL': 'spidermane_full'
}}

module.TATTOOS = {fil, Material("models/ppm2/partrender/tattoo/#{fil\lower()}.png") for _, fil in ipairs PPM2.TATTOOS_REGISTRY when fil ~= 'NONE'}

debugwhite = {
	'$basetexture': 'models/debug/debugwhite'
	'$ignorez': 1
	'$vertexcolor': 1
	'$vertexalpha': 1
	'$nolod': 1
}

module.EYE_OVALS = {
	'DEFAULT':  Material('models/ppm2/partrender/eye_oval.png')
	'APERTURE': Material('models/ppm2/partrender/eye_oval_aperture.png')
}

module.EYE_REFLECTIONS = {
	'DEFAULT':      Material('models/ppm2/partrender/eye_reflection.png')
	'CRYSTAL_FOAL': Material('models/ppm2/partrender/eye_reflection_crystal_foal.png')
	'CRYSTAL':      Material('models/ppm2/partrender/eye_reflection_crystal_unisex.png')
	'FOAL':         Material('models/ppm2/partrender/eye_reflection_foal.png')
	'MALE':         Material('models/ppm2/partrender/eye_reflection_male.png')
}

module.HEAD_CLOTHES = {
	'APPLEJACK_HAT': {
		Material('models/ppm2/clothesrender/hat_aj.png')
	}

	'BRAEBURN_HAT': {
		Material('models/ppm2/clothesrender/hat_braeburn_2.png')
	}

	'TRIXIE_HAT': {
		Material('models/ppm2/clothesrender/tr_hat_stars_1.png')
		Material('models/ppm2/clothesrender/tr_hat_stars_2.png')
	}

	'HEADPHONES': {
		Material('models/ppm2/clothesrender/headphones_1.png')
		Material('models/ppm2/clothesrender/headphones_2.png')
		Material('models/ppm2/clothesrender/headphones_note.png')
	}
}

module.HEAD_CLOTHES_INDEX = {
	'APPLEJACK_HAT': 0
	'BRAEBURN_HAT': 1
	'TRIXIE_HAT': 2
	'HEADPHONES': 3
}

module.NECK_CLOTHES = {
	'SCARF': {
		Material('models/ppm2/clothesrender/winter_scarf_1.png')
		Material('models/ppm2/clothesrender/winter_scarf_2.png')
	}

	'TRIXIE_CAPE': {
		{
			Material('models/ppm2/clothesrender/cape_stars_1.png')
			Material('models/ppm2/clothesrender/cape_stars_2.png')
		}
		{
			Material('models/ppm2/clothesrender/gem.png')
		}
	}

	'TIE': {
		Material('models/ppm2/clothesrender/tie_1.png')
		Material('models/ppm2/clothesrender/tie_2.png')
	}

	'BOWTIE': {
		Material('models/ppm2/clothesrender/bowtie_1.png')
		Material('models/ppm2/clothesrender/bowtie_2.png')
	}
}

module.NECK_CLOTHES_INDEX = {
	'SCARF': 4
	'TRIXIE_CAPE': {5, 6}
	'TIE': 7
	'BOWTIE': 8
}

module.BODY_CLOTHES = {
	'VEST': {
		Material('models/ppm2/clothesrender/vest_pouches.png')
		Material('models/ppm2/clothesrender/vest_string.png')
	}

	'SHIRT': {
		Material('models/ppm2/clothesrender/shirt.png')
	}

	'HOODIE': {
		Material('models/ppm2/clothesrender/hoodie.png')
	}

	'WONDERBOLTS_BADGE': {
		Material('models/ppm2/clothesrender/badge.png')
	}
}

module.BODY_CLOTHES_INDEX = {
	'VEST': 9
	'SHIRT': 10
	'HOODIE': 11
	'WONDERBOLTS_BADGE': 12
}

module.EYE_CLOTHES = {
	'GOGGLES_ROUND_FEMALE': {
		{}
		{Material('models/ppm2/clothesrender/lense.png')}
	}
	['SHADES_FEMALE']: {
		{}
		{Material('models/ppm2/clothesrender/shades_lense.png')}
	}
	['MONOCLE_FEMALE']: {
		{}
		{}
	}
	['EYEPATH_FEMALE']: {
		{}
		{}
	}
}

module.EYE_CLOTHES['GOGGLES_ROUND_MALE'] = module.EYE_CLOTHES['GOGGLES_ROUND_FEMALE']
module.EYE_CLOTHES['SHADES_MALE'] = module.EYE_CLOTHES['SHADES_FEMALE']
module.EYE_CLOTHES['MONOCLE_MALE'] = module.EYE_CLOTHES['MONOCLE_FEMALE']
module.EYE_CLOTHES['EYEPATH_MALE'] = module.EYE_CLOTHES['EYEPATH_FEMALE']

module.EYE_CLOTHES_INDEX = {
	'GOGGLES_ROUND_FEMALE': {13, 14}
	'SHADES_FEMALE': {15, 16}
	'MONOCLE_FEMALE': {17, 18}
	'EYEPATH_FEMALE': {20, 21}
}

module.EYE_CLOTHES_INDEX['GOGGLES_ROUND_MALE'] = module.EYE_CLOTHES_INDEX['GOGGLES_ROUND_FEMALE']
module.EYE_CLOTHES_INDEX['SHADES_MALE'] = module.EYE_CLOTHES_INDEX['SHADES_FEMALE']
module.EYE_CLOTHES_INDEX['MONOCLE_MALE'] = module.EYE_CLOTHES_INDEX['MONOCLE_FEMALE']
module.EYE_CLOTHES_INDEX['EYEPATH_MALE'] = module.EYE_CLOTHES_INDEX['EYEPATH_FEMALE']

do
	_prMaterial = (tab) ->
		for i, sub in pairs(tab)
			if not istable(sub[1])
				tab[i] = {}
				tab[i][1] = [mat for mat in *sub when not isnumber(mat)]

	_prIndex = (tab) ->
		for i, sub in pairs(tab)
			if not istable(sub)
				tab[i] = {sub}

	_prMaterial(module.HEAD_CLOTHES)
	_prIndex(module.HEAD_CLOTHES_INDEX)
	_prMaterial(module.NECK_CLOTHES)
	_prIndex(module.NECK_CLOTHES_INDEX)
	_prMaterial(module.BODY_CLOTHES)
	_prIndex(module.BODY_CLOTHES_INDEX)
	_prMaterial(module.EYE_CLOTHES)
	_prIndex(module.EYE_CLOTHES_INDEX)

module.DEBUGWHITE = CreateMaterial('PPM2.Debugwhite', 'UnlitGeneric', debugwhite)
module.HAIR_MATERIAL_COLOR = CreateMaterial('PPM2.ManeTextureBase', 'UnlitGeneric', debugwhite)
module.TAIL_MATERIAL_COLOR = CreateMaterial('PPM2.TailTextureBase', 'UnlitGeneric', debugwhite)
module.WINGS_MATERIAL_COLOR = CreateMaterial('PPM2.WingsMaterialBase', 'UnlitGeneric', debugwhite)
module.HORN_MATERIAL_COLOR = CreateMaterial('PPM2.HornMaterialBase', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm2/base/horn'))
module.BODY_MATERIAL = CreateMaterial('PPM2.BodyTexture', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm2/base/body'))
module.HORN_DETAIL_BUMP = CreateMaterial('PPM2.HornBumpMapRenderer', 'UnlitGeneric', additionTable('$basetexture', 'models/ppm2/base/horn_normal'))
module.HORN_DETAIL_COLOR = Material('models/ppm2/partrender/horn_detail.png')
module.EYE_OVAL = Material('models/ppm2/partrender/eye_oval.png')
module.EYE_GRAD = Material('models/ppm2/partrender/eye_grad.png')
module.EYE_EFFECT = Material('models/ppm2/partrender/eye_effect.png')
module.EYE_LINE_L_1 = Material('models/ppm2/partrender/eye_line_l1.png')
module.EYE_LINE_R_1 = Material('models/ppm2/partrender/eye_line_r1.png')
module.EYE_LINE_L_2 = Material('models/ppm2/partrender/eye_line_l2.png')
module.EYE_LINE_R_2 = Material('models/ppm2/partrender/eye_line_r2.png')
module.EYEBROWS = Material('models/ppm2/partrender/eyebrows.png')
module.PONY_SOCKS = Material('models/ppm2/texclothes/pony_socks.png')

module.LIPS = Material('models/ppm2/partrender/lips.png')
module.NOSE = Material('models/ppm2/partrender/nose.png')
module.BODY_BUMP = Material('models/ppm2/partrender/body_bump2.png')

module.EYE_CORNERA = Material('models/ppm2/eyes/eye_cornea')
module.EYE_CORNERA_OVAL = Material('models/ppm2/eyes/eye_cornea_oval')
module.EYE_EXTRA = Material('models/ppm2/eyes/eye_extra')
module.EYE_EXTRA2 = Material('models/ppm2/eyes/eye_extra2')
module.EYE_LIGHTWARP = Material('models/ppm2/eyes/eye_lightwarp')
module.EYE_REFLECTION2 = Material('models/ppm2/eyes/eye_reflection')

module.MAGIC_HANDS_MATERIAL = Material('models/ppm2/base/magic_arms')

__index = (key) =>
	if key == 'size'
		return #getmetatable(@).original

	value = rawget(getmetatable(@).original, key)
	return value if not isstring(value)
	mat = _Material(value, 'smooth ignorez') if value\find('png')
	mat = _Material(value) if not value\find('png')
	rawset(@, key, mat)
	return mat

patch = (input) ->
	patch(value) for key, value in pairs(input) when istable(value)

	meta = {
		__index: __index
		original: table.Copy(input)
	}

	for k in *table.GetKeys(input)
		if not istable(input[k])
			input[k] = nil

	return setmetatable(input, meta)

PPM2.MaterialsRegistry = patch(module)

return module
