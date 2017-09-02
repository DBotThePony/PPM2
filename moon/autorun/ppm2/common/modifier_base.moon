
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

class PPM2.ModifierBase
	@MODIFIERS = {}
	@Setup: =>
	@__inherited: (child) =>
		child.MODIFIERS = {}
		child\Setup()

	@RegisterModifier: (modifName = 'MyModifier', def = 0, calculateStart = 0) =>
		iName = modifName .. 'Modifiers'
		for data in *@MODIFIERS
			if data.name == modifName
				data.def = def
				return
		table.insert(@MODIFIERS, {name: modifName, :def, :iName})
		@__base['SetModifier' .. modifName] = (modifID, val = 0) =>
			return if not modifID
			return if not @[iName][modifID]
			@[iName][modifID] = val
		@__base['Calculate' .. modifName] = =>
			calc = calculateStart
			calc += modif for modif in *@[iName]
			return calc

	new: =>
		for modif in *@@MODIFIERS
			@[modif.iName] = {}
		@modifiersNames = {}
		@nextModifierID = 0

	GetModifierID: (name = '') =>
		return @modifiersNames[name] if @modifiersNames[name]
		@nextModifierID += 1
		id = @nextModifierID
		@modifiersNames[name] = id
		@[modif.iName][id] = modif.def for modif in *@@MODIFIERS
		return id
	ResetModifiers: (name = '') =>
		return false if not @modifiersNames[name]
		id = @modifiersNames[name]
		@[modif.iName][id] = modif.def for modif in *@@MODIFIERS
		return true
