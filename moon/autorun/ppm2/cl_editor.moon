
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

        @animButton = vgui.Create('DButton', @)
        with @animButton
            \SetSize(120, 20)
            \SetText('Playing animation')
            .LastStatus = true
            .Think = ->
                if .LastStatus ~= @playing
                    .LastStatus = @playing
                    \SetText('Playing Animation') if @playing
                    \SetText('Play Animation') if not @playing
            .DoClick = ->
                @playing = not @playing
                if @playing
                    @editorSeq = 1
                    @nextSeq = RealTime() + @EDITOR_SEQUENCES[@editorSeq].time
                    @ResetPosition()

        @seqButton = vgui.Create('DComboBox', @)
        with @seqButton
            \SetSize(120, 20)
            \SetValue('Standing')
            SEQUENCES
            \AddChoice(choice, num) for choice, num in pairs @SEQUENCES
            .OnSelect = (pnl = box, index = 1, value = '', data = value) ->
                @SetSequence(data)
    ResetPosition: =>
        @targetAngle = Angle(0, 0, 0)
        @targetDistToPony = 100
        @vectorPos = Vector(@distToPony, 0, @PONY_VEC_Z)
    
    PerformLayout: (w = 0, h = 0) =>
        @animButton\SetPos(w - 130, 10)
        @seqButton\SetPos(10, 10)
    
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
        
        if @playing
            cseq = @EDITOR_SEQUENCES[@editorSeq]
            if @nextSeq < rtime
                @editorSeq += 1
                @editorSeq = 1 if not @EDITOR_SEQUENCES[@editorSeq]
                cseq = @EDITOR_SEQUENCES[@editorSeq]
                @nextSeq = rtime + cseq.time
            
            {:p, :y, :r} = @targetAngle
            @targetDistToPony, @targetAngle = cseq.func(@targetDistToPony, Angle(p, y, r), delta)
            @targetDistToPony = math.Clamp(@targetDistToPony, 20, 150)
            @targetAngle.p = math.Clamp(@targetAngle.p, -40, 10)
        else
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
    
    FLOOR_VECTOR: Vector(0, 0, 20)
    FLOOR_ANGLE: Vector(0, 0, 1)

    DRAW_WALLS: {
        {Vector(-4000, 0, 750), Vector(1, 0, 0), 8000, 1600}
        {Vector(4000, 0, 750), Vector(-1, 0, 0), 8000, 1600}
        {Vector(0, -4000, 750), Vector(0, 1, 0), 8000, 1600}
        {Vector(0, 4000, 750), Vector(0, -1, 0), 8000, 1600}
        {Vector(0, 0, 750), Vector(0, 0, -1), 8000, 8000}
    }

    WALL_COLOR: Color(98, 189, 176)
    FLOOR_COLOR: Color(53, 150, 84)

    Paint: (w = 0, h = 0) =>
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
        return if not IsValid(@model)
        x, y = @LocalToScreen(0, 0)
        cam.Start3D(@vectorPos, @drawAngle, 90, x, y, w, h)

        render.DrawQuadEasy(@FLOOR_VECTOR, @FLOOR_ANGLE, 4000, 4000, @FLOOR_COLOR)

        for {pos, ang, w, h} in *@DRAW_WALLS
            render.DrawQuadEasy(pos, ang, w, h, @WALL_COLOR)

        @controller\GetRenderController()\PreDraw(@model) if @controller
        @model\DrawModel()
        @controller\GetRenderController()\PostDraw(@model) if @controller

        cam.End3D()
}

vgui.Register('PPM2ModelPanel', MODEL_BOX_PANEL, 'EditablePanel')

