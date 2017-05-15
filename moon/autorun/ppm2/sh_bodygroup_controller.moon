
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

PPM2.AvaliableBodygroupControllers = {}

class DefaultBodygroupController
    @MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl'}
    @__inherited: (child) =>
        @MODELS_HASH = {mod, true for mod in *child.MODELS}
        PPM2.AvaliableBodygroupControllers[mod] = child for mod in *child.MODELS
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

    ApplyRace: =>
        switch @controller\GetRace()
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

    ApplyBodygroups: =>
        @ent\SetBodygroup(@@BODYGROUP_MANE_UPPER, @controller\GetManeType())
        @ent\SetBodygroup(@@BODYGROUP_MANE_LOWER, @controller\GetManeTypeLower())
        @ent\SetBodygroup(@@BODYGROUP_TAIL, @controller\GetTailType())
        @ent\SetBodygroup(@@BODYGROUP_EYELASH, @controller\GetEyelashType())
        @ent\SetBodygroup(@@BODYGROUP_GENDER, @controller\GetGender())
        @ApplyRace()
    StateChange: (state) =>
        switch state\GetKey()
            when 'ManeType'
                @ent\SetBodygroup(@@BODYGROUP_MANE_UPPER, @controller\GetManeType())
            when 'ManeTypeLower'
                @ent\SetBodygroup(@@BODYGROUP_MANE_LOWER, @controller\GetManeTypeLower())
            when 'TailType'
                @ent\SetBodygroup(@@BODYGROUP_TAIL, @controller\GetTailType())
            when 'EyelashType'
                @ent\SetBodygroup(@@BODYGROUP_EYELASH, @controller\GetEyelashType())
            when 'Gender'
                @ent\SetBodygroup(@@BODYGROUP_GENDER, @controller\GetGender())
            when 'Race'
                @ApplyRace()

class CPPMBodygroupController extends DefaultBodygroupController
    @MODELS = {'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}

    new: (...) => super(...)

    ApplyRace: =>
        switch @controller\GetRace()
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

PPM2.CPPMBodygroupController = CPPMBodygroupController
PPM2.DefaultBodygroupController = DefaultBodygroupController

PPM2.GetBodugroupController = (model = 'models/ppm/player_default_base.mdl') -> PPM2.AvaliableBodygroupControllers[model\lower()] or DefaultBodygroupController
