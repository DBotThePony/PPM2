
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


-- editor stuffs

gui.ppm2.dxlevel.not_supported = 'Your DirectX™ level is too low. At least 9.0 is required. If you use 8.1 for framerate,\nyou either have the most ancient videocard or have bad drivers.\nBecause framerate in gmod can only be low because of other addons which create pointless high CPU load.\nYes, this message will appear several times to annoy you. Because WHY THE FK YOU THEN REPORT ABOUT MISSING TEXTURES???'
gui.ppm2.dxlevel.toolow = 'DirectX™ level is too low for PPM/2'

gui.ppm2.editor.eyes.separate = 'Use separated settings for eyes'
gui.ppm2.editor.eyes.url = 'Eye URL texture'
gui.ppm2.editor.eyes.url_desc = 'When uring eye URL texture; options below have no effect'

gui.ppm2.editor.eyes.lightwarp_desc = 'Lightwarp has effect only on EyeRefract eyes'
gui.ppm2.editor.eyes.lightwarp = "Lightwarp"
gui.ppm2.editor.eyes.desc1 = "Lightwarp texture URL input\nIt must be 256x16!"
gui.ppm2.editor.eyes.desc2 = "Glossiness strength\nThis parameters adjucts strength of real time reflections on eye\nTo see changes, set ppm2_cl_reflections convar to 1\nOther players would see reflections only with ppm2_cl_reflections set to 1\n0 - is matted; 1 - is mirror"

for _, {tprefix, prefix} in ipairs {{'def', ''}, {'left', 'Left '}, {'right', 'Right '}}
	gui.ppm2.editor.eyes[tprefix].lightwarp.shader = "#{prefix}Use EyeRefract shader"
	gui.ppm2.editor.eyes[tprefix].lightwarp.cornera = "#{prefix}Use Eye Cornera diffuse"
	gui.ppm2.editor.eyes[tprefix].lightwarp.glossiness = "#{prefix}Glossiness"

	gui.ppm2.editor.eyes[tprefix].type = "#{prefix}Eye type"
	gui.ppm2.editor.eyes[tprefix].reflection_type = "#{prefix}Eye reflection type"
	gui.ppm2.editor.eyes[tprefix].lines = "#{prefix}Eye lines"
	gui.ppm2.editor.eyes[tprefix].derp = "#{prefix}Derp eye"
	gui.ppm2.editor.eyes[tprefix].derp_strength = "#{prefix}Derp eye strength"
	gui.ppm2.editor.eyes[tprefix].iris_size = "#{prefix}Eye size"

	gui.ppm2.editor.eyes[tprefix].points_inside = "#{prefix}Eye lines points inside"
	gui.ppm2.editor.eyes[tprefix].width = "#{prefix}Eye width"
	gui.ppm2.editor.eyes[tprefix].height = "#{prefix}Eye height"

	gui.ppm2.editor.eyes[tprefix].pupil.width = "#{prefix}Pupil width"
	gui.ppm2.editor.eyes[tprefix].pupil.height = "#{prefix}Pupil height"
	gui.ppm2.editor.eyes[tprefix].pupil.size = "#{prefix}Pupil size"

	gui.ppm2.editor.eyes[tprefix].pupil.shift_x = "#{prefix}Pupil Shift X"
	gui.ppm2.editor.eyes[tprefix].pupil.shift_y = "#{prefix}Pupil Shift Y"
	gui.ppm2.editor.eyes[tprefix].pupil.rotation = "#{prefix}Eye rotation"

	gui.ppm2.editor.eyes[tprefix].background = "#{prefix}Eye background"
	gui.ppm2.editor.eyes[tprefix].pupil_size = "#{prefix}Pupil"
	gui.ppm2.editor.eyes[tprefix].top_iris = "#{prefix}Top eye iris"
	gui.ppm2.editor.eyes[tprefix].bottom_iris = "#{prefix}Bottom eye iris"
	gui.ppm2.editor.eyes[tprefix].line1 = "#{prefix}Eye line 1"
	gui.ppm2.editor.eyes[tprefix].line2 = "#{prefix}Eye line 2"
	gui.ppm2.editor.eyes[tprefix].reflection = "#{prefix}Eye reflection effect"
	gui.ppm2.editor.eyes[tprefix].effect = "#{prefix}Eye effect"

