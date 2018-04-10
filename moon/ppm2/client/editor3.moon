
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

local EDIT_TREE

inRadius = (val, min, max) -> val >= min and val <= max
inBox = (pointX, pointY, x, y, w, h) -> inRadius(pointX, x - w, x + w) and inRadius(pointY, y - h, y + h)

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
		@holdRightClick = false
		@canHold = true
		@lastTick = RealTimeL()

		@holdLast = 0
		@mouseX, @mouseY = 0, 0

		@angle = Angle(0, 0, 0)
		@distToPony = 90
		@trackBone = -1
		@trackBoneName = 'LrigSpine2'
		@trackAttach = -1
		@trackAttachName = ''
		@shouldAutoTrack = true
		@autoTrackPos = Vector(0, 0, 0)
		@fixedDistanceToPony = 100

		@vectorPos = Vector(@fixedDistanceToPony, 0, 0)
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

	UpdateAttachsIDs: =>
		@trackBone = @model\LookupBone(@trackBoneName) or -1 if @trackBoneName ~= ''
		@trackAttach = @model\LookupAttachment(@trackAttachName) or -1 if @trackAttachName ~= ''
	GetTrackedPosition: =>
		return @autoTrackPos if @shouldAutoTrack
		return @targetPos

	PerformLayout: (w = 0, h = 0) =>
		@seqButton\SetPos(10, 10)
		@emotesPanel\SetPos(10, 40)

	OnMousePressed: (code = MOUSE_LEFT) =>
		if code == MOUSE_LEFT and @canHold
			@hold = true
			@SetCursor('sizeall')
			@holdLast = RealTimeL() + .1
			@mouseX, @mouseY = gui.MousePos()
		elseif code == MOUSE_RIGHT
			@holdRightClick = true

	OnMouseReleased: (code = MOUSE_LEFT) =>
		if code == MOUSE_LEFT and @canHold
			@hold = false
			@SetCursor('none')
		elseif code == MOUSE_RIGHT
			@holdRightClick = false

	SetController: (val) => @controller = val

	OnMouseWheeled: (wheelDelta = 0) =>
		if @canHold
			@distToPony = math.clamp(@distToPony - wheelDelta * 10, 20, 150)

	GetModel: => @model
	GetSequence: => @seq
	GetAnimRate: => @animRate
	SetAnimRate: (val = 1) => @animRate = val
	SetSequence: (val = @SEQUENCE_STAND) =>
		@seq = val
		@model\SetSequence(@seq) if IsValid(@model)

	ResetSequence: => @SetSequence(@SEQUENCE_STAND)
	ResetSeq: => @SetSequence(@SEQUENCE_STAND)

	PushMenu: (menu) =>
		table.insert(@stack, menu)
		return @

	PopMenu: =>
		assert(#@stack > 1, 'invalid stack size to pop from')
		table.remove(@stack)
		return @

	CurrentMenu: => @stack[#@stack]
	InRoot: => #@stack == 1

	ResetModel: (ponydata, model = 'models/ppm/player_default_base_new.mdl') =>
		@model\Remove() if IsValid(@model)

		with @model = ClientsideModel(model)
			\SetNoDraw(true)
			.__PPM2_PonyData = ponydata
			\SetSequence(@seq)
			\FrameAdvance(0)
			\SetPos(Vector())
			\InvalidateBoneCache()

		@UpdateAttachsIDs()
		return @model

	Think: =>
		rtime = RealTimeL()
		delta = rtime - @lastTick
		@lastTick = rtime

		if IsValid(@model)
			@model\FrameAdvance(delta * @animRate)
			@model\SetPlaybackRate(1)
			@model\SetPoseParameter('move_x', 1)

			if @shouldAutoTrack
				if @trackAttach ~= -1
					{:Ang, :Pos} = @model\GetAttachment(@trackAttach)
					@autoTrackPos = Pos or Vector()
				elseif @trackBone ~= -1
					@autoTrackPos = @model\GetBonePosition(@trackBone) or Vector()
				else
					@shouldAutoTrack = false

		@hold = @IsHovered() if @hold

		if @hold
			x, y = gui.MousePos()
			deltaX, deltaY = x - @mouseX, y - @mouseY
			@mouseX, @mouseY = x, y
			{:pitch, :yaw, :roll} = @angle
			yaw -= deltaX * .5
			pitch = math.clamp(pitch - deltaY * .5, -45, 45)
			@angle = Angle(pitch, yaw % 360, roll)

		@vectorPos = Vector(@fixedDistanceToPony, 0, 0)
		@vectorPos\Rotate(@angle)
		@drawAngle = Angle(-@angle.p, @angle.y - 180)

	FLOOR_VECTOR: Vector(0, 0, -30)
	FLOOR_ANGLE: Vector(0, 0, 1)

	DRAW_WALLS: {
		{Vector(-4000, 0, 900), Vector(1, 0, 0), 8000, 2000}
		{Vector(4000, 0, 900), Vector(-1, 0, 0), 8000, 2000}
		{Vector(0, -4000, 900), Vector(0, 1, 0), 8000, 2000}
		{Vector(0, 4000, 900), Vector(0, -1, 0), 8000, 2000}
		{Vector(0, 0, 900), Vector(0, 0, -1), 8000, 8000}
	}

	WALL_COLOR: Color() - 255
	FLOOR_COLOR: Color() - 255
	EMPTY_VECTOR: Vector()

	Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)
		return if not IsValid(@model)
		x, y = @LocalToScreen(0, 0)
		drawpos = @vectorPos + @GetTrackedPosition()
		cam.Start3D(drawpos, @drawAngle, @distToPony, x, y, w, h)

		if @holdRightClick
			@model\SetEyeTarget(drawpos)
		else
			@model\SetEyeTarget(@EMPTY_VECTOR)

		render.DrawQuadEasy(@FLOOR_VECTOR, @FLOOR_ANGLE, 7000, 7000, @FLOOR_COLOR)

		for {pos, ang, w, h} in *@DRAW_WALLS
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

		menu = @CurrentMenu()
		local positions

		if type(menu.points) == 'table'
			positions = [point.getpos(@model)\ToScreen() for point in *menu.points]

		cam.End3D()

		if positions
			lx, ly = x, y
			mx, my = gui.MousePos()
			mx, my = mx - lx, my - ly
			radius = ScreenScale(10)

			for {:x, :y} in *positions
				x, y = x - lx, y - ly

				if inBox(mx, my, x, y, radius, radius)
					surface.SetDrawColor(255, 255, 255)
				else
					surface.SetDrawColor(100, 100, 100)

				surface.DrawLine(x - radius, y - radius, x + radius, y + radius)
				surface.DrawLine(x + radius, y - radius, x - radius, y + radius)

	OnRemove: =>
		@model\Remove() if IsValid(@model)
		@buildingModel\Remove() if IsValid(@buildingModel)
}