PANEL_SETTINGS_BASE = {
    Init: =>
        @shouldSaveData = false
        @SetMouseInputEnabled(true)
        @SetKeyboardInputEnabled(true)
        @DockPadding(5, 5, 5, 5)
        @unsavedChanges = false
        @updateFuncs = {}
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
    NumSlider: (name = 'Slider', option = '', decimals = 0) =>
		with vgui.Create('DNumSlider', @scroll or @)
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
            @scroll\AddItem(_with_0) if IsValid(@scroll)
    Label: (text = '') =>
        with vgui.Create('DLabel', @scroll or @)
            \SetText(text)
            \Dock(TOP)
            \SetTextColor(color_white)
            \SizeToContents()
            w, h = \GetSize()
            \SetSize(w, h + 5)
            @scroll\AddItem(_with_0) if IsValid(@scroll)
	CheckBox: (name = 'Label', option = '') =>
		with vgui.Create('DCheckBoxLabel', @scroll or @)
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
            @scroll\AddItem(_with_0) if IsValid(@scroll)
    ColorBox: (name = 'Colorful Box', option = '') =>
        collapse = vgui.Create('DCollapsibleCategory', @scroll or @)
        box = vgui.Create('DColorMixer', collapse)
        collapse.box = box
        with box
            \SetSize(250, 250)
			\SetTooltip("#{name}\nData value: #{option}")
            \SetColor(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
            .ValueChanged = (pnl, newVal = Color(0, 0, 0)) ->
                return if option == ''
                data = @GetTargetData()
                return if not data
                data["Set#{option}"](data, newVal, @GetShouldSaveData())
                @ValueChanges(option, newVal, pnl)
            table.insert @updateFuncs, ->
                \SetColor(@GetTargetData()["Get#{option}"](@GetTargetData())) if @GetTargetData()
        with collapse
            \SetContents(box)
            \Dock(TOP)
            \DockMargin(2, 2, 2, 2)
            \SetSize(250, 250)
            \SetLabel(name)
            \SetExpanded(false)
        @scroll\AddItem(collapse) if IsValid(@scroll)
        return box, collapse
    ComboBox: (name = 'Combo Box', option = '', choices) =>
        label = vgui.Create('DLabel', @scroll or @)
        with label
            \SetText(name)
            \SetTextColor(color_white)
            \Dock(TOP)
            \SetSize(0, 20)
            \DockMargin(5, 0, 5, 0)
            \SetMouseInputEnabled(true)
        @scroll\AddItem(label) if IsValid(@scroll)
        box = vgui.Create('DComboBox', label)
        with box
            \Dock(RIGHT)
            \SetSize(170, 0)
            \DockMargin(0, 0, 5, 0)
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
    ScrollPanel: =>
        return @scroll if IsValid(@scroll)
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
            @CheckBox('Gender', 'Gender')
            @ComboBox('Race', 'Race')
            @NumSlider('Weight', 'Weight', 2)
            @CheckBox('Socks', 'Socks')
            @ComboBox('Eyelashes', 'EyelashType')
            @ComboBox('Bodysuit', 'Bodysuit')
            @ColorBox('Body color', 'BodyColor')
    }

    {
        'name': 'Eyes'
        'internal': 'eyes'
        'func': (sheet) =>
            @ScrollPanel()
            @CheckBox('Use separated settings for eyes', 'SeparateEyes')
            for publicName in *{'', 'Left', 'Right'}
                @Label("'#{publicName}' Eye settings")
                @CheckBox("#{publicName} Eye lines", "EyeLines#{publicName}")
                @CheckBox("#{publicName} Derp eye", "DerpEyes#{publicName}")
                @NumSlider("#{publicName} Derp eye strength", "DerpEyesStrength#{publicName}", 2)
                @NumSlider("#{publicName} Eye size", "IrisSize#{publicName}", 2)
                @NumSlider("#{publicName} Eye hole width", "HoleWidth#{publicName}", 2)
                @NumSlider("#{publicName} Eye hole size", "HoleSize#{publicName}", 2)

                @ColorBox("#{publicName} Eye background", "EyeBackground#{publicName}")
                @ColorBox("#{publicName} Eye hole", "EyeHole#{publicName}")
                @ColorBox("#{publicName} Top eye iris", "EyeIrisTop#{publicName}")
                @ColorBox("#{publicName} Bottom eye iris", "EyeIrisBottom#{publicName}")
                @ColorBox("#{publicName} Eye line 1", "EyeIrisLine1#{publicName}")
                @ColorBox("#{publicName} Eye line 2", "EyeIrisLine2#{publicName}")
                @ColorBox("#{publicName} Eye line 2", "EyeIrisLine2#{publicName}")
    }

    {
        'name': 'Mane and tail'
        'internal': 'manetail'
        'func': (sheet) =>
            @ScrollPanel()
            @Label('"New" types affect only new model')
            @ComboBox('Tail type', 'TailType')
            @ComboBox('New Tail type', 'TailTypeNew')
            
            @ComboBox('Mane type', 'ManeType')
            @ComboBox('New Mane type', 'ManeTypeNew')
            
            @ComboBox('Lower Mane type', 'ManeTypeLower')
            @ComboBox('New Lower Mane type', 'ManeTypeLowerNew')

            for i = 1, 2
                @ColorBox("Mane color #{i}", "ManeColor#{i}")
                @ColorBox("Tail color #{i}", "TailColor#{i}")
            for i = 1, 6
                @ColorBox("Mane detail color #{i}", "ManeColor#{i}")
                @ColorBox("Tail detail color #{i}", "TailDetailColor#{i}")
    }

    {
        'name': 'Body details'
        'internal': 'bodydetail'
        'func': (sheet) =>
            for i = 1, PPM2.MAX_BODY_DETAILS
                @ComboBox("Detail #{i}", "BodyDetail#{i}")
                @ColorBox("Detail color #{i}", "BodyDetailColor#{i}")
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
                    surface.SetDrawColor(0, 0, 0)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, w, h)
            
            @Label('Cutiemark URL image input field\nShould be PNG or JPEG (works same as\nPAC3 URL texture)')\DockMargin(5, 10, 5, 10)
            @textInput = vgui.Create('DTextEntry', @)
            with @textInput
                \Dock(TOP)
                \DockMargin(5, 10, 5, 10)
                \SetText(@GetTargetData()\GetCMarkURL())
                .OnEnter = ->
                    text = \GetValue()
                    if text\find('^https?://')
                        @GetTargetData()\SetCMarkURL(text)
                        @ValueChanges('CMarkURL', text, @textInput)
                    else
                        @GetTargetData()\SetCMarkURL('')
                        @ValueChanges('CMarkURL', '', @textInput)
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
                    timer.Create 'PPM2.EditorCodeChange', 1, 1, ->
                        return if not IsValid(@textInput)
                        .OnEnter()
                table.insert @updateFuncs, ->
                    \SetText(@GetTargetData()\GetCMarkURL())
    }

    {
        'name': 'Files'
        'internal': 'saves'
        'func': (sheet) =>
            @Label('Open file by double click')
            list = vgui.Create('DListView', @)
            list\Dock(FILL)
            list\SetMultiSelect(false)
            list.DoDoubleClick = (pnl, rowID, line) ->
                fil = line\GetColumnText(1)
                if @unsavedChanges
                    confirm = ->
                        @frame.data\SetFilename(fil)
                        @frame.data\ReadFromDisk(true)
                        @frame.data\UpdateController()
                        @frame.DoUpdate()
                        @unsavedChanges = false
                        @frame.unsavedChanges = false
                        @frame\SetTitle("#{fil} - PPM2 Pony Editor")
                    Derma_Query(
                        "Currently, you did not stated your changes.\nDo you really want to open #{fil}?",
                        'Unsaved changes!',
                        'Yas!',
                        confirm,
                        'Noh!'
                    )
                else
                    @frame.data\SetFilename(fil)
                    @frame.data\ReadFromDisk(true)
                    @frame.data\UpdateController()
                    @frame.DoUpdate()
                    @unsavedChanges = false
                    @frame.unsavedChanges = false
                    @frame\SetTitle("#{fil} - PPM2 Pony Editor")
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
}

