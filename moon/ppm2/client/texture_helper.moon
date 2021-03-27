
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

PPM2 = PPM2

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
PPM2.LOCKED_RENDERTARGETS = PPM2.LOCKED_RENDERTARGETS or {}
PPM2.LOCKED_RENDERTARGETS_MASK = PPM2.LOCKED_RENDERTARGETS_MASK or {}

PPM2.TEXTURE_TASKS = PPM2.TEXTURE_TASKS or {}
PPM2.TEXTURE_TASKS_EDITOR = PPM2.TEXTURE_TASKS_EDITOR or {}

coroutine_yield = coroutine.yield
coroutine_resume = coroutine.resume
coroutine_status = coroutine.status

PPM2.URLThreadWorker = ->
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

			systime = SysTime() + 16

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

				systime = SysTime() + 1

				while not htmlmat and systime <= SysTime()
					htmlmat = panel\GetHTMLMaterial()

				if htmlmat
					rt, mat = PPM2.PonyTextureController\LockRenderTarget(data.width, data.height, 0, 0, 0, 0)

					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(htmlmat)
					surface.DrawTexturedRect(0, 0, data.width, data.height)

					vtf = DLib.VTF.Create(2, data.width, data.height, IMAGE_FORMAT_DXT5, {fill: Color(0, 0, 0, 0)})
					vtf\CaptureRenderTargetCoroutine()

					if select('#', render.ReadPixel(0, 0)) == 3
						PPM2.PonyTextureController\_CaptureAlphaClosure(data.width, mat, vtf)
					else
						PPM2.PonyTextureController\ReleaseRenderTarget(data.width, data.height)

					path = '../data/' .. PPM2.CacheManager\Set(data.index, vtf\ToString())

					newMat = CreateMaterial("PPM2_URLMaterial_#{data.hash}", 'UnlitGeneric', {
						'$basetexture': '../data/' .. path
						'$ignorez': 1
						'$vertexcolor': 1
						'$vertexalpha': 1
						'$nolod': 1
					})

					newMat\SetTexture('$basetexture', '../data/' .. path)
					newMat\GetTexture('$basetexture')\Download() if developer\GetBool()

					PPM2.URL_MATERIAL_CACHE[data.index] = {
						texture: newMat\GetTexture('$basetexture')
						material: newMat
						index: data.index
						hash: data.hash
					}

					PPM2.ALREADY_DOWNLOADING[data.index] = nil

					for resolve in *data.resolve
						resolve(newMat\GetTexture('$basetexture'), newMat)
				else
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

				coroutine_yield()
				panel\Remove() if IsValid(panel)

PPM2.URLThread = PPM2.URLThread or coroutine.create(PPM2.URLThreadWorker)

PPM2.GetURLMaterial = (url, width = 512, height = 512) ->
	assert(isstring(url) and url\trim() ~= '', 'Must specify valid URL', 2)

	index = url .. '__' .. width .. '_' .. height

	if data = PPM2.FAILED_TO_DOWNLOAD[index]
		return DLib.Promise (resolve) -> resolve(data.texture, data.material)

	if data = PPM2.URL_MATERIAL_CACHE[index]
		return DLib.Promise (resolve) -> resolve(data.texture, data.material)

	if data = PPM2.ALREADY_DOWNLOADING[index]
		return DLib.Promise (resolve) -> table.insert(data.resolve, resolve)

	if getcache = PPM2.CacheManager\HasGet(index)
		return DLib.Promise (resolve) ->
			hash = DLib.Util.QuickSHA1(index)

			newMat = CreateMaterial("PPM2_URLMaterial_#{hash}", 'UnlitGeneric', {
				'$basetexture': '../data/' .. getcache
				'$ignorez': 1
				'$vertexcolor': 1
				'$vertexalpha': 1
				'$nolod': 1
			})

			newMat\SetTexture('$basetexture', '../data/' .. getcache)
			newMat\GetTexture('$basetexture')\Download() if developer\GetBool()

			PPM2.URL_MATERIAL_CACHE[index] = {
				texture: newMat\GetTexture('$basetexture')
				material: newMat
				index: index
				:hash
			}

			resolve(newMat\GetTexture('$basetexture'), newMat)

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

	if not status
		PPM2.URLThread = coroutine.create(PPM2.URLThreadWorker)
		error(err)

	for name, {thread, self, isEditor, lock, release} in pairs(PPM2.TEXTURE_TASKS_EDITOR)
		if coroutine_status(thread) == 'dead'
			PPM2.TEXTURE_TASKS_EDITOR[name] = nil
		else
			status, err = coroutine_resume(thread, self, isEditor, lock, release)

			if not status
				PPM2.TEXTURE_TASKS_EDITOR[name] = nil
				error(name .. ' editor texture task failed: ' .. err)

	for name, {thread, self, isEditor, lock, release} in pairs(PPM2.TEXTURE_TASKS)
		if coroutine_status(thread) == 'dead'
			PPM2.TEXTURE_TASKS[name] = nil
			self.unfinished_tasks -= 1
		else
			status, err = coroutine_resume(thread, self, isEditor, lock, release)

			if not status
				PPM2.TEXTURE_TASKS[name] = nil
				self.unfinished_tasks -= 1
				error(name .. ' texture task failed: ' .. err)

