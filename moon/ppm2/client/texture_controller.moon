
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

_M = PPM2.MaterialsRegistry
USE_HIGHRES_BODY = PPM2.USE_HIGHRES_BODY
USE_HIGHRES_TEXTURES = PPM2.USE_HIGHRES_TEXTURES

PPM2.REAL_TIME_EYE_REFLECTIONS = CreateConVar('ppm2_cl_reflections', '0', {FCVAR_ACRHIVE}, 'Calculate eye reflections in real time. Needs beefy computer.')
REAL_TIME_EYE_REFLECTIONS = PPM2.REAL_TIME_EYE_REFLECTIONS

PPM2.REAL_TIME_EYE_REFLECTIONS_SIZE = CreateConVar('ppm2_cl_reflections_size', '512', {FCVAR_ACRHIVE}, 'Reflections size. Must be multiple to 2! (16, 32, 64, 128, 256)')
REAL_TIME_EYE_REFLECTIONS_SIZE = PPM2.REAL_TIME_EYE_REFLECTIONS_SIZE

PPM2.REAL_TIME_EYE_REFLECTIONS_DIST = CreateConVar('ppm2_cl_reflections_drawdist', '192', {FCVAR_ACRHIVE}, 'Reflections maximal draw distance')
REAL_TIME_EYE_REFLECTIONS_DIST = PPM2.REAL_TIME_EYE_REFLECTIONS_DIST

PPM2.REAL_TIME_EYE_REFLECTIONS_RDIST = CreateConVar('ppm2_cl_reflections_renderdist', '1000', {FCVAR_ACRHIVE}, 'Reflection scene draw distance (ZFar)')
REAL_TIME_EYE_REFLECTIONS_RDIST = PPM2.REAL_TIME_EYE_REFLECTIONS_RDIST

lastReflectionFrame = 0

hook.Remove 'DrawOverlay', 'PPM2.ReflectionsUpdate'

hook.Add 'PreRender', 'PPM2.ReflectionsUpdate', (a, b) ->
	return if PPM2.__RENDERING_REFLECTIONS
	return if lastReflectionFrame == FrameNumberL()
	lastReflectionFrame = FrameNumberL()

	PPM2.__RENDERING_REFLECTIONS = true

	for i, task in ipairs PPM2.NetworkedPonyData.CheckTasks
		if task.GetRenderController
			if render = task\GetRenderController()
				if textures = render\GetTextureController()
					ProtectedCall(textures.CheckReflectionsClosure)

	PPM2.__RENDERING_REFLECTIONS = false

hook.Add 'PreDrawEffects', 'PPM2.ReflectionsUpdate', (-> return true if PPM2.__RENDERING_REFLECTIONS), -10
hook.Add 'PostDrawEffects', 'PPM2.ReflectionsUpdate', (-> return true if PPM2.__RENDERING_REFLECTIONS), -10
hook.Add 'PreDrawHalos', 'PPM2.ReflectionsUpdate', (-> return true if PPM2.__RENDERING_REFLECTIONS), -10
hook.Add 'PostDrawHalos', 'PPM2.ReflectionsUpdate', (-> return true if PPM2.__RENDERING_REFLECTIONS), -10
hook.Add 'PreDrawOpaqueRenderables', 'PPM2.ReflectionsUpdate', (-> return false if PPM2.__RENDERING_REFLECTIONS), -10
hook.Add 'PostDrawOpaqueRenderables', 'PPM2.ReflectionsUpdate', (-> return false if PPM2.__RENDERING_REFLECTIONS), -10
hook.Add 'PreDrawTranslucentRenderables', 'PPM2.ReflectionsUpdate', (-> return false if PPM2.__RENDERING_REFLECTIONS), -10
hook.Add 'PostDrawTranslucentRenderables', 'PPM2.ReflectionsUpdate', (-> return false if PPM2.__RENDERING_REFLECTIONS), -10

mat_picmip = GetConVar('mat_picmip')
RT_SIZES = [math.pow(2, i) for i = 1, 24]

PPM2.GetTextureQuality = ->
	mult = 1

	switch math.Clamp(mat_picmip\GetInt(), -2, 2)
		when -2
			mult *= 2
		when 0
			mult *= 0.75
		when 1
			mult *= 0.5
		when 2
			mult *= 0.25

	if USE_HIGHRES_TEXTURES\GetBool()
		mult *= 2

	return mult

PPM2.GetTextureSize = (texSize) ->
	texSize *= PPM2.GetTextureQuality(texSize)
	delta = 9999
	nsize = texSize

	for _, size in ipairs RT_SIZES
		ndelta = math.abs(size - texSize)
		if ndelta < delta
			delta = ndelta
			nsize = size

	return nsize

DrawTexturedRectRotated = (x = 0, y = 0, width = 0, height = 0, rotation = 0) -> surface.DrawTexturedRectRotated(x + width / 2, y + height / 2, width, height, rotation)

