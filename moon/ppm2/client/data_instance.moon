
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


file.CreateDir('ppm2')
file.CreateDir('ppm2/backups')
file.CreateDir('ppm2/thumbnails')

if canon_presets = include('ppm2/client/canon_presets.lua')
	for presetname, payload in pairs(canon_presets)
		if not file.Exists('ppm2/' .. presetname .. '.dat', 'DATA')
			file.Write('ppm2/' .. presetname .. '.dat', payload)

for _, ffind in ipairs file.Find('ppm2/*.txt', 'DATA')
	fTarget = ffind\sub(1, -5)
	-- maybe joined server with old ppm2 and new clear _current was generated
	if not file.Exists('ppm2/' .. fTarget .. '.dat', 'DATA')
		fRead = file.Read('ppm2/' .. ffind, 'DATA')
		if json = util.JSONToTable(fRead)
			tab = {}

			for key, value in pairs json
				if luatype(value) == 'table'
					tab[key] = Color(value.r, value.g, value.b, value.a)
				else
					tab[key] = value

			buf = DLib.GON.Serialize(tab)
			stream = file.Open('ppm2/' .. fTarget .. '.dat', 'wb', 'DATA')
			buf\ToFileStream(stream)
			stream\Flush()
			stream\Close()

class PonyDataInstance
	@DATA_DIR = "ppm2/"
	@DATA_DIR_BACKUP = "ppm2/backups/"

	@FindFiles = =>
		output = [str\sub(1, #str - 4) for _, str in ipairs file.Find(@DATA_DIR .. '*', 'DATA') when not str\find('.bak.dat')]
		return output

	@FindInstances = =>
		output = [@(str\sub(1, #str - 4)) for _, str in ipairs file.Find(@DATA_DIR .. '*', 'DATA') when not str\find('.bak.dat')]
		return output

	@PONY_DATA_MAPPING = {old, key for key, {:old} in pairs PPM2.PonyDataRegistry}
	@PONY_DATA_MAPPING[key] = key for key, value in pairs PPM2.PonyDataRegistry

	for key, {:fix, :enum_runtime_map, :enum, :min, :max, :default} in pairs PPM2.PonyDataRegistry
		@__base["Get#{key}"] = => @dataTable[key]
		@__base["GetMin#{key}"] = => min if min
		@__base["GetMax#{key}"] = => max if max
		@__base["Enum#{key}"] = => enum if enum
		@__base["Get#{key}Types"] = => enum if enum

		@["GetMin#{key}"] = => min if min
		@["GetMax#{key}"] = => max if max
		@["GetDefault#{key}"] = default()
		@["GetEnum#{key}"] = => enum if enum
		@["Enum#{key}"] = => enum if enum

		if enum_runtime_map
			@__base["Get#{key}"] = => enum_runtime_map[@dataTable[key]]
			def_old = default()
			def_old = enum_runtime_map[def_old] if isnumber(def_old)
			@__base["GetDefault#{key}"] = => def_old

		@__base["Reset#{key}"] = => @["Set#{key}"](@, default())

		@__base["Set#{key}"] = (val = defValue, ...) =>
			if enum_runtime_map
				if isstring(val)
					i = val
					val = enum_runtime_map[val]
					error('No such enum value ' .. i) if val == nil

				if isnumber(val)
					error('No such enum index ' .. val) if enum_runtime_map[val] == nil

			newVal = fix(val)
			oldVal = @dataTable[key]
			@dataTable[key] = newVal
			@ValueChanges(key, oldVal, newVal, ...) if oldVal ~= newVal

	new: (filename, data, readIfExists = true) =>
		@SetFilename(filename)

		@updateNWObject = true
		@networkNWObject = true
		@rawData = data
		@dataTable = {k, default() for k, {:default} in pairs PPM2.PonyDataRegistry}
		@saveOnChange = false

		if data
			@Deserialize(data)
		elseif @exists and readIfExists
			@ReadFromDisk()

	WriteNetworkData: =>
		for _, {:strName, :writeFunc, :getName, :defValue} in ipairs PPM2.NetworkedPonyData.NW_Vars
			if @["Get#{getName}"]
				writeFunc(@["Get#{getName}"](@))
			else
				writeFunc(defValue)

	Copy: (fileName = @filename) =>
		copyOfData = {}

		for key, val in pairs @dataTable
			switch luatype(val)
				when 'number', 'string', 'boolean'
					copyOfData[key] = val
				when 'table', 'Color'
					copyOfData[key] = IsColor(val) and Color(val) or Color()

		newData = @@(fileName, copyOfData, false)
		return newData

	CreateCustomNetworkObject: (goingToNetwork = false, ply = LocalPlayer(), ...) =>
		newData = PPM2.NetworkedPonyData(nil, ply)
		newData\SetShouldNetwork(goingToNetwork)
		@ApplyDataToObject(newData, ...)
		return newData

	CreateNetworkObject: (goingToNetwork = true, ...) =>
		newData = PPM2.NetworkedPonyData(nil, LocalPlayer())
		newData\SetShouldNetwork(goingToNetwork)
		@ApplyDataToObject(newData, ...)
		return newData

	ApplyDataToObject: (target, ...) =>
		for key, value in pairs @GetAsNetworked()
			error("Attempt to apply data to object #{target} at unknown index #{key}!") if not target["Set#{key}"]
			target["Set#{key}"](target, value, ...)

	UpdateController: (...) => @ApplyDataToObject(@nwObj, @networkNWObject, ...)
	CreateController: (...) => @CreateNetworkObject(false, ...)
	CreateCustomController: (...) => @CreateCustomNetworkObject(false, ...)

	Reset: => @['Reset' .. k](@) for k in pairs PPM2.PonyDataRegistry

	@ERR_MISSING_PARAMETER = 4
	@ERR_MISSING_CONTENT = 5

	GetSaveOnChange: => @saveOnChange
	SaveOnChange: => @saveOnChange
	SetSaveOnChange: (val = false) => @saveOnChange = val

	ValueChanges: (key, oldVal, newVal, saveNow = @exists and @saveOnChange) =>
		if @nwObj and @updateNWObject
			{:getFunc} = PPM2.PonyDataRegistry[key]
			@nwObj["Set#{key}"](@nwObj, newVal, @networkNWObject)

		@Save() if saveNow

	SetFilename: (filename) =>
		@filename = filename
		@fullPath = "#{@@DATA_DIR}#{filename}.dat"
		@thumbnailPath = "#{@@DATA_DIR}thumbnails/#{filename}.png"
		@absolutePath = "data/#{@@DATA_DIR}#{filename}.dat"
		@exists = file.Exists(@fullPath, 'DATA')
		return @exists

	SetNetworkObject: (nwObj) => @nwObj = nwObj
	SetNetworkOnChange: (newVal = true) => @networkNWObject = newVal
	SetUpdateOnChange: (newVal = true) => @updateNWObject = newVal
	GetNetworkOnChange: => @networkNWObject
	GetUpdateOnChange: => @updateNWObject
	GetNetworkObject: => @nwObj

	Exists: => @exists
	FileExists: => @exists
	IsExists: => @exists
	GetFilename: => @filename
	GetFilenameFull: => @filename .. '.dat'
	GetFullPath: => @fullPath
	GetAbsolutePath: => @absolutePath
	GetBackupPath: => "#{@@DATA_DIR_BACKUP}#{@filename}_bak_#{os.date('%S_%M_%H-%d_%m_%Y', os.time())}.dat"

	GetAsNetworked: => {k, @dataTable[k] for k in pairs PPM2.PonyDataRegistry}

	Serialize: =>
		tab = {}

		for key, value in pairs(@dataTable)
			if map = PPM2.PonyDataRegistry[key]
				if map.enum
					tab[key] = map.enum_runtime_map[value] or map.enum_runtime_map[map.default()]
				elseif map.serialize
					tab[key] = map.serialize(value)
				else
					tab[key] = value

		return DLib.GON.Serialize(tab)

	ReadFromDisk: =>
		return false if not @exists
		fRead = file.Read(@fullPath, 'DATA')
		return false if not fRead or fRead == ''

		buf = DLib.BytesBuffer(fRead)

		if buf\ReadUByte() == 10
			buf\Seek(0)
			tag = DLib.NBT.TagCompound()
			return false if not tag\ReadFile(buf)
			return @Deserialize(tag)
		else
			buf\Seek(0)
			return @Deserialize(DLib.GON.Deserialize(buf))

	FixNBTValue: (mapData, value) =>
		if mapData.enum and isstring(value)
			mapData.fix(mapData.enum_runtime_map[value])
		elseif mapData.type == 'COLOR'
			if IsColor(value)
				mapData.fix(Color(value))
			else
				mapData.fix(Color(value[1] + 128, value[2] + 128, value[3] + 128, value[4] + 128))
		elseif mapData.type == 'BOOLEAN'
			if isbool(value)
				mapData.fix(value)
			else
				mapData.fix(value == 1)
		else
			mapData.fix(value)

	DeserializeValue: (mapData, value) =>
		if mapData.enum and isstring(value)
			return mapData.fix(mapData.enum_runtime_map[value])

		return mapData.fix(value)

	Deserialize: (data) =>
		fixNBT = false

		if luatype(data) == 'NBTCompound'
			data = data\GetValue()
			fixNBT = true

		dataTable = {k, default() for k, {:default} in pairs PPM2.PonyDataRegistry}

		for key, value2 in pairs(data)
			if remap = @@PONY_DATA_MAPPING[key]
				if data = PPM2.PonyDataRegistry[remap]
					@dataTable[remap] = @DeserializeValue(data, value2) if not fixNBT
					@dataTable[remap] = @FixNBTValue(data, value2) if fixNBT
					dataTable[remap] = nil

		@dataTable[k] = v for k, v in pairs(dataTable)

	SaveAs: (path = @fullPath) =>
		buf = @Serialize()
		stream = file.Open(path, 'wb', 'DATA')
		error('Unable to open ' .. path .. '!') if not stream
		buf\ToFileStream(stream)
		stream\Flush()
		stream\Close()
		return buf

	WriteThumbnail: (path = @thumbnailPath) =>
		buildingModel = ClientsideModel('models/ppm/ppm2_stage.mdl', RENDERGROUP_OTHER)
		buildingModel\SetNoDraw(true)
		buildingModel\SetModelScale(0.9)
		model = ClientsideModel('models/ppm/player_default_base_new_nj.mdl')

		with model
			\SetNoDraw(true)
			data = @CreateCustomController(model)
			\SetPonyData(data)
			ctrl = data\GetRenderController()

			if bg = data\GetBodygroupController()
				bg\ApplyBodygroups()

			with model\PPMBonesModifier()
				\ResetBones()
				hook.Call('PPM2.SetupBones', nil, model, data)
				\Think(true)

			\SetSequence(22)
			\FrameAdvance(0)

		timer.Simple 0.5, ->
			renderTarget = GetRenderTarget('ppm2_save_thumbnailPath_generate2', 1024, 1024, false)
			renderTarget\Download()
			render.PushRenderTarget(renderTarget)
			--render.SuppressEngineLighting(true)
			render.Clear(0, 0, 0, 255, true, true)
			cam.Start3D(Vector(49.373046875, -35.021484375, 58.332901000977), Angle(0, 141, 0), 90, 0, 0, 1024, 1024)

			buildingModel\DrawModel()

			with model
				data = \GetPonyData()
				ctrl = data\GetRenderController()

				if textures = ctrl\GetTextureController()
					textures\CompileTextures()

				if bg = data\GetBodygroupController()
					bg\ApplyBodygroups()

				with model\PPMBonesModifier()
					\ResetBones()
					hook.Call('PPM2.SetupBones', nil, model, data)
					\Think(true)

				with ctrl
					\DrawModels()
					\HideModels(true)
					\PreDraw(model, true)

				\DrawModel()
				ctrl\PostDraw(model, true)

			cam.End3D()

			data = render.Capture({
				format: 'png'
				x: 0
				y: 0
				w: 1024
				h: 1024
				alpha: false
			})

			model\Remove()
			buildingModel\Remove()

			file.Write(path, data)

			--render.SuppressEngineLighting(false)
			render.PopRenderTarget()

	Save: (doBackup = true, saveThumbnail = true) =>
		file.Rename(@fullPath, @GetBackupPath()) if doBackup and @exists
		buf = @SaveAs(@fullPath)
		@WriteThumbnail(@thumbnailPath) if saveThumbnail
		@exists = true
		return buf

PPM2.PonyDataInstance = PonyDataInstance

PPM2.MainDataInstance = nil
PPM2.GetMainData = ->
	if not PPM2.MainDataInstance
		PPM2.MainDataInstance = PonyDataInstance('_current', nil, true, true)
		if not PPM2.MainDataInstance\FileExists()
			PPM2.MainDataInstance\Save()
	return PPM2.MainDataInstance
