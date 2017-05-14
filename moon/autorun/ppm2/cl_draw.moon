
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

timer.Create 'PPM2.ModelChecks', 1, 0, ->
    for ply in *player.GetAll()
        ply.__cachedIsPony = ply\IsPony()

PPM2.PrePlayerDraw = =>
    return unless @Alive()
    return unless @GetPonyData()
    return unless @__cachedIsPony
    data = @GetPonyData()
    texController = data\GetTextureController()
    texController\PreDraw()
PPM2.PostPlayerDraw = =>
    return unless @Alive()
    return unless @GetPonyData()
    return unless @__cachedIsPony
    data = @GetPonyData()
    texController = data\GetTextureController()
    texController\PostDraw()

hook.Add 'PrePlayerDraw', 'PPM2.PlayerDraw', PPM2.PrePlayerDraw
hook.Add 'PostPlayerDraw', 'PPM2.PostPlayerDraw', PPM2.PostPlayerDraw