gui.ppm2.editor.generic.title = 'PPM/2 Pony Editor'
gui.ppm2.editor.generic.title_file = '%q - PPM/2 Pony Editor'
gui.ppm2.editor.generic.title_file_unsaved = '%q* - PPM/2 Pony Editor (unsaved changes!)'

gui.ppm2.editor.generic.yes = 'Yas!'
gui.ppm2.editor.generic.no = 'Noh!'
gui.ppm2.editor.generic.ohno = 'Onoh!'
gui.ppm2.editor.generic.okay = 'Okai ;w;'
gui.ppm2.editor.generic.datavalue = '%s\nData value: %q'
gui.ppm2.editor.generic.url = '%s\n\nLink goes to: %s'
gui.ppm2.editor.generic.url_field = 'URL Field'
gui.ppm2.editor.generic.spoiler = 'Mysterious spoiler'

gui.ppm2.editor.generic.restart.needed = 'Editor restart required'
gui.ppm2.editor.generic.restart.text = 'You should restart editor for applying change.\nRestart now?\nUnsaved data will lost!'
gui.ppm2.editor.generic.fullbright = 'Fullbright'
gui.ppm2.editor.generic.wtf = 'For some reason, your player has no NetworkedPonyData - Nothing to edit!\nTry ppm2_reload in your console and try to open editor again'

gui.ppm2.editor.io.random = 'Randomize!'
gui.ppm2.editor.io.newfile.title = 'New File'
gui.ppm2.editor.io.newfile.confirm = 'Really want to create a new file?'
gui.ppm2.editor.io.newfile.toptext = 'Reset'
gui.ppm2.editor.io.delete.confirm = 'Do you really want to delete that file?\nIt will be gone forever!\n(a long time!)'
gui.ppm2.editor.io.delete.title = 'Really Delete?'

gui.ppm2.editor.io.filename = 'Filename'
gui.ppm2.editor.io.hint = 'Open file by double click'
gui.ppm2.editor.io.reload = 'Reload file list'
gui.ppm2.editor.io.failed = 'Failed to import.'

gui.ppm2.editor.io.warn.oldfile = '!!! It may or may not work. You will be squished.'
gui.ppm2.editor.io.warn.text = "Currently, you did not stated your changes.\nDo you really want to open another file?"
gui.ppm2.editor.io.warn.header = 'Unsaved changes!'
gui.ppm2.editor.io.save.button = 'Save'
gui.ppm2.editor.io.save.text = 'Enter file name without ppm2/ and .dat\nTip: to save as autoload, type "_current" (without quotes)'
gui.ppm2.editor.io.wear = 'Apply changes (wear)'

gui.ppm2.editor.seq.standing = 'Standing'
gui.ppm2.editor.seq.move = 'Moving'
gui.ppm2.editor.seq.walk = 'Walking'
gui.ppm2.editor.seq.sit = 'Sit'
gui.ppm2.editor.seq.swim = 'Swim'
gui.ppm2.editor.seq.run = 'Run'
gui.ppm2.editor.seq.duckwalk = 'Crouch walk'
gui.ppm2.editor.seq.duck = 'Crouch'
gui.ppm2.editor.seq.jump = 'Jump'

gui.ppm2.editor.misc.race = 'Race'
gui.ppm2.editor.misc.weight = 'Weight'
gui.ppm2.editor.misc.size = 'Pony Size'
gui.ppm2.editor.misc.hide_weapons = 'Should hide weapons'
gui.ppm2.editor.misc.chest = 'Male chest buff'
gui.ppm2.editor.misc.gender = 'Gender'
gui.ppm2.editor.misc.wings = 'Wings Type'
gui.ppm2.editor.misc.flexes = 'Flexes controls'
gui.ppm2.editor.misc.no_flexes2 = 'No flexes on new model'
gui.ppm2.editor.misc.no_flexes_desc = 'You can disable separately any flex state controller\nSo these flexes can be modified with third-party addons (like PAC3)'

gui.ppm2.editor.misc.hide_pac3 = 'Hide entitites when using PAC3 entity'
gui.ppm2.editor.misc.hide_mane = 'Hide mane when using PAC3 entity'
gui.ppm2.editor.misc.hide_tail = 'Hide tail when using PAC3 entity'
gui.ppm2.editor.misc.hide_socks = 'Hide socks when using PAC3 entity'

