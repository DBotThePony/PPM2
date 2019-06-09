
--
-- Copyright (C) 2017-2019 DBot

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


DLib.CMessage(PPM2, 'PPM2')
DEBUG_LEVEL = CreateConVar('ppm2_debug', '0', {}, 'Enables debug printing. LOTS OF IT. 1 - simple messages; 2 - messages with traceback.')

PPM2.DebugPrint = (...) ->
	return if DEBUG_LEVEL\GetInt() <= 0
	frmt = PPM2.formatMessage(DEBUG_COLOR, ...)
	MsgC(DEBUG_COLOR, PREFIX_DEBUG, unpack(frmt))
	MsgC('\n')
	if DEBUG_LEVEL\GetInt() >= 2
		MsgC(DEBUG_COLOR, debug.traceback())
		MsgC('\n')
	return frmt

PPM2.TransformNewModelID = (id = 0) ->
	bgID = id % 16
	maneModelID = math.floor(id / 16) + 1
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

entMeta.GetPonyRaceFlags = =>
	return 0 if not @IsPonyCached()
	data = @GetPonyData()
	return 0 if not data

	switch data\GetRace()
		when PPM2.RACE_EARTH
			return 0
		when PPM2.RACE_PEGASUS
			return PPM2.RACE_HAS_WINGS
		when PPM2.RACE_UNICORN
			return PPM2.RACE_HAS_HORN
		when PPM2.RACE_ALICORN
			return PPM2.RACE_HAS_HORN + PPM2.RACE_HAS_WINGS

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
	return model == 'models/ppm/player_default_base_new.mdl' or model == 'models/ppm/player_default_base_new_nj.mdl'

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
