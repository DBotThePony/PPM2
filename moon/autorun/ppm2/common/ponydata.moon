
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

ply.__PPM2_PonyData = nil for ply in *player.GetAll()

class NetworkedPonyData extends PPM2.NetworkedObject
    @NW_ClientsideCreation = true

    @Setup()
    @NetworkVar('Entity',           net.ReadEntity, net.WriteEntity, NULL)
    @NetworkVar('UpperManeModel',   net.ReadEntity, net.WriteEntity, NULL)
    @NetworkVar('LowerManeModel',   net.ReadEntity, net.WriteEntity, NULL)
    @NetworkVar('TailModel',        net.ReadEntity, net.WriteEntity, NULL)
    @NetworkVar('SocksModel',       net.ReadEntity, net.WriteEntity, NULL)

    @NetworkVar('Race',             (-> math.Clamp(net.ReadUInt(4), 0, 3)), ((arg = PPM2.RACE_EARTH) -> net.WriteUInt(arg, 4)), PPM2.RACE_EARTH)
    @NetworkVar('Gender',           (-> math.Clamp(net.ReadUInt(4), 0, 1)), ((arg = PPM2.GENDER_FEMALE) -> net.WriteUInt(arg, 4)), PPM2.GENDER_FEMALE)
    @NetworkVar('Weight',           (-> math.Clamp(net.ReadFloat(), PPM2.MIN_WEIGHT, PPM2.MAX_WEIGHT)), net.WriteFloat, 1)

    -- Reserved - they can be accessed/used/changed, but they do not do anything
    @NetworkVar('Age',              (-> math.Clamp(net.ReadUInt(4), 0, 2)), ((arg = PPM2.AGE_ADULT) -> net.WriteUInt(arg, 4)), PPM2.AGE_ADULT)

    @NetworkVar('EyelashType',      (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_EYELASHES, PPM2.MAX_EYELASHES)),           ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('TailType',         (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_TAILS, PPM2.MAX_TAILS)),                   ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('ManeType',         (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_UPPER_MANES, PPM2.MAX_UPPER_MANES)),       ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('ManeTypeLower',    (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_LOWER_MANES, PPM2.MAX_LOWER_MANES)),       ((arg = 0) -> net.WriteUInt(arg, 8)), 0)

    @NetworkVar('TailTypeNew',      (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_TAILS_NEW, PPM2.MAX_TAILS_NEW)),               ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('ManeTypeNew',      (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_UPPER_MANES_NEW, PPM2.MAX_UPPER_MANES_NEW)),   ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('ManeTypeLowerNew', (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_LOWER_MANES_NEW, PPM2.MAX_LOWER_MANES_NEW)),   ((arg = 0) -> net.WriteUInt(arg, 8)), 0)

    @NetworkVar('BodyColor',        net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))

    @NetworkVar('SeparateEyes',     net.ReadBool, net.WriteBool,              false)
    for publicName in *{'', 'Left', 'Right'}
        @NetworkVar("EyeType#{publicName}",          (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_EYE_TYPE, PPM2.MAX_EYE_TYPE)), ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
        @NetworkVar("EyeBackground#{publicName}",    net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeHole#{publicName}",          net.ReadColor, net.WriteColor, 	    Color(0,   0,   0  ))
        @NetworkVar("EyeIrisTop#{publicName}",       net.ReadColor, net.WriteColor, 	    Color(200, 200, 200))
        @NetworkVar("EyeIrisBottom#{publicName}",    net.ReadColor, net.WriteColor, 	    Color(200, 200, 200))
        @NetworkVar("EyeIrisLine1#{publicName}",     net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeIrisLine2#{publicName}",     net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeReflection#{publicName}",    net.ReadColor, net.WriteColor,    Color(255, 255, 255, 127))
        @NetworkVar("EyeEffect#{publicName}",        net.ReadColor, net.WriteColor,         Color(255, 255, 255))
        @NetworkVar("EyeLines#{publicName}",         net.ReadBool, net.WriteBool,                           true)
        @NetworkVar("DerpEyes#{publicName}",         net.ReadBool, net.WriteBool,                          false)
        @NetworkVar("DerpEyesStrength#{publicName}", (-> math.Clamp(net.ReadFloat(), PPM2.MIN_DERP_STRENGTH, PPM2.MAX_DERP_STRENGTH)), net.WriteFloat, 1)
        @NetworkVar("HoleWidth#{publicName}",        (-> math.Clamp(net.ReadFloat(), PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)), net.WriteFloat,  1)
        @NetworkVar("HoleSize#{publicName}",         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_HOLE, PPM2.MAX_HOLE)),             net.WriteFloat, .8)
        @NetworkVar("IrisSize#{publicName}",         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_IRIS, PPM2.MAX_IRIS)),             net.WriteFloat, .8)
        @NetworkVar("EyeURL#{publicName}",           net.ReadString,                                                            net.WriteString, '')

    @NetworkVar('SeparateMane',     net.ReadBool, net.WriteBool,              false)
    for i = 1, 6
        @NetworkVar("ManeColor#{i}",            net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("ManeDetailColor#{i}",      net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("ManeURLColor#{i}",         net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("ManeURL#{i}",              net.ReadString, net.WriteString,   '')

        @NetworkVar("TailColor#{i}",            net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("TailDetailColor#{i}",      net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("TailURLColor#{i}",         net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("TailURL#{i}",              net.ReadString, net.WriteString,   '')

        @NetworkVar("LowerManeColor#{i}",       net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("LowerManeURL#{i}",         net.ReadString, net.WriteString,   '')
        @NetworkVar("LowerManeURLColor#{i}",    net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("LowerManeDetailColor#{i}", net.ReadColor, net.WriteColor,     Color(255, 255, 255))

        @NetworkVar("UpperManeColor#{i}",       net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("UpperManeURL#{i}",         net.ReadString, net.WriteString,   '')
        @NetworkVar("UpperManeDetailColor#{i}", net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("UpperManeURLColor#{i}",    net.ReadColor, net.WriteColor,     Color(255, 255, 255))
    
    @NetworkVar('CMark',            net.ReadBool, net.WriteBool,              true)
    @NetworkVar('CMarkSize',        (-> math.Clamp(net.ReadFloat(), 0, 1)), net.WriteFloat, 1)
    @NetworkVar('CMarkColor',       net.ReadColor, net.WriteColor,     Color(255, 255, 255))
    @NetworkVar('CMarkURL',         net.ReadString, net.WriteString,            '')
    @NetworkVar('CMarkType',        (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_CMARK, PPM2.MAX_CMARK)),           ((arg = 4) -> net.WriteUInt(arg, 8)), 4)
    @NetworkVar('TailSize',         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE)),   net.WriteFloat, 1)

    @NetworkVar('Bodysuit',         (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_SUIT, PPM2.MAX_SUIT)),             ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('Socks',            net.ReadBool, net.WriteBool,              false)
    @NetworkVar('NoFlex',           net.ReadBool, net.WriteBool,              false)
    @NetworkVar('SocksAsModel',     net.ReadBool, net.WriteBool,              false)
    @NetworkVar('SocksColor',       net.ReadColor, net.WriteColor,            Color(255, 255, 255))

    @NetworkVar('BatPonyEars',      net.ReadBool, net.WriteBool,              false)
    @NetworkVar('Fangs',            net.ReadBool, net.WriteBool,              false)
    @NetworkVar('ClawTeeth',        net.ReadBool, net.WriteBool,              false)

    @NetworkVar('TeethColor',       net.ReadColor, net.WriteColor,    Color(255, 255, 255))
    @NetworkVar('MouthColor',       net.ReadColor, net.WriteColor,    Color(219, 65, 155))
    @NetworkVar('TongueColor',      net.ReadColor, net.WriteColor,    Color(235, 131, 59))

    for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
        @NetworkVar("DisableFlex#{flex}", net.ReadBool, net.WriteBool, false) if active

    for i = 1, PPM2.MAX_BODY_DETAILS
        @NetworkVar("BodyDetail#{i}",       (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_DETAIL, PPM2.MAX_DETAIL)), ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
        @NetworkVar("BodyDetailColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))
        @NetworkVar("BodyDetailURL#{i}",    net.ReadString, net.WriteString, '')
        @NetworkVar("BodyDetailURLColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))
    
    for i = 1, 3
        @NetworkVar("HornURL#{i}",       net.ReadString, net.WriteString, '')
        @NetworkVar("WingsURL#{i}",      net.ReadString, net.WriteString, '')
        @NetworkVar("HornURLColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))
        @NetworkVar("WingsURLColor#{i}", net.ReadColor,  net.WriteColor, Color(255, 255, 255))
    
    @NetworkVar('NewMuzzle',            net.ReadBool,   net.WriteBool,                  true)
    @NetworkVar('PAC3Bones',            net.ReadBool,   net.WriteBool,                  true)
    @NetworkVar('SeparateWings',        net.ReadBool,   net.WriteBool,                  false)
    @NetworkVar('SeparateHorn',         net.ReadBool,   net.WriteBool,                  false)
    @NetworkVar('WingsColor',           net.ReadColor,  net.WriteColor,  Color(255, 255, 255))
    @NetworkVar('HornColor',            net.ReadColor,  net.WriteColor,  Color(255, 255, 255))

    @NetworkVar('WingsType',            (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_WINGS, PPM2.MAX_WINGS)), ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('MaleBuff',             (-> math.Clamp(net.ReadFloat(), PPM2.MIN_MALE_BUFF, PPM2.MAX_MALE_BUFF)), net.WriteFloat, PPM2.DEFAULT_MALE_BUFF)

    @NetworkVar('BatWingColor',         net.ReadColor, net.WriteColor,    Color(255, 255, 255))
    @NetworkVar('BatWingSkinColor',     net.ReadColor, net.WriteColor,    Color(255, 255, 255))

    for i = 1, 3
        @NetworkVar("BatWingURL#{i}",           net.ReadString, net.WriteString, '')
        @NetworkVar("BatWingSkinURL#{i}",       net.ReadString, net.WriteString, '')
        @NetworkVar("BatWingURLColor#{i}",      net.ReadColor,  net.WriteColor, Color(255, 255, 255))
        @NetworkVar("BatWingSkinURLColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))

    new: (netID, ent) =>
        @recomputeTextures = true
        @isValid = true
        if ent
            @modelCached = ent\GetModel()
            @SetEntity(ent)
            @SetupEntity(ent)
        super(netID)
    IsValid: => @isValid
    GetModel: => @modelCached
    EntIndex: => @entID
    SetupEntity: (ent) =>
        return unless IsValid(ent)
        @modelCached = ent\GetModel()
        @ent = ent
        ent.__PPM2_PonyData\Remove() if ent.__PPM2_PonyData and ent.__PPM2_PonyData.Remove and ent.__PPM2_PonyData ~= @
        ent.__PPM2_PonyData = @
        @entID = ent\EntIndex()
        @ModelChanges(@modelCached, @modelCached)
        @Reset()
        if CLIENT
            timer.Simple 0, ->
                @GetRenderController()\CompileTextures() if @GetRenderController()
        PPM2.DebugPrint('Ponydata ', @, ' was updated to use for ', @ent)
    ModelChanges: (old = @ent\GetModel(), new = old) =>
        @modelCached = new
        timer.Simple 0.5, ->
            return unless IsValid(@ent)
            @GetBodygroupController()\ApplyBodygroups(CLIENT) if @GetBodygroupController()
            if CLIENT
                @GetRenderController()
                @GetWeightController()
            @Reset()
    GenericDataChange: (state) =>
        if state\GetKey() == 'Entity' and IsValid(@GetEntity())
            @SetupEntity(@GetEntity())
        
        @GetBodygroupController()\DataChanges(state) if @ent and @GetBodygroupController()

        if CLIENT and @ent
            @GetWeightController()\DataChanges(state) if @GetWeightController()
            @GetRenderController()\DataChanges(state) if @GetRenderController()
    
    Reset: =>
        if CLIENT
            @GetWeightController()\Reset() if @GetWeightController().Reset
            @GetRenderController()\Reset() if @GetRenderController().Reset
            @GetBodygroupController()\Reset() if @GetBodygroupController().Reset
    PlayerRespawn: =>
        @ent.__cachedIsPony = @ent\IsPony()
        if not @ent.__cachedIsPony
            return if @alreadyCalledRespawn
            @alreadyCalledRespawn = true
            @alreadyCalledDeath = true
        else
            @alreadyCalledRespawn = false
            @alreadyCalledDeath = false
        @ApplyBodygroups(CLIENT)

        if CLIENT
            @deathRagdollMerged = false
            @GetWeightController()\UpdateWeight() if @GetWeightController()
            @GetRenderController()\PlayerRespawn() if @GetRenderController()
            @GetBodygroupController()\MergeModels(@ent) if IsValid(@ent) and @GetBodygroupController().MergeModels
    PlayerDeath: =>
        @ent.__cachedIsPony = @ent\IsPony()
        if not @ent.__cachedIsPony
            return if @alreadyCalledDeath
            @alreadyCalledDeath = true
        else
            @alreadyCalledDeath = false
        if CLIENT
            @DoRagdollMerge()
            @GetRenderController()\PlayerDeath() if @GetRenderController()
    DoRagdollMerge: =>
        return if @deathRagdollMerged
        bgController = @GetBodygroupController()
        rag = @ent\GetRagdollEntity()
        if not bgController.MergeModels
            @deathRagdollMerged = true
        elseif IsValid(rag)
            @deathRagdollMerged = true
            bgController\MergeModels(rag)
    
    ApplyBodygroups: (updateModels = CLIENT) => @GetBodygroupController()\ApplyBodygroups(updateModels) if @ent
    SetLocalChange: (state) => @GenericDataChange(state)
    NetworkDataChanges: (state) => @GenericDataChange(state)
    SlowUpdate: => @GetBodygroupController()\SlowUpdate() if @GetBodygroupController()
    
    GetRenderController: =>
        return if SERVER
        return @renderController if not @isValid
        if not @renderController or @modelCached ~= @modelRender
            @modelRender = @modelCached
            cls = PPM2.GetRenderController(@modelCached)
            if @renderController and cls == @renderController.__class
                @renderController.ent = @ent
                PPM2.DebugPrint('Skipping render controller recreation for ', @ent, ' as part of ', @)
                return @renderController
            @renderController\Remove() if @renderController
            @renderController = cls(@)
        @renderController.ent = @ent
        return @renderController
    GetWeightController: =>
        return if SERVER
        return @weightController if not @isValid
        if not @weightController or @modelCached ~= @modelWeight
            @modelCached = @modelCached or @ent\GetModel()
            @modelWeight = @modelCached
            cls = PPM2.GetPonyWeightController(@modelCached)
            if @weightController and cls == @weightController.__class
                @weightController.ent = @ent
                PPM2.DebugPrint('Skipping weight controller recreation for ', @ent, ' as part of ', @)
                return @weightController
            @weightController\Remove() if @weightController
            @weightController = cls(@)
        @weightController.ent = @ent
        return @weightController
    GetBodygroupController: =>
        return @bodygroups if not @isValid
        if not @bodygroups or @modelBodygroups ~= @modelCached
            @modelCached = @modelCached or @ent\GetModel()
            @modelBodygroups = @modelCached
            cls = PPM2.GetBodygroupController(@modelCached)
            if @bodygroups and cls == @bodygroups.__class
                @bodygroups.ent = @ent
                PPM2.DebugPrint('Skipping bodygroup controller recreation for ', @ent, ' as part of ', @)
                return @bodygroups
            @bodygroups\Remove() if @bodygroups
            @bodygroups = cls(@)
        @bodygroups.ent = @ent
        return @bodygroups
    Remove: (byClient = false) =>
        @@NW_Objects[@netID] = nil if @NETWORKED
        @isValid = false
        @ent = @GetEntity() if not IsValid(@ent)
        @ent.__PPM2_PonyData = nil if IsValid(@ent) and @ent.__PPM2_PonyData == @
        if CLIENT
            @GetWeightController()\Remove() if @GetWeightController()
            @GetRenderController()\Remove() if @GetRenderController()
        @GetBodygroupController()\Remove() if @GetBodygroupController()
    __tostring: => "[#{@@__name}:#{@netID}|#{@ent}]"

PPM2.NetworkedPonyData = NetworkedPonyData

if CLIENT
    net.Receive 'PPM2.NotifyDisconnect', ->
        netID = net.ReadUInt(16)
        data = NetworkedPonyData.NW_Objects[netID]
        return if not data
        data\Remove()

entMeta = FindMetaTable('Entity')
entMeta.GetPonyData = =>
    if @__PPM2_PonyData and @__PPM2_PonyData\GetEntity() ~= @
        @__PPM2_PonyData\SetEntity(@)
        @__PPM2_PonyData\SetupEntity(@) if CLIENT
    return @__PPM2_PonyData
