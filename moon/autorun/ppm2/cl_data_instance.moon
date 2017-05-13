
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
        'age':                  -> PPM2.AGE_ADULT
        'race':                 -> PPM2.RACE_EARTH
        'gender':               -> PPM2.GENDER_FEMALE
        'weight':               -> 1
        'eyelash':              -> 0
        'tail':                 -> 0
        'mane':                 -> 0
        'manelower':            -> 0
        'tailsize':             -> 1
        'eye_iris_size':        -> 1
        'eye_width':            -> 1
        'eye_bg':               -> Color(255, 255, 255)
        'eye_hole':             -> Color(0, 0, 0)
        'eye_iris1':            -> Color(200, 200, 200)
        'eye_iris2':            -> Color(200, 200, 200)
        'eye_irisline1':        -> Color(255, 255, 255)
        'eye_irisline2':        -> Color(255, 255, 255)
        'body':                 -> Color(255, 255, 255)
        'eye_lines':            -> true
    }

    for i = 1, 6
        @PONY_DATA["tail_color_#{i}"] =         -> Color(255, 255, 255)
        @PONY_DATA["lower_mane_color_#{i}"] =   -> Color(255, 255, 255)
        @PONY_DATA["upper_mane_color_#{i}"] =   -> Color(255, 255, 255)

    new: (filename, data) =>
        @SetFilename(filename)
        @valid = @isOpen
        @rawData = data
        --if data
    
    SetFilename: (filename) =>
        @filename = filename
        @isOpen = @filename ~= nil
        @exists = file.Exists("#{@DATA_DIR}#{filename}", 'DATA')
    IsValid: => @valid
    Exists: => @exists
    FileExists: => @exists
    IsExists: => @exists

    Serealize: =>


    Save: =>
        error('Create file first with Create()') unless @exists


PPM2.PonyDataInstance = PonyDataInstance
