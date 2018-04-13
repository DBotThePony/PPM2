
--
-- Copyright (C) 2017-2018 DBot
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

file.CreateDir('ppm2')
file.CreateDir('ppm2/backups')
file.CreateDir('ppm2/thumbnails')

for ffind in *file.Find('ppm2/*.txt', 'DATA')
	fTarget = ffind\sub(1, -5)
	-- maybe joined server with old ppm2 and new clear _current was generated
	if not file.Exists('ppm2/' .. fTarget .. '.dat', 'DATA')
		fRead = file.Read('ppm2/' .. ffind, 'DATA')
		json = util.JSONToTable(fRead)
		if json
			TagCompound = DLib.NBT.TagCompound()
			for key, value in pairs json
				switch type(value)
					when 'string'
						TagCompound\AddString(key, value)
					when 'number'
						TagCompound\AddFloat(key, value)
					when 'boolean'
						TagCompound\AddByte(key, value and 1 or 0)
					when 'table'
						-- assume color
						TagCompound\AddByteArray(key, {value.r - 128, value.g - 128, value.b - 128, value.a - 128}) if value.r and value.g and value.b and value.a
					else
						error(type(value))
			buf = DLib.BytesBuffer()
			TagCompound\WriteFile(buf)
			stream = file.Open('ppm2/' .. fTarget .. '.dat', 'wb', 'DATA')
			buf\ToFileStream(stream)
			stream\Flush()
			stream\Close()
	file.Delete('ppm2/' .. ffind)

