
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

export PPM2

player_manager.AddValidModel('ppm2_pony', 'models/ppm/player_default_base.mdl')
list.Set('PlayerOptionsModel', 'ppm2_pony', 'models/ppm/player_default_base.mdl')

player_manager.AddValidModel('ppm2_pony_cppm', 'models/cppm/player_default_base.mdl')
list.Set('PlayerOptionsModel', 'ppm2_pony_cppm', 'models/cppm/player_default_base.mdl')

player_manager.AddValidModel('ppm2_ponynj', 'models/ppm/player_default_base_nj.mdl')
list.Set('PlayerOptionsModel', 'ppm2_ponynj', 'models/ppm/player_default_base_nj.mdl')

player_manager.AddValidModel('ppm2_ponynj_cppm', 'models/cppm/player_default_base_nj.mdl')
list.Set('PlayerOptionsModel', 'ppm2_ponynj_cppm', 'models/cppm/player_default_base_nj.mdl')

player_manager.AddValidModel('ppm2_pony_new', 'models/ppm/player_default_base_new.mdl')
list.Set('PlayerOptionsModel', 'ppm2_pony_new', 'models/ppm/player_default_base_new.mdl')

player_manager.AddValidHands(model, 'models/cppm/pony_arms.mdl', 0, '') for model in *{'ppm2_pony', 'ppm2_pony_cppm', 'ppm2_ponynj', 'ppm2_ponynj_cppm', 'ppm2_pony_new'}

PPM2 = PPM2 or {}

entMeta = FindMetaTable('Entity')
entMeta.IsPony = =>
    switch @GetModel()
        when 'models/ppm/player_default_base.mdl'
            return true
        when 'models/ppm/player_default_base_new.mdl'
            return true
        when 'models/ppm/player_default_base_nj.mdl'
            return true
        when 'models/cppm/player_default_base.mdl'
            return true
        when 'models/cppm/player_default_base_nj.mdl'
            return true
        else
            return false
entMeta.HasPonyModel = entMeta.IsPony

include 'autorun/ppm2/sh_networked_object.lua'
include 'autorun/ppm2/sh_registry.lua'
include 'autorun/ppm2/sh_ponydata.lua'
include 'autorun/ppm2/sh_hooks.lua'
include 'autorun/ppm2/sh_bodygroup_controller.lua'

if CLIENT
    file.CreateDir('ppm2')
    file.CreateDir('ppm2/backups')
    include 'autorun/ppm2/cl_data_instance.lua'
    include 'autorun/ppm2/cl_texture_controller.lua'
    include 'autorun/ppm2/cl_hooks.lua'
    include 'autorun/ppm2/cl_render_controller.lua'
    include 'autorun/ppm2/cl_editor.lua'

    for ent in *ents.GetAll()
        if ent.isPonyLegsModel
            ent\Remove()
else
    util.AddNetworkString('PPM2.RequestPonyData')
    util.AddNetworkString('PPM2.SendManeModel')
    util.AddNetworkString('PPM2.SendManeModelLower')
    util.AddNetworkString('PPM2.SendTailModel')

    AddCSLuaFile 'autorun/ppm2/sh_networked_object.lua'
    AddCSLuaFile 'autorun/ppm2/sh_registry.lua'
    AddCSLuaFile 'autorun/ppm2/sh_ponydata.lua'
    AddCSLuaFile 'autorun/ppm2/sh_hooks.lua'
    AddCSLuaFile 'autorun/ppm2/sh_bodygroup_controller.lua'
    AddCSLuaFile 'autorun/ppm2/cl_data_instance.lua'
    AddCSLuaFile 'autorun/ppm2/cl_texture_controller.lua'
    AddCSLuaFile 'autorun/ppm2/cl_hooks.lua'
    AddCSLuaFile 'autorun/ppm2/cl_render_controller.lua'
    AddCSLuaFile 'autorun/ppm2/cl_editor.lua'
    include 'autorun/ppm2/sv_hooks.lua'
