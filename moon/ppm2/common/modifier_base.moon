
--
-- Copyright (C) 2017-2020 DBotThePony

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


-- uuuuuuuuugh
Lerp = (byVal, fromValue, intoValue) ->
	delta = intoValue - fromValue
	if delta < 0 and delta > -0.025
		return intoValue
	elseif delta > 0 and delta < 0.025
		return intoValue
	return fromValue + delta * byVal

class PPM2.ModifierBase
	@MODIFIERS = {}
	@SetupModifiers: =>
	@__inherited: (child) =>
		child.MODIFIERS = {}
		child\SetupModifiers()

	@RegisterModifier: (modifName = 'MyModifier', def = 0, calculateStart = 0) =>
		iName = modifName .. 'Modifiers'
		for _, data in ipairs @MODIFIERS
			if data.name == modifName
				data.def = def
				return

		targetTable = {
			name: modifName
			:def, :iName
			clamp: (val) -> val
			clampFinal: (val) -> val
			lerpFunc: Lerp
			:calculateStart
		}

		targetTable.def = (-> def) if type(def) ~= 'function'
		targetTable.calculateStart = (-> calculateStart) if type(calculateStart) ~= 'function'

		table.insert(@MODIFIERS, targetTable)

		@__base['SetModifier' .. modifName] = (modifID, val = 0) =>
			return if not modifID
			return if not @[iName][modifID]
			@[iName][modifID] = targetTable.clamp(val)

		@__base['GetModifier' .. modifName] = (modifID, val = 0) =>
			return if not modifID
			if targetTable.isLerped
				return @[targetTable.iNameLerp][modifID]
			else
				return @[iName][modifID]

		@__base['Calculate' .. modifName] = (inputAdd) =>
			calc = targetTable.calculateStart()
			calc += inputAdd if inputAdd
			if targetTable.isLerped and @[targetTable.iNameLerp]
				calc += modif for _, modif in ipairs @[targetTable.iNameLerp]
			elseif @[iName]
				calc += modif for _, modif in ipairs @[iName]
			return targetTable.clampFinal(calc)

	@SetModifierMinMax: (modifName = 'MyModifier', mins, maxs) =>
		for _, data in ipairs @MODIFIERS
			if data.name == modifName
				data.mins = mins
				data.maxs = maxs
				if not mins and not maxs
					data.clamp = (val) -> val
				elseif not mins
					data.clamp = (val) -> math.min(val, maxs)
				elseif not maxs
					data.clamp = (val) -> math.max(val, mins)
				else
					data.clamp = (val) -> math.Clamp(val, mins, maxs)
				return true
		return false

	@SetModifierMinMaxFinal: (modifName = 'MyModifier', mins, maxs) =>
		for _, data in ipairs @MODIFIERS
			if data.name == modifName
				data.minsFinal = mins
				data.maxsFinal = maxs
				if not mins and not maxs
					data.clampFinal = (val) -> val
				elseif not mins
					data.clampFinal = (val) -> math.min(val, maxs)
				elseif not maxs
					data.clampFinal = (val) -> math.max(val, mins)
				else
					data.clampFinal = (val) -> math.Clamp(val, mins, maxs)
				return true
		return false

	RegisterModifier: (modifName = 'MyModifier', def = 0, calculateStart = 0) =>
		iName = modifName .. 'Modifiers'
		for _, data in ipairs @CUSTOM_MODIFIERS
			if data.name == modifName
				data.def = def
				return

		targetTable = {
			name: modifName
			:def, :iName
			clamp: (val) -> val
			clampFinal: (val) -> val
			lerpFunc: Lerp
			:calculateStart
		}

		targetTable.def = (-> def) if type(def) ~= 'function'
		targetTable.calculateStart = (-> calculateStart) if type(calculateStart) ~= 'function'

		table.insert(@CUSTOM_MODIFIERS, targetTable)
		@[iName] = {}

		@['SetModifier' .. modifName] = (modifID, val = 0) =>
			return if not modifID
			return if not @[iName][modifID]
			@[iName][modifID] = targetTable.clamp(val)

		@['GetModifier' .. modifName] = (modifID, val = 0) =>
			return if not modifID
			if targetTable.isLerped
				return @[targetTable.iNameLerp][modifID]
			else
				return @[iName][modifID]

		@['GetRawModifier' .. modifName] = (modifID, val = 0) =>
			return if not modifID
			return @[iName][modifID]

		@['Calculate' .. modifName] = (inputAdd) =>
			calc = targetTable.calculateStart()
			calc += inputAdd if inputAdd
			if targetTable.isLerped and @[targetTable.iNameLerp]
				calc += modif for i, modif in ipairs @[targetTable.iNameLerp]
			elseif @[iName]
				calc += modif for i, modif in ipairs @[iName]
			return targetTable.clampFinal(calc)

	SetModifierMinMax: (modifName = 'MyModifier', mins, maxs) =>
		for _, data in ipairs @CUSTOM_MODIFIERS
			if data.name == modifName
				data.mins = mins
				data.maxs = maxs
				if not mins and not maxs
					data.clamp = (val) -> val
				elseif not mins
					data.clamp = (val) -> math.min(val, maxs)
				elseif not maxs
					data.clamp = (val) -> math.max(val, mins)
				else
					data.clamp = (val) -> math.Clamp(val, mins, maxs)
				return true
		return false

	SetModifierMinMaxFinal: (modifName = 'MyModifier', mins, maxs) =>
		for _, data in ipairs @CUSTOM_MODIFIERS
			if data.name == modifName
				data.minsFinal = mins
				data.maxsFinal = maxs
				if not mins and not maxs
					data.clampFinal = (val) -> val
				elseif not mins
					data.clampFinal = (val) -> math.min(val, maxs)
				elseif not maxs
					data.clampFinal = (val) -> math.max(val, mins)
				else
					data.clamp = (val) -> math.Clamp(val, mins, maxs)
				return true
		return false

	@SetupLerpTables: (modifName = 'MyModifier') =>
		for _, data in ipairs @MODIFIERS
			if data.name == modifName
				data.isLerped = true
				data.iNameLerp = data.iName .. 'Lerp'
				return true
		return false

	SetupLerpTables: (modifName = 'MyModifier') =>
		for _, data in ipairs @CUSTOM_MODIFIERS
			if data.name == modifName
				data.isLerped = true
				data.lerpTable = {k, v for k, v in pairs @[data.iName]}
				data.iNameLerp = data.iName .. 'Lerp'
				@[data.iNameLerp] = data.lerpTable
				return true, data.lerpTable
		return false

	@SetLerpFunc: (modifName = 'MyModifier', func = Lerp) =>
		for _, data in ipairs @MODIFIERS
			if data.name == modifName
				data.lerpFunc = func
				return true
		return false

	SetLerpFunc: (modifName = 'MyModifier', func = Lerp) =>
		for _, data in ipairs @CUSTOM_MODIFIERS
			if data.name == modifName
				data.lerpFunc = func
				return true
		return false

	TriggerLerp: (modifName = 'MyModifier', lerpBy = 0.5) =>
		for _, modif in ipairs @CUSTOM_MODIFIERS
			if modif.name == modifName
				@[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, @[modif.iNameLerp][id], @[modif.iName][id]) for id = 1, #@[modif.iNameLerp] when @[modif.iNameLerp][id] ~= @[modif.iName][id]
				return true
		for _, modif in ipairs @@MODIFIERS
			if modif.name == modifName
				@[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, @[modif.iNameLerp][id], @[modif.iName][id]) for id = 1, #@[modif.iNameLerp] when @[modif.iNameLerp][id] ~= @[modif.iName][id]
				return true
		return false

	TriggerLerpAll: (lerpBy = 0.5) =>
		outputTriggered = {}
		for _, modif in ipairs @CUSTOM_MODIFIERS
			if modif.iNameLerp
				for id = 1, #@[modif.iNameLerp]
					if @[modif.iNameLerp][id] ~= @[modif.iName][id]
						@[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, @[modif.iNameLerp][id], @[modif.iName][id])
						table.insert(outputTriggered, {modif.name, @[modif.iNameLerp][id]})
		for _, modif in ipairs @@MODIFIERS
			if modif.iNameLerp
				for id = 1, #@[modif.iNameLerp]
					if @[modif.iNameLerp][id] ~= @[modif.iName][id]
						@[modif.iNameLerp][id] = modif.lerpFunc(lerpBy, @[modif.iNameLerp][id], @[modif.iName][id])
						table.insert(outputTriggered, {modif.name, @[modif.iNameLerp][id]})
		return outputTriggered

	@ClearModifiers: =>
		for _, modif in ipairs @MODIFIERS
			@__base['SetModifier' .. modif.name] = nil
			@__base['Calculate' .. modif.name] = nil
		@MODIFIERS = {}

	ClearModifiers: =>
		for _, modif in ipairs @CUSTOM_MODIFIERS
			@[modif.iName] = nil
			@['SetModifier' .. modif.name] = nil
			@['Calculate' .. modif.name] = nil
		@CUSTOM_MODIFIERS = {}

	new: =>
		@CUSTOM_MODIFIERS = {}
		for _, modif in ipairs @@MODIFIERS
			@[modif.iName] = {}
			@[modif.iNameLerp] = {} if modif.iNameLerp
		@modifiersNames = {}
		@nextModifierID = 0

	GetModifierID: (name = '') =>
		return @modifiersNames[name] if @modifiersNames[name]
		@nextModifierID += 1
		id = @nextModifierID
		@modifiersNames[name] = id
		@[modif.iName][id] = modif.def() for _, modif in ipairs @@MODIFIERS
		@[modif.iNameLerp][id] = modif.def() for _, modif in ipairs @@MODIFIERS when modif.iNameLerp
		@[modif.iName][id] = modif.def() for _, modif in ipairs @CUSTOM_MODIFIERS
		@[modif.iNameLerp][id] = modif.def() for _, modif in ipairs @CUSTOM_MODIFIERS when modif.iNameLerp
		return id

	ResetModifiers: (name = '', hard = false) =>
		return false if not @modifiersNames[name]
		id = @modifiersNames[name]
		@[modif.iName][id] = modif.def() for _, modif in ipairs @@MODIFIERS
		@[modif.iName][id] = modif.def() for _, modif in ipairs @CUSTOM_MODIFIERS
		if hard
			@[modif.iNameLerp][id] = modif.def() for _, modif in ipairs @@MODIFIERS when modif.iNameLerp
			@[modif.iNameLerp][id] = modif.def() for _, modif in ipairs @CUSTOM_MODIFIERS when modif.iNameLerp
		return true