class PonyDataInstance
	@DATA_DIR = "ppm2/"
	@DATA_DIR_BACKUP = "ppm2/backups/"

	@FindFiles = =>
		output = [str\sub(1, #str - 4) for str in *file.Find(@DATA_DIR .. '*', 'DATA') when not str\find('.bak.dat')]
		return output

	@FindInstances = =>
		output = [@(str\sub(1, #str - 4)) for str in *file.Find(@DATA_DIR .. '*', 'DATA') when not str\find('.bak.dat')]
		return output

	@PONY_DATA = PPM2.PonyDataRegistry

	@PONY_DATA_MAPPING = {getFunc\lower(), key for key, {:getFunc} in pairs @PONY_DATA}
	@PONY_DATA_MAPPING[key] = key for key, value in pairs @PONY_DATA

	for key, data in pairs @PONY_DATA
		continue unless data.enum
		data.enum = [arg\upper() for arg in *data.enum]
		data.enumMapping = {}
		data.enumMappingBackward = {}
		i = -1
		for enumVal in *data.enum
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
			if type(val) == 'string' and enumMappingBackward
				newVal = enumMappingBackward[val\upper()]
				val = newVal if newVal
			newVal = fix(val)
			oldVal = @dataTable[key]
			@dataTable[key] = newVal
			@ValueChanges(key, oldVal, newVal, ...)

	WriteNetworkData: =>
		for {:strName, :writeFunc, :getName, :defValue} in *PPM2.NetworkedPonyData.NW_Vars
			if @["Get#{getName}"]
				writeFunc(@["Get#{getName}"](@))
			else
				writeFunc(defValue)

	Copy: (fileName = @filename) =>
		copyOfData = {}
		for key, val in pairs @dataTable
			switch type(val)
				when 'number'
					copyOfData[key] = val
				when 'string'
					copyOfData[key] = val
				when 'boolean'
					copyOfData[key] = val
				when 'table'
					{:r, :g, :b} = val
					if r and g and b
						copyOfData[key] = Color(r, g, b)
		newData = @@(fileName, copyOfData, false)
		return newData
	CreateCustomNetworkObject: (goingToNetwork = false, ply = LocalPlayer(), ...) =>
		newData = PPM2.NetworkedPonyData(nil, ply)
		newData\SetIsGoingToNetwork(goingToNetwork)
		newData\SetEntity(ply)
		@ApplyDataToObject(newData, ...)
		return newData
	CreateNetworkObject: (goingToNetwork = true, ...) =>
		newData = PPM2.NetworkedPonyData(nil, LocalPlayer())
		newData\SetIsGoingToNetwork(goingToNetwork)
		newData\SetEntity(LocalPlayer())
		@ApplyDataToObject(newData, ...)
		return newData
	ApplyDataToObject: (target, ...) =>
		for key, value in pairs @GetAsNetworked()
			error("Attempt to apply data to object #{target} at unknown index #{key}!") if not target["Set#{key}"]
			target["Set#{key}"](target, value, ...)
	UpdateController: (...) => @ApplyDataToObject(@nwObj, ...)
	CreateController: (...) => @CreateNetworkObject(false, ...)
	CreateCustomController: (...) => @CreateCustomNetworkObject(false, ...)

	new: (filename, data, readIfExists = true, force = false, doBackup = true) =>
		@SetFilename(filename)
		@NBTTagCompound = DLib.NBT.TagCompound()
		@updateNWObject = true
		@networkNWObject = true
		@valid = @isOpen
		@rawData = data
		@dataTable = {k, default() for k, {:default} in pairs @@PONY_DATA}
		@saveOnChange = true
		if data
			@SetupData(data, true)
		elseif @exists and readIfExists
			@ReadFromDisk(force, doBackup)

	Reset: => @['Reset' .. getFunc](@) for k, {:getFunc} in pairs @@PONY_DATA

	@ERR_MISSING_PARAMETER = 4
	@ERR_MISSING_CONTENT = 5

	GetSaveOnChange: => @saveOnChange
	SaveOnChange: => @saveOnChange
	SetSaveOnChange: (val = true) => @saveOnChange = val
	GetValueFromNBT: (mapData, value) =>
		if mapData.enum and type(value) == 'string'
			mapData.fix(mapData.enumMappingBackward[value\upper()])
		elseif mapData.type == 'COLOR'
			if value.r and value.g and value.b and value.a
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

	SetupData: (data = @NBTTagCompound, force = false, doBackup = false) =>
		if type(data) == 'NBTCompound'
			data = data\GetValue()
		if doBackup or not force
			makeBackup = false
			for key, value2 in pairs(data)
				key = key\lower()
				map = @@PONY_DATA_MAPPING[key]
				if map
					mapData = @@PONY_DATA[map]
					value = @GetValueFromNBT(mapData, value2)
					if mapData.enum
						if type(value) == 'string' and not mapData.enumMappingBackward[value\upper()] or type(value) == 'number' and not mapData.enumMapping[value]
							return @@ERR_MISSING_CONTENT if not force
							makeBackup = true
							break
			if doBackup and makeBackup and @exists
				bkName = "#{@@DATA_DIR_BACKUP}#{@filename}_bak_#{os.date('%S_%M_%H-%d_%m_%Y', os.time())}.dat"
				fRead = file.Read(@fpath, 'DATA')
				file.Write(bkName, fRead)

		for key, value2 in pairs(data)
			key = key\lower()
			map = @@PONY_DATA_MAPPING[key]
			continue unless map
			mapData = @@PONY_DATA[map]
			@dataTable[key] = @GetValueFromNBT(mapData, value2)
	ValueChanges: (key, oldVal, newVal, saveNow = @exists and @saveOnChange) =>
		if @nwObj and @updateNWObject
			{:getFunc} = @@PONY_DATA[key]
			@nwObj["Set#{getFunc}"](@nwObj, newVal, @networkNWObject)
		@Save() if saveNow
	SetFilename: (filename) =>
		@filename = filename
		@filenameFull = "#{filename}.dat"
		@fpath = "#{@@DATA_DIR}#{filename}.dat"
		@preview = "#{@@DATA_DIR}thumbnails/#{filename}.png"
		@fpathBackup = "#{@@DATA_DIR}#{filename}.bak.dat"
		@fpathFull = "data/#{@@DATA_DIR}#{filename}.dat"
		@isOpen = @filename ~= nil
		@exists = file.Exists(@fpath, 'DATA')
		return @exists
	SetNetworkData: (nwObj) => @nwObj = nwObj
	SetPonyData: (nwObj) => @nwObj = nwObj
	SetPonyDataController: (nwObj) => @nwObj = nwObj
	SetPonyController: (nwObj) => @nwObj = nwObj
	SetController: (nwObj) => @nwObj = nwObj
	SetDataController: (nwObj) => @nwObj = nwObj

	SetNetworkOnChange: (newVal = true) => @networkNWObject = newVal
	SetUpdateOnChange: (newVal = true) => @updateNWObject = newVal

	GetNetworkOnChange: => @networkNWObject
	GetUpdateOnChange: => @updateNWObject

	GetNetworkData: => @nwObj
	GetPonyData: => @nwObj
	GetPonyDataController: => @nwObj
	GetPonyController: => @nwObj
	GetController: => @nwObj
	GetDataController: => @nwObj

	IsValid: => @valid
	Exists: => @exists
	FileExists: => @exists
	IsExists: => @exists
	GetFileName: => @filename
	GetFilename: => @filename
	GetFileNameFull: => @filenameFull
	GetFilenameFull: => @filenameFull
	GetFilePath: => @fpath
	GetFullFilePath: => @fpathFull
	SerealizeValue: (valID = '') =>
		map = @@PONY_DATA[valID]
		return unless map
		val = @dataTable[valID]
		if map.enum
			return DLib.NBT.TagString(map.enumMapping[val] or map.enumMapping[map.default()])
		elseif map.serealize
			return map.serealize(val)
		else
			switch map.type
				when 'INT'
					return DLib.NBT.TagInt(val)
				when 'FLOAT'
					return DLib.NBT.TagFloat(val)
				when 'URL'
					return DLib.NBT.TagString(val)
				when 'BOOLEAN'
					return DLib.NBT.TagByte(val and 1 or 0)
				when 'COLOR'
					return DLib.NBT.TagByteArray({val.r - 128, val.g - 128, val.b - 128, val.a - 128})
	GetAsNetworked: => {getFunc, @dataTable[k] for k, {:getFunc} in pairs @@PONY_DATA}

	@READ_SUCCESS = 0
	@ERR_FILE_NOT_EXISTS = 1
	@ERR_FILE_EMPTY = 2
	@ERR_FILE_CORRUPT = 3
	ReadFromDisk: (force = false, doBackup = true) =>
		return @@ERR_FILE_NOT_EXISTS unless @exists
		fRead = file.Read(@fpath, 'DATA')
		return @@ERR_FILE_EMPTY if not fRead or fRead == ''
		@NBTTagCompound\ReadFile(DLib.BytesBuffer(fRead))
		return @SetupData(@NBTTagCompound, force, doBackup) or @@READ_SUCCESS

	SaveAs: (path = @fpath) =>
		@NBTTagCompound\AddTag(key, @SerealizeValue(key)) for key, val in pairs @dataTable
		buf = DLib.BytesBuffer()
		@NBTTagCompound\WriteFile(buf)
		stream = file.Open(path, 'wb', 'DATA')
		buf\ToFileStream(stream)
		stream\Flush()
		stream\Close()
		return buf

	SavePreview: (path = @preview) =>
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
			renderTarget = GetRenderTarget('ppm2_save_preview_generate2', 1024, 1024, false)
			renderTarget\Download()
			render.PushRenderTarget(renderTarget)
			--render.SuppressEngineLighting(true)
			render.Clear(0, 0, 0, 255, true, true)
			cam.Start3D(Vector(49.373046875, -35.021484375, 58.332901000977), Angle(0, 141, 0), 90, 0, 0, 1024, 1024)

			buildingModel\DrawModel()

			with model
				data = .__PPM2_PonyData
				ctrl = data\GetRenderController()

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

	Save: (doBackup = true, preview = true) =>
		if doBackup and @exists
			fRead = file.Read(@fpath, 'DATA')
			file.Write(@fpathBackup, fRead)
		buf = @SaveAs(@fpath)
		@SavePreview(@preview) if preview
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
