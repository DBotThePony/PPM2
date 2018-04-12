
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

		@menuPanelsCache = {}

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

	UpdateSeqButtonsPos: (inMenus = @InMenu()) =>
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
			@UpdateSeqButtonsPos(@InMenu())

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

	UpdateMenu: (menu, goingToDelete = false) =>
		if @InMenu2() and not goingToDelete
			x, y = @GetPos()
			frame = @GetParentTarget() or @GetParent() or @
			W, H = @GetSize()
			width = ScreenScale(120)

			if not @menuPanelsCache[menu.id]
				if menu.menus
					with settingsPanel = vgui.Create('DPropertySheet', frame)
						\SetPos(x, y)
						\SetSize(width, H)
						@menuPanelsCache[menu.id] = settingsPanel

						for menuName, menuPopulate in pairs menu.menus
							with menuPanel = vgui.Create('PPM2SettingsBase', settingsPanel)
								with vgui.Create('DLabel', menuPanel)
									\Dock(TOP)
									\SetFont('PPM2EditorPanelHeaderText')
									\SetText(menuName)
									\SizeToContents()
								settingsPanel\AddSheet(menuName, menuPanel)
								\SetTargetData(@controllerData)
								\Dock(FILL)
								menuPopulate(menuPanel)
				else
					with settingsPanel = vgui.Create('PPM2SettingsBase', frame)
						@menuPanelsCache[menu.id] = settingsPanel
						with vgui.Create('DLabel', settingsPanel)
							\Dock(TOP)
							\SetFont('PPM2EditorPanelHeaderText')
							\SetText(menu.name or '<unknown>')
							\SizeToContents()
						\SetPos(x, y)
						\SetSize(width, H)
						\SetTargetData(@controllerData)
						menu.populate(settingsPanel)

			with @menuPanelsCache[menu.id]
				\SetVisible(true)
				\SetPos(x, y)
				\SetSize(width, H)

			@lastVisibleMenu = @menuPanelsCache[menu.id]
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
	InMenu2: => @CurrentMenu().type == 'menu' or @CurrentMenu().populate

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

doAddPhongData = (ttype = 'Body', spoilerName = ttype .. ' phong parameters') =>
	spoiler = @Spoiler(spoilerName)
	@URLLabel('More info about Phong on wiki', 'https://developer.valvesoftware.com/wiki/Phong_materials', spoiler)
	@Label('Phong Exponent - how strong reflective property\nof pony skin is\nSet near zero to get robotic looking of your\npony skin', spoiler)
	@NumSlider('Phong Exponent', ttype .. 'PhongExponent', 3, spoiler)
	@Label('Phong Boost - multiplies specular map reflections', spoiler)
	@NumSlider('Phong Boost', ttype .. 'PhongBoost', 3, spoiler)
	@Label('Tint color - what colors does reflect specular map\nWhite - Reflects all colors\n(In white room - white specular map)', spoiler)
	picker, pickerSpoiler = @ColorBox('Phong Tint', ttype .. 'PhongTint', spoiler)
	pickerSpoiler\SetExpanded(true)
	@Label('Phong Front - Fresnel 0 degree reflection angle multiplier', spoiler)
	@NumSlider('Phong Front', ttype .. 'PhongFront', 2, spoiler)
	@Label('Phong Middle - Fresnel 45 degree reflection angle multiplier', spoiler)
	@NumSlider('Phong Middle', ttype .. 'PhongMiddle', 2, spoiler)
	@Label('Phong Sliding - Fresnel 90 degree reflection angle multiplier', spoiler)
	@NumSlider('Phong Sliding', ttype .. 'PhongSliding', 2, spoiler)
	@ComboBox('Lightwarp', ttype .. 'Lightwarp', nil, spoiler)
	@Label('Lightwarp texture URL input\nIt must be 256x16!', spoiler)
	@URLInput(ttype .. 'LightwarpURL', spoiler)
	@Label('Bumpmap input URL', spoiler)
	@URLInput(ttype .. 'BumpmapURL', spoiler)

