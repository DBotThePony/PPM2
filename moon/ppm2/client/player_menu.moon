
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


doPatch = =>
	return if not @IsValid()
	local target

	for _, child in ipairs @GetChildren()
		if child\GetName() == 'DIconLayout'
			target = child
			break

	return if not target
	local buttonTarget

	for _, button in ipairs target\GetChildren()
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

		for _, child in ipairs buttonTarget.Window\GetChildren()
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
