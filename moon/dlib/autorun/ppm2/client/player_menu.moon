
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

doPatch = =>
	return if not @IsValid()
	local target

	for child in *@GetChildren()
		if child\GetName() == 'DIconLayout'
			target = child
			break

	return if not target
	local buttonTarget

	for button in *target\GetChildren()
		buttonChilds = button\GetChildren()
		cond1 = buttonChilds[1] and buttonChilds[1]\GetName() == 'DLabel'
		cond2 = buttonChilds[2] and buttonChilds[2]\GetName() == 'DLabel'
		if cond1 and buttonChilds[1]\GetText() == 'Player Model'
			buttonTarget = button
			break
		elseif cond2 and buttonChilds[2]\GetText() == 'Player Model'
			buttonTarget = button
			break

	return if not buttonTarget
	{:title, :init, :icon, :width, :height, :onewindow} = list.Get('DesktopWindows').PlayerEditor
	buttonTarget.DoClick = ->
		return buttonTarget.Window\Center() if onewindow and IsValid(buttonTarget.Window)

		buttonTarget.Window = @Add('DFrame')
		with buttonTarget.Window
			\SetSize(width, height)
			\SetTitle(title)
			\Center()

		init(buttonTarget, buttonTarget.Window)
		local targetModel

		for child in *buttonTarget.Window\GetChildren()
			if child\GetName() == 'DModelPanel'
				targetModel = child
				break

		return if not targetModel
		targetModel.oldSetModel = targetModel.SetModel
		targetModel.SetModel = (model) =>
			oldModel = @Entity\GetModel()
			oldPonyData = @Entity\GetPonyData()
			@oldSetModel(model)
			if IsValid(@Entity) and oldPonyData
				oldPonyData\SetupEntity(@Entity)
				oldPonyData\ModelChanges(oldModel, model)
		targetModel.PreDrawModel = (ent) =>
			controller = @ponyController
			return if not controller
			return if not ent\IsPony()
			controller\SetupEntity(ent) if controller.ent ~= ent
			controller\GetRenderController()\DrawModels()
			controller\GetRenderController()\PreDraw(ent)
			controller\GetRenderController()\HideModels(true)
			bg = controller\GetBodygroupController()
			bg\ApplyBodygroups() if bg

		copy = PPM2.GetMainData()\Copy()
		controller = copy\CreateCustomController(targetModel.Entity)
		copy\SetController(controller)
		controller\SetDisableTask(true)
		targetModel.ponyController = controller

		hook.Run 'BuildPlayerModelMenu', buttonTarget, buttonTarget.Window

hook.Add 'ContextMenuCreated', 'PPM2.PatchPlayerModelMenu', => timer.Simple 0, -> doPatch(@)
