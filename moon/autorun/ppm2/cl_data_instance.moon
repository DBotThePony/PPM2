
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
    @PONY_DATA = {
        'age': {
            default: -> PPM2.AGE_ADULT
            getFunc: 'Age'
            enum: {'FILLY', 'ADULT', 'MATURE'}
            fix: (arg = PPM2.AGE_ADULT) -> math.Clamp(tonumber(arg) or PPM2.AGE_ADULT, 0, 2)
        }
        
        'race': {
            default: -> PPM2.RACE_EARTH
            getFunc: 'Race'
            enum: [arg for arg in *PPM2.RACE_ENUMS]
            fix: (arg = PPM2.RACE_EARTH) -> math.Clamp(tonumber(arg) or PPM2.RACE_EARTH, 0, 3)
        }

        'gender': {
            default: -> PPM2.GENDER_FEMALE
            getFunc: 'Gender'
            enum: [arg for arg in *PPM2.AGE_ENUMS]
            fix: (arg = PPM2.GENDER_FEMALE) -> math.Clamp(tonumber(arg) or PPM2.GENDER_FEMALE, 0, 1)
        }

        'weight': {
            default: -> 1
            getFunc: 'Weight'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_WEIGHT, PPM2.MAX_WEIGHT)
        }

        'eyelash': {
            default: -> 0
            getFunc: 'EyelashType'
            enum: [arg for arg in *PPM2.EyelashTypes]
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_EYELASHES, PPM2.MAX_EYELASHES)
        }
        
        'tail': {
            default: -> 0
            getFunc: 'TailType'
            enum: [arg for arg in *PPM2.AvaliableTails] -- fast copy
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_TAILS, PPM2.MAX_TAILS)
        }

        'mane': {
            default: -> 0
            getFunc: 'ManeType'
            enum: [arg for arg in *PPM2.AvaliableUpperManes] -- fast copy
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_UPPER_MANES, PPM2.MAX_UPPER_MANES)
        }

        'manelower': {
            default: -> 0
            getFunc: 'ManeTypeLower'
            enum: [arg for arg in *PPM2.AvaliableLowerManes] -- fast copy
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_LOWER_MANES, PPM2.MAX_LOWER_MANES)
        }

        'tailsize': {
            default: -> 1
            getFunc: 'TailSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE)
        }

        'eye_iris_size': {
            default: -> 1
            getFunc: 'IrisSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_IRIS, PPM2.MAX_IRIS)
        }

        'hole_width': {
            default: -> 1
            getFunc: 'HoleWidth'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
        }

        'eye_hole_size': {
            default: -> .8
            getFunc: 'HoleSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or .8, PPM2.MIN_HOLE, PPM2.MAX_HOLE)
        }

        'cmark': {
            default: -> true
            getFunc: 'CMark'
            fix: (arg = true) -> tobool(arg)
        }

        'cmark_type': {
            default: -> 4
            getFunc: 'CMarkType'
            enum: [arg for arg in *PPM2.DefaultCutiemarks]
            fix: (arg = 4) -> math.Clamp(tonumber(arg) or 4, PPM2.MIN_CMARK, PPM2.MAX_CMARK)
        }

        'cmark_url': {
            default: -> ''
            getFunc: 'CMarkURL'
            fix: (arg = '') ->
                arg = tostring(arg)
                if arg\find('^https?://')
                    return arg
                else
                    return ''
        }

        'eye_bg': {
            default: -> Color(255, 255, 255)
            getFunc: 'EyeBackground'
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        'eye_hole': {
            default: -> Color(0, 0, 0)
            getFunc: 'EyeHole'
            fix: (arg = Color(0, 0, 0)) ->
                if type(arg) ~= 'table'
                    return Color(0, 0, 0)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(0, 0, 0)
        }

        'eye_iris1': {
            default: -> Color(200, 200, 200)
            getFunc: 'EyeIrisTop'
            fix: (arg = Color(200, 200, 200)) ->
                if type(arg) ~= 'table'
                    return Color(200, 200, 200)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(200, 200, 200)
        }

        'eye_iris2': {
            default: -> Color(200, 200, 200)
            getFunc: 'EyeIrisBottom'
            fix: (arg = Color(200, 200, 200)) ->
                if type(arg) ~= 'table'
                    return Color(200, 200, 200)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(200, 200, 200)
        }

        'eye_irisline1': {
            default: -> Color(255, 255, 255)
            getFunc: 'EyeIrisLine1'
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        'eye_irisline2': {
            default: -> Color(255, 255, 255)
            getFunc: 'EyeIrisLine2'
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        'body': {
            default: -> Color(255, 255, 255)
            getFunc: 'BodyColor'
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        'eye_lines': {
            default: -> true
            getFunc: 'EyeLines'
            fix: (arg = true) -> tobool(arg)
        }

        'socks': {
            default: -> false
            getFunc: 'Socks'
            fix: (arg = false) -> tobool(arg)
        }

        'suit': {
            default: -> 0
            getFunc: 'Bodysuit'
            enum: [arg for arg in *PPM2.AvaliablePonySuits]
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_SUIT, PPM2.MAX_SUIT)
        }
    }

    for i = 1, 6
        @PONY_DATA["mane_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "ManeColor#{i}"
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        @PONY_DATA["mane_detail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "ManeDetailColor#{i}"
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        @PONY_DATA["tail_detail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "TailDetailColor#{i}"
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        @PONY_DATA["tail_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "TailColor#{i}"
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        @PONY_DATA["body_detail_color_#{i}"] = {
            default: -> Color(140, 50, 100)
            getFunc: "BodyDetailColor#{i}"
            fix: (arg = Color(140, 50, 100)) ->
                if type(arg) ~= 'table'
                    return Color(140, 50, 100)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(140, 50, 100)
        }

        @PONY_DATA["body_detail_#{i}"] = {
            default: -> 0
            getFunc: "BodyDetail#{i}"
            enum: [arg for arg in *PPM2.BodyDetailsEnum]
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_DETAIL, PPM2.MAX_DETAIL)
        }

        -- Reserved - they can be accessed/used/changed, but they do not do anything
        @PONY_DATA["lower_mane_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "LowerManeColor#{i}"
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }

        @PONY_DATA["upper_mane_color_#{i}"] = {
            default: -> Color(255, 255, 255)
            getFunc: "UpperManeColor#{i}"
            fix: (arg = Color(255, 255, 255)) ->
                if type(arg) ~= 'table'
                    return Color(255, 255, 255)
                else
                    {:r, :g, :b, :a} = arg
                    if r and g and b and a
                        return Color(r, g, b, a)
                    else
                        return Color(255, 255, 255)
        }
        ------
    
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
    for key, {:getFunc, :fix, :enumMappingBackward, :enumMapping} in pairs @PONY_DATA
        @__base["Get#{getFunc}"] = => @dataTable[key]
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

    new: (filename, data, readIfExists = true, force = false, doBackup = true) =>
        @SetFilename(filename)
        @valid = @isOpen
        @rawData = data
        @dataTable = {k, default() for k, {:default} in pairs @@PONY_DATA}
        if data
            @SetupData(data, true)
        elseif @exists and readIfExists
            @ReadFromDisk(force, doBackup)
    
    @ERR_MISSING_PARAMETER = 4
    @ERR_MISSING_CONTENT = 5
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
    ValueChanges: (key, oldVal, newVal, saveNow = @exists) =>
        if @nwObj
            {:getFunc} = @@PONY_DATA[key]
            @nwObj["Set#{getFunc}"](@nwObj, newVal)
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
    IsValid: => @valid
    Exists: => @exists
    FileExists: => @exists
    IsExists: => @exists
    GetFileName: => @filename
    GetFileNameFull: => @filenameFull
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
    Save: (doBackup = true) =>
        if doBackup and @exists
            fRead = file.Read(@fpath, 'DATA')
            file.Write(@fpathBackup, fRead)
        fCreate = @Serealize()
        file.Write(@fpath, fCreate)
        @exists = true

PPM2.PonyDataInstance = PonyDataInstance

PPM2.MainDataInstance = nil
PPM2.GetMainData = ->
    if not PPM2.MainDataInstance
        PPM2.MainDataInstance = PonyDataInstance('_current', nil, true, true)
        if not PPM2.MainDataInstance\FileExists()
            PPM2.MainDataInstance\Save()
    return PPM2.MainDataInstance
