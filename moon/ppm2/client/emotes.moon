
--
-- Copyright (C) 2017-2020 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

net = DLib.net

ENABLE_EMOTES_IN_CHAT = CreateConVar('ppm2_cl_emotes_chat', '1', {FCVAR_ARCHIVE}, 'Show emotes list while chatbox is open')
ENABLE_EMOTES_IN_CONTEXT = CreateConVar('ppm2_cl_emotes_context', '1', {FCVAR_ARCHIVE}, 'Show emotes list while context menu is open')

net.Receive 'PPM2.DamageAnimation', ->
	ent = net.ReadEntity()
	return if not IsValid(ent) or not ent\GetPonyData()
	hook.Call('PPM2_HurtAnimation', nil, ent)

net.Receive 'PPM2.KillAnimation', ->
	ent = net.ReadEntity()
	return if not IsValid(ent) or not ent\GetPonyData()
	hook.Call('PPM2_KillAnimation', nil, ent)

net.Receive 'PPM2.AngerAnimation', ->
	ent = net.ReadEntity()
	return if not IsValid(ent) or not ent\GetPonyData()
	hook.Call('PPM2_AngerAnimation', nil, ent)

net.Receive 'PPM2.PlayEmote', ->
	emoteID = net.ReadUInt(8)
	ply = net.ReadEntity()
	isEndless = net.ReadBool()
	shouldStop = net.ReadBool()
	return if not IsValid(ply) or not ply\GetPonyData()
	return if not PPM2.AVALIABLE_EMOTES[emoteID]
	hook.Call('PPM2_EmoteAnimation', nil, ply, PPM2.AVALIABLE_EMOTES[emoteID].sequence, PPM2.AVALIABLE_EMOTES[emoteID].time, isEndless, shouldStop)

PPM2.EmotesPanelContext\Remove() if IsValid(PPM2.EmotesPanelContext)
PPM2.EmotesPanel\Remove() if IsValid(PPM2.EmotesPanel)

CONSOLE_EMOTES_COMMAND = (ply = LocalPlayer(), cmd = '', args = {}) ->
	args[1] = args[1] or ''
	emoteID = tonumber(args[1])
	isEndless = tobool(args[2])
	shouldStop = tobool(args[3])

	if emoteID
		if not PPM2.AVALIABLE_EMOTES[emoteID]
			PPM2.LMessage('message.ppm2.emotes.invalid', emoteID)
			return
		net.Start('PPM2.PlayEmote')
		net.WriteUInt(emoteID, 8)
		net.WriteBool(isEndless)
		net.WriteBool(shouldStop)
		net.SendToServer()
		hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), PPM2.AVALIABLE_EMOTES[emoteID].sequence, PPM2.AVALIABLE_EMOTES[emoteID].time)
	else
		emoteID = args[1]\lower()
		if not PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID]
			PPM2.LMessage('message.ppm2.emotes.invalid', emoteID)
			return
		net.Start('PPM2.PlayEmote')
		net.WriteUInt(PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID].id, 8)
		net.WriteBool(isEndless)
		net.WriteBool(shouldStop)
		net.SendToServer()
		hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), emoteID, PPM2.AVALIABLE_EMOTES_BY_SEQUENCE[emoteID].time)

CONSOLE_DEF_LIST = ['ppm2_emote "' .. sequence .. '"' for _, {:sequence} in ipairs PPM2.AVALIABLE_EMOTES]
CONSOLE_EMOTES_AUTOCOMPLETE = (cmd = '', args = '') ->
	args = args\Trim()
	return CONSOLE_DEF_LIST if args == ''
	output = {}
	for _, {:sequence} in ipairs PPM2.AVALIABLE_EMOTES
		if string.find(sequence, '^' .. args)
			table.insert(output, 'ppm2_emote "' .. sequence .. '"')
	return output

concommand.Add 'ppm2_emote', CONSOLE_EMOTES_COMMAND, CONSOLE_EMOTES_AUTOCOMPLETE

