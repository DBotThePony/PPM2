
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


class ExpressionSequence extends PPM2.SequenceBase
	new: (controller, data) =>
		super(controller, data)

		{
			'flexSequence': @flexSequence
			'bonesSequence': @bonesSequence
			'bones': @bonesNames
			'flexes': @flexNames
		} = data

		@knownBonesSequences = {}
		@controller = controller

		@flexStates = {}
		@bonesNames = @bonesNames or {}
		@bonesFuncsPos = ['SetModifier' .. boneName .. 'Position' for _, boneName in ipairs @bonesNames]
		@bonesFuncsScale = ['SetModifier' .. boneName .. 'Scale' for _, boneName in ipairs @bonesNames]
		@bonesFuncsAngles = ['SetModifier' .. boneName .. 'Angles' for _, boneName in ipairs @bonesNames]
		@ponydata = @controller.renderController\GetData()
		@ponydataID = @ponydata\GetModifierID(@name .. '_emote')
		@RestartChildren()
		@Launch()

	GetController: => @controller

	SetControllerModifier: (name = '', val) => @ponydata['SetModifier' .. name](@ponydata, @ponydataID, val)

	RestartChildren: =>
		if @flexSequence
			if flexController = @controller.renderController\GetFlexController()
				@flexController = flexController
				if type(@flexSequence) == 'table'
					for _, seq in ipairs @flexSequence
						flexController\StartSequence(seq, @time)\SetInfinite(@GetInfinite())
				else
					flexController\StartSequence(@flexSequence, @time)\SetInfinite(@GetInfinite())
				if @flexNames
					@flexStates = [{flexController\GetFlexState(flex), flexController\GetFlexState(flex)\GetModifierID(@name .. '_emote')} for _, flex in ipairs @flexNames]

		@knownBonesSequences = {}
		if bones = @GetEntity()\PPMBonesModifier()
			@bonesController = bones
			if @bonesSequence
				if type(@bonesSequence) == 'table'
					for _, seq in ipairs @bonesSequence
						bones\StartSequence(seq, @time)\SetInfinite(@GetInfinite())
						table.insert(@knownBonesSequences, seq)
				else
					bones\StartSequence(@bonesSequence, @time)\SetInfinite(@GetInfinite())
					table.insert(@knownBonesSequences, @bonesSequence)

				@bonesModifierID = bones\GetModifierID(@name .. '_emote')

	PlayBonesSequence: (name, time = @time) =>
		return PPM2.Message('Bones controller not found for sequence ', @, '! This is a bug. ', @controller) if not @bonesController
		table.insert(@knownBonesSequences, name)
		return @bonesController\StartSequence(name, time)

	Think: (delta = 0) =>
		return false if not IsValid(@GetEntity())
		super(delta)

	Stop: =>
		super()
		@ponydata\ResetModifiers(@name .. '_emote')
		if @flexController
			if @flexSequence
				if type(@flexSequence) == 'table'
					for _, id in ipairs @flexSequence
						@flexController\EndSequence(id)
				else
					@flexController\EndSequence(@flexSequence)
			flex\ResetModifiers(id) for _, {flex, id} in ipairs @flexStates
		if @bonesController
			for _, id in ipairs @knownBonesSequences
				@bonesController\EndSequence(id)

	SetBonePosition: (id = 1, val = Vector(0, 0, 0)) => @controller[@bonesFuncsPos[id]] and @controller[@bonesFuncsPos[id]](@controller, @bonesModifierID, val)
	SetBoneScale: (id = 1, val = 0) => @controller[@bonesFuncsScale[id]] and @controller[@bonesFuncsScale[id]](@controller, @bonesModifierID, val)
	SetBoneAngles: (id = 1, val = Angles(0, 0, 0)) => @controller[@bonesFuncsAngles[id]] and @controller[@bonesFuncsAngles[id]](@controller, @bonesModifierID, val)
	SetFlexWeight: (id = 1, val = 0) => @flexStates[id] and @flexStates[id][1](@flexStates[id][1], @flexStates[id][2], val)

PPM2.ExpressionSequence = ExpressionSequence

class PPM2.PonyExpressionsController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	@SEQUENCES = {
		{
			'name': 'sad'
			'flexSequence': {'sad'}
			'bonesSequence': {'floppy_ears'}
			'autostart': false
			'repeat': false
			'time': 5
			'reset': =>
			'func': (delta, timeOfAnim) =>
		}

