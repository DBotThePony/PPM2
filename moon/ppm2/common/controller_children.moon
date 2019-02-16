
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


class PPM2.ControllerChildren extends PPM2.SequenceHolder
	--@AVALIABLE_CONTROLLERS = {}
	@MODELS = {}
	@__inherited: (child) =>
		super(child)
		child.MODELS_HASH = {mod, true for _, mod in ipairs child.MODELS}
		child.NEXT_OBJ_ID = 0
		return if not child.AVALIABLE_CONTROLLERS
		child.MODELS_HASH = {mod, true for _, mod in ipairs child.MODELS}
		child.AVALIABLE_CONTROLLERS[mod] = child for _, mod in ipairs child.MODELS

	@SelectController = (model = 'models/ppm/player_default_base.mdl') => @AVALIABLE_CONTROLLERS[model\lower()] or @

	@NEXT_OBJ_ID = 0

	new: (controller) =>
		super()
		assert(controller, 'You can not create a children without controller.')

		@entID = controller.entID
		@controller = controller
		@nwController = controller

		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0

	__tostring: => "[#{@@__name}:#{@objID}|#{@GetEntity()}]"
	-- IsValid: => @isValid
	IsValid: => @isValid and IsValid(@GetEntity())
	GetData: => @nwController
	GrabData: (str, ...) => @nwController['Get' .. str](@nwController, ...)
	GetEntity: => @controller\GetEntity()
	GetEntityID: => @entID
	GetDataID: => @entID
	GetObjectSlot: => @nwController\GetObjectSlot()
	ObjectSlot: => @nwController\ObjectSlot()

	RemoveFunc: =>
	Remove: =>
		return false if not @isValid
		super()
		@RemoveFunc()
		return true
