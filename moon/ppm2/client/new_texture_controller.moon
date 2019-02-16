
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


USE_HIGHRES_BODY = PPM2.USE_HIGHRES_BODY
USE_HIGHRES_TEXTURES = PPM2.USE_HIGHRES_TEXTURES

-- [ 1] = "models/ppm2/base/cmark",
-- [ 2] = "models/ppm2/base/tongue",
-- [ 3] = "models/ppm2/base/body",
-- [ 4] = "models/ppm2/base/eyelashes",
-- [ 5] = "models/ppm2/base/eye_r",
-- [ 6] = "models/ppm2/base/teeth",
-- [ 7] = "models/ppm2/base/mouth",
-- [ 8] = "models/ppm2/base/eye_l",
-- [ 9] = "models/ppm2/base/horn",
-- [10] = "models/ppm2/base/wings",
-- [11] = "models/ppm2/base/wing_bat",
-- [12] = "models/ppm2/base/wing_bat_skin",
-- [13] = "models/ppm2/base/hair_color_1",
-- [14] = "models/ppm2/base/tail_color_1"

class NewPonyTextureController extends PPM2.PonyTextureController
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	@UPPER_MANE_MATERIALS = {i, [val1 for _, val1 in ipairs val] for i, val in pairs @UPPER_MANE_MATERIALS}
	@LOWER_MANE_MATERIALS = {i, [val1 for _, val1 in ipairs val] for i, val in pairs @LOWER_MANE_MATERIALS}
	@TAIL_DETAIL_MATERIALS = {i, [val1 for _, val1 in ipairs val] for i, val in pairs @TAIL_DETAIL_MATERIALS}

	@PHONG_UPDATE_TRIGGER = {k, v for k, v in pairs PPM2.PonyTextureController.PHONG_UPDATE_TRIGGER}

	for _, ttype in ipairs {'Mouth', 'Teeth', 'Tongue'}
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongExponent'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongBoost'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongTint'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongFront'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongMiddle'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongSliding'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'Lightwarp'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'LightwarpURL'] = true

	@MAT_INDEX_CMARK = 0
	@MAT_INDEX_EYELASHES = 3
	@MAT_INDEX_TONGUE = 1
	@MAT_INDEX_BODY = 2
	@MAT_INDEX_TEETH = 5
	@MAT_INDEX_EYE_LEFT = 7
	@MAT_INDEX_EYE_RIGHT = 4
	@MAT_INDEX_MOUTH = 6
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
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
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

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_HAIR)

		urlTextures = {}
		left = 0

		continueCompilation = ->
			return unless @isValid
			{:r, :g, :b} = @GrabData("#{prefix}ManeColor1")
			@StartRTOpaque("Mane_rt_1_#{prefix}", texSize, r, g, b)

			maneTypeUpper = @GetManeType()
			if @@UPPER_MANE_MATERIALS[maneTypeUpper]
				i = 1
				for _, mat in ipairs @@UPPER_MANE_MATERIALS[maneTypeUpper]
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

			HairColor1Material\SetTexture('$basetexture', @EndRT())

			-- Second mane pass
			{:r, :g, :b} = @GrabData("#{prefix}ManeColor2")
			@StartRTOpaque("Mane_rt_2_#{prefix}", texSize, r, g, b)

			maneTypeLower = @GetManeTypeLower()
			if @@LOWER_MANE_MATERIALS[maneTypeLower]
				i = 1
				for _, mat in ipairs @@LOWER_MANE_MATERIALS[maneTypeLower]
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

			HairColor2Material\SetTexture('$basetexture', @EndRT())
			PPM2.DebugPrint('Compiled mane textures for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, 6
			detailURL = data["Get#{prefix}ManeURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		for _, {url, i} in ipairs validURLS
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
			@ApplyPhongData(@BatWingsMaterial, 'Wings')
			@ApplyPhongData(@BatWingsSkinMaterial, 'BatWingsSkin')

		if @GrabData('SeparateManePhong')
			@ApplyPhongData(@UpperManeColor1, 'UpperMane')
			@ApplyPhongData(@UpperManeColor2, 'UpperMane')
			@ApplyPhongData(@LowerManeColor1, 'LowerMane')
			@ApplyPhongData(@LowerManeColor2, 'LowerMane')

		@ApplyPhongData(@TeethMaterial, 'Teeth') if @TeethMaterial
		@ApplyPhongData(@MouthMaterial, 'Mouth') if @MouthMaterial
		@ApplyPhongData(@TongueMaterial, 'Tongue') if @TongueMaterial

	CompileBatWings: =>
		return unless @isValid
		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_BatWings"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/debug/debugwhite'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
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
		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_WING)

		continueCompilation = ->
			{:r, :g, :b} = @GrabData('BodyColor')
			{:r, :g, :b} = @GrabData('BatWingColor') if @GrabData('SeparateWings')
			@StartRTOpaque('BatWings_rt', texSize, r, g, b)

			for i, mat in pairs urlTextures
				{:r, :g, :b, :a} = @GetData()["GetBatWingURLColor#{i}"](@GetData())
				surface.SetDrawColor(r, g, b, a)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			@BatWingsMaterial\SetTexture('$basetexture', @EndRT())
			PPM2.DebugPrint('Compiled Bat Wings texture for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, 3
			detailURL = data["GetBatWingURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		for _, {url, i} in ipairs validURLS
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
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
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
		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_WING)

		continueCompilation = ->
			{:r, :g, :b} = @GrabData('BodyColor')
			{:r, :g, :b} = @GrabData('BatWingSkinColor') if @GrabData('SeparateWings')
			@StartRTOpaque('BatWingsSkin_rt', texSize, r, g, b)

			for i, mat in pairs urlTextures
				{:r, :g, :b, :a} = @GetData()["GetBatWingSkinURLColor#{i}"](@GetData())
				surface.SetDrawColor(r, g, b, a)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			@BatWingsSkinMaterial\SetTexture('$basetexture', @EndRT())
			PPM2.DebugPrint('Compiled Bat Wings skin texture for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, 3
			detailURL = data["GetBatWingSkinURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		for _, {url, i} in ipairs validURLS
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
			'$lightwarptexture': 'models/ppm2/base/lightwrap'
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

		{:r, :g, :b} = @GrabData('TeethColor')
		@TeethMaterialName = "!ppm2_#{@@SessionID}_#{@GetID()}_teeth"
		@TeethMaterial = CreateMaterial("ppm2_#{@@SessionID}_#{@GetID()}_teeth", 'VertexLitGeneric', textureData)
		@TeethMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
		@TeethMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

		{:r, :g, :b} = @GrabData('MouthColor')
		@MouthMaterialName = "!ppm2_#{@@SessionID}_#{@GetID()}_mouth"
		@MouthMaterial = CreateMaterial("ppm2_#{@@SessionID}_#{@GetID()}_mouth", 'VertexLitGeneric', textureData)
		@MouthMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
		@MouthMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

		{:r, :g, :b} = @GrabData('TongueColor')
		@TongueMaterialName = "!ppm2_#{@@SessionID}_#{@GetID()}_tongue"
		@TongueMaterial = CreateMaterial("ppm2_#{@@SessionID}_#{@GetID()}_tongue", 'VertexLitGeneric', textureData)
		@TongueMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
		@TongueMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

		@UpdatePhongData()
		PPM2.DebugPrint('Compiled mouth textures for ', @GetEntity(), ' as part of ', @)

		return @TeethMaterial, @MouthMaterial, @TongueMaterial

	CompileTextures: =>
		return if not @GetData()\IsValid()
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

	UpdateUpperMane: (ent = @GetEntity(), entMane) =>
		return unless @isValid
		return unless @compiled

		if not @GetData()\GetSeparateMane()
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetManeName(1))
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetManeName(2))
		else
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetUpperHairName(1))
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetUpperHairName(2))

	UpdateLowerMane: (ent = @GetEntity(), entMane) =>
		return unless @compiled
		return unless @isValid

		if not @GetData()\GetSeparateMane()
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetManeName(1))
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetManeName(2))
		else
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetLowerHairName(1))
			entMane\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetLowerHairName(2))

	UpdateTail: (ent = @GetEntity(), entTail) =>
		return unless @compiled
		return unless @isValid
		entTail\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR1, @GetTailName(1))
		entTail\SetSubMaterial(@@MAT_INDEX_HAIR_COLOR2, @GetTailName(2))

	PreDraw: (ent = @GetEntity(), drawingNewTask = false) =>
		return unless @compiled
		return unless @isValid
		@CheckReflections(ent)

		if @lastMaterialUpdate < RealTimeL() or @lastMaterialUpdateEnt ~= ent
			@lastMaterialUpdateEnt = ent
			@lastMaterialUpdate = RealTimeL() + 1
			ent\SetSubMaterial(@@MAT_INDEX_EYE_LEFT, @GetEyeName(true))
			ent\SetSubMaterial(@@MAT_INDEX_EYE_RIGHT, @GetEyeName(false))
			ent\SetSubMaterial(@@MAT_INDEX_TONGUE, @GetTongueName())
			ent\SetSubMaterial(@@MAT_INDEX_TEETH, @GetTeethName())
			ent\SetSubMaterial(@@MAT_INDEX_MOUTH, @GetMouthName())
			ent\SetSubMaterial(@@MAT_INDEX_BODY, @GetBodyName())
			ent\SetSubMaterial(@@MAT_INDEX_HORN, @GetHornName())
			ent\SetSubMaterial(@@MAT_INDEX_WINGS, @GetWingsName())
			ent\SetSubMaterial(@@MAT_INDEX_CMARK, @GetCMarkName())
			ent\SetSubMaterial(@@MAT_INDEX_EYELASHES, @EyelashesName)
			ent\SetSubMaterial(@@MAT_INDEX_WINGS_BAT, @GetBatWingsName())
			ent\SetSubMaterial(@@MAT_INDEX_WINGS_BAT_SKIN, @GetBatWingsSkinName())

		if drawingNewTask
			render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT, @GetEye(true))
			render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT, @GetEye(false))
			render.MaterialOverrideByIndex(@@MAT_INDEX_TONGUE, @GetTongue())
			render.MaterialOverrideByIndex(@@MAT_INDEX_TEETH, @GetTeeth())
			render.MaterialOverrideByIndex(@@MAT_INDEX_MOUTH, @GetMouth())
			render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
			render.MaterialOverrideByIndex(@@MAT_INDEX_HORN, @GetHorn())
			render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS, @GetWings())
			render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK, @GetCMark())
			render.MaterialOverrideByIndex(@@MAT_INDEX_EYELASHES, @Eyelashes)
			render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS_BAT, @GetBatWings())
			render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS_BAT_SKIN, @GetBatWingsSkin())

	PostDraw: (ent = @GetEntity(), drawingNewTask = false) =>
		return unless @compiled
		return unless @isValid
		return unless drawingNewTask
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

	ResetTextures: (ent = @GetEntity()) =>
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

PPM2.NewPonyTextureController = NewPonyTextureController