gui.ppm2.editor.tabs.main = 'General'
gui.ppm2.editor.tabs.files = 'Files'
gui.ppm2.editor.tabs.old_files = 'Old Files'
gui.ppm2.editor.tabs.cutiemark = 'Cutiemark'
gui.ppm2.editor.tabs.head = 'Head anatomy'
gui.ppm2.editor.tabs.eyes = 'Eyes'
gui.ppm2.editor.tabs.face = 'Face'
gui.ppm2.editor.tabs.mouth = 'Mouth'
gui.ppm2.editor.tabs.left_eye = 'Left Eye'
gui.ppm2.editor.tabs.right_eye = 'Right Eye'
gui.ppm2.editor.tabs.mane_horn = 'Mane and Horn'
gui.ppm2.editor.tabs.mane = 'Mane'
gui.ppm2.editor.tabs.details = 'Details'
gui.ppm2.editor.tabs.url_details = 'URL Details'
gui.ppm2.editor.tabs.url_separated_details = 'URL Separated Details'
gui.ppm2.editor.tabs.ears = 'Ears'
gui.ppm2.editor.tabs.horn = 'Horn'
gui.ppm2.editor.tabs.back = 'Back'
gui.ppm2.editor.tabs.wings = 'Wings'
gui.ppm2.editor.tabs.left = 'Left'
gui.ppm2.editor.tabs.right = 'Right'
gui.ppm2.editor.tabs.neck = 'Neck'
gui.ppm2.editor.tabs.body = 'Pony body'
gui.ppm2.editor.tabs.tattoos = 'Tattoos'
gui.ppm2.editor.tabs.tail = 'Tail'
gui.ppm2.editor.tabs.hooves = 'Hooves anatomy'
gui.ppm2.editor.tabs.bottom_hoof = 'Bottom hoof'
gui.ppm2.editor.tabs.legs = 'Legs'
gui.ppm2.editor.tabs.socks = 'Socks'
gui.ppm2.editor.tabs.newsocks = 'New Socks'
gui.ppm2.editor.tabs.about = 'About'

gui.ppm2.editor.old_tabs.mane_tail = 'Mane and tail'
gui.ppm2.editor.old_tabs.wings_and_horn_details = 'Wings and horn details'
gui.ppm2.editor.old_tabs.wings_and_horn = 'Wings and horn'
gui.ppm2.editor.old_tabs.body_details = 'Body details'
gui.ppm2.editor.old_tabs.mane_tail_detals = 'Mane and tail URL details'

gui.ppm2.editor.cutiemark.display = 'Display cutiemark'
gui.ppm2.editor.cutiemark.type = 'Cutiemark type'
gui.ppm2.editor.cutiemark.size = 'Cutiemark size'
gui.ppm2.editor.cutiemark.color = 'Cutiemark color'
gui.ppm2.editor.cutiemark.input = 'Cutiemark URL image input field\nShould be PNG or JPEG (works same as\nPAC3 URL texture)'

gui.ppm2.editor.face.eyelashes = 'Eyelashes'
gui.ppm2.editor.face.eyelashes_color = 'Eyelashes Color'
gui.ppm2.editor.face.eyelashes_phong = 'Eyelashes phong parameters'
gui.ppm2.editor.face.eyebrows_color = 'Eyebrows Color'
gui.ppm2.editor.face.new_muzzle = 'Use new muzzle for male model'

gui.ppm2.editor.face.nose = 'Nose Color'
gui.ppm2.editor.face.lips = 'Lips Color'
gui.ppm2.editor.face.eyelashes_separate_phong = 'Separate Eyelashes Phong'
gui.ppm2.editor.face.eyebrows_glow = 'Glowing eyebrows'
gui.ppm2.editor.face.eyebrows_glow_strength = 'Eyebrows glow strength'
gui.ppm2.editor.face.inherit.lips = 'Inherit Lips Color from body'
gui.ppm2.editor.face.inherit.nose = 'Inherit Nose Color from body'

gui.ppm2.editor.mouth.fangs = 'Fangs'
gui.ppm2.editor.mouth.alt_fangs = 'Alternative Fangs'
gui.ppm2.editor.mouth.claw = 'Claw teeth'