		{
			'name': 'sorry'
			'flexSequence': 'sorry'
			'bonesSequence': {'floppy_ears'}
			'autostart': false
			'repeat': false
			'time': 8
		}

		{
			'name': 'scrunch'
			'flexSequence': 'scrunch'
			'autostart': false
			'repeat': false
			'time': 6
		}

		{
			'name': 'gulp'
			'flexSequence': 'gulp'
			'autostart': false
			'repeat': false
			'time': 2
		}

		{
			'name': 'blahblah'
			'flexSequence': 'blahblah'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'wink_left'
			'flexSequence': 'wink_left'
			'bonesSequence': 'forward_left'
			'autostart': false
			'repeat': false
			'time': 2
		}

		{
			'name': 'wink_right'
			'flexSequence': 'wink_right'
			'bonesSequence': 'forward_right'
			'autostart': false
			'repeat': false
			'time': 2
		}

		{
			'name': 'happy_eyes'
			'flexSequence': 'happy_eyes'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'happy_grin'
			'flexSequence': 'happy_grin'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'duck'
			'flexSequence': 'duck'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'duck_insanity'
			'flexSequence': 'duck_insanity'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'duck_quack'
			'flexSequence': 'duck_quack'
			'flexSequence': 'duck_quack'
			'autostart': false
			'repeat': false
			'time': 5
		}

		{
			'name': 'hurt'
			'flexSequence': 'hurt'
			'bonesSequence': 'floppy_ears_weak'
			'autostart': false
			'repeat': false
			'time': 4
			'reset': =>
				@SetControllerModifier('IrisSizeInternal', -0.3)
		}

		{
			'name': 'kill_grin'
			'flexSequence': 'kill_grin'
			'autostart': false
			'repeat': false
			'time': 8
		}

		{
			'name': 'greeny'
			'flexSequence': 'greeny'
			'autostart': false
			'repeat': false
			'time': 2
		}

		{
			'name': 'big_grin'
			'flexSequence': 'big_grin'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'o3o'
			'flexSequence': 'o3o'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'xd'
			'flexSequence': 'xd'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'tongue'
			'flexSequence': 'tongue'
			'autostart': false
			'repeat': false
			'time': 3
		}

		{
			'name': 'angry_tongue'
			'flexSequence': 'angry_tongue'
			'bonesSequence': 'forward_ears'
			'autostart': false
			'repeat': false
			'time': 6
		}

		{
			'name': 'pffff'
			'flexSequence': 'pffff'
			'bonesSequence': 'forward_ears'
			'autostart': false
			'repeat': false
			'time': 6
		}

		{
			'name': 'cat'
			'flexSequence': 'cat'
			'autostart': false
			'repeat': false
			'time': 5
		}

		{
			'name': 'talk'
			'flexSequence': 'talk'
			'autostart': false
			'repeat': false
			'time': 1.25
		}

		{
			'name': 'ooo'
			'flexSequence': 'ooo'
			'bonesSequence': 'neck_flopping_backward'
			'autostart': false
			'repeat': false
			'time': 2
		}

		{
			'name': 'anger'
			'flexSequence': 'anger'
			'bonesSequence': 'forward_ears'
			'autostart': false
			'repeat': false
			'time': 4
			'reset': =>
				@SetControllerModifier('IrisSizeInternal', -0.2)
		}

		{
			'name': 'ugh'
			'flexSequence': 'ugh'
			'autostart': false
			'repeat': false
			'time': 5
			'reset': =>
		}

		{
			'name': 'lips_licking'
			'flexSequence': 'lips_lick'
			'autostart': false
			'repeat': false
			'time': 5
			'reset': =>
		}

		{
			'name': 'lips_licking_suggestive'
			'bonesSequence': 'floppy_ears_weak'
			'flexSequence': {'lips_lick', 'face_smirk', 'suggestive_eyes'}
			'autostart': false
			'repeat': false
			'time': 4
			'reset': =>
		}

		{
			'name': 'suggestive_eyes'
			'flexSequence': {'suggestive_eyes'}
			'autostart': false
			'repeat': false
			'time': 4
			'reset': =>
		}

