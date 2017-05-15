
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

class PonyRenderController
    @AVALIABLE_CONTROLLERS = {}
    @MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}
    @__inherited: (child) =>
        child.MODELS_HASH = {mod, true for mod in *child.MODELS}
        @AVALIABLE_CONTROLLERS[mod] = child for mod in *child.MODELS
    @__inherited(@)

    CompileTextures: => @GetTextureController()\CompileTextures()
    new: (data) =>
        @networkedData = data
        @ent = data.ent
        @modelCached = data\GetModel()
        @CompileTextures()
    GetEntity: => @ent
    GetData: => @networkedData
    GetModel: => @networkedData\GetModel()

    PreDraw: =>
        @GetTextureController()\PreDraw()
    PostDraw: =>
        @GetTextureController()\PostDraw()

    DataChanges: (state) =>
        return if not @ent
        @GetTextureController()\DataChanges(state)
    GetTextureController: =>
        if not @renderController
            cls = PPM2.GetTextureController(@modelCached)
            @renderController = cls(@)
        @renderController.ent = @ent
        return @renderController

PPM2.PonyRenderController = PonyRenderController
PPM2.GetPonyRenderController = (model = 'models/ppm/player_default_base.mdl') -> PonyRenderController.AVALIABLE_CONTROLLERS[model\lower()] or PonyRenderController
PPM2.GetPonyRendererController = PPM2.GetPonyRenderController
PPM2.GetRenderController = PPM2.GetPonyRenderController
PPM2.GetRendererController = PPM2.GetPonyRenderController
