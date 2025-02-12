
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

--
-- 0    eyes_updown
-- 1    eyes_rightleft
-- 2    JawOpen
-- 3    JawClose
-- 4    Smirk
-- 5    Frown
-- 6    Stretch
-- 7    Pucker
-- 8    Grin
-- 9    CatFace
-- 10   Mouth_O
-- 11   Mouth_O2
-- 12   Mouth_Full
-- 13   Tongue_Out
-- 14   Tongue_Up
-- 15   Tongue_Down
-- 16   NoEyelashes
-- 17   Eyes_Blink
-- 18   Left_Blink
-- 19   Right_Blink
-- 20   Scrunch
-- 21   FatButt
-- 22   Stomach_Out
-- 23   Stomach_In
-- 24   Throat_Bulge
-- 25   Male
-- 26   Hoof_Fluffers
-- 27   o3o
-- 28   Ear_Fluffers
-- 29   Fangs
-- 30   Claw_Teeth
-- 31   Fang_Test
-- 32   angry_eyes
-- 33   sad_eyes
-- 34   Eyes_Blink_Lower
-- 35   Male_2
-- 36   Buff_Body
-- 37   Manliest_Chin
-- 38   Lowerlid_Raise
-- 39   Happy_Eyes
-- 40   Duck

BLINK_CURVE = {0, 0.2, 0.45, 0.65, 0.9, 1, 1, 0.75, 0.55, 0.25, 0.15, 0}
BREATH_CURVE = {0, 0, 0, 0.1, 0.3, 0.55, 0.85, 1, 1, 0.85, 0.65, 0.4, 0.2, 0, 0, 0}

DISABLE_FLEXES = CreateConVar('ppm2_disable_flexes', '0', {FCVAR_ARCHIVE}, 'Disable pony flexes controllers. Saves some FPS.')

class FlexState extends PPM2.ModifierBase
	@SetupModifiers: =>
		@RegisterModifier('Speed', 0)
		@RegisterModifier('Scale', 0)
		@RegisterModifier('Weight', 0)

	new: (controller, flexName = '', flexID = 0, scale = 1, speed = 1, active = true, min = 0, max = 1, useModifiers = true) =>
		super()
		@controller = controller
		@name = flexName
		@flexName = flexName
		@flexID = flexID
		@id = flexID
		@scale = scale
		@speed = speed
		@originalscale = scale
		@originalspeed = speed
		@min = min
		@max = max
		@current = -1
		@target = 0
		@speedModify = 1
		@scaleModify = 1
		@modifiers = {}
		@useModifiers = useModifiers
		@active = active
		@useLerp = true
		@lerpMultiplier = 1
		@activeID = "DisableFlex#{@flexName}"
		controller = @controller\GetController()\GetData()
		@SetIsActive(not controller['Get' .. @activeID](controller)) if controller['Get' .. @activeID]

	__tostring: => "[#{@@__name}:#{@flexName}[#{@flexID}]|#{@GetData()}]"

	GetFlexID: => @flexID
	GetFlexName: => @flexName
	SetUseLerp: (val = true) => @useLerp = val
	GetUseLerp: => @useLerp
	UseLerp: => @useLerp
	SetLerpModify: (val = 1) => @lerpMultiplier = val
	GetLerpModify: => @lerpMultiplier
	LerpModify: => @lerpMultiplier

	GetEntity: => @controller\GetEntity()
	GetData: => @controller
	GetController: => @controller
	GetValue: => @current
	GetRealValue: => @target
	SetValue: (val = @target) =>
		@current = math.Clamp(val, @min, @max) * @scale * @scaleModify
		@target = @target
	SetRealValue: (val = @target) => @target = math.Clamp(val, @min, @max) * @scale * @scaleModify

	GetScale: => @scale
	GetSpeed: => @speed
	GetScaleModify: => @scaleModify
	GetSpeedModify: => @speedModify
	GetOriginalScale: => @originalscale
	GetOriginalSpeed: => @originalspeed

	SetScale: (val = @scale) => @scale = val
	GetSpeed: (val = @speed) => @speed = val
	SetScaleModify: (val = @scaleModify) => @scaleModify = val
	GetSpeedModify: (val = @speedModify) => @speedModify = val

	GetIsActive: => @active
	SetIsActive: (val = true) => @active = val

	AddValue: (val = 0) => @SetValue(@current + val)
	AddRealValue: (val = 0) => @SetRealValue(@target + val)
	Think: (ent = @GetEntity(), delta = 0) =>
		return if not @active

		if @useModifiers
			@current = 0
			@scale = @originalscale * @scaleModify
			@speed = @originalspeed * @speedModify

			if @useLerp
				for i = 1, #@WeightModifiers
					@modifiers[i] = Lerp(delta * 15 * @speed * @speedModify * @lerpMultiplier, @modifiers[i] or 0, @WeightModifiers[i])
					@current += @modifiers[i]
			else
				@current += @WeightModifiers[i] for i = 1, #@WeightModifiers

			@scale += modif for _, modif in ipairs @ScaleModifiers
			@speed += modif for _, modif in ipairs @SpeedModifiers
			@current = math.Clamp(@current, @min, @max) * @scale

		ent\SetFlexWeight(@flexID, @current)

	DataChanges: (state) =>
		return if state\GetKey() ~= @activeID
		@SetIsActive(not state\GetValue())
		@GetController()\RebuildIterableList()
		@Reset()

	Reset: (resetVars = true) =>
		for name, id in pairs @modifiersNames
			@ResetModifiers(name)
		if resetVars
			@scaleModify = 1
			@speedModify = 1
		@scale = @originalscale * @scaleModify
		@speed = @originalspeed * @speedModify
		@target = 0
		@current = 0
		@GetEntity()\SetFlexWeight(@flexID, 0) if IsValid(@GetEntity())

