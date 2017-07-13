
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

class PonyDataInstance
    @DATA_DIR = "ppm2/"
    @DATA_DIR_BACKUP = "ppm2/backups/"

    @FindFiles = =>
        output = [str\sub(1, #str - 4) for str in *file.Find(@DATA_DIR .. '*', 'DATA') when not str\find('.bak.txt')]
        return output

    @FindInstances = =>
        output = [@(str\sub(1, #str - 4)) for str in *file.Find(@DATA_DIR .. '*', 'DATA') when not str\find('.bak.txt')]
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
    for key, {:getFunc, :fix, :enumMappingBackward, :enumMapping, :enum, :min, :max} in pairs @PONY_DATA
        @__base["Get#{getFunc}"] = => @dataTable[key]
        @__base["GetMin#{getFunc}"] = => min if min
        @__base["GetMax#{getFunc}"] = => max if max
        @__base["Enum#{getFunc}"] = => enum if enum
        @__base["Get#{getFunc}Types"] = => enum if enum

        @["GetMin#{getFunc}"] = => min if min
        @["GetMax#{getFunc}"] = => max if max
        @["GetEnum#{getFunc}"] = => enum if enum
        @["Enum#{getFunc}"] = => enum if enum

        if enumMapping
            @__base["Get#{getFunc}Enum"] = => enumMapping[@dataTable[key]] or enumMapping[0] or @dataTable[key]
            @__base["GetEnum#{getFunc}"] = @__base["Get#{getFunc}Enum"]
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
    CreateCustomNetworkObject: (ply = LocalPlayer(), ...) =>
        newData = PPM2.NetworkedPonyData(nil, ply)
        newData\SetEntity(ply)
        @ApplyDataToObject(newData, ...)
        return newData
    CreateNetworkObject: (gointToNetwork = true, ...) =>
        newData = PPM2.NetworkedPonyData(nil, LocalPlayer())
        newData\SetIsGoingToNetwork(gointToNetwork)
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
    
    @ERR_MISSING_PARAMETER = 4
    @ERR_MISSING_CONTENT = 5

    GetSaveOnChange: => @saveOnChange
    SaveOnChange: => @saveOnChange
    SetSaveOnChange: (val = true) => @saveOnChange = val
    SetupData: (data, force = false, doBackup = false) =>
        if doBackup or not force
            makeBackup = false
            for key, value in pairs data
                key = key\lower()
                map = @@PONY_DATA_MAPPING[key]
                if not map
                    return @@ERR_MISSING_PARAMETER if not force
                    makeBackup = true
                    break
                mapData = @@PONY_DATA[map]
                if mapData.enum
                    if type(value) == 'string' and not mapData.enumMappingBackward[value\upper()] or type(value) == 'number' and not mapData.enumMapping[value]
                        return @@ERR_MISSING_CONTENT if not force
                        makeBackup = true
                        break
            if doBackup and makeBackup and @exists
                bkName = "#{@@DATA_DIR_BACKUP}#{@filename}_bak_#{os.date('%S_%M_%H-%d_%m_%Y', os.time())}.txt"
                fRead = file.Read(@fpath, 'DATA')
                file.Write(bkName, fRead)
        
        for key, value in pairs data
            key = key\lower()
            map = @@PONY_DATA_MAPPING[key]
            continue unless map
            mapData = @@PONY_DATA[map]
            if mapData.enum and type(value) == 'string'
                @dataTable[key] = mapData.fix(mapData.enumMappingBackward[value\upper()])
            else
                @dataTable[key] = mapData.fix(value)
    ValueChanges: (key, oldVal, newVal, saveNow = @exists and @saveOnChange) =>
        if @nwObj and @updateNWObject
            {:getFunc} = @@PONY_DATA[key]
            @nwObj["Set#{getFunc}"](@nwObj, newVal, @networkNWObject)
        @Save() if saveNow
    SetFilename: (filename) =>
        @filename = filename
        @filenameFull = "#{filename}.txt"
        @fpath = "#{@@DATA_DIR}#{filename}.txt"
        @fpathBackup = "#{@@DATA_DIR}#{filename}.bak.txt"
        @fpathFull = "data/#{@@DATA_DIR}#{filename}.txt"
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
            return map.enumMapping[val] or map.enumMapping[map.default()]
        elseif map.serealize
            return map.serealize(val)
        else
            return val
    Serealize: (prettyPrint = true) =>
        serTab = {key, @SerealizeValue(key) for key, val in pairs @dataTable}
        util.TableToJSON(serTab, prettyPrint)
    GetAsNetworked: => {getFunc, @dataTable[k] for k, {:getFunc} in pairs @@PONY_DATA}

    @READ_SUCCESS = 0
    @ERR_FILE_NOT_EXISTS = 1
    @ERR_FILE_EMPTY = 2
    @ERR_FILE_CORRUPT = 3
    ReadFromDisk: (force = false, doBackup = true) =>
        return @@ERR_FILE_NOT_EXISTS unless @exists
        fRead = file.Read(@fpath, 'DATA')
        return @@ERR_FILE_EMPTY if not fRead or fRead == ''
        readTable = util.JSONToTable(fRead)
        return @@ERR_FILE_CORRUPT unless readTable
        return @SetupData(readTable, force, doBackup) or @@READ_SUCCESS
    SaveAs: (path = @fpath) =>
        fCreate = @Serealize()
        file.Write(path, fCreate)
    Save: (doBackup = true) =>
        if doBackup and @exists
            fRead = file.Read(@fpath, 'DATA')
            file.Write(@fpathBackup, fRead)
        @SaveAs(@fpath)
        @exists = true

do
    PARSE_VECTOR = (str = '1.0 1.0 1.0', X = 1, Y = 1, Z = 1) ->
        return Vector(X, Y, Z) if str == ''
        x, y, z = str\match('([0-9.]+) ([0-9.]+) ([0-9.]+)')
        return Vector(tonumber(x) or X, tonumber(y) or Y, tonumber(z) or Z)

    PARSE_COLOR = (str = '1.0 1.0 1.0', r = 255, g = 255, b = 255) ->
        return Color(r, g, b) if str == ''
        {x, y, z} = PARSE_VECTOR(str, r / 255, g / 255, b / 255)
        return Color(x * 255, y * 255, z * 255)
    
    IMPORT_TABLE = {
        'gender': {
            name: 'Gender'
            func: (arg = 0) ->
                num = tonumber(arg)
                return num == 0 and 'MALE' or 'FEMALE'
        }

        'coatcolor': {
            name: 'BodyColor'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_bg': {
            name: 'EyeBackground'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_grad': {
            name: 'EyeIrisBottom'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_iris': {
            name: 'EyeIrisTop'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_line1': {
            name: 'EyeIrisLine1'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyecolor_line2': {
            name: 'EyeIrisLine2'
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'haircolor1': {
            name: {'ManeColor1', 'TailColor1', 'ManeColor2', 'TailColor2'}
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

        'eyejholerssize': {
            name: 'HoleWidth'
            func: (arg = '1') -> tonumber(arg) or 1
        }

        'eyeirissize': {
            name: 'IrisSize'
            func: (arg = '1') -> (tonumber(arg) or 1) * 1.2
        }

        'eyeholesize': {
            name: 'HoleSize'
            func: (arg = '0.8') -> tonumber(arg) or 0.8
        }

        'bodyweight': {
            name: 'Weight'
            func: (arg = 1) -> tonumber(arg) or 1
        }

        'mane': {
            name: {'ManeType', 'ManeTypeNew'}
            func: (arg = 0) -> (tonumber(arg) or 0) - 1
        }

        'manel': {
            name: {'ManeTypeLower', 'ManeTypeLowerNew'}
            func: (arg = 0) -> (tonumber(arg) or 0) - 1
        }

        'tail': {
            name: {'TailType', 'TailTypeNew'}
            func: (arg = 0) -> (tonumber(arg) or 0) - 1
        }

        'tailsize': {
            name: 'TailSize'
            func: (arg = 1) -> tonumber(arg) or 1
        }

        'cmark': {
            name: 'CMarkType'
            func: (arg = 1) -> (tonumber(arg) or 1) - 1
        }

        'cmark_enabled': {
            name: 'CMark'
            func: (arg = '1') -> arg == '1' or arg == '2'
        }
    }

    for i = 1, 8
        IMPORT_TABLE["bodydetail#{i}"] = {
            name: "BodyDetail#{i}"
            func: (arg = 1) -> (tonumber(arg) or 1) - 1
        }

        IMPORT_TABLE["bodydetail#{i}_c"] = {
            name: "BodyDetailColor#{i}"
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

    for i = 2, 6
        IMPORT_TABLE["haircolor#{i}"] = {
            name: {"ManeDetailColor#{i - 1}", "TailDetailColor#{i - 1}"}
            func: (arg = '1.0 1.0 1.0') -> PARSE_COLOR(arg)
        }

    PPM2.ReadFromOldData = (filename = '_current') ->
        read = file.Read("ppm/#{filename}.txt", 'DATA')
        return false if read == ''
        split = [str\Trim() for str in *string.Explode('\n', read\Replace('\r', ''))]
        outputData = {}
        
        for line in *split
            varID = line\match('([a-zA-Z0-9_]+)')
            continue if not varID or varID == ''
            continue if not IMPORT_TABLE[varID]
            dt = IMPORT_TABLE[varID]
            value = line\sub(#varID + 2)
            if type(dt.name) ~= 'table'
                outputData[dt.name] = dt.func(value)
            else
                get = dt.func(value)
                outputData[name] = get for name in *dt.name
        
        data = PonyDataInstance("#{filename}_imported", nil, false)
        for key, value in pairs outputData
            data["Set#{key}"](data, value, false)
        return data, outputData

PPM2.PonyDataInstance = PonyDataInstance

PPM2.MainDataInstance = nil
PPM2.GetMainData = ->
    if not PPM2.MainDataInstance
        PPM2.MainDataInstance = PonyDataInstance('_current', nil, true, true)
        if not PPM2.MainDataInstance\FileExists()
            PPM2.MainDataInstance\Save()
    return PPM2.MainDataInstance
