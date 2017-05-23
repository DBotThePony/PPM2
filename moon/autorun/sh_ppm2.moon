
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
PPM2 = PPM2 or {}

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

include_ = include
AddCSLuaFile_ = AddCSLuaFile
include = (f) -> include_("autorun/ppm2/#{f}")
AddCSLuaFile = (f) -> AddCSLuaFile_("autorun/ppm2/#{f}")

include 'common/networked_object.lua'
include 'common/registry.lua'
include 'common/functions.lua'
include 'common/hooks.lua'
include 'common/bodygroup_controller.lua'
include 'common/weight_controller.lua'
include 'common/flex_controller.lua'
include 'common/ponydata.lua'
include 'common/emotes.lua'

if CLIENT
    file.CreateDir('ppm2')
    file.CreateDir('ppm2/backups')
    include 'client/data_instance.lua'
    include 'client/texture_controller.lua'
    include 'client/hooks.lua'
    include 'client/render_controller.lua'
    include 'client/editor.lua'
    include 'client/emotes.lua'

    for ent in *ents.GetAll()
        if ent.isPonyLegsModel
            ent\Remove()
else
    util.AddNetworkString('PPM2.RequestPonyData')
    util.AddNetworkString('PPM2.PlayerRespawn')
    util.AddNetworkString('PPM2.Require')
    util.AddNetworkString('PPM2.EditorStatus')
    util.AddNetworkString('PPM2.NotifyDisconnect')

    AddCSLuaFile 'common/networked_object.lua'
    AddCSLuaFile 'common/registry.lua'
    AddCSLuaFile 'common/ponydata.lua'
    AddCSLuaFile 'common/hooks.lua'
    AddCSLuaFile 'common/bodygroup_controller.lua'
    AddCSLuaFile 'common/weight_controller.lua'
    AddCSLuaFile 'common/flex_controller.lua'
    AddCSLuaFile 'common/functions.lua'
    AddCSLuaFile 'common/emotes.lua'
    AddCSLuaFile 'client/data_instance.lua'
    AddCSLuaFile 'client/texture_controller.lua'
    AddCSLuaFile 'client/hooks.lua'
    AddCSLuaFile 'client/render_controller.lua'
    AddCSLuaFile 'client/editor.lua'
    AddCSLuaFile 'client/emotes.lua'
    include 'server/hooks.lua'
    include 'server/fastdl.lua'
    include 'server/emotes.lua'

include 'common/vll_loader.lua' if VLL
