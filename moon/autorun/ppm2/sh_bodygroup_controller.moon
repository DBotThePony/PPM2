
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

    @NEXT_OBJ_ID = 0

    @COOLDOWN_TIME = 5
    @COOLDOWN_MAX_COUNT = 4

    new: (controller) =>
        @isValid = true
        @ent = controller.ent
        @entID = controller.entID
        @controller = controller
        @objID = @@NEXT_OBJ_ID
        @@NEXT_OBJ_ID += 1
        @SocksModelUpdateCooldown = 0
        @SocksModelUpdateCount = 0
    
    UpdateCooldowns: =>
        if CLIENT
            @SocksModelUpdateCooldown = 0
            @SocksModelUpdateCount = 0
        rTime = RealTime()
        if @SocksModelUpdateCooldown < rTime
            @SocksModelUpdateCooldown = rTime + @@COOLDOWN_TIME
            @SocksModelUpdateCount = 0
    
    __tostring: => "[#{@@__name}:#{@objID}|#{@ent}]"
    IsValid: => @isValid
    GetData: => @controller
    GetEntity: => @ent
    GetEntityID: => @entID
    GetDataID: => @entID

    @ATTACHMENT_EYES = 4
    @ATTACHMENT_EYES_NAME = 'eyes'

    CreateSocksModel: =>
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @socksModel if IsValid(@socksModel)
        @UpdateCooldowns()
        return NULL if @SocksModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @SocksModelUpdateCount += 1

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.isSocks and ent.manePlayer == @ent
                @socksModel = ent
                return ent

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
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateSocksModel() if not IsValid(@socksModel)
        @socksModel\SetParent(@ent) if IsValid(@ent)
        @socksModel\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
        return @socksModel
    
    MergeModels: (targetEnt = NULL) =>
        return unless @isValid
        return unless IsValid(targetEnt)
        socks = @CreateSocksModelIfNotExists() if @GetData()\GetSocksAsModel()
        if IsValid(socks)
            socks\SetParent(targetEnt)
            socks\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
    
    GetSocks: => @socksModel or NULL

    ApplyRace: =>
        return unless @isValid
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
        return unless @isValid
        for grp in *@ent\GetBodyGroups()
            @ent\SetBodygroup(grp.id, 0)
    ApplyBodygroups: =>
        return unless @isValid
        @ResetBodygroups()
        @ent\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GetData()\GetManeType())
        @ent\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GetData()\GetManeTypeLower())
        @ent\SetBodygroup(@@BODYGROUP_TAIL, @GetData()\GetTailType())
        @ent\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
        @ent\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
        @ApplyRace()
        @CreateSocksModelIfNotExists() if @GetData()\GetSocksAsModel()
    
    Remove: =>
        @socksModel\Remove() if IsValid(@socksModel)
        @ResetBodygroups()
        @isValid = false
    
    @TAIL_BONE1 = 38
    @TAIL_BONE2 = 39
    @TAIL_BONE3 = 40
    DataChanges: (state) =>
        return unless @isValid
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

    __tostring: => "[#{@@__name}:#{@objID}|#{@GetData()}]"

    new: (...) =>
        super(...)
        @UpperManeModelUpdateCooldown = 0
        @UpperManeModelUpdateCount = 0
        @LowerManeModelUpdateCooldown = 0
        @LowerManeModelUpdateCount = 0
        @TailModelUpdateCooldown = 0
        @TailModelUpdateCount = 0
    
    UpdateCooldowns: =>
        super()
        if CLIENT
            @UpperManeModelUpdateCooldown = 0
            @UpperManeModelUpdateCount = 0
            @LowerManeModelUpdateCooldown = 0
            @LowerManeModelUpdateCount = 0
            @TailModelUpdateCooldown = 0
            @TailModelUpdateCount = 0 
        rTime = RealTime()
        if @UpperManeModelUpdateCooldown > rTime
            @UpperManeModelUpdateCooldown = rTime + @@COOLDOWN_TIME
            @UpperManeModelUpdateCount = 0
        if @LowerManeModelUpdateCooldown > rTime
            @LowerManeModelUpdateCooldown = rTime + @@COOLDOWN_TIME
            @LowerManeModelUpdateCount = 0
        if @TailModelUpdateCooldown > rTime
            @TailModelUpdateCooldown = rTime + @@COOLDOWN_TIME
            @TailModelUpdateCount = 0

    CreateUpperManeModel: =>
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @maneModelUP if IsValid(@maneModelUP)
        @UpdateCooldowns()
        return NULL if @UpperManeModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @UpperManeModelUpdateCount += 1

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.upperMane and ent.manePlayer == @ent
                @maneModelUP = ent
                return ent

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
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @maneModelLower if IsValid(@maneModelLower)
        @UpdateCooldowns()
        return NULL if @LowerManeModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @LowerManeModelUpdateCount += 1

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.lowerMane and ent.manePlayer == @ent
                @maneModelLower = ent
                return ent

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
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @tailModel if IsValid(@tailModel)
        @UpdateCooldowns()
        return NULL if @TailModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @TailModelUpdateCount += 1

        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.isTail and ent.manePlayer == @ent
                @tailModel = ent
                return ent

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
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateUpperManeModel() if not IsValid(@maneModelUP)
        return @maneModelUP
    CreateLowerManeModelIfNotExists: =>
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateLowerManeModel() if not IsValid(@maneModelLower)
        return @maneModelLower
    CreateTailModelIfNotExists: =>
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateTailModel() if not IsValid(@tailModel)
        return @tailModel

    GetUpperMane: => @maneModelUP or NULL
    GetLowerMane: => @maneModelLower or NULL
    GetTail: => @tailModel or NULL

    MergeModels: (targetEnt = NULL) =>
        return unless @isValid
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
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateUpperManeModelIfNotExists()
        return NULL if not IsValid(@maneModelUP)
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetupper#{modelID}.mdl"
        @maneModelUP\SetModel(model)
        @maneModelUP\SetBodygroup(1, bodygroupID)
        @maneModelUP\SetParent(@ent) if IsValid(@ent)
        @maneModelUP\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
        return @maneModelUP
    UpdateLowerMane: =>
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateLowerManeModelIfNotExists()
        return NULL if not IsValid(@maneModelLower)
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetlower#{modelID}.mdl"
        @maneModelLower\SetModel(model)
        @maneModelLower\SetBodygroup(1, bodygroupID)
        @maneModelLower\SetParent(@ent) if IsValid(@ent)
        @maneModelLower\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
        return @maneModelLower
    UpdateTailModel: =>
        return NULL unless @isValid
        return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateTailModelIfNotExists()
        return NULL if not IsValid(@tailModel)
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_tailset#{modelID}.mdl"
        @tailModel\SetModel(model)
        @tailModel\SetBodygroup(1, bodygroupID)
        @tailModel\SetModelScale(@GetData()\GetTailSize())
        @tailModel\SetParent(@ent) if IsValid(@ent)
        @tailModel\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
        return @tailModel
    
    @FLEX_ID_EYELASHES = 16
    @FLEX_ID_MALE = 25
    @FLEX_ID_BAT_PONY_EARS = 28
    @FLEX_ID_FANGS = 31
    @FLEX_ID_CLAW_TEETH = 30

    ResetBodygroups: =>
        return unless IsValid(@ent)
        @ent\SetFlexWeight(@@FLEX_ID_EYELASHES, 0)
        @ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
        @ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, 0)
        @ent\SetFlexWeight(@@FLEX_ID_FANGS, 0)
        @ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, 0)
        super()
    ApplyBodygroups: =>
        return unless @isValid
        @ResetBodygroups()
        @ent\SetFlexWeight(@@FLEX_ID_EYELASHES,     @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
        @ent\SetFlexWeight(@@FLEX_ID_MALE,          @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0)
        @ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GetData()\GetBatPonyEars() and 1 or 0)
        @ent\SetFlexWeight(@@FLEX_ID_FANGS,         @GetData()\GetFangs() and 1 or 0)
        @ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH,    @GetData()\GetClawTeeth() and 1 or 0)
        @ApplyRace()
        @CreateUpperManeModel()
        @CreateLowerManeModel()
        @CreateTailModel()
        @CreateSocksModelIfNotExists() if @GetData()\GetSocksAsModel()

    DataChanges: (state) =>
        return unless @isValid
        switch state\GetKey()
            when 'EyelashType'
                @ent\SetFlexWeight(@@FLEX_ID_EYELASHES, @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
            when 'Gender'
                @ent\SetFlexWeight(@@FLEX_ID_MALE, @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0)
            when 'BatPonyEars'
                @ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GetData()\GetBatPonyEars() and 1 or 0)
            when 'Fangs'
                @ent\SetFlexWeight(@@FLEX_ID_FANGS, @GetData()\GetFangs() and 1 or 0)
            when 'ClawTeeth'
                @ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, @GetData()\GetClawTeeth() and 1 or 0)
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
    Remove: =>
        @maneModelUP\Remove() if IsValid(@maneModelUP)
        @maneModelLower\Remove() if IsValid(@maneModelLower)
        @tailModel\Remove() if IsValid(@tailModel)
        super()


PPM2.CPPMBodygroupController = CPPMBodygroupController
PPM2.DefaultBodygroupController = DefaultBodygroupController

PPM2.GetBodugroupController = (model = 'models/ppm/player_default_base.mdl') -> DefaultBodygroupController.AVALIABLE_CONTROLLERS[model\lower()] or DefaultBodygroupController
