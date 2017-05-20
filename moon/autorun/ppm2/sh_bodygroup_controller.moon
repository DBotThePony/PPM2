
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

PPM2.BODYGROUP_SKELETON = 0
PPM2.BODYGROUP_GENDER = 1
PPM2.BODYGROUP_HORN = 2
PPM2.BODYGROUP_WINGS = 3
PPM2.BODYGROUP_MANE_UPPER = 4
PPM2.BODYGROUP_MANE_LOWER = 5
PPM2.BODYGROUP_TAIL = 6
PPM2.BODYGROUP_CMARK = 7
PPM2.BODYGROUP_EYELASH = 8

class DefaultBodygroupController
    @AVALIABLE_CONTROLLERS = {}
    @MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl'}
    @__inherited: (child) =>
        child.MODELS_HASH = {mod, true for mod in *child.MODELS}
        @AVALIABLE_CONTROLLERS[mod] = child for mod in *child.MODELS
    @__inherited(@)

    @BODYGROUP_SKELETON = 0
    @BODYGROUP_GENDER = 1
    @BODYGROUP_HORN = 2
    @BODYGROUP_WINGS = 3
    @BODYGROUP_MANE_UPPER = 4
    @BODYGROUP_MANE_LOWER = 5
    @BODYGROUP_TAIL = 6
    @BODYGROUP_CMARK = 7
    @BODYGROUP_EYELASH = 8

    new: (controller) =>
        @ent = controller.ent
        @entID = controller.entID
        @controller = controller
    
    GetData: => @controller
    GetEntity: => @ent
    GetEntityID: => @entID
    GetDataID: => @entID

    @ATTACHMENT_EYES = 4
    @ATTACHMENT_EYES_NAME = 'eyes'

    CreateSocksModel: =>
        @socksModel\Remove() if IsValid(@socksModel)

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.isSocks and ent.manePlayer == @ent
                ent\Remove()

        model = 'models/props_pony/ppm/cosmetics/ppm_socks.mdl'

        return if CLIENT and @GetData()\IsGoingToNetwork()
        @socksModel = ents.Create('prop_dynamic') if SERVER
        @socksModel = ClientsideModel(model) if CLIENT
        with @socksModel
            .isPonyPropModel = true
            .isSocks = true
            .manePlayer = @ent
            \SetModel(model)
            \SetPos(@ent\GetPos())
            \Spawn()
            \Activate()
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        if SERVER
            timer.Simple .5, ->
                return unless IsValid(@socksModel)
                @GetData()\SetSocksModel(@socksModel)
                @ent\SetNWEntity('PPM2.SocksModel', @socksModel) if IsValid(@ent)
        else
            @GetData()\SetSocksModel(@socksModel)
        
        return @socksModel
    CreateSocksModelIfNotExists: =>
        return if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateSocksModel() if not IsValid(@socksModel)
        return @socksModel
    
    MergeModels: (targetEnt = NULL) =>
        return unless IsValid(targetEnt)
        socks = @CreateSocksModelIfNotExists() if @GetData()\GetSocksAsModel()
        if IsValid(socks)
            socks\SetParent(targetEnt)
            socks\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
    
    GetSocks: => @socksModel or NULL

    ApplyRace: =>
        switch @GetData()\GetRace()
            when PPM2.RACE_EARTH
                @ent\SetBodygroup(@@BODYGROUP_HORN, 1)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 1)
            when PPM2.RACE_PEGASUS
                @ent\SetBodygroup(@@BODYGROUP_HORN, 1)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 0)
            when PPM2.RACE_UNICORN
                @ent\SetBodygroup(@@BODYGROUP_HORN, 0)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 1)
            when PPM2.RACE_ALICORN
                @ent\SetBodygroup(@@BODYGROUP_HORN, 0)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 0)

    ResetBodygroups: =>
        for grp in *@ent\GetBodyGroups()
            @ent\SetBodygroup(grp.id, 0)
    ApplyBodygroups: =>
        @ResetBodygroups()
        @ent\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GetData()\GetManeType())
        @ent\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GetData()\GetManeTypeLower())
        @ent\SetBodygroup(@@BODYGROUP_TAIL, @GetData()\GetTailType())
        @ent\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
        @ent\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
        @ApplyRace()
        @CreateSocksModelIfNotExists() if @GetData()\GetSocksAsModel()
    
    @TAIL_BONE1 = 38
    @TAIL_BONE2 = 39
    @TAIL_BONE3 = 40
    DataChanges: (state) =>
        switch state\GetKey()
            when 'ManeType'
                @ent\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GetData()\GetManeType())
            when 'ManeTypeLower'
                @ent\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GetData()\GetManeTypeLower())
            when 'TailType'
                @ent\SetBodygroup(@@BODYGROUP_TAIL, @GetData()\GetTailType())
            when 'TailSize'
                size = state\GetValue()
                vec = Vector(size, size, size)
                @ent\ManipulateBoneScale(@@TAIL_BONE1, vec)
                @ent\ManipulateBoneScale(@@TAIL_BONE2, vec)
                @ent\ManipulateBoneScale(@@TAIL_BONE3, vec)
            when 'EyelashType'
                @ent\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
            when 'Gender'
                @ent\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
            when 'SocksAsModel'
                if state\GetValue()
                    @CreateSocksModelIfNotExists()
                else
                    @socksModel\Remove() if IsValid(@socksModel)
            when 'Race'
                @ApplyRace()

