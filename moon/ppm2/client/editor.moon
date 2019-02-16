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


ADVANCED_MODE = CreateConVar('ppm2_editor_advanced', '0', {FCVAR_ARCHIVE}, 'Show all options. Keep in mind Editor3 acts different with this option.')
ENABLE_FULLBRIGHT = CreateConVar('ppm2_editor_fullbright', '1', {FCVAR_ARCHIVE}, 'Disable lighting in editor')
DISTANCE_LIMIT = CreateConVar('ppm2_sv_editor_dist', '0', {FCVAR_NOTIFY, FCVAR_REPLICATED}, 'Distance limit in PPM/2 Editor/2. 0 - means default (400)')

BackgroundColors = {
	Color(200, 200, 200)
	Color(150, 150, 150)
	Color(255, 255, 255)
	Color(131, 255, 240)
	Color(131, 255, 143)
	Color(206, 131, 255)
	Color(131, 135, 255)
	Color(92, 98, 228)
	Color(92, 201, 228)
	Color(92, 228, 201)
	Color(228, 155, 92)
	Color(228, 92, 110)
}

surface.CreateFont('PPM2.Title', {
	font: 'Roboto'
	size: 72
	weight: 600
})

surface.CreateFont('PPM2.AboutLabels', {
	font: 'Roboto'
	size: 16
	weight: 500
})

EditorModels = {
	'DEFAULT': 'models/ppm/player_default_base.mdl'
	'CPPM': 'models/cppm/player_default_base.mdl'
	'NEW': 'models/ppm/player_default_base_new.mdl'
}

USE_MODEL = CreateConVar('ppm2_editor_model', 'new', {FCVAR_ARCHIVE}, 'What model to use in editor. Valids are "default", "cppm", "new"')
PANEL_WIDTH = CreateConVar('ppm2_editor_width', '370', {FCVAR_ARCHIVE}, 'Width of editor panel, in pixels')

IS_USING_NEW = (newEditor = false) ->
	if newEditor
		return LocalPlayer()\IsNewPony()
	else
		switch USE_MODEL\GetString()
			when 'new'
				return true
	return false

MODEL_BOX_PANEL = {
	SEQUENCE_STAND: 22
	PONY_VEC_Z: 64 * .7

	SEQUENCES: {
		'gui.ppm2.editor.seq.standing':     22
		'gui.ppm2.editor.seq.move':         316
		'gui.ppm2.editor.seq.walk':         232
		'gui.ppm2.editor.seq.sit':          202
		'gui.ppm2.editor.seq.swim':         370
		'gui.ppm2.editor.seq.run':          328
		'gui.ppm2.editor.seq.duckwalk':     286
		'gui.ppm2.editor.seq.duck':         76
		'gui.ppm2.editor.seq.jump':         160
	}

	Init: =>
		@animRate = 1
		@seq = @SEQUENCE_STAND
		@targetAngle = Angle(0, 0, 0)
		@angle = Angle(0, 0, 0)
		@distToPony = 100
		@targetDistToPony = 100
		@vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)
		@hold = false
		@holdLast = 0
		@mouseX, @mouseY = 0, 0
		@SetMouseInputEnabled(true)
		@editorSeq = 1
		@playing = true
		@lastTick = RealTimeL()
		@SetCursor('none')

		@buildingModel = ClientsideModel('models/ppm/ppm2_stage.mdl', RENDERGROUP_OTHER)
		@buildingModel\SetNoDraw(true)
		@buildingModel\SetModelScale(0.9)

		@seqButton = vgui.Create('DComboBox', @)
		with @seqButton
			\SetSize(120, 20)
			\SetValue('Standing')
			\AddChoice(choice, num) for choice, num in pairs @SEQUENCES
			.OnSelect = (pnl = box, index = 1, value = '', data = value) ->
				@SetSequence(data)
	ResetPosition: =>
		@targetAngle = Angle(0, 0, 0)
		@targetDistToPony = 100
		@vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)

	PerformLayout: (w = 0, h = 0) =>
		@seqButton\SetPos(10, 10)
		@emotesPanel\SetPos(10, 40) if IsValid(@emotesPanel)

	OnMousePressed: (code = MOUSE_LEFT) =>
		return if code ~= MOUSE_LEFT
		@hold = true
		@SetCursor('sizeall')
		@holdLast = RealTimeL() + .1
		@mouseX, @mouseY = gui.MousePos()

	OnMouseReleased: (code = MOUSE_LEFT) =>
		return if code ~= MOUSE_LEFT
		@hold = false
		@SetCursor('none')

	SetController: (val) => @controller = val

	OnMouseWheeled: (wheelDelta = 0) =>
		@playing = false
		@editorSeq = 1
		@targetDistToPony = math.Clamp(@targetDistToPony - wheelDelta * 10, 20, 150)
	GetModel: => @model
	GetSequence: => @seq
	GetSeq: => @seq
	GetAnimRate: => @animRate
	SetAnimRate: (val = 1) => @animRate = val
	SetSeq: (val = @SEQUENCE_STAND) =>
		@seq = val
		@model\SetSequence(@seq) if IsValid(@model)
	SetSequence: (val = @SEQUENCE_STAND) =>
		@seq = val
		@model\SetSequence(@seq) if IsValid(@model)
	ResetSequence: => @SetSequence(@SEQUENCE_STAND)
	ResetSeq: => @SetSequence(@SEQUENCE_STAND)

	ResetModel: (ponydata, model = 'models/ppm/player_default_base.mdl') =>
		@model\Remove() if IsValid(@model)
		with @model = ClientsideModel(model)
			\SetNoDraw(true)
			.__PPM2_PonyData = ponydata
			\SetSequence(@seq)
			\FrameAdvance(0)
		@emotesPanel\Remove() if IsValid(@emotesPanel)
		if IS_USING_NEW()
			@emotesPanel = PPM2.CreateEmotesPanel(@, @model, false)
			@emotesPanel\SetPos(10, 40)
			@emotesPanel\SetMouseInputEnabled(true)
			@emotesPanel\SetVisible(true)
		return @model
	Think: =>
		rtime = RealTimeL()
		delta = rtime - @lastTick
		@lastTick = rtime
		if IsValid(@model)
			@model\FrameAdvance(delta * @animRate)
			@model\SetPlaybackRate(1)
			@model\SetPoseParameter('move_x', 1)

		@hold = @IsHovered() if @hold

		if @hold
			x, y = gui.MousePos()
			deltaX, deltaY = x - @mouseX, y - @mouseY
			@mouseX, @mouseY = x, y
			{:pitch, :yaw, :roll} = @targetAngle
			yaw -= deltaX * .5
			pitch = math.Clamp(pitch - deltaY * .5, -40, 10)
			@targetAngle = Angle(pitch, yaw, roll)

		@angle = LerpAngle(delta * 4, @angle, @targetAngle)
		@distToPony = Lerp(delta * 4, @distToPony, @targetDistToPony)
		@vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)
		@vectorPos\Rotate(@angle)
		@drawAngle = (Vector(0, 0, @PONY_VEC_Z * .7) - @vectorPos)\Angle()

	FLOOR_VECTOR: Vector(0, 0, -30)
	FLOOR_ANGLE: Vector(0, 0, 1)

	DRAW_WALLS: {
		{Vector(-4000, 0, 900), Vector(1, 0, 0), 8000, 2000}
		{Vector(4000, 0, 900), Vector(-1, 0, 0), 8000, 2000}
		{Vector(0, -4000, 900), Vector(0, 1, 0), 8000, 2000}
		{Vector(0, 4000, 900), Vector(0, -1, 0), 8000, 2000}
		{Vector(0, 0, 900), Vector(0, 0, -1), 8000, 8000}
	}

	WALL_COLOR: Color(98, 189, 176)
	FLOOR_COLOR: Color(53, 150, 84)

	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)
		return if not IsValid(@model)
		x, y = @LocalToScreen(0, 0)
		cam.Start3D(@vectorPos, @drawAngle, 90, x, y, w, h)

		render.DrawQuadEasy(@FLOOR_VECTOR, @FLOOR_ANGLE, 7000, 7000, @FLOOR_COLOR)

		for _, {pos, ang, w, h} in ipairs @DRAW_WALLS
			render.DrawQuadEasy(pos, ang, w, h, @WALL_COLOR)

		if ENABLE_FULLBRIGHT\GetBool()
			render.SuppressEngineLighting(true)
			render.ResetModelLighting(1, 1, 1)
			render.SetColorModulation(1, 1, 1)

		@buildingModel\DrawModel()
		ctrl = @controller\GetRenderController()

		if bg = @controller\GetBodygroupController()
			bg\ApplyBodygroups()

		with @model\PPMBonesModifier()
			\ResetBones()
			hook.Call('PPM2.SetupBones', nil, @model, @controller)
			\Think(true)

		with ctrl
			\DrawModels()
			\HideModels(true)
			\PreDraw(@model)

		@model\DrawModel()
		ctrl\PostDraw(@model)

		render.SuppressEngineLighting(false) if ENABLE_FULLBRIGHT\GetBool()

		cam.End3D()
	OnRemove: =>
		@model\Remove() if IsValid(@model)
		@buildingModel\Remove() if IsValid(@buildingModel)
}

vgui.Register('PPM2ModelPanel', MODEL_BOX_PANEL, 'EditablePanel')

