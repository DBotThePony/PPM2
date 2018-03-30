
--
-- Copyright (C) 2017-2018 DBot
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

DLib.manifest({
	name: 'PPM/2'
	prefix: 'ppm2'

	shared: {
		'common/modifier_base.lua'
		'common/sequence_base.lua'
		'common/sequence_holder.lua'
		'common/networked_data.lua'
		'common/controller_children.lua'
		'common/registry.lua'
		'common/functions.lua'
		'common/bodygroup_controller.lua'
		'common/weight_controller.lua'
		'common/pony_expressions_controller.lua'
		'common/emotes.lua'
		'common/flex_controller.lua'
		'common/registry_data.lua'
		'common/ponydata.lua'
		'common/ponyfly.lua'
		'common/size_controller.lua'
		'common/hooks.lua'
	}

	client: {
		'client/bones_modifier.lua'
		'client/data_instance.lua'
		'client/materials_registry.lua'
		'client/texture_controller.lua'
		'client/new_texture_controller.lua'
		'client/hooks.lua'
		'client/functions.lua'
		'client/render_controller.lua'
		'client/emotes.lua'
		'client/player_menu.lua'
		'client/editor.lua'
		'client/rag_edit.lua'
		'client/render.lua'
	}

	server: {
		'server/misc.lua'
		'server/hooks.lua'
		'server/emotes.lua'
		'server/hitgroups.lua'
		'server/rag_edit.lua'
	}
})
