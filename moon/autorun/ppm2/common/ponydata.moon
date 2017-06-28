
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

for ply in *player.GetAll()
    ply.__PPM2_PonyData\Remove() if ply.__PPM2_PonyData

wUInt = (def = 0, size = 8) ->
    return (arg = def) -> net.WriteUInt(arg, size)

rUInt = (size = 8, min = 0, max = 255) ->
    return -> math.Clamp(net.ReadUInt(size), min, max)

rFloat = (min = 0, max = 255) ->
    return -> math.Clamp(net.ReadFloat(), min, max)

wFloat = net.WriteFloat
rSEnt = net.ReadStrongEntity
wSEnt = net.WriteStrongEntity
rBool = net.ReadBool
wBool = net.WriteBool
rColor = net.ReadColor
wColor = net.WriteColor
rString = net.ReadString
wString = net.WriteString

class NetworkedPonyData extends PPM2.NetworkedObject
    @NW_ClientsideCreation = true
    @RenderTasks = {}

    @Setup()
    @NetworkVar('Entity',           rSEnt, wSEnt, StrongEntity(-1), ((newValue) => IsValid(@GetOwner()) and StrongEntity(@GetOwner()\EntIndex()) or newValue))
    @NetworkVar('UpperManeModel',   rSEnt, wSEnt, StrongEntity(-1), nil, false)
    @NetworkVar('LowerManeModel',   rSEnt, wSEnt, StrongEntity(-1), nil, false)
    @NetworkVar('TailModel',        rSEnt, wSEnt, StrongEntity(-1), nil, false)
    @NetworkVar('SocksModel',       rSEnt, wSEnt, StrongEntity(-1), nil, false)

    @NetworkVar('Race',             rUInt(4, 0, 3), wUInt(PPM2.RACE_EARTH, 4), PPM2.RACE_EARTH)
    @NetworkVar('Gender',           rUInt(4, 0, 1), wUInt(PPM2.GENDER_FEMALE, 4), PPM2.GENDER_FEMALE)
    @NetworkVar('Weight',           rFloat(PPM2.MIN_WEIGHT, PPM2.MAX_WEIGHT), wFloat, 1)
    @NetworkVar('PonySize',         rFloat(PPM2.MIN_SCALE, PPM2.MAX_SCALE),   wFloat, 1)
    @NetworkVar('NeckSize',         rFloat(PPM2.MIN_NECK, PPM2.MAX_NECK),     wFloat, 1)
    @NetworkVar('LegsSize',         rFloat(PPM2.MIN_LEGS, PPM2.MAX_LEGS),     wFloat, 1)

    -- Reserved - they can be accessed/used/changed, but they do not do anything
    @NetworkVar('Age',              rUInt(4, 0, 2), wUInt(PPM2.AGE_ADULT, 4), PPM2.AGE_ADULT)

    @NetworkVar('EyelashType',      rUInt(8, PPM2.MIN_EYELASHES, PPM2.MAX_EYELASHES),           wUInt(0, 8), 0)
    @NetworkVar('TailType',         rUInt(8, PPM2.MIN_TAILS, PPM2.MAX_TAILS),                   wUInt(0, 8), 0)
    @NetworkVar('ManeType',         rUInt(8, PPM2.MIN_UPPER_MANES, PPM2.MAX_UPPER_MANES),       wUInt(0, 8), 0)
    @NetworkVar('ManeTypeLower',    rUInt(8, PPM2.MIN_LOWER_MANES, PPM2.MAX_LOWER_MANES),       wUInt(0, 8), 0)

    @NetworkVar('TailTypeNew',      rUInt(8, PPM2.MIN_TAILS_NEW, PPM2.MAX_TAILS_NEW),               wUInt(0, 8), 0)
    @NetworkVar('ManeTypeNew',      rUInt(8, PPM2.MIN_UPPER_MANES_NEW, PPM2.MAX_UPPER_MANES_NEW),   wUInt(0, 8), 0)
    @NetworkVar('ManeTypeLowerNew', rUInt(8, PPM2.MIN_LOWER_MANES_NEW, PPM2.MAX_LOWER_MANES_NEW),   wUInt(0, 8), 0)

    @NetworkVar('BodyColor',        rColor, wColor, 	    Color(255, 255, 255))

    @NetworkVar('SeparateEyes',     rBool, wBool,              false)
    for publicName in *{'', 'Left', 'Right'}
        @NetworkVar("EyeType#{publicName}",          rUInt(8, PPM2.MIN_EYE_TYPE, PPM2.MAX_EYE_TYPE), wUInt(0, 8), 0)
        @NetworkVar("EyeBackground#{publicName}",    rColor, wColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeHole#{publicName}",          rColor, wColor, 	    Color(0,   0,   0  ))
        @NetworkVar("EyeIrisTop#{publicName}",       rColor, wColor, 	    Color(200, 200, 200))
        @NetworkVar("EyeIrisBottom#{publicName}",    rColor, wColor, 	    Color(200, 200, 200))
        @NetworkVar("EyeIrisLine1#{publicName}",     rColor, wColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeIrisLine2#{publicName}",     rColor, wColor, 	    Color(255, 255, 255))
        @NetworkVar("EyeReflection#{publicName}",    rColor, wColor,    Color(255, 255, 255, 127))
        @NetworkVar("EyeEffect#{publicName}",        rColor, wColor,         Color(255, 255, 255))
        @NetworkVar("EyeLines#{publicName}",         rBool, wBool,                           true)
        @NetworkVar("DerpEyes#{publicName}",         rBool, wBool,                          false)
        @NetworkVar("DerpEyesStrength#{publicName}", rFloat(PPM2.MIN_DERP_STRENGTH, PPM2.MAX_DERP_STRENGTH), wFloat, 1)
        @NetworkVar("HoleWidth#{publicName}",        rFloat(PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE), wFloat,  1)
        @NetworkVar("HoleHeight#{publicName}",       rFloat(PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE), wFloat,  1)
        @NetworkVar("HoleSize#{publicName}",         rFloat(PPM2.MIN_HOLE, PPM2.MAX_HOLE),             wFloat, .8)
        @NetworkVar("HoleShiftX#{publicName}",       rFloat(PPM2.MIN_HOLE_SHIFT, PPM2.MAX_HOLE_SHIFT), wFloat, 0)
        @NetworkVar("HoleShiftY#{publicName}",       rFloat(PPM2.MIN_HOLE_SHIFT, PPM2.MAX_HOLE_SHIFT), wFloat, 0)
        @NetworkVar("IrisSize#{publicName}",         rFloat(PPM2.MIN_IRIS, PPM2.MAX_IRIS),             wFloat, .8)
        @NetworkVar("IrisWidth#{publicName}",        rFloat(PPM2.MIN_IRIS, PPM2.MAX_IRIS),             wFloat, 1)
        @NetworkVar("IrisHeight#{publicName}",       rFloat(PPM2.MIN_IRIS, PPM2.MAX_IRIS),             wFloat, 1)
        @NetworkVar("EyeRotation#{publicName}",      rUInt(12, PPM2.MIN_EYE_ROTATION, PPM2.MAX_EYE_ROTATION), wUInt(0, 12), 0)
        @NetworkVar("EyeURL#{publicName}",           rString,                                                            wString, '')

    @NetworkVar('SeparateMane',     rBool, wBool,              false)
    for i = 1, 6
        @NetworkVar("ManeColor#{i}",            rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("ManeDetailColor#{i}",      rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("ManeURLColor#{i}",         rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("ManeURL#{i}",              rString, wString,   '')

        @NetworkVar("TailColor#{i}",            rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("TailDetailColor#{i}",      rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("TailURLColor#{i}",         rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("TailURL#{i}",              rString, wString,   '')

        @NetworkVar("LowerManeColor#{i}",       rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("LowerManeURL#{i}",         rString, wString,   '')
        @NetworkVar("LowerManeURLColor#{i}",    rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("LowerManeDetailColor#{i}", rColor, wColor,     Color(255, 255, 255))

        @NetworkVar("UpperManeColor#{i}",       rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("UpperManeURL#{i}",         rString, wString,   '')
        @NetworkVar("UpperManeDetailColor#{i}", rColor, wColor,     Color(255, 255, 255))
        @NetworkVar("UpperManeURLColor#{i}",    rColor, wColor,     Color(255, 255, 255))
    
    @NetworkVar('CMark',            rBool, wBool,                    true)
    @NetworkVar('CMarkSize',        rFloat(0, 1), wFloat,            1)
    @NetworkVar('CMarkColor',       rColor, wColor,                  Color(255, 255, 255))
    @NetworkVar('CMarkURL',         rString, wString,                '')
    @NetworkVar('CMarkType',        rUInt(8, PPM2.MIN_CMARK, PPM2.MAX_CMARK),       wUInt(4, 8), 4)
    @NetworkVar('TailSize',         rFloat(PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE), wFloat, 1)

    @NetworkVar('Bodysuit',         rUInt(8, PPM2.MIN_SUIT, PPM2.MAX_SUIT),   wUInt(0, 8), 0)
    @NetworkVar('Socks',            rBool, wBool,              false)
    @NetworkVar('NoFlex',           rBool, wBool,              false)

    @NetworkVar('SocksAsModel',     rBool, wBool,              false)
    @NetworkVar('SocksTexture',     rUInt(8, PPM2.MIN_SOCKS, PPM2.MAX_SOCKS), wUInt(0, 8), 0)
    @NetworkVar('SocksColor',       rColor, wColor,            Color(255, 255, 255))
    @NetworkVar('SocksTextureURL',  rString, wString,          '')
    
    for i = 1, 6
        @NetworkVar('SocksDetailColor' .. i, rColor, wColor, Color(255, 255, 255))

    @NetworkVar('BatPonyEars',      rBool, wBool,              false)
    @NetworkVar('Fangs',            rBool, wBool,              false)
    @NetworkVar('ClawTeeth',        rBool, wBool,              false)

    @NetworkVar('TeethColor',       rColor, wColor,    Color(255, 255, 255))
    @NetworkVar('MouthColor',       rColor, wColor,    Color(219, 65, 155))
    @NetworkVar('TongueColor',      rColor, wColor,    Color(235, 131, 59))

    for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
        @NetworkVar("DisableFlex#{flex}", rBool, wBool, false) if active

    for i = 1, PPM2.MAX_BODY_DETAILS
        @NetworkVar("BodyDetail#{i}",       rUInt(8, PPM2.MIN_DETAIL, PPM2.MAX_DETAIL), wUInt(0, 8), 0)
        @NetworkVar("BodyDetailColor#{i}",  rColor,  wColor, Color(255, 255, 255))
        @NetworkVar("BodyDetailURL#{i}",    rString, wString, '')
        @NetworkVar("BodyDetailURLColor#{i}",  rColor,  wColor, Color(255, 255, 255))
    
    for i = 1, 3
        @NetworkVar("HornURL#{i}",       rString, wString, '')
        @NetworkVar("WingsURL#{i}",      rString, wString, '')
        @NetworkVar("HornURLColor#{i}",  rColor,  wColor, Color(255, 255, 255))
        @NetworkVar("WingsURLColor#{i}", rColor,  wColor, Color(255, 255, 255))
    
    @NetworkVar('Fly',                  rBool,   wBool,                 false)
    @NetworkVar('DisableTask',          rBool,   wBool,                 false)
    @NetworkVar('UseFlexLerp',          rBool,   wBool,                  true)
    @NetworkVar('FlexLerpMultiplier',   net.ReadFloat,  wFloat,                    1)
    @NetworkVar('NewMuzzle',            rBool,   wBool,                  true)
    @NetworkVar('SeparateWings',        rBool,   wBool,                 false)
    @NetworkVar('SeparateHorn',         rBool,   wBool,                 false)
    @NetworkVar('WingsColor',           rColor,  wColor,  Color(255, 255, 255))
    @NetworkVar('HornColor',            rColor,  wColor,  Color(255, 255, 255))

    @NetworkVar('WingsType',            rUInt(8, PPM2.MIN_WINGS, PPM2.MAX_WINGS), wUInt(0, 8), 0)
    @NetworkVar('MaleBuff',             rFloat(PPM2.MIN_MALE_BUFF, PPM2.MAX_MALE_BUFF), wFloat, PPM2.DEFAULT_MALE_BUFF)

    @NetworkVar('BatWingColor',         rColor, wColor,    Color(255, 255, 255))
    @NetworkVar('BatWingSkinColor',     rColor, wColor,    Color(255, 255, 255))

    for i = 1, 3
        @NetworkVar("BatWingURL#{i}",           rString, wString, '')
        @NetworkVar("BatWingSkinURL#{i}",       rString, wString, '')
        @NetworkVar("BatWingURLColor#{i}",      rColor,  wColor, Color(255, 255, 255))
        @NetworkVar("BatWingSkinURLColor#{i}",  rColor,  wColor, Color(255, 255, 255))
    
    Clone: (target = @ent) =>
        copy = @@(nil, target)
        @ApplyDataToObject(copy)
        return copy

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
        if ent.__PPM2_PonyData
            return if ent.__PPM2_PonyData\GetOwner() and IsValid(ent.__PPM2_PonyData\GetOwner()) and StrongEntity(ent.__PPM2_PonyData\GetOwner()) ~= StrongEntity(@GetOwner())
            ent.__PPM2_PonyData\Remove() if ent.__PPM2_PonyData.Remove and ent.__PPM2_PonyData ~= @
        ent.__PPM2_PonyData = @
        @ent = ent
        return unless IsValid(ent)
        @modelCached = ent\GetModel()
        @ent = ent
        @flightController = PPM2.PonyflyController(@)
        @entID = ent\EntIndex()
        @ModelChanges(@modelCached, @modelCached)
        @Reset()
        if CLIENT
            timer.Simple 0, ->
                @GetRenderController()\CompileTextures() if @GetRenderController()
        PPM2.DebugPrint('Ponydata ', @, ' was updated to use for ', @ent)
        @@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]
    ModelChanges: (old = @ent\GetModel(), new = old) =>
        @modelCached = new
        @SetFly(false) if SERVER
        timer.Simple 0.5, ->
            return unless IsValid(@ent)
            @Reset()
    GenericDataChange: (state) =>
        if state\GetKey() == 'Entity' and IsValid(@GetEntity())
            @SetupEntity(@GetEntity())
        
        if state\GetKey() == 'Fly' and @flightController
            @flightController\Switch(state\GetValue())
        
        if state\GetKey() == 'DisableTask'
            @@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]
        
        @GetSizeController()\DataChanges(state) if @ent and @GetBodygroupController()
        @GetBodygroupController()\DataChanges(state) if @ent and @GetBodygroupController()

        if CLIENT and @ent
            @GetWeightController()\DataChanges(state) if @GetWeightController()
            @GetRenderController()\DataChanges(state) if @GetRenderController()

    ResetScale: =>
        if scale = @GetSizeController()
            scale\ResetScale()

    ModifyScale: =>
        if scale = @GetSizeController()
            scale\ModifyScale()

    Reset: =>
        if scale = @GetSizeController()
            scale\Reset()
        if CLIENT
            @GetWeightController()\Reset() if @GetWeightController().Reset
            @GetRenderController()\Reset() if @GetRenderController().Reset
            @GetBodygroupController()\Reset() if @GetBodygroupController().Reset
    PlayerRespawn: =>
        return if not IsValid(@ent)
        @ent.__cachedIsPony = @ent\IsPony()
        if not @ent.__cachedIsPony
            return if @alreadyCalledRespawn
            @alreadyCalledRespawn = true
            @alreadyCalledDeath = true
        else
            @alreadyCalledRespawn = false
            @alreadyCalledDeath = false
        @ApplyBodygroups(CLIENT)
        @SetFly(false) if SERVER

        if scale = @GetSizeController()
            scale\PlayerRespawn()

        if CLIENT
            @deathRagdollMerged = false
            @GetWeightController()\UpdateWeight() if @GetWeightController()
            @GetRenderController()\PlayerRespawn() if @GetRenderController()
            @GetBodygroupController()\MergeModels(@ent) if IsValid(@ent) and @GetBodygroupController().MergeModels
    
    PlayerDeath: =>
        return if not IsValid(@ent)
        @ent.__cachedIsPony = @ent\IsPony()
        if not @ent.__cachedIsPony
            return if @alreadyCalledDeath
            @alreadyCalledDeath = true
        else
            @alreadyCalledDeath = false
        @SetFly(false) if SERVER

        if scale = @GetSizeController()
            scale\PlayerDeath()

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
    SlowUpdate: =>
        @GetBodygroupController()\SlowUpdate() if @GetBodygroupController()
        if scale = @GetSizeController()
            scale\SlowUpdate()
    
    GetFlightController: => @flightController
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
    GetSizeController: =>
        return @scaleController if not @isValid
        if not @scaleController or @modelCached ~= @modelScale
            @modelCached = @modelCached or @ent\GetModel()
            @modelScale = @modelCached
            cls = PPM2.GetSizeController(@modelCached)
            if @scaleController and cls == @scaleController.__class
                @scaleController.ent = @ent
                PPM2.DebugPrint('Skipping size controller recreation for ', @ent, ' as part of ', @)
                return @scaleController
            @scaleController\Remove() if @scaleController
            @scaleController = cls(@)
        @scaleController.ent = @ent
        return @scaleController
    GetScaleController: => @GetSizeController()
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
            if IsValid(@ent) and @ent.__ppm2_task_hit
                @ent.__ppm2_task_hit = false
                @ent\SetNoDraw(false)
        @GetBodygroupController()\Remove() if @GetBodygroupController()
        @GetSizeController()\Remove() if @GetSizeController()
        @flightController\Switch(false) if @flightController
        @@RenderTasks = [task for i, task in pairs @@NW_Objects when task\IsValid() and IsValid(task.ent) and not task.ent\IsPlayer() and not task\GetDisableTask()]
    __tostring: => "[#{@@__name}:#{@netID}|#{@ent}]"

PPM2.NetworkedPonyData = NetworkedPonyData

if CLIENT
    net.Receive 'PPM2.NotifyDisconnect', ->
        netID = net.ReadUInt(16)
        data = NetworkedPonyData.NW_Objects[netID]
        return if not data
        data\Remove()
    
    net.Receive 'PPM2.PonyDataRemove', ->
        netID = net.ReadUInt(16)
        data = NetworkedPonyData.NW_Objects[netID]
        return if not data
        data\Remove()

	hook.Add 'StrongEntityLinkUpdates', 'PPM2.NetworkedObjectCheck', =>
		if @__PPM2_PonyData
            @__PPM2_PonyData\SetEntity(@GetEntity())
            @__PPM2_PonyData\SetupEntity(@)
else
    hook.Add 'PlayerJoinTeam', 'PPM2.TeamWaypoint', (ply, new) ->
        ply.__ppm2_modified_jump = false
    hook.Add 'OnPlayerChangedTeam', 'PPM2.TeamWaypoint', (ply, old, new) ->
        ply.__ppm2_modified_jump = false

entMeta = FindMetaTable('Entity')
entMeta.GetPonyData = =>
    if @__PPM2_PonyData and StrongEntity(@__PPM2_PonyData\GetEntity()) ~= StrongEntity(@)
        @__PPM2_PonyData\SetEntity(@)
        @__PPM2_PonyData\SetupEntity(@) if CLIENT
    return @__PPM2_PonyData