CALC_VIEW_PANEL = {
	Init: =>
		@playingOpenAnim = true
		@hold = false
		@mousex, @mousey = 0, 0
		@SetMouseInputEnabled(true)
		@SetKeyboardInputEnabled(true)
		ply = LocalPlayer()
		@drawPos = Vector(100, 0, 70)
		@drawAngle = Angle(0, 180, 0)
		@fov = 90
		@lastTick = RealTimeL()
		hook.Add('CalcView', @, @CalcView)
		hook.Add('PrePlayerDraw', @, @PrePlayerDraw)

		@slow = false
		@fast = false
		@forward = false
		@backward = false
		@left = false
		@right = false
		@up = false
		@down = false
		@lastPosSend = 0
		@prevPos = Vector()

		@realX, @realY = 0, 0
		@realW, @realH = ScrW(), ScrH()
		@SetCursor('hand')

		if IS_USING_NEW(true)
			@emotesPanel = PPM2.CreateEmotesPanel(@, LocalPlayer(), false)
			@emotesPanel\SetPos(10, 10)
			@emotesPanel\SetMouseInputEnabled(true)
			@emotesPanel\SetVisible(true)

	SetRealSize: (w = @realW, h = @realH) => @realW, @realH = w, h
	SetRealPos: (x = @realX, y = @realY) => @realX, @realY = x, y

	CalcView: (ply = LocalPlayer(), origin = Vector(0, 0, 0), angles = Angle(0, 0, 0), fov = @fov, znear = 0, zfar = 1000) =>
		return hook.Remove('CalcView', @) if not @IsValid()
		return if not @IsVisible()
		origin, angles = LocalToWorld(@drawPos, @drawAngle, LocalPlayer()\GetPos(), Angle(0, LocalPlayer()\EyeAnglesFixed().y, 0))
		newData = {:angles, :origin, fov: @fov, :znear, :zfar, drawviewer: true}
		return newData

	PrePlayerDraw: (ply = LocalPlayer()) =>
		return hook.Remove('PrePlayerDraw', @) if not @IsValid()
		return if not @IsVisible()
		return if ply ~= LocalPlayer()

		if data = ply\GetPonyData()
			if bg = data\GetBodygroupController()
				bg\ApplyBodygroups()

			with ply\PPMBonesModifier()
				\ResetBones()
				hook.Call('PPM2.SetupBones', nil, ply, data)
				\Think(true)

		return

	OnMousePressed: (code = MOUSE_LEFT) =>
		return if code ~= MOUSE_LEFT
		@emotesPanel\SetVisible(false) if IsValid(@emotesPanel)
		@hold = true
		@SetCursor('sizeall')
		@mouseX, @mouseY = gui.MousePos()

	IsActive: => @forward or @backward or @left or @right or @hold or @down or @up

	CheckCode: (code = KEY_NONE, status = false) =>
		switch code
			when KEY_RCONTROL, KEY_LCONTROL
				@slow = status
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)
			when KEY_LSHIFT, KEY_RSHIFT
				@fast = status
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)
			when KEY_W
				@forward = status
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)
			when KEY_S
				@backward = status
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)
			when KEY_A
				@left = status
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)
			when KEY_D
				@right = status
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)
			when KEY_SPACE
				@up = status
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)

	OnKeyCodePressed: (code = KEY_NONE) =>
		@CheckCode(code, true)

	OnKeyCodeReleased: (code = KEY_NONE) =>
		@CheckCode(code, false)

	OnMouseReleased: (code = MOUSE_LEFT) =>
		return if code ~= MOUSE_LEFT
		@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)
		@hold = false
		@SetCursor('hand')

	Think: =>
		rtime = RealTimeL()
		delta = rtime - @lastTick
		@lastTick = rtime

		@hold = @IsHovered() if @hold

		if @hold
			x, y = gui.MousePos()
			deltaX, deltaY = x - @mouseX, y - @mouseY
			@mouseX, @mouseY = x, y
			{:pitch, :yaw, :roll} = @drawAngle
			yaw -= deltaX * .3
			pitch += deltaY * .3
			@drawAngle = Angle(pitch\clamp(-89, 89), yaw, roll)
			@drawAngle\Normalize()

		speedModifier = 1
		speedModifier *= 2 if @fast
		speedModifier *= 0.5 if @slow

		if @forward
			@drawPos += @drawAngle\Forward() * speedModifier * delta * 100

		if @backward
			@drawPos -= @drawAngle\Forward() * speedModifier * delta * 100

		if @right
			@drawPos += @drawAngle\Right() * speedModifier * delta * 100

		if @left
			@drawPos -= @drawAngle\Right() * speedModifier * delta * 100

		if @up
			@drawPos += @drawAngle\Up() * speedModifier * delta * 100

		limitDist = DISTANCE_LIMIT\GetFloat()
		limitDist = 400 if limitDist <= 0
		lenDist = @drawPos\Length()

		if lenDist > limitDist
			@drawPos\Normalize()
			@drawPos = @drawPos * limitDist

		if @drawPos ~= @prevPos and @lastPosSend < RealTimeL()
			@lastPosSend = RealTimeL() + 0.1
			@prevPos = Vector(@drawPos)
			net.Start('PPM2.EditorCamPos')
			net.WriteVector(@drawPos)
			net.WriteAngle(@drawAngle)
			net.SendToServer()

		if @IsActive()
			if not @resizedToScreen
				@emotesPanel\SetVisible(false) if IsValid(@emotesPanel)
				@resizedToScreen = true
				@SetPos(0, 0)
				@SetSize(ScrW(), ScrH())
		else
			if @resizedToScreen
				@resizedToScreen = false
				@SetPos(@realX, @realY)
				@SetSize(@realW, @realH)
				@emotesPanel\SetVisible(not @IsActive()) if IsValid(@emotesPanel)

	OnRemove: =>
		hook.Remove('CalcView', @)
		hook.Remove('PrePlayerDraw', @)
}

vgui.Register('PPM2CalcViewPanel', CALC_VIEW_PANEL, 'EditablePanel')

TATTOO_INPUT_GRABBER = {
	WatchButtons: {KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_Q, KEY_E}
	BUTTONS_DELAY: 0.5
	DEFAULT_STEP: 0.25
	ROTATE_STEP: 6
	SCALE_STEP: 0.05
	CONTINIOUS_STEP_MULTIPLIER: 2
	CONTINIOUS_SCALE_STEP: 0.25
	CONTINIOUS_ROTATE_STEP: 3

	SetPanelsToUpdate: (data = {}) => @panelsToUpdate = data
	SetTargetData: (data) => @targetData = data
	GetTargetData: => @targetData
	GetPanelsToUpdate: => @panelsToUpdate

	SetTargetID: (id = @targetID) => @targetID = id
	GetTargetID: => @targetID
	DataCall: (key = '', ...) => @targetData[key .. @targetID](@targetData, ...)
	DataSet: (key = '', ...) => @targetData['Set' .. key .. @targetID](@targetData, ...)
	DataGet: (key = '', ...) => @targetData['Get' .. key .. @targetID](@targetData, ...)
	DataAdd: (key = '', val = 0) => @DataSet(key, @DataGet(key) + val)

	TriggerUpdate: => pnl\DoUpdate() for _, pnl in ipairs @panelsToUpdate when IsValid(pnl)

	Init: =>
		@targetID = 1
		@MakePopup()
		@SetSize(400, 90)
		@SetPos(ScrW() / 2 - 200, ScrH() * .2)
		@SetMouseInputEnabled(false)
		@SetKeyboardInputEnabled(true)
		@ignoreFocus = RealTimeL() + 1
		@scaleUp = false
		@scaleDown = false
		@scaleLeft = false
		@scaleRight = false
		@rotateLeft = false
		@rotateRight = false
		@moveLeft = false
		@moveRight = false
		@moveUp = false
		@moveDown = false
		@scaleUpTime = 0
		@scaleDownTime = 0
		@scaleLeftTime = 0
		@scaleRightTime = 0
		@rotateLeftTime = 0
		@rotateRightTime = 0
		@moveLeftTime = 0
		@moveRightTime = 0
		@moveUpTime = 0
		@moveDownTime = 0
		@panelsToUpdate = {}
		with @helpLabel = vgui.Create('DLabel', @)
			\SetFont('HudHintTextLarge')
			\Dock(FILL)
			\DockMargin(10, 10, 10, 10)
			\SetTextColor(color_white)
			\SetText('gui.ppm2.editor.tattoo.help')

	HandleKey: (code = KEY_NONE, status = false) =>
		switch code
			when KEY_W
				@moveUpTime = RealTimeL() + @BUTTONS_DELAY if not @moveDown and not @moveUp and not @moveLeft and not @moveRight
				@moveUp = status
				@DataAdd('TattooPosY', @DEFAULT_STEP) if status
				@TriggerUpdate()
			when KEY_S
				@moveDownTime = RealTimeL() + @BUTTONS_DELAY if not @moveDown and not @moveUp and not @moveLeft and not @moveRight
				@moveDown = status
				@DataAdd('TattooPosY', -@DEFAULT_STEP) if status
				@TriggerUpdate()
			when KEY_A
				@moveLeftTime = RealTimeL() + @BUTTONS_DELAY if not @moveDown and not @moveUp and not @moveLeft and not @moveRight
				@moveLeft = status
				@DataAdd('TattooPosX', -@DEFAULT_STEP) if status
				@TriggerUpdate()
			when KEY_D
				@moveRightTime = RealTimeL() + @BUTTONS_DELAY if not @moveDown and not @moveUp and not @moveLeft and not @moveRight
				@moveRight = status
				@DataAdd('TattooPosX', @DEFAULT_STEP) if status
				@TriggerUpdate()
			when KEY_UP
				@scaleUp = status
				@scaleUpTime = RealTimeL() + @BUTTONS_DELAY
				@DataAdd('TattooScaleY', @SCALE_STEP) if status
				@TriggerUpdate()
			when KEY_DOWN
				@scaleDown = status
				@scaleDownTime = RealTimeL() + @BUTTONS_DELAY
				@DataAdd('TattooScaleY', -@SCALE_STEP) if status
				@TriggerUpdate()
			when KEY_LEFT
				@scaleLeft = status
				@scaleLeftTime = RealTimeL() + @BUTTONS_DELAY
				@DataAdd('TattooScaleX', -@SCALE_STEP) if status
				@TriggerUpdate()
			when KEY_RIGHT
				@scaleRight = status
				@scaleRightTime = RealTimeL() + @BUTTONS_DELAY
				@DataAdd('TattooScaleX', @SCALE_STEP) if status
				@TriggerUpdate()
			when KEY_Q
				@rotateLeft = status
				@rotateLeftTime = RealTimeL() + @BUTTONS_DELAY
				@DataAdd('TattooRotate', -@ROTATE_STEP) if status
				@TriggerUpdate()
			when KEY_E
				@rotateRight = status
				@rotateRightTime = RealTimeL() + @BUTTONS_DELAY
				@DataAdd('TattooRotate', @ROTATE_STEP) if status
				@TriggerUpdate()
			when KEY_ESCAPE
				@Remove()
	OnKeyCodePressed: (code = KEY_NONE) =>
		@HandleKey(code, true)
	OnKeyCodeReleased: (code = KEY_NONE) =>
		@HandleKey(code, false)
	Think: =>
		return @Remove() if not @HasFocus() and @ignoreFocus < RealTimeL()
		ftime = FrameTime()
		if @moveUp and @moveUpTime < RealTimeL()
			@DataAdd('TattooPosY', @CONTINIOUS_STEP_MULTIPLIER * ftime)
			@TriggerUpdate()
		if @moveDown and @moveDownTime < RealTimeL()
			@DataAdd('TattooPosY', -@CONTINIOUS_STEP_MULTIPLIER * ftime)
			@TriggerUpdate()
		if @moveRight and @moveRightTime < RealTimeL()
			@DataAdd('TattooPosX', @CONTINIOUS_STEP_MULTIPLIER * ftime)
			@TriggerUpdate()
		if @moveLeft and @moveLeftTime < RealTimeL()
			@DataAdd('TattooPosX', -@CONTINIOUS_STEP_MULTIPLIER * ftime)
			@TriggerUpdate()
		if @scaleUp and @scaleUpTime < RealTimeL()
			@DataAdd('TattooScaleY', @CONTINIOUS_SCALE_STEP * ftime)
			@TriggerUpdate()
		if @scaleDown and @scaleDownTime < RealTimeL()
			@DataAdd('TattooScaleY', -@CONTINIOUS_SCALE_STEP * ftime)
			@TriggerUpdate()
		if @scaleLeft and @scaleLeftTime < RealTimeL()
			@DataAdd('TattooScaleX', -@CONTINIOUS_SCALE_STEP * ftime)
			@TriggerUpdate()
		if @scaleRight and @scaleRightTime < RealTimeL()
			@DataAdd('TattooScaleX', @CONTINIOUS_SCALE_STEP * ftime)
			@TriggerUpdate()
		if @rotateLeft and @rotateLeftTime < RealTimeL()
			@DataAdd('TattooRotate', -@CONTINIOUS_ROTATE_STEP * ftime)
			@TriggerUpdate()
		if @rotateRight and @rotateRightTime < RealTimeL()
			@DataAdd('TattooRotate', @CONTINIOUS_ROTATE_STEP * ftime)
			@TriggerUpdate()

	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)
}

