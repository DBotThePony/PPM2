
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
    switch @GetModel()
        when 'models/ppm/player_default_base.mdl'
            return true
        when 'models/ppm/player_default_base_new.mdl'
            return true
        when 'models/ppm/player_default_base_nj.mdl'
            return true
        when 'models/cppm/player_default_base.mdl'
            return true
        when 'models/cppm/player_default_base_nj.mdl'
            return true
        else
            return false
entMeta.IsPonyCached = =>
    switch @__ppm2_lastmodel
        when 'models/ppm/player_default_base.mdl'
            return true
        when 'models/ppm/player_default_base_new.mdl'
            return true
        when 'models/ppm/player_default_base_nj.mdl'
            return true
        when 'models/cppm/player_default_base.mdl'
            return true
        when 'models/cppm/player_default_base_nj.mdl'
            return true
        else
            return false
entMeta.HasPonyModel = entMeta.IsPony
