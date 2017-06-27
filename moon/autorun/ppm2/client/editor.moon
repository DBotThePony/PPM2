
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

ADVANCED_MODE = CreateConVar('ppm2_editor_advanced', '0', {FCVAR_ARCHIVE}, 'Show all options')
ENABLE_FULLBRIGHT = CreateConVar('ppm2_editor_fullbright', '1', {FCVAR_ARCHIVE}, 'Disable lighting in editor')

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

IS_USING_NEW = ->
    switch USE_MODEL\GetString()
        when 'new'
            return true
        else
            return false

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

    EDITOR_SEQUENCES: {
        -- idle
        {
            time: 5
            func: (dist, ang, delta) -> dist, ang
        }

        -- Slow move to left
        {
            time: 5
            func: (dist, ang, delta) ->
                ang.y += delta * 10
                return dist, ang
        }

        -- Eyes
        {
            time: 5
            func: (dist, ang, delta) ->
                return 40, Angle(0, 0, 0)
        }

        -- Left view
        {
            time: 3
            func: (dist, ang, delta) ->
                return 80, Angle(0, 90, 0)
        }

        -- Move to right
        {
            time: 7
            func: (dist, ang, delta) ->
                ang.y -= 10 * delta
                return 80, ang
        }

        -- Eyes (bottom)
        {
            time: 5
            func: (dist, ang, delta) ->
                return 20, Angle(40, 0, 0)
        }

        -- Look at top mane
        {
            time: 5
            func: (dist, ang, delta) ->
                return 50, Angle(-20, 180, 0)
        }
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
        @nextSeq = @EDITOR_SEQUENCES[@editorSeq].time + RealTime()
        @playing = true
        @lastTick = RealTime()
        @SetCursor('none')

        -- @animButton = vgui.Create('DButton', @)
        -- with @animButton
        --     \SetSize(120, 20)
        --     \SetText('Playing animation')
        --     .LastStatus = true
        --     .Think = ->
        --         if .LastStatus ~= @playing
        --             .LastStatus = @playing
        --             \SetText('Playing Animation') if @playing
        --             \SetText('Play Animation') if not @playing
        --     .DoClick = ->
        --         @playing = not @playing
        --         if @playing
        --             @editorSeq = 1
        --             @nextSeq = RealTime() + @EDITOR_SEQUENCES[@editorSeq].time
        --             @ResetPosition()

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
        --@animButton\SetPos(w - 130, 10)
        @seqButton\SetPos(10, 10)
        @emotesPanel\SetPos(10, 40) if IsValid(@emotesPanel)
    
    OnMousePressed: (code = MOUSE_LEFT) =>
        return if code ~= MOUSE_LEFT
        @hold = true
        @SetCursor('sizeall')
        @holdLast = RealTime() + .1
        @oldPlaying = @playing
        @playing = false
        @mouseX, @mouseY = gui.MousePos()
    OnMouseReleased: (code = MOUSE_LEFT) =>
        return if code ~= MOUSE_LEFT
        @hold = false
        @SetCursor('none')
        if @holdLast > RealTime()
            @playing = true
            if not @oldPlaying
                @editorSeq = 1
                @nextSeq = RealTime() + @EDITOR_SEQUENCES[@editorSeq].time
                @ResetPosition()

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
        @model = ClientsideModel(model)
        with @model
            \SetNoDraw(true)
            .__PPM2_PonyData = ponydata
        @model\SetSequence(@seq)
        @model\FrameAdvance(0)
        @emotesPanel\Remove() if IsValid(@emotesPanel)
        if IS_USING_NEW()
            @emotesPanel = PPM2.CreateEmotesPanel(@, @model, false)
            @emotesPanel\SetPos(10, 40)
            @emotesPanel\SetMouseInputEnabled(true)
            @emotesPanel\SetVisible(true)
        return @model
    Think: =>
        rtime = RealTime()
        delta = rtime - @lastTick
        @lastTick = rtime
        if IsValid(@model)
            @model\FrameAdvance(delta * @animRate)
            @model\SetPlaybackRate(1)
            @model\SetPoseParameter('move_x', 1)
        
        @hold = @IsHovered() if @hold
        
        -- if @playing
        --     cseq = @EDITOR_SEQUENCES[@editorSeq]
        --     if @nextSeq < rtime
        --         @editorSeq += 1
        --         @editorSeq = 1 if not @EDITOR_SEQUENCES[@editorSeq]
        --         cseq = @EDITOR_SEQUENCES[@editorSeq]
        --         @nextSeq = rtime + cseq.time
            
        --     {:p, :y, :r} = @targetAngle
        --     @targetDistToPony, @targetAngle = cseq.func(@targetDistToPony, Angle(p, y, r), delta)
        --     @targetDistToPony = math.Clamp(@targetDistToPony, 20, 150)
        --     @targetAngle.p = math.Clamp(@targetAngle.p, -40, 10)
        -- else
        --     if @hold
        --         x, y = gui.MousePos()
        --         deltaX, deltaY = x - @mouseX, y - @mouseY
        --         @mouseX, @mouseY = x, y
        --         {:pitch, :yaw, :roll} = @targetAngle
        --         yaw -= deltaX * .5
        --         pitch = math.Clamp(pitch - deltaY * .5, -40, 10)
        --         @targetAngle = Angle(pitch, yaw, roll)
        
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

        for {pos, ang, w, h} in *@DRAW_WALLS
            render.DrawQuadEasy(pos, ang, w, h, @WALL_COLOR)

        if ENABLE_FULLBRIGHT\GetBool()
            render.SuppressEngineLighting(true)
            render.ResetModelLighting(1, 1, 1)
            render.SetColorModulation(1, 1, 1)
        @controller\GetRenderController()\DrawModels()
        @controller\GetRenderController()\HideModels(true) if @controller
        @controller\GetRenderController()\PreDraw(@model) if @controller
        
        if data = @model\GetPonyData()
            if bg = data\GetBodygroupController()
                bg\ApplyBodygroups()
            if size = data\GetSizeController()
                size\ModifyNeck()
                size\ModifyLegs()
                size\ModifyScale()
        @model\DrawModel()
        @controller\GetRenderController()\PostDraw(@model) if @controller
        render.SuppressEngineLighting(false) if ENABLE_FULLBRIGHT\GetBool()

        cam.End3D()
    OnRemove: =>
        @model\Remove() if IsValid(@model)
}

