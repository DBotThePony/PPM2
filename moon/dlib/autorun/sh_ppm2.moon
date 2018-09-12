
--
-- Copyright (C) 2017-2018 DBot

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.


export PPM2
PPM2 = PPM2 or {}

DLib.manifest({
	name: 'PPM/2'
	prefix: 'ppm2'

	shared: {
		'common/modifier_base.lua'
		'common/sequence_base.lua'
		'common/sequence_holder.lua'
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
		'common/bones_modifier.lua'
		'common/ponyfly.lua'
		'common/size_controller.lua'
		'common/hooks.lua'
	}

	client: {
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
		'client/editor3.lua'
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
