
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

net.Receive 'PPM2.DamageAnimation', ->
    ent = net.ReadEntity()
    return if not IsValid(ent) or not ent\IsPlayer()
    hook.Call('PPM2_HurtAnimation', nil, ent)

net.Receive 'PPM2.KillAnimation', ->
    ent = net.ReadEntity()
    return if not IsValid(ent) or not ent\IsPlayer()
    hook.Call('PPM2_KillAnimation', nil, ent)

net.Receive 'PPM2.AngerAnimation', ->
    ent = net.ReadEntity()
    return if not IsValid(ent) or not ent\IsPlayer()
    hook.Call('PPM2_AngerAnimation', nil, ent)

net.Receive 'PPM2.PlayEmote', ->
    emoteID = net.ReadUInt(8)
    ply = net.ReadEntity()
    return if not IsValid(ply) or not ply\IsPlayer()
    return if not PPM2.AVALIABLE_EMOTES[emoteID]
    hook.Call('PPM2_EmoteAnimation', nil, ply, PPM2.AVALIABLE_EMOTES[emoteID].sequence, PPM2.AVALIABLE_EMOTES[emoteID].time)

PPM2.EmotesPanelContext\Remove() if IsValid(PPM2.EmotesPanelContext)
PPM2.EmotesPanel\Remove() if IsValid(PPM2.EmotesPanel)

CONSOLE_EMOTES_COMMAND = (ply = LocalPlayer(), cmd = '', args = {}) ->
    args[1] = args[1] or ''
    emoteID = tonumber(args[1])

    if emoteID
        if not PPM2.AVALIABLE_EMOTES[emoteID]
            PPM2.Message('No such emotion with ID: ', emoteID)
            return
        net.Start('PPM2.PlayEmote')
        net.WriteUInt(emoteID, 8)
        net.SendToServer()
        hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), PPM2.AVALIABLE_EMOTES[emoteID].sequence, PPM2.AVALIABLE_EMOTES[emoteID].time)
    else
        emoteID = args[1]\lower()
        if not PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID]
            PPM2.Message('No such emotion with ID: ', emoteID)
            return
        net.Start('PPM2.PlayEmote')
        net.WriteUInt(PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID].id, 8)
        net.SendToServer()
        hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), emoteID, PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID].time)

CONSOLE_DEF_LIST = ['ppm2_emote "' .. sequence .. '"' for {:sequence} in *PPM2.AVALIABLE_EMOTES]
CONSOLE_EMOTES_AUTOCOMPLETE = (cmd = '', args = '') ->
    args = args\Trim()
    return CONSOLE_DEF_LIST if args == ''
    output = {}
    for {:sequence} in *PPM2.AVALIABLE_EMOTES
        if string.find(sequence, '^' .. args)
            table.insert(output, 'ppm2_emote "' .. sequence .. '"')
    return output

concommand.Add 'ppm2_emote', CONSOLE_EMOTES_COMMAND, CONSOLE_EMOTES_AUTOCOMPLETE

BUTTON_DRAW_FUNC = (w = 0, h = 0) =>
    @hoverDelta = math.Clamp(@hoverDelta + (@IsHovered() and FrameTime() or -FrameTime()) * 5, 0, 1)
    col = @hoverDelta * 150
    col = 200 if @IsDown()
    surface.SetDrawColor(col, col, col, 150)
    surface.DrawRect(0, 0, w, h)

BUTTON_CLICK_FUNC = =>
    net.Start('PPM2.PlayEmote')
    net.WriteUInt(@id, 8)
    net.SendToServer()
    hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), @sequence, @time)

BUTTON_TEXT_COLOR = Color(255, 255, 255)

IMAGE_PANEL_THINK = =>
    @lastThink = RealTime() + .4
    if @IsHovered()
        if not @oldHover
            @oldHover = true
            @hoverPnl\SetVisible(true)
            x, y = @LocalToScreen(0, 0)
            @hoverPnl\SetPos(x - 256, y - 224)
    else
        if @oldHover
            @oldHover = false
            @hoverPnl\SetVisible(false)
