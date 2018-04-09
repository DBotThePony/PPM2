
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

ENABLE_FULLBRIGHT = CreateConVar('ppm2_editor_fullbright', '1', {FCVAR_ARCHIVE}, 'Disable lighting in editor')

MODEL_BOX_PANEL = {
	SEQUENCE_STAND: 22
	PONY_VEC_Z: 64 * .7

	SEQUENCES: {
		'Standing':    22
		'Moving':      316
		'Walking':     232
		'Sit':         202
		'Swim':        370
		'Run':         328
		'Crouch walk': 286
		'Crouch':      76
		'Jump':        160
	}

	Init: =>
		@animRate = 1
		@seq = @SEQUENCE_STAND
		@hold = false
		@canHold = true
		@lastTick = RealTimeL()

		@holdLast = 0
		@mouseX, @mouseY = 0, 0

		@angle = Angle(0, 0, 0)
		@distToPony = 100
		@vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)
		@targetPos = Vector(0, 0, @PONY_VEC_Z * .7)

		@SetCursor('none')
		@SetMouseInputEnabled(true)

		@buildingModel = ClientsideModel('models/ppm/ppm2_stage.mdl', RENDERGROUP_OTHER)
		@buildingModel\SetNoDraw(true)
		@buildingModel\SetModelScale(0.9)

		with @seqButton = vgui.Create('DComboBox', @)
			\SetSize(120, 20)
			\SetValue('Standing')
			\AddChoice(choice, num) for choice, num in pairs @SEQUENCES
			.OnSelect = (pnl = box, index = 1, value = '', data = value) -> @SetSequence(data)

		with @emotesPanel = PPM2.CreateEmotesPanel(@, @model, false)
			\SetPos(10, 40)
			\SetMouseInputEnabled(true)
			\SetVisible(true)

	ResetPosition: =>
		@angle = Angle(0, 0, 0)
		@distToPony = 100
		@vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)

	PerformLayout: (w = 0, h = 0) =>
		@seqButton\SetPos(10, 10)
		@emotesPanel\SetPos(10, 40) if IsValid(@emotesPanel)

	OnMousePressed: (code = MOUSE_LEFT) =>
		return if code ~= MOUSE_LEFT
		if @canHold
			@hold = true
			@SetCursor('sizeall')
			@holdLast = RealTimeL() + .1
			@mouseX, @mouseY = gui.MousePos()

	OnMouseReleased: (code = MOUSE_LEFT) =>
		return if code ~= MOUSE_LEFT
		if @canHold
			@hold = false
			@SetCursor('none')

	SetController: (val) => @controller = val

	OnMouseWheeled: (wheelDelta = 0) =>
		if @canHold
			@distToPony = math.clamp(@distToPony - wheelDelta * 10, 20, 150)

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

	ResetModel: (ponydata, model = 'models/ppm/player_default_base_new.mdl') =>
		@model\Remove() if IsValid(@model)

		with @model = ClientsideModel(model)
			\SetNoDraw(true)
			.__PPM2_PonyData = ponydata
			\SetSequence(@seq)
			\FrameAdvance(0)

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
			{:pitch, :yaw, :roll} = @angle
			yaw -= deltaX * .5
			pitch = math.clamp(pitch - deltaY * .5, -40, 10)
			@angle = Angle(pitch, yaw, roll)

		@vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)
		@vectorPos\Rotate(@angle)
		@drawAngle = (@targetPos - @vectorPos)\Angle()

	FLOOR_VECTOR: Vector(0, 0, -30)
	FLOOR_ANGLE: Vector(0, 0, 1)

	DRAW_WALLS: {
		{Vector(-4000, 0, 900), Vector(1, 0, 0), 8000, 2000}
		{Vector(4000, 0, 900), Vector(-1, 0, 0), 8000, 2000}
		{Vector(0, -4000, 900), Vector(0, 1, 0), 8000, 2000}
		{Vector(0, 4000, 900), Vector(0, -1, 0), 8000, 2000}
		{Vector(0, 0, 900), Vector(0, 0, -1), 8000, 8000}
	}

	--WALL_COLOR: Color(98, 189, 176)
	--FLOOR_COLOR: Color(53, 150, 84)

	WALL_COLOR: Color() - 255
	FLOOR_COLOR: Color() - 255

	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)
		return if not IsValid(@model)
		x, y = @LocalToScreen(0, 0)
		cam.Start3D(@vectorPos, @drawAngle, 90, x, y, w, h)

		render.DrawQuadEasy(@FLOOR_VECTOR, @FLOOR_ANGLE, 7000, 7000, @FLOOR_COLOR)

		for {pos, ang, w, h} in *@DRAW_WALLS
			render.DrawQuadEasy(pos, ang, w, h, @WALL_COLOR)

		if ENABLE_FULLBRIGHT\GetBool()
			render.SuppressEngineLighting(true)
			render.ResetModelLighting(1, 1, 1)
			render.SetColorModulation(1, 1, 1)

		--@buildingModel\DrawModel()
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

vgui.Register('PPM2Model2Panel', MODEL_BOX_PANEL, 'EditablePanel')

ppm2_editor3 = ->
	if IsValid(PPM2.EDITOR3)
		PPM2.EDITOR3\SetVisible(true)
		PPM2.EDITOR3\MakePopup()
		return PPM2.EDITOR3
	PPM2.EDITOR3 = vgui.Create('DLib_Window')
	self = PPM2.EDITOR3
	@SetSize(ScrWL(), ScrHL())
	@SetPos(0, 0)
	@MakePopup()
	@SetTitle('PPM/2 Editor/3')

	with @modelPanel = vgui.Create('PPM2Model2Panel', @)
		\Dock(FILL)
		\DockMargin(10, 10, 10, 10)

	copy = PPM2.GetMainData()\Copy()
	ply = LocalPlayer()
	ent = @modelPanel\ResetModel()

	controller = copy\CreateCustomController(ent)
	controller\SetFlexLerpMultiplier(1.3)
	copy\SetController(controller)

	@modelPanel\SetController(controller)
	controller\SetupEntity(ent)
	controller\SetDisableTask(true)

concommand.Add 'ppm2_editor3', ppm2_editor3
