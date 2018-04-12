
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

	PerformLayout: (w = 0, h = 0) =>
		if @InMenu()
			bX, bY = @backButton\GetPos()
			bW, bH = @backButton\GetSize()
			w, h = @GetSize()
			W, H = @seqButton\GetSize()
			@seqButton\SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8))
			W, H = @emotesPanel\GetSize()
			@emotesPanel\SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8) + 30)
		else
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

			if menu.menus
				@settingsPanel = vgui.Create('DPropertySheet', frame)
				@settingsPanel\SetPos(x, y)
				@settingsPanel\SetSize(width, H)

				for menuName, menuPopulate in pairs menu.menus
					with menuPanel = vgui.Create('PPM2SettingsBase', @settingsPanel)
						with vgui.Create('DLabel', menuPanel)
							\Dock(TOP)
							\SetFont('PPM2EditorPanelHeaderText')
							\SetText(menuName)
							\SizeToContents()
						@settingsPanel\AddSheet(menuName, menuPanel)
						\SetTargetData(@controllerData)
						\Dock(FILL)
						menuPopulate(menuPanel)
			else
				with @settingsPanel = vgui.Create('PPM2SettingsBase', frame)
					with vgui.Create('DLabel', @settingsPanel)
						\Dock(TOP)
						\SetFont('PPM2EditorPanelHeaderText')
						\SetText(menu.name or menu.id or '<unknown>')
						\SizeToContents()
					\SetPos(x, y)
					\SetSize(width, H)
					\SetTargetData(@controllerData)
					menu.populate(@settingsPanel)

			bX, bY = @backButton\GetPos()
			bW, bH = @backButton\GetSize()
			w, h = @GetSize()
			W, H = @seqButton\GetSize()
			@seqButton\SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8))
			W, H = @seqButton\GetSize()
			@emotesPanel\SetPos(w - ScreenScale(6) - W, bY + bH + ScreenScale(8) + 30)

		@fixedDistanceToPony = menu.dist
		@angle = Angle(menu.defang)
		@distToPony = 90
		return @

	PopMenu: =>
		assert(#@stack > 1, 'invalid stack size to pop from')
		if @InMenu() and IsValid(@settingsPanel)
			@settingsPanel\Remove()
			@seqButton\SetPos(10, 10)
			@emotesPanel\SetPos(10, 40)
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

EDIT_TREE = {
	type: 'level'
	name: 'Pony overview'
	dist: 100
	defang: Angle(-10, -30, 0)

	points: {
		{
			type: 'bone'
			target: 'LrigScull'
			link: 'head_submenu'
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
							defang: Angle(-7, -120, 0)
							populate: =>
						}

						ears: {
							type: 'menu'
							defang: Angle(-12, -110, 0)
							populate: =>
						}

						horn: {
							type: 'menu'
							dist: 30
							defang: Angle(-13, -20, 0)
							populate: =>
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
					populate: =>
				}

				neck: {
					type: 'menu'
					name: 'Neck'
					dist: 40
					defang: Angle(-7, -15, 0)
					populate: =>
				}

				overall_body: {
					type: 'menu'
					name: 'Pony Body'
					dist: 90
					defang: Angle(-3, -90, 0)
					populate: =>
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
				'Details': =>
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
					link: 'legs_length'
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_FR_Metacarpus'
					link: 'legs_length'
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_BR_LargeCannon'
					link: 'legs_length'
				}

				{
					type: 'bone'
					target: 'Lrig_LEG_BL_LargeCannon'
					link: 'legs_length'
				}
			}

			children: {
				bottom_hoof: {
					type: 'menu'
					name: 'Buttom Hoof'
					dist: 30
					defang: Angle(0, -90, 0)
					populate: =>
				}

				legs_length: {
					type: 'menu'
					name: 'Buttom Hoof'
					dist: 30
					defang: Angle(0, -90, 0)
					populate: =>
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

concommand.Add 'ppm2_editor3', ppm2_editor3