		{
			'name': 'suggestive'
			'bonesSequence': 'floppy_ears_weak'
			'flexSequence': {'suggestive_eyes', 'tongue_pullout', 'suggestive_open'}
			'autostart': false
			'repeat': false
			'time': 4
			'reset': =>
		}

		{
			'name': 'suggestive_wo'
			'bonesSequence': 'floppy_ears_weak'
			'flexSequence': {'suggestive_eyes', 'suggestive_open_anim'}
			'autostart': false
			'repeat': false
			'time': 4
			'reset': =>
		}

		{
			'name': 'wild'
			'bonesSequence': 'neck_backward'
			'autostart': false
			'repeat': false
			'time': 3
			'reset': =>
				@SetControllerModifier('IrisSizeInternal', -0.5)
				@PlayBonesSequence(math.random(1, 100) > 50 and 'neck_left' or 'neck_right')
		}

		{
			'name': 'owo_alternative'
			'flexSequence': 'owo_alternative'
			'autostart': false
			'repeat': false
			'time': 8
			'reset': => @SetControllerModifier('IrisSizeInternal', math.Rand(0.1, 0.3))
		}

		{
			'name': 'licking'
			'bonesSequence': 'neck_twitch_fast'
			'flexSequence': 'tongue_pullout_twitch_fast'
			'autostart': false
			'repeat': false
			'time': 6
		}
	}

	@SequenceObject = ExpressionSequence

	new: (controller) =>
		super(controller)
		@renderController = controller
		@Hook('PPM2_HurtAnimation', @PPM2_HurtAnimation)
		@Hook('PPM2_KillAnimation', @PPM2_KillAnimation)
		@Hook('PPM2_AngerAnimation', @PPM2_AngerAnimation)
		@Hook('PPM2_EmoteAnimation', @PPM2_EmoteAnimation)
		@Hook('OnPlayerChat', @OnPlayerChat)
		@ResetSequences()

	PPM2_HurtAnimation: (ply = NULL) =>
		return if ply ~= @GetEntity()
		@RestartSequence('hurt')
		@EndSequence('kill_grin')

	PPM2_KillAnimation: (ply = NULL) =>
		return if ply ~= @GetEntity()
		@RestartSequence('kill_grin')
		@EndSequence('anger')

	PPM2_AngerAnimation: (ply = NULL) =>
		return if ply ~= @GetEntity()
		@EndSequence('kill_grin')
		@RestartSequence('anger')

	OnPlayerChat: (ply = NULL, text = '', teamOnly = false, isDead = false) =>
		return if ply ~= @GetEntity() or teamOnly or isDead
		text = text\lower()
		switch text
			when 'o', ':o', 'о', 'О', ':о', ':О'
				@RestartSequence('ooo')
			when ':3', ':з'
				@RestartSequence('cat')
			when ':d'
				@RestartSequence('big_grin')
			when 'xd', 'exdi'
				@RestartSequence('xd')
			when ':p'
				@RestartSequence('tongue')
			when '>:p', '>:р', '>:Р'
				@RestartSequence('angry_tongue')
			when ':р', ':Р'
				@RestartSequence('tongue')
			when ':c', 'o3o', 'oops', ':С', ':с', '(', ':('
				@RestartSequence('sad')
			when 'sorry'
				@RestartSequence('sorry')
			when 'okay mate', 'okay, mate'
				@RestartSequence('wink_left')
			else
				if text\find('hehehe') or text\find('hahaha')
					@RestartSequence('greeny')
				elseif text\find('^pff+')
					@RestartSequence('pffff')
				elseif text\find('^blah blah')
					@RestartSequence('blahblah')
				else
					@RestartSequence('talk')

	PPM2_EmoteAnimation: (ply = NULL, emote = '', time, isEndless = false, shouldStop = false) =>
		return if ply ~= @GetEntity()
		for _, {:sequence} in ipairs PPM2.AVALIABLE_EMOTES
			if shouldStop or sequence ~= emote
				@EndSequence(sequence)

		if not shouldStop
			seqPlay = @RestartSequence(emote, time)
			if not seqPlay
				PPM2.Message("Unknown Emote - #{emote}!")
				print(seqPlay, @isValid)
				print(debug.traceback())
				return
			seqPlay\SetInfinite(isEndless)
			seqPlay\RestartChildren()

	DataChanges: (state) =>

PPM2.GetPonyExpressionsController = (...) -> PPM2.PonyExpressionsController\SelectController(...)
