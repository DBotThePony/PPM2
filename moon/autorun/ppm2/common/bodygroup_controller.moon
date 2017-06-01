
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
        PPM2.DebugPrint('Created new bodygroups controller for ', @ent, ' as part of ', controller, '; internal ID is ', @objID)

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
        return NULL unless @ent\IsPony()
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @socksModel if IsValid(@socksModel)
        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.isSocks and ent.manePlayer == @ent
                @socksModel = ent
                @GetData()\SetSocksModel(@socksModel)
                PPM2.DebugPrint('Resuing ', @socksModel, ' as socks model for ', @ent)
                return ent

        @UpdateCooldowns()
        return NULL if @SocksModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @SocksModelUpdateCount += 1

        model = 'models/props_pony/ppm/cosmetics/ppm_socks.mdl'

        @socksModel = ents.Create('prop_dynamic') if SERVER
        @socksModel = ClientsideModel(model) if CLIENT
        with @socksModel
            .isPonyPropModel = true
            .isSocks = true
            .manePlayer = @ent
            \DrawShadow(true) if CLIENT
            \SetModel(model)
            \SetPos(@ent\EyePos())
            \Spawn()
            \Activate()
            \SetNoDraw(true) if CLIENT
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        PPM2.DebugPrint('Creating new socks model for ', @ent, ' as ', @socksModel)

        if SERVER
            timer.Simple .5, ->
                return unless @isValid
                return unless IsValid(@socksModel)
                @GetData()\SetSocksModel(@socksModel)
                @ent\SetNWEntity('PPM2.SocksModel', @socksModel) if IsValid(@ent)
        else
            @GetData()\SetSocksModel(@socksModel)

        return @socksModel
    CreateSocksModelIfNotExists: =>
        return NULL unless @isValid
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateSocksModel() if not IsValid(@socksModel)
        return NULL if not IsValid(@socksModel)
        @socksModel\SetParent(@ent) if IsValid(@ent)
        @socksModel\Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
        @GetData()\SetSocksModel(@socksModel)
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
        return unless IsValid(@ent)
        return unless @ent\GetBodyGroups()
        for grp in *@ent\GetBodyGroups()
            @ent\SetBodygroup(grp.id, 0)
    Reset: => @ResetBodygroups()
    RemoveModels: =>
        @socksModel\Remove() if IsValid(@socksModel)
    SlowUpdate: (createModels = CLIENT) =>
        return if not @ent\IsPony()
        @ent\SetBodygroup(@@BODYGROUP_MANE_UPPER, @GetData()\GetManeType())
        @ent\SetBodygroup(@@BODYGROUP_MANE_LOWER, @GetData()\GetManeTypeLower())
        @ent\SetBodygroup(@@BODYGROUP_TAIL, @GetData()\GetTailType())
        @ent\SetBodygroup(@@BODYGROUP_EYELASH, @GetData()\GetEyelashType())
        @ent\SetBodygroup(@@BODYGROUP_GENDER, @GetData()\GetGender())
        @ApplyRace()
        @CreateSocksModelIfNotExists() if createModels and @GetData()\GetSocksAsModel()
    ApplyBodygroups: (createModels = CLIENT) =>
        return unless @isValid
        @ResetBodygroups()
        return if not @ent\IsPony()
        @SlowUpdate(createModels)

    Remove: =>
        @RemoveModels()
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
                @ent\SetBodygroup(@@BODYGROUP_HORN, 2)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, 3)

