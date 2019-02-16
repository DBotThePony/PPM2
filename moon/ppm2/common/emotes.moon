
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


PPM2.AVALIABLE_EMOTES = {
	{
		'name': 'gui.ppm2.emotes.sad'
		'sequence': 'sad'
		'time': 6
	}

	{
		'name': 'gui.ppm2.emotes.wild'
		'sequence': 'wild'
		'time': 3
	}

	{
		'name': 'gui.ppm2.emotes.grin'
		'sequence': 'big_grin'
		'time': 6
	}

	{
		'name': 'gui.ppm2.emotes.angry'
		'sequence': 'anger'
		'time': 7
	}

	{
		'name': 'gui.ppm2.emotes.tongue'
		'sequence': 'tongue'
		'time': 10
	}

	{
		'name': 'gui.ppm2.emotes.angrytongue'
		'sequence': 'angry_tongue'
		'time': 7
	}

	{
		'name': 'gui.ppm2.emotes.pff'
		'sequence': 'pffff'
		'time': 4
	}

	{
		'name': 'gui.ppm2.emotes.kitty'
		'sequence': 'cat'
		'time': 10
	}

	{
		'name': 'gui.ppm2.emotes.owo'
		'sequence': 'owo_alternative'
		'time': 8
	}

	{
		'name': 'gui.ppm2.emotes.ugh'
		'sequence': 'ugh'
		'time': 5
	}

	{
		'name': 'gui.ppm2.emotes.lips'
		'sequence': 'lips_licking'
		'time': 5
	}

	{
		'name': 'gui.ppm2.emotes.scrunch'
		'sequence': 'scrunch'
		'time': 6
	}

	{
		'name': 'gui.ppm2.emotes.sorry'
		'sequence': 'sorry'
		'time': 4
	}

	{
		'name': 'gui.ppm2.emotes.wink'
		'sequence': 'wink_left'
		'time': 2
	}

	{
		'name': 'gui.ppm2.emotes.right_wink'
		'sequence': 'wink_right'
		'time': 2
	}

	{
		'name': 'gui.ppm2.emotes.licking'
		'sequence': 'licking'
		'time': 6
	}

	{
		'name': 'gui.ppm2.emotes.suggestive_lips'
		'sequence': 'lips_licking_suggestive'
		'time': 4
	}

	{
		'name': 'gui.ppm2.emotes.suggestive_no_tongue'
		'sequence': 'suggestive_wo'
		'time': 4
	}

	{
		'name': 'gui.ppm2.emotes.gulp'
		'sequence': 'gulp'
		'time': 1
	}

	{
		'name': 'gui.ppm2.emotes.blah'
		'sequence': 'blahblah'
		'time': 3
	}

	{
		'name': 'gui.ppm2.emotes.happi'
		'sequence': 'happy_eyes'
		'time': 4
	}

	{
		'name': 'gui.ppm2.emotes.happi_grin'
		'sequence': 'happy_grin'
		'time': 5
	}

	{
		'name': 'gui.ppm2.emotes.duck'
		'sequence': 'duck'
		'time': 3
	}

	{
		'name': 'gui.ppm2.emotes.ducks'
		'sequence': 'duck_insanity'
		'time': 2
	}

	{
		'name': 'gui.ppm2.emotes.quack'
		'sequence': 'duck_quack'
		'time': 4
	}

	{
		'name': 'gui.ppm2.emotes.suggestive'
		'sequence': 'suggestive'
		'time': 4
	}

}

AvaliableFiles = {fil, true for _, fil in ipairs file.Find('materials/gui/ppm2/emotes/*', 'GAME')} if CLIENT

for i, data in pairs PPM2.AVALIABLE_EMOTES
	data.id = i
	data.file = "materials/gui/ppm2/emotes/#{data.sequence}.png"
	data.filecrop = "gui/ppm2/emotes/#{data.sequence}.png"
	data.fexists = AvaliableFiles["#{data.sequence}.png"] or false if CLIENT

PPM2.AVALIABLE_EMOTES_BY_NAME = {data.name, data for _, data in ipairs PPM2.AVALIABLE_EMOTES}
PPM2.AVALIABLE_EMOTES_BY_SEQUENCE = {data.sequence, data for _, data in ipairs PPM2.AVALIABLE_EMOTES}