PPM2.FlexState = FlexState

class FlexSequence extends PPM2.SequenceBase
	new: (controller, data) =>
		super(controller, data)

		{
			'ids': @flexIDsIterable
			'numid': @numid
		} = data

		@flexIDS = {}
		@flexStates = {}
		i = 1
		for _, id in ipairs data.ids
			state = controller\GetFlexState(id)
			num = state\GetModifierID(@name)
			@["flex_#{id}"] = num
			@flexIDS[id] = num
			@flexStates[id] = state
			@flexStates[i] = state
			@flexIDS[i] = num
			i += 1

		@controller = controller
		@Launch()

	GetController: => @controller
	GetModifierID: (id = '') => @flexIDS[id]
	GetFlexState: (id = '') => @flexStates[id]

	Think: (delta = 0) =>
		return false if not IsValid(@GetEntity())
		super(delta)

	Stop: =>
		super()
		return unless @parent
		@parent\GetFlexState(id)\ResetModifiers(@name) for _, id in ipairs @flexIDsIterable

	SetModifierWeight: (id = '', val = 0) => @GetFlexState(id)\SetModifierWeight(@GetModifierID(id), val)
	SetModifierSpeed: (id = '', val = 0) => @GetFlexState(id)\SetModifierSpeed(@GetModifierID(id), val)
	SetUseLerp: (id = '', status = true) => @GetFlexState(id)\SetUseLerp(status)
	GetUseLerp: (id = '') => @GetFlexState(id)\GetUseLerp()

PPM2.FlexSequence = FlexSequence

