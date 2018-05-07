
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
ADVANCED_MODE = CreateConVar('ppm2_editor_advanced', '0', {FCVAR_ARCHIVE}, 'Show all options. Keep in mind Editor3 acts different with this option.')

inRadius = (val, min, max) -> val >= min and val <= max
inBox = (pointX, pointY, x, y, w, h) -> inRadius(pointX, x - w, x + w) and inRadius(pointY, y - h, y + h)

-- loal
surface.CreateFont('PPM2BackButton', {
	font: 'Roboto'
	size: ScreenScale(24)\floor()
	weight: 600
})

surface.CreateFont('PPM2EditorPanelHeaderText', {
	font: 'PT Serif'
	size: ScreenScale(16)\floor()
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
		@startAnimStart = RealTimeL() + 2
		@startAnimEnd = RealTimeL() + 8

		@startAnimStart2 = RealTimeL() + 2.5
		@startAnimEnd2 = RealTimeL() + 9

		@menuPanelsCache = {}
		@updatePanels = {}

		@holdLast = 0
		@mouseX, @mouseY = 0, 0

		@crosshairCircleInactive = Color(150, 150, 150)
		@crosshairBoxInactive = Color(100, 100, 100)

		@crosshairCircleHovered = Color(137, 195, 196)
		@crosshairBoxHovered = Color(200, 200, 200)

		@crosshairCircleSelected = Color(0, 0, 0, 0)
		@crosshairBoxSelected = Color(211, 255, 192)

		@angle = Angle(-10, -30, 0)
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

	UpdateAttachsIDs: =>
		@trackBone = @model\LookupBone(@trackBoneName) or -1 if @trackBoneName ~= ''
		@trackAttach = @model\LookupAttachment(@trackAttachName) or -1 if @trackAttachName ~= ''
	GetTrackedPosition: =>
		return @lautoTrackPos if @shouldAutoTrack
		return @targetPos

	UpdateSeqButtonsPos: (inMenus = @InMenu2()) =>
		if inMenus
			bX, bY = @GetSize()
			bW, bH = 0, 0
			bX -= ScreenScale(6)
			bY = ScreenScale(4)

			bX, bY = @backButton\GetPos() if IsValid(@backButton)
			bW, bH = @backButton\GetSize() if IsValid(@backButton)

			w, h = @GetSize()
			W, H = @seqButton\GetSize()
			@seqButton\SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8))
			W, H = @emotesPanel\GetSize()
			@emotesPanel\SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8) + 30)
		else
			@seqButton\SetPos(10, 10)
			@emotesPanel\SetPos(10, 40)

	PerformLayout: (w = 0, h = 0) =>
		if IsValid(@lastVisibleMenu) and @lastVisibleMenu\IsVisible()
			@UpdateSeqButtonsPos(true)
			x, y = @GetPos()
			W, H = @GetSize()
			width = ScreenScale(120)

			with @lastVisibleMenu
				\SetPos(x, y)
				\SetSize(width, H)
		else
			@UpdateSeqButtonsPos(@InMenu2())

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

	DoUpdate: => panel\DoUpdate() for panel in *@updatePanels when panel\IsValid()

	UpdateMenu: (menu, goingToDelete = false) =>
		if @InMenu2() and not goingToDelete
			x, y = @GetPos()
			frame = @GetParentTarget() or @GetParent() or @
			W, H = @GetSize()
			width = ScreenScale(120)

			if not @menuPanelsCache[menu.id]
				if menu.menus
					local targetPanel
					with settingsPanel = vgui.Create('DPropertySheet', frame)
						\SetPos(x, y)
						\SetSize(width, H)
						@menuPanelsCache[menu.id] = settingsPanel

						for menuName, menuPopulate in pairs menu.menus
							with menuPanel = vgui.Create('PPM2SettingsBase', settingsPanel)
								table.insert(@updatePanels, menuPanel)
								.frame = @frame
								with vgui.Create('DLabel', menuPanel)
									\Dock(TOP)
									\SetFont('PPM2EditorPanelHeaderText')
									\SetText(menuName)
									\SizeToContents()
								settingsPanel\AddSheet(menuName, menuPanel)
								\SetTargetData(@controllerData)
								\Dock(FILL)
								.Populate = menuPopulate
								targetPanel = menuPanel if menu.selectmenu == menuName
						-- god i hate gmod
						if targetPanel
							for item in *\GetItems()
								if item.Panel == targetPanel
									\SetActiveTab(item.Tab)
				else
					with settingsPanel = vgui.Create('PPM2SettingsBase', frame)
						@menuPanelsCache[menu.id] = settingsPanel
						.frame = @frame
						table.insert(@updatePanels, settingsPanel)
						with vgui.Create('DLabel', settingsPanel)
							\Dock(TOP)
							\SetFont('PPM2EditorPanelHeaderText')
							\SetText(menu.name or '<unknown>')
							\SizeToContents()
						\SetPos(x, y)
						\SetSize(width, H)
						\SetTargetData(@controllerData)
						.Populate = menu.populate

			with @menuPanelsCache[menu.id]
				\SetVisible(true)
				\SetPos(x, y)
				\SetSize(width, H)

			@lastVisibleMenu = @menuPanelsCache[menu.id]
			@UpdateSeqButtonsPos(true)
		elseif IsValid(@menuPanelsCache[menu.id])
			@menuPanelsCache[menu.id]\SetVisible(false)
			@seqButton\SetPos(10, 10)
			@emotesPanel\SetPos(10, 40)

	PushMenu: (menu) =>
		@UpdateMenu(@stack[#@stack], true)
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

		@UpdateMenu(menu)

		@fixedDistanceToPony = menu.dist
		@angle = Angle(menu.defang)
		@distToPony = 90
		return @

	PopMenu: =>
		assert(#@stack > 1, 'invalid stack size to pop from')
		_menu = @stack[#@stack]
		table.remove(@stack)
		@UpdateMenu(_menu, true)
		@backButton\Remove() if #@stack == 1 and IsValid(@backButton)
		menu = @stack[#@stack]
		@UpdateMenu(menu)
		@fixedDistanceToPony = menu.dist
		@angle = Angle(menu.defang)
		@distToPony = 90
		return @

	CurrentMenu: => @stack[#@stack]
	InRoot: => #@stack == 1
	InSelection: => @CurrentMenu().type == 'level'
	InMenu: => @CurrentMenu().type == 'menu'
	InMenu2: => @CurrentMenu().type == 'menu' or @CurrentMenu().populate or @CurrentMenu().menus

	ResetModel: (ponydata, model = 'models/ppm/player_default_base_new_nj.mdl') =>
		@model\Remove() if IsValid(@model)

		with @model = ClientsideModel(model)
			\SetNoDraw(true)
			.__PPM2_PonyData = ponydata
			\SetSequence(@seq)
			\FrameAdvance(0)
			\SetPos(Vector())
			\InvalidateBoneCache()

		@emotesPanel\Remove() if IsValid(@emotesPanel)
		with @emotesPanel = PPM2.CreateEmotesPanel(@, @model, false)
			\SetPos(10, 40)
			\SetMouseInputEnabled(true)
			\SetVisible(true)

		@UpdateAttachsIDs()
		return @model

	Think: =>
		rtime = RealTimeL()
		delta = rtime - @lastTick
		@lastTick = rtime
		lerp = (delta * 15)\min(1)

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
	WIREFRAME: Material('models/wireframe')

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

			turnpitch = turnpitch + 2000 / @lfixedDistanceToPony
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

		if ENABLE_FULLBRIGHT\GetBool()
			render.SuppressEngineLighting(true)
			render.ResetModelLighting(1, 1, 1)
			render.SetColorModulation(1, 1, 1)

		progression = RealTimeL()\progression(@startAnimStart, @startAnimEnd)
		progression2 = RealTimeL()\progression(@startAnimStart2, @startAnimEnd2)

		if progression2 == 1
			@buildingModel\DrawModel()
		else
			old = render.EnableClipping(true)

			render.SetBlend(0.2)
			render.MaterialOverride(@WIREFRAME)

			for layer = -16, 16
				render.PushCustomClipPlane(Vector(0, 0, -1), (1 - progression) * 1200 + layer * 9 - 800)
				@buildingModel\DrawModel()
				render.PopCustomClipPlane()

			render.MaterialOverride()
			render.SetBlend(1)

			render.PushCustomClipPlane(Vector(0, 0, -1), (1 - progression2) * 1200 - 800)
			@buildingModel\DrawModel()
			render.PopCustomClipPlane()

			render.EnableClipping(old)

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

		@model\InvalidateBoneCache()

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
			radius = ScreenScale(10)
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
				radius = ScreenScale(10)
				drawCrosshair(x, y, radius, @crosshairCircleSelected, @crosshairBoxSelected)

	OnRemove: =>
		@model\Remove() if IsValid(@model)
		@buildingModel\Remove() if IsValid(@buildingModel)
		panel\Remove() for panel in *@menuPanelsCache when panel\IsValid()
}

vgui.Register('PPM2Model2Panel', MODEL_BOX_PANEL, 'EditablePanel')

-- 0 LrigPelvis
-- 1 Lrig_LEG_BL_Femur
-- 2 Lrig_LEG_BL_Tibia
-- 3 Lrig_LEG_BL_LargeCannon
-- 4 Lrig_LEG_BL_PhalanxPrima
-- 5 Lrig_LEG_BL_RearHoof
-- 6 Lrig_LEG_BR_Femur
-- 7 Lrig_LEG_BR_Tibia
-- 8 Lrig_LEG_BR_LargeCannon
-- 9 Lrig_LEG_BR_PhalanxPrima
-- 10 Lrig_LEG_BR_RearHoof
-- 11 LrigSpine1
-- 12 LrigSpine2
-- 13 LrigRibcage
-- 14 Lrig_LEG_FL_Scapula
-- 15 Lrig_LEG_FL_Humerus
-- 16 Lrig_LEG_FL_Radius
-- 17 Lrig_LEG_FL_Metacarpus
-- 18 Lrig_LEG_FL_PhalangesManus
-- 19 Lrig_LEG_FL_FrontHoof
-- 20 Lrig_LEG_FR_Scapula
-- 21 Lrig_LEG_FR_Humerus
-- 22 Lrig_LEG_FR_Radius
-- 23 Lrig_LEG_FR_Metacarpus
-- 24 Lrig_LEG_FR_PhalangesManus
-- 25 Lrig_LEG_FR_FrontHoof
-- 26 LrigNeck1
-- 27 LrigNeck2
-- 28 LrigNeck3
-- 29 LrigScull
-- 30 Jaw
-- 31 Ear_L
-- 32 Ear_R
-- 33 Mane02
-- 34 Mane03
-- 35 Mane03_tip
-- 36 Mane04
-- 37 Mane05
-- 38 Mane06
-- 39 Mane07
-- 40 Mane01
-- 41 Lrigweaponbone
-- 42 right_hand
-- 43 Tail01
-- 44 Tail02
-- 45 Tail03
-- 46 wing_l
-- 47 wing_r
-- 48 wing_l_bat
-- 49 wing_r_bat
-- 50 wing_open_l
-- 51 wing_open_r

genEyeMenu = (publicName) ->
	return =>
		@ScrollPanel()
		@CheckBox('gui.ppm2.editor.eyes.separate', 'SeparateEyes')

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

EDIT_TREE = {
	type: 'level'
	name: 'Pony overview'
	dist: 100
	defang: Angle(-10, -30, 0)
	selectmenu: 'gui.ppm2.editor.tabs.main'

	menus: {
		'gui.ppm2.editor.tabs.main': =>
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
			@Hr()
			@CheckBox('gui.ppm2.editor.misc.no_flexes2', 'NoFlex')
			@Label('gui.ppm2.editor.misc.no_flexes_desc')
			flexes = @Spoiler('gui.ppm2.editor.misc.flexes')
			for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
				@CheckBox("Disable #{flex} control", "DisableFlex#{flex}")\SetParent(flexes) if active
			flexes\SizeToContents()

		'gui.ppm2.editor.tabs.files': PPM2.EditorBuildNewFilesPanel
		'gui.ppm2.editor.tabs.old_files': PPM2.EditorBuildOldFilesPanel

		'gui.ppm2.editor.tabs.about': =>
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

	points: {
		{
			type: 'bone'
			target: 'LrigScull'
			link: 'head_submenu'
		}

		{
			type: 'bone'
			target: 'Lrig_LEG_BL_Femur'
			link: 'cutiemark'
		}

		{
			type: 'bone'
			target: 'Lrig_LEG_BR_Femur'
			link: 'cutiemark'
		}

		{
			type: 'bone'
			target: 'LrigSpine1'
			link: 'spine'
		}

		{
			type: 'bone'
			target: 'Tail03'
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
		cutiemark: {
			type: 'menu'
			name: 'gui.ppm2.editor.tabs.cutiemark'
			dist: 30
			defang: Angle(0, -90, 0)

			populate: =>
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

		head_submenu: {
			type: 'level'
			name: 'gui.ppm2.editor.tabs.head'
			dist: 40
			defang: Angle(-7, -30, 0)

			points: {
				{
					type: 'attach'
					target: 'eyes'
					link: 'eyes'
				}

				{
					type: 'attach'
					target: 'eyes'
					link: 'eyel'
					addvector: Vector(-5, 5, 2)
				}

				{
					type: 'attach'
					target: 'eyes'
					link: 'mane_horn'
					addvector: Vector(-5, 0, 13)
				}

				{
					type: 'attach'
					target: 'eyes'
					link: 'eyer'
					addvector: Vector(-5, -5, 2)
				}
			}

			children: {
				eyes: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.eyes'
					dist: 30
					defang: Angle(-10, 0, 0)

					menus: {
						'gui.ppm2.editor.tabs.eyes': genEyeMenu('')
						'gui.ppm2.editor.tabs.face': =>
							@ScrollPanel()
							@ComboBox('gui.ppm2.editor.face.eyelashes', 'EyelashType')
							@ColorBox('gui.ppm2.editor.face.eyelashes_color', 'EyelashesColor')
							@ColorBox('gui.ppm2.editor.face.eyebrows_color', 'EyebrowsColor')

							@CheckBox('gui.ppm2.editor.face.new_muzzle', 'NewMuzzle')

							if ADVANCED_MODE\GetBool()
								@Hr()
								@CheckBox('gui.ppm2.editor.face.inherit.lips', 'LipsColorInherit')
								@CheckBox('gui.ppm2.editor.face.inherit.nose', 'NoseColorInherit')
								@ColorBox('gui.ppm2.editor.face.lips', 'LipsColor')
								@ColorBox('gui.ppm2.editor.face.nose', 'NoseColor')
								@Hr()
								@CheckBox('gui.ppm2.editor.face.eyebrows_glow', 'GlowingEyebrows')
								@NumSlider('gui.ppm2.editor.face.eyebrows_glow_strength', 'EyebrowsGlowStrength', 2)

								@CheckBox('gui.ppm2.editor.face.eyelashes_separate_phong', 'SeparateEyelashesPhong')
								PPM2.EditorPhongPanels(@, 'Eyelashes', 'gui.ppm2.editor.face.eyelashes_phong')

						'gui.ppm2.editor.tabs.mouth': =>
							@CheckBox('gui.ppm2.editor.mouth.fangs', 'Fangs')
							@CheckBox('gui.ppm2.editor.mouth.alt_fangs', 'AlternativeFangs')
							@NumSlider('gui.ppm2.editor.mouth.fangs', 'FangsStrength', 2) if ADVANCED_MODE\GetBool()
							@CheckBox('gui.ppm2.editor.mouth.claw', 'ClawTeeth')
							@NumSlider('gui.ppm2.editor.mouth.claw', 'ClawTeethStrength', 2) if ADVANCED_MODE\GetBool()

							@Hr()

							@ColorBox('gui.ppm2.editor.mouth.teeth', 'TeethColor')
							@ColorBox('gui.ppm2.editor.mouth.mouth', 'MouthColor')
							@ColorBox('gui.ppm2.editor.mouth.tongue', 'TongueColor')
							PPM2.EditorPhongPanels(@, 'Teeth', 'gui.ppm2.editor.mouth.teeth_phong')
							PPM2.EditorPhongPanels(@, 'Mouth', 'gui.ppm2.editor.mouth.mouth_phong')
							PPM2.EditorPhongPanels(@, 'Tongue', 'gui.ppm2.editor.mouth.tongue_phong')
					}
				}

				eyel: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.left_eye'
					dist: 20
					defang: Angle(-7, 30, 0)
					populate: genEyeMenu('Left')
				}

				eyer: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.right_eye'
					dist: 20
					populate: genEyeMenu('Right')
				}

				mane_horn: {
					type: 'level'
					name: 'gui.ppm2.editor.tabs.mane_horn'
					dist: 50
					defang: Angle(-25, -120, 0)

					points: {
						{
							type: 'attach'
							target: 'eyes'
							link: 'mane'
							addvector: Vector(-15, 0, 14)
						}

						{
							type: 'attach'
							target: 'eyes'
							link: 'horn'
							addvector: Vector(-2, 0, 14)
						}

						{
							type: 'attach'
							target: 'eyes'
							link: 'ears'
							addvector: Vector(-16, -8, 8)
						}

						{
							type: 'attach'
							target: 'eyes'
							link: 'ears'
							addvector: Vector(-16, 8, 8)
						}
					}

					children: {
						mane: {
							type: 'menu'
							name: 'gui.ppm2.editor.tabs.mane'
							defang: Angle(-7, -120, 0)
							menus: {
								'gui.ppm2.editor.tabs.main': =>
									@ComboBox('gui.ppm2.editor.mane.type', 'ManeTypeNew')
									@CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
									@CheckBox('gui.ppm2.editor.misc.hide_mane', 'HideManesMane')

									@Hr()
									@CheckBox('gui.ppm2.editor.mane.phong', 'SeparateManePhong') if ADVANCED_MODE\GetBool()
									PPM2.EditorPhongPanels(@, 'Mane', 'gui.ppm2.editor.mane.mane_phong') if ADVANCED_MODE\GetBool()
									@ColorBox("gui.ppm2.editor.mane.color#{i}", "ManeColor#{i}") for i = 1, 2

									@Hr()
									@ColorBox("gui.ppm2.editor.mane.detail_color#{i}", "ManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

								'gui.ppm2.editor.tabs.details': =>
									@CheckBox('gui.ppm2.editor.mane.phong_sep', 'SeparateMane')
									PPM2.EditorPhongPanels(@, 'UpperMane', 'gui.ppm2.editor.mane.up.phong') if ADVANCED_MODE\GetBool()
									PPM2.EditorPhongPanels(@, 'LowerMane', 'gui.ppm2.editor.mane.down.phong') if ADVANCED_MODE\GetBool()

									@Hr()
									@ColorBox("gui.ppm2.editor.mane.up.color#{i}", "UpperManeColor#{i}") for i = 1, 2
									@ColorBox("gui.ppm2.editor.mane.down.color#{i}", "LowerManeColor#{i}") for i = 1, 2

									@Hr()
									@ColorBox("gui.ppm2.editor.mane.up.detail_color#{i}", "UpperManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
									@ColorBox("gui.ppm2.editor.mane.down.detail_color#{i}", "LowerManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

								'gui.ppm2.editor.tabs.url_details': =>
									for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
										@Label("gui.ppm2.editor.url_mane.desc#{i}")
										@URLInput("ManeURL#{i}")
										@ColorBox("gui.ppm2.editor.url_mane.color#{i}", "ManeURLColor#{i}")
										@Hr()

								'gui.ppm2.editor.tabs.url_separated_details': =>
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
						}

						ears: {
							type: 'menu'
							name: 'gui.ppm2.editor.tabs.ears'
							defang: Angle(-12, -110, 0)
							populate: =>
								@CheckBox('gui.ppm2.editor.ears.bat', 'BatPonyEars')
								@NumSlider('gui.ppm2.editor.ears.bat', 'BatPonyEarsStrength', 2) if ADVANCED_MODE\GetBool()

								if ADVANCED_MODE\GetBool()
									@NumSlider('gui.ppm2.editor.ears.size', 'EarsSize', 2)
						}

						horn: {
							type: 'menu'
							name: 'gui.ppm2.editor.tabs.horn'
							dist: 30
							defang: Angle(-13, -20, 0)
							menus: {
								'gui.ppm2.editor.tabs.main': =>
									@CheckBox('gui.ppm2.editor.horn.separate_color', 'SeparateHorn')
									@ColorBox('gui.ppm2.editor.horn.detail_color', 'HornDetailColor')
									@CheckBox('gui.ppm2.editor.horn.glowing_detail', 'HornGlow')
									@NumSlider('gui.ppm2.editor.horn.glow_strength', 'HornGlowSrength', 2)
									@ColorBox('gui.ppm2.editor.horn.color', 'HornColor')
									@CheckBox('gui.ppm2.editor.horn.separate_magic_color', 'SeparateMagicColor')
									@ColorBox('gui.ppm2.editor.horn.magic', 'HornMagicColor')
									@CheckBox('gui.ppm2.editor.horn.separate_phong', 'SeparateHornPhong') if ADVANCED_MODE\GetBool()
									PPM2.EditorPhongPanels(@, 'Horn', 'gui.ppm2.editor.horn.horn_phong') if ADVANCED_MODE\GetBool()
								'gui.ppm2.editor.tabs.details': =>
									for i = 1, 3
										@Label('gui.ppm2.editor.horn.detail.desc' .. i)
										@URLInput("HornURL#{i}")
										@ColorBox('gui.ppm2.editor.horn.detail.color' .. i, "HornURLColor#{i}")
										@Hr()

							}
						}
					}
				}
			}
		}

		spine: {
			type: 'level'
			name: 'gui.ppm2.editor.tabs.back'
			dist: 80
			defang: Angle(-30, -90, 0)

			points: {
				{
					type: 'bone'
					target: 'LrigSpine1'
					link: 'overall_body'
				}

				{
					type: 'bone'
					target: 'LrigNeck2'
					link: 'neck'
				}

				{
					type: 'bone'
					target: 'wing_l'
					link: 'wings'
				}

				{
					type: 'bone'
					target: 'wing_r'
					link: 'wings'
				}
			}

			children: {
				wings: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.wings'
					dist: 40
					defang: Angle(-12, -30, 0)

					menus: {
						'gui.ppm2.editor.tabs.main': =>
							@CheckBox('gui.ppm2.editor.wings.separate_color', 'SeparateWings')
							@ColorBox('gui.ppm2.editor.wings.color', 'WingsColor')
							@CheckBox('gui.ppm2.editor.wings.separate_phong', 'SeparateWingsPhong') if ADVANCED_MODE\GetBool()
							@Hr()
							@ColorBox('gui.ppm2.editor.wings.bat_color', 'BatWingColor')
							@ColorBox('gui.ppm2.editor.wings.bat_skin_color', 'BatWingSkinColor')
							PPM2.EditorPhongPanels(@, 'BatWingsSkin', 'gui.ppm2.editor.wings.bat_skin_phong') if ADVANCED_MODE\GetBool()

						'gui.ppm2.editor.tabs.left': =>
							@NumSlider('gui.ppm2.editor.wings.left.size', 'LWingSize', 2)
							@NumSlider('gui.ppm2.editor.wings.left.fwd', 'LWingX', 2)
							@NumSlider('gui.ppm2.editor.wings.left.up', 'LWingY', 2)
							@NumSlider('gui.ppm2.editor.wings.left.inside', 'LWingZ', 2)

						'gui.ppm2.editor.tabs.right': =>
							@NumSlider('gui.ppm2.editor.wings.right.size', 'RWingSize', 2)
							@NumSlider('gui.ppm2.editor.wings.right.fwd', 'RWingX', 2)
							@NumSlider('gui.ppm2.editor.wings.right.up', 'RWingY', 2)
							@NumSlider('gui.ppm2.editor.wings.right.inside', 'RWingZ', 2)

						'gui.ppm2.editor.tabs.details': =>
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
				}

				neck: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.neck'
					dist: 40
					defang: Angle(-7, -15, 0)
					populate: =>
						@NumSlider('gui.ppm2.editor.neck.height', 'NeckSize', 2)
				}

				overall_body: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.body'
					dist: 90
					defang: Angle(-3, -90, 0)
					menus: {
						'gui.ppm2.editor.tabs.main': =>
							@ComboBox('gui.ppm2.editor.body.suit', 'Bodysuit')
							@ColorBox('gui.ppm2.editor.body.color', 'BodyColor')

						'gui.ppm2.editor.tabs.back': =>
							@NumSlider('gui.ppm2.editor.body.spine_length', 'BackSize', 2)

						'gui.ppm2.editor.tabs.details': =>
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

						'gui.ppm2.editor.tabs.tattoos': =>
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
				}
			}
		}

		tail: {
			type: 'menu'
			name: 'gui.ppm2.editor.tabs.tail'
			dist: 50
			defang: Angle(-10, -90, 0)

			menus: {
				'gui.ppm2.editor.tabs.main': =>
					@ComboBox('gui.ppm2.editor.tail.type', 'TailTypeNew')

					@CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
					@CheckBox('gui.ppm2.editor.misc.hide_tail', 'HideManesTail')

					@NumSlider('gui.ppm2.editor.tail.size', 'TailSize', 2)

					@ColorBox('gui.ppm2.editor.tail.color' .. i, "TailColor#{i}") for i = 1, 2

					@Hr()
					@CheckBox('gui.ppm2.editor.tail.separate', 'SeparateTailPhong') if ADVANCED_MODE\GetBool()
					PPM2.EditorPhongPanels(@, 'Tail', 'gui.ppm2.editor.tail.tail_phong') if ADVANCED_MODE\GetBool()
					@ColorBox('gui.ppm2.editor.tail.detail' .. i, "TailDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

				'gui.ppm2.editor.tabs.details': =>
					for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
						@Hr()
						@Label('gui.ppm2.editor.tail.url.detail' .. i)
						@URLInput("TailURL#{i}")
						@ColorBox('gui.ppm2.editor.tail.url.color' .. i, "TailURLColor#{i}")
			}
		}

		legs_submenu: {
			type: 'level'
			name: 'gui.ppm2.editor.tabs.hooves'
			dist: 50
			defang: Angle(-10, -50, 0)

			points: {
				{
					type: 'bone'
					target: 'Lrig_LEG_BR_RearHoof'
					link: 'bottom_hoof'
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_BL_RearHoof'
					link: 'bottom_hoof'
					defang: Angle(0, 90, 0)
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_FL_FrontHoof'
					link: 'bottom_hoof'
					defang: Angle(0, 90, 0)
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_FR_FrontHoof'
					link: 'bottom_hoof'
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_FL_Metacarpus'
					link: 'legs_generic'
					defang: Angle(0, 90, 0)
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_FR_Metacarpus'
					link: 'legs_generic'
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_BR_LargeCannon'
					link: 'legs_generic'
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_BL_LargeCannon'
					link: 'legs_generic'
					defang: Angle(0, 90, 0)
				}
			}

			children: {
				bottom_hoof: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.bottom_hoof'
					dist: 30
					defang: Angle(0, -90, 0)
					populate: =>
						@CheckBox('gui.ppm2.editor.hoof.fluffers', 'HoofFluffers')
						@NumSlider('gui.ppm2.editor.hoof.fluffers', 'HoofFluffersStrength', 2)
				}

				legs_generic: {
					type: 'menu'
					name: 'gui.ppm2.editor.tabs.legs'
					dist: 30
					defang: Angle(0, -90, 0)

					menus: {
						'gui.ppm2.editor.tabs.main': =>
							@CheckBox('gui.ppm2.editor.misc.hide_pac3', 'HideManes')
							@CheckBox('gui.ppm2.editor.misc.hide_socks', 'HideManesSocks')
							@NumSlider('gui.ppm2.editor.legs.height', 'LegsSize', 2)

						'gui.ppm2.editor.tabs.socks': =>
							@CheckBox('gui.ppm2.editor.legs.socks.simple', 'Socks') if ADVANCED_MODE\GetBool()
							@CheckBox('gui.ppm2.editor.legs.socks.model', 'SocksAsModel')
							@ColorBox('gui.ppm2.editor.legs.socks.color', 'SocksColor')

							if ADVANCED_MODE\GetBool()
								@Hr()
								PPM2.EditorPhongPanels(@, 'Socks', 'gui.ppm2.editor.legs.socks.socks_phong')
								@ComboBox('gui.ppm2.editor.legs.socks.texture', 'SocksTexture')
								@Label('gui.ppm2.editor.legs.socks.url_texture')
								@URLInput('SocksTextureURL')

								@Hr()
								@ColorBox('gui.ppm2.editor.legs.socks.color' .. i, 'SocksDetailColor' .. i) for i = 1, 6

						'gui.ppm2.editor.tabs.newsocks': =>
							@CheckBox('gui.ppm2.editor.legs.newsocks.model', 'SocksAsNewModel')
							@ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor1')
							@ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor2')
							@ColorBox('gui.ppm2.editor.legs.newsocks.color1', 'NewSocksColor3')

							if ADVANCED_MODE\GetBool()
								@Label('gui.ppm2.editor.legs.newsocks.url')
								@URLInput('NewSocksTextureURL')
					}
				}
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
							--bonepos = @GetBonePosition(point.targetID)
							--print(point.target, bonepos) if bonepos == Vector()
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
				point.linkTable = table.Copy(node.children[point.link])
				if type(point.linkTable) == 'table'
					point.linkTable.getpos = point.getpos
					if point.defang
						point.linkTable.defang = Angle(point.defang)
				else
					PPM2.Message('Editor3: Missing submenu ' .. point.link .. ' of ' .. node.id .. '!')

EDIT_TREE.id = 'root'
patchSubtree(EDIT_TREE)

if IsValid(PPM2.EDITOR3)
	PPM2.EDITOR3\Remove()
	net.Start('PPM2.EditorStatus')
	net.WriteBool(false)
	net.SendToServer()

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
	@SetDeleteOnClose(false)

	with @modelPanel = vgui.Create('PPM2Model2Panel', @)
		\Dock(FILL)
		\DockMargin(3, 3, 3, 3)

	copy = PPM2.GetMainData()\Copy()
	ply = LocalPlayer()
	ent = @modelPanel\ResetModel()

	@data = copy

	controller = copy\CreateCustomController(ent)
	controller\SetFlexLerpMultiplier(1.3)
	copy\SetController(controller)

	@controller = controller

	@modelPanel\SetController(controller)
	controller\SetupEntity(ent)
	controller\SetDisableTask(true)

	@modelPanel.frame = @
	@modelPanel.stack = {EDIT_TREE}
	@modelPanel\SetParentTarget(@)
	@modelPanel.controllerData = copy
	@modelPanel\UpdateMenu(@modelPanel\CurrentMenu())

	@SetTitle('gui.ppm2.editor.generic.title_file', copy\GetFilename() or '%ERRNAME%')
	PPM2.EditorCreateTopButtons(@, true, true)

	@DoUpdate = -> @modelPanel\DoUpdate()
	@OnClose = ->
		net.Start('PPM2.EditorStatus')
		net.WriteBool(false)
		net.SendToServer()

	net.Start('PPM2.EditorStatus')
	net.WriteBool(true)
	net.SendToServer()

	if not file.Exists('ppm2_intro.txt', 'DATA')
		file.Write('ppm2_intro.txt', '')
		Derma_Message('gui.ppm2.editor.intro.text', 'gui.ppm2.editor.intro.title', 'gui.ppm2.editor.intro.okay')

concommand.Add 'ppm2_editor3', ppm2_editor3

IconData3 =
	title: 'PPM/2 Editor/3',
	icon: 'gui/ppm2_icon.png',
	width: 960,
	height: 700,
	onewindow: true,
	init: (icon, window) ->
		window\Remove()
		ppm2_editor3()

list.Set('DesktopWindows', 'PPM2_E3', IconData3)
CreateContextMenu() if IsValid(g_ContextMenu)
