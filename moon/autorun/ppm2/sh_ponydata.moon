
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
        @NetworkVar("EyeBackground#{publicName}",    net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeHole#{publicName}",          net.ReadColor, net.WriteColor, 	    Color(0,   0,   0  ))
        @NetworkVar("EyeIrisTop#{publicName}",       net.ReadColor, net.WriteColor, 	    Color(200, 200, 200))
        @NetworkVar("EyeIrisBottom#{publicName}",    net.ReadColor, net.WriteColor, 	    Color(200, 200, 200))
        @NetworkVar("EyeIrisLine1#{publicName}",     net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeIrisLine2#{publicName}",     net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
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
        @NetworkVar("TailColor#{i}",            net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("TailDetailColor#{i}",      net.ReadColor, net.WriteColor,     Color(255, 255, 255))

        @NetworkVar("LowerManeColor#{i}",       net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("LowerManeDetailColor#{i}", net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("UpperManeColor#{i}",       net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("UpperManeDetailColor#{i}", net.ReadColor, net.WriteColor,     Color(255, 255, 255))
    
    @NetworkVar('CMark',            net.ReadBool, net.WriteBool,              true)
    @NetworkVar('CMarkURL',         net.ReadString, net.WriteString,            '')
    @NetworkVar('CMarkType',        (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_CMARK, PPM2.MAX_CMARK)),           ((arg = 4) -> net.WriteUInt(arg, 8)), 4)
    @NetworkVar('TailSize',         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE)),   net.WriteFloat, 1)

    @NetworkVar('Bodysuit',         (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_SUIT, PPM2.MAX_SUIT)),             ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('Socks',            net.ReadBool, net.WriteBool,              false)
    @NetworkVar('SocksAsModel',     net.ReadBool, net.WriteBool,              false)
    @NetworkVar('SocksColor',       net.ReadColor, net.WriteColor,            Color(255, 255, 255))

    for i = 1, PPM2.MAX_BODY_DETAILS
        @NetworkVar("BodyDetail#{i}",       (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_DETAIL, PPM2.MAX_DETAIL)), ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
        @NetworkVar("BodyDetailColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))
        @NetworkVar("BodyDetailURL#{i}",    net.ReadString, net.WriteString, '')
        @NetworkVar("BodyDetailURLColor#{i}",  net.ReadColor,  net.WriteColor, Color(255, 255, 255))

    new: (netID, ent) =>
        @recomputeTextures = true
        if ent
            @modelCached = ent\GetModel()
            @SetEntity(ent)
            @SetupEntity(ent)
        super(netID)
    GetModel: => @modelCached
    EntIndex: => @entID
    SetupEntity: (ent) =>
        return unless IsValid(ent)
        @modelCached = ent\GetModel()
        @ent = ent
        ent.__PPM2_PonyData = @
        @entID = ent\EntIndex()
        @ModelChanges(@modelCached, @modelCached)
        if CLIENT
            timer.Simple(0, ->
                @GetRenderController()\CompileTextures()
                @CreateFlexController()
            )
    ModelChanges: (old = @ent\GetModel(), new = old) =>
        @modelCached = new
        timer.Simple 0.5, ->
            return unless IsValid(@ent)
            @GetBodygroupController()\ApplyBodygroups()
            if CLIENT
                @GetRenderController()
                @GetWeightController()
                @CreateFlexController()
    GenericDataChange: (state) =>
        if state\GetKey() == 'Entity' and IsValid(@GetEntity())
            @SetupEntity(@GetEntity())
        
        @GetBodygroupController()\DataChanges(state) if @ent

        if CLIENT and @ent
            @GetWeightController()\DataChanges(state)
            @GetRenderController()\DataChanges(state)
            @flexes\DataChanges(state) if @flexes
    Think: =>
        if CLIENT
            @flexes\Think() if @flexes
    PlayerRespawn: =>
        if CLIENT
            @GetWeightController()\UpdateWeight()
            @flexes\PlayerRespawn() if @flexes
    ApplyBodygroups: => @GetBodygroupController()\ApplyBodygroups() if @ent
    SetLocalChange: (state) => @GenericDataChange(state)
    NetworkDataChanges: (state) => @GenericDataChange(state)
    GetRenderController: =>
        return if SERVER
        if not @renderController or @modelCached ~= @modelRender
            cls = PPM2.GetRenderController(@modelCached)
            @modelRender = @modelCached
            @renderController = cls(@)
        @renderController.ent = @ent
        return @renderController
    GetWeightController: =>
        return if SERVER
        if not @weightController or @modelCached ~= @modelWeight
            cls = PPM2.GetPonyWeightController(@modelCached)
            @modelWeight = @modelCached
            @weightController = cls(@)
        @weightController.ent = @ent
        return @weightController
    GetBodygroupController: =>
        if not @bodygroups or @modelBodygroups ~= @modelCached
            @modelCached = @modelCached or @ent\GetModel()
            cls = PPM2.GetBodugroupController(@modelCached)
            @bodygroups = cls(@)
            @modelBodygroups = @modelCached
        @bodygroups.ent = @ent
        return @bodygroups
    CreateFlexController: =>
        return if not @ent\IsPlayer()
        if not @flexes or @modelFlexes ~= @modelCached
            @modelCached = @modelCached or @ent\GetModel()
            cls = PPM2.GetFlexController(@modelCached)
            return if not cls
            @flexes = cls(@)
            @modelFlexes = @modelCached
        @flexes.ent = @ent
        return @flexes
    GetFlexController: => @flexes

PPM2.NetworkedPonyData = NetworkedPonyData

entMeta = FindMetaTable('Entity')
entMeta.GetPonyData = =>
    if @__PPM2_PonyData and @__PPM2_PonyData\GetEntity() ~= @
        @__PPM2_PonyData\SetEntity(@)
        @__PPM2_PonyData\SetupEntity(@) if CLIENT
    return @__PPM2_PonyData