class PonyFlexController extends PPM2.ControllerChildren
	@AVALIABLE_CONTROLLERS = {}
	@MODELS = {'models/ppm/player_default_base_new.mdl', 'models/ppm/player_default_base_new_nj.mdl'}

	@FLEX_LIST = {
		{flex: 'eyes_updown',       scale: 1, speed: 1, active: false}
		{flex: 'eyes_rightleft',    scale: 1, speed: 1, active: false}
		{flex: 'JawOpen',           scale: 1, speed: 1, active: true}
		{flex: 'JawClose',          scale: 1, speed: 1, active: true}
		{flex: 'Smirk',             scale: 1, speed: 1, active: true}
		{flex: 'Frown',             scale: 1, speed: 1, active: true}
		{flex: 'Stretch',           scale: 1, speed: 1, active: false}
		{flex: 'Pucker',            scale: 1, speed: 1, active: false}
		{flex: 'Grin',              scale: 1, speed: 1, active: true}
		{flex: 'CatFace',           scale: 1, speed: 1, active: true}
		{flex: 'Mouth_O',           scale: 1, speed: 1, active: true}
		{flex: 'Mouth_O2',          scale: 1, speed: 1, active: true}
		{flex: 'Mouth_Full',        scale: 1, speed: 1, active: false}
		{flex: 'Tongue_Out',        scale: 1, speed: 1, active: true}
		{flex: 'Tongue_Up',         scale: 1, speed: 1, active: true}
		{flex: 'Tongue_Down',       scale: 1, speed: 1, active: true}
		{flex: 'NoEyelashes',       scale: 1, speed: 1, active: false}
		{flex: 'Eyes_Blink',        scale: 1, speed: 1, active: false}
		{flex: 'Left_Blink',        scale: 1, speed: 1, active: true}
		{flex: 'Right_Blink',       scale: 1, speed: 1, active: true}
		{flex: 'Scrunch',           scale: 1, speed: 1, active: true}
		{flex: 'FatButt',           scale: 1, speed: 1, active: false}
		{flex: 'Stomach_Out',       scale: 1, speed: 1, active: true}
		{flex: 'Stomach_In',        scale: 1, speed: 1, active: true}
		{flex: 'Throat_Bulge',      scale: 1, speed: 1, active: true}
		{flex: 'Male',              scale: 1, speed: 1, active: false}
		{flex: 'Hoof_Fluffers',     scale: 1, speed: 1, active: false}
		{flex: 'o3o',               scale: 1, speed: 1, active: true}
		{flex: 'Ear_Fluffers',      scale: 1, speed: 1, active: false}
		{flex: 'Fangs',             scale: 1, speed: 1, active: false}
		{flex: 'Claw_Teeth',        scale: 1, speed: 1, active: false}
		{flex: 'Fang_Test',         scale: 1, speed: 1, active: false}
		{flex: 'angry_eyes',        scale: 1, speed: 1, active: true}
		{flex: 'sad_eyes',          scale: 1, speed: 1, active: true}
		{flex: 'Eyes_Blink_Lower',  scale: 1, speed: 1, active: true}
		{flex: 'Male_2',            scale: 1, speed: 1, active: false}
		{flex: 'Buff_Body',         scale: 1, speed: 1, active: false}
		{flex: 'Manliest_Chin',     scale: 1, speed: 1, active: false}
		{flex: 'Lowerlid_Raise',    scale: 1, speed: 1, active: false}
		{flex: 'Happy_Eyes',        scale: 1, speed: 1, active: true}
		{flex: 'Duck',              scale: 1, speed: 1, active: true}
	}

	@SEQUENCES = {
		{
			'name': 'anger'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Frown', 'Grin', 'angry_eyes', 'Scrunch'}
			'reset': =>
				@SetTime(math.random(15, 45) / 10)
				@lastStrengthUpdate = @lastStrengthUpdate or 0
				if @lastStrengthUpdate < CurTimeL()
					@lastStrengthUpdate = CurTimeL() + 2
					@frownStrength = math.random(40, 100) / 100
					@grinStrength = math.random(15, 40) / 100
					@angryStrength = math.random(30, 80) / 100
					@scrunchStrength = math.random(50, 100) / 100
					@SetModifierWeight(1, @frownStrength)
					@SetModifierWeight(2, @grinStrength)
					@SetModifierWeight(3, @angryStrength)
					@SetModifierWeight(4, @scrunchStrength)
		}

		{
			'name': 'sad'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Frown', 'Grin', 'sad_eyes'}
			'reset': =>
				@SetTime(math.random(15, 45) / 10)
				@lastStrengthUpdate = @lastStrengthUpdate or 0
				if @lastStrengthUpdate < CurTimeL()
					@lastStrengthUpdate = CurTimeL() + 2
					@frownStrength = math.random(40, 100) / 100
					@grinStrength = math.random(15, 40) / 100
					@angryStrength = math.random(30, 80) / 100
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, @frownStrength)
				@SetModifierWeight(2, @grinStrength)
				@SetModifierWeight(3, @angryStrength)
		}

		{
			'name': 'ugh'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'sad_eyes', 'Eyes_Blink_Lower'}
			'reset': =>
				@SetModifierWeight(1, math.Rand(0.27, 0.34))
				@SetModifierWeight(2, math.Rand(0.3, 0.35))
				@PauseSequence('eyes_blink')
				@PauseSequence('eyes_idle')
		}

		{
			'name': 'suggestive_eyes'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'sad_eyes', 'Eyes_Blink_Lower'}
			'reset': =>
				@SetModifierWeight(1, 0.28)
				@SetModifierWeight(2, 0.4)
				@PauseSequence('eyes_blink')
				@PauseSequence('eyes_idle')
		}

		{
			'name': 'lips_lick'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Tongue_Out', 'Tongue_Up'}
			'reset': =>
				@SetModifierWeight(1, 0.9)
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(2, 0.75 + math.sin(CurTimeL() * 7) * 0.25)
		}

		{
			'name': 'tongue_pullout'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Tongue_Out'}
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, 0.15 + math.sin(CurTimeL() * 10) * 0.1)
		}

		{
			'name': 'tongue_pullout_twitch'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Tongue_Out'}
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, 0.5 + math.sin(CurTimeL() * 4) * 0.5)
		}

		{
			'name': 'tongue_pullout_twitch_fast'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Tongue_Out'}
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, 0.5 + math.sin(CurTimeL() * 8) * 0.5)
		}

		{
			'name': 'suggestive_open'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Pucker', 'JawOpen', 'Scrunch'}
			'reset': =>
				@SetModifierWeight(1, math.Rand(0.28, 0.34))
				@SetModifierWeight(2, math.Rand(0.35, 0.40))
				@SetModifierWeight(3, math.Rand(0.45, 0.50))
		}

		{
			'name': 'suggestive_open_anim'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Pucker', 'JawOpen', 'Scrunch'}
			'reset': =>
				@SetModifierWeight(1, math.Rand(0.28, 0.34))
				@SetModifierWeight(3, math.Rand(0.45, 0.50))
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(2, 0.2 + math.sin(CurTimeL() * 16) * 0.07)
		}

		{
			'name': 'face_smirk'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Smirk', 'Frown'}
			'reset': =>
				@SetModifierWeight(1, 0.78)
				@SetModifierWeight(2, 0.61)
		}

		{
			'name': 'eyes_idle'
			'autostart': true
			'repeat': true
			'time': 5
			'ids': {'Left_Blink', 'Right_Blink'}
			'func': (delta, timeOfAnim) =>
				return false if @GetEntity()\GetNWBool('PPM2.IsDeathRagdoll') or (@GetEntity()\IsPlayer() and not @GetEntity()\Alive())
				value = math.abs(math.sin(CurTimeL() * .5) * .15)
				@SetModifierWeight(1, value)
				@SetModifierWeight(2, value)
		}

		{
			'name': 'eyes_close'
			'autostart': true
			'repeat': true
			'time': 5
			'ids': {'Left_Blink', 'Right_Blink', 'Frown'}
			'func': (delta, timeOfAnim) =>
				allow = true

				if @GetEntity()\IsPlayer()
					if @GetEntity()\Alive()
						allow = false
				else
					if not @GetEntity()\GetNWBool('PPM2.IsDeathRagdoll')
						allow = false

				if not allow
					@SetModifierWeight(1, 0)
					@SetModifierWeight(2, 0)
					@SetModifierWeight(3, 0)
					return

				@SetModifierWeight(1, 1)
				@SetModifierWeight(2, 1)
				@SetModifierWeight(3, 0.5)
		}

		{
			'name': 'body_idle'
			'autostart': true
			'repeat': true
			'time': 2
			'ids': {'Stomach_Out'}
			'func': (delta, timeOfAnim) =>
				return false if @GetEntity()\GetNWBool('PPM2.IsDeathRagdoll') or (@GetEntity()\IsPlayer() and not @GetEntity()\Alive())
				return if timeOfAnim < 0 or timeOfAnim > 1
				@SetModifierWeight(1, math.tbezier(timeOfAnim, BREATH_CURVE) * 0.35)
		}

		{
			'name': 'health_idle'
			'autostart': true
			'repeat': true
			'time': 5
			'ids': {'Frown', 'Left_Blink', 'Right_Blink', 'Scrunch', 'Mouth_O', 'JawOpen', 'Grin'}
			'func': (delta, timeOfAnim) =>
				return false if (not @GetEntity()\IsPlayer() or not @GetEntity()\Alive()) and not @GetEntity()\IsNPC() and @GetEntity().Type ~= 'nextbot'
				frown = @GetModifierID(1)
				frownState = @GetFlexState(1)
				left, right = @GetModifierID(2), @GetModifierID(3)
				leftState, rightState = @GetFlexState(2), @GetFlexState(3)
				Mouth_O, Mouth_OState = @GetModifierID(4), @GetFlexState(4)
				Scrunch = @GetModifierID(4)
				ScrunchState = @GetFlexState(4)

				hp, mhp = @GetEntity()\Health(), @GetEntity()\GetMaxHealth()
				mhp = 1 if mhp == 0
				div = hp / mhp
				strength = math.Clamp(1.5 - div * 1.5, 0, 1)
				frownState\SetModifierWeight(frown, strength)
				ScrunchState\SetModifierWeight(Scrunch, strength * .5)
				leftState\SetModifierWeight(left, strength * .1)
				rightState\SetModifierWeight(right, strength * .1)
				Mouth_OState\SetModifierWeight(Mouth_O, strength * .8)

				JawOpen = @GetModifierID(6)
				JawOpenState = @GetFlexState(6)

				if strength > .75
					JawOpenState\SetModifierWeight(JawOpen, strength * .2 + math.sin(CurTimeL() * strength * 3) * .1)
				else
					JawOpenState\SetModifierWeight(JawOpen, 0)

				if div >= 2
					@SetModifierWeight(7, .5)
				else
					@SetModifierWeight(7, 0)
		}

		{
			'name': 'greeny'
			'autostart': false
			'repeat': false
			'time': 2
			'ids': {'Grin'}
			'func': (delta, timeOfAnim) =>
				Grin = @GetModifierID(1)
				GrinState = @GetFlexState(1)
				strength = .5 + math.sin(CurTimeL() * 2) * .25
				GrinState\SetModifierWeight(Grin, strength)
		}

		{
			'name': 'big_grin'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'Grin'}
			'func': (delta, timeOfAnim) =>
				Grin = @GetModifierID(1)
				GrinState = @GetFlexState(1)
				GrinState\SetModifierWeight(Grin, 1)
		}

		{
			'name': 'o3o'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'o3o'}
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, 1)
		}

		{
			'name': 'owo_alternative'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'o3o', 'JawOpen'}
			'reset': (delta, timeOfAnim) =>
				@SetModifierWeight(1, math.Rand(0.8, 1))
				@SetModifierWeight(2, math.Rand(0.05, 0.1))
		}

		{
			'name': 'xd'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'Grin', 'Left_Blink', 'Right_Blink', 'JawOpen'}
			'func': (delta, timeOfAnim) =>
				Grin = @GetModifierID(1)
				GrinState = @GetFlexState(1)
				GrinState\SetModifierWeight(Grin, .6)

				Left_Blink = @GetModifierID(2)
				Left_BlinkState = @GetFlexState(2)
				Left_BlinkState\SetModifierWeight(Left_Blink, .9)

				Right_Blink = @GetModifierID(3)
				Right_BlinkState = @GetFlexState(3)
				Right_BlinkState\SetModifierWeight(Right_Blink, .9)

				JawOpen = @GetModifierID(4)
				JawOpenState = @GetFlexState(4)
				JawOpenState\SetModifierScale(JawOpen, 2)
				JawOpenState\SetModifierWeight(JawOpen, (timeOfAnim % .1) * 2)
		}

		{
			'name': 'tongue'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'JawOpen', 'Tongue_Out'}
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, .1)
				@SetModifierWeight(2, 1)
		}

		{
			'name': 'angry_tongue'
			'autostart': false
			'repeat': false
			'time': 6
			'ids': {'Frown', 'Grin', 'angry_eyes', 'Scrunch', 'JawOpen', 'Tongue_Out'}
			'reset': (delta, timeOfAnim) =>
				@SetModifierWeight(1, math.random(40, 100) / 100)
				@SetModifierWeight(2, math.random(15, 40) / 100)
				@SetModifierWeight(3, math.random(30, 80) / 100)
				@SetModifierWeight(4, math.random(50, 100) / 100)
				@SetModifierWeight(5, math.random(10, 15) / 100)
				@SetModifierWeight(6, math.random(80, 100) / 100)
		}

		{
			'name': 'pffff'
			'autostart': false
			'repeat': false
			'time': 6
			'ids': {'Frown', 'Grin', 'angry_eyes', 'Scrunch', 'JawOpen', 'Tongue_Out', 'Tongue_Down', 'Tongue_Up'}
			'reset': =>
				@SetModifierWeight(1, math.random(40, 100) / 100)
				@SetModifierWeight(2, math.random(15, 40) / 100)
				@SetModifierWeight(3, math.random(30, 80) / 100)
				@SetModifierWeight(4, math.random(50, 100) / 100)
				@SetModifierWeight(5, math.random(10, 15) / 100)
				@SetModifierWeight(6, math.random(80, 100) / 100)
			'func': (delta, timeOfAnim) =>
				val = math.sin(CurTimeL() * 8) * .6
				if val > 0
					@SetModifierWeight(7, val)
					@SetModifierWeight(8, 0)
				else
					@SetModifierWeight(7, 0)
					@SetModifierWeight(8, -val)
		}

		{
			'name': 'cat'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'CatFace'}
			'func': (delta, timeOfAnim) =>
				Grin = @GetModifierID(1)
				GrinState = @GetFlexState(1)
				GrinState\SetModifierWeight(Grin, 1)
		}

		{
			'name': 'ooo'
			'autostart': false
			'repeat': false
			'time': 2
			'ids': {'Mouth_O2', 'Mouth_O'}
			'func': (delta, timeOfAnim) =>
				timeOfAnim *= 2
				Grin = @GetModifierID(1)
				GrinState = @GetFlexState(1)
				GrinState\SetModifierWeight(Grin, timeOfAnim)
				Grin = @GetModifierID(2)
				GrinState = @GetFlexState(2)
				GrinState\SetModifierWeight(Grin, timeOfAnim)
		}

		{
			'name': 'talk'
			'autostart': false
			'repeat': false
			'time': 2
			'ids': {'JawOpen', 'Tongue_Out', 'Tongue_Up', 'Tongue_Down'}
			'create': =>
				@talkAnim = for i = 0, 1, 0.05
					rand = math.random(1, 100) / 100
					if rand <= .25
						{1 * rand, 0.4 * rand, 2 * rand, 0}
					elseif rand >= .25 and rand < .4
						rand *= .8
						{2 * rand, .6 * rand, 0, 1 * rand}
					elseif rand >= .4 and rand < .75
						rand *= .6
						{1 * rand, 0, 1 * rand, 2 * rand}
					elseif rand >= .75
						rand *= .4
						{1.5 * rand, 0, 1 * rand, 0}
				@SetModifierSpeed(1, 2)
				@SetModifierSpeed(2, 2)
				@SetModifierSpeed(3, 2)
				@SetModifierSpeed(4, 2)
			'func': (delta, timeOfAnim) =>
				JawOpen = @GetModifierID(1)
				JawOpenState = @GetFlexState(1)
				Tongue_OutOpen = @GetModifierID(2)
				Tongue_OutOpenState = @GetFlexState(2)
				Tongue_UpOpen = @GetModifierID(3)
				Tongue_UpOpenState = @GetFlexState(3)
				Tongue_DownOpen = @GetModifierID(4)
				Tongue_DownOpenState = @GetFlexState(4)
				cPos = math.floor(timeOfAnim * 20) + 1
				data = @talkAnim[cPos]
				return if not data
				{jaw, out, up, down} = data
				JawOpenState\SetModifierWeight(JawOpen, jaw)
				Tongue_OutOpenState\SetModifierWeight(Tongue_OutOpen, out)
				Tongue_UpOpenState\SetModifierWeight(Tongue_UpOpen, up)
				Tongue_DownOpenState\SetModifierWeight(Tongue_DownOpen, down)
		}

		{
			'name': 'talk_endless'
			'autostart': false
			'repeat': true
			'time': 4
			'ids': {'JawOpen', 'Tongue_Out', 'Tongue_Up', 'Tongue_Down'}
			'create': =>
				@talkAnim = for i = 0, 1, 0.05
					rand = math.random(1, 100) / 100
					if rand <= .25
						{1 * rand, 0.4 * rand, 2 * rand, 0}
					elseif rand >= .25 and rand < .4
						rand *= .8
						{2 * rand, .6 * rand, 0, 1 * rand}
					elseif rand >= .4 and rand < .75
						rand *= .6
						{1 * rand, 0, 1 * rand, 2 * rand}
					elseif rand >= .75
						rand *= .4
						{1.5 * rand, 0, 1 * rand, 0}
				@SetModifierSpeed(1, 2)
				@SetModifierSpeed(2, 2)
				@SetModifierSpeed(3, 2)
				@SetModifierSpeed(4, 2)
			'func': (delta, timeOfAnim) =>
				JawOpen = @GetModifierID(1)
				JawOpenState = @GetFlexState(1)
				Tongue_OutOpen = @GetModifierID(2)
				Tongue_OutOpenState = @GetFlexState(2)
				Tongue_UpOpen = @GetModifierID(3)
				Tongue_UpOpenState = @GetFlexState(3)
				Tongue_DownOpen = @GetModifierID(4)
				Tongue_DownOpenState = @GetFlexState(4)
				cPos = math.floor(timeOfAnim * 20) + 1
				data = @talkAnim[cPos]
				return if not data
				{jaw, out, up, down} = data
				volume = @GetEntity()\VoiceVolume() * 6
				jaw *= volume
				out *= volume
				up *= volume
				down *= volume
				JawOpenState\SetModifierWeight(JawOpen, jaw)
				Tongue_OutOpenState\SetModifierWeight(Tongue_OutOpen, out)
				Tongue_UpOpenState\SetModifierWeight(Tongue_UpOpen, up)
				Tongue_DownOpenState\SetModifierWeight(Tongue_DownOpen, down)
		}

		{
			'name': 'eyes_blink'
			'autostart': true
			'repeat': true
			'time': 7
			'ids': {'Eyes_Blink_Lower'}
			'create': =>
				@SetUseLerp(1, false)

			'reset': =>
				@nextBlink = math.random(300, 600) / 1000
				@nextBlinkLength = math.random(15, 30) / 800
				@min, @max = @nextBlink, @nextBlink + @nextBlinkLength

			'func': (delta, timeOfAnim) =>
				return false if @GetEntity()\GetNWBool('PPM2.IsDeathRagdoll') or (@GetEntity()\IsPlayer() and not @GetEntity()\Alive())
				if @min > timeOfAnim or @max < timeOfAnim
					if @blinkHit
						@blinkHit = false
						@SetModifierWeight(1, 0)

					return

				len = (timeOfAnim - @min) / @nextBlinkLength
				blink = math.tbezier(len\clamp(0, 1), BLINK_CURVE)

				@SetModifierWeight(1, blink)
				-- print(len, blink)

				@blinkHit = true
		}

		{
			'name': 'hurt'
			'autostart': false
			'repeat': false
			'time': 4
			'ids': {'JawOpen', 'Frown', 'Grin', 'Scrunch'}
			'reset': (delta, timeOfAnim) =>
				@SetModifierWeight(1, math.random(4, 16) / 100)
				@SetModifierWeight(2, math.random(60, 70) / 100)
				@SetModifierWeight(3, math.random(30, 40) / 100)
				@SetModifierWeight(4, math.random(70, 90) / 100)
		}

		{
			'name': 'kill_grin'
			'autostart': false
			'repeat': false
			'time': 8
			'ids': {'Smirk', 'Frown', 'Grin'}
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, .51)
				@SetModifierWeight(2, .38)
				@SetModifierWeight(3, .66)
		}

		{
			'name': 'sorry'
			'autostart': false
			'repeat': false
			'time': 8
			'ids': {'Frown', 'Stretch', 'Grin', 'Scrunch', 'sad_eyes'}
			'create': =>
				@SetModifierWeight(1, math.random(45, 75) / 100)
				@SetModifierWeight(2, math.random(45, 75) / 100)
				@SetModifierWeight(3, math.random(70, 100) / 100)
				@SetModifierWeight(4, math.random(7090, 100) / 100)
		}

		{
			'name': 'scrunch'
			'autostart': false
			'repeat': false
			'time': 6
			'ids': {'Scrunch'}
			'create': =>
				@SetModifierWeight(1, math.random(80, 100) / 100)
		}

		{
			'name': 'gulp'
			'autostart': false
			'repeat': false
			'time': 2
			'ids': {'Throat_Bulge', 'Frown', 'Grin'}
			'create': =>
				@SetModifierWeight(2, 1)
				@SetModifierWeight(3, math.random(35, 55) / 100)
			'func': (delta, timeOfAnim) =>
				if timeOfAnim > 0.5
					@SetModifierWeight(1, (1 - timeOfAnim) * 2)
				else
					@SetModifierWeight(1, timeOfAnim * 2)
		}

		{
			'name': 'blahblah'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'o3o', 'Mouth_O'}
			'create': =>
				@SetModifierWeight(1, 1)
				@talkAnim = [math.random(50, 70) / 100 for i = 0, 1, 0.05]
			'func': (delta, timeOfAnim) =>
				cPos = math.floor(timeOfAnim * 20) + 1
				data = @talkAnim[cPos]
				return if not data
				@SetModifierWeight(2, data)
		}

		{
			'name': 'wink_left'
			'autostart': false
			'repeat': false
			'time': 2
			'ids': {'Frown', 'Stretch', 'Grin', 'Left_Blink'}
			'create': =>
				@SetModifierWeight(1, math.random(40, 60) / 100)
				@SetModifierWeight(2, math.random(30, 50) / 100)
				@SetModifierWeight(3, math.random(60, 100) / 100)
				@SetModifierWeight(4, 1)
				@PauseSequence('eyes_blink')
		}

		{
			'name': 'wink_right'
			'autostart': false
			'repeat': false
			'time': 2
			'ids': {'Frown', 'Stretch', 'Grin', 'Right_Blink'}
			'create': =>
				@SetModifierWeight(1, math.random(40, 60) / 100)
				@SetModifierWeight(2, math.random(30, 50) / 100)
				@SetModifierWeight(3, math.random(60, 100) / 100)
				@SetModifierWeight(4, 1)
				@PauseSequence('eyes_blink')
		}

		{
			'name': 'happy_eyes'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'Happy_Eyes'}
			'create': =>
				@SetModifierWeight(1, 1)
				@PauseSequence('eyes_blink')
		}

		{
			'name': 'happy_grin'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'Happy_Eyes', 'Grin'}
			'create': =>
				@SetModifierWeight(1, 1)
				@SetModifierWeight(2, 1)
				@PauseSequence('eyes_blink')
		}

		{
			'name': 'duck'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'Duck'}
			'create': =>
				@SetModifierWeight(1, math.random(70, 90) / 100)
		}

		{
			'name': 'duck_insanity'
			'autostart': false
			'repeat': false
			'time': 3
			'ids': {'Duck'}
			'func': (delta, timeOfAnim) =>
				@SetModifierWeight(1, math.abs(math.sin(timeOfAnim * @GetTime() * 4)))
		}

		{
			'name': 'duck_quack'
			'autostart': false
			'repeat': false
			'time': 5
			'ids': {'Duck', 'JawOpen'}
			'create': =>
				@talkAnim = for i = 0, 1, 0.1
					rand = math.random(1, 100)
					rand > 50 and 1 or 0
				@SetModifierWeight(1, math.random(70, 90) / 100)
			'func': (delta, timeOfAnim) =>
				cPos = math.floor(timeOfAnim * 10) + 1
				data = @talkAnim[cPos]
				return if not data
				@SetModifierWeight(2, data)
		}
	}

	@SetupFlexesTables: =>
		for i, flex in pairs @FLEX_LIST
			flex.id = i - 1
			flex.targetName = "target#{flex.flex}"
		@FLEX_IDS = {flex.id, flex for _, flex in ipairs @FLEX_LIST}
		@FLEX_TABLE = {flex.flex, flex for _, flex in ipairs @FLEX_LIST}

	@SetupFlexesTables()

	@NEXT_HOOK_ID = 0
	@SequenceObject = FlexSequence

	new: (data) =>
		super(data)
		@states = [FlexState(@, flex, id, scale, speed, active) for _, {:flex, :id, :scale, :speed, :active} in ipairs @@FLEX_LIST]
		@statesTable = {state\GetFlexName(), state for _, state in ipairs @states}
		@statesTable[state\GetFlexName()\lower()] = state for _, state in ipairs @states
		@statesTable[state\GetFlexID()] = state for _, state in ipairs @states
		@RebuildIterableList()
		ponyData = data\GetData()
		flex\SetUseLerp(ponyData\GetUseFlexLerp()) for _, flex in ipairs @states
		flex\SetLerpModify(ponyData\GetFlexLerpMultiplier()) for _, flex in ipairs @states
		@Hook('PlayerStartVoice', @PlayerStartVoice)
		@Hook('PlayerEndVoice', @PlayerEndVoice)
		@ResetSequences()

	IsValid: => @isValid

	GetFlexState: (name = '') => @statesTable[name]
	RebuildIterableList: =>
		return false if not @isValid
		@statesIterable = [state for _, state in ipairs @states when state\GetIsActive()]
	DataChanges: (state) =>
		return if not @isValid
		flexState\DataChanges(state) for _, flexState in ipairs @states
		if state\GetKey() == 'UseFlexLerp'
			flex\SetUseLerp(state\GetValue()) for _, flex in ipairs @states
		if state\GetKey() == 'FlexLerpMultiplier'
			flex\SetLerpModify(state\GetValue()) for _, flex in ipairs @states

	GetEntity: => @controller\GetEntity()
	GetData: => @controller
	GetController: => @controller

	PlayerStartVoice: (ply = NULL) =>
		return if ply ~= @GetEntity()
		@StartSequence('talk_endless')
	PlayerEndVoice: (ply = NULL) =>
		return if ply ~= @GetEntity()
		@EndSequence('talk_endless')

	ResetSequences: =>
		super()
		state\Reset(false) for _, state in ipairs @statesIterable

	Think: (ent = @GetEntity()) =>
		return if DISABLE_FLEXES\GetBool()
		delta = super(ent)
		return if not delta
		state\Think(ent, delta) for _, state in ipairs @statesIterable
		return delta

do
	ppm2_disable_flexes = (cvar, oldval, newval) ->
		for _, ply in ipairs player.GetAll()
			data = ply\GetPonyData()
			continue if not data
			renderer = data\GetRenderController()
			continue if not renderer
			flex = renderer\GetFlexController()
			continue if not flex
			flex\ResetSequences()
	cvars.AddChangeCallback 'ppm2_disable_flexes', ppm2_disable_flexes, 'ppm2_disable_flexes'

PPM2.PonyFlexController = PonyFlexController
PPM2.GetFlexController = (model = 'models/ppm/player_default_base_new.mdl') -> PonyFlexController.AVALIABLE_CONTROLLERS[model]