gui.ppm2.editor.mouth.teeth = 'Teeth color'
gui.ppm2.editor.mouth.teeth_phong = 'Teeth phong parameters'
gui.ppm2.editor.mouth.mouth = 'Mouth color'
gui.ppm2.editor.mouth.mouth_phong = 'Mouth phong parameters'
gui.ppm2.editor.mouth.tongue = 'Tongue color'
gui.ppm2.editor.mouth.tongue_phong = 'Tongue phong parameters'

gui.ppm2.editor.mane.type = 'Mane Type'
gui.ppm2.editor.mane.phong = 'Separate mane phong settings from body'
gui.ppm2.editor.mane.mane_phong = 'Mane phong parameters'
gui.ppm2.editor.mane.phong_sep = 'Separate upper and lower mane colors'
gui.ppm2.editor.mane.up.phong = 'Upper Mane Phong Settings'
gui.ppm2.editor.mane.down.type = 'Lower Mane Type'
gui.ppm2.editor.mane.down.phong = 'Lower Mane Phong Settings'
gui.ppm2.editor.mane.newnotice = 'Next options have effect only on new model'

for i = 1, 2
	gui.ppm2.editor.mane['color' .. i] = "Mane color #{i}"
	gui.ppm2.editor.mane.up['color' .. i] = "Upper mane color #{i}"
	gui.ppm2.editor.mane.down['color' .. i] = "Lower mane color #{i}"

for i = 1, 6
	gui.ppm2.editor.mane['detail_color' .. i] = "Mane detail color #{i}"
	gui.ppm2.editor.mane.up['detail_color' .. i] = "Upper mane color #{i}"
	gui.ppm2.editor.mane.down['detail_color' .. i] = "Lower mane color #{i}"

	gui.ppm2.editor.url_mane['desc' .. i] = "Mane URL Detail #{i} input field"
	gui.ppm2.editor.url_mane['color' .. i] = "Mane URL detail color #{i}"

	gui.ppm2.editor.url_tail['desc' .. i] = "Tail URL Detail #{i} input field"
	gui.ppm2.editor.url_tail['color' .. i] = "Tail URL detail color #{i}"

	gui.ppm2.editor.url_mane.sep.up['desc' .. i] = "Upper mane URL Detail #{i} input field"
	gui.ppm2.editor.url_mane.sep.up['color' .. i] = "Upper Mane URL detail color #{i}"

	gui.ppm2.editor.url_mane.sep.down['desc' .. i] = "Lower mane URL Detail #{i} input field"
	gui.ppm2.editor.url_mane.sep.down['color' .. i] = "Lower Mane URL detail color #{i}"

gui.ppm2.editor.ears.bat = 'Bat pony ears'
gui.ppm2.editor.ears.size = 'Ears size'

gui.ppm2.editor.horn.detail_color = 'Horn detail color'
gui.ppm2.editor.horn.glowing_detail = 'Glowing Horn Detail'
gui.ppm2.editor.horn.glow_strength = 'Horn Glow Strength'
gui.ppm2.editor.horn.separate_color = 'Separate horn color from body'
gui.ppm2.editor.horn.color = 'Horn color'
gui.ppm2.editor.horn.horn_phong = 'Horn phong parameters'
gui.ppm2.editor.horn.magic = 'Horn magic color'
gui.ppm2.editor.horn.separate_magic_color = 'Separate magic color from eye color'
gui.ppm2.editor.horn.separate = 'Separate horn color from body'
gui.ppm2.editor.horn.separate_phong = 'Separate horn phong settings from body'

for i = 1, 3
	gui.ppm2.editor.horn.detail['desc' .. i] = "Horn URL detail #{i}"
	gui.ppm2.editor.horn.detail['color' .. i] = "URL Detail color #{i}"

gui.ppm2.editor.wings.separate_color = 'Separate wings color from body'
gui.ppm2.editor.wings.color = 'Wings color'
gui.ppm2.editor.wings.wings_phong = 'Wings phong parameters'
gui.ppm2.editor.wings.separate = 'Separate wings color from body'
gui.ppm2.editor.wings.separate_phong = 'Separate wings phong settings from body'
gui.ppm2.editor.wings.bat_color = 'Bat Wings color'
gui.ppm2.editor.wings.bat_skin_color = 'Bat Wings skin color'
gui.ppm2.editor.wings.bat_skin_phong = 'Bat wings skin phong parameters'

gui.ppm2.editor.wings.normal = 'Normal wings'
gui.ppm2.editor.wings.bat = 'Bat wings'
gui.ppm2.editor.wings.bat_skin = 'Bat wings skin'

