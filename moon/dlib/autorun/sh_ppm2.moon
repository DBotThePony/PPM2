
--
-- Copyright (C) 2017-2019 DBot

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

shared = (filein) ->
	AddCSLuaFile('ppm2/' .. filein) if SERVER
	include('ppm2/' .. filein)

server = (filein) -> include('ppm2/' .. filein) if SERVER
client = (filein) ->
	AddCSLuaFile('ppm2/' .. filein) if SERVER
	include('ppm2/' .. filein) if CLIENT

shared('common/modifier_base.lua')
shared('common/sequence_base.lua')
shared('common/sequence_holder.lua')
shared('common/controller_children.lua')
shared('common/registry.lua')
shared('common/functions.lua')
shared('common/bodygroup_controller.lua')
shared('common/weight_controller.lua')
shared('common/pony_expressions_controller.lua')
shared('common/emotes.lua')
shared('common/flex_controller.lua')
shared('common/registry_data.lua')
shared('common/ponydata.lua')
shared('common/bones_modifier.lua')
shared('common/ponyfly.lua')
shared('common/size_controller.lua')
shared('common/hooks.lua')
shared('common/hoofsteps.lua')

client('client/data_instance.lua')
client('client/materials_registry.lua')
client('client/texture_controller.lua')
client('client/new_texture_controller.lua')
client('client/hooks.lua')
client('client/functions.lua')
client('client/render_controller.lua')
client('client/emotes.lua')
client('client/player_menu.lua')
client('client/editor.lua')
client('client/editor3.lua')
client('client/rag_edit.lua')
client('client/render.lua')

server('server/misc.lua')
server('server/hooks.lua')
server('server/emotes.lua')
server('server/hitgroups.lua')
server('server/rag_edit.lua')

return nil