BUTTON_CLICK_FUNC = (isEndless = false, shouldStop = false) =>
	if @sendToServer
		net.Start('PPM2.PlayEmote')
		net.WriteUInt(@id, 8)
		net.WriteBool(isEndless)
		net.WriteBool(shouldStop)
		net.SendToServer()
		hook.Call('PPM2_EmoteAnimation', nil, LocalPlayer(), @sequence, @time, isEndless, shouldStop)
	else
		hook.Call('PPM2_EmoteAnimation', nil, @target, @sequence, @time, isEndless, shouldStop)

BUTTON_TEXT_COLOR = Color(255, 255, 255)

IMAGE_PANEL_THINK = =>
	@lastThink = RealTimeL() + .4
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
	if @parent.lastThink < RealTimeL()
		@SetVisible(false)

PPM2.CreateEmotesPanel = (parent, target = LocalPlayer(), sendToServer = true) ->
	self = vgui.Create('DPanel', parent)
	self\SetSkin('DLib_Black')
	@SetSize(200, 300)
	@Paint = (w = 0, h = 0) =>
		DLib.blur.DrawPanel(w, h, @LocalToScreen(0, 0)) if DLib.skin.ENABLE_BLUR\GetBool()
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)
	@scroll = vgui.Create('DScrollPanel', @)
	with @scroll
		\Dock(FILL)
		\SetSkin('DLib_Black')
		\SetSize(200, 300)
		.Paint = ->
		\SetMouseInputEnabled(true)
	@buttons = for _, {:name, :id, :sequence, :time, :fexists, :filecrop} in ipairs PPM2.AVALIABLE_EMOTES
		with btn = vgui.Create('DButton', @scroll)
			.id = id
			.time = time
			.sequence = sequence
			.sendToServer = sendToServer
			.target = target
			.DoClick = BUTTON_CLICK_FUNC
			\SetSize(200, 32)
			\SetText(name)
			\SetFont('HudHintTextLarge')
			\Dock(TOP)
			with .checkbox = \Add('DCheckBox')
				\Dock(RIGHT)
				\DockMargin(2, 8, 2, 8)
				\SetSize(16, 16)
				\SetChecked(false)
				.Think = ->
					if IsValid(target)
						if ponyData = target\GetPonyData()
							if renderController = ponyData\GetRenderController()
								if emotesController = renderController\CreateEmotesController()
									\SetChecked(emotesController\HasSequence(sequence) and emotesController\GetSequence(sequence)\GetInfinite())
				.OnChange = (checkbox3, newVal) ->
					return if .suppress
					BUTTON_CLICK_FUNC(btn, true) if newVal
					BUTTON_CLICK_FUNC(btn, false, true) if not newVal
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
	@scroll\AddItem(btn) for _, btn in ipairs @buttons
	@SetVisible(false)
	@SetMouseInputEnabled(false)
	return @

hook.Add 'ContextMenuCreated', 'PPM2.Emotes', =>
	return if not IsValid(@)
	return if not ENABLE_EMOTES_IN_CONTEXT\GetBool()
	PPM2.EmotesPanelContext\Remove() if IsValid(PPM2.EmotesPanelContext)
	PPM2.EmotesPanelContext = PPM2.CreateEmotesPanel(@)
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
	if not IsValid(PPM2.EmotesPanel) and ENABLE_EMOTES_IN_CHAT\GetBool()
		PPM2.EmotesPanel = PPM2.CreateEmotesPanel()
		PPM2.EmotesPanel\SetPos(ScrW() - 500, ScrH() - 300)

	if IsValid(PPM2.EmotesPanel)
		if LocalPlayer()\IsPony()
			PPM2.EmotesPanel\SetVisible(true)
			PPM2.EmotesPanel\SetMouseInputEnabled(true)
			PPM2.EmotesPanel\RequestFocus()
		else
			PPM2.EmotesPanel\SetVisible(false)
			PPM2.EmotesPanel\SetMouseInputEnabled(false)
			PPM2.EmotesPanel\KillFocus()

hook.Add 'FinishChat', 'PPM2.Emotes', ->
	if IsValid(PPM2.EmotesPanel)
		PPM2.EmotesPanel\KillFocus()
		PPM2.EmotesPanel\SetVisible(false)
		PPM2.EmotesPanel\SetMouseInputEnabled(false)