class CPPMBodygroupController extends DefaultBodygroupController
    @MODELS = {'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

    new: (...) => super(...)

    ApplyRace: =>
        switch @GetData()\GetRace()
            when PPM2.RACE_EARTH
                @ent\SetBodygroup(@@BODYGROUP_HORN, 1)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 1)
            when PPM2.RACE_PEGASUS
                @ent\SetBodygroup(@@BODYGROUP_HORN, 1)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 0)
            when PPM2.RACE_UNICORN
                @ent\SetBodygroup(@@BODYGROUP_HORN, 0)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 1)
            when PPM2.RACE_ALICORN
                @ent\SetBodygroup(@@BODYGROUP_HORN, 2)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 3)

class NewBodygroupController extends DefaultBodygroupController
    @MODELS = {'models/ppm/player_default_base_new.mdl'}

    @BODYGROUP_SKELETON = 0
    @BODYGROUP_GENDER = -1
    @BODYGROUP_HORN = 1
    @BODYGROUP_WINGS = 2

    CreateUpperManeModel: =>
        @maneModelUP\Remove() if IsValid(@maneModelUP)

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.upperMane and ent.manePlayer == @ent
                ent\Remove()

        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetupper#{modelID}.mdl"

        return if CLIENT and @GetData()\IsGoingToNetwork()
        @maneModelUP = ents.Create('prop_dynamic') if SERVER
        @maneModelUP = ClientsideModel(model) if CLIENT
        with @maneModelUP
            .isPonyPropModel = true
            .upperMane = true
            .manePlayer = @ent
            \SetModel(model)
            \SetPos(@ent\GetPos())
            \Spawn()
            \Activate()
            \SetBodygroup(1, bodygroupID)
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        if SERVER
            timer.Simple .5, ->
                return unless IsValid(@maneModelUP)
                @GetData()\SetUpperManeModel(@maneModelUP)
                @ent\SetNWEntity('PPM2.UpperManeModel', @maneModelUP) if IsValid(@ent)
        else
            @GetData()\SetUpperManeModel(@maneModelUP)
            
        return @maneModelUP
    CreateLowerManeModel: =>
        @maneModelLower\Remove() if IsValid(@maneModelLower)

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.lowerMane and ent.manePlayer == @ent
                ent\Remove()

        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetlower#{modelID}.mdl"

        return if CLIENT and @GetData()\IsGoingToNetwork()
        @maneModelLower = ents.Create('prop_dynamic') if SERVER
        @maneModelLower = ClientsideModel(model) if CLIENT
        with @maneModelLower
            .isPonyPropModel = true
            .lowerMane = true
            .manePlayer = @ent
            \SetModel(model)
            \SetPos(@ent\GetPos())
            \Spawn()
            \Activate()
            \SetBodygroup(1, bodygroupID)
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        if SERVER
            timer.Simple .5, ->
                return unless IsValid(@maneModelLower)
                @GetData()\SetLowerManeModel(@maneModelLower) 
                @ent\SetNWEntity('PPM2.LowerManeModel', @maneModelLower) if IsValid(@ent)
        else
            @GetData()\SetLowerManeModel(@maneModelLower) 

        return @maneModelLower
    CreateTailModel: =>
        @tailModel\Remove() if IsValid(@tailModel)

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.isTail and ent.manePlayer == @ent
                ent\Remove()

        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_tailset#{modelID}.mdl"

        return if CLIENT and @GetData()\IsGoingToNetwork()
        @tailModel = ents.Create('prop_dynamic') if SERVER
        @tailModel = ClientsideModel(model) if CLIENT
        with @tailModel
            .isPonyPropModel = true
            .isTail = true
            .manePlayer = @ent
            \SetModel(model)
            \SetPos(@ent\GetPos())
            \Spawn()
            \Activate()
            \SetBodygroup(1, bodygroupID)
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        if SERVER
            timer.Simple .5, ->
                return unless IsValid(@tailModel)
                @GetData()\SetTailModel(@tailModel)
                @ent\SetNWEntity('PPM2.TailModel', @tailModel) if IsValid(@ent)
        else
            @GetData()\SetTailModel(@tailModel)
        
        return @tailModel
    
    CreateUpperManeModelIfNotExists: =>
        return if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateUpperManeModel() if not IsValid(@maneModelUP)
        return @maneModelUP
    CreateLowerManeModelIfNotExists: =>
        return if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateLowerManeModel() if not IsValid(@maneModelLower)
        return @maneModelLower
    CreateTailModelIfNotExists: =>
        return if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateTailModel() if not IsValid(@tailModel)
        return @tailModel

    GetUpperMane: => @maneModelUP or NULL
    GetLowerMane: => @maneModelLower or NULL
    GetTail: => @tailModel or NULL

    MergeModels: (targetEnt = NULL) =>
        super(targetEnt)
        return unless IsValid(targetEnt)
        maneUpper = @CreateUpperManeModelIfNotExists()
        maneLower = @CreateLowerManeModelIfNotExists()
        tail = @CreateTailModelIfNotExists()
        if IsValid(maneUpper)
            maneUpper\SetParent(targetEnt)
            maneUpper\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
        if IsValid(maneLower)
            maneLower\SetParent(targetEnt)
            maneLower\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
        if IsValid(tail)
            tail\SetParent(targetEnt)
            tail\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER

    UpdateUpperMane: =>
        return if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateUpperManeModelIfNotExists()
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetupper#{modelID}.mdl"
        @maneModelUP\SetModel(model)
        @maneModelUP\SetBodygroup(1, bodygroupID)
        return @maneModelUP
    UpdateLowerMane: =>
        return if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateLowerManeModelIfNotExists()
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetlower#{modelID}.mdl"
        @maneModelLower\SetModel(model)
        @maneModelLower\SetBodygroup(1, bodygroupID)
        return @maneModelLower
    UpdateTailModel: =>
        return if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateTailModelIfNotExists()
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_tailset#{modelID}.mdl"
        @tailModel\SetModel(model)
        @tailModel\SetBodygroup(1, bodygroupID)
        @tailModel\SetModelScale(@GetData()\GetTailSize())
        return @tailModel

    ApplyBodygroups: =>
        @ResetBodygroups()
        @ent\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
        @ent\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
        @ApplyRace()
        @CreateUpperManeModel()
        @CreateLowerManeModel()
        @CreateTailModel()
        @CreateSocksModelIfNotExists() if @GetData()\GetSocksAsModel()

    DataChanges: (state) =>
        switch state\GetKey()
            when 'EyelashType'
                @ent\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
            when 'Gender'
                @ent\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
            when 'ManeTypeNew'
                @UpdateUpperMane()
            when 'ManeTypeLowerNew'
                @UpdateLowerMane()
            when 'TailTypeNew'
                @UpdateTailModel()
            when 'TailSize'
                @UpdateTailModel()
            when 'Race'
                @ApplyRace()
            when 'SocksAsModel'
                if state\GetValue()
                    @CreateSocksModelIfNotExists()
                else
                    @socksModel\Remove() if IsValid(@socksModel)


PPM2.CPPMBodygroupController = CPPMBodygroupController
PPM2.DefaultBodygroupController = DefaultBodygroupController

PPM2.GetBodugroupController = (model = 'models/ppm/player_default_base.mdl') -> DefaultBodygroupController.AVALIABLE_CONTROLLERS[model\lower()] or DefaultBodygroupController