HOVERED_IMAGE_PANEL_THINK = =>
    if not @parent\IsValid()
        @Remove()
        return
    if @parent.lastThink < RealTime()
        @SetVisible(false)
CreatePanel = (parent) ->
    self = vgui.Create('DPanel', parent)
    @SetSize(200, 300)
    @Paint = (w = 0, h = 0) =>
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
    @scroll = vgui.Create('DScrollPanel', @)
    with @scroll
        \Dock(FILL)
        \SetSize(200, 300)
        .Paint = ->
        \SetMouseInputEnabled(true)
    @buttons = for {:name, :id, :sequence, :time, :fexists, :filecrop} in *PPM2.AVALIABLE_EMOTES
        btn = vgui.Create('DButton', @scroll)
        with btn
            \SetTextColor(BUTTON_TEXT_COLOR)
            .Paint = BUTTON_DRAW_FUNC
            .id = id
            .time = time
            .sequence = sequence
            .hoverDelta = 0
            .DoClick = BUTTON_CLICK_FUNC
            \SetSize(200, 32)
            \SetText(name)
            \SetFont('HudHintTextLarge')
            \Dock(TOP)
            if fexists
                image = vgui.Create('DImage', btn)
                with image
                    \Dock(LEFT)
                    \SetSize(32, 32)
                    \SetImage(filecrop)
                    \SetMouseInputEnabled(true)
                    .hoverPnl = vgui.Create('DImage')
                    .Think = IMAGE_PANEL_THINK
                    .oldHover = false
                    with .hoverPnl
                        \SetMouseInputEnabled(false)
                        \SetVisible(false)
                        \SetImage(filecrop)
                        \SetSize(256, 256)
                        .Think = HOVERED_IMAGE_PANEL_THINK
                        .parent = image
                    .OnRemove = -> .hoverPnl\Remove() if IsValid(.hoverPnl)
        btn
    @scroll\AddItem(btn) for btn in *@buttons
    @SetVisible(false)
    @SetMouseInputEnabled(false)
    return @

hook.Add 'ContextMenuCreated', 'PPM2.Emotes', =>
    PPM2.EmotesPanelContext\Remove() if IsValid(PPM2.EmotesPanelContext)
    PPM2.EmotesPanelContext = CreatePanel(@)
    PPM2.EmotesPanelContext\SetPos(ScrW() / 2 - 100, ScrH() - 300)
    PPM2.EmotesPanelContext\SetVisible(true)
    PPM2.EmotesPanelContext\SetMouseInputEnabled(true)
    timer.Create 'PPM2.ContextMenuEmotesUpdate', 1, 0, ->
        if not IsValid(PPM2.EmotesPanelContext)
            timer.Remove 'PPM2.ContextMenuEmotesUpdate'
            return
        return if not IsValid(LocalPlayer())
        status = LocalPlayer()\IsPony()
        PPM2.EmotesPanelContext\SetVisible(status)
        PPM2.EmotesPanelContext\SetMouseInputEnabled(status)

hook.Add 'StartChat', 'PPM2.Emotes', ->
    if not IsValid(PPM2.EmotesPanel)
        PPM2.EmotesPanel = CreatePanel()
        PPM2.EmotesPanel\SetPos(ScrW() - 500, ScrH() - 300)

    if IsValid(PPM2.EmotesPanel) and LocalPlayer()\IsPony()
        PPM2.EmotesPanel\SetVisible(true)
        PPM2.EmotesPanel\SetMouseInputEnabled(true)
        PPM2.EmotesPanel\RequestFocus()
hook.Add 'FinishChat', 'PPM2.Emotes', ->
    if IsValid(PPM2.EmotesPanel)
        PPM2.EmotesPanel\KillFocus()
        PPM2.EmotesPanel\SetVisible(false)
        PPM2.EmotesPanel\SetMouseInputEnabled(false)