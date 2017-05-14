
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
    @PONY_DATA = {
        'age': {
            default: (-> PPM2.AGE_ADULT)
            getFunc: 'Age'
            fix: (arg = PPM2.AGE_ADULT) -> math.Clamp(tonumber(arg) or PPM2.AGE_ADULT, 0, 2)
        }
        
        'race': {
            default: (-> PPM2.RACE_EARTH)
            getFunc: 'Race'
            fix: (arg = PPM2.RACE_EARTH) -> math.Clamp(tonumber(arg) or PPM2.RACE_EARTH, 0, 3)
        }

        'gender': {
            default: (-> PPM2.GENDER_FEMALE)
            getFunc: 'Gender'
            fix: (arg = PPM2.GENDER_FEMALE) -> math.Clamp(tonumber(arg) or PPM2.GENDER_FEMALE, 0, 1)
        }

        'weight': {
            default: (-> 1)
            getFunc: 'Weight'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_WEIGHT, PPM2.MAX_WEIGHT)
        }

        'eyelash': {
            default: (-> 0)
            getFunc: 'EyelashType'
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_EYELASHES, PPM2.MAX_EYELASHES)
        }
        
        'tail': {
            default: (-> 0)
            getFunc: 'TailType'
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_TAILS, PPM2.MAX_TAILS)
        }

        'mane': {
            default: (-> 0)
            getFunc: 'ManeType'
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_UPPER_MANES, PPM2.MAX_UPPER_MANES)
        }

        'manelower': {
            default: (-> 0)
            getFunc: 'ManeTypeLower'
            fix: (arg = 0) -> math.Clamp(tonumber(arg) or 0, PPM2.MIN_LOWER_MANES, PPM2.MAX_LOWER_MANES)
        }

        'tailsize': {
            default: (-> 1)
            getFunc: 'TailSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE)
        }

        'eye_iris_size': {
            default: (-> 1)
            getFunc: 'IrisSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_IRIS, PPM2.MAX_IRIS)
        }

        'hole_width': {
            default: (-> 1)
            getFunc: 'HoleWidth'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or 1, PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)
        }

        'eye_hole_size': {
            default: (-> .8)
            getFunc: 'HoleSize'
            fix: (arg = 1) -> math.Clamp(tonumber(arg) or .8, PPM2.MIN_HOLE, PPM2.MAX_HOLE)
        }

        'eye_bg': {
            default: (-> Color(255, 255, 255))
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
            default: (-> Color(0, 0, 0))
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
            default: (-> Color(200, 200, 200))
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
            default: (-> Color(200, 200, 200))
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
            default: (-> Color(255, 255, 255))
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
            default: (-> Color(255, 255, 255))
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
            default: (-> Color(255, 255, 255))
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
            default: (-> true)
            getFunc: 'EyeLines'
            fix: (arg = true) -> tobool(arg)
        }
    }

    for i = 1, 6
        @PONY_DATA["mane_color_#{i}"] = {
            default: (-> Color(255, 255, 255))
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
            default: (-> Color(255, 255, 255))
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
            default: (-> Color(255, 255, 255))
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
            default: (-> Color(255, 255, 255))
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

        -- Reserved - they can be accessed/used/changed, but they do not do anything
        @PONY_DATA["lower_mane_color_#{i}"] = {
            default: (-> Color(255, 255, 255))
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
            default: (-> Color(255, 255, 255))
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

    for key, {:getFunc, :fix} in pairs @PONY_DATA
        @__base["Get#{getFunc}"] = => @dataTable[key]
		@__base["Set#{getFunc}"] = (val = defValue, ...) =>
            newVal = fix(val)
			oldVal = @dataTable[key]
			@dataTable[key] = newVal
            @ValueChanges(key, oldVal, newVal, ...)

    new: (filename, data, readIfExists = true) =>
        @SetFilename(filename)
        @valid = @isOpen
        @rawData = data
        @dataTable = {k, default() for k, {:default} in pairs @@PONY_DATA}
        if data
            @SetupData(data)
        elseif @exists and readIfExists
            @ReadFromDisk()
    SetupData: (data, doSave = false) =>
        for key, value in pairs data
            key = key\lower()
            map = @@PONY_DATA_MAPPING[key]
            continue unless map
            @dataTable[key] = @@PONY_DATA[map].fix(value)
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
    Serealize: (prettyPrint = true) => util.TableToJSON(@dataTable, prettyPrint)
    GetAsNetworked: => {getFunc, @dataTable[k] for k, {:getFunc} in pairs @@PONY_DATA}
    ReadFromDisk: =>
        return false unless @exists
        fRead = file.Read(@fpath, 'DATA')
        return false if not fRead or fRead == ''
        readTable = util.JSONToTable(fRead)
        return false unless readTable
        @SetupData(readTable, false)
        return true
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
        PPM2.MainDataInstance = PonyDataInstance('_current')
        if not PPM2.MainDataInstance\FileExists()
            PPM2.MainDataInstance\Save()
    return PPM2.MainDataInstance