vgui.Register('PPM2TattooEditor', TATTOO_INPUT_GRABBER, 'EditablePanel')

PPM2.EditorBuildNewFilesPanel = =>
	@Label('gui.ppm2.editor.io.hint')
	@Button 'gui.ppm2.editor.io.reload', -> @rebuildFileList()
	list = vgui.Create('DListView', @)
	list\Dock(FILL)
	list\SetMultiSelect(false)
	openFile = (fil) ->
		confirm = ->
			@frame.data\SetFilename(fil)
			@frame.data\ReadFromDisk(true)
			@frame.data\UpdateController()
			@frame.DoUpdate()
			@unsavedChanges = false
			@frame.unsavedChanges = false
			@frame\SetTitle('gui.ppm2.editor.generic.title_file', fil)
		if @unsavedChanges
			Derma_Query(
				'gui.ppm2.editor.io.warn.text',
				'gui.ppm2.editor.io.warn.header',
				'gui.ppm2.editor.generic.yes',
				confirm,
				'gui.ppm2.editor.generic.no'
			)
		else
			confirm()

	PPM2.EditorFileManipFuncs(list, 'ppm2', openFile)
	list\AddColumn('gui.ppm2.editor.io.filename')
	@rebuildFileList = ->
		list\Clear()
		files, dirs = file.Find('ppm2/*.dat', 'DATA')
		matchBak = '.bak.dat'
		for _, fil in ipairs files
			if fil\sub(-#matchBak) ~= matchBak
				fil2 = fil\sub(1, #fil - 4)
				line = list\AddLine(fil2)
				line.file = fil

				recomputed = false

				hook.Add 'PostRenderVGUI', line, =>
					return if not @IsVisible() or not @IsHovered()

					if not recomputed
						recomputed = true
						if file.Exists('ppm2/thumbnails/' .. fil2 .. '.png', 'DATA')
							line.png = Material('data/ppm2/thumbnails/' .. fil2 .. '.png')
							line.png\Recompute()
							line.png\GetTexture('$basetexture')\Download()

					parent = @GetParent()\GetParent()
					x, y = parent\LocalToScreen(parent\GetWide(), 0)

					if @png
						surface.SetMaterial(@png)
						surface.SetDrawColor(255, 255, 255)
						surface.DrawTexturedRect(x, y, 512, 512)
					else
						if not @genPreview
							PPM2.PonyDataInstance(fil2)\SavePreview()
							@genPreview = true
							timer.Simple 1, ->
								@png = Material('data/ppm2/thumbnails/' .. fil2 .. '.png')
								@png\Recompute()
								@png\GetTexture('$basetexture')\Download()

						surface.SetDrawColor(0, 0, 0)
						surface.DrawRect(x, y, 512, 512)
						DLib.HUDCommons.DrawLoading(x + 40, y + 40, 432, color_white)
	@rebuildFileList()
	list.rebuildFileList = @rebuildFileList

PPM2.EditorBuildOldFilesPanel = =>
	@Label('gui.ppm2.editor.io.warn.oldfile')
	@Button 'gui.ppm2.editor.io.reload', -> @rebuildFileList()
	list = vgui.Create('DListView', @)
	list\Dock(FILL)
	list\SetMultiSelect(false)
	openFile = (fil) ->
		confirm = ->
			newData = PPM2.ReadFromOldData(fil)
			if not newData
				Derma_Message('gui.ppm2.editor.io.failed', 'gui.ppm2.editor.generic.ohno', 'gui.ppm2.editor.generic.okay')
				return
			@frame.data\SetFilename(newData\GetFilename())
			newData\ApplyDataToObject(@frame.data, false)
			@frame.data\UpdateController()
			@frame.DoUpdate()
			@unsavedChanges = true
			@frame.unsavedChanges = true
			@frame\SetTitle('gui.ppm2.editor.generic.title_file_unsaved', newData\GetFilename())
		if @unsavedChanges
			Derma_Query(
				'gui.ppm2.editor.io.warn.text',
				'gui.ppm2.editor.io.warn.header',
				'gui.ppm2.editor.generic.yes',
				confirm,
				'gui.ppm2.editor.generic.no'
			)
		else
			confirm()
	list\AddColumn('gui.ppm2.editor.io.filename')
	PPM2.EditorFileManipFuncs(list, 'ppm', openFile)
	@rebuildFileList = ->
		list\Clear()
		files, dirs = file.Find('ppm/*', 'DATA')
		for _, fil in ipairs files
			fil2 = fil\sub(1, #fil - 4)
			line = list\AddLine(fil2)
			line.file = fil

			recomputed = false

			hook.Add 'PostRenderVGUI', line, =>
				return if not @IsVisible() or not @IsHovered()

				if not recomputed
					recomputed = true
					if file.Exists('ppm2/thumbnails/' .. fil2 .. '_imported.png', 'DATA')
						line.png = Material('data/ppm2/thumbnails/' .. fil2 .. '_imported.png')
						line.png\Recompute()
						line.png\GetTexture('$basetexture')\Download()

				parent = @GetParent()\GetParent()
				x, y = parent\LocalToScreen(parent\GetWide(), 0)

				if @png
					surface.SetMaterial(@png)
					surface.SetDrawColor(255, 255, 255)
					surface.DrawTexturedRect(x, y, 512, 512)
				else
					if not @genPreview
						PPM2.ReadFromOldData(fil2)\SavePreview()
						@genPreview = true
						timer.Simple 1, ->
							@png = Material('data/ppm2/thumbnails/' .. fil2 .. '_imported.png')
							@png\Recompute()
							@png\GetTexture('$basetexture')\Download()

					surface.SetDrawColor(0, 0, 0)
					surface.DrawRect(x, y, 512, 512)
					DLib.HUDCommons.DrawLoading(x + 40, y + 40, 432, color_white)
	@rebuildFileList()
	list.rebuildFileList = @rebuildFileList

PPM2.EditorFileManipFuncs = (list, prefix, openFile) ->
	list.DoDoubleClick = (pnl, rowID, line) ->
		fil = line\GetColumnText(1)
		openFile(fil)
	list.OnRowRightClick = (pnl, rowID, line) ->
		fil = line\GetColumnText(1)
		menu = DermaMenu()
		menu\AddOption('Open', -> openFile(fil))\SetIcon('icon16/accept.png')
		menu\AddOption('Delete', ->
			confirm = ->
				file.Delete("#{prefix}/#{fil}.dat")
				list\rebuildFileList()
			Derma_Query(
				'gui.ppm2.editor.io.delete.confirm',
				'gui.ppm2.editor.io.delete.title',
				'gui.ppm2.editor.generic.yes',
				confirm,
				'gui.ppm2.editor.generic.no'
			)
		)\SetIcon('icon16/cross.png')
		menu\Open()

PANEL_SETTINGS_BASE = {
	Init: =>
		@shouldSaveData = false
		@SetMouseInputEnabled(true)
		@SetKeyboardInputEnabled(true)
		@DockPadding(5, 5, 5, 5)
		@unsavedChanges = false
		@updateFuncs = {}
		@createdPanels = 1
		@isNewEditor = false
		-- @resetCollapse = @Spoiler('Reset buttons')
		@populated = false

	Populate: =>
	Think: =>
		if not @populated and @IsVisible()
			@populated = true
			@Populate()

	IsNewEditor: => @isNewEditor
	GetIsNewEditor: => @isNewEditor
	SetIsNewEditor: (val) => @isNewEditor = val
	ValueChanges: (valID, newVal, pnl) =>
		@unsavedChanges = true
		return if not @frame
		@frame.unsavedChanges = true
		@frame\SetTitle('gui.ppm2.editor.generic.title_file_unsaved', @GetTargetData() and @GetTargetData()\GetFilename() or '%ERRNAME%')
	GetFrame: => @frame
	GetShouldSaveData: => @shouldSaveData
	ShouldSaveData: => @shouldSaveData
	SetShouldSaveData: (val = false) => @shouldSaveData = val
	GetTargetData: => @data
	TargetData: => @data
	SetTargetData: (val) => @data = val
	DoUpdate: => func() for _, func in ipairs @updateFuncs

	CreateResetButton: (name = 'NULL', option = 'NULL', parent) =>
		@createdPanels += 1
		if not IsValid(parent)
			with button = vgui.Create('DButton', @resetCollapse)
				\SetParent(@resetCollapse)
				\Dock(TOP)
				\DockMargin(2, 0, 2, 0)
				\SetText('gui.ppm2.editor.reset_value', DLib.i18n.localize(option))
				.DoClick = ->
					dt = @GetTargetData()
					dt['Reset' .. option](dt)
					@ValueChanges(option, dt['Get' .. option](dt), button)
					@DoUpdate()
		else
			with button = vgui.Create('DButton', parent)
				\SetParent(parent)
				\DockMargin(0, 0, 0, 0)
				\SetText('gui.ppm2.editor.reset_value', DLib.i18n.localize(option))
				\SetSize(0, 0)
				\SetTextColor(Color(255, 255, 255))
				.Paint = (w, h) =>
					return if w == 0
					surface.SetDrawColor(0, 0, 0)
					surface.DrawRect(0, 0, w, h)
				.DoClick = ->
					dt = @GetTargetData()
					dt['Reset' .. option](dt)
					@ValueChanges(option, dt['Get' .. option](dt), button)
					@DoUpdate()
				.Think = ->
					if input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
						\SetSize(\GetParent()\GetSize())
					else
						\SetSize(0, 0)

	NumSlider: (name = 'Slider', option = '', decimals = 0, parent = @scroll or @) =>
		@createdPanels += 3
		with withPanel = vgui.Create('DNumSlider', parent)
			@CreateResetButton(name, option, withPanel)
			\Dock(TOP)
			\DockMargin(2, 0, 2, 0)
			\SetTooltip('gui.ppm2.editor.generic.datavalue', name, option)
			\SetText(name)
			\SetMin(0)
			\SetMax(1)
			\SetMin(@GetTargetData()["GetMin#{option}"](@GetTargetData())) if @GetTargetData()
			\SetMax(@GetTargetData()["GetMax#{option}"](@GetTargetData())) if @GetTargetData()
			\SetDecimals(decimals)
			\SetValue(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			.TextArea\SetTextColor(color_white)
			.Label\SetTextColor(color_white)
			.DoUpdate = -> \SetValue(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			.OnValueChanged = (pnl, newVal = 1) ->
				return if option == ''
				data = @GetTargetData()
				return if not data
				data["Set#{option}"](data, newVal, @GetShouldSaveData())
				@ValueChanges(option, newVal, pnl)
			table.insert @updateFuncs, ->
				\SetMin(@GetTargetData()["GetMin#{option}"](@GetTargetData())) if @GetTargetData()
				\SetMax(@GetTargetData()["GetMax#{option}"](@GetTargetData())) if @GetTargetData()
				\SetValue(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			@scroll\AddItem(withPanel) if IsValid(@scroll) and parent == @scroll
	Label: (text = '', parent = @scroll or @) =>
		@createdPanels += 1
		with withPanel = vgui.Create('DLabel', parent)
			\SetText(text)
			\SetTooltip(text)
			\Dock(TOP)
			\DockMargin(2, 2, 2, 2)
			\SetTextColor(color_white)
			\SizeToContents()
			\SetMouseInputEnabled(true)
			w, h = \GetSize()
			\SetSize(w, h + 5)
			@scroll\AddItem(withPanel) if IsValid(@scroll) and parent == @scroll
	URLLabel: (text = '', url = '', parent = @scroll or @) =>
		@createdPanels += 1
		with withPanel = vgui.Create('DLabel', parent)
			\SetText(text)
			\SetTooltip('gui.ppm2.editor.generic.url', text, url)
			\Dock(TOP)
			\DockMargin(2, 2, 2, 2)
			\SetTextColor(Color(158, 208, 208))
			\SizeToContents()
			\SetCursor('hand')
			w, h = \GetSize()
			\SetSize(w, h + 5)
			\SetMouseInputEnabled(true)
			.DoClick = -> gui.OpenURL(url) if url ~= ''
			@scroll\AddItem(withPanel) if IsValid(@scroll) and parent == @scroll
	Hr: (parent = @scroll or @) =>
		@createdPanels += 1
		with withPanel = vgui.Create('EditablePanel', parent)
			\Dock(TOP)
			\SetSize(200, 15)
			@scroll\AddItem(withPanel) if IsValid(@scroll) and parent == @scroll
			.Paint = (w = 0, h = 0) =>
				surface.SetDrawColor(150, 162, 162)
				surface.DrawLine(0, h / 2, w, h / 2)
	Button: (text = 'Perfectly generic button', doClick = (->), parent = @scroll or @) =>
		@createdPanels += 1
		with withPanel = vgui.Create('DButton', parent)
			\Dock(TOP)
			\SetSize(200, 20)
			\DockMargin(2, 2, 2, 2)
			\SetText(text)
			@scroll\AddItem(withPanel) if IsValid(@scroll) and parent == @scroll
			.DoClick = -> doClick()
	CheckBox: (name = 'Label', option = '', parent = @scroll or @) =>
		@createdPanels += 3
		with withPanel = vgui.Create('DCheckBoxLabel', parent)
			@CreateResetButton(name, option, withPanel)
			\Dock(TOP)
			\DockMargin(2, 2, 2, 2)
			\SetText(name)
			\SetTextColor(color_white)
			\SetTooltip('gui.ppm2.editor.generic.datavalue', name, option)
			\SetChecked(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			.OnChange = (pnl, newVal = false) ->
				return if option == ''
				data = @GetTargetData()
				return if not data
				data["Set#{option}"](data, newVal and 1 or 0, @GetShouldSaveData())
				@ValueChanges(option, newVal and 1 or 0, pnl)
			table.insert @updateFuncs, ->
				\SetChecked(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			@scroll\AddItem(withPanel) if IsValid(@scroll) and parent == @scroll
	ColorBox: (name = 'Colorful Box', option = '', parent = @scroll or @) =>
		@createdPanels += 7
		collapse = vgui.Create('DCollapsibleCategory', parent)
		box = vgui.Create('DColorMixer', collapse)
		collapse.box = box
		with box
			\SetSize(250, 270)
			\SetTooltip('gui.ppm2.editor.generic.datavalue', name, option)
			\SetColor(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			.ValueChanged = (pnl) ->
				timer.Simple 0, ->
					return if option == ''
					data = @GetTargetData()
					return if not data
					newVal = pnl\GetColor()
					data["Set#{option}"](data, newVal, @GetShouldSaveData())
					@ValueChanges(option, newVal, pnl)
			table.insert @updateFuncs, ->
				\SetColor(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
		with collapse
			\SetContents(box)
			\Dock(TOP)
			\DockMargin(2, 2, 2, 2)
			\SetSize(250, 270)
			\SetLabel(name)
			\SetExpanded(false)
			@scroll\AddItem(collapse) if IsValid(@scroll) and parent == @scroll
			@CreateResetButton(name, option, collapse)
		return box, collapse
	Spoiler: (name = 'gui.ppm2.editor.generic.spoiler', parent = @scroll or @) =>
		@createdPanels += 2
		collapse = vgui.Create('DCollapsibleCategory', parent)
		canvas = vgui.Create('EditablePanel', collapse)
		with canvas
			\SetSize(0, 400)
			\Dock(FILL)
		with collapse
			\SetContents(canvas)
			\Dock(TOP)
			\DockMargin(2, 2, 2, 2)
			\SetSize(250, 270)
			\SetLabel(name)
			\SetExpanded(false)
			@scroll\AddItem(collapse) if IsValid(@scroll) and parent == @scroll
		return canvas, collapse
	ComboBox: (name = 'Combo Box', option = '', choices, parent = @scroll or @) =>
		@createdPanels += 4
		with label = vgui.Create('DLabel', parent)
			\SetText(name)
			\SetTextColor(color_white)
			\Dock(TOP)
			\SetSize(0, 20)
			\DockMargin(5, 0, 5, 0)
			\SetMouseInputEnabled(true)
			@scroll\AddItem(label) if IsValid(@scroll) and parent == @scroll
			with box = vgui.Create('DComboBox', label)
				\Dock(RIGHT)
				\SetSize(170, 0)
				\DockMargin(0, 0, 5, 0)
				\SetSortItems(false)
				\SetValue(@GetTargetData()["Get#{option}Enum"](@GetTargetData())) if @GetTargetData()
				if choices
					\AddChoice(choice) for _, choice in ipairs choices
				else
					\AddChoice(choice) for _, choice in ipairs @GetTargetData()["Get#{option}Types"](@GetTargetData()) if @GetTargetData() and @GetTargetData()["Get#{option}Types"]
				.OnSelect = (pnl = box, index = 1, value = '', data = value) ->
					index -= 1
					data = @GetTargetData()
					return if not data
					data["Set#{option}"](data, index, @GetShouldSaveData())
					@ValueChanges(option, index, pnl)
				table.insert @updateFuncs, ->
					\SetValue(@GetTargetData()["Get#{option}Enum"](@GetTargetData())) if @GetTargetData()
			@CreateResetButton(name, option, label)
		return box, label
	URLInput: (option = '', parent = @scroll or @) =>
		@createdPanels += 2
		with wrapper = vgui.Create('EditablePanel', parent)
			\Dock(TOP)
			\DockMargin(5, 10, 5, 10)
			\SetKeyboardInputEnabled(true)
			\SetMouseInputEnabled(true)
			\SetSize(0, 20)
			@scroll\AddItem(wrapper) if IsValid(@scroll) and parent == @scroll
			with textInput = vgui.Create('DTextEntry', wrapper)
				@CreateResetButton('gui.ppm2.editor.generic.url_field', option, textInput)
				\Dock(FILL)
				\SetText(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
				\SetKeyboardInputEnabled(true)
				\SetMouseInputEnabled(true)
				.OnEnter = ->
					text = \GetValue()
					if text\find('^https?://')
						@GetTargetData()["Set#{option}"](@GetTargetData(), text)
						@ValueChanges(option, text, textInput)
					else
						@GetTargetData()["Set#{option}"](@GetTargetData(), '')
						@ValueChanges(option, '', textInput)
				.OnKeyCodeTyped = (pnl, key = KEY_FIRST) ->
					switch key
						when KEY_FIRST
							return true
						when KEY_NONE
							return true
						when KEY_TAB
							return true
						when KEY_ENTER
							.OnEnter()
							\KillFocus()
							return true
					timer.Create "PPM2.EditorCodeChange.#{option}", 1, 1, ->
						return if not IsValid(textInput)
						.OnEnter()
				table.insert @updateFuncs, -> \SetText(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
				return textInput
	ScrollPanel: =>
		return @scroll if IsValid(@scroll)
		@createdPanels += 1
		@scroll = vgui.Create('DScrollPanel', @)
		@scroll\Dock(FILL)
		return @scroll
	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(130, 130, 130)
		surface.DrawRect(0, 0, w, h)
}

vgui.Register('PPM2SettingsBase', PANEL_SETTINGS_BASE, 'EditablePanel')

PPM2.EditorPhongPanels = (ttype = 'Body', spoilerName = ttype .. ' phong parameters') =>
	spoiler = @Spoiler(spoilerName)
	@URLLabel('gui.ppm2.editor.phong.info', 'https://developer.valvesoftware.com/wiki/Phong_materials', spoiler)
	@Label('gui.ppm2.editor.phong.exponent', spoiler)
	@NumSlider('gui.ppm2.editor.phong.exponent_text', ttype .. 'PhongExponent', 3, spoiler)
	@Label('gui.ppm2.editor.phong.boost.title', spoiler)
	@NumSlider('gui.ppm2.editor.phong.boost.boost', ttype .. 'PhongBoost', 3, spoiler)
	@Label('gui.ppm2.editor.phong.tint.title', spoiler)
	picker, pickerSpoiler = @ColorBox('gui.ppm2.editor.phong.tint.tint', ttype .. 'PhongTint', spoiler)
	pickerSpoiler\SetExpanded(true)
	@Label('gui.ppm2.editor.phong.frensel.front.title', spoiler)
	@NumSlider('gui.ppm2.editor.phong.frensel.front.front', ttype .. 'PhongFront', 2, spoiler)
	@Label('gui.ppm2.editor.phong.frensel.middle.title', spoiler)
	@NumSlider('gui.ppm2.editor.phong.frensel.middle.front', ttype .. 'PhongMiddle', 2, spoiler)
	@Label('gui.ppm2.editor.phong.frensel.sliding.title', spoiler)
	@NumSlider('gui.ppm2.editor.phong.frensel.sliding.front', ttype .. 'PhongSliding', 2, spoiler)
	@ComboBox('gui.ppm2.editor.phong.lightwarp', ttype .. 'Lightwarp', nil, spoiler)
	@Label('gui.ppm2.editor.phong.url_lightwarp', spoiler)
	@URLInput(ttype .. 'LightwarpURL', spoiler)
	@Label('gui.ppm2.editor.phong.bumpmap', spoiler)
	@URLInput(ttype .. 'BumpmapURL', spoiler)

EditorPages = {
	{
		'name': 'gui.ppm2.editor.tabs.main'
		'internal': 'main'
		'func': (sheet) =>
			@Button 'gui.ppm2.editor.io.newfile.title', ->
				data = @GetTargetData()
				return if not data
				confirmed = ->
					data\SetFilename("new_pony-#{math.random(1, 100000)}")
					data\Reset()
					@ValueChanges()
				Derma_Query('gui.ppm2.editor.io.newfile.confirm', 'gui.ppm2.editor.io.newfile.toptext', 'gui.ppm2.editor.generic.yes', confirmed, 'gui.ppm2.editor.generic.no')

			@Button 'gui.ppm2.editor.io.random', ->
				data = @GetTargetData()
				return if not data
				confirmed = ->
					PPM2.Randomize(data, false)
					@ValueChanges()
				Derma_Query('Really want to randomize?', 'Randomize', 'gui.ppm2.editor.generic.yes', confirmed, 'gui.ppm2.editor.generic.no')

			@ComboBox('gui.ppm2.editor.misc.race', 'Race')
			@ComboBox('gui.ppm2.editor.misc.wings', 'WingsType')
			@CheckBox('gui.ppm2.editor.misc.gender', 'Gender')
			@NumSlider('gui.ppm2.editor.misc.chest', 'MaleBuff', 2)
			@NumSlider('gui.ppm2.editor.misc.weight', 'Weight', 2)
			@NumSlider('gui.ppm2.editor.misc.size', 'PonySize', 2)

			return if not ADVANCED_MODE\GetBool()
			@CheckBox('gui.ppm2.editor.misc.hide_weapons', 'HideWeapons')

			if IS_USING_NEW(@IsNewEditor())
				@Hr()
				@CheckBox('gui.ppm2.editor.misc.no_flexes2', 'NoFlex')
				@Label('gui.ppm2.editor.misc.no_flexes_desc')
				flexes = @Spoiler('gui.ppm2.editor.misc.flexes')
				for _, {:flex, :active} in ipairs PPM2.PonyFlexController.FLEX_LIST
					@CheckBox("Disable #{flex} control", "DisableFlex#{flex}")\SetParent(flexes) if active
				flexes\SizeToContents()
	}

	{
		'name': 'gui.ppm2.editor.tabs.body'
		'internal': 'body'
		'func': (sheet) =>
			@ScrollPanel()
			@ComboBox('gui.ppm2.editor.body.suit', 'Bodysuit')
			@ColorBox('gui.ppm2.editor.body.color', 'BodyColor')

			if ADVANCED_MODE\GetBool()
				@CheckBox('gui.ppm2.editor.face.inherit.lips', 'LipsColorInherit')
				@CheckBox('gui.ppm2.editor.face.inherit.nose', 'NoseColorInherit')
				@ColorBox('gui.ppm2.editor.face.lips', 'LipsColor')
				@ColorBox('gui.ppm2.editor.face.nose', 'NoseColor')
				PPM2.EditorPhongPanels(@, 'Body', 'gui.ppm2.editor.body.body_phong')

			@NumSlider('gui.ppm2.editor.neck.height', 'NeckSize', 2)
			@NumSlider('gui.ppm2.editor.legs.height', 'LegsSize', 2)
			@NumSlider('gui.ppm2.editor.body.spine_length', 'BackSize', 2)

			@Hr()
			@CheckBox('gui.ppm2.editor.legs.socks.simple', 'Socks') if ADVANCED_MODE\GetBool()
			@CheckBox('gui.ppm2.editor.legs.socks.model', 'SocksAsModel')
			@ColorBox('gui.ppm2.editor.legs.socks.color', 'SocksColor')

			if ADVANCED_MODE\GetBool()
				@Hr()
				PPM2.EditorPhongPanels(@, 'Socks', 'gui.ppm2.editor.legs.socks.socks_phong')
				@ComboBox('gui.ppm2.editor.legs.socks.texture', 'SocksTexture')
				@Label('gui.ppm2.editor.legs.socks.url_texture')
				@URLInput('SocksTextureURL')

				if IS_USING_NEW(@IsNewEditor())
					@Hr()
					@CheckBox('gui.ppm2.editor.hoof.fluffers', 'HoofFluffers')
					@NumSlider('gui.ppm2.editor.hoof.fluffers', 'HoofFluffersStrength', 2)

				@Hr()
				@ColorBox('gui.ppm2.editor.legs.socks.color' .. i, 'SocksDetailColor' .. i) for i = 1, 6

			@Hr()
			@CheckBox('gui.ppm2.editor.legs.newsocks.model', 'SocksAsNewModel')
			@ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor1')
			@ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor2')
			@ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor3')

			if ADVANCED_MODE\GetBool()
				@Label('gui.ppm2.editor.legs.newsocks.url')
				@URLInput('NewSocksTextureURL')
	}

	{
		'name': 'gui.ppm2.editor.old_tabs.wings_and_horn'
		'internal': 'wings_horn'
		'func': (sheet) =>
			@ScrollPanel()
			@CheckBox('gui.ppm2.editor.wings.separate_color', 'SeparateWings')
			@CheckBox('gui.ppm2.editor.wings.separate_phong', 'SeparateWingsPhong') if ADVANCED_MODE\GetBool()
			@CheckBox('gui.ppm2.editor.horn.separate_color', 'SeparateHorn')
			@CheckBox('gui.ppm2.editor.horn.separate_phong', 'SeparateHornPhong') if ADVANCED_MODE\GetBool()
			@CheckBox('gui.ppm2.editor.horn.separate_magic_color', 'SeparateMagicColor')
			@Hr()
			@ColorBox('gui.ppm2.editor.wings.color', 'WingsColor')
			PPM2.EditorPhongPanels(@, 'Wings', 'gui.ppm2.editor.wings.wings_phong') if ADVANCED_MODE\GetBool()
			@ColorBox('gui.ppm2.editor.horn.color', 'HornColor')
			@ColorBox('gui.ppm2.editor.horn.magic', 'HornMagicColor')
			PPM2.EditorPhongPanels(@, 'Horn', 'gui.ppm2.editor.horn.horn_phong') if ADVANCED_MODE\GetBool()
			@Hr()
			@ColorBox('gui.ppm2.editor.wings.bat_color', 'BatWingColor')
			@ColorBox('gui.ppm2.editor.wings.bat_skin_color', 'BatWingSkinColor')
			PPM2.EditorPhongPanels(@, 'BatWingsSkin', 'gui.ppm2.editor.wings.bat_skin_phong') if ADVANCED_MODE\GetBool()
			@Hr()
			left = @Spoiler('gui.ppm2.editor.tabs.left')
			@NumSlider('gui.ppm2.editor.wings.left.size', 'LWingSize', 2, left)
			@NumSlider('gui.ppm2.editor.wings.left.fwd', 'LWingX', 2, left)
			@NumSlider('gui.ppm2.editor.wings.left.up', 'LWingY', 2, left)
			@NumSlider('gui.ppm2.editor.wings.left.inside', 'LWingZ', 2, left)
			right = @Spoiler('gui.ppm2.editor.tabs.right')
			@NumSlider('gui.ppm2.editor.wings.right.size', 'RWingSize', 2, right)
			@NumSlider('gui.ppm2.editor.wings.right.fwd', 'RWingX', 2, right)
			@NumSlider('gui.ppm2.editor.wings.right.up', 'RWingY', 2, right)
			@NumSlider('gui.ppm2.editor.wings.right.inside', 'RWingZ', 2, right)
			return if not ADVANCED_MODE\GetBool()
			@Hr()
			@ColorBox('gui.ppm2.editor.horn.detail_color', 'HornDetailColor')
			@CheckBox('gui.ppm2.editor.horn.glowing_detail', 'HornGlow')
			@NumSlider('gui.ppm2.editor.horn.glow_strength', 'HornGlowSrength', 2)
	}

	{
		'name': 'gui.ppm2.editor.old_tabs.mane_tail'
		'internal': 'manetail_old'
		'display': (editorMode = false) -> not IS_USING_NEW(editorMode)
		'func': (sheet) =>
			@ScrollPanel()
			@ComboBox('Mane type', 'ManeType')
			@ComboBox('Lower Mane type', 'ManeTypeLower')
			@ComboBox('Tail type', 'TailType')

			@CheckBox('Hide entitites when using PAC3 entity', 'HideManes')
			@CheckBox('Hide socks when using PAC3 entity', 'HideManesSocks')

			@NumSlider('Tail size', 'TailSize', 2)

			@Hr()
			@ColorBox("Mane color #{i}", "ManeColor#{i}") for i = 1, 2
			@ColorBox("Tail color #{i}", "TailColor#{i}") for i = 1, 2

			@Hr()
			@ColorBox("Mane detail color #{i}", "ManeDetailColor#{i}") for i = 1, 4
			@ColorBox("Tail detail color #{i}", "TailDetailColor#{i}") for i = 1, 4
	}

	{
		'name': 'gui.ppm2.editor.old_tabs.mane_tail'
		'internal': 'manetail_new'
		'display': IS_USING_NEW
		'func': (sheet) =>
			@ScrollPanel()
			@ComboBox('gui.ppm2.editor.mane.type', 'ManeTypeNew')
			@ComboBox('gui.ppm2.editor.mane.down.type', 'ManeTypeLowerNew')
			@ComboBox('gui.ppm2.editor.tail.type', 'TailTypeNew')

			@CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
			@CheckBox('gui.ppm2.editor.misc.hide_mane', 'HideManesMane')
			@CheckBox('gui.ppm2.editor.misc.hide_socks', 'HideManesSocks')
			@CheckBox('gui.ppm2.editor.misc.hide_tail', 'HideManesTail')

			@NumSlider('gui.ppm2.editor.tail.size', 'TailSize', 2)

			@Hr()
			@CheckBox('gui.ppm2.editor.mane.phong', 'SeparateManePhong') if ADVANCED_MODE\GetBool()
			PPM2.EditorPhongPanels(@, 'Mane', 'gui.ppm2.editor.mane.mane_phong') if ADVANCED_MODE\GetBool()
			@ColorBox("gui.ppm2.editor.mane.color#{i}", "ManeColor#{i}") for i = 1, 2
			@ColorBox('gui.ppm2.editor.tail.color' .. i, "TailColor#{i}") for i = 1, 2

			@Hr()
			@CheckBox('gui.ppm2.editor.tail.separate', 'SeparateTailPhong') if ADVANCED_MODE\GetBool()
			PPM2.EditorPhongPanels(@, 'Tail', 'gui.ppm2.editor.tail.tail_phong') if ADVANCED_MODE\GetBool()
			@ColorBox("gui.ppm2.editor.mane.detail_color#{i}", "ManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
			@ColorBox('gui.ppm2.editor.tail.detail' .. i, "TailDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

			return if not ADVANCED_MODE\GetBool()

			@Hr()
			@CheckBox('gui.ppm2.editor.mane.phong_sep', 'SeparateMane')
			PPM2.EditorPhongPanels(@, 'UpperMane', 'gui.ppm2.editor.mane.up.phong') if ADVANCED_MODE\GetBool()
			PPM2.EditorPhongPanels(@, 'LowerMane', 'gui.ppm2.editor.mane.down.phong') if ADVANCED_MODE\GetBool()

			@Hr()
			@ColorBox("gui.ppm2.editor.mane.up.color#{i}", "UpperManeColor#{i}") for i = 1, 2
			@ColorBox("gui.ppm2.editor.mane.down.color#{i}", "LowerManeColor#{i}") for i = 1, 2

			@Hr()
			@ColorBox("gui.ppm2.editor.mane.up.detail_color#{i}", "UpperManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
			@ColorBox("gui.ppm2.editor.mane.down.detail_color#{i}", "LowerManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
	}

	{
		'name': 'gui.ppm2.editor.tabs.face'
		'internal': 'face'
		'func': (sheet) =>
			@ScrollPanel()
			@ComboBox('gui.ppm2.editor.face.eyelashes', 'EyelashType')
			@ColorBox('gui.ppm2.editor.face.eyelashes_color', 'EyelashesColor')
			@ColorBox('gui.ppm2.editor.face.eyebrows_color', 'EyebrowsColor')

			if ADVANCED_MODE\GetBool()
				@CheckBox('gui.ppm2.editor.face.eyebrows_glow', 'GlowingEyebrows')
				@NumSlider('gui.ppm2.editor.face.eyebrows_glow_strength', 'EyebrowsGlowStrength', 2)

				@CheckBox('gui.ppm2.editor.face.eyelashes_separate_phong', 'SeparateEyelashesPhong')
				PPM2.EditorPhongPanels(@, 'Eyelashes', 'gui.ppm2.editor.face.eyelashes_phong')

			if IS_USING_NEW(@IsNewEditor())
				@CheckBox('gui.ppm2.editor.ears.bat', 'BatPonyEars')
				@NumSlider('gui.ppm2.editor.ears.bat', 'BatPonyEarsStrength', 2) if ADVANCED_MODE\GetBool()
				@CheckBox('gui.ppm2.editor.mouth.fangs', 'Fangs')
				@CheckBox('gui.ppm2.editor.mouth.alt_fangs', 'AlternativeFangs')
				@NumSlider('gui.ppm2.editor.mouth.fangs', 'FangsStrength', 2) if ADVANCED_MODE\GetBool()
				@CheckBox('gui.ppm2.editor.mouth.claw', 'ClawTeeth')
				@NumSlider('gui.ppm2.editor.mouth.claw', 'ClawTeethStrength', 2) if ADVANCED_MODE\GetBool()

				if ADVANCED_MODE\GetBool()
					@NumSlider('gui.ppm2.editor.ears.size', 'EarsSize', 2)
					@Hr()
					@ColorBox('gui.ppm2.editor.mouth.teeth', 'TeethColor')
					@ColorBox('gui.ppm2.editor.mouth.mouth', 'MouthColor')
					@ColorBox('gui.ppm2.editor.mouth.tongue', 'TongueColor')
					PPM2.EditorPhongPanels(@, 'Teeth', 'gui.ppm2.editor.mouth.teeth_phong')
					PPM2.EditorPhongPanels(@, 'Mouth', 'gui.ppm2.editor.mouth.mouth_phong')
					PPM2.EditorPhongPanels(@, 'Tongue', 'gui.ppm2.editor.mouth.tongue_phong')
	}

	{
		'name': 'gui.ppm2.editor.tabs.eyes'
		'internal': 'eyes'
		'func': (sheet) =>
			@ScrollPanel()
			if ADVANCED_MODE\GetBool()
				@Hr()
				@CheckBox('gui.ppm2.editor.eyes.separate', 'SeparateEyes')
			eyes = {''}
			eyes = {'', 'Left', 'Right'} if ADVANCED_MODE\GetBool()
			for _, publicName in ipairs eyes
				@Hr()

				prefix = ''
				tprefix = 'def'

				if publicName ~= ''
					tprefix = publicName\lower()
					prefix = publicName .. ' '

				@Label('gui.ppm2.editor.eyes.url')
				@URLInput("EyeURL#{publicName}")

				if ADVANCED_MODE\GetBool()
					@Label('gui.ppm2.editor.eyes.lightwarp_desc')
					ttype = publicName == '' and 'BEyes' or publicName == 'Left' and 'LEye' or 'REye'
					@CheckBox("gui.ppm2.editor.eyes.#{tprefix}.lightwarp.shader", "EyeRefract#{publicName}")
					@CheckBox("gui.ppm2.editor.eyes.#{tprefix}.lightwarp.cornera", "EyeCornerA#{publicName}")
					@ComboBox('gui.ppm2.editor.eyes.lightwarp', ttype .. 'Lightwarp')
					@Label('gui.ppm2.editor.eyes.desc1')
					@URLInput(ttype .. 'LightwarpURL')
					@Label('gui.ppm2.editor.eyes.desc2')
					@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.lightwarp.glossiness", 'EyeGlossyStrength' .. publicName, 2)

				@Label('gui.ppm2.editor.eyes.url_desc')

				@ComboBox("gui.ppm2.editor.eyes.#{tprefix}.type", "EyeType#{publicName}")
				@ComboBox("gui.ppm2.editor.eyes.#{tprefix}.reflection_type", "EyeReflectionType#{publicName}")
				@CheckBox("gui.ppm2.editor.eyes.#{tprefix}.lines", "EyeLines#{publicName}")
				@CheckBox("gui.ppm2.editor.eyes.#{tprefix}.derp", "DerpEyes#{publicName}")
				@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.derp_strength", "DerpEyesStrength#{publicName}", 2)
				@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.iris_size", "IrisSize#{publicName}", 2)

				if ADVANCED_MODE\GetBool()
					@CheckBox("gui.ppm2.editor.eyes.#{tprefix}.points_inside", "EyeLineDirection#{publicName}")
					@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.width", "IrisWidth#{publicName}", 2)
					@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.height", "IrisHeight#{publicName}", 2)

				@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.pupil.width", "HoleWidth#{publicName}", 2)
				@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.pupil.height", "HoleHeight#{publicName}", 2) if ADVANCED_MODE\GetBool()
				@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.pupil.size", "HoleSize#{publicName}", 2)

				if ADVANCED_MODE\GetBool()
					@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.pupil.shift_x", "HoleShiftX#{publicName}", 2)
					@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.pupil.shift_y", "HoleShiftY#{publicName}", 2)
					@NumSlider("gui.ppm2.editor.eyes.#{tprefix}.pupil.rotation", "EyeRotation#{publicName}", 0)

				@Hr()
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.background", "EyeBackground#{publicName}")
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.pupil_size", "EyeHole#{publicName}")
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.top_iris", "EyeIrisTop#{publicName}")
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.bottom_iris", "EyeIrisBottom#{publicName}")
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.line1", "EyeIrisLine1#{publicName}")
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.line2", "EyeIrisLine2#{publicName}")
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.reflection", "EyeReflection#{publicName}")
				@ColorBox("gui.ppm2.editor.eyes.#{tprefix}.effect", "EyeEffect#{publicName}")
	}

	{
		'name': 'gui.ppm2.editor.old_tabs.wings_and_horn_details'
		'internal': 'wings_horn_details'
		'display': (editorMode = false) -> ADVANCED_MODE\GetBool()
		'func': (sheet) =>
			@ScrollPanel()

			for i = 1, 3
				@Label('gui.ppm2.editor.horn.detail.desc' .. i)
				@URLInput("HornURL#{i}")
				@ColorBox('gui.ppm2.editor.horn.detail.color' .. i, "HornURLColor#{i}")
				@Hr()

			@Hr()
			@Label('gui.ppm2.editor.wings.normal')
			@Hr()

			for i = 1, 3
				@Label('gui.ppm2.editor.wings.details.def.detail' .. i)
				@URLInput("WingsURL#{i}")
				@ColorBox('gui.ppm2.editor.wings.details.def.color' .. i, "WingsURLColor#{i}")
				@Hr()

			@Label('gui.ppm2.editor.wings.bat')
			@Hr()

			for i = 1, 3
				@Label('gui.ppm2.editor.wings.details.bat.detail' .. i)
				@URLInput("BatWingURL#{i}")
				@ColorBox('gui.ppm2.editor.wings.details.bat.color' .. i, "BatWingURLColor#{i}")
				@Hr()

			@Label('gui.ppm2.editor.wings.bat_skin')
			@Hr()

			for i = 1, 3
				@Label('gui.ppm2.editor.wings.details.batskin.detail' .. i)
				@URLInput("BatWingSkinURL#{i}")
				@ColorBox('gui.ppm2.editor.wings.details.batskin.color' .. i, "BatWingSkinURLColor#{i}")
				@Hr()
	}

	{
		'name': 'gui.ppm2.editor.old_tabs.body_details'
		'internal': 'bodydetails'
		'func': (sheet) =>
			@ScrollPanel()

			for i = 1, ADVANCED_MODE\GetBool() and PPM2.MAX_BODY_DETAILS or 3
				@ComboBox('gui.ppm2.editor.body.detail.desc' .. i, "BodyDetail#{i}")
				@ColorBox('gui.ppm2.editor.body.detail.color' .. i, "BodyDetailColor#{i}")
				if ADVANCED_MODE\GetBool()
					@CheckBox('gui.ppm2.editor.body.detail.glow' .. i, "BodyDetailGlow#{i}")
					@NumSlider('gui.ppm2.editor.body.detail.glow_strength' .. i, "BodyDetailGlowStrength#{i}", 2)
				@Hr()

			@Label('gui.ppm2.editor.body.url_desc')
			@Hr()

			for i = 1, ADVANCED_MODE\GetBool() and PPM2.MAX_BODY_DETAILS or 2
				@Label('gui.ppm2.editor.body.detail.url.desc' .. i)
				@URLInput("BodyDetailURL#{i}")
				@ColorBox('gui.ppm2.editor.body.detail.url.color' .. i, "BodyDetailURLColor#{i}")
				@Hr()
	}

	{
		'name': 'gui.ppm2.editor.old_tabs.mane_tail_detals'
		'internal': 'manetail'
		'func': (sheet) =>
			@ScrollPanel()
			for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
				@Label("gui.ppm2.editor.url_mane.desc#{i}")
				@URLInput("ManeURL#{i}")
				@ColorBox("gui.ppm2.editor.url_mane.color#{i}", "ManeURLColor#{i}")
				@Hr()

			for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
				@Label("gui.ppm2.editor.url_tail.desc#{i}")
				@URLInput("TailURL#{i}")
				@ColorBox("gui.ppm2.editor.url_tail.color#{i}", "TailURLColor#{i}")
				@Hr()

			@Label('gui.ppm2.editor.mane.newnotice')
			@CheckBox('gui.ppm2.editor.mane.phong_sep', 'SeparateMane')
			for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
				@Hr()
				@Label("gui.ppm2.editor.url_mane.sep.up.desc#{i}")
				@URLInput("UpperManeURL#{i}")
				@ColorBox("gui.ppm2.editor.url_mane.sep.up.color#{i}", "UpperManeURLColor#{i}")

			for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
				@Hr()
				@Label("gui.ppm2.editor.url_mane.sep.down.desc#{i}")
				@URLInput("LowerManeURL#{i}")
				@ColorBox("gui.ppm2.editor.url_mane.sep.down.color#{i}", "LowerManeURLColor#{i}")
	}

	{
		'name': 'gui.ppm2.editor.tabs.tattoos'
		'internal': 'tattoos'
		'display': -> ADVANCED_MODE\GetBool()
		'func': (sheet) =>
			@ScrollPanel()

			for i = 1, PPM2.MAX_TATTOOS
				spoiler = @Spoiler('gui.ppm2.editor.tattoo.layer' .. i)
				updatePanels = {}
				@Button('gui.ppm2.editor.tattoo.edit_keyboard', (-> @GetFrame()\EditTattoo(i, updatePanels)), spoiler)
				@ComboBox('gui.ppm2.editor.tattoo.type', "TattooType#{i}", nil, spoiler)
				table.insert(updatePanels, @NumSlider('gui.ppm2.editor.tattoo.tweak.rotate', "TattooRotate#{i}", 0, spoiler))
				table.insert(updatePanels, @NumSlider('gui.ppm2.editor.tattoo.tweak.x', "TattooPosX#{i}", 2, spoiler))
				table.insert(updatePanels, @NumSlider('gui.ppm2.editor.tattoo.tweak.y', "TattooPosY#{i}", 2, spoiler))
				table.insert(updatePanels, @NumSlider('gui.ppm2.editor.tattoo.tweak.width', "TattooScaleX#{i}", 2, spoiler))
				table.insert(updatePanels, @NumSlider('gui.ppm2.editor.tattoo.tweak.height', "TattooScaleY#{i}", 2, spoiler))
				@CheckBox('gui.ppm2.editor.tattoo.over', "TattooOverDetail#{i}", spoiler)
				@CheckBox('gui.ppm2.editor.tattoo.glow', "TattooGlow#{i}", spoiler)
				@NumSlider('gui.ppm2.editor.tattoo.glow_strength', "TattooGlowStrength#{i}", 2, spoiler)
				box, collapse = @ColorBox('gui.ppm2.editor.tattoo.color', "TattooColor#{i}", spoiler)
				collapse\SetExpanded(true)
	}

	{
		'name': 'gui.ppm2.editor.tabs.cutiemark'
		'internal': 'cmark'
		'func': (sheet) =>
			@CheckBox('gui.ppm2.editor.cutiemark.display', 'CMark')
			@ComboBox('gui.ppm2.editor.cutiemark.type', 'CMarkType')
			@markDisplay = vgui.Create('EditablePanel', @)
			with @markDisplay
				\Dock(TOP)
				\SetSize(320, 320)
				\DockMargin(20, 20, 20, 20)
				.currentColor = BackgroundColors[1]
				.lerpChange = 0
				.colorIndex = 2
				.nextColor = BackgroundColors[2]
				.Paint = (pnl, w = 0, h = 0) ->
					data = @GetTargetData()
					return if not data
					controller = data\GetController()
					return if not controller
					rcontroller = controller\GetRenderController()
					return if not rcontroller
					tcontroller = rcontroller\GetTextureController()
					return if not tcontroller
					mat = tcontroller\GetCMarkGUI()
					return if not mat
					.lerpChange += RealFrameTime() / 4
					if .lerpChange >= 1
						.lerpChange = 0
						.currentColor = BackgroundColors[.colorIndex]
						.colorIndex += 1
						if .colorIndex > #BackgroundColors
							.colorIndex = 1
						.nextColor = BackgroundColors[.colorIndex]
					{r: r1, g: g1, b: b1} = .currentColor
					{r: r2, g: g2, b: b2} = .nextColor
					r, g, b = r1 + (r2 - r1) * .lerpChange, g1 + (g2 - g1) * .lerpChange, r1 + (b2 - b1) * .lerpChange
					surface.SetDrawColor(r, g, b, 100)
					surface.DrawRect(0, 0, w, h)
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(mat)
					surface.DrawTexturedRect(0, 0, w, h)

			@NumSlider('gui.ppm2.editor.cutiemark.size', 'CMarkSize', 2)
			@ColorBox('gui.ppm2.editor.cutiemark.color', 'CMarkColor')
			@Hr()
			@Label('gui.ppm2.editor.cutiemark.input')\DockMargin(5, 10, 5, 10)
			@URLInput('CMarkURL')
	}

	{
		'name': 'gui.ppm2.editor.tabs.files'
		'internal': 'saves'
		'func': PPM2.EditorBuildNewFilesPanel

	}

	{
		'name': 'gui.ppm2.editor.tabs.old_files'
		'internal': 'oldsaves'
		'func': PPM2.EditorBuildOldFilesPanel
	}

	{
		'name': 'gui.ppm2.editor.tabs.about'
		'internal': 'about'
		'func': (sheet) =>
			title = @Label('PPM/2')
			title\SetFont('PPM2.Title')
			title\SizeToContents()
			@URLLabel('gui.ppm2.editor.info.discord', 'https://discord.gg/HG9eS79')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.ponyscape', 'http://steamcommunity.com/groups/Ponyscape')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.creator', 'https://steamcommunity.com/profiles/76561198077439269')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.newmodels', 'https://steamcommunity.com/profiles/76561198013875404')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.cppmmodels', 'http://steamcommunity.com/profiles/76561198084938735')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.oldmodels', 'https://github.com/ChristinaTech/PonyPlayerModels')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.bugs', 'https://gitlab.com/DBotThePony/PPM2/issues')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.sources', 'https://gitlab.com/DBotThePony/PPM2')\SetFont('PPM2.AboutLabels')
			@URLLabel('gui.ppm2.editor.info.githubsources', 'https://github.com/roboderpy/PPM2')\SetFont('PPM2.AboutLabels')
			@Label('gui.ppm2.editor.info.thanks')\SetFont('PPM2.AboutLabels')
	}
}

if IsValid(PPM2.OldEditorFrame)
	PPM2.OldEditorFrame\Remove()
	net.Start('PPM2.EditorStatus')
	net.WriteBool(false)
	net.SendToServer()

if IsValid(PPM2.EditorTopFrame)
	PPM2.EditorTopFrame\Remove()
	net.Start('PPM2.EditorStatus')
	net.WriteBool(false)
	net.SendToServer()

STRETCHING_PANEL = {
	Init: =>
		@size = PANEL_WIDTH\GetInt()
		@isize = PANEL_WIDTH\GetInt()
		@SetSize(8, 0)
		@SetCursor('sizewe')
		@SetMouseInputEnabled(true)
		@hold = false
		@MINS = 200
		@MAXS = 600
		@posx, @posy = 0, 0
	OnMousePressed: (key = MOUSE_LEFT) =>
		return if key ~= MOUSE_LEFT
		@hold = true
		@posx, @posy = @LocalToScreen(0, 0)
		@posx += 3
		@isize = @size
	OnMouseReleased: (key = MOUSE_LEFT) =>
		return if key ~= MOUSE_LEFT
		@hold = false
		RunConsoleCommand('ppm2_editor_width', @size)
	Think: =>
		return if not @hold
		x, y = gui.MousePos()
		@size = @isize + x - @posx
		@target\SetSize(@size, 0) if @size ~= @isize
	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(35, 175, 99)
		surface.DrawRect(0, 0, w, h)
}

vgui.Register('PPM2.Editor.Stretch', STRETCHING_PANEL, 'EditablePanel')

local cl_playermodel

PPM2.EditorCreateTopButtons = (isNewEditor = false, addFullbright = false) =>
	oldPerformLayout = @PerformLayout or (->)

	saveAs = (callback = (->)) ->
		confirm = (txt = '') ->
			txt = txt\Trim()
			return if txt == ''
			@data\SetFilename(txt)
			@data\Save()
			@unsavedChanges = false
			@model.unsavedChanges = false if IsValid(@model)
			@SetTitle('gui.ppm2.editor.generic.title_file', @data\GetFilename() or '%ERRNAME%')
			@panels.saves.rebuildFileList() if @panels and @panels.saves and @panels.saves.rebuildFileList
			@saves.rebuildFileList() if @saves and @saves.rebuildFileList
			callback(txt)
		Derma_StringRequest('gui.ppm2.editor.io.save.button', 'gui.ppm2.editor.io.save.text', @data\GetFilename(), confirm)

	with @saveButton = vgui.Create('DButton', @)
		\SetText('gui.ppm2.editor.io.save.button')
		\SetSize(90, 20)
		.DoClick = -> saveAs()

	with @wearButton = vgui.Create('DButton', @)
		\SetText('gui.ppm2.editor.io.wear')
		\SetSize(140, 20)
		lastWear = 0
		.DoClick = ->
			return if RealTimeL() < lastWear
			lastWear = RealTimeL() + 5
			mainData = PPM2.GetMainData()
			nwdata = LocalPlayer()\GetPonyData()
			if nwdata
				mainData\SetNetworkData(nwdata)
				if nwdata.netID == -1
					nwdata.NETWORKED = false
					nwdata\Create()
			@data\ApplyDataToObject(mainData, false) -- no save on apply
			cl_playermodel = cl_playermodel or GetConVar('cl_playermodel')
			RunConsoleCommand('cl_playermodel', 'pony') if not cl_playermodel\GetString()\find('pony')

	if not isNewEditor
		editorModelSelect = USE_MODEL\GetString()\upper()
		editorModelSelect = EditorModels[editorModelSelect] and editorModelSelect or 'DEFAULT'
		with @selectModelBox = vgui.Create('DComboBox', @)
			\SetSize(120, 20)
			\SetValue(editorModelSelect)
			\AddChoice(choice) for _, choice in ipairs {'default', 'cppm', 'new'}
			.OnSelect = (pnl = box, index = 1, value = '', data = value) ->
				@SetDeleteOnClose(true)
				RunConsoleCommand('ppm2_editor_model', value)

				confirm = ->
					@Close()
					timer.Simple 0.1, PPM2.OpenOldEditor
				Derma_Query(
					'gui.ppm2.editor.generic.restart.text',
					'gui.ppm2.editor.generic.restart.needed',
					'gui.ppm2.editor.generic.yes',
					confirm,
					'gui.ppm2.editor.generic.no'
				)

	with @enableAdvanced = vgui.Create('DCheckBoxLabel', @)
		\SetSize(120, 20)
		\SetConVar('ppm2_editor_advanced')
		\SetText('Advanced mode')
		.ingore = true
		.OnChange = (pnl = box, newVal) ->
			return if newVal == ADVANCED_MODE\GetBool()
			@SetDeleteOnClose(true)
			confirm = ->
				@Close()
				timer.Simple 0.1, PPM2.OpenEditor
			Derma_Query(
				'gui.ppm2.editor.generic.restart.text',
				'gui.ppm2.editor.generic.restart.needed',
				'gui.ppm2.editor.generic.yes',
				confirm,
				'gui.ppm2.editor.generic.no'
			)

	if not isNewEditor or addFullbright
		with @fullbrightSwitch = vgui.Create('DCheckBoxLabel', @)
			\SetSize(120, 20)
			\SetConVar('ppm2_editor_fullbright')
			\SetText('gui.ppm2.editor.generic.fullbright')

	@PerformLayout = (W = 0, H = 0) =>
		oldPerformLayout(@, w, h)
		@wearButton\SetPos(W - 350, 5)
		@saveButton\SetPos(W - 205, 5)
		@enableAdvanced\SetPos(W - 590, 7)
		@fullbrightSwitch\SetPos(W - 700, 7) if IsValid(@fullbrightSwitch)
		@selectModelBox\SetPos(W - 475, 5) if IsValid(@selectModelBox)

PPM2.OpenNewEditor = ->
	if IsValid(PPM2.EditorTopFrame)
		with PPM2.EditorTopFrame
			if .TargetModel ~= LocalPlayer()\GetModel()
				\Remove()
				return PPM2.OpenNewEditor()
			\SetVisible(true)
			.controller = LocalPlayer()\GetPonyData() or .controller
			.data\ApplyDataToObject(.controller, false)
			.data\SetNetworkData(.controller)
			.leftPanel\SetVisible(true)
			.calcPanel\SetVisible(true)
			net.Start('PPM2.EditorStatus')
			net.WriteBool(true)
			net.SendToServer()
		return

	ply = LocalPlayer()
	controller = ply\GetPonyData()
	if not controller
		Derma_Message('gui.ppm2.editor.generic.wtf', 'gui.ppm2.editor.generic.ohno', 'gui.ppm2.editor.generic.okay')
		return

	PPM2.EditorTopFrame = vgui.Create('EditablePanel')
	PPM2.EditorTopFrame\SetSkin('DLib_Black')
	self = PPM2.EditorTopFrame
	topframe = PPM2.EditorTopFrame
	@SetPos(0, 0)
	@MakePopup()
	topSize = 55
	@SetSize(ScrW(), topSize)
	sysTime = SysTime()

	@TargetModel = LocalPlayer()\GetModel()

	@btnClose = vgui.Create('DButton', @)
	@btnClose\SetText('')
	@btnClose.DoClick = -> @Close()
	@btnClose.Paint = (w = 0, h = 0) => derma.SkinHook('Paint', 'WindowCloseButton', @, w, h)
	@btnClose\SetSize(31, 31)
	@btnClose\SetPos(ScrW() - 40, 0)

	@Paint = (w = 0, h = 0) => derma.SkinHook('Paint', 'Frame', @, w, h)
	@DockPadding(5, 29, 5, 5)
	PPM2.EditorCreateTopButtons(@, true)

	@lblTitle = vgui.Create('DLabel', @)
	@lblTitle\SetPos(5, 0)
	@lblTitle\SetSize(300, 20)
	@SetTitle = (text = '', ...) => @lblTitle\SetText(text, ...)
	@GetTitle = => @lblTitle\GetText()
	@deleteOnClose = false
	@SetDeleteOnClose = (val = false) => @deleteOnClose = val

	@Close = =>
		data = PPM2.GetMainData()
		data\ApplyDataToObject(@controller, false)
		@SetVisible(false)
		@leftPanel\SetVisible(false)
		@calcPanel\SetVisible(false)
		net.Start('PPM2.EditorStatus')
		net.WriteBool(false)
		net.SendToServer()
		if @deleteOnClose
			@Remove()

	@OnRemove = =>
		@leftPanel\Remove()
		@calcPanel\Remove()

	@calcPanel = vgui.Create('PPM2CalcViewPanel')
	@calcPanel\SetPos(350, topSize)
	@calcPanel\SetRealPos(350, topSize)
	@calcPanel\SetSize(ScrW() - 350, ScrH() - topSize)
	@calcPanel\SetRealSize(ScrW() - 350, ScrH() - topSize)
	@calcPanel\MakePopup()
	@calcPanel\SetSkin('DLib_Black')
	@MakePopup()

	@leftPanel = vgui.Create('EditablePanel')
	@leftPanel\SetPos(0, topSize)
	@leftPanel\SetSize(350, ScrH() - topSize)
	@leftPanel\SetMouseInputEnabled(true)
	@leftPanel\SetKeyboardInputEnabled(true)
	@leftPanel\MakePopup()
	@leftPanel\SetSkin('DLib_Black')

	@menus = vgui.Create('DPropertySheet', @leftPanel)
	@menus\Dock(FILL)
	@menus\SetSize(PANEL_WIDTH\GetInt(), 0)
	@menusBar = @menus.tabScroller
	@menusBar\SetParent(@)
	@menusBar\Dock(FILL)
	@menusBar\SetSize(0, 20)

	copy = PPM2.GetMainData()\Copy()
	@controller = controller
	copy\SetNetworkData(@controller)
	copy\SetNetworkOnChange(false)
	@data = copy
	@DoUpdate = -> pnl\DoUpdate() for i, pnl in pairs @panels

	@SetTitle('gui.ppm2.editor.generic.title_file', copy\GetFilename() or '%ERRNAME%')

	@EditTattoo = (index = 1, panelsToUpdate = {}) =>
		editor = vgui.Create('PPM2TattooEditor')
		editor\SetTargetData(copy)
		editor\SetTargetID(index)
		editor\SetPanelsToUpdate(panelsToUpdate)

	@panels = {}

	createdPanels = 9

	for _, {:name, :func, :internal, :display} in ipairs EditorPages
		continue if display and not display(true)
		pnl = vgui.Create('PPM2SettingsBase', @menus)
		@menus\AddSheet(name, pnl)
		pnl\SetIsNewEditor(true)
		pnl\SetTargetData(copy)
		pnl\Dock(FILL)
		pnl.frame = @
		pnl.Populate = -> func(pnl, @menus)
		@panels[internal] = pnl

	@leftPanel\MakePopup()
	@MakePopup()

	net.Start('PPM2.EditorStatus')
	net.WriteBool(true)
	net.SendToServer()

	iTime = math.floor((SysTime() - sysTime) * 1000)
	-- PPM2.Message('Initialized Pony editor in ', iTime, ' milliseconds (created nearly ', createdPanels, ' panels). Look how slow your PC is xd')

PPM2.OpenOldEditor = ->
	if IsValid(PPM2.OldEditorFrame)
		PPM2.OldEditorFrame\SetVisible(true)
		PPM2.OldEditorFrame\Center()
		PPM2.OldEditorFrame\MakePopup()
		net.Start('PPM2.EditorStatus')
		net.WriteBool(true)
		net.SendToServer()
		return

	sysTime = SysTime()
	frame = vgui.Create('DLib_Window')
	self = frame
	W, H = ScrW() - 25, ScrH() - 25
	@SetSize(W, H)
	@Center()
	@SetDeleteOnClose(false)
	PPM2.OldEditorFrame = @

	@OnClose = ->
		net.Start('PPM2.EditorStatus')
		net.WriteBool(false)
		net.SendToServer()

	@menus = vgui.Create('DPropertySheet', @)
	@menus\Dock(LEFT)
	@menus\SetSize(PANEL_WIDTH\GetInt(), 0)
	@menusBar = @menus.tabScroller
	@menusBar\SetParent(@)
	@menusBar\Dock(TOP)
	@menusBar\SetSize(0, 20)

	@stretch = vgui.Create('PPM2.Editor.Stretch', @)
	@stretch\Dock(LEFT)
	@stretch\DockMargin(5, 0, 0, 0)
	@stretch.target = @menus

	@model = vgui.Create('PPM2ModelPanel', @)
	@model\Dock(FILL)

	copy = PPM2.GetMainData()\Copy()
	ply = LocalPlayer()
	editorModelSelect = USE_MODEL\GetString()\upper()
	editorModelSelect = EditorModels[editorModelSelect] and editorModelSelect or 'DEFAULT'
	ent = @model\ResetModel(nil, EditorModels[editorModelSelect])
	controller = copy\CreateCustomController(ent)
	controller\SetFlexLerpMultiplier(1.3)
	copy\SetController(controller)
	frame.controller = controller
	frame.data = copy
	frame.DoUpdate = -> pnl\DoUpdate() for i, pnl in pairs @panels

	PPM2.EditorCreateTopButtons(@)

	@SetTitle('gui.ppm2.editor.generic.title_file', copy\GetFilename() or '%ERRNAME%')

	@model\SetController(controller)
	controller\SetupEntity(ent)
	controller\SetDisableTask(true)

	@EditTattoo = (index = 1, panelsToUpdate = {}) =>
		editor = vgui.Create('PPM2TattooEditor')
		editor\SetTargetData(copy)
		editor\SetTargetID(index)
		editor\SetPanelsToUpdate(panelsToUpdate)

	@panels = {}

	createdPanels = 17

	for _, {:name, :func, :internal, :display} in ipairs EditorPages
		continue if display and not display(false)
		pnl = vgui.Create('PPM2SettingsBase', @menus)
		@menus\AddSheet(name, pnl)
		pnl\SetTargetData(copy)
		pnl\Dock(FILL)
		pnl.frame = @
		pnl.Populate = -> func(pnl, @menus)
		@panels[internal] = pnl

	net.Start('PPM2.EditorStatus')
	net.WriteBool(true)
	net.SendToServer()

	iTime = math.floor((SysTime() - sysTime) * 1000)
	-- PPM2.Message('Initialized Pony editor in ', iTime, ' milliseconds (created nearly ', createdPanels, ' panels). Look how slow your PC is xd')

PPM2.OpenEditor = ->
	if LocalPlayer()\IsPony()
		PPM2.OpenNewEditor()
	else
		PPM2.OpenOldEditor()

concommand.Add 'ppm2_editor', PPM2.OpenEditor
concommand.Add 'ppm2_new_editor', PPM2.OpenNewEditor
concommand.Add 'ppm2_old_editor', PPM2.OpenOldEditor
concommand.Add 'ppm2_old_editor_reload', -> PPM2.OldEditorFrame\Remove() if IsValid(PPM2.OldEditorFrame)
concommand.Add 'ppm2_new_editor_reload', -> PPM2.EditorTopFrame\Remove() if IsValid(PPM2.EditorTopFrame)
concommand.Add 'ppm2_editor_reload', ->
	PPM2.OldEditorFrame\Remove() if IsValid(PPM2.OldEditorFrame)
	PPM2.EditorTopFrame\Remove() if IsValid(PPM2.EditorTopFrame)
	PPM2.EDITOR3\Remove() if IsValid(PPM2.EDITOR3)

IconData =
	title: 'PPM/2 Editor',
	icon: 'gui/ppm2_icon.png',
	width: 960,
	height: 700,
	onewindow: true,
	init: (icon, window) ->
		window\Remove()
		RunConsoleCommand('ppm2_editor')

list.Set('DesktopWindows', 'PPM2', IconData)
CreateContextMenu() if IsValid(g_ContextMenu)

hook.Add 'PopulateToolMenu', 'PPM2.PonyPosing', -> spawnmenu.AddToolMenuOption 'Utilities', 'User', 'PPM2.Posing', 'PPM2', '', '', =>
	return if not @IsValid()
	@Clear()
	@Button 'gui.ppm2.spawnmenu.newmodel', 'gm_spawn', 'models/ppm/player_default_base_new.mdl'
	@Button 'gui.ppm2.spawnmenu.newmodelnj', 'gm_spawn', 'models/ppm/player_default_base_new_nj.mdl'
	@Button 'gui.ppm2.spawnmenu.oldmodel', 'gm_spawn', 'models/ppm/player_default_base.mdl'
	@Button 'gui.ppm2.spawnmenu.oldmodelnj', 'gm_spawn', 'models/ppm/player_default_base_nj.mdl'
	@Button 'gui.ppm2.spawnmenu.cppmmodel', 'gm_spawn', 'models/cppm/player_default_base.mdl'
	@Button 'gui.ppm2.spawnmenu.cppmmodelnj', 'gm_spawn', 'models/cppm/player_default_base_nj.mdl'
	@Button 'gui.ppm2.spawnmenu.cleanup', 'ppm2_cleanup'
	@Button 'gui.ppm2.spawnmenu.reload', 'ppm2_reload'
	@Button 'gui.ppm2.spawnmenu.require', 'ppm2_require'
	@CheckBox 'gui.ppm2.spawnmenu.drawhooves', 'ppm2_cl_draw_hands'
	@CheckBox 'gui.ppm2.spawnmenu.nohoofsounds', 'ppm2_cl_no_hoofsound'
	@CheckBox 'gui.ppm2.spawnmenu.noflexes', 'ppm2_disable_flexes'
	@CheckBox 'gui.ppm2.spawnmenu.advancedmode', 'ppm2_editor_advanced'
	@CheckBox 'gui.ppm2.spawnmenu.reflections', 'ppm2_cl_reflections'
	@NumSlider 'gui.ppm2.spawnmenu.reflections_drawdist', 'ppm2_cl_reflections_drawdist', 0, 1024, 0
	@NumSlider 'gui.ppm2.spawnmenu.reflections_renderdist', 'ppm2_cl_reflections_renderdist', 32, 4096, 0
	@CheckBox 'gui.ppm2.spawnmenu.doublejump', 'ppm2_flight_djump'