--
-- 0	LrigPelvis
-- 1	Lrig_LEG_BL_Femur
-- 2	Lrig_LEG_BL_Tibia
-- 3	Lrig_LEG_BL_LargeCannon
-- 4	Lrig_LEG_BL_PhalanxPrima
-- 5	Lrig_LEG_BL_RearHoof
-- 6	Lrig_LEG_BR_Femur
-- 7	Lrig_LEG_BR_Tibia
-- 8	Lrig_LEG_BR_LargeCannon
-- 9	Lrig_LEG_BR_PhalanxPrima
-- 10	Lrig_LEG_BR_RearHoof
-- 11	LrigSpine1
-- 12	LrigSpine2
-- 13	LrigRibcage
-- 14	Lrig_LEG_FL_Scapula
-- 15	Lrig_LEG_FL_Humerus
-- 16	Lrig_LEG_FL_Radius
-- 17	Lrig_LEG_FL_Metacarpus
-- 18	Lrig_LEG_FL_PhalangesManus
-- 19	Lrig_LEG_FL_FrontHoof
-- 20	Lrig_LEG_FR_Scapula
-- 21	Lrig_LEG_FR_Humerus
-- 22	Lrig_LEG_FR_Radius
-- 23	Lrig_LEG_FR_Metacarpus
-- 24	Lrig_LEG_FR_PhalangesManus
-- 25	Lrig_LEG_FR_FrontHoof
-- 26	LrigNeck1
-- 27	LrigNeck2
-- 28	LrigNeck3
-- 29	LrigScull
-- 30	Jaw
-- 31	Ear_L
-- 32	Ear_R
-- 33	Mane02
-- 34	Mane03
-- 35	Mane03_tip
-- 36	Mane04
-- 37	Mane05
-- 38	Mane06
-- 39	Mane07
-- 40	Mane01
-- 41	Lrigweaponbone
-- 42	Tail01
-- 43	Tail02
-- 44	Tail03
--

