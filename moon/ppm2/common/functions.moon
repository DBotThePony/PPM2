
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


DLib.CMessage(PPM2, 'PPM2')

do
	randomColor = (a = 255) -> Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), a)
	PPM2.Randomize = (object, ...) ->
		mane, manelower, tail = math.random(PPM2.MIN_UPPER_MANES_NEW, PPM2.MAX_UPPER_MANES_NEW), math.random(PPM2.MIN_LOWER_MANES_NEW, PPM2.MAX_LOWER_MANES_NEW), math.random(PPM2.MIN_TAILS_NEW, PPM2.MAX_TAILS_NEW)
		irisSize = math.random(PPM2.MIN_IRIS * 10, PPM2.MAX_IRIS * 10) / 10
		with object
			\SetGenderSafe(math.random(0, 1), ...)
			\SetRaceSafe(math.random(0, 3), ...)
			\SetPonySizeSafe(math.random(85, 110) / 100, ...)
			\SetNeckSizeSafe(math.random(92, 108) / 100, ...)
			\SetLegsSizeSafe(math.random(90, 120) / 100, ...)
			\SetWeightSafe(math.random(PPM2.MIN_WEIGHT * 10, PPM2.MAX_WEIGHT * 10) / 10, ...)
			\SetTailTypeSafe(tail, ...)
			\SetTailTypeNewSafe(tail, ...)
			\SetManeTypeSafe(mane, ...)
			\SetManeTypeLowerSafe(manelower, ...)
			\SetManeTypeNewSafe(mane, ...)
			\SetManeTypeLowerNewSafe(manelower, ...)
			\SetBodyColorSafe(randomColor(), ...)
			\SetEyeIrisTopSafe(randomColor(), ...)
			\SetEyeIrisBottomSafe(randomColor(), ...)
			\SetEyeIrisLine1Safe(randomColor(), ...)
			\SetEyeIrisLine2Safe(randomColor(), ...)
			\SetIrisSizeSafe(irisSize, ...)
			\SetManeColor1Safe(randomColor(), ...)
			\SetManeColor2Safe(randomColor(), ...)
			\SetManeDetailColor1Safe(randomColor(), ...)
			\SetManeDetailColor2Safe(randomColor(), ...)
			\SetUpperManeColor1Safe(randomColor(), ...)
			\SetUpperManeColor2Safe(randomColor(), ...)
			\SetUpperManeDetailColor1Safe(randomColor(), ...)
			\SetUpperManeDetailColor2Safe(randomColor(), ...)
			\SetLowerManeColor1Safe(randomColor(), ...)
			\SetLowerManeColor2Safe(randomColor(), ...)
			\SetLowerManeDetailColor1Safe(randomColor(), ...)
			\SetLowerManeDetailColor2Safe(randomColor(), ...)
			\SetTailColor1Safe(randomColor(), ...)
			\SetTailColor2Safe(randomColor(), ...)
			\SetTailDetailColor1Safe(randomColor(), ...)
			\SetTailDetailColor2Safe(randomColor(), ...)
			\SetSocksAsModelSafe(math.random(1, 2) == 1, ...)
			\SetSocksColorSafe(randomColor(), ...)
		return object

entMeta = FindMetaTable('Entity')

entMeta.GetPonyRaceFlags = =>
	return 0 if not @IsPonyCached()
	data = @GetPonyData()
	return 0 if not data
	return data\GetPonyRaceFlags()

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
