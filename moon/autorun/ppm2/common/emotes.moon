
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

PPM2.AVALIABLE_EMOTES = {
    {
        'name': 'Sad'
        'sequence': 'sad'
        'time': 10
    }

    {
        'name': 'Grin'
        'sequence': 'big_grin'
        'time': 10
    }

    {
        'name': 'Angry'
        'sequence': 'anger'
        'time': 10
    }

    {
        'name': ':P'
        'sequence': 'tongue'
        'time': 10
    }

    {
        'name': ':3'
        'sequence': 'cat'
        'time': 10
    }
}

for i, data in pairs PPM2.AVALIABLE_EMOTES
    data.id = i
