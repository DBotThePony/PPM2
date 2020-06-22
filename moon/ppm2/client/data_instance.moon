
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

	@PONY_DATA = PPM2.PonyDataRegistry

	@PONY_DATA_MAPPING = {getFunc\lower(), key for key, {:getFunc} in pairs @PONY_DATA}
	@PONY_DATA_MAPPING[key] = key for key, value in pairs @PONY_DATA

	for key, data in pairs @PONY_DATA
		continue unless data.enum
		data.enum = [arg\upper() for _, arg in ipairs data.enum]
		data.enumMapping = {}
		data.enumMappingBackward = {}
		i = -1
		for _, enumVal in ipairs data.enum
			i += 1
			data.enumMapping[i] = enumVal
			data.enumMappingBackward[enumVal] = i
	for key, {:getFunc, :fix, :enumMappingBackward, :enumMapping, :enum, :min, :max, :default} in pairs @PONY_DATA
		@__base["Get#{getFunc}"] = => @dataTable[key]
		@__base["GetMin#{getFunc}"] = => min if min
		@__base["GetMax#{getFunc}"] = => max if max
		@__base["Enum#{getFunc}"] = => enum if enum
		@__base["Get#{getFunc}Types"] = => enum if enum

		@["GetMin#{getFunc}"] = => min if min
		@["GetMax#{getFunc}"] = => max if max
		@["GetDefault#{getFunc}"] = default
		@["GetEnum#{getFunc}"] = => enum if enum
		@["Enum#{getFunc}"] = => enum if enum

		if enumMapping
			@__base["Get#{getFunc}Enum"] = => enumMapping[@dataTable[key]] or enumMapping[0] or @dataTable[key]
			@__base["GetEnum#{getFunc}"] = @__base["Get#{getFunc}Enum"]
		@__base["Reset#{getFunc}"] = => @["Set#{getFunc}"](@, default())
		@__base["Set#{getFunc}"] = (val = defValue, ...) =>
			if luatype(val) == 'string' and enumMappingBackward
				newVal = enumMappingBackward[val\upper()]
				val = newVal if newVal
			newVal = fix(val)
			oldVal = @dataTable[key]
			@dataTable[key] = newVal
			@ValueChanges(key, oldVal, newVal, ...) if oldVal ~= newVal

	new: (filename, data, readIfExists = true) =>
		@SetFilename(filename)

		@updateNWObject = true
		@networkNWObject = true
		@rawData = data
		@dataTable = {k, default() for k, {:default} in pairs @@PONY_DATA}
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
		newData\SetIsGoingToNetwork(goingToNetwork)
		@ApplyDataToObject(newData, ...)
		return newData

	CreateNetworkObject: (goingToNetwork = true, ...) =>
		newData = PPM2.NetworkedPonyData(nil, LocalPlayer())
		newData\SetIsGoingToNetwork(goingToNetwork)
		@ApplyDataToObject(newData, ...)
		return newData

	ApplyDataToObject: (target, ...) =>
		for key, value in pairs @GetAsNetworked()
			error("Attempt to apply data to object #{target} at unknown index #{key}!") if not target["Set#{key}"]
			target["Set#{key}"](target, value, ...)

	UpdateController: (...) => @ApplyDataToObject(@nwObj, ...)
	CreateController: (...) => @CreateNetworkObject(false, ...)
	CreateCustomController: (...) => @CreateCustomNetworkObject(false, ...)

	Reset: => @['Reset' .. getFunc](@) for k, {:getFunc} in pairs @@PONY_DATA

	@ERR_MISSING_PARAMETER = 4
	@ERR_MISSING_CONTENT = 5

	GetSaveOnChange: => @saveOnChange
	SaveOnChange: => @saveOnChange
	SetSaveOnChange: (val = false) => @saveOnChange = val

	ValueChanges: (key, oldVal, newVal, saveNow = @exists and @saveOnChange) =>
		if @nwObj and @updateNWObject
			{:getFunc} = @@PONY_DATA[key]
			@nwObj["Set#{getFunc}"](@nwObj, newVal, @networkNWObject)

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

	GetAsNetworked: => {getFunc, @dataTable[k] for k, {:getFunc} in pairs @@PONY_DATA}

	Serealize: =>
		tab = {}

		for key, value in pairs(@dataTable)
			if map = @@PONY_DATA[key]
				if map.enum
					tab[key] = map.enumMapping[value] or map.enumMapping[map.default()]
				elseif map.serealize
					tab[key] = map.serealize(value)
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
		if mapData.enum and type(value) == 'string'
			mapData.fix(mapData.enumMappingBackward[value\upper()])
		elseif mapData.type == 'COLOR'
			if IsColor(value)
				mapData.fix(Color(value))
			else
				mapData.fix(Color(value[1] + 128, value[2] + 128, value[3] + 128, value[4] + 128))
		elseif mapData.type == 'BOOLEAN'
			if type(value) == 'boolean'
				mapData.fix(value)
			else
				mapData.fix(value == 1)
		else
			mapData.fix(value)

	DeserializeValue: (mapData, value) =>
		if mapData.enum and type(value) == 'string'
			return mapData.fix(mapData.enumMappingBackward[value\upper()])

		return mapData.fix(value)

	Deserialize: (data) =>
		fixNBT = false

		if luatype(data) == 'NBTCompound'
			data = data\GetValue()
			fixNBT = true

		dataTable = {k, default() for k, {:default} in pairs @@PONY_DATA}

		for key, value2 in pairs(data)
			key = key\lower()
			if map = @@PONY_DATA_MAPPING[key]
				if mapData = @@PONY_DATA[map]
					@dataTable[key] = @DeserializeValue(mapData, value2) if not fixNBT
					@dataTable[key] = @FixNBTValue(mapData, value2) if fixNBT
					dataTable[key] = nil

		@dataTable[k] = v for k, v in pairs(dataTable)

	SaveAs: (path = @fullPath) =>
		buf = @Serealize()
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
			.__PPM2_PonyData = data
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
				data = .__PPM2_PonyData
				ctrl = data\GetRenderController()

				if textures = ctrl\GetTextureController()
					textures\CompileTextures(true)

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
		file.Write(@GetBackupPath(), file.Read(@fullPath, 'DATA')) if doBackup and @exists
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