class NewBodygroupController extends DefaultBodygroupController
    @MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

    @BODYGROUP_SKELETON = 0
    @BODYGROUP_GENDER = -1
    @BODYGROUP_HORN = 1
    @BODYGROUP_WINGS = 2

    @BONE_TAIL_1 = 42
    @BONE_TAIL_2 = 43
    @BONE_TAIL_3 = 44

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
        if @UpperManeModelUpdateCooldown < rTime
            @UpperManeModelUpdateCooldown = rTime + @@COOLDOWN_TIME
            @UpperManeModelUpdateCount = 0
        if @LowerManeModelUpdateCooldown < rTime
            @LowerManeModelUpdateCooldown = rTime + @@COOLDOWN_TIME
            @LowerManeModelUpdateCount = 0
        if @TailModelUpdateCooldown < rTime
            @TailModelUpdateCooldown = rTime + @@COOLDOWN_TIME
            @TailModelUpdateCount = 0

    CreateUpperManeModel: =>
        return NULL unless @isValid
        return NULL unless @ent\IsPony()
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @maneModelUP if IsValid(@maneModelUP)
        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.upperMane and ent.manePlayer == @ent
                @maneModelUP = ent
                @GetData()\SetUpperManeModel(@maneModelUP)
                PPM2.DebugPrint('Resuing ', @maneModelUP, ' as upper mane model for ', @ent)
                return ent

        @UpdateCooldowns()
        return NULL if @UpperManeModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @UpperManeModelUpdateCount += 1

        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetupper#{modelID}.mdl"

        @maneModelUP = ents.Create('prop_dynamic') if SERVER
        @maneModelUP = ClientsideModel(model) if CLIENT
        with @maneModelUP
            .isPonyPropModel = true
            .upperMane = true
            .manePlayer = @ent
            \DrawShadow(true) if CLIENT
            \SetModel(model)
            \SetPos(@ent\EyePos())
            \Spawn()
            \Activate()
            \SetNoDraw(true) if CLIENT
            \SetBodygroup(1, bodygroupID)
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        PPM2.DebugPrint('Creating new upper mane model for ', @ent, ' as ', @maneModelUP)

        if SERVER
            timer.Simple .5, ->
                return unless @isValid
                return unless IsValid(@maneModelUP)
                @GetData()\SetUpperManeModel(@maneModelUP)
        else
            @GetData()\SetUpperManeModel(@maneModelUP)

        return @maneModelUP
    CreateLowerManeModel: =>
        return NULL unless @isValid
        return NULL unless @ent\IsPony()
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @maneModelLower if IsValid(@maneModelLower)
        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.lowerMane and ent.manePlayer == @ent
                @maneModelLower = ent
                @GetData()\SetLowerManeModel(@maneModelLower)
                PPM2.DebugPrint('Resuing ', @maneModelLower, ' as lower mane model for ', @ent)
                return ent

        @UpdateCooldowns()
        return NULL if @LowerManeModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @LowerManeModelUpdateCount += 1

        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetlower#{modelID}.mdl"

        @maneModelLower = ents.Create('prop_dynamic') if SERVER
        @maneModelLower = ClientsideModel(model) if CLIENT
        with @maneModelLower
            .isPonyPropModel = true
            .lowerMane = true
            .manePlayer = @ent
            \DrawShadow(true) if CLIENT
            \SetModel(model)
            \SetPos(@ent\EyePos())
            \Spawn()
            \Activate()
            \SetBodygroup(1, bodygroupID)
            \SetNoDraw(true) if CLIENT
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        PPM2.DebugPrint('Creating new lower mane model for ', @ent, ' as ', @maneModelLower)

        if SERVER
            timer.Simple .5, ->
                return unless @isValid
                return unless IsValid(@maneModelLower)
                @GetData()\SetLowerManeModel(@maneModelLower)
        else
            @GetData()\SetLowerManeModel(@maneModelLower)

        return @maneModelLower
    CreateTailModel: =>
        return NULL unless @isValid
        return NULL unless @ent\IsPony()
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        return @tailModel if IsValid(@tailModel)
        for ent in *ents.GetAll()
            if ent.isPonyPropModel and ent.isTail and ent.manePlayer == @ent
                @tailModel = ent
                @GetData()\SetTailModel(@tailModel)
                PPM2.DebugPrint('Resuing ', @tailModel, ' as tail model for ', @ent)
                return ent

        @UpdateCooldowns()
        return NULL if @TailModelUpdateCount > @@COOLDOWN_MAX_COUNT
        @TailModelUpdateCount += 1

        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_tailset#{modelID}.mdl"

        @tailModel = ents.Create('prop_dynamic') if SERVER
        @tailModel = ClientsideModel(model) if CLIENT
        with @tailModel
            .isPonyPropModel = true
            .isTail = true
            .manePlayer = @ent
            \DrawShadow(true) if CLIENT
            \SetModel(model)
            \SetPos(@ent\EyePos())
            \Spawn()
            \Activate()
            \SetNoDraw(true) if CLIENT
            \SetBodygroup(1, bodygroupID)
            \SetParent(@ent)
            \Fire('SetParentAttachment', @@ATTACHMENT_EYES_NAME) if SERVER
            \AddEffects(EF_BONEMERGE)
        
        PPM2.DebugPrint('Creating new tail model for ', @ent, ' as ', @tailModel)

        if SERVER
            timer.Simple .5, ->
                return unless @isValid
                return unless IsValid(@tailModel)
                @GetData()\SetTailModel(@tailModel)
                @ent\SetNWEntity('PPM2.TailModel', @tailModel) if IsValid(@ent)
        else
            @GetData()\SetTailModel(@tailModel)

        return @tailModel

    CreateUpperManeModelIfNotExists: =>
        return NULL unless @isValid
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateUpperManeModel() if not IsValid(@maneModelUP)
        @GetData()\SetUpperManeModel(@maneModelUP) if IsValid(@maneModelUP)
        return @maneModelUP
    CreateLowerManeModelIfNotExists: =>
        return NULL unless @isValid
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateLowerManeModel() if not IsValid(@maneModelLower)
        @GetData()\SetLowerManeModel(@maneModelLower) if IsValid(@maneModelLower)
        return @maneModelLower
    CreateTailModelIfNotExists: =>
        return NULL unless @isValid
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateTailModel() if not IsValid(@tailModel)
        @GetData()\SetTailModel(@tailModel) if IsValid(@tailModel)
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
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateUpperManeModelIfNotExists()
        return NULL if not IsValid(@maneModelUP)
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetupper#{modelID}.mdl"
        @maneModelUP\SetModel(model) if model ~= @maneModelUP\GetModel()
        @maneModelUP\SetBodygroup(1, bodygroupID) if @maneModelUP\GetBodygroup(1) ~= bodygroupID
        @maneModelUP\SetParent(@ent) if @maneModelUP\GetParent() ~= @ent and IsValid(@ent)
        @GetData()\SetUpperManeModel(@maneModelUP)
        return @maneModelUP
    UpdateLowerMane: =>
        return NULL unless @isValid
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateLowerManeModelIfNotExists()
        return NULL if not IsValid(@maneModelLower)
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetManeTypeLowerNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_manesetlower#{modelID}.mdl"
        @maneModelLower\SetModel(model) if model ~= @maneModelLower\GetModel()
        @maneModelLower\SetBodygroup(1, bodygroupID) if @maneModelLower\GetBodygroup(1) ~= bodygroupID
        @maneModelLower\SetParent(@ent) if IsValid(@ent)
        @GetData()\SetLowerManeModel(@maneModelLower)
        return @maneModelLower
    UpdateTailModel: =>
        return NULL unless @isValid
        --return NULL if CLIENT and @GetData()\IsGoingToNetwork()
        @CreateTailModelIfNotExists()
        return NULL if not IsValid(@tailModel)
        modelID, bodygroupID = PPM2.TransformNewModelID(@GetData()\GetTailTypeNew())
        modelID = "0" .. modelID if modelID < 10
        model = "models/ppm/hair/ppm_tailset#{modelID}.mdl"
        @tailModel\SetModel(model) if model ~= @tailModel\GetModel()
        @tailModel\SetBodygroup(1, bodygroupID) if @tailModel\GetBodygroup(1) ~= bodygroupID
        @tailModel\SetModelScale(@GetData()\GetTailSize())
        @tailModel\SetParent(@ent) if IsValid(@ent)
        @GetData()\SetTailModel(@tailModel)
        return @tailModel

    @FLEX_ID_EYELASHES = 16
    @FLEX_ID_MALE = 25
    @FLEX_ID_MALE_2 = 35
    @FLEX_ID_MALE_BODY = 36
    @FLEX_ID_BAT_PONY_EARS = 28
    @FLEX_ID_FANGS = 31
    @FLEX_ID_CLAW_TEETH = 30

    ResetBodygroups: =>
        return unless @isValid
        return unless IsValid(@ent)
        @ent\SetFlexWeight(@@FLEX_ID_EYELASHES, 0)
        @ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
        @ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
        @ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, 0)
        @ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, 0)
        @ent\SetFlexWeight(@@FLEX_ID_FANGS, 0)
        @ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, 0)
        if CLIENT
            @ent\ManipulateBoneScale(@@BONE_TAIL_1, Vector(0, 0, 0))
            @ent\ManipulateBoneScale(@@BONE_TAIL_2, Vector(0, 0, 0))
            @ent\ManipulateBoneScale(@@BONE_TAIL_3, Vector(0, 0, 0))
        super()

    SlowUpdate: (createModels = CLIENT) =>
        return if not @ent\IsPony()
        @ent\SetFlexWeight(@@FLEX_ID_EYELASHES,     @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
        maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0

        if @GetData()\GetNewMuzzle()
            @ent\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
            @ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
        else
            @ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
            @ent\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)

        @ent\SetFlexWeight(@@FLEX_ID_MALE_BODY,     maleModifier * @GetData()\GetMaleBuff())
        
        @ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GetData()\GetBatPonyEars() and 1 or 0)
        @ent\SetFlexWeight(@@FLEX_ID_FANGS,         @GetData()\GetFangs() and 1 or 0)
        @ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH,    @GetData()\GetClawTeeth() and 1 or 0)

        if CLIENT
            size = @GetData()\GetTailSize()
            vecTail = Vector(size, size, size)
            @ent\ManipulateBoneScale(@@BONE_TAIL_1, vecTail)
            @ent\ManipulateBoneScale(@@BONE_TAIL_2, vecTail)
            @ent\ManipulateBoneScale(@@BONE_TAIL_3, vecTail)

        @ApplyRace()
        if createModels
            @UpdateUpperMane()
            @UpdateLowerMane()
            @UpdateTailModel()
            @CreateSocksModelIfNotExists() if createModels and @GetData()\GetSocksAsModel()
    RemoveModels: =>
        @maneModelUP\Remove() if IsValid(@maneModelUP)
        @maneModelLower\Remove() if IsValid(@maneModelLower)
        @tailModel\Remove() if IsValid(@tailModel)
        super()
    ApplyBodygroups: (createModels = CLIENT) =>
        return unless @isValid
        @ResetBodygroups()
        return @RemoveModels() if not @ent\IsPony()
        @SlowUpdate(createModels)
    
    ApplyRace: =>
        return unless @isValid
        switch @GetData()\GetRace()
            when PPM2.RACE_EARTH
                @ent\SetBodygroup(@@BODYGROUP_HORN, 1)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS + 1)
            when PPM2.RACE_PEGASUS
                @ent\SetBodygroup(@@BODYGROUP_HORN, 1)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, @GetData()\GetWingsType())
            when PPM2.RACE_UNICORN
                @ent\SetBodygroup(@@BODYGROUP_HORN, 0)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, PPM2.MAX_WINGS + 1)
            when PPM2.RACE_ALICORN
                @ent\SetBodygroup(@@BODYGROUP_HORN, 0)
                @ent\SetBodygroup(@@BODYGROUP_WINGS, @GetData()\GetWingsType())

    DataChanges: (state) =>
        return unless @isValid
        switch state\GetKey()
            when 'EyelashType'
                @ent\SetFlexWeight(@@FLEX_ID_EYELASHES, @GetData()\GetEyelashType() == PPM2.EYELASHES_NONE and 1 or 0)
            when 'Gender'
                maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
                if @GetData()\GetNewMuzzle()
                    @ent\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
                    @ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
                else
                    @ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
                    @ent\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)
                @ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
            when 'NewMuzzle'
                maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
                if @GetData()\GetNewMuzzle()
                    @ent\SetFlexWeight(@@FLEX_ID_MALE_2, maleModifier)
                    @ent\SetFlexWeight(@@FLEX_ID_MALE, 0)
                else
                    @ent\SetFlexWeight(@@FLEX_ID_MALE_2, 0)
                    @ent\SetFlexWeight(@@FLEX_ID_MALE, maleModifier)
                @ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
            when 'BatPonyEars'
                @ent\SetFlexWeight(@@FLEX_ID_BAT_PONY_EARS, @GetData()\GetBatPonyEars() and 1 or 0)
            when 'Fangs'
                @ent\SetFlexWeight(@@FLEX_ID_FANGS, @GetData()\GetFangs() and 1 or 0)
            when 'ClawTeeth'
                @ent\SetFlexWeight(@@FLEX_ID_CLAW_TEETH, @GetData()\GetClawTeeth() and 1 or 0)
            when 'ManeTypeNew'
                @UpdateUpperMane() if CLIENT
            when 'ManeTypeLowerNew'
                @UpdateLowerMane() if CLIENT
            when 'TailTypeNew'
                @UpdateTailModel() if CLIENT
            when 'TailSize'
                @UpdateTailModel() if CLIENT
            when 'Race'
                @ApplyRace()
            when 'WingsType'
                @ApplyRace()
            when 'MaleBuff'
                maleModifier = @GetData()\GetGender() == PPM2.GENDER_MALE and 1 or 0
                @ent\SetFlexWeight(@@FLEX_ID_MALE_BODY, maleModifier * @GetData()\GetMaleBuff())
            when 'TailSize'
                return if SERVER
                size = @GetData()\GetTailSize()
                vecTail = Vector(size, size, size)
                @ent\ManipulateBoneScale(@@BONE_TAIL_1, vecTail)
                @ent\ManipulateBoneScale(@@BONE_TAIL_2, vecTail)
                @ent\ManipulateBoneScale(@@BONE_TAIL_3, vecTail)
            when 'SocksAsModel'
                return if SERVER
                if state\GetValue()
                    @CreateSocksModelIfNotExists()
                else
                    @socksModel\Remove() if IsValid(@socksModel)


PPM2.CPPMBodygroupController = CPPMBodygroupController
PPM2.DefaultBodygroupController = DefaultBodygroupController

PPM2.GetBodygroupController = (model = 'models/ppm/player_default_base.mdl') -> DefaultBodygroupController.AVALIABLE_CONTROLLERS[model\lower()] or DefaultBodygroupController
