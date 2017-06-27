
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

PREFIX = '[PPM2] '
PREFIX_DEBUG = '[PPM2 DEBUG] '
PREFIX_COLOR = Color(95, 188, 179)
DEBUG_COLOR = Color(209, 207, 183)
DEFAULT_TEXT_COLOR = Color(200, 200, 200)
NUMBER_COLOR = Color(245, 199, 64)
STEAMID_COLOR = Color(255, 255, 255)
ENTITY_COLOR = Color(180, 232, 180)
NPC_COLOR = Color(180, 213, 232)
VEHICLE_COLOR = Color(192, 180, 232)
FUNCTION_COLOR = Color(62, 106, 255)
TABLE_COLOR = Color(107, 200, 224)
URL_COLOR = Color(174, 124, 192)

PPM2.Format = (...) ->
	previousColor = DEFAULT_TEXT_COLOR
	output = {previousColor}
	
	for value in *{...}
		switch type(value)
			when 'table'
				if value.r and value.g and value.b and value.a
					table.insert(output, value)
					previousColor = value
                else
                    table.insert(output, TABLE_COLOR)
                    table.insert(output, tostring(value))
                    table.insert(output, previousColor)
			when 'Entity'
				table.insert(output, ENTITY_COLOR)
				table.insert(output, tostring(value))
				table.insert(output, previousColor)
			when 'string'
                if value\find('^https?://')
                    table.insert(output, URL_COLOR)
                    table.insert(output, value)
                    table.insert(output, previousColor)
                else
				    table.insert(output, value)
			when 'number'
				table.insert(output, NUMBER_COLOR)
				table.insert(output, tostring(value))
				table.insert(output, previousColor)
			when 'Player'
				tm = value\Team()
				table.insert(output, team.GetColor(tm))
				table.insert(output, value\Nick())
				table.insert(output, " (#{value\SteamName()})") if value.SteamName
				table.insert(output, STEAMID_COLOR)
				table.insert(output, "<#{value\SteamID()}>")
				table.insert(output, previousColor)
			when 'NPC'
				table.insert(output, NPC_COLOR)
				table.insert(output, "[NPC:#{value\GetClass()}]")
				table.insert(output, previousColor)
			when 'Vehicle'
				table.insert(output, VEHICLE_COLOR)
				table.insert(output, "[Vehicle:#{value\GetClass()}|#{value\GetModel()}]")
				table.insert(output, previousColor)
			when 'function'
				table.insert(output, FUNCTION_COLOR)
				table.insert(output, tostring(value))
				table.insert(output, previousColor)
			else
				table.insert(output, tostring(value))
	return output

PPM2.Message = (...) ->
    frmt = PPM2.Format(...)
    MsgC(PREFIX_COLOR, PREFIX, unpack(frmt))
    MsgC('\n')
    return frmt

if CLIENT
    PPM2.ChatPrint = (...) ->
        frmt = PPM2.Format(...)
        chat.AddText(PREFIX_COLOR, PREFIX, unpack(frmt))
        return frmt

DEBUG_LEVEL = CreateConVar('ppm2_debug', '0', {}, 'Enables debug printing. LOTS OF IT. 1 - simple messages; 2 - messages with traceback.')

PPM2.DebugPrint = (...) ->
    return if DEBUG_LEVEL\GetInt() <= 0
    frmt = PPM2.Format(DEBUG_COLOR, ...)
    MsgC(DEBUG_COLOR, PREFIX_DEBUG, unpack(frmt))
    MsgC('\n')
    if DEBUG_LEVEL\GetInt() >= 2
        MsgC(DEBUG_COLOR, debug.traceback())
        MsgC('\n')
    return frmt

PPM2.TransformNewModelID = (id = 0) ->
    bgID = id % 17
    maneModelID = math.floor(id / 16 - .01) + 1
    maneModelID = 1 if maneModelID == 0
    return maneModelID, bgID