vgui.Register('PPM2Model2Panel', MODEL_BOX_PANEL, 'EditablePanel')

EDIT_TREE = {
	type: 'level'
	name: 'Pony overview'

	points: {
		{
			type: 'bone'
			target: 'LrigScull'
			link: 'head_submenu'
		}

		{
			type: 'bone'
			target: 'LrigSpine1'
			link: 'spine_length'
		}

		{
			type: 'bone'
			target: 'Tail01'
			link: 'tail'
		}

		{
			type: 'bone'
			target: 'Lrig_LEG_FL_Metacarpus'
			link: 'legs_submenu'
		}

		{
			type: 'bone'
			target: 'Lrig_LEG_FR_Metacarpus'
			link: 'legs_submenu'
		}

		{
			type: 'bone'
			target: 'Lrig_LEG_BR_LargeCannon'
			link: 'legs_submenu'
		}

		{
			type: 'bone'
			target: 'Lrig_LEG_BL_LargeCannon'
			link: 'legs_submenu'
		}
	}

	children: {
		head_submenu: {
			type: 'level'
			name: 'Head anatomy'

			points: {
				{
					type: 'attach'
					target: 'eyes'
					link: 'eyes'
				}
			}

			children: {
				eyes: {
					type: 'menu'
					populate: =>
				}
			}
		}

		legs_submenu: {
			type: 'level'
			name: 'Hooves anatomy'

			points: {

			}

			children: {

			}
		}
	}
}

patchSubtree = (node) ->
	if type(node.children) == 'table'
		for childID, child in pairs node.children
			child.id = childID
			patchSubtree(child)

	if type(node.points) == 'table'
		for point in *node.points
			point.addvector = point.addvector or Vector()
			if type(node.children) == 'table'
				point.linkTable = node.children[point.link]
			switch point.type
				when 'point'
					point.getpos = => Vector(point.target)
				when 'bone'
					point.getpos = =>
						if not point.targetID or point.targetID == -1
							point.targetID = @LookupBone(point.target) or -1

						if point.targetID == -1
							return Vector(point.addvector)
						else
							return @GetBonePosition(point.targetID) + point.addvector
				when 'attach'
					point.getpos = =>
						if not point.targetID or point.targetID == -1
							point.targetID = @LookupAttachment(point.target) or -1

						if point.targetID == -1
							return Vector(point.addvector)
						else
							{:Pos, :Ang} = @GetAttachment(point.targetID)
							return Pos and (Pos + point.addvector) or Vector(point.addvector)

EDIT_TREE.id = 'root'
patchSubtree(EDIT_TREE)

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
	@SetDraggable(false)
	@RemoveResize()

	with @modelPanel = vgui.Create('PPM2Model2Panel', @)
		\Dock(FILL)
		\DockMargin(3, 3, 3, 3)

	copy = PPM2.GetMainData()\Copy()
	ply = LocalPlayer()
	ent = @modelPanel\ResetModel()

	controller = copy\CreateCustomController(ent)
	controller\SetFlexLerpMultiplier(1.3)
	copy\SetController(controller)

	@modelPanel\SetController(controller)
	controller\SetupEntity(ent)
	controller\SetDisableTask(true)

	@modelPanel.stack = {EDIT_TREE}

concommand.Add 'ppm2_editor3', ppm2_editor3
