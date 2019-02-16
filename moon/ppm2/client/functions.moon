
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
	split = [str\Trim() for _, str in ipairs string.Explode('\n', read\Replace('\r', ''))]
	outputData = {}

	for _, line in ipairs split
		varID = line\match('([a-zA-Z0-9_]+)')
		continue if not varID or varID == ''
		continue if not IMPORT_TABLE[varID]
		dt = IMPORT_TABLE[varID]
		value = line\sub(#varID + 2)
		if type(dt.name) ~= 'table'
			outputData[dt.name] = dt.func(value)
		else
			get = dt.func(value)
			outputData[name] = get for _, name in ipairs dt.name

	data = PPM2.PonyDataInstance("#{filename}_imported", nil, false)
	for key, value in pairs outputData
		data["Set#{key}"](data, value, false)
	return data, outputData