do
    randomColor = (a = 255) -> Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), a)
    PPM2.Randomize = (object, ...) ->
        mane, manelower, tail = math.random(PPM2.MIN_UPPER_MANES_NEW, PPM2.MAX_UPPER_MANES_NEW), math.random(PPM2.MIN_LOWER_MANES_NEW, PPM2.MAX_LOWER_MANES_NEW), math.random(PPM2.MIN_TAILS_NEW, PPM2.MAX_TAILS_NEW)
        irisSize = math.random(PPM2.MIN_IRIS * 10, PPM2.MAX_IRIS * 10) / 10
        with object
            \SetGender(math.random(0, 1), ...)
            \SetRace(math.random(0, 3), ...)
            \SetPonySize(math.random(85, 110) / 100, ...)
            \SetNeckSize(math.random(92, 108) / 100, ...)
            \SetLegsSize(math.random(90, 120) / 100, ...)
            \SetWeight(math.random(PPM2.MIN_WEIGHT * 10, PPM2.MAX_WEIGHT * 10) / 10, ...)
            \SetTailType(tail, ...)
            \SetTailTypeNew(tail, ...)
            \SetManeType(mane, ...)
            \SetManeTypeLower(manelower, ...)
            \SetManeTypeNew(mane, ...)
            \SetManeTypeLowerNew(manelower, ...)
            \SetBodyColor(randomColor(), ...)
            \SetEyeIrisTop(randomColor(), ...)
            \SetEyeIrisBottom(randomColor(), ...)
            \SetEyeIrisLine1(randomColor(), ...)
            \SetEyeIrisLine2(randomColor(), ...)
            \SetIrisSize(irisSize, ...)
            \SetManeColor1(randomColor(), ...)
            \SetManeColor2(randomColor(), ...)
            \SetManeDetailColor1(randomColor(), ...)
            \SetManeDetailColor2(randomColor(), ...)
            \SetUpperManeColor1(randomColor(), ...)
            \SetUpperManeColor2(randomColor(), ...)
            \SetUpperManeDetailColor1(randomColor(), ...)
            \SetUpperManeDetailColor2(randomColor(), ...)
            \SetLowerManeColor1(randomColor(), ...)
            \SetLowerManeColor2(randomColor(), ...)
            \SetLowerManeDetailColor1(randomColor(), ...)
            \SetLowerManeDetailColor2(randomColor(), ...)
            \SetTailColor1(randomColor(), ...)
            \SetTailColor2(randomColor(), ...)
            \SetTailDetailColor1(randomColor(), ...)
            \SetTailDetailColor2(randomColor(), ...)
            \SetSocksAsModel(math.random(1, 2) == 1, ...)
            \SetSocksColor(randomColor(), ...)
        return object

entMeta = FindMetaTable('Entity')

entMeta.IsPony = =>
    model = @GetModel()
    @__ppm2_lastmodel = @__ppm2_lastmodel or model
    if @__ppm2_lastmodel ~= model
        data = @GetPonyData()
        if data and data.ModelChanges
            oldModel = @__ppm2_lastmodel
            @__ppm2_lastmodel = model
            data\ModelChanges(oldModel, model)
    switch model
        when 'models/ppm/player_default_base.mdl'
            return true
        when 'models/ppm/player_default_base_new.mdl'
            return true
        when 'models/ppm/player_default_base_new_nj.mdl'
            return true
        when 'models/ppm/player_default_base_nj.mdl'
            return true
        when 'models/cppm/player_default_base.mdl'
            return true
        when 'models/cppm/player_default_base_nj.mdl'
            return true
        else
            return false

entMeta.IsNJPony = =>
    model = @GetModel()
    @__ppm2_lastmodel = @__ppm2_lastmodel or model
    if @__ppm2_lastmodel ~= model
        data = @GetPonyData()
        if data and data.ModelChanges
            oldModel = @__ppm2_lastmodel
            @__ppm2_lastmodel = model
            data\ModelChanges(oldModel, model)
    switch model
        when 'models/ppm/player_default_base_new_nj.mdl'
            return true
        when 'models/ppm/player_default_base_nj.mdl'
            return true
        when 'models/cppm/player_default_base_nj.mdl'
            return true
        else
            return false

entMeta.IsNewPony = =>
    model = @GetModel()
    @__ppm2_lastmodel = @__ppm2_lastmodel or model
    if @__ppm2_lastmodel ~= model
        data = @GetPonyData()
        if data and data.ModelChanges
            oldModel = @__ppm2_lastmodel
            @__ppm2_lastmodel = model
            data\ModelChanges(oldModel, model)
    switch model
        when 'models/ppm/player_default_base_new.mdl'
            return true
        when 'models/ppm/player_default_base_new_nj.mdl'
            return true
        else
            return false

entMeta.IsPonyCached = =>
    switch @__ppm2_lastmodel
        when 'models/ppm/player_default_base.mdl'
            return true
        when 'models/ppm/player_default_base_new.mdl'
            return true
        when 'models/ppm/player_default_base_new_nj.mdl'
            return true
        when 'models/ppm/player_default_base_nj.mdl'
            return true
        when 'models/cppm/player_default_base.mdl'
            return true
        when 'models/cppm/player_default_base_nj.mdl'
            return true
        else
            return false

entMeta.IsNewPonyCached = =>
    switch @__ppm2_lastmodel
        when 'models/ppm/player_default_base_new.mdl'
            return true
        when 'models/ppm/player_default_base_new_nj.mdl'
            return true
        else
            return false

entMeta.IsNJPonyCached = =>
    switch @__ppm2_lastmodel
        when 'models/ppm/player_default_base_new_nj.mdl'
            return true
        when 'models/ppm/player_default_base_nj.mdl'
            return true
        when 'models/cppm/player_default_base_nj.mdl'
            return true
        else
            return false

entMeta.HasPonyModel = entMeta.IsPony
