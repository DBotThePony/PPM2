
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


PPM2.ALLOW_TO_MODIFY_SCALE = CreateConVar('ppm2_sv_allow_resize', '1', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Allow to resize ponies. Disables resizing completely (visual; mechanical)')

player_manager.AddValidModel('pony', 'models/ppm/player_default_base_new.mdl')
list.Set('PlayerOptionsModel', 'pony', 'models/ppm/player_default_base_new.mdl')

player_manager.AddValidModel('ponynj', 'models/ppm/player_default_base_new_nj.mdl')
list.Set('PlayerOptionsModel', 'ponynj', 'models/ppm/player_default_base_new_nj.mdl')

player_manager.AddValidModel('ponynj_old', 'models/ppm/player_default_base_nj.mdl')
list.Set('PlayerOptionsModel', 'ponynj_old', 'models/ppm/player_default_base_nj.mdl')

player_manager.AddValidModel('pony_old', 'models/ppm/player_default_base.mdl')
list.Set('PlayerOptionsModel', 'pony_old', 'models/ppm/player_default_base.mdl')

player_manager.AddValidModel('pony_cppm', 'models/cppm/player_default_base.mdl')
list.Set('PlayerOptionsModel', 'pony_cppm', 'models/cppm/player_default_base.mdl')

player_manager.AddValidModel('ponynj_cppm', 'models/cppm/player_default_base_nj.mdl')
list.Set('PlayerOptionsModel', 'ponynj_cppm', 'models/cppm/player_default_base_nj.mdl')

player_manager.AddValidHands(model, 'models/ppm/c_arms_pony.mdl', 0, '') for model in *{'pony', 'pony_cppm', 'ponynj', 'ponynj_cppm', 'pony_old'}

PPM2.MIN_WEIGHT = 0.7
PPM2.MAX_WEIGHT = 1.5

PPM2.MIN_SCALE = 0.5
PPM2.MAX_SCALE = 1.3

PPM2.PONY_HEIGHT_MODIFIER = 0.64
PPM2.PONY_HEIGHT_MODIFIER_DUCK = 1.12
PPM2.PONY_HEIGHT_MODIFIER_DUCK_HULL = 1

PPM2.MIN_NECK = 0.6
PPM2.MAX_NECK = 1.4

PPM2.MIN_LEGS = 0.6
PPM2.MAX_LEGS = 1.75

PPM2.MIN_SPINE = 0.8
PPM2.MAX_SPINE = 2

PPM2.PONY_JUMP_MODIFIER = 1.4

PPM2.PLAYER_VOFFSET = 64 * PPM2.PONY_HEIGHT_MODIFIER
PPM2.PLAYER_VOFFSET_DUCK = 28 * PPM2.PONY_HEIGHT_MODIFIER_DUCK

PPM2.PLAYER_VIEW_OFFSET = Vector(0, 0, PPM2.PLAYER_VOFFSET)
PPM2.PLAYER_VIEW_OFFSET_DUCK = Vector(0, 0, PPM2.PLAYER_VOFFSET_DUCK)

PPM2.PLAYER_VIEW_OFFSET_ORIGINAL = Vector(0, 0, 64)
PPM2.PLAYER_VIEW_OFFSET_DUCK_ORIGINAL = Vector(0, 0, 28)

PPM2.MIN_TAIL_SIZE = 0.6
PPM2.MAX_TAIL_SIZE = 1.7 -- i luv big tails

PPM2.MIN_IRIS = 0.4
PPM2.MAX_IRIS = 1.3

PPM2.MIN_HOLE = 0.1
PPM2.MAX_HOLE = .95

PPM2.MIN_HOLE_SHIFT = -0.5
PPM2.MAX_HOLE_SHIFT = 0.5

PPM2.MIN_PUPIL_SIZE = 0.2
PPM2.MAX_PUPIL_SIZE = 1

PPM2.MIN_EYE_ROTATION = -180
PPM2.MAX_EYE_ROTATION = 180

PPM2.HAND_BODYGROUP_ID = 0
PPM2.HAND_BODYGROUP_MAGIC = 0
PPM2.HAND_BODYGROUP_HOOVES = 1

PPM2.AvaliableTails = {
	'MAILCALL'
	'FLOOFEH'
	'ADVENTUROUS'
	'SHOWBOAT'
	'ASSERTIVE'
	'BOLD'
	'STUMPY'
	'SPEEDSTER'
	'EDGY'
	'RADICAL'
	'BOOKWORM'
	'BUMPKIN'
	'POOFEH'
	'CURLY'
	'NONE'
}

PPM2.AvailableClothesHead = {
	'EMPTY', 'APPLEJACK_HAT', 'BRAEBURN_HAT', 'TRIXIE_HAT', 'HEADPHONES'
}

PPM2.AvailableClothesNeck = {
	'EMPTY', 'SCARF', 'TRIXIE_CAPE', 'TIE', 'BOWTIE'
}

PPM2.AvailableClothesBody = {
	'EMPTY', 'VEST', 'SHIRT', 'HOODIE', 'WONDERBOLTS_BADGE'
}

PPM2.AvailableClothesEye = {
	'EMPTY', 'GOGGLES_ROUND_FEMALE', 'GOGGLES_ROUND_MALE', 'SHADES_FEMALE', 'SHADES_MALE'
	'MONOCLE_FEMALE', 'MONOCLE_MALE', 'EYEPATH_FEMALE', 'EYEPATH_MALE'
}

PPM2.MAX_CLOTHES_COLORS = 6

PPM2.AvailableHorns = {
	'EMPTY', 'CUSTOM', 'CLASSIC_SHARP', 'CLASSIC', 'BROKEN', 'LONG'
	'LONG_CURLED', 'POISON_JOKE', 'CHANGELING'
	'CHANGELING_QUEEN', 'KIRIN'
}

PPM2.AvaliableUpperManes = {
	'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT', 'ASSERTIVE'
	'BOLD', 'STUMPY', 'SPEEDSTER', 'RADICAL', 'SPIKED'
	'BOOKWORM', 'BUMPKIN', 'POOFEH', 'CURLY', 'INSTRUCTOR', 'NONE'
}

PPM2.AvaliableLowerManes = {
	'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT'
	'ASSERTIVE', 'BOLD', 'STUMPY', 'HIPPIE', 'SPEEDSTER'
	'BOOKWORM', 'BUMPKIN', 'CURLY', 'NONE'
}

PPM2.EyelashTypes = {
	'Default', 'Double', 'Coy', 'Full', 'Mess', 'None'
}

PPM2.BodyDetails = {
	'None', 'Leg gradient', 'Lines', 'Stripes', 'Head stripes'
	'Freckles', 'Hooves big', 'Hooves small', 'Head layer'
	'Hooves big rnd', 'Hooves small rnd', 'Spots 1', 'Robotic'
	'DASH-E', 'Eye Scar', 'Eye Wound', 'Scars', 'MGS Socks'
	'Sharp Hooves', 'Sharp Hooves 2', 'Muzzle', 'Eye Scar Left'
	'Eye Scar Right'

	'Albedo Printed Plate Skin'
	'Paintable Printed Plate Skin'
	'Albedo Printed Plate Strip'
	'Paintable Printed Plate Strip'
	'Cow Details'
	'Deer Details'
	'Extended Deer Details'
	'Demonic'
	'Ear Inner Detail'
	'Zebra Details'
}

PPM2.BodyDetailsEnum = {
	'NONE', 'GRADIENT', 'LINES', 'STRIPES', 'HSTRIPES'
	'FRECKLES', 'HOOF_BIG', 'HOOF_SMALL', 'LAYER'
	'HOOF_BIG_ROUND', 'HOOF_SMALL_ROUND', 'SPOTS', 'ROBOTIC'
	'DASH_E', 'EYE_SCAR', 'EYE_WOUND', 'SCARS', 'MGS_SOCKS'
	'SHARP_HOOVES', 'SHARP_HOOVES_2', 'MUZZLE', 'EYE_SCAR_LEFT'
	'EYE_SCAR_RIGHT'

	'ALBEDO_ANDROID'
	'PAINT_ANDROID'
	'ALBEDO_ANDROID_STRIP'
	'PAINT_ANDROID_STRIP'
	'COW'
	'DEER'
	'DEER_EXTENDED'
	'DEMONIC'
	'EAR_INNER'
	'ZEBRA_DETAILS'
}

PPM2.SocksTypes = {
	'DEFAULT'
	'GEOMETRIC1'
	'GEOMETRIC2'
	'GEOMETRIC3'
	'GEOMETRIC4'
	'GEOMETRIC5'
	'GEOMETRIC6'
	'GEOMETRIC7'
	'GEOMETRIC8'
	'DARK1'
	'FLOWERS10'
	'FLOWERS11'
	'FLOWERS12'
	'FLOWERS13'
	'FLOWERS14'
	'FLOWERS15'
	'FLOWERS16'
	'FLOWERS17'
	'FLOWERS18'
	'FLOWERS19'
	'FLOWERS2'
	'FLOWERS20'
	'FLOWERS3'
	'FLOWERS4'
	'FLOWERS5'
	'FLOWERS6'
	'FLOWERS7'
	'FLOWERS8'
	'FLOWERS9'
	'GREY1'
	'GREY2'
	'GREY3'
	'HEARTS1'
	'HEARTS2'
	'SNOW1'
	'WALLPAPER1'
	'WALLPAPER2'
	'WALLPAPER3'
}

PPM2.AvaliableLightwarps = {
	'SFM_PONY'
	'AIRBRUSH'
	'HARD_LIGHT'
	'PURPLE_SKY'
	'SPAWN'
	'TF2'
	'TF2_CINEMATIC'
	'TF2_CLASSIC'
	'WELL_OILED'
}

PPM2.MAX_LIGHTWARP = #PPM2.AvaliableLightwarps - 1

PPM2.AvaliableLightwarpsPaths = ['models/ppm2/lightwarps/' .. mat\lower() for _, mat in ipairs PPM2.AvaliableLightwarps]

PPM2.DefaultCutiemarks = {
	'8ball', 'dice', 'magichat',
	'magichat02', 'record', 'microphone',
	'bits', 'checkered', 'lumps',
	'mirror', 'camera', 'magnifier',
	'padlock', 'binaryfile', 'floppydisk',
	'cube', 'bulb', 'battery',
	'deskfan', 'flames', 'alarm',
	'myon', 'beer', 'berryglass',
	'roadsign', 'greentree', 'seasons',
	'palette', 'palette02', 'palette03',
	'lightningstone', 'partiallycloudy', 'thunderstorm',
	'storm', 'stoppedwatch', 'twistedclock',
	'surfboard', 'surfboard02', 'star',
	'ussr', 'vault', 'anarchy',
	'suit', 'deathscythe', 'shoop',
	'smiley', 'dawsome', 'weegee'
	'applej', 'applem', 'bon_bon', 'carrots', 'celestia', 'cloudy', 'custom01', 'custom02', 'derpy', 'firezap',
	'fluttershy', 'fruits', 'island', 'lyra', 'mine', 'note', 'octavia', 'pankk', 'pinkie_pie', 'rainbow_dash',
	'rarity', 'rosen', 'sflowers', 'storm', 'time', 'time2', 'trixie', 'twilight', 'waters', 'weer', 'zecora'
}

PPM2.AvaliableUpperManesNew = {
	'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT', 'ASSERTIVE'
	'BOLD', 'STUMPY', 'SPEEDSTER', 'RADICAL', 'SPIKED'
	'BOOKWORM', 'BUMPKIN', 'POOFEH', 'CURLY', 'INSTRUCTOR'
	'TIMID', 'FILLY', 'MECHANIC', 'MOON', 'CLOUD'
	'DRUNK', 'EMO'
	'NONE'
}

PPM2.AvaliableLowerManesNew = {
	'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT'
	'ASSERTIVE', 'BOLD', 'STUMPY', 'HIPPIE', 'SPEEDSTER'
	'BOOKWORM', 'BUMPKIN', 'CURLY'
	'TIMID', 'MOON', 'BUN', 'CLOUD', 'EMO'
	'NONE'
}

PPM2.AvaliableTailsNew = {
	'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT'
	'ASSERTIVE', 'BOLD', 'STUMPY', 'SPEEDSTER', 'EDGY'
	'RADICAL', 'BOOKWORM', 'BUMPKIN', 'POOFEH', 'CURLY'
	'NONE'
}

PPM2.AvaliableEyeTypes = {
	'DEFAULT', 'APERTURE'
}

PPM2.AvaliableEyeReflections = {
	'DEFAULT', 'CRYSTAL_FOAL', 'CRYSTAL'
	'FOAL', 'MALE'
}

PPM2.AvaliablePonyWings = {'DEFAULT', 'BATPONY'}

PPM2.AvaliablePonySuits = {'NONE', 'ROYAL_GUARD', 'SHADOWBOLTS_FULL', 'SHADOWBOLTS_LIGHT', 'WONDERBOLTS_FULL', 'WONDERBOLTS_LIGHT', 'SPIDERMANE_LIGHT', 'SPIDERMANE_FULL'}

do
	i = -1
	for _, mark in ipairs PPM2.DefaultCutiemarks
		i += 1
		PPM2["CMARK_#{mark\upper()}"] = i

PPM2.MIN_EYELASHES = 0
PPM2.MAX_EYELASHES = #PPM2.EyelashTypes - 1
PPM2.EYELASHES_NONE = #PPM2.EyelashTypes - 1

PPM2.MIN_TAILS = 0
PPM2.MAX_TAILS = #PPM2.AvaliableTails - 1

PPM2.MIN_TAILS_NEW = 0
PPM2.MAX_TAILS_NEW = #PPM2.AvaliableTailsNew - 1

PPM2.MIN_UPPER_MANES = 0
PPM2.MAX_UPPER_MANES = #PPM2.AvaliableUpperManes - 1

PPM2.MIN_LOWER_MANES = 0
PPM2.MAX_LOWER_MANES = #PPM2.AvaliableLowerManes - 1

PPM2.MIN_UPPER_MANES_NEW = 0
PPM2.MAX_UPPER_MANES_NEW = #PPM2.AvaliableUpperManesNew - 1

PPM2.MIN_LOWER_MANES_NEW = 0
PPM2.MAX_LOWER_MANES_NEW = #PPM2.AvaliableLowerManesNew - 1

PPM2.MIN_EYE_TYPE = 0
PPM2.MAX_EYE_TYPE = #PPM2.AvaliableEyeTypes - 1

PPM2.MIN_DETAIL = 0
PPM2.MAX_DETAIL = #PPM2.BodyDetails - 1

PPM2.MIN_CMARK = 0
PPM2.MAX_CMARK = #PPM2.DefaultCutiemarks - 1

PPM2.MIN_SUIT = 0
PPM2.MAX_SUIT = #PPM2.AvaliablePonySuits - 1

PPM2.MIN_WINGS = 0
PPM2.MAX_WINGS = #PPM2.AvaliablePonyWings - 1

PPM2.MIN_SOCKS = 0
PPM2.MAX_SOCKS = #PPM2.SocksTypes - 1

PPM2.GENDER_FEMALE = 0
PPM2.GENDER_MALE = 1

PPM2.MAX_BODY_DETAILS = 8

PPM2.RACE_EARTH = 0
PPM2.RACE_PEGASUS = 1
PPM2.RACE_UNICORN = 2
PPM2.RACE_ALICORN = 3
PPM2.RACE_ENUMS = {'EARTH', 'PEGASUS', 'UNICORN', 'ALICORN'}

PPM2.RACE_HAS_HORN = 0x1
PPM2.RACE_HAS_WINGS = 0x2

PPM2.AGE_FILLY = 0
PPM2.AGE_ADULT = 1
PPM2.AGE_MATURE = 2
PPM2.AGE_ENUMS = {'FILLY', 'ADULT', 'MATURE'}

PPM2.MIN_DERP_STRENGTH = 0.1
PPM2.MAX_DERP_STRENGTH = 1.3

PPM2.MIN_MALE_BUFF = 0
PPM2.DEFAULT_MALE_BUFF = 1
PPM2.MAX_MALE_BUFF = 2

PPM2.MAX_TATTOOS = 25

PPM2.TATTOOS_REGISTRY = {
	'NONE', 'ARROW', 'BLADES', 'CROSS', 'DIAMONDINNER', 'DIAMONDOUTER'
	'DRACO', 'EVILHEART', 'HEARTWAVE', 'JUNCTION', 'NOTE', 'NOTE2'
	'TATTOO1', 'TATTOO2', 'TATTOO3', 'TATTOO4', 'TATTOO5', 'TATTOO6', 'TATTOO7'
	'WING', 'HEART'
}

PPM2.MIN_TATTOOS = 0
PPM2.MAX_TATTOOS = #PPM2.TATTOOS_REGISTRY - 1

PPM2.MIN_WING = 0.1
PPM2.MIN_WINGX = -10
PPM2.MIN_WINGY = -10
PPM2.MIN_WINGZ = -10
PPM2.MAX_WING = 2
PPM2.MAX_WINGX = 10
PPM2.MAX_WINGY = 10
PPM2.MAX_WINGZ = 10
