
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

class PonyCollarController
    @AVALIABLE_CONTROLLERS = {}

    @MODELS = {
        'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl'
        'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'
        'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'
    }

    @COLLAR_MODEL = 'models/collars/collar_main.mdl'

    @__inherited: (child) =>
        child.MODELS_HASH = {mod, true for mod in *child.MODELS}
        @AVALIABLE_CONTROLLERS[mod] = child for mod in *child.MODELS
    @__inherited(@)

    new: (controller) =>
        @controller = controller
        @linkedEntity = NULL
        @linkedCollar = NULL
        @linkedEntities = {}
    
    GetData: => @controller
    GetEntity: => @ent
    GetLinedEntity: => @linkedEntity
    GetCollar: => @linkedCollar

    GetLinedEntities: => [ent for {ent, collar, ropelink} in *@linkedEntities when ent\IsValid()]
    GetCollars: => [collar for {ent, collar, ropelink} in *@linkedEntities when collar\IsValid()]
    GetRopes: => [ropelink for {ent, collar, ropelink} in *@linkedEntities when ropelink\IsValid()]
    GetCollarsAndEntities: => [{ent, collar, ropelink} for {ent, collar, ropelink} in *@linkedEntities when collar\IsValid() and ent\IsValid()]
    HasLinkTo: (target = NULL) =>
        return false if not IsValid(target)
        return @linkedCollar if @linkedEntity == target and IsValid(@linkedCollar)
        for {ent, collar} in *@linkedEntities
            return true if ent == target and IsValid(collar)
        return false

    RemoveEntities: =>
        collar\Remove() for {ent, collar} in *@collars when collar\IsValid()
        if IsValid(@linkedCollar)
            @linkedCollar\Remove()
        if IsValid(@linkedEntity)
            if targetData = @linkedEntity\GetPonyData()
                if controller = targetData\GetCollarController()
                    controller\GetCollar()\Remove() if IsValid(controller\GetCollar()) and controller\GetLinedEntity() == @ent
        @linkedEntity = NULL
        @linkedEntities = {}
    
    Remove: => @RemoveEntities()
    Reset: => @RemoveEntities()
    
    LinkToSelf: (target = NULL, position = @ent\GetPos(), angle = Angle(0, 0, 0)) =>
        local targetTable
        if IsValid(target)
            return @linkedCollar if IsValid(@linkedCollar) and @linkedEntity == target

            if targetData = target\GetPonyData()
                if controller = targetData\GetCollarController()
                    return NULL if controller\HasLinkTo(@ent)
            
            for data in *@linkedEntities
                if data[1] == target
                    return data[2] if IsValid(data[2])
                    targetTable = data
                    break
        
        targetTable = targetTable or {}
        targetTable[1] = target
        collar = ents.Create('prop_dynamic')
        targetTable[2] = collar
        with collar
            \SetModel(@@COLLAR_MODEL)
            if IsValid(target)
                pos, ang = target\GetBonePosition(1)
                \SetPos()

        return collar

PPM2.GetCollarController = (model = 'models/ppm/player_default_base.mdl') -> PonyCollarController.AVALIABLE_CONTROLLERS[model] or PonyCollarController