gui.ppm2.editor.wings.left.size = 'Left wing size'
gui.ppm2.editor.wings.left.fwd = 'Left Wing Forward'
gui.ppm2.editor.wings.left.up = 'Left Wing Up'
gui.ppm2.editor.wings.left.inside = 'Left Wing Inside'

gui.ppm2.editor.wings.right.size = 'Right wing size'
gui.ppm2.editor.wings.right.fwd = 'Right Wing Forward'
gui.ppm2.editor.wings.right.up = 'Right Wing Up'
gui.ppm2.editor.wings.right.inside = 'Right Wing Inside'

for i = 1, 3
	gui.ppm2.editor.wings.details.def['detail' .. i] = "Wings URL detail #{i}"
	gui.ppm2.editor.wings.details.def['color' .. i] = "URL Detail color #{i}"
	gui.ppm2.editor.wings.details.bat['detail' .. i] = "Bat wing URL detail #{i}"
	gui.ppm2.editor.wings.details.bat['color' .. i] = "Bat wing URL Detail color #{i}"
	gui.ppm2.editor.wings.details.batskin['detail' .. i] = "Bat wing skin URL detail #{i}"
	gui.ppm2.editor.wings.details.batskin['color' .. i] = "Bat wing skin URL Detail color #{i}"

gui.ppm2.editor.neck.height = 'Neck height'

gui.ppm2.editor.body.suit = 'Bodysuit'
gui.ppm2.editor.body.color = 'Body color'
gui.ppm2.editor.body.body_phong = 'Body phong parameters'
gui.ppm2.editor.body.spine_length = 'Spine length'
gui.ppm2.editor.body.url_desc = 'Body detail URL image input fields\nShould be PNG or JPEG (works same as\nPAC3 URL texture)'

for i = 1, PPM2.MAX_BODY_DETAILS
	gui.ppm2.editor.body.detail['desc' .. i] = "Detail #{i}"
	gui.ppm2.editor.body.detail['color' .. i] = "Detail color #{i}"
	gui.ppm2.editor.body.detail['glow' .. i] = "Detail #{i} is glowing"
	gui.ppm2.editor.body.detail['glow_strength' .. i] = "Detail #{i} glow strength"

	gui.ppm2.editor.body.detail.url['desc' .. i] = "Detail #{i}"
	gui.ppm2.editor.body.detail.url['color' .. i] = "Detail color #{i}"

gui.ppm2.editor.tattoo.edit_keyboard = 'Edit using keyboard'
gui.ppm2.editor.tattoo.type = 'Type'
gui.ppm2.editor.tattoo.over = 'Tattoo over body details'
gui.ppm2.editor.tattoo.glow = 'Tattoo is glowing'
gui.ppm2.editor.tattoo.glow_strength = 'Tattoo glow strength'
gui.ppm2.editor.tattoo.color = 'Color of Tattoo'

gui.ppm2.editor.tattoo.tweak.rotate = 'Rotation'
gui.ppm2.editor.tattoo.tweak.x = 'X Position'
gui.ppm2.editor.tattoo.tweak.y = 'Y Position'
gui.ppm2.editor.tattoo.tweak.width = 'Width Scale'
gui.ppm2.editor.tattoo.tweak.height = 'Height Scale'

for i = 1, PPM2.MAX_TATTOOS
	gui.ppm2.editor.tattoo['layer' .. i] = "Tattoo layer #{i}"

gui.ppm2.editor.tail.type = 'Tail type'
gui.ppm2.editor.tail.size = 'Tail size'
gui.ppm2.editor.tail.tail_phong = 'Tail phong parameters'
gui.ppm2.editor.tail.separate = 'Separate tail phong settings from body'

for i = 1, 2
	gui.ppm2.editor.tail['color' .. i] = 'Tail color ' .. i

for i = 1, 6
	gui.ppm2.editor.tail['detail' .. i] = "Tail detail color #{i}"
	gui.ppm2.editor.tail.url['detail' .. i] = "Tail URL detail #{i}"
	gui.ppm2.editor.tail.url['color' .. i] = "Tail URL detail #{i}"

gui.ppm2.editor.hoof.fluffers = 'Hoof Fluffers'

