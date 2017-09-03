
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

class ExpressionSequence extends PPM2.SequenceBase
	new: (controller, data) =>
		super(controller, data)

		{
			'flexSequence': @flexSequence
			'bonesSequence': @bonesSequence
			'bones': @bonesNames
			'flexes': @flexNames
		} = data

		@ent = controller.ent
		@controller = controller

		@flexStates = {}
		@bonesNames = @bonesNames or {}
		@bonesFuncsPos = ['SetModifier' .. boneName .. 'Position' for boneName in *@bonesNames]
		@bonesFuncsScale = ['SetModifier' .. boneName .. 'Scale' for boneName in *@bonesNames]
		@bonesFuncsAngles = ['SetModifier' .. boneName .. 'Angles' for boneName in *@bonesNames]
		@RestartChildren()
		@Launch()

	GetController: => @controller
	GetEntity: => @ent

	RestartChildren: =>
		if @flexSequence
			if flexController = @controller.renderController\GetFlexController()
				@flexController = flexController
				if type(@flexSequence) == 'table'
					for seq in *@flexSequence
						flexController\StartSequence(seq, @time)\SetInfinite(@GetInfinite())
				else
					flexController\StartSequence(@flexSequence, @time)\SetInfinite(@GetInfinite())
				if @flexNames
					@flexStates = [{flexController\GetFlexState(flex), flexController\GetFlexState(flex)\GetModifierID(@name .. '_emote')} for flex in *@flexNames]

		if @bonesSequence
			if bones = @ent\PPMBonesModifier()
				@bonesController = bones
				if type(@bonesSequence) == 'table'
					for seq in *@bonesSequence
						bones\StartSequence(seq, @time)\SetInfinite(@GetInfinite())
				else
					bones\StartSequence(@bonesSequence, @time)\SetInfinite(@GetInfinite())

				@bonesModifierID = bones\GetModifierID(@name .. '_emote')

	Think: (delta = 0) =>
		@ent = @controller.ent
		return false if not IsValid(@ent)
		super(delta)

	Stop: =>
		super()
		if @flexController
			if @flexSequence
				if type(@flexSequence) == 'table'
					for id in *@flexSequence
						@flexController\EndSequence(id)
				else
					@flexController\EndSequence(@flexSequence)
			flex\ResetModifiers(id) for {flex, id} in *@flexStates
		if @bonesController and @bonesSequence
			if type(@bonesSequence) == 'table'
				for id in *@bonesSequence
					@bonesController\EndSequence(id)
			else
				@bonesController\EndSequence(@bonesSequence)

	SetBonePosition: (id = 1, val = Vector(0, 0, 0)) => @controller[@bonesFuncsPos[id]] and @controller[@bonesFuncsPos[id]](@controller, @bonesModifierID, val)
	SetBoneScale: (id = 1, val = 0) => @controller[@bonesFuncsScale[id]] and @controller[@bonesFuncsScale[id]](@controller, @bonesModifierID, val)
	SetBoneAngles: (id = 1, val = Angles(0, 0, 0)) => @controller[@bonesFuncsAngles[id]] and @controller[@bonesFuncsAngles[id]](@controller, @bonesModifierID, val)
	SetFlexWeight: (id = 1, val = 0) => @flexStates[id] and @flexStates[id][1](@flexStates[id][1], @flexStates[id][2], val)

PPM2.ExpressionSequence = ExpressionSequence

class PPM2.PonyExpressionsController extends PPM2.SequenceHolder
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
			'autostart': false
			'repeat': false
			'time': 2
		}

		{
			'name': 'wink_right'
			'flexSequence': 'wink_right'
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
			'autostart': false
			'repeat': false
			'time': 4
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
			'autostart': false
			'repeat': false
			'time': 6
		}

		{
			'name': 'pffff'
			'flexSequence': 'pffff'
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
			'name': 'ooo'
			'flexSequence': 'ooo'
			'autostart': false
			'repeat': false
			'time': 2
		}

		{
			'name': 'anger'
			'flexSequence': 'anger'
			'autostart': false
			'repeat': false
			'time': 5
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
		@ResetSequences()
		PPM2.DebugPrint('Created new PonyExpressionsController for ', @ent, ' as part of ', controller, '; internal ID is ', @objID)

	PPM2_HurtAnimation: (ply = NULL) =>
		return if ply\GetEntity() ~= @ent\GetEntity()
		@RestartSequence('hurt')
		@EndSequence('kill_grin')

	PPM2_KillAnimation: (ply = NULL) =>
		return if ply\GetEntity() ~= @ent\GetEntity()
		@RestartSequence('kill_grin')
		@EndSequence('anger')

	PPM2_AngerAnimation: (ply = NULL) =>
		return if ply\GetEntity() ~= @ent\GetEntity()
		@EndSequence('kill_grin')
		@RestartSequence('anger')

	PPM2_EmoteAnimation: (ply = NULL, emote = '', time, isEndless = false, shouldStop = false) =>
		return if ply\GetEntity() ~= @ent\GetEntity()
		for {:sequence} in *PPM2.AVALIABLE_EMOTES
			if shouldStop or sequence ~= emote
				@EndSequence(sequence)

		if not shouldStop
			seqPlay = @RestartSequence(emote, time)
			seqPlay\SetInfinite(isEndless)
			seqPlay\RestartChildren()

	DataChanges: (state) =>

PPM2.GetPonyExpressionsController = (...) -> PPM2.PonyExpressionsController\SelectController(...)
