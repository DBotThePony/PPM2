
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


PPM2.USE_HIGHRES_BODY = CreateConVar('ppm2_cl_hires_body', '0', {FCVAR_ARCHIVE}, 'Use high resoluation when rendering pony bodies. AFFECTS ONLY TEXTURE COMPILATION TIME (increases lag spike on pony data load)')
PPM2.USE_HIGHRES_TEXTURES = CreateConVar('ppm2_cl_hires_generic', '0', {FCVAR_ARCHIVE}, 'Create 1024x1024 textures instead of 512x512 on texture compiling')

RELOADABLE_MATERIALS = {}
PPM2.RELOADABLE_MATERIALS = RELOADABLE_MATERIALS
concommand.Add 'ppm2_reload_materials', ->
	cTime = SysTime()
	for _, mat in ipairs RELOADABLE_MATERIALS
		if texname = mat\GetString('$basetexture')
			mat\SetTexture('$basetexture', texname)
		if texture = mat\GetTexture('$basetexture')
			texture\Download()
		mat\Recompute()
	PPM2.PonyTextureController.URL_MATERIAL_CACHE = {}
	PPM2.PonyTextureController.SessionID = math.random(1, 1000)
	PPM2.Message('Reloaded textures in ', math.floor((SysTime() - cTime) * 100000) / 100, ' milliseconds.')
	RunConsoleCommand('ppm2_reload')
	RunConsoleCommand('ppm2_require')

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
		Material('models/ppm2/partrender/body_leggrad1.png')
		Material('models/ppm2/partrender/body_lines1.png')
		Material('models/ppm2/partrender/body_stripes1.png')
		Material('models/ppm2/partrender/body_headstripes1.png')
		Material('models/ppm2/partrender/body_freckles.png')
		Material('models/ppm2/partrender/body_hooves1.png')
		Material('models/ppm2/partrender/body_hooves2.png')
		Material('models/ppm2/partrender/body_headmask1.png')
		Material('models/ppm2/partrender/body_hooves1_crit.png')
		Material('models/ppm2/partrender/body_hooves2_crit.png')
		Material('models/ppm2/partrender/body_spots1.png')
		Material('models/ppm2/partrender/body_robotic.png')
		Material('models/ppm2/partrender/dash-e.png')
		Material('models/ppm2/partrender/eye_scar.png')
		Material('models/ppm2/partrender/eye_wound.png')
		Material('models/ppm2/partrender/body_scar.png')
		Material('models/ppm2/partrender/gear_socks.png')
		Material('models/ppm2/partrender/sharp_hooves.png')
		Material('models/ppm2/partrender/sharp_hooves2.png')
		Material('models/ppm2/partrender/separated_muzzle.png')
		Material('models/ppm2/partrender/eye_scar_left.png')
		Material('models/ppm2/partrender/eye_scar_right.png')
		Material('models/ppm2/partrender/android_albedo.png')
		Material('models/ppm2/partrender/android_paint.png')
		Material('models/ppm2/partrender/android_albedo_strip.png')
		Material('models/ppm2/partrender/android_paint_strip.png')
		Material('models/ppm2/partrender/cow_paint.png')
		Material('models/ppm2/partrender/deer_paint.png')
		Material('models/ppm2/partrender/deer_extended_paint.png')
		Material('models/ppm2/partrender/demonic_paint.png')
		Material('models/ppm2/partrender/ear_inner_paint.png')
		Material('models/ppm2/partrender/zebra_detail_paint.png')
	}

	UPPER_MANE_DETAILS: {
		[4]: {Material('models/ppm2/partrender/upmane_5_mask0.png')}
		[5]: {Material('models/ppm2/partrender/upmane_6_mask0.png')}
		[7]: {Material('models/ppm2/partrender/upmane_8_mask0.png'), Material('models/ppm2/partrender/upmane_8_mask1.png')}
		[8]: {Material('models/ppm2/partrender/upmane_9_mask0.png'), Material('models/ppm2/partrender/upmane_9_mask1.png'), Material('models/ppm2/partrender/upmane_9_mask2.png')}
		[9]: {Material('models/ppm2/partrender/upmane_10_mask0.png')}
		[10]: {Material('models/ppm2/partrender/upmane_11_mask0.png'), Material('models/ppm2/partrender/upmane_11_mask1.png'), Material('models/ppm2/partrender/upmane_11_mask2.png')}
		[11]: {Material('models/ppm2/partrender/upmane_12_mask0.png')}
		[12]: {Material('models/ppm2/partrender/upmane_13_mask0.png')}
		[13]: {Material('models/ppm2/partrender/upmane_14_mask0.png')}
		[14]: {Material('models/ppm2/partrender/upmane_15_mask0.png')}
	}

	LOWER_MANE_DETAILS: {
		[4]: {Material('models/ppm2/partrender/dnmane_5_mask0.png')}
		[7]: {Material('models/ppm2/partrender/dnmane_8_mask0.png'), Material('models/ppm2/partrender/dnmane_8_mask1.png')}
		[8]: {Material('models/ppm2/partrender/dnmane_9_mask0.png'), Material('models/ppm2/partrender/dnmane_9_mask1.png')}
		[9]: {Material('models/ppm2/partrender/dnmane_10_mask0.png'), Material('models/ppm2/partrender/dnmane_10_mask1.png'), Material('models/ppm2/partrender/dnmane_10_mask2.png')}
		[10]: {Material('models/ppm2/partrender/dnmane_11_mask0.png'), Material('models/ppm2/partrender/dnmane_11_mask1.png')}
		[11]: {Material('models/ppm2/partrender/dnmane_12_mask0.png')}
	}

	TAIL_DETAILS: {
		[4]: {Material('models/ppm2/partrender/tail_5_mask0.png')}
		[7]: {Material('models/ppm2/partrender/tail_8_mask0.png'), Material('models/ppm2/partrender/tail_8_mask1.png'), Material('models/ppm2/partrender/tail_8_mask2.png'), Material('models/ppm2/partrender/tail_8_mask3.png'), Material('models/ppm2/partrender/tail_8_mask4.png')}
		[9]: {Material('models/ppm2/partrender/tail_10_mask0.png')}
		[10]: {Material('models/ppm2/partrender/tail_11_mask0.png'), Material('models/ppm2/partrender/tail_11_mask1.png'), Material('models/ppm2/partrender/tail_11_mask2.png')}
		[11]: {Material('models/ppm2/partrender/tail_12_mask0.png'), Material('models/ppm2/partrender/tail_12_mask1.png')}
		[12]: {Material('models/ppm2/partrender/tail_13_mask0.png')}
		[13]: {Material('models/ppm2/partrender/tail_14_mask0.png')}
	}

	SOCKS_PATCHS: {
		'models/props_pony/ppm/ppm_socks/socks_striped_unlit'
		'models/props_pony/ppm2/ppm_socks/custom/geometric1_1.png'
		'models/props_pony/ppm2/ppm_socks/custom/geometric2_1.png'
		'models/props_pony/ppm2/ppm_socks/custom/geometric3_1.png'
		'models/props_pony/ppm2/ppm_socks/custom/geometric4_1.png'
		'models/props_pony/ppm2/ppm_socks/custom/geometric5_1.png'
		'models/props_pony/ppm2/ppm_socks/custom/geometric6_1.png'
		'models/props_pony/ppm2/ppm_socks/custom/geometric7_1.png'
		'models/props_pony/ppm2/ppm_socks/custom/geometric8_1.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/dark1.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers10.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers11.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers12.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers13.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers14.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers15.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers16.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers17.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers18.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers19.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers2.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers20.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers3.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers4.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers5.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers6.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers7.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers8.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/flowers9.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/grey1.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/grey2.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/grey3.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/hearts1.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/hearts2.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/snow1.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper1.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper2.png'
		'models/props_pony/ppm2/ppm_socks/custom_textured/wallpaper3.png'
	}

	SOCKS_DETAILS_PATCHS: {
		[2]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric1_4.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric1_5.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric1_6.png'
		}

		[3]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric2_3.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric2_4.png'
		}

		[4]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric3_2.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric3_3.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric3_5.png'
		}

		[5]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric4_2.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric4_3.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric4_4.png'
		}

		[6]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric5_4.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric5_5.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric5_6.png'
		}

		[7]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric6_2.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric6_3.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric6_4.png'
		}

		[8]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric7_3.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric7_4.png'
		}

		[9]: {
			'models/props_pony/ppm2/ppm_socks/custom/geometric8_2.png'
			'models/props_pony/ppm2/ppm_socks/custom/geometric8_3.png'
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

module.SOCKS_MATERIALS = [Material(id) for _, id in ipairs module.SOCKS_PATCHS]
module.SOCKS_DETAILS = {i, [Material(path) for path in *data] for i, data in pairs module.SOCKS_DETAILS_PATCHS}
module.CUTIEMARKS = [Material("models/ppm2/cmarks/#{mark}.png") for _, mark in ipairs PPM2.DefaultCutiemarks]
module.SUITS = [Material("models/ppm2/texclothes/#{mat}.png") for _, mat in ipairs {
	'clothes_royalguard', 'clothes_sbs_full'
	'clothes_sbs_light', 'clothes_wbs_full'
	'clothes_wbs_light', 'spidermane_light'
	'spidermane_full'
}]

module.TATTOOS = [Material("models/ppm2/partrender/tattoo/#{fil\lower()}.png") for _, fil in ipairs PPM2.TATTOOS_REGISTRY when fil ~= 'NONE']
debugwhite = {
	'$basetexture': 'models/debug/debugwhite'
	'$ignorez': 1
	'$vertexcolor': 1
	'$vertexalpha': 1
	'$nolod': 1
}

module.EYE_OVALS = {
	Material('models/ppm2/partrender/eye_oval.png')
	Material('models/ppm2/partrender/eye_oval_aperture.png')
}

module.EYE_REFLECTIONS = {
	Material('models/ppm2/partrender/eye_reflection.png')
	Material('models/ppm2/partrender/eye_reflection_crystal_foal.png')
	Material('models/ppm2/partrender/eye_reflection_crystal_unisex.png')
	Material('models/ppm2/partrender/eye_reflection_foal.png')
	Material('models/ppm2/partrender/eye_reflection_male.png')
}

module.HEAD_CLOTHES = {
	[2]: {
		Material('models/ppm2/clothesrender/hat_aj.png')
	}

	[3]: {
		Material('models/ppm2/clothesrender/hat_braeburn_2.png')
	}

	[4]: {
		Material('models/ppm2/clothesrender/tr_hat_stars_1.png')
		Material('models/ppm2/clothesrender/tr_hat_stars_2.png')
	}

	[5]: {
		Material('models/ppm2/clothesrender/headphones_1.png')
		Material('models/ppm2/clothesrender/headphones_2.png')
		Material('models/ppm2/clothesrender/headphones_note.png')
	}
}

module.HEAD_CLOTHES_INDEX = {
	[2]: 0
	[3]: 1
	[4]: 2
	[5]: 3
}

module.NECK_CLOTHES = {
	[2]: {
		Material('models/ppm2/clothesrender/winter_scarf_1.png')
		Material('models/ppm2/clothesrender/winter_scarf_2.png')
	}

	[3]: {
		{
			Material('models/ppm2/clothesrender/cape_stars_1.png')
			Material('models/ppm2/clothesrender/cape_stars_2.png')
			nil
		}
		{
			Material('models/ppm2/clothesrender/gem.png')
			nil
		}
	}

	[4]: {
		Material('models/ppm2/clothesrender/tie_1.png')
		Material('models/ppm2/clothesrender/tie_2.png')
	}

	[5]: {
		Material('models/ppm2/clothesrender/bowtie_1.png')
		Material('models/ppm2/clothesrender/bowtie_2.png')
	}
}

module.NECK_CLOTHES_INDEX = {
	[2]: 4
	[3]: {5, 6}
	[4]: 7
	[5]: 8
}

module.BODY_CLOTHES = {
	[2]: {
		Material('models/ppm2/clothesrender/vest_pouches.png')
		Material('models/ppm2/clothesrender/vest_string.png')
	}

	[3]: {
		Material('models/ppm2/clothesrender/shirt.png')
	}

	[4]: {
		Material('models/ppm2/clothesrender/hoodie.png')
	}

	[5]: {
		Material('models/ppm2/clothesrender/badge.png')
	}
}

module.BODY_CLOTHES_INDEX = {
	[2]: 9
	[3]: 10
	[4]: 11
	[5]: 12
}

module.EYE_CLOTHES = {
	[2]: {
		{}
		{Material('models/ppm2/clothesrender/lense.png')}
	}
	[4]: {
		{}
		{Material('models/ppm2/clothesrender/shades_lense.png')}
	}
	[6]: {
		{}
		{}
	}
	[8]: {
		{}
		{}
	}
}

module.EYE_CLOTHES[3] = module.EYE_CLOTHES[2]
module.EYE_CLOTHES[5] = module.EYE_CLOTHES[4]
module.EYE_CLOTHES[7] = module.EYE_CLOTHES[6]
module.EYE_CLOTHES[9] = module.EYE_CLOTHES[8]

module.EYE_CLOTHES_INDEX = {
	[2]: {13, 14}
	[4]: {15, 16}
	[6]: {17, 18}
	[8]: {20, 21}
}

module.EYE_CLOTHES_INDEX[3] = module.EYE_CLOTHES_INDEX[2]
module.EYE_CLOTHES_INDEX[5] = module.EYE_CLOTHES_INDEX[4]
module.EYE_CLOTHES_INDEX[7] = module.EYE_CLOTHES_INDEX[6]
module.EYE_CLOTHES_INDEX[9] = module.EYE_CLOTHES_INDEX[8]

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

PPM2.MaterialsRegistry = module
return module
