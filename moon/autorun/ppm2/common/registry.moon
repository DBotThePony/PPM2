
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
    'Sharp Hooves', 'Sharp Hooves 2', 'Muzzle'
}

PPM2.BodyDetailsEnum = {
    'NONE', 'GRADIENT', 'LINES', 'STRIPES', 'HSTRIPES'
    'FRECKLES', 'HOOF_BIG', 'HOOF_SMALL', 'LAYER'
    'HOOF_BIG_ROUND', 'HOOF_SMALL_ROUND', 'SPOTS', 'ROBOTIC'
    'DASH_E', 'EYE_SCAR', 'EYE_WOUND', 'SCARS', 'MGS_SOCKS'
    'SHARP_HOOVES', 'SHARP_HOOVES_2', 'MUZZLE'
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
    'BOOKWORM', 'BUMPKIN', 'POOFEH', 'CURLY', 'INSTRUCTOR', 'NONE'
}

PPM2.AvaliableLowerManesNew = {
    'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT'
    'ASSERTIVE', 'BOLD', 'STUMPY', 'HIPPIE', 'SPEEDSTER'
    'BOOKWORM', 'BUMPKIN', 'CURLY', 'NONE'
}

PPM2.AvaliableTailsNew = {
    'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT'
    'ASSERTIVE', 'BOLD', 'STUMPY', 'SPEEDSTER', 'EDGY'
    'RADICAL', 'BOOKWORM', 'BUMPKIN', 'POOFEH', 'CURLY', 'NONE'
}

PPM2.AvaliableEyeTypes = {
    'DEFAULT', 'APERTURE'
}

PPM2.AvaliablePonyWings = {'DEFAULT', 'BATPONY'}

PPM2.AvaliablePonySuits = {'NONE', 'ROYAL_GUARD', 'SHADOWBOLTS_FULL', 'SHADOWBOLTS_LIGHT', 'WONDERBOLTS_FULL', 'WONDERBOLTS_LIGHT', 'SPIDERMANE_LIGHT', 'SPIDERMANE_FULL'}

do
    i = -1
    for mark in *PPM2.DefaultCutiemarks
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

PPM2.AGE_FILLY = 0
PPM2.AGE_ADULT = 1
PPM2.AGE_MATURE = 2
PPM2.AGE_ENUMS = {'FILLY', 'ADULT', 'MATURE'}

PPM2.MIN_DERP_STRENGTH = 0.1
PPM2.MAX_DERP_STRENGTH = 1.3

PPM2.MIN_MALE_BUFF = 0
PPM2.DEFAULT_MALE_BUFF = 1
PPM2.MAX_MALE_BUFF = 2