hook.Add 'InvalidateMaterialCache', 'PPM2.WebTexturesCache', ->
	PPM2.HTML_MATERIAL_QUEUE = {}
	PPM2.URL_MATERIAL_CACHE = {}
	PPM2.ALREADY_DOWNLOADING = {}
	PPM2.FAILED_TO_DOWNLOAD = {}
	PPM2.LOCKED_RENDERTARGETS = {}
	PPM2.LOCKED_RENDERTARGETS_MASK = {}
	PPM2.URLThread = coroutine.create(PPM2.URLThreadWorker)

PPM2.TextureTableHash = (input) ->
	hash = DLib.Util.SHA1()
	hash\Update('post intel fix')
	hash\Update(' ' .. tostring(value) .. ' ') for value in *input
	return hash\Digest()

PPM2.LockRenderTargetEditor = (name, width, height, r = 0, g = 0, b = 0, a = 255) ->
	index = string.format('PPM2_editor_%s_%d_%d', name, width, height)
	rt = GetRenderTarget(index, width, height)

	render.PushRenderTarget(rt)
	render.Clear(r, g, b, a, true, true)

	cam.Start2D()

	surface.SetDrawColor(r, g, b, a)

	mat = CreateMaterial(index .. 'a', 'UnlitGeneric', {
		'$basetexture': '!' .. index,
		'$translucent': '1',
	})

	mat\SetTexture('$basetexture', rt)

	return rt, mat

PPM2.ReleaseRenderTargetEditor = (name, width, height, no_pop = false) ->
	index = string.format('PPM2_editor_%s_%d_%d', name, width, height)

	if not no_pop
		cam.End2D()
		render.PopRenderTarget()

	return GetRenderTarget(index, width, height)

PPM2.LockRenderTarget = (name, width, height, r = 0, g = 0, b = 0, a = 255) ->
	index = string.format('PPM2_buffer_%d_%d', width, height)

	while PPM2.LOCKED_RENDERTARGETS[index]
		coroutine_yield()

	PPM2.LOCKED_RENDERTARGETS[index] = true

	rt = GetRenderTarget(index, width, height)

	render.PushRenderTarget(rt)
	render.Clear(r, g, b, a, true, true)

	cam.Start2D()

	surface.SetDrawColor(r, g, b, a)
	surface.DrawRect(0, 0, width + 1, height + 1)

	mat = CreateMaterial(index .. 'a', 'UnlitGeneric', {
		'$basetexture': '!' .. index,
		'$translucent': '1',
	})

	mat\SetTexture('$basetexture', rt)

	return rt, mat

PPM2.ReleaseRenderTarget = (name, width, height, no_pop = false) ->
	index = string.format('PPM2_buffer_%d_%d', width, height)
	PPM2.LOCKED_RENDERTARGETS[index] = false

	if not no_pop
		cam.End2D()
		render.PopRenderTarget()

	return GetRenderTarget(index, width, height)

PPM2.LockRenderTargetMask = (width, height) ->
	index = string.format('PPM2_mask_%d_%d', width, height)

	while PPM2.LOCKED_RENDERTARGETS_MASK[index]
		coroutine_yield()

	PPM2.LOCKED_RENDERTARGETS_MASK[index] = true

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

PPM2.ReleaseRenderTargetMask = (width, height) ->
	index = string.format('PPM2_mask_%d_%d', width, height)
	index2 = string.format('PPM2_mask2_%d_%d', width, height)
	PPM2.LOCKED_RENDERTARGETS_MASK[index] = false
	return GetRenderTarget(index, width, height), GetRenderTarget(index2, width, height)
