
--
-- Copyright (C) 2017 DBot
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

MODEL_BOX_PANEL = {
    SEQUENCE_STAND: 22
    SEQUENCE_FORWARD: 316
    SEQUENCE_WALK: 232
    PONY_VEC_Z: 64 * .7

    EDITOR_SEQUENCES: {

    }

    Init: =>
        @animRate = 1
        @seq = SEQUENCE_STAND
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
        @nextSeq = @EDITOR_SEQUENCES[@editorSeq].time + RealTime()
        @playing = true
        @lastTick = RealTime()
    
    OnMousePressed: (code = MOUSE_LEFT) =>
        return if code ~= MOUSE_LEFT
        @hold = true
        @holdLast = RealTime() + .1
        @oldPlaying = @playing
        @playing = false
        @mouseX, @mouseY = gui.MousePos()
    OnMouseReleased: (code = MOUSE_LEFT) =>
        return if code ~= MOUSE_LEFT
        @hold = false
        if @holdLast > RealTime()
            @playing = true
            if not @oldPlaying
                @editorSeq = 1

    OnMouseWheeled: (wheelDelta = 0) =>
        @playing = false
        @editorSeq = 1
        @targetDistToPony = math.Clamp(@targetDistToPony + wheelDelta, 20, 150)
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
        @model = ClientsideModel(model)
        with @model
            \SetNoDraw(true)
            .__PPM2_PonyData = ponydata
        @model\SetSequence(@seq)
        @model\FrameAdvance(0)
        return @model
    Think: =>
        rtime = RealTime()
        delta = rtime - @lastTick
        @lastTick = rtime
        if IsValid(@model)
            @model\FrameAdvance(delta * @animRate)
        
        if @playing
            cseq = @EDITOR_SEQUENCES[@editorSeq]
            if @nextSeq < rtime
                @editorSeq += 1
                @editorSeq = 1 if not @EDITOR_SEQUENCES[@editorSeq]
                cseq = @EDITOR_SEQUENCES[@editorSeq]
                @nextSeq = rtime + cseq.time
            @targetDistToPony, @targetAngle = cseq.func(@targetDistToPony, @targetAngle, delta)
        else
            x, y = gui.MousePos()
            deltaX, deltaY = x - @mouseX, y - @mouseY
            @mouseX, @mouseY = x, y
            {:pitch, :yaw, :roll} = @targetAngle
            yaw += deltaX
            pitch += deltaY
            @targetAngle = Angle(pitch, yaw, roll)
        
        @angle = LerpAngle(delta / 2, @angle, @targetAngle)
        @distToPony = Lerp(delta / 2, @distToPony, @targetDistToPony)
        @vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)
        @vectorPos\Rotate(@angle)
        @drawAngle = (Vector(0, 0, @PONY_VEC_Z) - @vectorPos)\Angle()
    Paint: (w = 0, h = 0) =>
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
        return if not IsValid(@model)
        cam.Start3D(@vectorPos, @drawAngle)
        @model\DrawModel()
        cam.End3D()
}

vgui.Register('PPM2ModelPanel', MODEL_BOX_PANEL, 'EditablePanel')

PANEL_SETTINGS_BASE = {
    Init: =>
        @shouldSaveData = false
    GetShouldSaveData: => @shouldSaveData
    ShouldSaveData: => @shouldSaveData
    SetShouldSaveData: (val = false) => @shouldSaveData = val
    GetTargetData: => @data
    TargetData: => @data
    SetTargetData: (val) => @data = val
    NumSlider: (name = 'Slider', option = '', min = 0, max = 1, decimals = 0) =>
		with vgui.Create('DNumSlider', @)
			\Dock(TOP)
			\DockMargin(2, 0, 2, 0)
			\SetTooltip("#{name}\nData value: #{option}")
			\SetText(name)
			\SetMin(min)
			\SetMax(max)
			\SetDecimals(decimals)
            \SetValue(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			.TextArea\SetTextColor(color_white)
			.Label\SetTextColor(color_white)
            .OnValueChanged = (pnl, newVal = 1) ->
                return if option == ''
                data = @GetTargetData()
                return if not data
                data["Set#{option}"](data, newVal, @GetShouldSaveData())
	CheckBox: (name = 'Label', option = '') =>
		with vgui.Create('DCheckBoxLabel', @)
			\Dock(TOP)
			\DockMargin(2, 2, 2, 2)
			\SetText(name)
			\SetTextColor(color_white)
			\SetTooltip("#{name}\nData value: #{option}")
			\SetChecked(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
            .OnChange = (pnl, newVal = false) ->
                return if option == ''
                data = @GetTargetData()
                return if not data
                data["Set#{option}"](data, newVal, @GetShouldSaveData())
    ColorBox: (name = 'Colorful Box', option = '') =>
        collapse = vgui.Create('DCollapsibleCategory', @)
        box = vgui.Create('DColorMixer', collapse)
        collapse.box = box
        with box
            \SetSize(250, 180)
			\SetTooltip("#{name}\nData value: #{option}")
            \SetColor(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
            .ValueChanged = (pnl, newVal = Color(0, 0, 0)) ->
                return if option == ''
                data = @GetTargetData()
                return if not data
                data["Set#{option}"](data, newVal, @GetShouldSaveData())
        with collapse
            \SetContents(box)
            \Dock(TOP)
            \DockMargin(2, 2, 2, 2)
            \SetSize(250, 180)
            \SetLabel(name)
            \SetExpanded(false)
        return box, collapse
    ComboBox: (name = 'Combo Box', option = '', choices = {}) =>
        label = vgui.Create('DLabel', @)
        with label
            \SetText(name)
            \SetTextColor(color_white)
            \Dock(TOP)
            \SetSize(0, 20)
        box = vgui.Create('DComboBox', label)
        with box
            \Dock(RIGHT)
            \SetSize(90)
            \SetValue(@GetTargetData()["Get#{option}Enum"](@GetTargetData())) if @GetTargetData()
            \AddChoice(choice) for choice in *choices
            .OnSelect = (pnl = box, index = 1, value = '', data = value) ->
                index -= 1
        return box, label
    Paint: (w = 0, h = 0) =>
		surface.SetDrawColor(130, 130, 130)
		surface.DrawRect(0, 0, w, h)
}

vgui.Register('PPM2SettingsBase', PANEL_SETTINGS_BASE, 'EditablePanel')

EditorPages = {
    {
        'name': 'Main'
        'func': (sheet) =>
            @NumSlider('Weight', 'Weight')
    }
}

PPM2.OpenEditor = ->
    frame = vgui.Create('DFrame')
    self = frame
    @SetSize(ScrW() - 25, ScrH() - 25)
    @Center()
    @MakePopup()
    @SetTitle('PPM2 Pony Editor')

    @menus = vgui.Create('DPropertySheet', @)
    @menus\Dock(LEFT)
    @menus\SetSize(180, 0)

    @model = vgui.Create('PPM2ModelPanel', @)
    @model\Dock(FILL)

    copy = PPM2.GetMainData()\Copy()
    ply = @LocalPlayer()
    ent = @model\ResetModel(nil, ply\IsPony() and ply\GetModel() or 'models/ppm/player_default_base.mdl')
    controller = copy\CreateCustomController(ent)
    copy\SetController(controller)

    for {:name, :func} in *EditorPages
        pnl = vgui.Create('PPM2SettingsBase', @menus)
        @menus\AddSheet(pnl)
        pnl\SetTargetData(copy)
        func(pnl, @menus)
