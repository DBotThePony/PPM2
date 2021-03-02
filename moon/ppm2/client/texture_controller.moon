
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

-- Texture indexes (-1)
-- 1    =   models/ppm2/base/eye_l
-- 2    =   models/ppm2/base/eye_r
-- 3    =   models/ppm2/base/body
-- 4    =   models/ppm2/base/horn
-- 5    =   models/ppm2/base/wings
-- 6    =   models/ppm2/base/hair_color_1
-- 7    =   models/ppm2/base/hair_color_2
-- 8    =   models/ppm2/base/tail_color_1
-- 9    =   models/ppm2/base/tail_color_2
-- 10   =   models/ppm2/base/cmark
-- 11   =   models/ppm2/base/eyelashes

USE_HIGHRES_BODY = PPM2.USE_HIGHRES_BODY
USE_HIGHRES_TEXTURES = PPM2.USE_HIGHRES_TEXTURES

file.mkdir('ppm2_cache')

developer = ConVar('developer')

PPM2.IsValidURL = (url) ->
	print(debug.traceback()) if not isstring(url)
	url ~= '' and url\find('^https?://') and url or false

PPM2.BuildURLHTML = (url, width, height) ->
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

PPM2.HTML_MATERIAL_QUEUE =  PPM2.HTML_MATERIAL_QUEUE or {}
PPM2.URL_MATERIAL_CACHE =   PPM2.URL_MATERIAL_CACHE  or {}
PPM2.ALREADY_DOWNLOADING =  PPM2.ALREADY_DOWNLOADING or {}
PPM2.FAILED_TO_DOWNLOAD =   PPM2.FAILED_TO_DOWNLOAD  or {}

PPM2.TEXTURE_TASKS = PPM2.TEXTURE_TASKS or {}

coroutine_yield = coroutine.yield
coroutine_resume = coroutine.resume

PPM2.TextureCompileWorker = ->
	while true
		name, task = next(PPM2.TEXTURE_TASKS)

		if not name
			coroutine_yield()
		else
			PPM2.TEXTURE_TASKS[name] = nil
			PPM2.TEXTURE_TASK_CURRENT = name
			if IsValid(task[2])
				task[1](task[2])
				task[2].unfinished_tasks -= 1
			PPM2.TEXTURE_TASK_CURRENT = nil

PPM2.TextureCompileThread = PPM2.TextureCompileThread or coroutine.create(PPM2.TextureCompileWorker)

PPM2.URLThread = PPM2.URLThread or coroutine.create ->
	while true
		if not PPM2.HTML_MATERIAL_QUEUE[1]
			coroutine_yield()
		else
			data = table.remove(PPM2.HTML_MATERIAL_QUEUE, 1)

			panel = vgui.Create('DHTML')
			panel\SetVisible(false)
			panel\SetSize(data.width, data.height)
			panel\SetHTML(PPM2.BuildURLHTML(data.url, data.width, data.height))
			panel\Refresh()

			frame = 0

			panel.ConsoleMessage = (pnl, msg) ->
				if msg == 'FRAME'
					frame += 1

			systime = SysTime() + 8

			timeout = false

			while panel\IsLoading() or frame < 20
				if systime <= SysTime()
					timeout = true
					panel\Remove() if IsValid(panel)

					newMat = CreateMaterial("PPM2_URLMaterial_Failed_#{data.hash}", 'UnlitGeneric', {
						'$basetexture': 'null'
						'$ignorez': 1
						'$vertexcolor': 1
						'$vertexalpha': 1
						'$nolod': 1
						'$translucent': 1
					})

					PPM2.FAILED_TO_DOWNLOAD[data.index] = {
						texture: newMat\GetTexture('$basetexture')
						material: newMat
						index: data.index
						hash: data.hash
					}

					PPM2.ALREADY_DOWNLOADING[data.index] = nil

					for resolve in *data.resolve
						resolve(newMat\GetTexture('$basetexture'), newMat)

					break

				coroutine_yield()

			if not timeout
				panel\UpdateHTMLTexture()
				htmlmat = panel\GetHTMLMaterial()

				if htmlmat
					texture = htmlmat\GetTexture('$basetexture')
					texture\Download()

					newMat = CreateMaterial("PPM2_URLMaterial_#{data.hash}", 'UnlitGeneric', {
						'$basetexture': 'models/debug/debugwhite'
						'$ignorez': 1
						'$vertexcolor': 1
						'$vertexalpha': 1
						'$nolod': 1
					})

					newMat\SetTexture('$basetexture', texture)

					PPM2.URL_MATERIAL_CACHE[data.index] = {
						texture: texture
						material: newMat
						index: data.index
						hash: data.hash
					}

					PPM2.ALREADY_DOWNLOADING[data.index] = nil

					for resolve in *data.resolve
						resolve(texture, newMat)

				coroutine_yield()
				panel\Remove() if IsValid(panel)

PPM2.GetURLMaterial = (url, width = 512, height = 512) ->
	assert(isstring(url) and url\trim() ~= '', 'Must specify valid URL', 2)

	index = url .. '_' .. width .. '_' .. height

	if data = PPM2.FAILED_TO_DOWNLOAD[index]
		return DLib.Promise (resolve) -> resolve(data.texture, data.material)

	if data = PPM2.URL_MATERIAL_CACHE[index]
		return DLib.Promise (resolve) -> resolve(data.texture, data.material)

	if data = PPM2.ALREADY_DOWNLOADING[index]
		return DLib.Promise (resolve) -> table.insert(data.resolve, resolve)

	return DLib.Promise (resolve) ->
		data = {
			:url
			:width
			:height
			:index
			hash: DLib.Util.QuickSHA1(index)
			resolve: {resolve}
		}

		PPM2.ALREADY_DOWNLOADING[index] = data
		table.insert(PPM2.HTML_MATERIAL_QUEUE, data)

hook.Add 'Think', 'PPM2 Material Tasks', ->
	status, err = coroutine_resume(PPM2.URLThread)
	error(err) if not status

	status, err = coroutine_resume(PPM2.TextureCompileThread)

	if not status
		table.Empty(PPM2.PonyTextureController.LOCKED_RENDERTARGETS)
		PPM2.TextureCompileThread = coroutine.create(PPM2.TextureCompileWorker)
		error(err)

	return

hook.Add 'InvalidateMaterialCache', 'PPM2.WebTexturesCache', ->
	PPM2.HTML_MATERIAL_QUEUE = {}
	PPM2.URL_MATERIAL_CACHE = {}
	PPM2.ALREADY_DOWNLOADING = {}
	PPM2.FAILED_TO_DOWNLOAD = {}

PPM2.TextureTableHash = (input) ->
	hash = DLib.Util.SHA1()
	hash\Update(' ' .. tostring(value) .. ' ') for value in *input
	return hash\Digest()

DrawTexturedRectRotated = (x = 0, y = 0, width = 0, height = 0, rotation = 0) -> surface.DrawTexturedRectRotated(x + width / 2, y + height / 2, width, height, rotation)

GetMat = (matIn) ->
	return matIn if not isstring(matIn)
	return Material(matIn, 'smooth'), nil

LOCKED_RENDERTARGETS = PPM2.PonyTextureController and PPM2.PonyTextureController.LOCKED_RENDERTARGETS

