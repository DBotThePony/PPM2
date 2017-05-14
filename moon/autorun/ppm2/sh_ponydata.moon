
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

PPM2.MIN_WEIGHT = 0.7
PPM2.MAX_WEIGHT = 1.3

PPM2.MIN_TAIL_SIZE = 0.6
PPM2.MAX_TAIL_SIZE = 1.7 -- i luv big tails

PPM2.MIN_IRIS = 0.7
PPM2.MAX_IRIS = 1.3

PPM2.MIN_PUPIL_SIZE = 0.2
PPM2.MAX_PUPIL_SIZE = 1

PPM2.AvaliableTails = {
    'MAILCALL'
    'FLOOFEH'
    'ADVENTUROUS'
    'SHOWBOAT'
    'ASSERTIVE' 
    'BOLD'
    'STUMPY'
    'SPEEDSTER'
    'EDGY'
    'RADICAL' 
    'BOOKWORM'
    'BUMPKIN'
    'POOFEH'
    'CURLY'
    'NONE'
}

PPM2.AvaliableUpperManes = {
    'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT', 'ASSERTIVE'
    'BOLD', 'STUMPY', 'SPEEDSTER', 'RADICAL', 'SPIKED'
    'BOOKWORM', 'BUMPKIN', 'POOFEH', 'CURLY', 'INSTRUCTOR', 'NONE'
}

PPM2.AvaliableLowerManes = {
    'MAILCALL', 'FLOOFEH', 'ADVENTUROUS', 'SHOWBOAT'
    'ASSERTIVE', 'BOLD', 'STUMPY', 'HIPPIE', 'SPEEDSTER'
    'BOOKWORM', 'BUMPKIN', 'CURLY', 'NONE'
}

PPM2.EyelashTypes = {
    'Default', 'Double', 'Coy', 'Full', 'Mess', 'None'
}

PPM2.BodyDetails = {
    'None', 'Leg gradient', 'Lines', 'Stripes', 'Head stripes'
    'Freckles', 'Hooves big', 'Hooves small', 'Head layer'
    'Hooves big rnd', 'Hooves small rnd', 'Spots 1'
}

PPM2.BodyDetailsEnum = {
    'NONE', 'GRADIENT', 'LINES', 'STRIPES', 'HSTRIPES'
    'FRECKLES', 'HOOF_BIG', 'HOOF_SMALL', 'LAYER'
    'HOOF_BIG_ROUND', 'HOOF_SMALL_ROUND', 'SPOTS'
}

PPM2.MIN_EYELASHES = 0
PPM2.MAX_EYELASHES = #PPM2.EyelashTypes - 1

PPM2.MIN_TAILS = 0
PPM2.MAX_TAILS = #PPM2.AvaliableTails - 1

PPM2.MIN_UPPER_MANES = 0
PPM2.MAX_UPPER_MANES = #PPM2.AvaliableUpperManes - 1

PPM2.MIN_LOWER_MANES = 0
PPM2.MAX_LOWER_MANES = #PPM2.AvaliableLowerManes - 1

PPM2.MIN_DETAIL = 0
PPM2.MAX_DETAIL = #PPM2.BodyDetails - 1

PPM2.GENDER_FEMALE = 0
PPM2.GENDER_MALE = 1

PPM2.MAX_BODY_DETAILS = 8

PPM2.RACE_EARTH = 0
PPM2.RACE_PEGASUS = 1
PPM2.RACE_UNICORN = 2
PPM2.RACE_ALICORN = 3

PPM2.AGE_FILLY = 0
PPM2.AGE_ADULT = 1
PPM2.AGE_MATURE = 2

