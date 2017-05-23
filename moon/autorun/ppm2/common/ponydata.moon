
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

PPM2.TransformNewModelID = (id = 0) ->
    bgID = id % 17
    maneModelID = math.floor(id / 16 - .01) + 1
    maneModelID = 1 if maneModelID == 0
    return maneModelID, bgID

do
    ply.__PPM2_PonyData = nil for ply in *player.GetAll()
    randomColor = (a = 255) -> Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), a)
    PPM2.Randomize = (object, ...) ->
        mane, manelower, tail = math.random(PPM2.MIN_UPPER_MANES_NEW, PPM2.MAX_UPPER_MANES_NEW), math.random(PPM2.MIN_LOWER_MANES_NEW, PPM2.MAX_LOWER_MANES_NEW), math.random(PPM2.MIN_TAILS_NEW, PPM2.MAX_TAILS_NEW)
        irisSize = math.random(PPM2.MIN_IRIS * 10, PPM2.MAX_IRIS * 10) / 10
        with object
            \SetGender(math.random(0, 1), ...)
            \SetRace(math.random(0, 3), ...)
            \SetWeight(math.random(PPM2.MIN_WEIGHT * 10, PPM2.MAX_WEIGHT * 10) / 10, ...)
            \SetTailType(tail, ...)
            \SetTailTypeNew(tail, ...)
            \SetManeType(mane, ...)
            \SetManeTypeLower(manelower, ...)
            \SetManeTypeNew(mane, ...)
            \SetManeTypeLowerNew(manelower, ...)
            \SetBodyColor(randomColor(), ...)
            \SetEyeIrisTop(randomColor(), ...)
            \SetEyeIrisBottom(randomColor(), ...)
            \SetEyeIrisLine1(randomColor(), ...)
            \SetEyeIrisLine2(randomColor(), ...)
            \SetIrisSize(irisSize, ...)
            \SetManeColor1(randomColor(), ...)
            \SetManeColor2(randomColor(), ...)
            \SetManeDetailColor1(randomColor(), ...)
            \SetManeDetailColor2(randomColor(), ...)
            \SetUpperManeColor1(randomColor(), ...)
            \SetUpperManeColor2(randomColor(), ...)
            \SetUpperManeDetailColor1(randomColor(), ...)
            \SetUpperManeDetailColor2(randomColor(), ...)
            \SetLowerManeColor1(randomColor(), ...)
            \SetLowerManeColor2(randomColor(), ...)
            \SetLowerManeDetailColor1(randomColor(), ...)
            \SetLowerManeDetailColor2(randomColor(), ...)
            \SetTailColor1(randomColor(), ...)
            \SetTailColor2(randomColor(), ...)
            \SetTailDetailColor1(randomColor(), ...)
            \SetTailDetailColor2(randomColor(), ...)
            \SetSocksAsModel(math.random(1, 2) == 1, ...)
            \SetSocksColor(randomColor(), ...)
        return object

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
        @NetworkVar("HoleWidth#{publicName}",        (-> math.Clamp(net.ReadFloat(), PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)), net.WriteFloat, 1)
        @NetworkVar("HoleSize#{publicName}",         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_HOLE, PPM2.MAX_HOLE)),             net.WriteFloat, .8)
        @NetworkVar("IrisSize#{publicName}",         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_IRIS, PPM2.MAX_IRIS)),             net.WriteFloat, .8)

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

    for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
        @NetworkVar("DisableFlex#{flex}", net.ReadBool, net.WriteBool, false) if active

    for i = 1, PPM2.MAX_BODY_DETAILS
        @NetworkVar("BodyDetail#{i}",       (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_DETAIL, PPM2.MAX_DETAIL)), ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
        @NetworkVar("BodyDetailColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))
        @NetworkVar("BodyDetailURL#{i}",    net.ReadString, net.WriteString, '')
        @NetworkVar("BodyDetailURLColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))

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
        if CLIENT
            timer.Simple 0, ->
                @GetRenderController()\CompileTextures() if @GetRenderController()
    ModelChanges: (old = @ent\GetModel(), new = old) =>
        @modelCached = new
        timer.Simple 0.5, ->
            return unless IsValid(@ent)
            @GetBodygroupController()\ApplyBodygroups() if @GetBodygroupController()
            if CLIENT
                @GetRenderController()
                @GetWeightController()
    GenericDataChange: (state) =>
        if state\GetKey() == 'Entity' and IsValid(@GetEntity())
            @SetupEntity(@GetEntity())
        
        @GetBodygroupController()\DataChanges(state) if @ent and @GetBodygroupController()

        if CLIENT and @ent
            @GetWeightController()\DataChanges(state) if @GetWeightController()
            @GetRenderController()\DataChanges(state) if @GetRenderController()
    PlayerRespawn: =>
        if CLIENT
            @GetWeightController()\UpdateWeight() if @GetWeightController()
            @GetRenderController()\PlayerRespawn() if @GetRenderController()
    ApplyBodygroups: => @GetBodygroupController()\ApplyBodygroups() if @ent
    SetLocalChange: (state) => @GenericDataChange(state)
    NetworkDataChanges: (state) => @GenericDataChange(state)

    SlowUpdate: =>
        @GetBodygroupController()\SlowUpdate() if @GetBodygroupController()
    
    GetRenderController: =>
        return if SERVER
        return @renderController if not @isValid
        if not @renderController or @modelCached ~= @modelRender
            @modelRender = @modelCached
            cls = PPM2.GetRenderController(@modelCached)
            if @renderController and cls == @renderController.__class
                @renderController.ent = @ent
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
            @GetWeightController()\Remove()
            @GetRenderController()\Remove()
        @GetBodygroupController()\Remove()
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