genEyeMenu = (publicName) ->
	return =>
		@ScrollPanel()
		@CheckBox('Use separated settings for eyes', 'SeparateEyes')

		@Hr()
		prefix = ''
		if publicName ~= ''
			prefix = publicName .. ' '
			@Label("'#{publicName}' Eye settings")

		@Label('Eye URL texture')
		@URLInput("EyeURL#{publicName}")

		if ADVANCED_MODE\GetBool()
			@Label('Lightwarp has effect only on EyeRefract eyes')
			ttype = publicName == '' and 'BEyes' or publicName == 'Left' and 'LEye' or 'REye'
			@CheckBox("#{prefix}Use EyeRefract shader", "EyeRefract#{publicName}")
			@CheckBox("#{prefix}Use Eye Cornera diffuse", "EyeCornerA#{publicName}")
			@ComboBox('Lightwarp', ttype .. 'Lightwarp')
			@Label('Lightwarp texture URL input\nIt must be 256x16!')
			@URLInput(ttype .. 'LightwarpURL')
			@Label('Glossiness strength\nThis parameters adjucts strength of real time reflections on eye\nTo see changes, set ppm2_cl_reflections convar to 1\nOther players would see reflections only with ppm2_cl_reflections set to 1\n0 - is matted; 1 - is mirror')
			@NumSlider('Glossiness' .. publicName, 'EyeGlossyStrength' .. publicName, 2)

		@Label('When uring eye URL texture; options below have no effect')

		@ComboBox("#{prefix}Eye type", "EyeType#{publicName}")
		@CheckBox("#{prefix}Eye lines", "EyeLines#{publicName}")
		@CheckBox("#{prefix}Derp eye", "DerpEyes#{publicName}")
		@NumSlider("#{prefix}Derp eye strength", "DerpEyesStrength#{publicName}", 2)
		@NumSlider("#{prefix}Eye size", "IrisSize#{publicName}", 2)

		if ADVANCED_MODE\GetBool()
			@CheckBox("#{prefix}Eye lines points inside", "EyeLineDirection#{publicName}")
			@NumSlider("#{prefix}Eye width", "IrisWidth#{publicName}", 2)
			@NumSlider("#{prefix}Eye height", "IrisHeight#{publicName}", 2)

		@NumSlider("#{prefix}Pupil width", "HoleWidth#{publicName}", 2)
		@NumSlider("#{prefix}Pupil height", "HoleHeight#{publicName}", 2) if ADVANCED_MODE\GetBool()
		@NumSlider("#{prefix}Pupil size", "HoleSize#{publicName}", 2)

		if ADVANCED_MODE\GetBool()
			@NumSlider("#{prefix}Pupil Shift X", "HoleShiftX#{publicName}", 2)
			@NumSlider("#{prefix}Pupil Shift Y", "HoleShiftY#{publicName}", 2)
			@NumSlider("#{prefix}Eye rotation", "EyeRotation#{publicName}", 0)

		@Hr()
		@ColorBox("#{prefix}Eye background", "EyeBackground#{publicName}")
		@ColorBox("#{prefix}Pupil", "EyeHole#{publicName}")
		@ColorBox("#{prefix}Top eye iris", "EyeIrisTop#{publicName}")
		@ColorBox("#{prefix}Bottom eye iris", "EyeIrisBottom#{publicName}")
		@ColorBox("#{prefix}Eye line 1", "EyeIrisLine1#{publicName}")
		@ColorBox("#{prefix}Eye line 2", "EyeIrisLine2#{publicName}")
		@ColorBox("#{prefix}Eye reflection effect", "EyeReflection#{publicName}")
		@ColorBox("#{prefix}Eye effect", "EyeEffect#{publicName}")

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

	menus: {
		'Main': =>
			@Button 'New File', ->
				data = @GetTargetData()
				return if not data
				confirmed = ->
					data\SetFilename("new_pony-#{math.random(1, 100000)}")
					data\Reset()
					@ValueChanges()
				Derma_Query('Really want to create a new file?', 'Reset', 'Yas!', confirmed, 'Noh!')

			@Button 'Randomize!', ->
				data = @GetTargetData()
				return if not data
				confirmed = ->
					PPM2.Randomize(data, false)
					@ValueChanges()
				Derma_Query('Really want to randomize?', 'Randomize', 'Yas!', confirmed, 'Noh!')

			@ComboBox('Race', 'Race')
			@ComboBox('Wings Type', 'WingsType')
			@CheckBox('Gender', 'Gender')
			@NumSlider('Male chest buff', 'MaleBuff', 2)
			@NumSlider('Weight', 'Weight', 2)
			@NumSlider('Pony Size', 'PonySize', 2)

			return if not ADVANCED_MODE\GetBool()

			@CheckBox('Should hide weapons', 'HideWeapons')
			@Hr()
			@CheckBox('No flexes on new model', 'NoFlex')
			@Label('You can disable separately any flex state controller\nSo these flexes can be modified with third-party addons (like PAC3)')
			flexes = @Spoiler('Flexes controls')
			for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
				@CheckBox("Disable #{flex} control", "DisableFlex#{flex}")\SetParent(flexes) if active
			flexes\SizeToContents()
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
			name: 'Cutiemark'
			dist: 30
			defang: Angle(0, -90, 0)

			populate: =>
				@CheckBox('Display cutiemark', 'CMark')
				@ComboBox('Cutiemark type', 'CMarkType')
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

				@NumSlider('Cutiemark size', 'CMarkSize', 2)
				@ColorBox('Cutiemark color', 'CMarkColor')
				@Hr()
				@Label('Cutiemark URL image input field\nShould be PNG or JPEG (works same as\nPAC3 URL texture)')\DockMargin(5, 10, 5, 10)
				@URLInput('CMarkURL')
		}

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
					name: 'Eyes'
					dist: 30
					defang: Angle(-10, 0, 0)

					menus: {
						'Eyes': genEyeMenu('')
						'Face': =>
							@ScrollPanel()
							@ComboBox('Eyelashes', 'EyelashType')
							@ColorBox('Eyelashes Color', 'EyelashesColor')
							@ColorBox('Eyebrows Color', 'EyebrowsColor')

							@CheckBox('Use new muzzle for male model', 'NewMuzzle')

							if ADVANCED_MODE\GetBool()
								@Hr()
								@CheckBox('Inherit Lips Color from body', 'LipsColorInherit')
								@CheckBox('Inherit Nose Color from body', 'NoseColorInherit')
								@ColorBox('Lips Color', 'LipsColor')
								@ColorBox('Nose Color', 'NoseColor')
								@Hr()
								@CheckBox('Glowing eyebrows', 'GlowingEyebrows')
								@NumSlider('Glow strength', 'EyebrowsGlowStrength', 2)

								@CheckBox('Separate Eyelashes Phong', 'SeparateEyelashesPhong')
								doAddPhongData(@, 'Eyelashes')

						'Mouth': =>
							@CheckBox('Fangs', 'Fangs')
							@CheckBox('Alternative Fangs', 'AlternativeFangs')
							@NumSlider('Fangs', 'FangsStrength', 2) if ADVANCED_MODE\GetBool()
							@CheckBox('Claw teeth', 'ClawTeeth')
							@NumSlider('Claw teeth', 'ClawTeethStrength', 2) if ADVANCED_MODE\GetBool()

							@Hr()

							@ColorBox('Teeth color', 'TeethColor')
							@ColorBox('Mouth color', 'MouthColor')
							@ColorBox('Tongue color', 'TongueColor')
							doAddPhongData(@, 'Teeth')
							doAddPhongData(@, 'Mouth')
							doAddPhongData(@, 'Tongue')
					}
				}

				eyel: {
					type: 'menu'
					name: 'Left Eye'
					dist: 20
					defang: Angle(-7, 30, 0)
					populate: genEyeMenu('Left')
				}

				eyer: {
					type: 'menu'
					name: 'Right Eye'
					dist: 20
					populate: genEyeMenu('Right')
				}

				mane_horn: {
					type: 'level'
					name: 'Mane and Horn'
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
							name: 'Mane'
							defang: Angle(-7, -120, 0)
							menus: {
								'Main': =>
									@ComboBox('Mane type', 'ManeTypeNew')
									@CheckBox('Hide entitites when using PAC3 entity', 'HideManes')
									@CheckBox('Hide mane when using PAC3 entity', 'HideManesMane')

									@Hr()
									@CheckBox('Separate mane phong settings from body', 'SeparateManePhong') if ADVANCED_MODE\GetBool()
									doAddPhongData(@, 'Mane') if ADVANCED_MODE\GetBool()
									@ColorBox("Mane color #{i}", "ManeColor#{i}") for i = 1, 2

									@Hr()
									@ColorBox("Mane detail color #{i}", "ManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

								'Details': =>
									@CheckBox('Separate upper and lower mane colors', 'SeparateMane')
									doAddPhongData(@, 'UpperMane', 'Upper Mane Phong Settings') if ADVANCED_MODE\GetBool()
									doAddPhongData(@, 'LowerMane', 'Lower Mane Phong Settings') if ADVANCED_MODE\GetBool()

									@Hr()
									@ColorBox("Upper Mane color #{i}", "UpperManeColor#{i}") for i = 1, 2
									@ColorBox("Lower Mane color #{i}", "LowerManeColor#{i}") for i = 1, 2

									@Hr()
									@ColorBox("Upper Mane detail color #{i}", "UpperManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
									@ColorBox("Lower Mane detail color #{i}", "LowerManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

								'URL Details': =>
									for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
										@Label("Mane URL Detail #{i} input field")
										@URLInput("ManeURL#{i}")
										@ColorBox("Mane URL detail color #{i}", "ManeURLColor#{i}")
										@Hr()

								'URL Separated Details': =>
									for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
										@Hr()
										@Label("Upper mane URL Detail #{i} input field")
										@URLInput("UpperManeURL#{i}")
										@ColorBox("Upper Mane URL detail color #{i}", "UpperManeURLColor#{i}")

									for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
										@Hr()
										@Label("Lower mane URL Detail #{i} input field")
										@URLInput("LowerManeURL#{i}")
										@ColorBox("Lower Mane URL detail color #{i}", "LowerManeURLColor#{i}")
							}
						}

						ears: {
							type: 'menu'
							name: 'Ears'
							defang: Angle(-12, -110, 0)
							populate: =>
								@CheckBox('Bat pony ears', 'BatPonyEars')
								@NumSlider('Bat pony ears', 'BatPonyEarsStrength', 2) if ADVANCED_MODE\GetBool()

								if ADVANCED_MODE\GetBool()
									@NumSlider('Ears Size', 'EarsSize', 2)
						}

						horn: {
							type: 'menu'
							name: 'Horn'
							dist: 30
							defang: Angle(-13, -20, 0)
							menus: {
								'Main': =>
									@ColorBox('Horn Detail Color', 'HornDetailColor')
									@CheckBox('Glowing Horn Detail', 'HornGlow')
									@NumSlider('Horn Glow Strength', 'HornGlowSrength', 2)
									@ColorBox('Horn color', 'HornColor')
									@ColorBox('Horn magic color', 'HornMagicColor')
									doAddPhongData(@, 'Horn') if ADVANCED_MODE\GetBool()

								'Details': =>
									for i = 1, 3
										@Label("Horn URL detail #{i}")
										@URLInput("HornURL#{i}")
										@ColorBox("URL Detail color #{i}", "HornURLColor#{i}")
										@Hr()

							}
						}
					}
				}
			}
		}

		spine: {
			type: 'level'
			name: 'Back'
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
					name: 'Wings'
					dist: 40
					defang: Angle(-12, -30, 0)

					menus: {
						'Main': =>
							@ColorBox('Wings color', 'WingsColor')
							@CheckBox('Separate wings color from body', 'SeparateWings')
							@CheckBox('Separate wings phong settings from body', 'SeparateWingsPhong') if ADVANCED_MODE\GetBool()
							@CheckBox('Separate horn color from body', 'SeparateHorn')
							@CheckBox('Separate horn phong settings from body', 'SeparateHornPhong') if ADVANCED_MODE\GetBool()
							@CheckBox('Separate magic color from eye color', 'SeparateMagicColor')
							@Hr()
							@ColorBox('Bat Wings color', 'BatWingColor')
							@ColorBox('Bat Wings skin color', 'BatWingSkinColor')
							doAddPhongData(@, 'BatWingsSkin', 'Bat wings skin phong parameters') if ADVANCED_MODE\GetBool()

						'Left': =>
							@NumSlider('Left Wing Size', 'LWingSize', 2)
							@NumSlider('Left Wing Forward', 'LWingX', 2)
							@NumSlider('Left Wing Up', 'LWingY', 2)
							@NumSlider('Left Wing Inside', 'LWingZ', 2)

						'Right': =>
							@NumSlider('Right Wing Size', 'RWingSize', 2)
							@NumSlider('Right Wing Forward', 'RWingX', 2)
							@NumSlider('Right Wing Up', 'RWingY', 2)
							@NumSlider('Right Wing Inside', 'RWingZ', 2)

						'Details': =>
							@Label('Normal wings')
							@Hr()

							for i = 1, 3
								@Label("Wings URL detail #{i}")
								@URLInput("WingsURL#{i}")
								@ColorBox("URL Detail color #{i}", "WingsURLColor#{i}")
								@Hr()

							@Label('Bat wings')
							@Hr()

							for i = 1, 3
								@Label("Bat Wings URL detail #{i}")
								@URLInput("BatWingURL#{i}")
								@ColorBox('Bat wing URL color', "BatWingURLColor#{i}")
								@Hr()

							@Label('Bat wings skin')
							@Hr()

							for i = 1, 3
								@Label("Bat Wings skin URL detail #{i}")
								@URLInput("BatWingSkinURL#{i}")
								@ColorBox('Bat wing skin URL color', "BatWingSkinURLColor#{i}")
								@Hr()
					}
				}

				neck: {
					type: 'menu'
					name: 'Neck'
					dist: 40
					defang: Angle(-7, -15, 0)
					populate: =>
						@NumSlider('Neck height', 'NeckSize', 2)
				}

				overall_body: {
					type: 'menu'
					name: 'Pony Body'
					dist: 90
					defang: Angle(-3, -90, 0)
					menus: {
						'Main': =>
							@ComboBox('Bodysuit', 'Bodysuit')
							@ColorBox('Body color', 'BodyColor')

						'Back': =>
							@NumSlider('Spine length', 'BackSize', 2)

						'Details': =>
							for i = 1, ADVANCED_MODE\GetBool() and PPM2.MAX_BODY_DETAILS or 3
								@ComboBox("Detail #{i}", "BodyDetail#{i}")
								@ColorBox("Detail color #{i}", "BodyDetailColor#{i}")
								if ADVANCED_MODE\GetBool()
									@CheckBox("Detail #{i} is glowing", "BodyDetailGlow#{i}")
									@NumSlider("Detail #{i} glow strength", "BodyDetailGlowStrength#{i}", 2)
								@Hr()

							@Label('Body detail URL image input fields\nShould be PNG or JPEG (works same as\nPAC3 URL texture)')
							@Hr()

							for i = 1, ADVANCED_MODE\GetBool() and PPM2.MAX_BODY_DETAILS or 2
								@Label("Body detail #{i}")
								@URLInput("BodyDetailURL#{i}")
								@ColorBox("URL Detail color #{i}", "BodyDetailURLColor#{i}")
								@Hr()

						'Tattoos': =>
							@ScrollPanel()

							for i = 1, PPM2.MAX_TATTOOS
								spoiler = @Spoiler("Tattoo layer #{i}")
								updatePanels = {}
								@Button('Edit using keyboard', (-> @GetFrame()\EditTattoo(i, updatePanels)), spoiler)
								@ComboBox('Type', "TattooType#{i}", nil, spoiler)
								table.insert(updatePanels, @NumSlider('Rotation', "TattooRotate#{i}", 0, spoiler))
								table.insert(updatePanels, @NumSlider('X Position', "TattooPosX#{i}", 2, spoiler))
								table.insert(updatePanels, @NumSlider('Y Position', "TattooPosY#{i}", 2, spoiler))
								table.insert(updatePanels, @NumSlider('Width Scale', "TattooScaleX#{i}", 2, spoiler))
								table.insert(updatePanels, @NumSlider('Height Scale', "TattooScaleY#{i}", 2, spoiler))
								@CheckBox('Tattoo over body details', "TattooOverDetail#{i}", spoiler)
								@CheckBox('Tattoo is glowing', "TattooGlow#{i}", spoiler)
								@NumSlider('Tattoo glow strength', "TattooGlowStrength#{i}", 2, spoiler)
								box, collapse = @ColorBox('Color of Tattoo', "TattooColor#{i}", spoiler)
								collapse\SetExpanded(true)
					}
				}
			}
		}

		tail: {
			type: 'menu'
			name: 'Tail'
			dist: 50
			defang: Angle(-10, -90, 0)

			menus: {
				'Main': =>
					@ComboBox('Tail type', 'TailTypeNew')

					@CheckBox('Hide entitites when using PAC3 entity', 'HideManes')
					@CheckBox('Hide tail when using PAC3 entity', 'HideManesTail')

					@NumSlider('Tail size', 'TailSize', 2)

					@Hr()
					@CheckBox('Separate tail phong settings from body', 'SeparateTailPhong') if ADVANCED_MODE\GetBool()
					doAddPhongData(@, 'Tail') if ADVANCED_MODE\GetBool()
					@ColorBox("Tail detail color #{i}", "TailDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

				'Details': =>
					for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
						@Hr()
						@Label("Tail URL Detail #{i} input field")
						@URLInput("TailURL#{i}")
						@ColorBox("Tail URL detail color #{i}", "TailURLColor#{i}")
			}
		}

		legs_submenu: {
			type: 'level'
			name: 'Hooves anatomy'
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
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_FL_FrontHoof'
					link: 'bottom_hoof'
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
				}
			}

			children: {
				bottom_hoof: {
					type: 'menu'
					name: 'Bottom Hoof'
					dist: 30
					defang: Angle(0, -90, 0)
					populate: =>
						@CheckBox('Hoof Fluffers', 'HoofFluffers')
						@NumSlider('Hoof Fluffers', 'HoofFluffersStrength', 2)
				}

				legs_generic: {
					type: 'menu'
					name: 'Legs'
					dist: 30
					defang: Angle(0, -90, 0)

					menus: {
						'General': =>
							@CheckBox('Hide entitites when using PAC3 entity', 'HideManes')
							@CheckBox('Hide socks when using PAC3 entity', 'HideManesSocks')
							@NumSlider('Legs height', 'LegsSize', 2)

						'Socks': =>
							@CheckBox('Socks (simple texture)', 'Socks') if ADVANCED_MODE\GetBool()
							@CheckBox('Socks (as model)', 'SocksAsModel')
							@ColorBox('Socks model color', 'SocksColor')

							if ADVANCED_MODE\GetBool()
								@Hr()
								doAddPhongData(@, 'Socks')
								@ComboBox('Socks Texture', 'SocksTexture')
								@Label('Socks URL texture')
								@URLInput('SocksTextureURL')

								@Hr()
								@CheckBox('Hoof Fluffers', 'HoofFluffers')
								@NumSlider('Hoof Fluffers', 'HoofFluffersStrength', 2)

								@Hr()
								@ColorBox('Socks detail color ' .. i, 'SocksDetailColor' .. i) for i = 1, 6

						'New Socks': =>
							@CheckBox('Socks (as new model)', 'SocksAsNewModel')
							@ColorBox('New Socks color 1', 'NewSocksColor1')
							@ColorBox('New Socks color 2', 'NewSocksColor2')
							@ColorBox('New Socks color 3', 'NewSocksColor3')

							if ADVANCED_MODE\GetBool()
								@Label('New Socks URL texture')
								@URLInput('NewSocksTextureURL')
								@Hr()
								@CheckBox('Separate wings color from body', 'SeparateWings')
								@CheckBox('Separate horn color from body', 'SeparateHorn')
								@ColorBox('Wings color', 'WingsColor')
								@ColorBox('Horn color', 'HornColor')
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
				else
					PPM2.Message('Editor3: Missing submenu ' .. point.link .. ' of ' .. node.id .. '!')

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
	@modelPanel.controllerData = copy
	@modelPanel\UpdateMenu(@modelPanel\CurrentMenu())

concommand.Add 'ppm2_editor3', ppm2_editor3