gui.ppm2.editor.legs.height = 'Legs height'
gui.ppm2.editor.legs.socks.simple = 'Socks (simple texture)'
gui.ppm2.editor.legs.socks.model = 'Socks (as model)'
gui.ppm2.editor.legs.socks.color = 'Socks model color'
gui.ppm2.editor.legs.socks.socks_phong = 'Socks phong parameters'
gui.ppm2.editor.legs.socks.texture = 'Socks Texture'
gui.ppm2.editor.legs.socks.url_texture = 'Socks URL texture'

for i = 1, 6
	gui.ppm2.editor.legs.socks['color' .. i] = 'Socks detail color ' .. i

gui.ppm2.editor.legs.newsocks.model = 'Socks (as new model)'

for i = 1, 3
	gui.ppm2.editor.legs.newsocks['color' .. i] = 'New Socks color ' .. i

gui.ppm2.editor.legs.newsocks.url = 'New Socks URL texture'

-- shared editor stuffs

gui.ppm2.editor.tattoo.help = "To exit edit mode, press Escape or click anywhere with mouse
To move tatto use WASD
To Scale higher/lower use Up/Down arrows
To Scale wider/smaller use Right/Left arrows
To rotate left/right use Q/E"

gui.ppm2.editor.reset_value = 'Reset %s'

gui.ppm2.editor.phong.info = 'More info about Phong on wiki'
gui.ppm2.editor.phong.exponent = 'Phong Exponent - how strong reflective property\nof pony skin is\nSet near zero to get robotic looking of your\npony skin'
gui.ppm2.editor.phong.exponent_text = 'Phong Exponent'
gui.ppm2.editor.phong.boost.title = 'Phong Boost - multiplies specular map reflections'
gui.ppm2.editor.phong.boost.boost = 'Phong Boost'
gui.ppm2.editor.phong.tint.title = 'Tint color - what colors does reflect specular map\nWhite - Reflects all colors\n(In white room - white specular map)'
gui.ppm2.editor.phong.tint.tint = 'Tint color'
gui.ppm2.editor.phong.frensel.front.title = 'Phong Front - Fresnel 0 degree reflection angle multiplier'
gui.ppm2.editor.phong.frensel.front.front = 'Phong Front'
gui.ppm2.editor.phong.frensel.middle.title = 'Phong Middle - Fresnel 45 degree reflection angle multiplier'
gui.ppm2.editor.phong.frensel.middle.front = 'Phong Middle'
gui.ppm2.editor.phong.frensel.sliding.title = 'Phong Sliding - Fresnel 90 degree reflection angle multiplier'
gui.ppm2.editor.phong.frensel.sliding.front = 'Phong Sliding'
gui.ppm2.editor.phong.lightwarp = 'Lightwarp'
gui.ppm2.editor.phong.url_lightwarp = 'Lightwarp texture URL input\nIt must be 256x16!'
gui.ppm2.editor.phong.bumpmap = 'Bumpmap URL input'

gui.ppm2.editor.info.discord = "Join DBot's Discord!"
gui.ppm2.editor.info.ponyscape = "PPM/2 is a Ponyscape project"
gui.ppm2.editor.info.creator = "PPM/2 were created and being developed by DBot"
gui.ppm2.editor.info.newmodels = "New models were created by Durpy"
gui.ppm2.editor.info.cppmmodels = "CPPM Models (including pony hands) belong to UnkN', 'http://steamcommunity.com/profiles/76561198084938735"
gui.ppm2.editor.info.oldmodels = "Old models belong to Scentus and others"
gui.ppm2.editor.info.bugs = "Found a bug? Report here!"
gui.ppm2.editor.info.sources = "You can find sources here"
gui.ppm2.editor.info.githubsources = "Or on GitHub mirror"
gui.ppm2.editor.info.thanks = "Special thanks to everypony who criticized,\nhelped and tested PPM/2!"

-- other stuff

info.ppm2.fly.pegasus = 'You need to be a Pegasus or an Alicorn to fly!'
info.ppm2.fly.cannot = 'You can not %s right now.'