vgui.Register('PPM2ModelPanel', MODEL_BOX_PANEL, 'EditablePanel')

CALC_VIEW_PANEL = {
    Init: =>
        @playingOpenAnim = true
        @lock = false
        @mousex, @mousey = 0, 0
    CalcView: (ply = LocalPlayer(), origin = Vector(0, 0, 0), angles = Angle(0, 0, 0), fov = 90, znear = 0, zfar = 1000) =>
}

PANEL_SETTINGS_BASE = {
    Init: =>
        @shouldSaveData = false
        @SetMouseInputEnabled(true)
        @SetKeyboardInputEnabled(true)
        @DockPadding(5, 5, 5, 5)
        @unsavedChanges = false
        @updateFuncs = {}
        @createdPanels = 1
    ValueChanges: (valID, newVal, pnl) =>
        @unsavedChanges = true
        @frame.unsavedChanges = true
        @frame\SetTitle("#{@GetTargetData() and @GetTargetData()\GetFilename() or '%ERRNAME%'} - PPM2 Pony Editor; *Unsaved changes*")
    GetShouldSaveData: => @shouldSaveData
    ShouldSaveData: => @shouldSaveData
    SetShouldSaveData: (val = false) => @shouldSaveData = val
    GetTargetData: => @data
    TargetData: => @data
    SetTargetData: (val) => @data = val
    DoUpdate: => func() for func in *@updateFuncs
    NumSlider: (name = 'Slider', option = '', decimals = 0, parent = @scroll or @) =>
        @createdPanels += 3
		with vgui.Create('DNumSlider', parent)
			\Dock(TOP)
			\DockMargin(2, 0, 2, 0)
			\SetTooltip("#{name}\nData value: #{option}")
			\SetText(name)
			\SetMin(0)
			\SetMax(1)
			\SetMin(@GetTargetData()["GetMin#{option}"](@GetTargetData())) if @GetTargetData()
			\SetMax(@GetTargetData()["GetMax#{option}"](@GetTargetData())) if @GetTargetData()
			\SetDecimals(decimals)
            \SetValue(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
			.TextArea\SetTextColor(color_white)
			.Label\SetTextColor(color_white)
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
            @scroll\AddItem(_with_0) if IsValid(@scroll) and parent == @scroll
    Label: (text = '', parent = @scroll or @) =>
        @createdPanels += 1
        with vgui.Create('DLabel', parent)
            \SetText(text)
            \Dock(TOP)
            \DockMargin(2, 2, 2, 2)
            \SetTextColor(color_white)
            \SizeToContents()
            w, h = \GetSize()
            \SetSize(w, h + 5)
            @scroll\AddItem(_with_0) if IsValid(@scroll) and parent == @scroll
    URLLabel: (text = '', url = '', parent = @scroll or @) =>
        @createdPanels += 1
        with vgui.Create('DLabel', parent)
            \SetText(text)
            \Dock(TOP)
            \DockMargin(2, 2, 2, 2)
            \SetTextColor(Color(158, 208, 208))
            \SizeToContents()
            \SetCursor('hand')
            w, h = \GetSize()
            \SetSize(w, h + 5)
            \SetMouseInputEnabled(true)
            .DoClick = -> gui.OpenURL(url) if url ~= ''
            @scroll\AddItem(_with_0) if IsValid(@scroll) and parent == @scroll
    Hr: (parent = @scroll or @) =>
        @createdPanels += 1
        with vgui.Create('EditablePanel', parent)
            \Dock(TOP)
            \SetSize(200, 15)
            @scroll\AddItem(_with_0) if IsValid(@scroll) and parent == @scroll
            .Paint = (w = 0, h = 0) =>
                surface.SetDrawColor(150, 162, 162)
                surface.DrawLine(0, h / 2, w, h / 2)
    Button: (text = 'Perfectly generic button', doClick = (->), parent = @scroll or @) =>
        @createdPanels += 1
        with vgui.Create('DButton', parent)
            \Dock(TOP)
            \SetSize(200, 20)
            \DockMargin(2, 2, 2, 2)
            \SetText(text)
            @scroll\AddItem(_with_0) if IsValid(@scroll) and parent == @scroll
            .DoClick = -> doClick()
	CheckBox: (name = 'Label', option = '', parent = @scroll or @) =>
        @createdPanels += 3
		with vgui.Create('DCheckBoxLabel', parent)
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
                data["Set#{option}"](data, newVal and 1 or 0, @GetShouldSaveData())
                @ValueChanges(option, newVal and 1 or 0, pnl)
            table.insert @updateFuncs, ->
                \SetChecked(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
            @scroll\AddItem(_with_0) if IsValid(@scroll) and parent == @scroll
    ColorBox: (name = 'Colorful Box', option = '', parent = @scroll or @) =>
        @createdPanels += 7
        collapse = vgui.Create('DCollapsibleCategory', parent)
        box = vgui.Create('DColorMixer', collapse)
        collapse.box = box
        with box
            \SetSize(250, 270)
			\SetTooltip("#{name}\nData value: #{option}")
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
        return box, collapse
    Spoiler: (name = 'Mysterious spoiler', parent = @scroll or @) =>
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
        label = vgui.Create('DLabel', parent)
        with label
            \SetText(name)
            \SetTextColor(color_white)
            \Dock(TOP)
            \SetSize(0, 20)
            \DockMargin(5, 0, 5, 0)
            \SetMouseInputEnabled(true)
        @scroll\AddItem(label) if IsValid(@scroll) and parent == @scroll
        box = vgui.Create('DComboBox', label)
        with box
            \Dock(RIGHT)
            \SetSize(170, 0)
            \DockMargin(0, 0, 5, 0)
            \SetSortItems(false)
            \SetValue(@GetTargetData()["Get#{option}Enum"](@GetTargetData())) if @GetTargetData()
            if choices
                \AddChoice(choice) for choice in *choices
            else
                \AddChoice(choice) for choice in *@GetTargetData()["Get#{option}Types"](@GetTargetData()) if @GetTargetData() and @GetTargetData()["Get#{option}Types"]
            .OnSelect = (pnl = box, index = 1, value = '', data = value) ->
                index -= 1
                data = @GetTargetData()
                return if not data
                data["Set#{option}"](data, index, @GetShouldSaveData())
                @ValueChanges(option, index, pnl)
            table.insert @updateFuncs, ->
                \SetValue(@GetTargetData()["Get#{option}Enum"](@GetTargetData())) if @GetTargetData()
        return box, label
    URLInput: (option = '', parent = @scroll or @) =>
        @createdPanels += 2
        wrapper = vgui.Create('EditablePanel', parent)
        with wrapper
            \Dock(TOP)
            \DockMargin(5, 10, 5, 10)
            \SetKeyboardInputEnabled(true)
            \SetMouseInputEnabled(true)
            \SetSize(0, 20)
        textInput = vgui.Create('DTextEntry', wrapper)
        @scroll\AddItem(wrapper) if IsValid(@scroll) and parent == @scroll
        with textInput
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

EditorPages = {
    {
        'name': 'Main'
        'internal': 'main'
        'func': (sheet) =>
            @ScrollPanel()
            @Button 'Randomize!', ->
                data = @GetTargetData()
                return if not data
                confirmed = ->
                    PPM2.Randomize(data, false)
                    @ValueChanges()
                Derma_Query('Really want to randomize?', 'Randomize', 'Yas!', confirmed, 'Noh!')
            
            @ComboBox('Race', 'Race')
            @ComboBox('Wings Type', 'WingsType') if IS_USING_NEW()
            @CheckBox('Gender', 'Gender')
            @CheckBox('Use new muzzle for male model', 'NewMuzzle') if IS_USING_NEW()
            @NumSlider('Male chest buff', 'MaleBuff', 2) if IS_USING_NEW()
            @NumSlider('Weight', 'Weight', 2)
            @NumSlider('Pony Size', 'PonySize', 2)

            if ADVANCED_MODE\GetBool() and IS_USING_NEW()
                @Hr()
                @CheckBox('No flexes on new model', 'NoFlex')
                @Label('You can disable separately any flex state controller\nSo these flexes can be modified with third-party addons (like PAC3)')
                flexes = @Spoiler('Flexes controls')
                for {:flex, :active} in *PPM2.PonyFlexController.FLEX_LIST
                    @CheckBox("Disable #{flex} control", "DisableFlex#{flex}")\SetParent(flexes) if active
                flexes\SizeToContents()
    }

    {
        'name': 'Body'
        'internal': 'body'
        'func': (sheet) =>
            @ScrollPanel()
            @ComboBox('Bodysuit', 'Bodysuit')
            @ColorBox('Body color', 'BodyColor')
            @NumSlider('Neck Height', 'NeckSize', 2)
            @NumSlider('Legs Height', 'LegsSize', 2)
            @CheckBox('Socks (simple texture)', 'Socks') if ADVANCED_MODE\GetBool()
            @CheckBox('Socks (as model)', 'SocksAsModel')
            @ColorBox('Socks model color', 'SocksColor')

            if ADVANCED_MODE\GetBool()
                @ComboBox('Socks Texture', 'SocksTexture')
                @Label('Socks URL texture')
                @URLInput('SocksTextureURL')
                @Hr()
                @ColorBox('Socks detail color ' .. i, 'SocksDetailColor' .. i) for i = 1, 6
                @Hr()
                @CheckBox('Separate wings color from body', 'SeparateWings')
                @CheckBox('Separate horn color from body', 'SeparateHorn')
                @ColorBox('Wings color', 'WingsColor')
                @ColorBox('Horn color', 'HornColor')
    }

    {
        'name': 'Wings and horn'
        'internal': 'wings_horn'
        'func': (sheet) =>
            @ScrollPanel()
            @CheckBox('Separate wings color from body', 'SeparateWings')
            @CheckBox('Separate horn color from body', 'SeparateHorn')
            @Hr()
            @ColorBox('Wings color', 'WingsColor')
            @ColorBox('Horn color', 'HornColor')
            return if not IS_USING_NEW()
            @Hr()
            @ColorBox('Bat Wings color', 'BatWingColor')
            @ColorBox('Bat Wings skin color', 'BatWingSkinColor')
    }

    {
        'name': 'Wings and horn details'
        'internal': 'wings_horn_details'
        'display': -> ADVANCED_MODE\GetBool()
        'func': (sheet) =>
            @ScrollPanel()

            for i = 1, 3
                @Label("Horn URL detail #{i}")
                @URLInput("HornURL#{i}")
                @ColorBox("URL Detail color #{i}", "HornURLColor#{i}")
                @Hr()
            
            @Hr()
            @Label('Normal wings')
            @Hr()

            for i = 1, 3
                @Label("Wings URL detail #{i}")
                @URLInput("WingsURL#{i}")
                @ColorBox("URL Detail color #{i}", "WingsURLColor#{i}")
                @Hr()
            
            @Hr()
            @Label('Bat wings')
            @Hr()
            
            for i = 1, 3
                @Label("Bat Wings URL detail #{i}")
                @URLInput("BatWingURL#{i}")
                @ColorBox('Bat wing URL color', "BatWingURLColor#{i}")
                @Hr()
            
            @Hr()
            @Label('Bat wings skin')
            @Hr()
            
            for i = 1, 3
                @Label("Bat Wings skin URL detail #{i}")
                @URLInput("BatWingSkinURL#{i}")
                @ColorBox('Bat wing skin URL color', "BatWingSkinURLColor#{i}")
                @Hr()
    }

    {
        'name': 'Body details'
        'internal': 'bodydetails'
        'func': (sheet) =>
            @ScrollPanel()

            for i = 1, ADVANCED_MODE\GetBool() and PPM2.MAX_BODY_DETAILS or 3
                @ComboBox("Detail #{i}", "BodyDetail#{i}")
                @ColorBox("Detail color #{i}", "BodyDetailColor#{i}")
                @Hr()

            @Label('Body detail URL image input fields\nShould be PNG or JPEG (works same as\nPAC3 URL texture)')
            @Hr()

            for i = 1, ADVANCED_MODE\GetBool() and PPM2.MAX_BODY_DETAILS or 2
                @Label("Body detail #{i}")
                @URLInput("BodyDetailURL#{i}")
                @ColorBox("URL Detail color #{i}", "BodyDetailURLColor#{i}")
                @Hr()
    }

    {
        'name': 'Face'
        'internal': 'face'
        'func': (sheet) =>
            @ScrollPanel()
            @ComboBox('Eyelashes', 'EyelashType')
            if IS_USING_NEW()
                @CheckBox('Bat pony ears', 'BatPonyEars')
                @CheckBox('Fangs', 'Fangs')
                @CheckBox('Claw teeth', 'ClawTeeth')

                if ADVANCED_MODE\GetBool()
                    @Hr()
                    @ColorBox('Teeth color', 'TeethColor')
                    @ColorBox('Mouth color', 'MouthColor')
                    @ColorBox('Tongue color', 'TongueColor')
    }

    {
        'name': 'Eyes'
        'internal': 'eyes'
        'func': (sheet) =>
            @ScrollPanel()
            if ADVANCED_MODE\GetBool()
                @Hr()
                @CheckBox('Use separated settings for eyes', 'SeparateEyes')
            eyes = {''}
            eyes = {'', 'Left', 'Right'} if ADVANCED_MODE\GetBool()
            for publicName in *eyes
                @Hr()
                prefix = ''
                if publicName ~= ''
                    prefix = publicName .. ' '
                    @Label("'#{publicName}' Eye settings")
                
                @Label('Eye URL texture')
                @URLInput("EyeURL#{publicName}")
                @Label('When uring eye URL texture; options below have no effect')
                @ComboBox("#{prefix}Eye type", "EyeType#{publicName}")
                @CheckBox("#{prefix}Eye lines", "EyeLines#{publicName}")
                @CheckBox("#{prefix}Derp eye", "DerpEyes#{publicName}")
                @NumSlider("#{prefix}Derp eye strength", "DerpEyesStrength#{publicName}", 2)
                @NumSlider("#{prefix}Eye size", "IrisSize#{publicName}", 2)

                if ADVANCED_MODE\GetBool()
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
    }

    {
        'name': 'Mane and tail'
        'internal': 'manetail_old'
        'display': -> not IS_USING_NEW()
        'func': (sheet) =>
            @ScrollPanel()
            @ComboBox('Mane type', 'ManeType')
            @ComboBox('Lower Mane type', 'ManeTypeLower')
            @ComboBox('Tail type', 'TailType')

            @NumSlider('Tail size', 'TailSize', 2)

            @Hr()
            @ColorBox("Mane color #{i}", "ManeColor#{i}") for i = 1, 2
            @ColorBox("Tail color #{i}", "TailColor#{i}") for i = 1, 2

            @Hr()
            @ColorBox("Mane detail color #{i}", "ManeDetailColor#{i}") for i = 1, 4
            @ColorBox("Tail detail color #{i}", "TailDetailColor#{i}") for i = 1, 4
    }

    {
        'name': 'Mane and tail'
        'internal': 'manetail_new'
        'display': IS_USING_NEW
        'func': (sheet) =>
            @ScrollPanel()
            @Label('"New" affect only new model')
            @ComboBox('New Mane type', 'ManeTypeNew')
            @ComboBox('New Lower Mane type', 'ManeTypeLowerNew')
            @ComboBox('New Tail type', 'TailTypeNew')

            @NumSlider('Tail size', 'TailSize', 2)

            @Hr()
            @ColorBox("Mane color #{i}", "ManeColor#{i}") for i = 1, 2
            @ColorBox("Tail color #{i}", "TailColor#{i}") for i = 1, 2

            @Hr()
            @ColorBox("Mane detail color #{i}", "ManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
            @ColorBox("Tail detail color #{i}", "TailDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4

            @Hr()
            @CheckBox('Separate upper and lower mane colors', 'SeparateMane')
            @Label('These options have effect only on new model')

            @Hr()
            @ColorBox("Upper Mane color #{i}", "UpperManeColor#{i}") for i = 1, 2
            @ColorBox("Lower Mane color #{i}", "LowerManeColor#{i}") for i = 1, 2

            @Hr()
            @ColorBox("Upper Mane detail color #{i}", "UpperManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
            @ColorBox("Lower Tail detail color #{i}", "LowerManeDetailColor#{i}") for i = 1, ADVANCED_MODE\GetBool() and 6 or 4
    }

    {
        'name': 'Mane and tail URL details'
        'internal': 'manetail'
        'func': (sheet) =>
            @ScrollPanel()
            for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
                @Label("Mane URL Detail #{i} input field")
                @URLInput("ManeURL#{i}")
                @ColorBox("Mane URL detail color #{i}", "ManeURLColor#{i}")
                @Hr()

            for i = 1, ADVANCED_MODE\GetBool() and 6 or 1
                @Hr()
                @Label("Tail URL Detail #{i} input field")
                @URLInput("TailURL#{i}")
                @ColorBox("Tail URL detail color #{i}", "TailURLColor#{i}")
            
            @Label('Next options have effect only on new model')
            @CheckBox('Separate upper and lower mane colors', 'SeparateMane')
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

    {
        'name': 'Cutiemark'
        'internal': 'cmark'
        'func': (sheet) =>
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

    {
        'name': 'Files'
        'internal': 'saves'
        'func': (sheet) =>
            @Label('Open file by double click')
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
                    @frame\SetTitle("#{fil} - PPM2 Pony Editor")
                if @unsavedChanges
                    Derma_Query(
                        "Currently, you did not stated your changes.\nDo you really want to open #{fil}?",
                        'Unsaved changes!',
                        'Yas!',
                        confirm,
                        'Noh!'
                    )
                else
                    confirm()
            list.DoDoubleClick = (pnl, rowID, line) ->
                fil = line\GetColumnText(1)
                openFile(fil)
            list.OnRowRightClick = (pnl, rowID, line) ->
                fil = line\GetColumnText(1)
                menu = DermaMenu()
                menu\AddOption('Open', -> openFile(fil))\SetIcon('icon16/accept.png')
                menu\AddOption('Delete', ->
                    confirm = ->
                        file.Delete("ppm2/#{fil}.txt")
                        @rebuildFileList()
                    Derma_Query(
                        "Do you really want to delete #{fil}?\nIt will be gone forever!\n(a long time!)",
                        "Delete #{fil}?",
                        'Yas!',
                        confirm,
                        'Noh!'
                    )
                )\SetIcon('icon16/cross.png')
                menu\Open()
            list\AddColumn('Filename')
            @rebuildFileList = ->
                list\Clear()
                files, dirs = file.Find('ppm2/*', 'DATA')
                for fil in *files
                    matchBak = '.bak.txt'
                    continue if fil\sub(-#matchBak) == matchBak
                    list\AddLine(fil\sub(1, #fil - 4))
            @rebuildFileList()
    }

    {
        'name': 'Old Files'
        'internal': 'oldsaves'
        'func': (sheet) =>
            @Label('!!! It may or may not work. You will be squished.')
            list = vgui.Create('DListView', @)
            list\Dock(FILL)
            list\SetMultiSelect(false)
            list.DoDoubleClick = (pnl, rowID, line) ->
                fil = line\GetColumnText(1)
                confirm = ->
                    newData = PPM2.ReadFromOldData(fil)
                    if not newData
                        Derma_Message('Failed to import.', 'Onoh!', 'Okai ;w;')
                        return
                    @frame.data\SetFilename(newData\GetFilename())
                    newData\ApplyDataToObject(@frame.data, false)
                    @frame.data\UpdateController()
                    @frame.DoUpdate()
                    @unsavedChanges = true
                    @frame.unsavedChanges = true
                    @frame\SetTitle("#{newData\GetFilename()} - PPM2 Pony Editor; *Unsaved changes*")
                if @unsavedChanges
                    Derma_Query(
                        "Currently, you did not stated your changes.\nDo you really want to open #{fil}?",
                        'Unsaved changes!',
                        'Yas!',
                        confirm,
                        'Noh!'
                    )
                else
                    confirm()
            list\AddColumn('Filename')
            @rebuildFileList = ->
                list\Clear()
                files, dirs = file.Find('ppm/*', 'DATA')
                list\AddLine(fil\sub(1, #fil - 4)) for fil in *files
            @rebuildFileList()
    }

    {
        'name': 'About'
        'internal': 'about'
        'func': (sheet) =>
            title = @Label('PPM/2')
            title\SetFont('PPM2.Title')
            title\SizeToContents()
            @URLLabel('PPM/2 is a Ponyscape project', 'http://steamcommunity.com/groups/Ponyscape')\SetFont('PPM2.AboutLabels')
            @URLLabel('PPM/2 was created and being developed by DBot', 'https://steamcommunity.com/profiles/76561198077439269')\SetFont('PPM2.AboutLabels')
            @URLLabel('New models was created by Durpy', 'https://steamcommunity.com/profiles/76561198013875404')\SetFont('PPM2.AboutLabels')
            @URLLabel('CPPM Models (including pony hands) belong to UnkN', 'http://steamcommunity.com/profiles/76561198084938735')\SetFont('PPM2.AboutLabels')
            @URLLabel('Old models belong to Scentus and others', 'https://github.com/ChristinaTech/PonyPlayerModels')\SetFont('PPM2.AboutLabels')
            @URLLabel('Found a bug? Report here!', 'https://git.dbot.serealia.ca/Ponyscape-open/PPM2/issues')\SetFont('PPM2.AboutLabels')
            @URLLabel("Bugs don't like to be forgotten", 'https://dbot.serealia.ca/sharex/2017/05/07465b74f6ee60dbba3e0253114db552.jpg')\SetFont('PPM2.AboutLabels')
            @URLLabel('You can find sources here', 'https://git.dbot.serealia.ca/Ponyscape-open/PPM2')\SetFont('PPM2.AboutLabels')
            @URLLabel('Or on GitHub mirror', 'https://github.com/roboderpy/PPM2')\SetFont('PPM2.AboutLabels')
            @Label('Special thanks to everypony who criticized,\nhelped and tested PPM/2!')\SetFont('PPM2.AboutLabels')
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

createTopButtons = (createModelSelect = true) =>
    W, H = @GetSize()
    saveAs = (callback = (->)) ->
        confirm = (txt = '') ->
            txt = txt\Trim()
            return if txt == ''
            copy\SetFilename(txt)
            copy\Save()
            @unsavedChanges = false
            @model.unsavedChanges = false
            @SetTitle("#{copy\GetFilename() or '%ERRNAME%'} - PPM2 Pony Editor")
            @panels.saves.rebuildFileList()
            callback(txt)
        Derma_StringRequest('Save as', 'Enter file name without ppm2/ and .txt\nTip: to save as autoload, type "_current" (without ")', copy\GetFilename(), confirm)
    
    @saveButton = vgui.Create('DButton', @)
    with @saveButton
        \SetText('Save')
        \SetPos(W - 205, 5)
        \SetSize(90, 20)
        .DoClick = -> saveAs()
    
    @wearButton = vgui.Create('DButton', @)
    with @wearButton
        \SetText('Apply changes (wear)')
        \SetPos(W - 350, 5)
        \SetSize(140, 20)
        lastWear = 0
        .DoClick = ->
            return if RealTime() < lastWear
            lastWear = RealTime() + 5
            mainData = PPM2.GetMainData()
            nwdata = LocalPlayer()\GetPonyData()
            if nwdata
                mainData\SetNetworkData(nwdata)
                if nwdata.netID == -1
                    nwdata.NETWORKED = false
                    nwdata\Create()
            copy\ApplyDataToObject(mainData, false) -- no save on apply
    
    if createModelSelect
        @selectModelBox = vgui.Create('DComboBox', @)
        with @selectModelBox
            \SetSize(120, 20)
            \SetPos(W - 475, 5)
            \SetValue(editorModelSelect)
            \AddChoice(choice) for choice in *{'default', 'cppm', 'new'}
            .OnSelect = (pnl = box, index = 1, value = '', data = value) ->
                @SetDeleteOnClose(true)
                RunConsoleCommand('ppm2_editor_model', value)

                confirm = ->
                    @Close()
                    timer.Simple 0.1, PPM2.OpenEditor
                Derma_Query(
                    'You should restart editor for applying change.\nRestart now?\nUnsaved data will lost!',
                    'Editor restart required',
                    'Yas!',
                    confirm,
                    'Noh!'
                )
    
    @enableAdvanced = vgui.Create('DCheckBoxLabel', @)
    with @enableAdvanced
        \SetSize(120, 20)
        \SetPos(W - 590, 7)
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
                'You should restart editor for applying change.\nRestart now?\nUnsaved data will lost!',
                'Editor restart required',
                'Yas!',
                confirm,
                'Noh!'
            )

    @fullbrightSwitch = vgui.Create('DCheckBoxLabel', @)
    with @fullbrightSwitch
        \SetSize(120, 20)
        \SetPos(W - 670, 7)
        \SetConVar('ppm2_editor_fullbright')
        \SetText('Fullbright')

PPM2.OpenNewEditor = ->
    if IsValid(PPM2.EditorTopFrame)
        PPM2.EditorTopFrame\SetVisible(true)
        PPM2.EditorTopFrame.data\ApplyDataToObject(PPM2.EditorTopFrame.controller, false)
        PPM2.EditorTopFrame.leftPanel\SetVisible(true)
        return
    
    PPM2.EditorTopFrame = vgui.Create('EditablePanel')
    self = PPM2.EditorTopFrame
    topframe = PPM2.EditorTopFrame
    @SetPos(0, 0)
    @MakePopup()
    topSize = 55
    @SetSize(ScrW(), topSize)
    sysTime = SysTime()

    @btnClose = vgui.Create('DButton', @)
	@btnClose\SetText('')
	@btnClose.DoClick = -> @Close()
	@btnClose.Paint = (w = 0, h = 0) => derma.SkinHook('Paint', 'WindowCloseButton', @, w, h)
    @btnClose\SetSize(31, 31)
    @btnClose\SetPos(ScrW() - 40, 0)

    @Paint = (w = 0, h = 0) => derma.SkinHook('Paint', 'Frame', @, w, h)
    @DockPadding(5, 29, 5, 5)
    createTopButtons(@, false)

    @lblTitle = vgui.Create('DLabel', @)
    @lblTitle\SetPos(5, 0)
    @lblTitle\SetSize(200, 20)
    @SetTitle = (text = '') => @lblTitle\SetText(text)
    @GetTitle = => @lblTitle\GetText()

    @Close = =>
        data = PPM2.GetMainData()
        data\ApplyDataToObject(@controller, false)
        @SetVisible(false)
        @leftPanel\SetVisible(false)

    @leftPanel = vgui.Create('EditablePanel')
    @leftPanel\SetPos(0, topSize)
    @leftPanel\SetSize(350, ScrH() - topSize)
    @leftPanel\SetMouseInputEnabled(true)
    @leftPanel\SetKeyboardInputEnabled(true)

    @menus = vgui.Create('DPropertySheet', @leftPanel)
    @menus\Dock(FILL)
    @menus\SetSize(PANEL_WIDTH\GetInt(), 0)
    @menusBar = @menus.tabScroller
    @menusBar\SetParent(@)
    @menusBar\Dock(FILL)
    @menusBar\SetSize(0, 20)

    copy = PPM2.GetMainData()\Copy()
    ply = LocalPlayer()
    @controller = ply\GetPonyData()
    copy\SetNetworkData(@controller)
    copy\SetNetworkOnChange(false)
    @data = copy
    @DoUpdate = -> pnl\DoUpdate() for i, pnl in pairs @panels

    @SetTitle("#{copy\GetFilename() or '%ERRNAME%'} - PPM2 Pony Editor")

    @panels = {}

    createdPanels = 9

    for {:name, :func, :internal, :display} in *EditorPages
        continue if display and not display()
        pnl = vgui.Create('PPM2SettingsBase', @menus)
        @menus\AddSheet(name, pnl)
        pnl\SetTargetData(copy)
        pnl\Dock(FILL)
        pnl.frame = @
        func(pnl, @menus)
        createdPanels += pnl.createdPanels
        @panels[internal] = pnl
    
    iTime = math.floor((SysTime() - sysTime) * 1000)
    PPM2.Message('Initialized Pony editor in ', iTime, ' milliseconds (created nearly ', createdPanels, ' panels). Look how slow your PC is xd')

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
    frame = vgui.Create('DFrame')
    self = frame
    W, H = ScrW() - 25, ScrH() - 25
    @SetSize(W, H)
    @Center()
    @MakePopup()
    @SetTitle('PPM2 Pony Editor')
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

    createTopButtons(@)
    
    @SetTitle("#{copy\GetFilename() or '%ERRNAME%'} - PPM2 Pony Editor")

    @model\SetController(controller)
    controller\SetupEntity(ent)
    controller\SetDisableTask(true)

    @panels = {}

    createdPanels = 17

    for {:name, :func, :internal, :display} in *EditorPages
        continue if display and not display()
        pnl = vgui.Create('PPM2SettingsBase', @menus)
        @menus\AddSheet(name, pnl)
        pnl\SetTargetData(copy)
        pnl\Dock(FILL)
        pnl.frame = @
        func(pnl, @menus)
        createdPanels += pnl.createdPanels
        @panels[internal] = pnl
    
    iTime = math.floor((SysTime() - sysTime) * 1000)
    PPM2.Message('Initialized Pony editor in ', iTime, ' milliseconds (created nearly ', createdPanels, ' panels). Look how slow your PC is xd')

PPM2.OpenEditor = ->
    if LocalPlayer()\IsPony()
        PPM2.OpenNewEditor()
    else
        PPM2.OpenOldEditor()

concommand.Add 'ppm2_editor', PPM2.OpenEditor
concommand.Add 'ppm2_new_editor', PPM2.OpenNewEditor
concommand.Add 'ppm2_old_editor', PPM2.OpenOldEditor
concommand.Add 'ppm2_old_editor_reload', -> PPM2.OldEditorFrame\Remove() if IsValid(PPM2.OldEditorFrame)

IconData =
	title: 'PPM/2 Editor',
	icon: 'gui/pped_icon.png',
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
    @Button 'Spawn new model', 'gm_spawn', 'models/ppm/player_default_base_new.mdl'
    @Button 'Spawn new nj model', 'gm_spawn', 'models/ppm/player_default_base_new_nj.mdl'
    @Button 'Spawn old model', 'gm_spawn', 'models/ppm/player_default_base.mdl'
    @Button 'Spawn old nj model', 'gm_spawn', 'models/ppm/player_default_base_nj.mdl'
    @Button 'Spawn CPPM model', 'gm_spawn', 'models/cppm/player_default_base.mdl'
    @Button 'Spawn CPPM nj model', 'gm_spawn', 'models/cppm/player_default_base_nj.mdl'
    @Button 'Cleanup unused models', 'ppm2_cleanup'
    @Button 'Reload local data', 'ppm2_reload'
    @Button 'Require data from server', 'ppm2_require'
    @CheckBox 'Alternative render', 'ppm2_alternative_render'
    @CheckBox 'No hoofsounds', 'ppm2_cl_no_hoofsound'
    @CheckBox 'Disable flexes (emotes)', 'ppm2_disable_flexes'
    @CheckBox 'Enable PPM2 editor advanced mode', 'ppm2_editor_advanced'
    @CheckBox 'Enable PPM2 editor advanced mode', 'ppm2_editor_advanced'