class PonyTextureController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

	@UPPER_MANE_MATERIALS = {i, [val1 for _, val1 in ipairs val] for i, val in pairs _M.UPPER_MANE_DETAILS}
	@LOWER_MANE_MATERIALS = {i, [val1 for _, val1 in ipairs val] for i, val in pairs _M.LOWER_MANE_DETAILS}
	@TAIL_DETAIL_MATERIALS = {i, [val1 for _, val1 in ipairs val] for i, val in pairs _M.TAIL_DETAILS}

	@HAIR_MATERIAL_COLOR = _M.HAIR_MATERIAL_COLOR
	@TAIL_MATERIAL_COLOR = _M.TAIL_MATERIAL_COLOR
	@WINGS_MATERIAL_COLOR = _M.WINGS_MATERIAL_COLOR
	@HORN_MATERIAL_COLOR = _M.HORN_MATERIAL_COLOR
	@BODY_MATERIAL = _M.BODY_MATERIAL
	@HORN_DETAIL_COLOR = _M.HORN_DETAIL_COLOR
	@EYE_OVAL = _M.EYE_OVAL
	@EYE_OVALS = _M.EYE_OVALS
	@EYE_GRAD = _M.EYE_GRAD
	@EYE_EFFECT = _M.EYE_EFFECT
	@EYE_LINE_L_1 = _M.EYE_LINE_L_1
	@EYE_LINE_R_1 = _M.EYE_LINE_R_1
	@EYE_LINE_L_2 = _M.EYE_LINE_L_2
	@EYE_LINE_R_2 = _M.EYE_LINE_R_2
	@PONY_SOCKS = _M.PONY_SOCKS

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

	@BODY_UPDATE_TRIGGER = {}
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

	@COMPILE_QUEUE = {IN_PLACE: false}
	@COMPILE_WAIT_UNTIL = 0

	@COMPILE_THREAD = coroutine.create () ->
		handleError = (err) ->
			PPM2.MessageError('There was a problem in compiling texture')
			PPM2.MessageError(debug.traceback(err))

		while true
			if #@COMPILE_QUEUE == 0
				coroutine.yield()
			else
				if #@COMPILE_QUEUE > 40 and #@COMPILE_QUEUE % 20 == 0
					PPM2.LMessage('message.ppm2.queue_notify', #@COMPILE_QUEUE)

				if @COMPILE_QUEUE.IN_PLACE
					for _, data in ipairs(@COMPILE_QUEUE)
						if data.self\IsValid() and data.now
							xpcall(data.run, handleError, data.self, unpack(data.args))
							data.self.lastMaterialUpdate = 0

					@COMPILE_QUEUE = [data for _, data in ipairs(@COMPILE_QUEUE) when data.self\IsValid() and not data.now]
					@COMPILE_QUEUE.IN_PLACE = false

				data = table.remove(@COMPILE_QUEUE)

				if data and data.self\IsValid()
					xpcall(data.run, handleError, data.self, unpack(data.args))
					data.self.lastMaterialUpdate = 0
					coroutine.yield()

	@COMPILE_TEXTURES = ->
		return if #@COMPILE_QUEUE == 0

		if @COMPILE_WAIT_UNTIL < RealTimeL() or @COMPILE_QUEUE.IN_PLACE
			@COMPILE_WAIT_UNTIL = RealTimeL() + 0.2
			coroutine.resume(@COMPILE_THREAD)

		return

	hook.Add 'PreRender', 'PPM2.CompileTextures', @COMPILE_TEXTURES, -1

	DelayCompile: (func = '', ...) =>
		return if not @[func]
		args = {...}

		for i, val in ipairs(@@COMPILE_QUEUE)
			if val.func == func and val.self == @
				val.args = args
				val.now = false
				return

		table.insert(@@COMPILE_QUEUE, {self: @, :func, now: false, :args, run: @[func]})

	DelayCompileNow: (func = '', ...) =>
		return if not @[func]
		args = {...}
		@@COMPILE_QUEUE.IN_PLACE = true

		for i, val in ipairs(@@COMPILE_QUEUE)
			if val.func == func and val.self == @
				val.args = args
				val.now = true
				return

		table.insert(@@COMPILE_QUEUE, {self: @, :func, now: true, :args, run: @[func]})

	IsBeingProcessed: =>
		return true if @url_processes > 0
		if #@@COMPILE_QUEUE == 0
			@processing_first = false
			return false

		num = 0

		for data in *@@COMPILE_QUEUE
			if data.self == @
				num += 1

		if not @processing_first and num > 10
			@processing_first = true
		elseif @processing_first and num == 0
			@processing_first = false

		return num > 0 if @processing_first
		return num > 3

	DataChanges: (state) =>
		return unless @isValid
		return if not @GetEntity()
		key = state\GetKey()

		if key\find('Separate') and key\find('Phong')
			@UpdatePhongData()
			return

		switch key
			when 'BodyColor'
				@DelayCompile('CompileBody')
				@DelayCompile('CompileWings')
				@DelayCompile('CompileHorn')
			when 'EyelashesColor'
				@DelayCompile('CompileEyelashes')
			when 'BodyBumpStrength', 'Socks', 'Bodysuit', 'LipsColor', 'NoseColor', 'LipsColorInherit', 'NoseColorInherit', 'EyebrowsColor', 'GlowingEyebrows', 'EyebrowsGlowStrength'
				@DelayCompile('CompileBody')
			when 'CMark', 'CMarkType', 'CMarkURL', 'CMarkColor', 'CMarkSize'
				@DelayCompile('CompileCMark')
			when 'SocksColor', 'SocksTextureURL', 'SocksTexture', 'SocksDetailColor1', 'SocksDetailColor2', 'SocksDetailColor3', 'SocksDetailColor4', 'SocksDetailColor5', 'SocksDetailColor6'
				@DelayCompile('CompileSocks')
			when 'NewSocksColor1', 'NewSocksColor2', 'NewSocksColor3', 'NewSocksTextureURL'
				@DelayCompile('CompileNewSocks')
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
					@DelayCompileNow('CompileLeftEye')
					@DelayCompileNow('CompileRightEye')
				elseif @@BODY_UPDATE_TRIGGER[key]
					@DelayCompile('CompileBody')
				elseif @@PHONG_UPDATE_TRIGGER[key]
					@UpdatePhongData()
				elseif @@CLOTHES_UPDATE_HEAD[key]
					@DelayCompile('CompileHeadClothes')
				elseif @@CLOTHES_UPDATE_EYES[key]
					@DelayCompile('CompileEyeClothes')
				elseif @@CLOTHES_UPDATE_NECK[key]
					@DelayCompile('CompileNeckClothes')
				elseif @@CLOTHES_UPDATE_BODY[key]
					@DelayCompile('CompileBodyClothes')

	@HTML_MATERIAL_QUEUE = {}
	@URL_MATERIAL_CACHE = {}
	@ALREADY_DOWNLOADING = {}
	@FAILED_TO_DOWNLOAD = {}

	hook.Add 'InvalidateMaterialCache', 'PPM2.WebTexturesCache', ->
		@HTML_MATERIAL_QUEUE = {}
		@URL_MATERIAL_CACHE = {}
		@ALREADY_DOWNLOADING = {}
		@FAILED_TO_DOWNLOAD = {}

	@LoadURL: (url, width = PPM2.GetTextureSize(@QUAD_SIZE_CONST), height = PPM2.GetTextureSize(@QUAD_SIZE_CONST), callback = (->)) =>
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
			for _, data in ipairs @HTML_MATERIAL_QUEUE
				if data.url == url
					table.insert(data.callbacks, callback)
					break
			return
		if @URL_MATERIAL_CACHE[width][height][url]
			callback(@URL_MATERIAL_CACHE[width][height][url].texture, nil, @URL_MATERIAL_CACHE[width][height][url].material)
			return
		@ALREADY_DOWNLOADING[width][height][url] = true
		table.insert(@HTML_MATERIAL_QUEUE, {:url, :width, :height, callbacks: {callback}, timeouts: 0})
		--PPM2.Message 'Queuing to download ', url
	@BuildURLHTML = (url = 'https://dbot.serealia.ca/illuminati.jpg', width = PPM2.GetTextureSize(@QUAD_SIZE_CONST), height = PPM2.GetTextureSize(@QUAD_SIZE_CONST)) =>
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
				table.remove(@HTML_MATERIAL_QUEUE, 1)
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

				@URL_MATERIAL_CACHE[data.width][data.height][data.url] = {
					texture: texture
					material: newMat
				}

				@ALREADY_DOWNLOADING[data.width][data.height][data.url] = false

				for _, callback in ipairs data.callbacks
					callback(texture, panel, newMat)
				timer.Simple 0, -> panel\Remove() if IsValid(panel)
			return

		data.frame = 0
		panel = vgui.Create('DHTML')
		panel\SetVisible(false)
		panel\SetSize(data.width, data.height)
		panel\SetHTML(@BuildURLHTML(data.url, data.width, data.height))
		panel\Refresh()

		panel.ConsoleMessage = (pnl, msg) ->
			if msg == 'FRAME'
				data.frame += 1

		data.panel = panel
		data.timerid = "PPM2.TextureMaterialTimeout.#{math.random(1, 100000)}"

		timer.Create data.timerid, 8, 1, ->
			return unless IsValid(panel)
			panel\Remove()
			if data.timeouts >= 4
				newMat = CreateMaterial("PPM2.URLMaterial_Failed_#{math.random(1, 100000)}", 'UnlitGeneric', {
					'$basetexture': 'null'
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

				for _, callback in ipairs data.callbacks
					callback(newMat\GetTexture('$basetexture'), nil, newMat)

				table.remove(@HTML_MATERIAL_QUEUE, 1)
			else
				data.timeouts += 1
				table.remove(@HTML_MATERIAL_QUEUE, 1)
				table.insert(@HTML_MATERIAL_QUEUE, data)

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
		@url_processes = 0
		@processing_first = true
		@CheckReflectionsClosure = -> @CheckReflections()
		@CompileTextures() if compile
		hook.Add('InvalidateMaterialCache', @, @InvalidateMaterialCache)
		PPM2.DebugPrint('Created new texture controller for ', @GetEntity(), ' as part of ', controller, '; internal ID is ', @id)

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
		--return if @compiled
		return if not @GetData()\IsValid()

		if now
			@CompileBody()
			@CompileHair()
			@CompileTail()
			@CompileHorn()
			@CompileWings()
			@CompileCMark()
			@CompileSocks()
			@CompileNewSocks()
			@CompileEyelashes()
			@CompileLeftEye()
			@CompileRightEye()
			@CompileBodyClothes()
			@CompileNeckClothes()
			@CompileHeadClothes()
			@CompileEyeClothes()
		else
			@DelayCompile('CompileBody')
			@DelayCompile('CompileHair')
			@DelayCompile('CompileTail')
			@DelayCompile('CompileHorn')
			@DelayCompile('CompileWings')
			@DelayCompile('CompileCMark')
			@DelayCompile('CompileSocks')
			@DelayCompile('CompileNewSocks')
			@DelayCompile('CompileEyelashes')
			@DelayCompile('CompileLeftEye')
			@DelayCompile('CompileRightEye')
			@DelayCompile('CompileBodyClothes')
			@DelayCompile('CompileNeckClothes')
			@DelayCompile('CompileHeadClothes')
			@DelayCompile('CompileEyeClothes')
		@compiled = true

	--@RT_SIZES = [math.pow(2, i) for i = 1, 24]

	StartRT: (name, texSize, r = 0, g = 0, b = 0, a = 255) =>
		error('Attempt to start new render target without finishing the old one!\nUPCOMING =======' .. debug.traceback() .. '\nCURRENT =======' .. @currentRTTrace) if @currentRT
		@currentRTTrace = debug.traceback()
		@oldW, @oldH = ScrW(), ScrH()
		rt = GetRenderTarget("PPM2_#{@@SessionID}_#{@GetID()}_#{name}_#{texSize}", texSize, texSize, false)
		rt\Download()
		render.PushRenderTarget(rt)
		render.Clear(r, g, b, a, true, true)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		cam.Start2D()
		cam.PushModelMatrix(Matrix())
		surface.SetDrawColor(r, g, b, a)
		surface.DrawRect(0, 0, texSize, texSize)
		@currentRT = rt
		return rt

	StartRTOpaque: (name, texSize, r = 0, g = 0, b = 0, a = 255) =>
		return @StartRT(name, texSize, r, g, b, a) if @@RT_BUFFER_BROKEN
		error('Attempt to start new render target without finishing the old one!\nUPCOMING =======' .. debug.traceback() .. '\nCURRENT =======' .. @currentRTTrace) if @currentRT
		@currentRTTrace = debug.traceback()
		@oldW, @oldH = ScrW(), ScrH()

		textureFlags = 0
		-- textureFlags = textureFlags + 16 -- anisotropic
		textureFlags = textureFlags + 256 -- no mipmaps
		textureFlags = textureFlags + 2048 -- Texture is procedural
		textureFlags = textureFlags + 4096
		textureFlags = textureFlags + 8388608
		textureFlags = textureFlags + 32768 -- Texture is a render target
		-- textureFlags = textureFlags + 67108864 -- Usable as a vertex texture

		rt = GetRenderTargetEx("PPM2_#{@@SessionID}_#{@GetID()}_#{name}_#{texSize}_op", texSize, texSize, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, textureFlags, 0, IMAGE_FORMAT_RGB888)
		if texSize ~= rt\Width() or texSize ~= rt\Height()
			PPM2.Message('Your videocard is garbage... I cant even save extra memory for you!')
			PPM2.Message('Switching to fat ass render targets with full buffer')
			@@RT_BUFFER_BROKEN = true
			return @StartRT(name, texSize, r, g, b, a)

		rt\Download()
		render.PushRenderTarget(rt)
		render.Clear(r, g, b, a, true, true)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		cam.Start2D()
		cam.PushModelMatrix(Matrix())
		surface.SetDrawColor(r, g, b, a)
		surface.DrawRect(0, 0, texSize, texSize)
		@currentRT = rt
		return rt

	EndRT: =>
		cam.PopModelMatrix()
		render.PopFilterMin()
		render.PopFilterMag()
		cam.End2D()
		render.PopRenderTarget()
		rt = @currentRT
		@currentRT = nil

		-- some shitty fixes for source engine
		cam.Start3D()
		cam.Start3D2D(Vector(0, 0, 0), Angle(0, 0, 0), 1)
		cam.End3D2D()
		cam.End3D()

		return rt

	CheckReflections: (ent = @GetEntity()) =>
		if REAL_TIME_EYE_REFLECTIONS\GetBool()
			@isInRealTimeLReflections = true
			@UpdateEyeReflections()
		elseif @isInRealTimeLReflections
			@isInRealTimeLReflections = false
			@ResetEyeReflections()

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
				clothesEnt\SetSubMaterial(@NeckClothes_Index[index], @NeckClothes_MatName[index]) for index = 1, #@NeckClothes_Index
			else
				clothesEnt\SetSubMaterial(index, '') for index in *@NeckClothes_Index

		if @EyeClothes_Index
			if @EyeClothes_MatName
				clothesEnt\SetSubMaterial(@EyeClothes_Index[index], @EyeClothes_MatName[index]) for index = 1, #@EyeClothes_Index
			else
				clothesEnt\SetSubMaterial(index, '') for index in *@EyeClothes_Index

		if @HeadClothes_Index
			if @HeadClothes_MatName
				clothesEnt\SetSubMaterial(@HeadClothes_Index[index], @HeadClothes_MatName[index]) for index = 1, #@HeadClothes_Index
			else
				clothesEnt\SetSubMaterial(index, '') for index in *@HeadClothes_Index

		if @BodyClothes_Index
			if @BodyClothes_MatName
				clothesEnt\SetSubMaterial(@BodyClothes_Index[index], @BodyClothes_MatName[index]) for index = 1, #@BodyClothes_Index
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

	@GetBodySize = => PPM2.GetTextureSize(@QUAD_SIZE_BODY * (USE_HIGHRES_BODY\GetInt() + 1))

	DrawTattoo: (index = 1, drawingGlow = false, texSize = @@GetBodySize()) =>
		mat = _M.TATTOOS[@GrabData("TattooType#{index}")]
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
		tSize = PPM2.GetTextureSize(@@TATTOO_DEF_SIZE * (USE_HIGHRES_BODY\GetInt() + 1))
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
		LightwarpURL = @GrabData(prefix .. 'LightwarpURL')
		BumpmapURL = @GrabData(prefix .. 'BumpmapURL')
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

		if LightwarpURL == '' or not LightwarpURL\find('^https?://')
			myTex = PPM2.AvaliableLightwarpsPaths[Lightwarp + 1] or PPM2.AvaliableLightwarpsPaths[1]
			matTarget\SetTexture('$lightwarptexture', myTex)
		else
			ticket = @PutTicket(prefix .. '_phong')

			@@LoadURL LightwarpURL, 256, 16, (tex, panel, mat) ->
				return if not @CheckTicket(prefix .. '_phong', ticket)
				matTarget\SetTexture('$lightwarptexture', tex)

		if not noBump
			if BumpmapURL == '' or not BumpmapURL\find('^https?://')
				matTarget\SetUndefined('$bumpmap')
			else
				ticket = @PutTicket(prefix .. '_bump')

				@@LoadURL BumpmapURL, matTarget\Width(), matTarget\Height(), (tex, panel, mat) ->
					return if not @CheckTicket(prefix .. '_bump', ticket)
					matTarget\SetTexture('$bumpmap', tex)

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
		urlTextures = {}
		left = 0
		bodysize = @@GetBodySize()

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

		@BodyMaterialName = "!#{textureData.name\lower()}"
		@BodyMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@UpdatePhongData()

		@url_processes += 1

		continueCompilation = ->
			@url_processes -= 1

			return unless @isValid
			{:r, :g, :b} = @GrabData('BodyColor')
			@StartRTOpaque("Body_rt", bodysize, r, g, b)

			surface.DrawRect(0, 0, bodysize, bodysize)

			for i = 1, PPM2.MAX_BODY_DETAILS
				if @GrabData('BodyDetailFirst' .. i)
					if mat = _M.BODY_DETAILS[@GrabData("BodyDetail#{i}")]
						surface.SetDrawColor(@GrabData("BodyDetailColor#{i}"))
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			surface.SetDrawColor(255, 255, 255)

			for i, mat in pairs urlTextures
				if @GrabData('BodyDetailURLFirst' .. i)
					surface.SetDrawColor(@GrabData("BodyDetailURLColor#{i}"))
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			surface.SetDrawColor(@GrabData('EyebrowsColor'))
			surface.SetMaterial(_M.EYEBROWS)
			surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			if not @GrabData('LipsColorInherit')
				surface.SetDrawColor(@GrabData('LipsColor'))
			else
				{:r, :g, :b} = @GrabData('BodyColor')
				r, g, b = math.max(r - 30, 0), math.max(g - 30, 0), math.max(b - 30, 0)
				surface.SetDrawColor(r, g, b)

			surface.SetMaterial(_M.LIPS)
			surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			if not @GrabData('NoseColorInherit')
				surface.SetDrawColor(@GrabData('NoseColor'))
			else
				{:r, :g, :b} = @GrabData('BodyColor')
				r, g, b = math.max(r - 30, 0), math.max(g - 30, 0), math.max(b - 30, 0)
				surface.SetDrawColor(r, g, b)

			surface.SetMaterial(_M.NOSE)
			surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			@DrawTattoo(i) for i = 1, PPM2.MAX_TATTOOS when @GrabData("TattooOverDetail#{i}")

			for i = 1, PPM2.MAX_BODY_DETAILS
				if not @GrabData('BodyDetailFirst' .. i)
					if mat = _M.BODY_DETAILS[@GrabData("BodyDetail#{i}")]
						surface.SetDrawColor(@GrabData("BodyDetailColor#{i}"))
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			surface.SetDrawColor(255, 255, 255)

			for i, mat in pairs urlTextures
				if not @GrabData('BodyDetailURLFirst' .. i)
					surface.SetDrawColor(@GrabData("BodyDetailURLColor#{i}"))
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			@DrawTattoo(i) for i = 1, PPM2.MAX_TATTOOS when @GrabData("TattooOverDetail#{i}")

			if suit = _M.SUITS[@GrabData('Bodysuit')]
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(suit)
				surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			if @GrabData('Socks')
				surface.SetDrawColor(255, 255, 255)
				surface.SetMaterial(@@PONY_SOCKS)
				surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			@BodyMaterial\SetTexture('$basetexture', @EndRT())

			@StartRTOpaque("Body_rtBump", bodysize, 127, 127, 255)

			surface.SetDrawColor(255, 255, 255, @GrabData('BodyBumpStrength') * 255)
			surface.SetMaterial(_M.BODY_BUMP)
			surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			@BodyMaterial\SetTexture('$bumpmap', @EndRT())

			@StartRTOpaque("Body_rtIllum", bodysize)
			surface.SetDrawColor(255, 255, 255)

			if @GrabData('GlowingEyebrows')
				surface.SetDrawColor(255, 255, 255, 255 * @GrabData('EyebrowsGlowStrength'))
				surface.SetMaterial(_M.EYEBROWS)
				surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			for i = 1, PPM2.MAX_TATTOOS
				if not @GrabData("TattooOverDetail#{i}")
					@DrawTattoo(i, true)

			for i = 1, PPM2.MAX_BODY_DETAILS
				if mat = _M.BODY_DETAILS[@GetData()["GetBodyDetail#{i}"](@GetData())]
					alpha = @GetData()["GetBodyDetailGlowStrength#{i}"](@GetData())

					if @GetData()["GetBodyDetailGlow#{i}"](@GetData())
						surface.SetDrawColor(255, 255, 255, alpha * 255)
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, bodysize, bodysize)
					else
						surface.SetDrawColor(0, 0, 0, alpha * 255)
						surface.SetMaterial(mat)
						surface.DrawTexturedRect(0, 0, bodysize, bodysize)

			for i = 1, PPM2.MAX_TATTOOS
				if @GrabData("TattooOverDetail#{i}")
					@DrawTattoo(i, true)

			@BodyMaterial\SetTexture('$selfillummask', @EndRT())
			PPM2.DebugPrint('Compiled body texture for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, PPM2.MAX_BODY_DETAILS
			detailURL = data["GetBodyDetailURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		tickets = {i, @PutTicket('body_detail' .. i) for i = 1, PPM2.MAX_BODY_DETAILS}

		for _, {url, i} in ipairs validURLS
			@@LoadURL url, bodysize, bodysize, (texture, panel, mat) ->
				return if not @CheckTicket('body_detail' .. i, tickets[i])
				left -= 1
				urlTextures[i] = mat
				if left == 0
					continueCompilation()

		continueCompilation() if left == 0
		return @BodyMaterial

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

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_HORN)
		urlTextures = {}
		left = 0

		@HornMaterialName = "!#{textureData.name\lower()}"
		@HornMaterialName1 = "!#{textureData_New1.name\lower()}"
		@HornMaterialName2 = "!#{textureData_New2.name\lower()}"
		@HornMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@HornMaterial1 = CreateMaterial(textureData_New1.name, textureData_New1.shader, textureData_New1.data)
		@HornMaterial2 = CreateMaterial(textureData_New2.name, textureData_New2.shader, textureData_New2.data)
		@UpdatePhongData()

		@url_processes += 1

		continueCompilation = ->
			@url_processes -= 1

			{:r, :g, :b} = @GrabData('BodyColor')
			{:r, :g, :b} = @GrabData('HornColor') if @GrabData('SeparateHorn')
			@StartRTOpaque('Horn', texSize, r, g, b)

			@HornMaterial1\SetVector('$color2', Vector(r / 255, g / 255, b / 255))
			{:r, :g, :b} = @GrabData('HornDetailColor')
			@HornMaterial2\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

			surface.SetDrawColor(r, g, b)
			surface.SetMaterial(@@HORN_DETAIL_COLOR)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			for i, mat in pairs urlTextures
				{:r, :g, :b, :a} = @GrabData("HornURLColor#{i}")
				surface.SetDrawColor(r, g, b, a)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			@HornMaterial\SetTexture('$basetexture', @EndRT())

			@StartRTOpaque('Horn_illum', texSize)

			if @GrabData('HornGlow')
				@HornMaterial2\SetTexture('$selfillummask', 'models/debug/debugwhite')
				surface.SetDrawColor(255, 255, 255, @GrabData('HornGlowSrength') * 255)
				surface.SetMaterial(@@HORN_DETAIL_COLOR)
				surface.DrawTexturedRect(0, 0, texSize, texSize)
			else
				@HornMaterial2\SetTexture('$selfillummask', 'null')

			@HornMaterial\SetTexture('$selfillummask', @EndRT())

			{:r, :g, :b} = @@BUMP_COLOR
			@StartRTOpaque('Horn_bump', texSize, r, g, b)
			alpha = 255
			alpha = @GrabData('HornDetailColor').a
			surface.SetDrawColor(255, 255, 255, alpha)
			surface.SetMaterial(_M.HORN_DETAIL_BUMP)
			surface.DrawTexturedRect(0, 0, texSize, texSize)
			@HornMaterial\SetTexture('$bumpmap', @EndRT())

			PPM2.DebugPrint('Compiled Horn texture for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, 3
			detailURL = data["GetHornURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		tickets = {i, @PutTicket('horn' .. i) for i = 1, 3}

		for _, {url, i} in ipairs validURLS
			@@LoadURL url, texSize, texSize, (texture, panel, mat) ->
				return if not @CheckTicket('horn' .. i, tickets[i])
				left -= 1
				urlTextures[i] = mat
				if left == 0
					continueCompilation()

		if left == 0
			continueCompilation()

		return @HornMaterial

	CompileClothPart: (iName, matregistry, indexregistry, rtsize, opaque = true) =>
		return unless @isValid

		data = {
			'$basetexture': 'models/debug/debugwhite'

			'$phong': '1'
			'$phongexponent': '20'
			'$phongboost': '.1'
			'$phongfresnelranges':	'[.3 1 8]'
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
			url = @GrabData(iName .. 'ClothesURL' .. i)\trim()
			url = '' if not url\find('^https?://')
			urls[i] = url if url ~= ''

		tickets = {i, @PutTicket('clothes' .. i) for i = 1, PPM2.MAX_CLOTHES_URLS}

		colored = @GrabData(iName .. 'ClothesUseColor')

		if not colored and table.Count(urls) == 0
			@[iName .. 'Clothes_Mat'] = nil
			@[iName .. 'Clothes_MatName'] = nil
			@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)
			return

		if #matregistry[clothes + 1] == 0
			name = "PPM2_#{@@SessionID}_#{@GetID()}_Clothes_#{iName}_1"
			mat = CreateMaterial(name, 'VertexLitGeneric', data)
			@[iName .. 'Clothes_Mat'] = {mat}
			@[iName .. 'Clothes_MatName'] = {"!#{name}"}

			if urls[1]
				@url_processes += 1

				@@LoadURL urls[1], texSize, texSize, (texture, panel, material) ->
					return if not @CheckTicket('clothes1', tickets[1])
					@url_processes -= 1

					mat\SetVector('$color2', Vector(1, 1, 1))
					mat\SetTexture('$basetexture', texture)

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

		for matIndex = 1, #matregistry[clothes + 1]
			name = "PPM2_#{@@SessionID}_#{@GetID()}_Clothes_#{iName}_#{matIndex}"
			mat = CreateMaterial(name, 'VertexLitGeneric', data)

			tab1[matIndex] = mat
			tab2[matIndex] = "!#{name}"

			if urls[matIndex]
				@url_processes += 1

				@@LoadURL urls[matIndex], texSize, texSize, (texture, panel, material) ->
					return if not @CheckTicket('clothes' .. matIndex, tickets[matIndex])
					@url_processes -= 1

					mat\SetVector('$color2', Vector(1, 1, 1))
					mat\SetTexture('$basetexture', texture)

					@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)
			elseif colored and #matregistry[clothes + 1][matIndex] == 0
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
				rtsize = PPM2.GetTextureSize(rtsize)
				mat\SetVector('$color2', Vector(1, 1, 1))
				{:r, :g, :b, :a} = @GrabData("#{iName}ClothesColor#{nextindex}")

				if opaque
					mat\SetFloat('$alpha', 1)
					mat\SetInt('$translucent', 0)
				else
					mat\SetFloat('$alpha', a / 255)
					mat\SetInt('$translucent', 1)

				nextindex += 1
				@StartRTOpaque("Clothes_#{iName}_#{matIndex}", rtsize, r, g, b)

				for i, texture in ipairs(matregistry[clothes + 1][matIndex])
					if not isnumber(texture)
						surface.SetMaterial(texture)
						surface.SetDrawColor(@GrabData("#{iName}ClothesColor#{nextindex}"))
						nextindex += 1
						surface.DrawTexturedRect(0, 0, rtsize, rtsize)

				mat\SetTexture('$basetexture', @EndRT())
			else
				tab1[matIndex] = nil
				tab2[matIndex] = nil

		@UpdateClothes(nil, @clothesModel) if IsValid(@clothesModel)

	CompileHeadClothes: => @CompileClothPart('Head', _M.HEAD_CLOTHES, _M.HEAD_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_HEAD)
	CompileBodyClothes: => @CompileClothPart('Body', _M.BODY_CLOTHES, _M.BODY_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_BODY)
	CompileNeckClothes: => @CompileClothPart('Neck', _M.NECK_CLOTHES, _M.NECK_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_NECK)
	CompileEyeClothes: => @CompileClothPart('Eye', _M.EYE_CLOTHES, _M.EYE_CLOTHES_INDEX, @@QUAD_SIZE_CLOTHES_EYES, false)

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

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_SOCKS)

		@UpdatePhongData()

		url = @GrabData('NewSocksTextureURL')
		if url == '' or not url\find('^https?://')
			{:r, :g, :b} = @GrabData('NewSocksColor1')
			@NewSocksColor1\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

			{:r, :g, :b} = @GrabData('NewSocksColor2')
			@NewSocksColor2\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

			{:r, :g, :b} = @GrabData('NewSocksColor3')
			@NewSocksBase\SetVector('$color2', Vector(r / 255, g / 255, b / 255))

			PPM2.DebugPrint('Compiled new socks texture for ', @GetEntity(), ' as part of ', @)
		else
			@url_processes += 1
			ticket = @PutTicket('newsocks')

			@@LoadURL url, texSize, texSize, (texture, panel, material) ->
				return if not @CheckTicket('newsocks', ticket)
				@url_processes -= 1

				for _, tex in ipairs {@NewSocksColor1, @NewSocksColor2, @NewSocksBase}
					tex\SetVector('$color2', Vector(1, 1, 1))
					tex\SetTexture('$basetexture', texture)

		return @NewSocksColor1, @NewSocksColor2, @NewSocksBase

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

		PPM2.DebugPrint('Compiled new eyelashes texture for ', @GetEntity(), ' as part of ', @)

		return @Eyelashes

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
		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_SOCKS)

		{:r, :g, :b} = @GrabData('SocksColor')
		@SocksMaterial\SetFloat('$alpha', 1)

		url = @GrabData('SocksTextureURL')
		if url == '' or not url\find('^https?://')
			@SocksMaterial\SetVector('$color', Vector(1, 1, 1))
			@SocksMaterial\SetVector('$color2', Vector(1, 1, 1))
			@StartRTOpaque('Socks', texSize, r, g, b)

			socksType = @GrabData('SocksTexture') + 1
			surface.SetMaterial(_M.SOCKS_MATERIALS[socksType] or _M.SOCKS_MATERIALS[1])
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			if details = _M.SOCKS_DETAILS[socksType]
				for i, id in pairs details
					{:r, :g, :b} = @GetData()['GetSocksDetailColor' .. i](@GetData())
					surface.SetDrawColor(r, g, b)
					surface.SetMaterial(id)
					surface.DrawTexturedRect(0, 0, texSize, texSize)

			@SocksMaterial\SetTexture('$basetexture', @EndRT())
			PPM2.DebugPrint('Compiled socks texture for ', @GetEntity(), ' as part of ', @)
		else
			ticket = @PutTicket('socks')

			@@LoadURL url, texSize, texSize, (texture, panel, material) ->
				return if not @CheckTicket('socks', ticket)
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

		urlTextures = {}
		left = 0
		@WingsMaterialName = "!#{textureData.name\lower()}"
		@WingsMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@UpdatePhongData()

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_WING)

		@url_processes += 1

		continueCompilation = ->
			@url_processes -= 1

			{:r, :g, :b} = @GrabData('BodyColor')
			{:r, :g, :b} = @GrabData('WingsColor') if @GrabData('SeparateWings')
			rt = @StartRTOpaque('Wings_rt', texSize, r, g, b)

			surface.SetMaterial(@@WINGS_MATERIAL_COLOR)
			surface.DrawTexturedRect(0, 0, texSize, texSize)

			for i, mat in pairs urlTextures
				{:r, :g, :b, :a} = @GetData()["GetWingsURLColor#{i}"](@GetData())
				surface.SetDrawColor(r, g, b, a)
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			@WingsMaterial\SetTexture('$basetexture', rt)
			@EndRT()
			PPM2.DebugPrint('Compiled wings texture for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, 3
			detailURL = data["GetWingsURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		tickets = {i, @PutTicket('wing' .. i) for i = 1, 3}

		for _, {url, i} in ipairs validURLS
			@@LoadURL url, texSize, texSize, (texture, panel, mat) ->
				return if not @CheckTicket('wing' .. i, tickets[i])
				left -= 1
				urlTextures[i] = mat
				if left == 0
					continueCompilation()
		if left == 0
			continueCompilation()

		return @WingsMaterial

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

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_HAIR)

		urlTextures = {}
		left = 0

		@url_processes += 1

		continueCompilation = ->
			@url_processes -= 1

			return unless @isValid
			{:r, :g, :b} = @GrabData('ManeColor1')
			@StartRTOpaque('Mane_1', texSize, r, g, b)

			maneTypeUpper = @GetManeType()
			if @@UPPER_MANE_MATERIALS[maneTypeUpper]
				i = 1
				for _, mat in ipairs @@UPPER_MANE_MATERIALS[maneTypeUpper]
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

			@HairColor1Material\SetTexture('$basetexture', @EndRT())

			-- Second mane pass
			{:r, :g, :b} = @GrabData('ManeColor2')
			@StartRTOpaque('Mane_2', texSize, r, g, b)

			maneTypeLower = @GetManeTypeLower()
			if @@LOWER_MANE_MATERIALS[maneTypeLower]
				i = 1
				for _, mat in ipairs @@LOWER_MANE_MATERIALS[maneTypeLower]
					continue if type(mat) == 'number'
					surface.SetDrawColor(@GrabData("ManeDetailColor#{i}"))
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, texSize, texSize)
					i += 1

			for i, mat in pairs urlTextures
				surface.SetDrawColor(@GrabData("ManeURLColor#{i}"))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			@HairColor2Material\SetTexture('$basetexture', @EndRT())
			PPM2.DebugPrint('Compiled mane textures for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, 6
			detailURL = data["GetManeURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		tickets = {i, @PutTicket('mane' .. i) for i = 1, 6}

		for _, {url, i} in ipairs validURLS
			@@LoadURL url, texSize, texSize, (texture, panel, mat) ->
				return if not @CheckTicket('mane' .. i, tickets[i])
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

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_TAIL)

		urlTextures = {}
		left = 0

		@url_processes += 1

		continueCompilation = ->
			@url_processes -= 1

			return unless @isValid
			{:r, :g, :b} = @GrabData('TailColor1')

			-- First tail pass
			@StartRTOpaque('Tail_1', texSize, r, g, b)

			tailType = @GetTailType()
			if @@TAIL_DETAIL_MATERIALS[tailType]
				i = 1
				for _, mat in ipairs @@TAIL_DETAIL_MATERIALS[tailType]
					continue if type(mat) == 'number'
					surface.SetMaterial(mat)
					surface.SetDrawColor(@GetData()["GetTailDetailColor#{i}"](@GetData()))
					surface.DrawTexturedRect(0, 0, texSize, texSize)
					i += 1

			for i, mat in pairs urlTextures
				surface.SetDrawColor(@GetData()["GetTailURLColor#{i}"](@GetData()))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			@TailColor1Material\SetTexture('$basetexture', @EndRT())

			-- Second tail pass
			{:r, :g, :b} = @GrabData('TailColor2')
			@StartRTOpaque('Tail_2', texSize, r, g, b)

			if @@TAIL_DETAIL_MATERIALS[tailType]
				i = 1
				for _, mat in ipairs @@TAIL_DETAIL_MATERIALS[tailType]
					continue if type(mat) == 'number'
					surface.SetMaterial(mat)
					surface.SetDrawColor(@GrabData("TailDetailColor#{i}"))
					surface.DrawTexturedRect(0, 0, texSize, texSize)
					i += 1

			for i, mat in pairs urlTextures
				surface.SetDrawColor(@GrabData("TailURLColor#{i}"))
				surface.SetMaterial(mat)
				surface.DrawTexturedRect(0, 0, texSize, texSize)

			@TailColor2Material\SetTexture('$basetexture', @EndRT())
			PPM2.DebugPrint('Compiled tail textures for ', @GetEntity(), ' as part of ', @)

		data = @GetData()
		validURLS = for i = 1, 6
			detailURL = data["GetTailURL#{i}"](data)
			continue if detailURL == '' or not detailURL\find('^https?://')
			left += 1
			{detailURL, i}

		tickets = {i, @PutTicket('tail' .. i) for i = 1, 6}

		for _, {url, i} in ipairs validURLS
			@@LoadURL url, texSize, texSize, (texture, panel, mat) ->
				return if not @CheckTicket('tail' .. i, tickets[i])
				left -= 1
				urlTextures[i] = mat
				if left == 0
					continueCompilation()
		if left == 0
			continueCompilation()
		return @TailColor1Material, @TailColor2Material

	@REFLECT_RENDER_SIZE = 64
	@GetReflectionsScale: =>
		val = REAL_TIME_EYE_REFLECTIONS_SIZE\GetInt()
		return @REFLECT_RENDER_SIZE if val % 2 ~= 0
		return val

	ResetEyeReflections: =>
		@EyeMaterialL\SetTexture('$iris', @EyeTextureL) if @EyeTextureL
		@EyeMaterialR\SetTexture('$iris', @EyeTextureR) if @EyeTextureR

	UpdateEyeReflections: (ent = @GetEntity()) =>
		return if not @EyeMaterialDrawL or not @EyeMaterialDrawR
		return if not ent\IsValid()
		@AttachID = @AttachID or @GetEntity()\LookupAttachment('eyes')
		local Pos
		local Ang
		{:Pos, :Ang} = @GetEntity()\GetAttachment(@AttachID) if ent == @GetEntity()
		{:Pos, :Ang} = ent\GetAttachment(ent\LookupAttachment('eyes')) if ent ~= @GetEntity()

		return @ResetEyeReflections() if Pos\Distance(EyePos()) > REAL_TIME_EYE_REFLECTIONS_DIST\GetInt()

		scale = @@GetReflectionsScale()
		@lastScale = @lastScale or scale
		if @lastScale ~= scale
			@lastScale = scale
			@reflectRT = nil
			@reflectRTMat = nil

		texName = "PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_EyesReflect_#{scale}"
		--reflectrt = @reflectRT or GetRenderTargetEx(
		--  texName,
		--  scale,
		--  scale,
		--  RT_SIZE_DEFAULT,
		--  MATERIAL_RT_DEPTH_NONE,
		--  1 + 32768 + 2048 + 8388608 + 512 + 256,
		--  CREATERENDERTARGETFLAGS_UNFILTERABLE_OK,
		--  IMAGE_FORMAT_RGB888
		--)

		reflectrt = @@reflectRT or GetRenderTarget(
			texName,
			scale,
			scale,
			false
		)

		reflectrt\Download()
		@@reflectRT = reflectrt
		@reflectRTMat = @reflectRTMat or CreateMaterial(texName .. '_Mat', 'UnlitGeneric', {
			'$basetexture': 'models/debug/debugwhite'
			'$ignorez': 1
			'$vertexcolor': 1
			'$translucent': 1
			'$alpha': 1
			'$vertexalpha': 1
			'$nolod': 1
		})

		@reflectRTMat\SetTexture('$basetexture', reflectrt)

		render.PushRenderTarget(reflectrt)
		render.Clear(0, 0, 0, 255, true, true)

		viewData = {}
		viewData.drawhud = false
		viewData.drawmonitors = false
		viewData.drawviewmodel = false
		viewData.origin = Pos
		viewData.angles = Ang
		viewData.x = 0
		viewData.y = 0
		viewData.fov = 150
		viewData.w = scale
		viewData.h = scale
		viewData.aspectratio = 1
		viewData.znear = 1
		viewData.zfar = REAL_TIME_EYE_REFLECTIONS_RDIST\GetInt()

		render.RenderView(viewData)
		render.PopRenderTarget()

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_EYES)

		surface.DisableClipping(true)
		rtleft = GetRenderTarget("PPM2_#{@@SessionID}_#{@GetID()}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_LeftReflect_#{scale}", texSize, texSize, false)
		rtleft\Download()
		rtright = GetRenderTarget("PPM2_#{@@SessionID}_#{@GetID()}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_RightReflect_#{scale}", texSize, texSize, false)
		rtright\Download()

		W, H = 1, 1

		separated = @GrabData('SeparateEyes')
		prefixData = ''
		prefixData = 'Left' if separated

		render.PushRenderTarget(rtleft)
		render.Clear(0, 0, 0, 255, true, true)
		cam.Start2D()

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(@EyeMaterialDrawL)
		surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)

		surface.SetDrawColor(255, 255, 255, 255 * @GrabData('EyeGlossyStrength' .. prefixData))
		surface.SetMaterial(@reflectRTMat)
		surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)

		cam.End2D()
		render.PopRenderTarget()
		@EyeMaterialL\SetTexture('$iris', rtleft)

		prefixData = 'Right' if separated

		render.PushRenderTarget(rtright)
		render.Clear(0, 0, 0, 255, true, true)
		cam.Start2D()

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(@EyeMaterialDrawR)
		surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)

		surface.SetDrawColor(255, 255, 255, 255 * @GrabData('EyeGlossyStrength' .. prefixData))
		surface.SetMaterial(@reflectRTMat)
		surface.DrawTexturedRect(0, 0, texSize * W, texSize * H)

		cam.End2D()
		render.PopRenderTarget()
		surface.DisableClipping(false)

		@EyeMaterialR\SetTexture('$iris', rtright)

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
		PonySize = 1 if IsValid(@GetEntity()) and @GetEntity()\IsRagdoll()

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_EYES)

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
			@StartRT("EyeCornea_#{prefix}", texSize)

			if EyeCornerA
				surface.SetMaterial(_M.EYE_CORNERA_OVAL)
				surface.SetDrawColor(255, 255, 255)
				DrawTexturedRectRotated(IrisPos + shiftX - texSize / 16, IrisPos + shiftY - texSize / 16, IrisQuadSize * IrisWidth * 1.5, IrisQuadSize * IrisHeight * 1.5, EyeRotation)

			createdMaterial\SetTexture('$corneatexture', @EndRT())

		if EyeURL == '' or not EyeURL\find('^https?://')
			{:r, :g, :b, :a} = EyeBackground
			rt = @StartRTOpaque("#{EyeRefract and 'EyeRefract' or 'Eyes'}_#{prefix}", texSize, r, g, b)
			@["EyeTexture#{prefixUpper}"] = rt

			drawMat = CreateMaterial("PPM2_#{@@SessionID}_#{USE_HIGHRES_TEXTURES\GetBool() and 'HD' or 'NORMAL'}_#{@GetID()}_#{EyeRefract and 'EyeRefract' or 'Eyes'}_RenderMat_#{prefix}", 'UnlitGeneric', {
				'$basetexture': 'models/debug/debugwhite'
				'$ignorez': 1
				'$vertexcolor': 1
				'$vertexalpha': 1
				'$nolod': 1
			})

			@["EyeMaterialDraw#{prefixUpper}"] = drawMat
			drawMat\SetTexture('$basetexture', rt)

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
			surface.SetMaterial(_M.EYE_REFLECTIONS[EyeReflectionType + 1])
			DrawTexturedRectRotated(IrisPos + shiftX, IrisPos + shiftY, IrisQuadSize * IrisWidth, IrisQuadSize * IrisHeight, EyeRotation)

			@["EyeMaterial#{prefixUpper}"]\SetTexture('$iris', @EndRT())

			PPM2.DebugPrint('Compiled eyes texture for ', @GetEntity(), ' as part of ', @)
		else
			@url_processes += 1
			ticket = @PutTicket(prefixData .. '_eye')

			@@LoadURL EyeURL, texSize, texSize, (texture, panel, material) ->
				return if not @CheckTicket(prefixData .. '_eye', ticket)
				@url_processes -= 1
				@["EyeMaterial#{prefixUpper}"]\SetTexture('$iris', texture)

		return @["EyeMaterial#{prefixUpper}"]

	CompileCMark: =>
		return unless @isValid
		textureData = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_CMark"
			'shader': 'VertexLitGeneric'
			'data': {
				'$basetexture': 'null'
				'$translucent': '1'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
				'$halflambert': '1'
			}
		}

		textureDataGUI = {
			'name': "PPM2_#{@@SessionID}_#{@GetID()}_CMark_GUI"
			'shader': 'UnlitGeneric'
			'data': {
				'$basetexture': 'null'
				'$translucent': '1'
				'$lightwarptexture': 'models/ppm2/base/lightwrap'
				'$halflambert': '1'
			}
		}

		@CMarkTextureName = "!#{textureData.name\lower()}"
		@CMarkTexture = CreateMaterial(textureData.name, textureData.shader, textureData.data)
		@CMarkTextureGUIName = "!#{textureDataGUI.name\lower()}"
		@CMarkTextureGUI = CreateMaterial(textureDataGUI.name, textureDataGUI.shader, textureDataGUI.data)

		unless @GrabData('CMark')
			@CMarkTexture\SetTexture('$basetexture', 'null')
			@CMarkTextureGUI\SetTexture('$basetexture', 'null')
			return @CMarkTexture, @CMarkTextureGUI

		URL = @GrabData('CMarkURL')
		size = @GrabData('CMarkSize')

		texSize = PPM2.GetTextureSize(@@QUAD_SIZE_CMARK)
		sizeQuad = texSize * size
		shift = (texSize - sizeQuad) / 2

		if URL == '' or not URL\find('^https?://')
			rt = @StartRT('CMark', texSize, 0, 0, 0, 0)

			if mark = _M.CUTIEMARKS[@GrabData('CMarkType') + 1]
				surface.SetDrawColor(@GrabData('CMarkColor'))
				surface.SetMaterial(mark)
				surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)

			@EndRT()
			@CMarkTexture\SetTexture('$basetexture', rt)
			@CMarkTextureGUI\SetTexture('$basetexture', rt)

			PPM2.DebugPrint('Compiled cutiemark texture for ', @GetEntity(), ' as part of ', @)
		else
			@url_processes += 1
			ticket = @PutTicket('cmark')

			@@LoadURL URL, texSize, texSize, (texture, panel, material) ->
				return if not @CheckTicket('cmark', ticket)
				@url_processes -= 1

				rt = @StartRT('CMark', texSize, 0, 0, 0, 0)

				surface.SetDrawColor(@GrabData('CMarkColor'))
				surface.SetMaterial(material)
				surface.DrawTexturedRect(shift, shift, sizeQuad, sizeQuad)

				@EndRT()
				@CMarkTexture\SetTexture('$basetexture', rt)
				@CMarkTextureGUI\SetTexture('$basetexture', rt)
				PPM2.DebugPrint('Compiled cutiemark texture for ', @GetEntity(), ' as part of ', @)

		return @CMarkTexture, @CMarkTextureGUI

PPM2.PonyTextureController = PonyTextureController
PPM2.GetTextureController = (model = 'models/ppm/player_default_base.mdl') -> PonyTextureController.AVALIABLE_CONTROLLERS[model\lower()] or PonyTextureController
