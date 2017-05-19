
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

timer.Create 'PPM2.ModelWatchdog', 1, 0, ->
    for ply in *player.GetAll()
        model = ply\GetModel()
        ply.__ppm2_lastmodel = ply.__ppm2_lastmodel or model
        if ply.__ppm2_lastmodel ~= model
            data = ply\GetPonyData()
            if data and data.ModelChanges
                data\ModelChanges(ply.__ppm2_lastmodel, model)
                ply.__ppm2_lastmodel = model

hook.Add 'Think', 'PPM2.Think', ->
    for ply in *player.GetAll()
        data = ply\GetPonyData()
        data\Think() if data
