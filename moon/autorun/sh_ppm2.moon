
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

player_manager.AddValidModel('pony', 'models/ppm/player_default_base_new.mdl')
list.Set('PlayerOptionsModel', 'pony', 'models/ppm/player_default_base_new.mdl')

player_manager.AddValidModel('pony_old', 'models/ppm/player_default_base.mdl')
list.Set('PlayerOptionsModel', 'pony_old', 'models/ppm/player_default_base.mdl')

player_manager.AddValidModel('pony_cppm', 'models/cppm/player_default_base.mdl')
list.Set('PlayerOptionsModel', 'pony_cppm', 'models/cppm/player_default_base.mdl')

player_manager.AddValidModel('ponynj', 'models/ppm/player_default_base_nj.mdl')
list.Set('PlayerOptionsModel', 'ponynj', 'models/ppm/player_default_base_nj.mdl')

player_manager.AddValidModel('ponynj_cppm', 'models/cppm/player_default_base_nj.mdl')
list.Set('PlayerOptionsModel', 'ponynj_cppm', 'models/cppm/player_default_base_nj.mdl')

player_manager.AddValidHands(model, 'models/cppm/pony_arms.mdl', 0, '') for model in *{'pony', 'pony_cppm', 'ponynj', 'ponynj_cppm', 'pony_old'}

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
entMeta.IsPonyCached = =>
    switch @__ppm2_lastmodel
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

include 'autorun/ppm2/common/networked_object.lua'
include 'autorun/ppm2/common/registry.lua'
include 'autorun/ppm2/common/hooks.lua'
include 'autorun/ppm2/common/bodygroup_controller.lua'
include 'autorun/ppm2/common/weight_controller.lua'
include 'autorun/ppm2/common/flex_controller.lua'
include 'autorun/ppm2/common/ponydata.lua'

if CLIENT
    file.CreateDir('ppm2')
    file.CreateDir('ppm2/backups')
    include 'autorun/ppm2/client/data_instance.lua'
    include 'autorun/ppm2/client/texture_controller.lua'
    include 'autorun/ppm2/client/hooks.lua'
    include 'autorun/ppm2/client/render_controller.lua'
    include 'autorun/ppm2/client/editor.lua'

    for ent in *ents.GetAll()
        if ent.isPonyLegsModel
            ent\Remove()
else
    util.AddNetworkString('PPM2.RequestPonyData')
    util.AddNetworkString('PPM2.PlayerRespawn')
    util.AddNetworkString('PPM2.Require')
    util.AddNetworkString('PPM2.EditorStatus')
    util.AddNetworkString('PPM2.DamageAnimation')
    util.AddNetworkString('PPM2.KillAnimation')
    util.AddNetworkString('PPM2.AngerAnimation')
    util.AddNetworkString('PPM2.NotifyDisconnect')

    AddCSLuaFile 'autorun/ppm2/common/networked_object.lua'
    AddCSLuaFile 'autorun/ppm2/common/registry.lua'
    AddCSLuaFile 'autorun/ppm2/common/ponydata.lua'
    AddCSLuaFile 'autorun/ppm2/common/hooks.lua'
    AddCSLuaFile 'autorun/ppm2/common/bodygroup_controller.lua'
    AddCSLuaFile 'autorun/ppm2/common/weight_controller.lua'
    AddCSLuaFile 'autorun/ppm2/common/flex_controller.lua'
    AddCSLuaFile 'autorun/ppm2/client/data_instance.lua'
    AddCSLuaFile 'autorun/ppm2/client/texture_controller.lua'
    AddCSLuaFile 'autorun/ppm2/client/hooks.lua'
    AddCSLuaFile 'autorun/ppm2/client/render_controller.lua'
    AddCSLuaFile 'autorun/ppm2/client/editor.lua'
    include 'autorun/ppm2/server/hooks.lua'
    include 'autorun/ppm2/server/fastdl.lua'

include 'autorun/ppm2/common/vll_loader.lua' if VLL