EditorModels = {
    'DEFAULT': 'models/ppm/player_default_base.mdl'
    'CPPM': 'models/cppm/player_default_base.mdl'
    'NEW': 'models/ppm/player_default_base_new.mdl'
}

USE_MODEL = CreateConVar('ppm2_editor_model', 'new', {FCVAR_ARCHIVE}, 'What model to use in editor. Valids are "default", "cppm", "new"')

PPM2.EditorFrame\Remove() if IsValid(PPM2.EditorFrame)
PPM2.OpenEditor = ->
    if IsValid(PPM2.EditorFrame)
        PPM2.EditorFrame\SetVisible(true)
        PPM2.EditorFrame\Center()
        PPM2.EditorFrame\MakePopup()
        return
    
    frame = vgui.Create('DFrame')
    self = frame
    W, H = ScrW() - 25, ScrH() - 25
    @SetSize(W, H)
    @Center()
    @MakePopup()
    @SetTitle('PPM2 Pony Editor')
    @SetDeleteOnClose(false)
    PPM2.EditorFrame = @

    @menus = vgui.Create('DPropertySheet', @)
    @menus\Dock(LEFT)
    @menus\SetSize(370, 0)

    @model = vgui.Create('PPM2ModelPanel', @)
    @model\Dock(FILL)

    copy = PPM2.GetMainData()\Copy()
    ply = LocalPlayer()
    editorModelSelect = USE_MODEL\GetString()\upper()
    editorModelSelect = EditorModels[editorModelSelect] and editorModelSelect or 'DEFAULT'
    ent = @model\ResetModel(nil, EditorModels[editorModelSelect])
    controller = copy\CreateCustomController(ent)
    copy\SetController(controller)
    frame.controller = controller
    frame.data = copy
    frame.DoUpdate = -> pnl\DoUpdate() for i, pnl in pairs @panels

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
        Derma_StringRequest('Save as', 'Enter file name without ppm2/ and .txt', copy\GetFilename(), confirm)
    
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
            copy\ApplyDataToObject(mainData, false) -- no save on apply
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
                'You should restart editor for applying change.\nRestart now?\nUnsaved data can be lost!',
                'Editor restart required',
                'Yas!',
                confirm,
                'Noh!'
            )

    @SetTitle("#{copy\GetFilename() or '%ERRNAME%'} - PPM2 Pony Editor")

    @model\SetController(controller)
    controller\SetupEntity(ent)

    @panels = {}

    for {:name, :func, :internal} in *EditorPages
        pnl = vgui.Create('PPM2SettingsBase', @menus)
        @menus\AddSheet(name, pnl)
        pnl\SetTargetData(copy)
        pnl\Dock(FILL)
        pnl.frame = @
        func(pnl, @menus)
        @panels[internal] = pnl

concommand.Add 'ppm2_editor', PPM2.OpenEditor

IconData =
	title: 'PPM V2.0',
	icon: 'gui/pped_icon.png',
	width: 960,
	height: 700,
	onewindow: true,
	init: (icon, window) ->
		window\Remove()
		RunConsoleCommand('ppm2_editor')

list.Set('DesktopWindows', 'PPM2', IconData)
CreateContextMenu() if IsValid(g_ContextMenu)
