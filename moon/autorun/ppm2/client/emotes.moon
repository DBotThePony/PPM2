
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

PPM2.EmotesPanel\Remove() if IsValid(PPM2.EmotesPanel)

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

hook.Add 'StartChat', 'PPM2.Emotes', ->
    if not IsValid(PPM2.EmotesPanel)
        PPM2.EmotesPanel = vgui.Create('EditablePanel')
        self = PPM2.EmotesPanel
        @SetSize(100, 200)
        @SetPos(ScrW() - 100, ScrH() / 2 - 100)
        @Paint = (w = 0, h = 0) =>
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
        @scroll = vgui.Create('DScrollPanel', @)
        with @scroll
            \Dock(FILL)
            .Paint = ->
        @buttons = for {:name, :id, :sequence, :time} in *PPM2.AVALIABLE_EMOTES
            with vgui.Create('DButton', @scroll)
                \SetTextColor(BUTTON_TEXT_COLOR)
                .Paint = BUTTON_DRAW_FUNC
                .id = id
                .time = time
                .sequence = sequence
                \SetSize(200, 30)
                \SetText(name)
                .hoverDelta = 0
                \Dock(TOP)
                .DoClick = BUTTON_CLICK_FUNC
        @SetVisible(false)
        @SetMouseInputEnabled(false)

    if IsValid(PPM2.EmotesPanel) and LocalPlayer()\IsPony()
        PPM2.EmotesPanel\SetVisible(true)
        PPM2.EmotesPanel\SetMouseInputEnabled(true)
hook.Add 'FinishChat', 'PPM2.Emotes', ->
    if IsValid(PPM2.EmotesPanel)
        PPM2.EmotesPanel\KillFocus()
        PPM2.EmotesPanel\SetVisible(false)
        PPM2.EmotesPanel\SetMouseInputEnabled(false)