class PPM2.PonyTextureController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	@HAIR_MATERIAL_COLOR = PPM2.MaterialsRegistry.HAIR_MATERIAL_COLOR
	@TAIL_MATERIAL_COLOR = PPM2.MaterialsRegistry.TAIL_MATERIAL_COLOR
	@WINGS_MATERIAL_COLOR = PPM2.MaterialsRegistry.WINGS_MATERIAL_COLOR
	@HORN_MATERIAL_COLOR = PPM2.MaterialsRegistry.HORN_MATERIAL_COLOR
	@BODY_MATERIAL = PPM2.MaterialsRegistry.BODY_MATERIAL
	@HORN_DETAIL_COLOR = PPM2.MaterialsRegistry.HORN_DETAIL_COLOR
	@EYE_OVAL = PPM2.MaterialsRegistry.EYE_OVAL
	@EYE_OVALS = PPM2.MaterialsRegistry.EYE_OVALS
	@EYE_GRAD = PPM2.MaterialsRegistry.EYE_GRAD
	@EYE_EFFECT = PPM2.MaterialsRegistry.EYE_EFFECT
	@EYE_LINE_L_1 = PPM2.MaterialsRegistry.EYE_LINE_L_1
	@EYE_LINE_R_1 = PPM2.MaterialsRegistry.EYE_LINE_R_1
	@EYE_LINE_L_2 = PPM2.MaterialsRegistry.EYE_LINE_L_2
	@EYE_LINE_R_2 = PPM2.MaterialsRegistry.EYE_LINE_R_2
	@PONY_SOCKS = PPM2.MaterialsRegistry.PONY_SOCKS

	--@SessionID = math.random(1, 1000)
	@SessionID = 0

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

	@NEXT_GENERATED_ID = 100000

	@BODY_UPDATE_TRIGGER = {}
	@MANE_UPDATE_TRIGGER = {'ManeType': true, 'ManeTypeLower': true}
	@TAIL_UPDATE_TRIGGER = {'TailType': true}
	@EYE_UPDATE_TRIGGER = {'SeparateEyes': true}
	@PHONG_UPDATE_TRIGGER = {
		'SeparateHornPhong': true
		'SeparateWingsPhong': true
		'SeparateManePhong': true
		'SeparateTailPhong': true
	}

	@CLOTHES_UPDATE_HEAD = {
		'HeadClothes': true
		'HeadClothesUseColor': true
	}

	@CLOTHES_UPDATE_NECK = {
		'NeckClothes': true
		'NeckClothesUseColor': true
	}

	@CLOTHES_UPDATE_BODY = {
		'BodyClothes': true
		'BodyClothesUseColor': true
	}

	@CLOTHES_UPDATE_EYES = {
		'EyeClothes': true
		'EyeClothesUseColor': true
	}

	for i = 1, PPM2.MAX_CLOTHES_COLORS
		@CLOTHES_UPDATE_HEAD["HeadClothesColor#{i}"] = true
		@CLOTHES_UPDATE_NECK["NeckClothesColor#{i}"] = true
		@CLOTHES_UPDATE_BODY["BodyClothesColor#{i}"] = true
		@CLOTHES_UPDATE_EYES["EyeClothesColor#{i}"] = true

	for i = 1, PPM2.MAX_CLOTHES_URLS
		@CLOTHES_UPDATE_HEAD["HeadClothesURL#{i}"] = true
		@CLOTHES_UPDATE_NECK["NeckClothesURL#{i}"] = true
		@CLOTHES_UPDATE_BODY["BodyClothesURL#{i}"] = true
		@CLOTHES_UPDATE_EYES["EyeClothesURL#{i}"] = true

	for _, ttype in ipairs {'Body', 'Horn', 'Wings', 'BatWingsSkin', 'Socks', 'Mane', 'Tail', 'UpperMane', 'LowerMane', 'LEye', 'REye', 'BEyes', 'Eyelashes'}
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongExponent'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongBoost'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongTint'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongFront'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongMiddle'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'PhongSliding'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'Lightwarp'] = true
		@PHONG_UPDATE_TRIGGER[ttype .. 'LightwarpURL'] = true

	for _, publicName in ipairs {'', 'Left', 'Right'}
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
		@EYE_UPDATE_TRIGGER["PonySize"] = true
		@EYE_UPDATE_TRIGGER["EyeRefract#{publicName}"] = true
		@EYE_UPDATE_TRIGGER["EyeCornerA#{publicName}"] = true
		@EYE_UPDATE_TRIGGER["EyeLineDirection#{publicName}"] = true
		@EYE_UPDATE_TRIGGER["LEyeLightwarp"] = true
		@EYE_UPDATE_TRIGGER["REyeLightwarp"] = true
		@EYE_UPDATE_TRIGGER["LEyeLightwarpURL"] = true
		@EYE_UPDATE_TRIGGER["REyeLightwarpURL"] = true
		@EYE_UPDATE_TRIGGER["BEyesLightwarp"] = true
		@EYE_UPDATE_TRIGGER["BEyesLightwarpURL"] = true

	for i = 1, 6
		@MANE_UPDATE_TRIGGER["ManeColor#{i}"] = true
		@MANE_UPDATE_TRIGGER["ManeDetailColor#{i}"] = true
		@MANE_UPDATE_TRIGGER["ManeURLColor#{i}"] = true
		@MANE_UPDATE_TRIGGER["ManeURL#{i}"] = true
		@MANE_UPDATE_TRIGGER["TailURL#{i}"] = true
		@MANE_UPDATE_TRIGGER["TailURLColor#{i}"] = true

		@TAIL_UPDATE_TRIGGER["TailColor#{i}"] = true
		@TAIL_UPDATE_TRIGGER["TailDetailColor#{i}"] = true

	for i = 1, PPM2.MAX_BODY_DETAILS
		@BODY_UPDATE_TRIGGER["BodyDetail#{i}"] = true
		@BODY_UPDATE_TRIGGER["BodyDetailColor#{i}"] = true
		@BODY_UPDATE_TRIGGER["BodyDetailURLColor#{i}"] = true
		@BODY_UPDATE_TRIGGER["BodyDetailURL#{i}"] = true
		@BODY_UPDATE_TRIGGER["BodyDetailGlow#{i}"] = true
		@BODY_UPDATE_TRIGGER["BodyDetailGlowStrength#{i}"] = true
		@BODY_UPDATE_TRIGGER["BodyDetailFirst#{i}"] = true
		@BODY_UPDATE_TRIGGER["BodyDetailURLFirst#{i}"] = true

	for i = 1, PPM2.MAX_TATTOOS
		@BODY_UPDATE_TRIGGER["TattooType#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooPosX#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooPosY#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooRotate#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooScaleX#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooScaleY#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooColor#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooGlow#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooGlowStrength#{i}"] = true
		@BODY_UPDATE_TRIGGER["TattooOverDetail#{i}"] = true

	@GetCache = (index) =>
		hash = DLib.Util.QuickSHA1(index)
		path = 'ppm2_cache/' .. hash\sub(1, 2) .. '/' .. hash .. '.vtf'
		return if not file.Exists(path, 'DATA')
		return '../data/' .. path

	@SetCache = (index, value) =>
		hash = DLib.Util.QuickSHA1(index)
		file.mkdir('ppm2_cache/' .. hash\sub(1, 2))
		path = 'ppm2_cache/' .. hash\sub(1, 2) .. '/' .. hash .. '.vtf'
		file.Write(path, value)
		return '../data/' .. path

	@GetCacheH = (hash) =>
		path = 'ppm2_cache/' .. hash\sub(1, 2) .. '/' .. hash .. '.vtf'
		return if not file.Exists(path, 'DATA')
		return '../data/' .. path

	@SetCacheH = (hash, value) =>
		file.mkdir('ppm2_cache/' .. hash\sub(1, 2))
		path = 'ppm2_cache/' .. hash\sub(1, 2) .. '/' .. hash .. '.vtf'
		file.Write(path, value)
		return '../data/' .. path

	@LOCKED_RENDERTARGETS = LOCKED_RENDERTARGETS or {}
	@LOCKED_RENDERTARGETS_MASK = LOCKED_RENDERTARGETS_MASK or {}

	@LockRenderTarget = (width, height, r = 0, g = 0, b = 0, a = 255) =>
		index = string.format('PPM2_buffer_%d_%d', width, height)

		while @LOCKED_RENDERTARGETS[index]
			coroutine_yield()

		@LOCKED_RENDERTARGETS[index] = true

		rt = GetRenderTarget(index, width, height)

		render.PushRenderTarget(rt)
		render.Clear(r, g, b, a, true, true)

		--render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		--render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		cam.Start2D()

		surface.SetDrawColor(r, g, b, a)

		mat = CreateMaterial(index .. 'a', 'UnlitGeneric', {
			'$basetexture': '!' .. index,
			'$translucent': '1',
		})

		mat\SetTexture('$basetexture', rt)

		return rt, mat

	@ReleaseRenderTarget = (width, height, no_pop = false) =>
		index = string.format('PPM2_buffer_%d_%d', width, height)
		@LOCKED_RENDERTARGETS[index] = false

		--render.PopFilterMin()
		--render.PopFilterMag()

		if not no_pop
			cam.End2D()
			render.PopRenderTarget()

	@LockRenderTargetMask = (width, height) =>
		index = string.format('PPM2_mask_%d_%d', width, height)

		while @LOCKED_RENDERTARGETS_MASK[index]
			coroutine_yield()

		@LOCKED_RENDERTARGETS_MASK[index] = true

		index2 = string.format('PPM2_mask2_%d_%d', width, height)
		rt1, rt2 = GetRenderTarget(index, width, height), GetRenderTarget(index2, width, height)

		mat1, mat2 = CreateMaterial(index .. 'b', 'UnlitGeneric', {
			'$basetexture': '!' .. index,
			'$translucent': '1',
		}), CreateMaterial(index2 .. 'b', 'UnlitGeneric', {
			'$basetexture': '!' .. index2,
			'$translucent': '1',
		})

		mat1\SetTexture('$basetexture', rt1)
		mat2\SetTexture('$basetexture', rt2)

		return rt1, rt2, mat1, mat2

	@ReleaseRenderTargetMask = (width, height) =>
		index = string.format('PPM2_mask_%d_%d', width, height)
		@LOCKED_RENDERTARGETS_MASK[index] = false

	new: (controller, compile = true) =>
		super(controller\GetData())

		@isValid = true
		@cachedENT = @GetEntity()
		@id = @GetEntity()\EntIndex()
		@load_tickets = {}

		if @id == -1
			@clientsideID = true
			@id = @@NEXT_GENERATED_ID
			@@NEXT_GENERATED_ID += 1

		@compiled = false
		@lastMaterialUpdate = 0
		@lastMaterialUpdateEnt = NULL
		@delayCompilation = {}
		@unfinished_tasks = 0
		@processing_first = true
		@CompileTextures() if compile
		hook.Add('InvalidateMaterialCache', @, @InvalidateMaterialCache)
		PPM2.DebugPrint('Created new texture controller for ', @GetEntity(), ' as part of ', controller, '; internal ID is ', @id)

	CreateRenderTask: (func = '', ...) =>
		index = string.format('%p%s', @, func)
		return if PPM2.TEXTURE_TASKS[index]
		@unfinished_tasks += 1
		PPM2.TEXTURE_TASKS[index] = {@[func], @}

	CreateInstantRenderTask: (...) => @CreateRenderTask(...) -- TODO?

	IsBeingProcessed: => @unfinished_tasks > 0

	DataChanges: (state) =>
		return unless @isValid
		return if not @GetEntity()
		key = state\GetKey()

		if key\find('Separate') and key\find('Phong')
			@UpdatePhongData()
			return

		switch key
			when 'BodyColor'
				@CreateRenderTask('CompileBody')
				@CreateRenderTask('CompileWings')
				@CreateRenderTask('CompileHorn')
			when 'EyelashesColor'
				@CreateRenderTask('CompileEyelashes')
			when 'BodyBumpStrength', 'Socks', 'Bodysuit', 'LipsColor', 'NoseColor', 'LipsColorInherit', 'NoseColorInherit', 'EyebrowsColor', 'GlowingEyebrows', 'EyebrowsGlowStrength'
				@CreateRenderTask('CompileBody')
			when 'CMark', 'CMarkType', 'CMarkURL', 'CMarkColor', 'CMarkSize'
				@CreateRenderTask('CompileCMark')
			when 'SocksColor', 'SocksTextureURL', 'SocksTexture', 'SocksDetailColor1', 'SocksDetailColor2', 'SocksDetailColor3', 'SocksDetailColor4', 'SocksDetailColor5', 'SocksDetailColor6'
				@CreateRenderTask('CompileSocks')
			when 'NewSocksColor1', 'NewSocksColor2', 'NewSocksColor3', 'NewSocksTextureURL'
				@CreateRenderTask('CompileNewSocks')
			when 'HornURL1', 'SeparateHorn', 'HornColor', 'HornURL2', 'HornURL3', 'HornURLColor1', 'HornURLColor2', 'HornURLColor3', 'UseHornDetail', 'HornGlow', 'HornGlowSrength', 'HornDetailColor'
				@CreateRenderTask('CompileHorn')
			when 'WingsURL1', 'WingsURL2', 'WingsURL3', 'WingsURLColor1', 'WingsURLColor2', 'WingsURLColor3', 'SeparateWings', 'WingsColor'
				@CreateRenderTask('CompileWings')
			else
				if @@MANE_UPDATE_TRIGGER[key]
					@CreateRenderTask('CompileHair')
				elseif @@TAIL_UPDATE_TRIGGER[key]
					@CreateRenderTask('CompileTail')
				elseif @@EYE_UPDATE_TRIGGER[key]
					@CreateInstantRenderTask('CompileLeftEye')
					@CreateInstantRenderTask('CompileRightEye')
				elseif @@BODY_UPDATE_TRIGGER[key]
					@CreateRenderTask('CompileBody')
				elseif @@PHONG_UPDATE_TRIGGER[key]
					@UpdatePhongData()
				elseif @@CLOTHES_UPDATE_HEAD[key]
					@CreateRenderTask('CompileHeadClothes')
				elseif @@CLOTHES_UPDATE_EYES[key]
					@CreateRenderTask('CompileEyeClothes')
				elseif @@CLOTHES_UPDATE_NECK[key]
					@CreateRenderTask('CompileNeckClothes')
				elseif @@CLOTHES_UPDATE_BODY[key]
					@CreateRenderTask('CompileBodyClothes')

	PutTicket: (name) =>
		@load_tickets[name] = (@load_tickets[name] or 0) + 1
		return @load_tickets[name]

	CheckTicket: (name, value) =>
		return @load_tickets[name] == value

	InvalidateMaterialCache: =>
		timer.Simple 0, -> @CompileTextures()

	Remove: =>
		@isValid = false
		@ResetTextures()

	IsValid: => IsValid(@GetEntity()) and @isValid and @compiled and @GetData()\IsValid()

	GetID: =>
		return @GetObjectSlot() if @GetObjectSlot()
		return @id if @clientsideID

		if @GetEntity() ~= @cachedENT
			@cachedENT = @GetEntity()
			@id = @GetEntity()\EntIndex()
			if @id == -1
				@id = @@NEXT_GENERATED_ID
				@@NEXT_GENERATED_ID += 1
				@CompileTextures() if @compiled

		return @id

	GetBody: => @BodyMaterial
	GetBodyName: => @BodyMaterialName
	GetSocks: => @SocksMaterial
	GetSocksName: => @SocksMaterialName
	GetNewSocks: => @NewSocksColor1, @NewSocksColor2, @NewSocksBase
	GetNewSocksName: => @NewSocksColor1Name, @NewSocksColor2Name, @NewSocksBaseName
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

	CompileTextures: (now = false) =>
		return if not @GetData()\IsValid()

		if now
			@CreateInstantRenderTask('CompileBody')
			@CreateInstantRenderTask('CompileHair')
			@CreateInstantRenderTask('CompileTail')
			@CreateInstantRenderTask('CompileHorn')
			@CreateInstantRenderTask('CompileWings')
			@CreateInstantRenderTask('CompileCMark')
			@CreateInstantRenderTask('CompileSocks')
			@CreateInstantRenderTask('CompileNewSocks')
			@CreateInstantRenderTask('CompileEyelashes')
			@CreateInstantRenderTask('CompileLeftEye')
			@CreateInstantRenderTask('CompileRightEye')
			@CreateInstantRenderTask('CompileBodyClothes')
			@CreateInstantRenderTask('CompileNeckClothes')
			@CreateInstantRenderTask('CompileHeadClothes')
			@CreateInstantRenderTask('CompileEyeClothes')
		else
			@CreateRenderTask('CompileBody')
			@CreateRenderTask('CompileHair')
			@CreateRenderTask('CompileTail')
			@CreateRenderTask('CompileHorn')
			@CreateRenderTask('CompileWings')
			@CreateRenderTask('CompileCMark')
			@CreateRenderTask('CompileSocks')
			@CreateRenderTask('CompileNewSocks')
			@CreateRenderTask('CompileEyelashes')
			@CreateRenderTask('CompileLeftEye')
			@CreateRenderTask('CompileRightEye')
			@CreateRenderTask('CompileBodyClothes')
			@CreateRenderTask('CompileNeckClothes')
			@CreateRenderTask('CompileHeadClothes')
			@CreateRenderTask('CompileEyeClothes')

		@compiled = true

	PreDraw: (ent = @GetEntity(), drawingNewTask = false) =>
		--return unless @compiled
		return unless @isValid

		if @lastMaterialUpdate < RealTimeL() or @lastMaterialUpdateEnt ~= ent
			@lastMaterialUpdateEnt = ent
			@lastMaterialUpdate = RealTimeL() + 1
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
			ent\SetSubMaterial(@@MAT_INDEX_EYELASHES, @EyelashesName)

		if drawingNewTask
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
			render.MaterialOverrideByIndex(@@MAT_INDEX_EYELASHES, @Eyelashes)

	PostDraw: (ent = @GetEntity(), drawingNewTask = false) =>
		--return unless @compiled
		return unless @isValid
		return unless drawingNewTask
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

	ResetTextures: (ent = @GetEntity()) =>
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

	PreDrawLegs: (ent = @GetEntity()) =>
		--return unless @compiled
		return unless @isValid
		render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
		render.MaterialOverrideByIndex(@@MAT_INDEX_HORN, @GetHorn())
		render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS, @GetWings())
		render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK, @GetCMark())

	PostDrawLegs: (ent = @GetEntity()) =>
		--return unless @compiled
		return unless @isValid
		render.MaterialOverrideByIndex(@@MAT_INDEX_BODY)
		render.MaterialOverrideByIndex(@@MAT_INDEX_HORN)
		render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS)
		render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK)

	@MAT_INDEX_SOCKS = 0

	UpdateSocks: (ent = @GetEntity(), socksEnt) =>
		return unless @isValid
		socksEnt\SetSubMaterial(@@MAT_INDEX_SOCKS, @GetSocksName())

	UpdateNewSocks: (ent = @GetEntity(), socksEnt) =>
		return unless @isValid
		socksEnt\SetSubMaterial(0, @NewSocksColor2Name)
		socksEnt\SetSubMaterial(1, @NewSocksColor1Name)
		socksEnt\SetSubMaterial(2, @NewSocksBaseName)

	UpdateNewHorn: (ent = @GetEntity(), hornEnt) =>
		return unless @isValid
		hornEnt\SetSubMaterial(0, @HornMaterialName1)
		hornEnt\SetSubMaterial(1, @HornMaterialName2)

	UpdateClothes: (ent = @GetEntity(), clothesEnt) =>
		return unless @isValid

		if @NeckClothes_Index
			if @NeckClothes_MatName
				clothesEnt\SetSubMaterial(@NeckClothes_Index[index], @NeckClothes_MatName[index]) for index = 1, @NeckClothes_Index.size
			else
				clothesEnt\SetSubMaterial(index, '') for index in *@NeckClothes_Index

		if @EyeClothes_Index
			if @EyeClothes_MatName
				clothesEnt\SetSubMaterial(@EyeClothes_Index[index], @EyeClothes_MatName[index]) for index = 1, @EyeClothes_Index.size
			else
				clothesEnt\SetSubMaterial(index, '') for index in *@EyeClothes_Index

		if @HeadClothes_Index
			if @HeadClothes_MatName
				clothesEnt\SetSubMaterial(@HeadClothes_Index[index], @HeadClothes_MatName[index]) for index = 1, @HeadClothes_Index.size
			else
				clothesEnt\SetSubMaterial(index, '') for index in *@HeadClothes_Index

		if @BodyClothes_Index
			if @BodyClothes_MatName
				clothesEnt\SetSubMaterial(@BodyClothes_Index[index], @BodyClothes_MatName[index]) for index = 1, @BodyClothes_Index.size
			else
				clothesEnt\SetSubMaterial(index, '') for index in *@BodyClothes_Index

		@clothesModel = clothesEnt

	@QUAD_SIZE_EYES = 512
	@QUAD_SIZE_SOCKS = 512
	@QUAD_SIZE_CLOTHES_BODY = 1024
	@QUAD_SIZE_CLOTHES_HEAD = 512
	@QUAD_SIZE_CLOTHES_NECK = 512
	@QUAD_SIZE_CLOTHES_EYES = 256
	@QUAD_SIZE_CMARK = 512
	@QUAD_SIZE_CONST = 512
	@QUAD_SIZE_WING = 64
	@QUAD_SIZE_HORN = 512
	@QUAD_SIZE_HAIR = 256
	@QUAD_SIZE_TAIL = 256
	@QUAD_SIZE_BODY = 2048
	@TATTOO_DEF_SIZE = 128

	DrawTattoo: (index = 1, drawingGlow = false, texSize = @@QUAD_SIZE_BODY) =>
		mat = PPM2.MaterialsRegistry.TATTOOS[@GrabData("TattooType#{index}")]
		return if not mat

		X, Y = @GrabData("TattooPosX#{index}"), @GrabData("TattooPosY#{index}")

		TattooRotate = @GrabData("TattooRotate#{index}")
		TattooScaleX = @GrabData("TattooScaleX#{index}")
		TattooScaleY = @GrabData("TattooScaleY#{index}")

		if not drawingGlow
			{:r, :g, :b} = @GrabData("TattooColor#{index}")
			surface.SetDrawColor(r, g, b)
		else
			if @GrabData("TattooGlow#{index}")
				surface.SetDrawColor(255, 255, 255, 255 * @GrabData("TattooGlowStrength#{index}"))
			else
				surface.SetDrawColor(0, 0, 0)

		surface.SetMaterial(mat)
		tSize = @@TATTOO_DEF_SIZE * (USE_HIGHRES_BODY\GetInt() + 1)
		sizeX, sizeY = tSize * TattooScaleX, tSize * TattooScaleY
		surface.DrawTexturedRectRotated((X * texSize / 2) / 100 + texSize / 2, -(Y * texSize / 2) / 100 + texSize / 2, sizeX, sizeY, TattooRotate)

	ApplyPhongData: (matTarget, prefix = 'Body', lightwarpsOnly = false, noBump = false) =>
		return if not matTarget
		PhongExponent = @GrabData(prefix .. 'PhongExponent')
		PhongBoost = @GrabData(prefix .. 'PhongBoost')
		PhongTint = @GrabData(prefix .. 'PhongTint')
		PhongFront = @GrabData(prefix .. 'PhongFront')
		PhongMiddle = @GrabData(prefix .. 'PhongMiddle')
		Lightwarp = @GrabData(prefix .. 'Lightwarp')
		LightwarpURL = PPM2.IsValidURL(@GrabData(prefix .. 'LightwarpURL'))
		BumpmapURL = PPM2.IsValidURL(@GrabData(prefix .. 'BumpmapURL'))
		PhongSliding = @GrabData(prefix .. 'PhongSliding')
		{:r, :g, :b} = PhongTint
		r /= 255
		g /= 255
		b /= 255
		PhongTint = Vector(r, g, b)
		PhongFresnel = Vector(PhongFront, PhongMiddle, PhongSliding)

		if not lightwarpsOnly
			with matTarget
				\SetFloat('$phongexponent', PhongExponent)
				\SetFloat('$phongboost', PhongBoost)
				\SetVector('$phongtint', PhongTint)
				\SetVector('$phongfresnelranges', PhongFresnel)

		if LightwarpURL
			ticket = @PutTicket(prefix .. '_phong')

			PPM2.GetURLMaterial(LightwarpURL, 256, 16)\Then (tex, mat) ->
				return if not @CheckTicket(prefix .. '_phong', ticket)
				matTarget\SetTexture('$lightwarptexture', tex)
		else
			myTex = PPM2.AvaliableLightwarpsPaths[Lightwarp + 1] or PPM2.AvaliableLightwarpsPaths[1]
			matTarget\SetTexture('$lightwarptexture', myTex)

		if not noBump
			if BumpmapURL
				ticket = @PutTicket(prefix .. '_bump')

			    PPM2.GetURLMaterial(BumpmapURL, matTarget\Width(), matTarget\Height())\Then (tex, mat) ->
			        return if not @CheckTicket(prefix .. '_bump', ticket)
			        matTarget\SetTexture('$bumpmap', tex)
			else
			    matTarget\SetUndefined('$bumpmap')

	GetBodyPhongMaterials: (output = {}) =>
		table.insert(output, {@BodyMaterial, false, false}) if @BodyMaterial
		table.insert(output, {@HornMaterial, false, true}) if @HornMaterial and not @GrabData('SeparateHornPhong')
		table.insert(output, {@HornMaterial1, false, true}) if @HornMaterial1 and not @GrabData('SeparateHornPhong')
		table.insert(output, {@HornMaterial2, false, true}) if @HornMaterial2 and not @GrabData('SeparateHornPhong')
		table.insert(output, {@WingsMaterial, false, false}) if @WingsMaterial and not @GrabData('SeparateWingsPhong')
		table.insert(output, {@Eyelashes, false, false}) if @Eyelashes and not @GrabData('SeparateEyelashesPhong')

		if not @GrabData('SeparateManePhong')
			table.insert(output, {@HairColor1Material, false, false}) if @HairColor1Material
			table.insert(output, {@HairColor2Material, false, false}) if @HairColor2Material
		if not @GrabData('SeparateTailPhong')
			table.insert(output, {@TailColor1Material, false, false}) if @TailColor1Material
			table.insert(output, {@TailColor2Material, false, false}) if @TailColor2Material

	UpdatePhongData: =>
		proceed = {}
		@GetBodyPhongMaterials(proceed)
		for _, mat in ipairs proceed
			@ApplyPhongData(mat[1], 'Body', mat[2], mat[3], mat[4])

		if @GrabData('SeparateHornPhong')
			@ApplyPhongData(@HornMaterial, 'Horn', false, true) if @HornMaterial
			@ApplyPhongData(@HornMaterial1, 'Horn', false, true) if @HornMaterial1
			@ApplyPhongData(@HornMaterial2, 'Horn', false, true) if @HornMaterial2

		if @GrabData('SeparateEyelashesPhong') and @Eyelashes
			@ApplyPhongData(@Eyelashes, 'Eyelashes', false, true)

		if @GrabData('SeparateWingsPhong') and @WingsMaterial
			@ApplyPhongData(@WingsMaterial, 'Wings')

		@ApplyPhongData(@SocksMaterial, 'Socks') if @SocksMaterial
		@ApplyPhongData(@NewSocksColor1, 'Socks') if @NewSocksColor1
		@ApplyPhongData(@NewSocksColor2, 'Socks') if @NewSocksColor2
		@ApplyPhongData(@NewSocksBase, 'Socks') if @NewSocksBase

		if @GrabData('SeparateManePhong')
			@ApplyPhongData(@HairColor1Material, 'Mane')
			@ApplyPhongData(@HairColor2Material, 'Mane')

		if @GrabData('SeparateTailPhong')
			@ApplyPhongData(@TailColor1Material, 'Tail')
			@ApplyPhongData(@TailColor2Material, 'Tail')

		if @GrabData('SeparateEyes')
			@ApplyPhongData(@EyeMaterialL, 'LEye', true)
			@ApplyPhongData(@EyeMaterialR, 'REye', true)
		else
			@ApplyPhongData(@EyeMaterialL, 'BEyes', true)
			@ApplyPhongData(@EyeMaterialR, 'BEyes', true)

	CompileBody: =>
		return unless @isValid

		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Body"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/ppm2/base/body'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
				'$halflambert': '1'
				'$selfillum': '1'
				'$selfillummask': 'null'
				'$bumpmap': 'null-bumpmap'

				'$color': '{255 255 255}'
				'$color2': '{255 255 255}'
				'$model': '1'
				'$phong': '1'
				'$phongexponent': '3'
				'$phongboost': '0.15'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[0.5 6 10]'

				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'
			}
		}

		hash = {
			'body'
			@GrabData('BodyColor')
			@GrabData('LipsColorInherit')
			@GrabData('LipsColor')
			@GrabData('NoseColorInherit')
			@GrabData('NoseColor')
			@GrabData('Socks')
			@GrabData('Bodysuit')
			@GrabData('EyebrowsColor')
		}

		for i = 1, PPM2.MAX_BODY_DETAILS
			table.insert(hash, PPM2.IsValidURL(@GrabData("BodyDetailURL#{i}")))
			table.insert(hash, @GrabData("BodyDetailFirst#{i}"))
			table.insert(hash, @GrabData("BodyDetail#{i}"))
			table.insert(hash, @GrabData("BodyDetailColor#{i}"))

		for i = 1, PPM2.MAX_TATTOOS
			table.insert(hash, @GrabData("TattooType#{i}"))
			table.insert(hash, @GrabData("TattooOverDetail#{i}"))
			table.insert(hash, @GrabData("TattooPosX#{i}"))
			table.insert(hash, @GrabData("TattooRotate#{i}"))
			table.insert(hash, @GrabData("TattooScaleX#{i}"))
			table.insert(hash, @GrabData("TattooScaleY#{i}"))
			table.insert(hash, @GrabData("TattooColor#{i}"))

		hash = PPM2.TextureTableHash(hash)
		texSize = @@QUAD_SIZE_BODY

		@BodyMaterialName = "!#{textureData.name\lower()}"
		@BodyMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)

		if getcache = @@GetCacheH(hash)
			@BodyMaterial\SetTexture('$basetexture', getcache)
			@BodyMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			urlTextures = {}

			for i = 1, PPM2.MAX_BODY_DETAILS
				if geturl = PPM2.IsValidURL(@GrabData("BodyDetailURL#{i}"))
					urlTextures[i] = select(2, PPM2.GetURLMaterial(geturl, texSize, texSize)\Await())
					return unless @isValid

			@UpdatePhongData()

			{:r, :g, :b} = @GrabData('BodyColor')

			@@LockRenderTarget(texSize, texSize, r, g, b)

			for i = 1, PPM2.MAX_BODY_DETAILS
				if @GrabData('BodyDetailFirst' .. i)
					if mat = PPM2.MaterialsRegistry.BODY_DETAILS[@GrabData("BodyDetail#{i}")]
						surface.SetDrawColor(@GrabData("BodyDetailColor#{i}"))
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, texSize, texSize)

			surface.SetDrawColor(255, 255, 255)

			for i, mat in pairs urlTextures
				if @GrabData('BodyDetailURLFirst' .. i)
					surface.SetDrawColor(@GrabData("BodyDetailURLColor#{i}"))
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, texSize, texSize)

			surface.SetDrawColor(@GrabData('EyebrowsColor'))
			surface.SetMaterial(PPM2.MaterialsRegistry.EYEBROWS)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			if not @GrabData('LipsColorInherit')
				surface.SetDrawColor(@GrabData('LipsColor'))
			else
				{:r, :g, :b} = @GrabData('BodyColor')
				r, g, b = math.max(r - 30, 0), math.max(g - 30, 0), math.max(b - 30, 0)
				surface.SetDrawColor(r, g, b)

			surface.SetMaterial(PPM2.MaterialsRegistry.LIPS)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			if not @GrabData('NoseColorInherit')
				surface.SetDrawColor(@GrabData('NoseColor'))
			else
				{:r, :g, :b} = @GrabData('BodyColor')
				r, g, b = math.max(r - 30, 0), math.max(g - 30, 0), math.max(b - 30, 0)
				surface.SetDrawColor(r, g, b)

			surface.SetMaterial(PPM2.MaterialsRegistry.NOSE)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			@DrawTattoo(i) for i = 1, PPM2.MAX_TATTOOS when @GrabData("TattooOverDetail#{i}")

			for i = 1, PPM2.MAX_BODY_DETAILS
				if not @GrabData('BodyDetailFirst' .. i)
					if mat = PPM2.MaterialsRegistry.BODY_DETAILS[@GrabData("BodyDetail#{i}")]
						surface.SetDrawColor(@GrabData("BodyDetailColor#{i}"))
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, texSize, texSize)

			surface.SetDrawColor(255, 255, 255)

			for i, mat in pairs urlTextures
				if not @GrabData('BodyDetailURLFirst' .. i)
					surface.SetDrawColor(@GrabData("BodyDetailURLColor#{i}"))
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, texSize, texSize)

			@DrawTattoo(i) for i = 1, PPM2.MAX_TATTOOS when @GrabData("TattooOverDetail#{i}")

			if suit = PPM2.MaterialsRegistry.SUITS[@GrabData('Bodysuit')]
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(suit)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			if @GrabData('Socks')
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(@@PONY_SOCKS)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)

			path = @@SetCacheH(hash, vtf\ToString())

			@BodyMaterial\SetTexture('$basetexture', path)
			@BodyMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()

		texSize = texSize / 2

		hash_bump = PPM2.TextureTableHash({
			'body bump'
			math.floor(@GrabData('BodyBumpStrength') * 255)
		})

		if getcache = @@GetCacheH(hash_bump)
			@BodyMaterial\SetTexture('$bumpmap', getcache)
			@BodyMaterial\GetTexture('$bumpmap')\Download() if developer\GetBool()
		else
			@@LockRenderTarget(texSize, texSize, 127, 127, 255)

			surface.SetDrawColor(255, 255, 255, @GrabData('BodyBumpStrength') * 255)
			surface.SetMaterial(PPM2.MaterialsRegistry.BODY_BUMP)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash_bump, vtf\ToString())

			@BodyMaterial\SetTexture('$bumpmap', path)
			@BodyMaterial\GetTexture('$bumpmap')\Download() if developer\GetBool()

		hash_glow = {
			'body illum'
			@GrabData('GlowingEyebrows')
			math.floor(@GrabData('EyebrowsGlowStrength') * 255)
		}

		for i = 1, PPM2.MAX_BODY_DETAILS
			table.insert(hash_glow, @GrabData("BodyDetail#{i}"))
			table.insert(hash_glow, math.floor(@GrabData("BodyDetailGlowStrength#{i}") * 255))
			table.insert(hash_glow, @GrabData("BodyDetailGlow#{i}"))

		for i = 1, PPM2.MAX_TATTOOS
			table.insert(hash_glow, math.floor(@GrabData("TattooGlowStrength#{i}") * 255))
			table.insert(hash_glow, @GrabData("TattooGlow#{i}"))
			table.insert(hash_glow, @GrabData("TattooType#{i}"))
			table.insert(hash_glow, @GrabData("TattooOverDetail#{i}"))
			table.insert(hash_glow, @GrabData("TattooPosX#{i}"))
			table.insert(hash_glow, @GrabData("TattooRotate#{i}"))
			table.insert(hash_glow, @GrabData("TattooScaleX#{i}"))
			table.insert(hash_glow, @GrabData("TattooScaleY#{i}"))

		hash_glow = PPM2.TextureTableHash(hash_glow)

		if getcache = @@GetCacheH(hash_glow)
			@BodyMaterial\SetTexture('$selfillummask', getcache)
			@BodyMaterial\GetTexture('$selfillummask')\Download() if developer\GetBool()
		else
			@@LockRenderTarget(texSize, texSize)

			surface.SetDrawColor(255, 255, 255)

			if @GrabData('GlowingEyebrows')
				surface.SetDrawColor(255, 255, 255, 255 * @GrabData('EyebrowsGlowStrength'))
				surface.SetMaterial(PPM2.MaterialsRegistry.EYEBROWS)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			for i = 1, PPM2.MAX_TATTOOS
				if not @GrabData("TattooOverDetail#{i}")
					@DrawTattoo(i, true)

			for i = 1, PPM2.MAX_BODY_DETAILS
				if mat = PPM2.MaterialsRegistry.BODY_DETAILS[@GrabData("BodyDetail#{i}")]
					alpha = @GrabData("BodyDetailGlowStrength#{i}")

					if @GetData()["GetBodyDetailGlow#{i}"](@GetData())
						surface.SetDrawColor(255, 255, 255, alpha * 255)
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, texSize, texSize)
					else
						surface.SetDrawColor(0, 0, 0, alpha * 255)
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, texSize, texSize)

			for i = 1, PPM2.MAX_TATTOOS
				if @GrabData("TattooOverDetail#{i}")
					@DrawTattoo(i, true)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash_glow, vtf\ToString())

			@BodyMaterial\SetTexture('$selfillummask', path)
			@BodyMaterial\GetTexture('$selfillummask')\Download() if developer\GetBool()

	@BUMP_COLOR = Color(127, 127, 255)

	CompileHorn: =>
		return unless @isValid

		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Horn"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/ppm2/base/horn'
				'$bumpmap': 'models/ppm2/base/horn_normal'
				'$selfillum': '1'
				'$selfillummask': 'null'

				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'

				'$model': '1'
				'$phong': '1'
				'$phongexponent': '3'
				'$phongboost': '0.05'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[0.5 6 10]'
				'$alpha': '1'
				'$color': '[1 1 1]'
				'$color2': '[1 1 1]'
			}
		}

		textureData_New1 = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Horn1"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/debug/debugwhite'
				'$selfillum': '0'

				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'

				'$model': '1'
				'$phong': '1'
				'$phongexponent': '3'
				'$phongboost': '0.05'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[0.5 6 10]'
				'$alpha': '1'
				'$color': '[1 1 1]'
				'$color2': '[1 1 1]'
			}
		}

		textureData_New2 = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Horn2"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/debug/debugwhite'
				'$selfillum': '1'
				'$selfillummask': 'null'

				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'

				'$model': '1'
				'$phong': '1'
				'$phongexponent': '3'
				'$phongboost': '0.05'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[0.5 6 10]'
				'$alpha': '1'
				'$color': '[1 1 1]'
				'$color2': '[1 1 1]'
			}
		}

		texSize = @@QUAD_SIZE_HORN

		@HornMaterialName = "!#{textureData.name\lower()}"
		@HornMaterialName1 = "!#{textureData_New1.name\lower()}"
		@HornMaterialName2 = "!#{textureData_New2.name\lower()}"
		@HornMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@HornMaterial1 = CreateMaterial(textureData_New1.name, textureData_New1.shader, textureData_New1.data)
		@HornMaterial2 = CreateMaterial(textureData_New2.name, textureData_New2.shader, textureData_New2.data)

		@UpdatePhongData()

		{:r, :g, :b} = @GrabData('BodyColor')
		{:r, :g, :b} = @GrabData('HornColor') if @GrabData('SeparateHorn')

		hash = PPM2.TextureTableHash({
			'horn'
			r, g, b
			@GrabData('SeparateHorn')
			@GrabData('HornDetailColor')
			@GrabData('HornURLColor1')
			@GrabData('HornURLColor2')
			@GrabData('HornURLColor3')
			PPM2.IsValidURL(@GrabData('HornURL1'))
			PPM2.IsValidURL(@GrabData('HornURL2'))
			PPM2.IsValidURL(@GrabData('HornURL3'))
		})

		@HornMaterial1\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

		do
			local r, g, b
			{:r, :g, :b} = @GrabData('HornDetailColor')
			@HornMaterial2\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

		if getcache = @@GetCacheH(hash)
			@HornMaterial\SetTexture('$basetexture', getcache)
			@HornMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			urlTextures = {}

			for i = 1, 3
				if geturl = PPM2.IsValidURL(@GrabData("HornURL#{i}"))
					urlTextures[i] = select(2, PPM2.GetURLMaterial(geturl, texSize, texSize)\Await())
					return unless @isValid

			@@LockRenderTarget(texSize, texSize, r, g, b)

			{:r, :g, :b} = @GrabData('HornDetailColor')

			surface.SetDrawColor(r, g, b)
			surface.SetMaterial(@@HORN_DETAIL_COLOR)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			for i, mat in pairs urlTextures
				{:r, :g, :b, :a} = @GrabData("HornURLColor#{i}")
				surface.SetDrawColor(r, g, b, a)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@HornMaterial\SetTexture('$basetexture', path)
			@HornMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()

		hash = PPM2.TextureTableHash({
			'horn illum'
			@GrabData('HornGlow')
			math.floor(@GrabData('HornGlowSrength') * 255)
		})

		if getcache = @@GetCacheH(hash)
			@HornMaterial\SetTexture('$selfillummask', getcache)
			@HornMaterial\GetTexture('$selfillummask')\Download() if developer\GetBool()
		else
			@@LockRenderTarget(texSize, texSize)

			if @GrabData('HornGlow')
				@HornMaterial2\SetTexture('$selfillummask', 'models/debug/debugwhite')

				surface.SetDrawColor(255, 255, 255, @GrabData('HornGlowSrength') * 255)
				surface.SetMaterial(@@HORN_DETAIL_COLOR)
				surface.DrawTexturedRect(0, 0, texSize, texSize)
			else
				@HornMaterial2\SetTexture('$selfillummask', 'null')

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(0, 0, 0), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@HornMaterial\SetTexture('$selfillummask', path)
			@HornMaterial\GetTexture('$selfillummask')\Download() if developer\GetBool()

		hash = PPM2.TextureTableHash({
			'horn bump'
			@GrabData('HornDetailColor').a
		})

		if getcache = @@GetCacheH(hash)
			@HornMaterial\SetTexture('$bumpmap', getcache)
			@HornMaterial\GetTexture('$bumpmap')\Download() if developer\GetBool()
		else
			@@LockRenderTarget(texSize, texSize, 127, 127, 255)

			surface.SetDrawColor(255, 255, 255, @GrabData('HornDetailColor').a)
			surface.SetMaterial(PPM2.MaterialsRegistry.HORN_DETAIL_BUMP)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(127, 127, 255), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@HornMaterial\SetTexture('$bumpmap', path)
			@HornMaterial\GetTexture('$bumpmap')\Download() if developer\GetBool()

	CompileClothPart: (iName, matregistry, indexregistry, rtsize, opaque = true) =>
		return unless @isValid

		data = {
			'$basetexture': 'models/debug/debugwhite'

			'$phong': '1'
			'$phongexponent': '20'
			'$phongboost': '.1'
			'$phongfresnelranges':  '[.3 1 8]'
			'$halflambert': '1'
			'$lightwarptexture': 'models/ppm/clothes/lightwarp'

			'$rimlight': '1'
			'$rimlightexponent': '2'
			'$rimlightboost': '1'
			'$color': '[1 1 1]'
			'$color2': '[1 1 1]'
		}

		if not opaque
			data['$alpha'] = '1'
			data['$translucent'] = '1'

		clothes = @GrabData(iName .. 'Clothes')
		return if not matregistry[clothes + 1] or not indexregistry[clothes + 1]

		@[iName .. 'Clothes_Index'] = indexregistry[clothes + 1]

		urls = {}

		for i = 1, PPM2.MAX_CLOTHES_URLS
			if url = PPM2.IsValidURL(@GrabData(iName .. 'ClothesURL' .. i))
				urls[i] = select(1, PPM2.GetURLMaterial(url)\Await())
				return unless @isValid

		colored = @GrabData(iName .. 'ClothesUseColor')

		if not colored and table.Count(urls) == 0
			@[iName .. 'Clothes_Mat'] = nil
			@[iName .. 'Clothes_MatName'] = nil
			@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)
			return

		if matregistry[clothes + 1].size == 0
			name = "PPM2_#{@@SessionID}_#{@GetID()}_Clothes_#{iName}_1"
			mat = CreateMaterial(name, 'VertexLitGeneric', data)
			@[iName .. 'Clothes_Mat'] = {mat}
			@[iName .. 'Clothes_MatName'] = {"!#{name}"}

			if urls[1]
				mat\SetVector('$color2', Vector(1, 1, 1))
				mat\SetTexture('$basetexture', urls[1])
				@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)

			elseif colored
				mat\SetTexture('$basetexture', 'models/debug/debugwhite')
				col = @GrabData("#{iName}ClothesColor1")
				mat\SetVector('$color2', col\ToVector())

				if opaque
					mat\SetFloat('$alpha', 1)
					mat\SetInt('$translucent', 0)
				else
					mat\SetFloat('$alpha', col.a / 255)
					mat\SetInt('$translucent', 1)

				@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)

			return

		@[iName .. 'Clothes_Mat'] = {}
		tab1 = @[iName .. 'Clothes_Mat']
		@[iName .. 'Clothes_MatName'] = {}
		tab2 = @[iName .. 'Clothes_MatName']
		nextindex = 1

		for matIndex = 1, matregistry[clothes + 1].size
			name = "PPM2_#{@@SessionID}_#{@GetID()}_Clothes_#{iName}_#{matIndex}"
			mat = CreateMaterial(name, 'VertexLitGeneric', data)

			tab1[matIndex] = mat
			tab2[matIndex] = "!#{name}"

			if urls[matIndex]
				mat\SetVector('$color2', Vector(1, 1, 1))
				mat\SetTexture('$basetexture', urls[matIndex])
				@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)

			elseif colored and matregistry[clothes + 1][matIndex].size == 0
				mat\SetTexture('$basetexture', 'models/debug/debugwhite')
				col = @GrabData("#{iName}ClothesColor#{nextindex}")
				nextindex += 1
				mat\SetVector('$color2', col\ToVector())

				if opaque
					mat\SetFloat('$alpha', 1)
					mat\SetInt('$translucent', 0)
				else
					mat\SetFloat('$alpha', col.a / 255)
					mat\SetInt('$translucent', 1)

			elseif colored
				rtsize = rtsize
				mat\SetVector('$color2', Vector(1, 1, 1))
				{:r, :g, :b, :a} = @GrabData("#{iName}ClothesColor#{nextindex}")

				if opaque
					mat\SetFloat('$alpha', 1)
					mat\SetInt('$translucent', 0)
				else
					mat\SetFloat('$alpha', a / 255)
					mat\SetInt('$translucent', 1)

				nextindex += 1

				hash = {
					'cloth part'
					opaque
					iName
					@GrabData(iName .. 'Clothes')
				}

				for i = 1, PPM2.MAX_CLOTHES_COLORS
					table.insert(hash, @GrabData(iName .. 'ClothesColor' .. i))

				hash = PPM2.TextureTableHash(hash)

				if getcache = @@GetCacheH(hash)
					mat\SetTexture('$bumpmap', getcache)
					mat\GetTexture('$bumpmap')\Download() if developer\GetBool()
				else
					@@LockRenderTarget(rtsize, rtsize, r, g, b)

					for i2 = 1, matregistry[clothes + 1][matIndex].size
						texture = matregistry[clothes + 1][matIndex][i2]

						if not isnumber(texture)
							surface.SetMaterial(texture)
							surface.SetDrawColor(@GrabData("#{iName}ClothesColor#{nextindex}"))
							nextindex += 1
							surface.DrawTexturedRect(0, 0, rtsize, rtsize)

					vtf = DLib.VTF.Create(2, rtsize, rtsize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
					vtf\CaptureRenderTargetCoroutine()
					@@ReleaseRenderTarget(rtsize, rtsize)

					vtf\AutoGenerateMips(false)
					path = @@SetCacheH(hash, vtf\ToString())

					mat\SetTexture('$basetexture', path)
					mat\GetTexture('$basetexture')\Download() if developer\GetBool()

			else
				tab1[matIndex] = nil
				tab2[matIndex] = nil

		@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)

	CompileHeadClothes: => @CompileClothPart('Head', PPM2.MaterialsRegistry.HEAD_CLOTHES, PPM2.MaterialsRegistry.HEAD_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_HEAD)
	CompileBodyClothes: => @CompileClothPart('Body', PPM2.MaterialsRegistry.BODY_CLOTHES, PPM2.MaterialsRegistry.BODY_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_BODY)
	CompileNeckClothes: => @CompileClothPart('Neck', PPM2.MaterialsRegistry.NECK_CLOTHES, PPM2.MaterialsRegistry.NECK_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_NECK)
	CompileEyeClothes: => @CompileClothPart('Eye', PPM2.MaterialsRegistry.EYE_CLOTHES, PPM2.MaterialsRegistry.EYE_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_EYES, false)

	CompileNewSocks: =>
		return unless @isValid

		data = {
			'$basetexture': 'models/debug/debugwhite'

			'$model': '1'
			'$ambientocclusion': '1'
			'$lightwarptexture': 'models/ppm2/base/lightwrap'
			'$phong': '1'
			'$phongexponent': '6'
			'$phongboost': '0.1'
			'$phongtint': '[1 .95 .95]'
			'$phongfresnelranges': '[1 5 10]'
			'$rimlight': '1'
			'$rimlightexponent': '2'
			'$rimlightboost': '1'
			'$color': '[1 1 1]'
			'$color2': '[1 1 1]'
			'$cloakPassEnabled': '1'
		}

		textureColor1 = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_NewSocks_Color1"
			'shader': 'VertexLitGeneric'
			'data': data
		}

		textureColor2 = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_NewSocks_Color2"
			'shader': 'VertexLitGeneric'
			'data': data
		}

		textureBase = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_NewSocks_Base"
			'shader': 'VertexLitGeneric'
			'data': data
		}

		@NewSocksColor1Name = '!' .. textureColor1.name\lower()
		@NewSocksColor2Name = '!' .. textureColor2.name\lower()
		@NewSocksBaseName = '!' .. textureBase.name\lower()

		@NewSocksColor1 = CreateMaterial(textureColor1.name, textureColor1.shader, textureColor1.data)
		@NewSocksColor2 = CreateMaterial(textureColor2.name, textureColor2.shader, textureColor2.data)
		@NewSocksBase = CreateMaterial(textureBase.name, textureBase.shader, textureBase.data)

		texSize = @@QUAD_SIZE_SOCKS

		@UpdatePhongData()

		if url = PPM2.IsValidURL(@GrabData('NewSocksTextureURL'))
			texture = PPM2.GetURLMaterial(url, texSize, texSize)\Await()
			return unless @isValid

			for _, tex in ipairs {@NewSocksColor1, @NewSocksColor2, @NewSocksBase}
				tex\SetVector('$color2', Vector(1, 1, 1))
				tex\SetTexture('$basetexture', texture)

			return

		{:r, :g, :b} = @GrabData('NewSocksColor1')
		@NewSocksColor1\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

		{:r, :g, :b} = @GrabData('NewSocksColor2')
		@NewSocksColor2\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

		{:r, :g, :b} = @GrabData('NewSocksColor3')
		@NewSocksBase\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

	CompileEyelashes: =>
		return unless @isValid

		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Eyelashes"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/debug/debugwhite'

				'$model': '1'
				'$ambientocclusion': '1'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
				'$phong': '1'
				'$phongexponent': '6'
				'$phongboost': '0.1'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[1 5 10]'
				'$rimlight': '1'
				'$rimlightexponent': '1'
				'$rimlightboost': '0.5'
				'$color': '[1 1 1]'
				'$color2': '[1 1 1]'
				'$cloakPassEnabled': '1'
			}
		}

		@EyelashesName = '!' .. textureData.name\lower()
		@Eyelashes = CreateMaterial(textureData.name, textureData.shader, textureData.data)

		@UpdatePhongData()

		{:r, :g, :b} = @GrabData('EyelashesColor')
		@Eyelashes\SetVector('$color', Vector(r / 255, g / 255, b / 255))
		@Eyelashes\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

	CompileSocks: =>
		return unless @isValid

		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Socks"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/props_pony/ppm/ppm_socks/socks_striped'

				'$model': '1'
				'$ambientocclusion': '1'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
				'$phong': '1'
				'$phongexponent': '6'
				'$phongboost': '0.1'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[1 5 10]'
				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'
				'$color': '[1 1 1]'
				'$color2': '[1 1 1]'
				'$cloakPassEnabled': '1'
			}
		}

		@SocksMaterialName = "!#{textureData.name\lower()}"
		@SocksMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@UpdatePhongData()
		texSize = @@QUAD_SIZE_SOCKS

		{:r, :g, :b} = @GrabData('SocksColor')
		@SocksMaterial\SetFloat('$alpha', 1)

		if url = PPM2.IsValidURL(@GrabData('SocksTextureURL'))
			texture = PPM2.GetURLMaterial(url, texSize, texSize)\Await()
			return unless @isValid

			@SocksMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
			@SocksMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))
			@SocksMaterial\SetTexture('$basetexture', texture)
		else
			@SocksMaterial\SetVector('$color', Vector(1, 1, 1))
			@SocksMaterial\SetVector('$color2', Vector(1, 1, 1))

			hash = {
				'socks'
				@GrabData('SocksTexture')
				@GrabData('SocksDetailColor1')
				@GrabData('SocksDetailColor2')
				@GrabData('SocksDetailColor3')
				@GrabData('SocksDetailColor4')
				@GrabData('SocksDetailColor5')
				@GrabData('SocksDetailColor6')
			}

			hash = PPM2.TextureTableHash(hash)

			if getcache = @@GetCacheH(hash)
				@SocksMaterial\SetTexture('$basetexture', getcache)
				@SocksMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()
			else
				@@LockRenderTarget(texSize, texSize, r, g, b)

				socksType = @GrabData('SocksTexture') + 1
				surface.SetMaterial(PPM2.MaterialsRegistry.SOCKS_MATERIALS[socksType] or PPM2.MaterialsRegistry.SOCKS_MATERIALS[1])
				surface.DrawTexturedRect(0, 0, texSize, texSize)

				if details = PPM2.MaterialsRegistry.SOCKS_DETAILS[socksType]
					for i = 1, details.size
						{:r, :g, :b} = @GrabData('SocksDetailColor' .. i)
						surface.SetDrawColor(r, g, b)
						surface.SetMaterial(details[i])
						surface.DrawTexturedRect(0, 0, texSize, texSize)

				vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
				vtf\CaptureRenderTargetCoroutine()
				@@ReleaseRenderTarget(texSize, texSize)

				vtf\AutoGenerateMips(false)
				path = @@SetCacheH(hash, vtf\ToString())

				@SocksMaterial\SetTexture('$basetexture', path)
				@SocksMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()

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
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[0.5 6 10]'
				'$alpha': '1'
				'$color': '[1 1 1]'
				'$color2': '[1 1 1]'

				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'
			}
		}

		texSize = @@QUAD_SIZE_WING

		@WingsMaterialName = "!#{textureData.name\lower()}"
		@WingsMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@UpdatePhongData()

		{:r, :g, :b} = @GrabData('BodyColor')
		{:r, :g, :b} = @GrabData('WingsColor') if @GrabData('SeparateWings')

		hash = {
			'wings',
			r, g, b
		}

		for i = 1, 3
			table.insert(hash, PPM2.IsValidURL(@GrabData("WingsURL#{i}")))
			table.insert(hash, @GrabData("WingsURLColor#{i}"))

		hash = PPM2.TextureTableHash(hash)

		if getcache = @@GetCacheH(hash)
			@WingsMaterial\SetTexture('$basetexture', getcache)
			@WingsMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			urlTextures = {}

			for i = 1, 3
				if url = PPM2.IsValidURL(@GrabData("WingsURL#{i}"))
					urlTextures[i] = select(2, PPM2.GetURLMaterial(url, texSize, texSize)\Await())
					return unless @isValid

			@@LockRenderTarget(texSize, texSize, r, g, b)

			surface.SetMaterial(@@WINGS_MATERIAL_COLOR)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			for i, mat in pairs urlTextures
				{:r, :g, :b, :a} = @GrabData("WingsURLColor#{i}")
				surface.SetDrawColor(r, g, b, a)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@WingsMaterial\SetTexture('$basetexture', path)
			@WingsMaterial\GetTexture('$basetexture')\Download() if developer\GetBool()

	GetManeType: => @GrabData('ManeType')
	GetManeTypeLower: => @GrabData('ManeTypeLower')
	GetTailType: => @GrabData('TailType')

	CompileHair: =>
		return unless @isValid

		textureFirst = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Mane_1"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/debug/debugwhite'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
				'$halflambert': '1'
				'$model': '1'
				'$phong': '1'
				'$phongexponent': '6'
				'$phongboost': '0.05'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[0.5 6 10]'

				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'
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

		texSize = @@QUAD_SIZE_HAIR

		hash = {
			'mane 1',
			@GrabData('ManeColor1')
		}

		for i = 1, 6
			table.insert(hash, PPM2.IsValidURL(@GrabData("ManeURL#{i}")))
			table.insert(hash, @GrabData("ManeURLColor#{i}"))
			table.insert(hash, @GrabData("ManeDetailColor#{i}"))

		hash = PPM2.TextureTableHash(hash)

		if getcache = @@GetCacheH(hash)
			@HairColor1Material\SetTexture('$basetexture', getcache)
			@HairColor1Material\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			urlTextures = {}

			for i = 1, 6
				if url = PPM2.IsValidURL(@GrabData("ManeURL#{i}"))
					urlTextures[i] = select(2, PPM2.GetURLMaterial(url, texSize, texSize)\Await())
					return unless @isValid

			{:r, :g, :b} = @GrabData('ManeColor1')
			@@LockRenderTarget(texSize, texSize, r, g, b)

			if registry = PPM2.MaterialsRegistry.UPPER_MANE_DETAILS[@GetManeType()]
				i = 1

				-- using moonscripts iterator will call index metamethods while iterating
				for i2 = 1, registry.size
					mat = registry[i2]
					{:r, :g, :b, :a} = @GrabData("ManeDetailColor#{i}")
					surface.SetDrawColor(r, g, b, a)
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, texSize, texSize)
					i += 1

			for i, mat in pairs urlTextures
				surface.SetDrawColor(@GrabData("ManeURLColor#{i}"))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@HairColor1Material\SetTexture('$basetexture', path)
			@HairColor1Material\GetTexture('$basetexture')\Download() if developer\GetBool()

		hash = {
			'mane 2',
			@GrabData('ManeColor2')
		}

		for i = 1, 6
			table.insert(hash, @GrabData("ManeURL#{i}"))
			table.insert(hash, @GrabData("ManeURLColor#{i}"))
			table.insert(hash, @GrabData("ManeDetailColor#{i}"))

		hash = PPM2.TextureTableHash(hash)

		if getcache = @@GetCacheH(hash)
			@HairColor2Material\SetTexture('$basetexture', getcache)
			@HairColor2Material\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			urlTextures = {}

			for i = 1, 6
				if url = PPM2.IsValidURL(@GrabData("ManeURL#{i}"))
					urlTextures[i] = select(2, PPM2.GetURLMaterial(url, texSize, texSize)\Await())
					return unless @isValid

			{:r, :g, :b} = @GrabData('ManeColor2')
			@@LockRenderTarget(texSize, texSize, r, g, b)

			if registry = PPM2.MaterialsRegistry.LOWER_MANE_DETAILS[@GetManeTypeLower()]
				i = 1

				for i2 = 1, registry.size
					mat = registry[i2]
					surface.SetDrawColor(@GrabData("ManeDetailColor#{i}"))
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, texSize, texSize)
					i += 1

			for i, mat in pairs urlTextures
				surface.SetDrawColor(@GrabData("ManeURLColor#{i}"))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@HairColor2Material\SetTexture('$basetexture', path)
			@HairColor2Material\GetTexture('$basetexture')\Download() if developer\GetBool()

	CompileTail: =>
		return unless @isValid
		textureFirst = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_Tail_1"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'models/debug/debugwhite'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
				'$halflambert': '1'
				'$model': '1'
				'$phong': '1'
				'$phongexponent': '6'
				'$phongboost': '0.05'
				'$phongtint': '[1 .95 .95]'
				'$phongfresnelranges': '[0.5 6 10]'

				'$rimlight': '1'
				'$rimlightexponent': '2'
				'$rimlightboost': '1'
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

		texSize = @@QUAD_SIZE_TAIL

		hash = {
			'tail 1',
			@GrabData('TailColor1')
		}

		for i = 1, 6
			table.insert(hash, PPM2.IsValidURL(@GrabData("TailURL#{i}")))
			table.insert(hash, @GrabData("TailDetailColor#{i}"))
			table.insert(hash, @GrabData("TailURLColor#{i}"))

		hash = PPM2.TextureTableHash(hash)

		if getcache = @@GetCacheH(hash)
			@TailColor1Material\SetTexture('$basetexture', getcache)
			@TailColor1Material\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			urlTextures = {}

			for i = 1, 6
				if url = PPM2.IsValidURL(@GrabData("TailURL#{i}"))
					urlTextures[i] = select(2, PPM2.GetURLMaterial(url, texSize, texSize)\Await())
					return unless @isValid

			{:r, :g, :b} = @GrabData('TailColor1')
			@@LockRenderTarget(texSize, texSize, r, g, b)

			if registry = PPM2.MaterialsRegistry.TAIL_DETAILS[@GetTailType()]
				i = 1

				for i2 = 1, registry.size
					mat = registry[i2]
					surface.SetMaterial(mat)
					surface.SetDrawColor(@GrabData("TailDetailColor#{i}"))
					surface.DrawTexturedRect(0, 0, texSize, texSize)
					i += 1

			for i, mat in pairs urlTextures
				surface.SetDrawColor(@GrabData("TailURLColor#{i}"))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@TailColor1Material\SetTexture('$basetexture', path)
			@TailColor1Material\GetTexture('$basetexture')\Download() if developer\GetBool()

		hash = {
			'tail 2',
			@GrabData('TailColor2')
		}

		for i = 1, 6
			table.insert(hash, PPM2.IsValidURL(@GrabData("TailURL#{i}")))
			table.insert(hash, @GrabData("TailDetailColor#{i}"))
			table.insert(hash, @GrabData("TailURLColor#{i}"))

		hash = PPM2.TextureTableHash(hash)

		if getcache = @@GetCacheH(hash)
			@TailColor2Material\SetTexture('$basetexture', getcache)
			@TailColor2Material\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			urlTextures = {}

			for i = 1, 6
				if url = PPM2.IsValidURL(@GrabData("TailURL#{i}"))
					urlTextures[i] = select(2, PPM2.GetURLMaterial(url, texSize, texSize)\Await())
					return unless @isValid

			{:r, :g, :b} = @GrabData('TailColor2')
			@@LockRenderTarget(texSize, texSize, r, g, b)

			if registry = PPM2.MaterialsRegistry.TAIL_DETAILS[@GetTailType()]
				i = 1

				for i2 = 1, registry.size
					mat = registry[i2]
					surface.SetMaterial(mat)
					surface.SetDrawColor(@GrabData("TailDetailColor#{i}"))
					surface.DrawTexturedRect(0, 0, texSize, texSize)
					i += 1

			for i, mat in pairs urlTextures
				surface.SetDrawColor(@GrabData("TailURLColor#{i}"))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			@TailColor2Material\SetTexture('$basetexture', path)
			@TailColor2Material\GetTexture('$basetexture')\Download() if developer\GetBool()

	@REFLECT_RENDER_SIZE = 64
	@GetReflectionsScale: =>
		val = REAL_TIME_EYE_REFLECTIONS_SIZE\GetInt()
		return @REFLECT_RENDER_SIZE if val % 2 ~= 0
		return val

	ResetEyeReflections: =>
	UpdateEyeReflections: (ent = @GetEntity()) =>

	CompileLeftEye: => @CompileEye(true)
	CompileRightEye: => @CompileEye(false)

	CompileEye: (left = false) =>
		return unless @isValid

		prefix = left and 'l' or 'r'
		prefixUpper = left and 'L' or 'R'
		prefixUpperR = left and 'R' or 'L'

		separated = @GrabData('SeparateEyes')
		prefixData = ''
		prefixData = left and 'Left' or 'Right' if separated

		EyeRefract =        @GrabData("EyeRefract#{prefixData}")
		EyeCornerA =        @GrabData("EyeCornerA#{prefixData}")
		EyeType =           @GrabData("EyeType#{prefixData}")
		EyeBackground =     @GrabData("EyeBackground#{prefixData}")
		EyeHole =           @GrabData("EyeHole#{prefixData}")
		HoleWidth =         @GrabData("HoleWidth#{prefixData}")
		IrisSize =          @GrabData("IrisSize#{prefixData}") * (EyeRefract and .38 or .75)
		EyeIris1 =          @GrabData("EyeIrisTop#{prefixData}")
		EyeIris2 =          @GrabData("EyeIrisBottom#{prefixData}")
		EyeIrisLine1 =      @GrabData("EyeIrisLine1#{prefixData}")
		EyeIrisLine2 =      @GrabData("EyeIrisLine2#{prefixData}")
		EyeLines =          @GrabData("EyeLines#{prefixData}")
		HoleSize =          @GrabData("HoleSize#{prefixData}")
		EyeReflection =     @GrabData("EyeReflection#{prefixData}")
		EyeReflectionType = @GrabData("EyeReflectionType#{prefixData}")
		EyeEffect =         @GrabData("EyeEffect#{prefixData}")
		DerpEyes =          @GrabData("DerpEyes#{prefixData}")
		DerpEyesStrength =  @GrabData("DerpEyesStrength#{prefixData}")
		EyeURL =            @GrabData("EyeURL#{prefixData}")
		IrisWidth =         @GrabData("IrisWidth#{prefixData}")
		IrisHeight =        @GrabData("IrisHeight#{prefixData}")
		HoleHeight =        @GrabData("HoleHeight#{prefixData}")
		HoleShiftX =        @GrabData("HoleShiftX#{prefixData}")
		HoleShiftY =        @GrabData("HoleShiftY#{prefixData}")
		EyeRotation =       @GrabData("EyeRotation#{prefixData}")
		EyeLineDirection =  @GrabData("EyeLineDirection#{prefixData}")
		PonySize =          @GrabData('PonySize')
		PonySize = 1        if IsValid(@GetEntity()) and @GetEntity()\IsRagdoll()

		texSize = @@QUAD_SIZE_EYES

		shiftX, shiftY = (1 - IrisWidth) * texSize / 2, (1 - IrisHeight) * texSize / 2
		shiftY += DerpEyesStrength * .15 * texSize if DerpEyes and left
		shiftY -= DerpEyesStrength * .15 * texSize if DerpEyes and not left

		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_#{EyeRefract and 'EyeRefract' or 'Eyes'}_#{prefix}"
			'shader': EyeRefract and 'EyeRefract' or 'Eyes'
			'data': {
				'$iris': 'models/ppm2/base/face/p_base'
				'$irisframe': '0'

				'$ambientoccltexture': 'models/ppm2/eyes/eye_extra'
				'$envmap': 'models/ppm2/eyes/eye_reflection'
				'$corneatexture': 'models/ppm2/eyes/eye_cornea_oval'
				'$lightwarptexture': 'models/ppm2/clothes/lightwarp'

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
		@UpdatePhongData()

		IrisPos = texSize / 2 - texSize * IrisSize * PonySize / 2
		IrisQuadSize = texSize * IrisSize * PonySize

		HoleQuadSize = texSize * IrisSize * HoleSize * PonySize
		HolePos = texSize / 2
		holeX = HoleQuadSize * HoleWidth / 2
		holeY = texSize * (IrisSize * HoleSize * HoleHeight * PonySize) / 2
		calcHoleX = HolePos - holeX + holeX * HoleShiftX + shiftX
		calcHoleY = HolePos - holeY + holeY * HoleShiftY + shiftY

		if EyeRefract
			if EyeCornerA
				hash = PPM2.TextureTableHash({
					'eye cornera',
					IrisPos + shiftX - texSize / 16, IrisPos + shiftY - texSize / 16, IrisQuadSize * IrisWidth * 1.5, IrisQuadSize * IrisHeight * 1.5, EyeRotation
				})

				if getcache = @@GetCacheH(hash)
					createdMaterial\SetTexture('$corneatexture', getcache)
					createdMaterial\GetTexture('$corneatexture')\Download() if developer\GetBool()
				else
					@@LockRenderTarget(texSize, texSize)

					surface.SetMaterial(PPM2.MaterialsRegistry.EYE_CORNERA_OVAL)
					surface.SetDrawColor(255, 255, 255)
					DrawTexturedRectRotated(IrisPos + shiftX - texSize / 16, IrisPos + shiftY - texSize / 16, IrisQuadSize * IrisWidth * 1.5, IrisQuadSize * IrisHeight * 1.5, EyeRotation)

					vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
					vtf\CaptureRenderTargetCoroutine()
					@@ReleaseRenderTarget(texSize, texSize)

					vtf\AutoGenerateMips(false)
					path = @@SetCacheH(hash, vtf\ToString())

					createdMaterial\SetTexture('$corneatexture', path)
					createdMaterial\SetTexture('$corneatexture')\Download() if developer\GetBool()
			else
				createdMaterial\SetTexture('$corneatexture', 'null')

		if url = PPM2.IsValidURL(EyeURL)
			texture = PPM2.GetURLMaterial(url, texSize, texSize)\Await()
			return unless @isValid
			createdMaterial\SetTexture('$iris', texture)
			return

		hash = PPM2.TextureTableHash({
			'eye',
			prefixUpper
			EyeType
			EyeBackground
			EyeHole
			HoleWidth * 100
			math.round(IrisSize * 100)
			EyeIris1
			EyeIris2
			EyeIrisLine1
			EyeIrisLine2
			EyeLines
			math.round(HoleSize * 100)
			EyeReflection
			EyeReflectionType
			EyeEffect
			DerpEyes
			math.round(DerpEyesStrength * 100)
			EyeURL
			math.round(IrisWidth * 100)
			math.round(IrisHeight * 100)
			math.round(HoleHeight * 100)
			math.round(HoleShiftX)
			math.round(HoleShiftY)
			math.round(EyeRotation)
			EyeLineDirection
			math.round(PonySize * 100)
		})

		if getcache = @@GetCacheH(hash)
			createdMaterial\SetTexture('$iris', getcache)
			createdMaterial\GetTexture('$iris')\Download() if developer\GetBool()
		else
			{:r, :g, :b, :a} = EyeBackground
			@@LockRenderTarget(texSize, texSize, r, g, b)

			surface.SetDrawColor(EyeIris1)
			surface.SetMaterial(@@EYE_OVALS[EyeType + 1] or @EYE_OVAL)
			DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

			surface.SetDrawColor(EyeIris2)
			surface.SetMaterial(@@EYE_GRAD)
			DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

			if EyeLines
				lprefix = prefixUpper
				lprefix = prefixUpperR if not EyeLineDirection
				surface.SetDrawColor(EyeIrisLine1)
				surface.SetMaterial(@@["EYE_LINE_#{lprefix}_1"])
				DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

				surface.SetDrawColor(EyeIrisLine2)
				surface.SetMaterial(@@["EYE_LINE_#{lprefix}_2"])
				DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

			surface.SetDrawColor(EyeHole)
			surface.SetMaterial(@@EYE_OVALS[EyeType + 1] or @EYE_OVAL)
			DrawTexturedRectRotated(calcHoleX, calcHoleY, HoleQuadSize * HoleWidth * IrisWidth, HoleQuadSize * HoleHeight * IrisHeight, EyeRotation)

			surface.SetDrawColor(EyeEffect)
			surface.SetMaterial(@@EYE_EFFECT)
			DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

			surface.SetDrawColor(EyeReflection)
			surface.SetMaterial(PPM2.MaterialsRegistry.EYE_REFLECTIONS[EyeReflectionType + 1])
			DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT1, {fill: Color(r, g, b), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			@@ReleaseRenderTarget(texSize, texSize)

			vtf\AutoGenerateMips(false)
			path = @@SetCacheH(hash, vtf\ToString())

			createdMaterial\SetTexture('$iris', path)
			createdMaterial\GetTexture('$iris')\Download() if developer\GetBool()

	_CaptureAlphaClosure: (texSize, mat, vtf) =>
		rt1, rt2, mat1, mat2 = @@LockRenderTargetMask(texSize, texSize)
		surface.SetDrawColor(255, 255, 255)

		-- capture alpha
		render.PushRenderTarget(rt1)
		render.Clear(255, 255, 255, 0, true, true)

		cam.Start2D()
		render.OverrideBlend(true, BLEND_DST_COLOR, BLEND_DST_COLOR, BLENDFUNC_ADD, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD)
		surface.SetMaterial(mat)
		surface.DrawTexturedRectUV(0, 0, texSize - 1, texSize - 1, -0.016129032258065, -0.016129032258065, 1.0161290322581, 1.0161290322581)
		render.OverrideBlend(false)
		cam.End2D()

		render.PopRenderTarget()

		@@ReleaseRenderTarget(texSize, texSize, true)

		-- compute alpha
		render.PushRenderTarget(rt2)
		render.Clear(0, 0, 0, 255, true, true)

		cam.Start2D()
		surface.SetMaterial(mat1)
		surface.DrawTexturedRectUV(0, 0, texSize - 1, texSize - 1, -0.016129032258065, -0.016129032258065, 1.0161290322581, 1.0161290322581)
		cam.End2D()

		PPM2.LATEST_MASK_ = mat1
		PPM2.LATEST_MASK = mat2

		vtf\CaptureRenderTargetAsAlphaCoroutine()
		render.PopRenderTarget()

		@@ReleaseRenderTargetMask(texSize, texSize)

	CompileCMark: =>
		return unless @isValid

		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_CMark3"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'null'
				'$translucent': '1'
				'$vertexalpha': '1' -- this is required for DXT3/DXT5 textures
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
			}
		}

		textureDataGUI = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_CMark_GUI3"
			'shader': 'UnlitGeneric'
			'data': {
				'$basetexture': 'null'
				'$vertexalpha': '1' -- this is required for DXT3/DXT5 textures
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
			}
		}

		@CMarkTextureName = "!#{textureData.name\lower()}"
		@CMarkTexture = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@CMarkTextureGUIName = "!#{textureDataGUI.name\lower()}"
		@CMarkTextureGUI = CreateMaterial(textureDataGUI.name, textureDataGUI.shader, textureDataGUI.data)

		unless @GrabData('CMark')
			@CMarkTexture\SetTexture('$basetexture', 'null')
			@CMarkTextureGUI\SetTexture('$basetexture', 'null')
			return

		URL = @GrabData('CMarkURL')
		size = @GrabData('CMarkSize')

		texSize = @@QUAD_SIZE_CMARK
		sizeQuad = texSize * size
		shift = (texSize - sizeQuad) / 2

		if url = PPM2.IsValidURL(URL)
			hash = PPM2.TextureTableHash({
				'cutie mark url'
				url
				@GrabData('CMarkColor')
				shift\floor(), sizeQuad\floor()
			})

			if getcache = @@GetCacheH(hash)
				@CMarkTexture\SetTexture('$basetexture', getcache)
				@CMarkTextureGUI\SetTexture('$basetexture', getcache)
				@CMarkTexture\GetTexture('$basetexture')\Download() if developer\GetBool()
				@CMarkTextureGUI\GetTexture('$basetexture')\Download() if developer\GetBool()
			else
				material = select(2, PPM2.GetURLMaterial(url, texSize, texSize)\Await())
				return unless @isValid

				rt, mat = @@LockRenderTarget(texSize, texSize, 0, 0, 0, 0)

				surface.SetDrawColor(@GrabData('CMarkColor'))
				surface.SetMaterial(material)
				surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)

				vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT5, {fill: Color(r, g, b), mipmap_count: -2})
				vtf\CaptureRenderTargetCoroutine()
				cam.End2D()
				render.PopRenderTarget()

				@_CaptureAlphaClosure(texSize, mat, vtf)

				vtf\AutoGenerateMips(true)
				path = @@SetCacheH(hash, vtf\ToString())

				@CMarkTexture\SetTexture('$basetexture', path)
				@CMarkTexture\GetTexture('$basetexture')\Download() if developer\GetBool()
				@CMarkTextureGUI\SetTexture('$basetexture', path)
				@CMarkTextureGUI\GetTexture('$basetexture')\Download() if developer\GetBool()

			return

		hash = PPM2.TextureTableHash({
			'cutie mark'
			@GrabData('CMarkType')
			@GrabData('CMarkColor')
			shift\floor(), sizeQuad\floor()
		})

		if getcache = @@GetCacheH(hash)
			@CMarkTexture\SetTexture('$basetexture', getcache)
			@CMarkTextureGUI\SetTexture('$basetexture', getcache)
			@CMarkTexture\GetTexture('$basetexture')\Download() if developer\GetBool()
			@CMarkTextureGUI\GetTexture('$basetexture')\Download() if developer\GetBool()
		else
			rt, mat = @@LockRenderTarget(texSize, texSize, 0, 0, 0, 0)

			if mark = PPM2.MaterialsRegistry.CUTIEMARKS[@GrabData('CMarkType') + 1]
				surface.SetDrawColor(@GrabData('CMarkColor'))
				surface.SetMaterial(mark)
				surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)

			vtf = DLib.VTF.Create(2, texSize, texSize, IMAGE_FORMAT_DXT5, {fill: Color(r, g, b), mipmap_count: -2})
			vtf\CaptureRenderTargetCoroutine()
			cam.End2D()
			render.PopRenderTarget()

			@_CaptureAlphaClosure(texSize, mat, vtf)

			vtf\AutoGenerateMips(true)
			path = @@SetCacheH(hash, vtf\ToString())

			@CMarkTexture\SetTexture('$basetexture', path)
			@CMarkTexture\GetTexture('$basetexture')\Download() if developer\GetBool()
			@CMarkTextureGUI\SetTexture('$basetexture', path)
			@CMarkTextureGUI\GetTexture('$basetexture')\Download() if developer\GetBool()

PPM2.GetTextureController = (model = 'models/ppm/player_default_base.mdl') ->
	PPM2.PonyTextureController.AVALIABLE_CONTROLLERS[model\lower()] or PPM2.PonyTextureController