gui.ppm2.emotes.sad = 'Sad'
gui.ppm2.emotes.wild = 'Wild'
gui.ppm2.emotes.grin = 'Grin'
gui.ppm2.emotes.angry = 'Angry'
gui.ppm2.emotes.tongue = ':P'
gui.ppm2.emotes.angrytongue = '>:P'
gui.ppm2.emotes.pff = 'Pffff!'
gui.ppm2.emotes.kitty = ':3'
gui.ppm2.emotes.owo = 'oWo'
gui.ppm2.emotes.ugh = 'Uuugh'
gui.ppm2.emotes.lips = 'Lips lick'
gui.ppm2.emotes.scrunch = 'Scrunch'
gui.ppm2.emotes.sorry = 'Sorry'
gui.ppm2.emotes.wink = 'Wink'
gui.ppm2.emotes.right_wink = 'Right Wink'
gui.ppm2.emotes.licking = 'Licking'
gui.ppm2.emotes.suggestive_lips = 'Suggestive Lips lick'
gui.ppm2.emotes.suggestive_no_tongue = 'Suggestive w/o tongue'
gui.ppm2.emotes.gulp = 'Gulp'
gui.ppm2.emotes.blah = 'Blah blah blah'
gui.ppm2.emotes.happi = 'Happi'
gui.ppm2.emotes.happi_grin = 'Happi grin'
gui.ppm2.emotes.duck = 'DUCK'
gui.ppm2.emotes.ducks = 'DUCK INSANITY'
gui.ppm2.emotes.quack = 'QUACKS'
gui.ppm2.emotes.suggestive = 'Suggestive w/ tongue'

message.ppm2.emotes.invalid = 'No such emotion with ID: %s'

gui.ppm2.editor.intro.text = "Welcome to my new... Robosurgeon for Ponies! It allows you to....\n" ..
	"hmmm... become a pony, and yes, this process is IRREVERSIBLE! But don't need worry,\n" ..
	"you won't loose any of your brain cells before, in, and after then operation, because it performs operation very gently...\n\n" ..
	"Actually i have no idea, you biological being! His mechanical hands will envelop you in the most tight hugs you ever get!\n" ..
	"And, please, don't die in process, because this would cause VOID OF YOUR LIFE WARRANTY... and you will not be a pony!\n" ..
	"----\n\n\n" ..
	"Caution: Do not disassemble Robosurgeon.\nDo not put your hands/hooves into moving parts of Robosurgeon.\n" ..
	"Do not poweroff it while it operates.\nDo not try to resist it's actions.\n" ..
	"Always be gently with Robosurgeon\n" ..
	"Never slap Robosurgeon onto his interface.\n" ..
	"DBot's DLibCo take no responsibility for any harm caused by wrong usage of Robosurgeon.\n" ..
	"Warranty is voided if user die.\n" ..
	"No refunds."
gui.ppm2.editor.intro.title = 'Welcome here, Human!'
gui.ppm2.editor.intro.okay = "Ok, i will never read this license anyway"

message.ppm2.debug.race_condition = 'Received NetworkedPonyData before entity were created on client! Waiting...'

gui.ppm2.spawnmenu.newmodel = 'Spawn new model'
gui.ppm2.spawnmenu.newmodelnj = 'Spawn new nj model'
gui.ppm2.spawnmenu.oldmodel = 'Spawn old model'
gui.ppm2.spawnmenu.oldmodelnj = 'Spawn old nj model'
gui.ppm2.spawnmenu.cppmmodel = 'Spawn CPPM model'
gui.ppm2.spawnmenu.cppmmodelnj = 'Spawn CPPM nj model'
gui.ppm2.spawnmenu.cleanup = 'Cleanup unused models'
gui.ppm2.spawnmenu.reload = 'Reload local data'
gui.ppm2.spawnmenu.require = 'Require data from server'
gui.ppm2.spawnmenu.drawhooves = 'Draw hooves as hands'
gui.ppm2.spawnmenu.nohoofsounds = 'No hoofsounds'
gui.ppm2.spawnmenu.noflexes = 'Disable flexes (emotes)'
gui.ppm2.spawnmenu.advancedmode = 'Enable PPM2 editor advanced mode'
gui.ppm2.spawnmenu.reflections = 'Enable real time eyes reflections'
gui.ppm2.spawnmenu.reflections_drawdist = 'Reflections draw distance'
gui.ppm2.spawnmenu.reflections_renderdist = 'Reflections render distance'
gui.ppm2.spawnmenu.doublejump = 'Double jump activate flight'

tip.ppm2.in_editor = 'In PPM/2 Editor'
tip.ppm2.camera = "%s's PPM/2 Camera"
