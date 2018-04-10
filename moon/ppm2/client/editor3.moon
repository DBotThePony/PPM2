
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

-- loal
surface.CreateFont('PPM2BackButton', {
	font: 'Roboto'
	size: ScreenScale(24)\floor()
	weight: 600
})

import HUDCommons from DLib
drawCrosshair = (x, y, radius = ScreenScale(10), arcColor = Color(255, 255, 255), boxesColor = Color(200, 200, 200)) ->
	x -= radius / 2
	y -= radius / 2

	HUDCommons.DrawCircleHollow(x, y, radius, radius * 2, radius * 0.2, arcColor)
	h = radius * 0.1
	w = radius * 0.6
	surface.SetDrawColor(boxesColor)
	surface.DrawRect(x - w / 2, y + radius / 2 - h / 2, w, h)
	surface.DrawRect(x + radius / 2 + w / 2, y + radius / 2 - h / 2, w, h)

	surface.DrawRect(x + radius / 2 - h / 2, y - w / 2, h, w)
	surface.DrawRect(x + radius / 2 - h / 2, y + radius / 2 + w / 3, h, w)

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
		@holdOnPoint = false
		@holdRightClick = false
		@canHold = true
		@lastTick = RealTimeL()

		@holdLast = 0
		@mouseX, @mouseY = 0, 0

		@crosshairCircleInactive = Color(150, 150, 150)
		@crosshairBoxInactive = Color(100, 100, 100)

		@crosshairCircleHovered = Color(137, 195, 196)
		@crosshairBoxHovered = Color(200, 200, 200)

		@crosshairCircleSelected = Color(0, 0, 0, 0)
		@crosshairBoxSelected = Color(211, 255, 192)

		@angle = Angle(0, 0, 0)
		@distToPony = 90
		@ldistToPony = 90
		@trackBone = -1
		@trackBoneName = 'LrigSpine2'
		@trackAttach = -1
		@trackAttachName = ''
		@shouldAutoTrack = true
		@autoTrackPos = Vector(0, 0, 0)
		@lautoTrackPos = Vector(0, 0, 0)
		@fixedDistanceToPony = 100
		@lfixedDistanceToPony = 100

		@vectorPos = Vector(@fixedDistanceToPony, 0, 0)
		@lvectorPos = Vector(@fixedDistanceToPony, 0, 0)
		@targetPos = Vector(0, 0, @PONY_VEC_Z * .7)
		@ldrawAngle = Angle()

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
		return @lautoTrackPos if @shouldAutoTrack
		return @targetPos

	PerformLayout: (w = 0, h = 0) =>
		@seqButton\SetPos(10, 10)
		@emotesPanel\SetPos(10, 40)

	OnMousePressed: (code = MOUSE_LEFT) =>
		if code == MOUSE_LEFT and @canHold
			if not @selectPoint
				@hold = true
				@SetCursor('sizeall')
				@holdLast = RealTimeL() + .1
				@mouseX, @mouseY = gui.MousePos()
			else
				@holdOnPoint = true
				@SetCursor('crosshair')
		elseif code == MOUSE_RIGHT
			@holdRightClick = true

	OnMouseReleased: (code = MOUSE_LEFT) =>
		if code == MOUSE_LEFT and @canHold
			@holdOnPoint = false
			@SetCursor('none')

			if not @selectPoint
				@hold = false
			else
				@PushMenu(@selectPoint.linkTable)

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

	GetParentTarget: => @parentTarget
	SetParentTarget: (val) => @parentTarget = val

	PushMenu: (menu) =>
		table.insert(@stack, menu)
		if not IsValid(@backButton)
			with @backButton = vgui.Create('DButton', @)
				x, y = @GetPos()
				w, h = @GetSize()
				\SetText('↩')
				\SetFont('PPM2BackButton')
				\SizeToContents()
				W, H = \GetSize()
				W += ScreenScale(8)
				\SetSize(W, H)
				\SetPos(w - ScreenScale(6) - W, ScreenScale(4))
				.DoClick = -> @PopMenu()
		if @InMenu()
			x, y = @GetPos()
			frame = @GetParentTarget() or @GetParent() or @
			W, H = @GetSize()
			width = ScreenScale(120)
			with @settingsPanel = vgui.Create('PPM2SettingsBase', frame)
				\SetPos(x, y)
				\SetSize(width, H)
				menu.populate(@settingsPanel)

		@fixedDistanceToPony = menu.dist
		@angle = Angle(menu.defang)
		@distToPony = 90
		return @

	PopMenu: =>
		assert(#@stack > 1, 'invalid stack size to pop from')
		@settingsPanel\Remove() if @InMenu() and IsValid(@settingsPanel)
		table.remove(@stack)
		@backButton\Remove() if #@stack == 1 and IsValid(@backButton)
		menu = @stack[#@stack]
		@fixedDistanceToPony = menu.dist
		@angle = Angle(menu.defang)
		@distToPony = 90
		return @

	CurrentMenu: => @stack[#@stack]
	InRoot: => #@stack == 1
	InSelection: => @CurrentMenu().type == 'level'
	InMenu: => @CurrentMenu().type == 'menu'

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
		lerp = delta * 15

		if IsValid(@model)
			@model\FrameAdvance(delta * @animRate)
			@model\SetPlaybackRate(1)
			@model\SetPoseParameter('move_x', 1)

			if @shouldAutoTrack
				menu = @CurrentMenu()
				if menu.getpos
					@autoTrackPos = menu.getpos(@model)
					@lautoTrackPos = LerpVector(lerp, @lautoTrackPos, @autoTrackPos)
				elseif @trackAttach ~= -1
					{:Ang, :Pos} = @model\GetAttachment(@trackAttach)
					@autoTrackPos = Pos or Vector()
					@lautoTrackPos = LerpVector(lerp, @lautoTrackPos, @autoTrackPos)
				elseif @trackBone ~= -1
					@autoTrackPos = @model\GetBonePosition(@trackBone) or Vector()
					@lautoTrackPos = LerpVector(lerp, @lautoTrackPos, @autoTrackPos)
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

		@lfixedDistanceToPony = Lerp(lerp, @lfixedDistanceToPony, @fixedDistanceToPony)
		@ldistToPony = Lerp(lerp, @ldistToPony, @distToPony)
		@vectorPos = Vector(@lfixedDistanceToPony, 0, 0)
		@vectorPos\Rotate(@angle)
		@lvectorPos = LerpVector(lerp, @lvectorPos, @vectorPos)
		@drawAngle = Angle(-@angle.p, @angle.y - 180)
		@ldrawAngle = LerpAngle(lerp, @ldrawAngle, @drawAngle)

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
		drawpos = @lvectorPos + @GetTrackedPosition()
		cam.Start3D(drawpos, @ldrawAngle, @ldistToPony, x, y, w, h)

		if @holdRightClick
			@model\SetEyeTarget(drawpos)
			turnpitch, turnyaw = DLib.combat.turnAngle(@EMPTY_VECTOR, drawpos, Angle())

			if not inRadius(turnyaw, -20, 20)
				if turnyaw < 0
					@model\SetPoseParameter('head_yaw', turnyaw + 20)
				else
					@model\SetPoseParameter('head_yaw', turnyaw - 20)
			else
				@model\SetPoseParameter('head_yaw', 0)

			turnpitch = turnpitch + 20
			if not inRadius(turnpitch, -10, 0)
				if turnpitch < 0
					@model\SetPoseParameter('head_pitch', turnpitch + 10)
				else
					@model\SetPoseParameter('head_pitch', turnpitch)
			else
				@model\SetPoseParameter('head_pitch', 0)
		else
			@model\SetEyeTarget(@EMPTY_VECTOR)
			@model\SetPoseParameter('head_yaw', 0)
			@model\SetPoseParameter('head_pitch', 0)

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
		@drawPoints = false
		lx, ly = x, y

		if type(menu.points) == 'table'
			@drawPoints = true
			@pointsData = for point in *menu.points
				vecpos = point.getpos(@model)
				position = vecpos\ToScreen()
				{position, point, vecpos\Distance(drawpos)}
		elseif @InMenu() and menu.getpos
			{:x, :y} = menu.getpos(@model)\ToScreen(drawpos)
			x, y = x - lx, y - ly

		cam.End3D()

		if @drawPoints
			mx, my = gui.MousePos()
			mx, my = mx - lx, my - ly
			radius = ScreenScale(20)
			local drawnSelected
			min = 9999

			for pointdata in *@pointsData
				{:x, :y} = pointdata[1]
				x, y = x - lx, y - ly
				pointdata[1].x, pointdata[1].y = x, y

				if inBox(mx, my, x, y, radius, radius)
					if min > pointdata[3]
						drawnSelected = pointdata
						min = pointdata[3]

			@selectPoint = drawnSelected and drawnSelected[2] or false

			for pointdata in *@pointsData
				{:x, :y} = pointdata[1]

				if pointdata == drawnSelected
					drawCrosshair(x, y, radius, @crosshairCircleHovered, @crosshairBoxHovered)
				else
					drawCrosshair(x, y, radius, @crosshairCircleInactive, @crosshairBoxInactive)

			if not @hold and not @holdOnPoint
				if drawnSelected
					@SetCursor('hand')
				else
					@SetCursor('none')
		else
			@selectPoint = false
			if @InMenu() and menu.getpos
				radius = ScreenScale(20)
				drawCrosshair(x, y, radius, @crosshairCircleSelected, @crosshairBoxSelected)

	OnRemove: =>
		@model\Remove() if IsValid(@model)
		@buildingModel\Remove() if IsValid(@buildingModel)
}

vgui.Register('PPM2Model2Panel', MODEL_BOX_PANEL, 'EditablePanel')

EDIT_TREE = {
	type: 'level'
	name: 'Pony overview'
	dist: 100
	defang: Angle(0, 0, 0)

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
			dist: 40
			defang: Angle(-7, -30, 0)

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
			child.defang = child.defang or Angle(node.defang)
			child.dist = child.dist or node.dist
			patchSubtree(child)

	if type(node.points) == 'table'
		for point in *node.points
			point.addvector = point.addvector or Vector()

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

			if type(node.children) == 'table'
				point.linkTable = node.children[point.link]
				if type(point.linkTable) == 'table'
					point.linkTable.getpos = point.getpos

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
	@modelPanel\SetParentTarget(@)

concommand.Add 'ppm2_editor3', ppm2_editor3