class NetworkedPonyData extends PPM2.NetworkedObject
    @NW_ClientsideCreation = true
    @Setup()
    @NetworkVar('Entity',           net.ReadEntity, net.WriteEntity, NULL)
    @NetworkVar('Race',             (-> math.Clamp(net.ReadUInt(4), 0, 3)), ((arg = PPM2.RACE_EARTH) -> net.WriteUInt(arg, 4)), PPM2.RACE_EARTH)
    @NetworkVar('Gender',           (-> math.Clamp(net.ReadUInt(4), 0, 1)), ((arg = PPM2.GENDER_FEMALE) -> net.WriteUInt(arg, 4)), PPM2.GENDER_FEMALE)
    @NetworkVar('Weight',           (-> math.Clamp(net.ReadFloat(), PPM2.MIN_WEIGHT, PPM2.MAX_WEIGHT)), net.WriteFloat, 1)

    -- Reserved - they can be accessed/used/changed, but they do not do anything
    @NetworkVar('Age',              (-> math.Clamp(net.ReadUInt(4), 0, 2)), ((arg = PPM2.AGE_ADULT) -> net.WriteUInt(arg, 4)), PPM2.AGE_ADULT)

    @NetworkVar('EyelashType',      (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_EYELASHES, PPM2.MAX_EYELASHES)),     ((arg = 0) -> net.WriteUInt(arg, 8)), 0)

    @NetworkVar('TailType',         (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_TAILS, PPM2.MAX_TAILS)),     ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('ManeType',         (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_UPPER_MANES, PPM2.MAX_UPPER_MANES)),     ((arg = 0) -> net.WriteUInt(arg, 8)), 0)
    @NetworkVar('ManeTypeLower',    (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_LOWER_MANES, PPM2.MAX_LOWER_MANES)),     ((arg = 0) -> net.WriteUInt(arg, 8)), 0)

    @NetworkVar('EyeBackground',    net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
    @NetworkVar('EyeHole',          net.ReadColor, net.WriteColor, 	    Color(0,   0,   0  ))
    @NetworkVar('EyeIris1',         net.ReadColor, net.WriteColor, 	    Color(200, 200, 200))
    @NetworkVar('EyeIris2',         net.ReadColor, net.WriteColor, 	    Color(200, 200, 200))
    @NetworkVar('EyeIrisLine1',     net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
    @NetworkVar('EyeIrisLine2',     net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))
    @NetworkVar('BodyColor',        net.ReadColor, net.WriteColor, 	    Color(255, 255, 255))

    for i = 1, 6
        @NetworkVar("ManeColor#{i}",        net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("TailColor#{i}",        net.ReadColor, net.WriteColor,     Color(255, 255, 255))

        -- Reserved - they can be accessed/used/changed, but they do not do anything
        @NetworkVar("LowerManeColor#{i}",        net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        @NetworkVar("UpperManeColor#{i}",        net.ReadColor, net.WriteColor,     Color(255, 255, 255))
        -----
    
    @NetworkVar('EyeLines',         net.ReadBool, net.WriteBool,              true)
    @NetworkVar('IrisSize',         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_IRIS, PPM2.MAX_IRIS)), net.WriteFloat, 1)
    @NetworkVar('EyeWidth',         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_PUPIL_SIZE, PPM2.MAX_PUPIL_SIZE)), net.WriteFloat, 1)
    @NetworkVar('TailSize',         (-> math.Clamp(net.ReadFloat(), PPM2.MIN_TAIL_SIZE, PPM2.MAX_TAIL_SIZE)), net.WriteFloat, 1)

    for i = 1, PPM2.MAX_BODY_DETAILS
        @NetworkVar("BodyDetail#{i}", (-> math.Clamp(net.ReadUInt(8), PPM2.MIN_DETAIL, PPM2.MAX_DETAIL)), ((arg = 0) -> net.WriteUInt(arg, 8)), 0)

    new: (netID, ent) =>
        if ent
            @SetEntity(ent)
            @SetupEntity(ent)
        super(netID)
    EntIndex: => @entID
    SetupEntity: (ent) =>
        return unless IsValid(ent)
        @ent = ent
        ent.__PPM2_PonyData = @
        @entID = ent\EntIndex()
    UpdateTextureController: (key) =>
        return if SERVER
        textureController = @GetTextureController()
        switch key
            when 'BodyColor'
                textureController\CompileBody()
    SetLocalChange: (key) =>
        if CLIENT
            @UpdateTextureController(key)
    NetworkDataChanges: (state) =>
        if state\GetKey() == 'Entity' and IsValid(@GetEntity())
            @SetupEntity(@GetEntity())
        
        if CLIENT
            @UpdateTextureController(state\GetKey())
    GetTextureController: =>
        return if SERVER
        @textureController = PPM2.PonyTextureController(@ent, @) if not @textureController
        return @textureController

PPM2.NetworkedPonyData = NetworkedPonyData

entMeta = FindMetaTable('Entity')
entMeta.GetPonyData = =>
    if @__PPM2_PonyData and @__PPM2_PonyData\GetEntity() ~= @
        @__PPM2_PonyData\SetEntity(@)
        @__PPM2_PonyData\SetupEntity(@) if CLIENT
    return @__PPM2_PonyData
