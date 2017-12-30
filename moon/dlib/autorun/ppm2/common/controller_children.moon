
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

class PPM2.ControllerChildren extends DLib.SequenceHolder
	--@AVALIABLE_CONTROLLERS = {}
	@MODELS = {}
	@__inherited: (child) =>
		super(child)
		child.MODELS_HASH = {mod, true for mod in *child.MODELS}
		child.NEXT_OBJ_ID = 0
		return if not child.AVALIABLE_CONTROLLERS
		child.MODELS_HASH = {mod, true for mod in *child.MODELS}
		child.AVALIABLE_CONTROLLERS[mod] = child for mod in *child.MODELS

	@SelectController = (model = 'models/ppm/player_default_base.mdl') => @AVALIABLE_CONTROLLERS[model\lower()] or @

	@NEXT_OBJ_ID = 0

	new: (controller) =>
		super()
		@isValid = true
		if controller
			@ent = controller.ent
			@entID = controller.entID
			@controller = controller
			@nwController = controller
		else
			@ent = NULL
			@entID = -1
			@controller = nil
			@nwController = nil
		@objID = @@NEXT_OBJ_ID
		@@NEXT_OBJ_ID += 1
		@lastPAC3BoneReset = 0

	__tostring: => "[#{@@__name}:#{@objID}|#{@ent}]"
	-- IsValid: => @isValid
	IsValid: => @isValid and IsValid(@ent)
	GetData: => @nwController
	GrabData: (str, ...) => @nwController['Get' .. str](@nwController, ...)
	GetEntity: => @ent
	GetEntityID: => @entID
	GetDataID: => @entID

	RemoveFunc: =>
	Remove: =>
		return false if not @isValid
		@isValid = false
		@RemoveFunc()
		return true
