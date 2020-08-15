
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

local DISABLE_HOOFSTEP_SOUND_CLIENT

if game.SinglePlayer()
	DISABLE_HOOFSTEP_SOUND_CLIENT = CreateConVar('ppm2_cl_no_hoofsound', '0', {FCVAR_ARCHIVE}, 'Disable hoofstep sound play time') if SERVER
else
	DISABLE_HOOFSTEP_SOUND_CLIENT = CreateConVar('ppm2_cl_no_hoofsound', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Disable hoofstep sound play time') if CLIENT

DISABLE_HOOFSTEP_SOUND = CreateConVar('ppm2_no_hoofsound', '0', {FCVAR_REPLICATED}, 'Disable hoofstep sound play time')

hook.Remove('PlayerStepSoundTime', 'PPM2.Hooks')
hook.Add 'PlayerStepSoundTime', 'PPM2.Hoofstep', (stepType = STEPSOUNDTIME_NORMAL, isWalking = false) =>
	return if not @IsPonyCached() or DISABLE_HOOFSTEP_SOUND_CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool() or DISABLE_HOOFSTEP_SOUND\GetBool()
	rate = @GetPlaybackRate() * .5
	if @Crouching()
		switch stepType
			when STEPSOUNDTIME_NORMAL
				return not isWalking and (300 / rate) or (600 / rate)
			when STEPSOUNDTIME_ON_LADDER
				return 500 / rate
			when STEPSOUNDTIME_WATER_KNEE
				return not isWalking and (400 / rate) or (800 / rate)
			when STEPSOUNDTIME_WATER_FOOT
				return not isWalking and (350 / rate) or (700 / rate)
	else
		switch stepType
			when STEPSOUNDTIME_NORMAL
				return not isWalking and (150 / rate) or (300 / rate)
			when STEPSOUNDTIME_ON_LADDER
				return 500 / rate
			when STEPSOUNDTIME_WATER_KNEE
				return not isWalking and (250 / rate) or (500 / rate)
			when STEPSOUNDTIME_WATER_FOOT
				return not isWalking and (175 / rate) or (350 / rate)

net.pool('ppm2_workaround_emitsound') if SERVER

SOUND_STRINGS_POOL = {}
SOUND_STRINGS_POOL_EXCP = {}
SOUND_STRINGS_POOL_INV = {}

AddSoundString = (sound) ->
	nextid = #SOUND_STRINGS_POOL_INV + 1
	SOUND_STRINGS_POOL[sound] = nextid
	SOUND_STRINGS_POOL_INV[nextid] = sound

AddSoundStringEx = (sound) ->
	nextid = #SOUND_STRINGS_POOL_INV + 1
	SOUND_STRINGS_POOL[sound] = nextid
	SOUND_STRINGS_POOL_EXCP[sound] = nextid
	SOUND_STRINGS_POOL_INV[nextid] = sound

class PPM2.MaterialSoundEntry
	@REGISTRIES = {}

	@Ask = (matType = MAT_DEFAULT) =>
		for reg in *@REGISTRIES
			if reg.material == matType
				return reg

		return false

	new: (name, material, variantsWalk = 0, variantsRun = 0, variantsWander = 0) =>
		table.insert(@@REGISTRIES, @)
		@name = name
		@material = material
		@variantsWalk = variantsWalk
		@variantsRun = variantsRun
		@variantsWander = variantsWander
		@variantsLand = 0
		@playHoofclap = true
		AddSoundString('player/ppm2/' .. @name .. '/' .. @name .. '_walk' .. i .. '.ogg') for i = 1, @variantsWalk
		AddSoundString('player/ppm2/' .. @name .. '/' .. @name .. '_run' .. i .. '.ogg') for i = 1, @variantsRun
		AddSoundString('player/ppm2/' .. @name .. '/' .. @name .. '_wander' .. i .. '.ogg') for i = 1, @variantsWander

	ShouldPlayHoofclap: => @playHoofclap

	DisableHoofclap: =>
		@playHoofclap = false
		return @

	GetWalkSound: =>
		return 'player/ppm2/' .. @name .. '/' .. @name .. '_walk' .. math.random(1, @variantsWalk) .. '.ogg' if @variantsWalk ~= 0
		return 'player/ppm2/' .. @name .. '/' .. @name .. '_run' .. math.random(1, @variantsRun) .. '.ogg' if @variantsRun ~= 0

	GetRunSound: =>
		return 'player/ppm2/' .. @name .. '/' .. @name .. '_run' .. math.random(1, @variantsRun) .. '.ogg' if @variantsRun ~= 0
		return 'player/ppm2/' .. @name .. '/' .. @name .. '_walk' .. math.random(1, @variantsWalk) .. '.ogg' if @variantsWalk ~= 0

	GetWanderSound: =>
		return 'player/ppm2/' .. @name .. '/' .. @name .. '_wander' .. math.random(1, @variantsWander) .. '.ogg' if @variantsWander ~= 0

	GetLandSound: =>
		return 'player/ppm2/' .. @name .. '/' .. @name .. '_land' .. math.random(1, @variantsLand) .. '.ogg' if @variantsLand ~= 0

	AddLandSounds: (variants) =>
		@variantsLand = variants
		AddSoundString('player/ppm2/' .. @name .. '/' .. @name .. '_land' .. i .. '.ogg') for i = 1, variants
		return @

AddSoundString('player/ppm2/hooves' .. i .. '.ogg') for i = 1, 3
AddSoundString('player/ppm2/falldown.ogg')
AddSoundStringEx('player/ppm2/jump.ogg')

RECALL = false

RecallPlayerFootstep = (ply, pos, foot, sound, volume, filter) ->
	RECALL = true
	ProtectedCall () -> hook.Run('PlayerFootstep', ply, pos, foot, sound, volume, filter)
	RECALL = false

LEmitSound = (ply, name, level = 75, volume = 1, levelIfOnServer = level) ->
	return if not IsValid(ply)
	if CLIENT
		ply\EmitSound(name, level, 100, volume) if not game.SinglePlayer() -- Some mods fix this globally (PAC3 for example)
		-- so lets try to avoid problems
		return

	if game.SinglePlayer()
		ply\EmitSound(name, level, 100, volume)
		return

	error('Tried to play unpooled sound: ' .. name) if not SOUND_STRINGS_POOL[name]

	filter = RecipientFilter()
	filter\AddPAS(ply\GetPos())
	filter\RemovePlayer(ply)

	for ply2 in *filter\GetPlayers()
		if ply2\GetInfoBool('ppm2_cl_no_hoofsound', false)
			filter\RemovePlayer(ply2)

	return if filter\GetCount() == 0

	net.Start('ppm2_workaround_emitsound')
	net.WritePlayer(ply)
	net.WriteUInt8(SOUND_STRINGS_POOL[name])
	net.WriteUInt8(levelIfOnServer)
	net.WriteUInt8((volume * 100)\floor())
	net.Send(filter)

	return filter

if CLIENT
	EntityEmitSound = (data) ->
		ply = data.Entity
		return if not IsValid(ply) or not ply\IsPlayer()
		pdata = ply\GetPonyData()
		return if not pdata or not pdata\ShouldMuffleHoosteps()
		return if not SOUND_STRINGS_POOL[data.OriginalSoundName] or SOUND_STRINGS_POOL_EXCP[data.OriginalSoundName]
		data.DSP = 31
		return true

	hook.Add 'EntityEmitSound', 'PPM2.Hoofsteps', EntityEmitSound, -2

-- 0    LrigPelvis
-- 1    Lrig_LEG_BL_Femur
-- 2    Lrig_LEG_BL_Tibia
-- 3    Lrig_LEG_BL_LargeCannon
-- 4    Lrig_LEG_BL_PhalanxPrima
-- 5    Lrig_LEG_BL_RearHoof
-- 6    Lrig_LEG_BR_Femur
-- 7    Lrig_LEG_BR_Tibia
-- 8    Lrig_LEG_BR_LargeCannon
-- 9    Lrig_LEG_BR_PhalanxPrima
-- 10   Lrig_LEG_BR_RearHoof
-- 11   LrigSpine1
-- 12   LrigSpine2
-- 13   LrigRibcage
-- 14   Lrig_LEG_FL_Scapula
-- 15   Lrig_LEG_FL_Humerus
-- 16   Lrig_LEG_FL_Radius
-- 17   Lrig_LEG_FL_Metacarpus
-- 18   Lrig_LEG_FL_PhalangesManus
-- 19   Lrig_LEG_FL_FrontHoof
-- 20   Lrig_LEG_FR_Scapula
-- 21   Lrig_LEG_FR_Humerus
-- 22   Lrig_LEG_FR_Radius
-- 23   Lrig_LEG_FR_Metacarpus
-- 24   Lrig_LEG_FR_PhalangesManus
-- 25   Lrig_LEG_FR_FrontHoof
-- 26   LrigNeck1
-- 27   LrigNeck2
-- 28   LrigNeck3
-- 29   LrigScull
-- 30   Jaw
-- 31   Ear_L
-- 32   Ear_R
-- 33   Mane02
-- 34   Mane03
-- 35   Mane03_tip
-- 36   Mane04
-- 37   Mane05
-- 38   Mane06
-- 39   Mane07
-- 40   Mane01
-- 41   Lrigweaponbone
-- 42   right_hand
-- 43   wing_l
-- 44   wing_r
-- 45   Tail01
-- 46   Tail02
-- 47   Tail03
-- 48   wing_l_bat
-- 49   wing_r_bat
-- 50   wing_open_l
-- 51   wing_open_r


class PPM2.PlayerFootstepsListener
	@soundBones = {
		Vector(8.112172, 3.867798, 0)
		Vector(8.111097, -3.863072, 0)
		Vector(-14.863633, 4.491844, 0)
		Vector(-14.863256, -4.487118, 0)
	}

	new: (ply) =>
		ply.__ppm2_walkc = @
		@ply = ply
		@walkSpeed = ply\GetWalkSpeed()
		@runSpeed = ply\GetRunSpeed()
		@playedWanderSound = false
		@running = false
		@lastVelocity = @ply\GetVelocity()
		@initialVel = @ply\GetVelocity()
		@lastTrace = @TraceNow()
		@onGround = @ply\OnGround()
		@Validate() if @onGround
		hook.Add 'PlayerFootstep', @, @PlayerFootstep, 8
		hook.Add 'Think', @, @Think

		@nextWanderPos = 0
		@nextWalkPos = 0
		@nextRunPos = 0

		@lambdaEmitWander = ->
			return if not @ply\IsValid()
			return if @ParentCall('GetDisableWanderSounds', false)
			return if not @onGround
			return if not @lastEntry
			sound = @lastEntry\GetWanderSound()
			return if not sound
			filter = @EmitSound(sound, 50, @GetVolume(), 70)
			return if not @ParentCall('GetCallPlayerFootstepHook', true)
			@nextWanderPos += 1
			@nextWanderPos %= 4
			RecallPlayerFootstep(@ply, @@GetPosForSide(@nextWanderPos, @ply), @nextWanderPos, sound, @GetVolume(), filter)

		@lambdaEmitWalk = ->
			return if not @ply\IsValid()
			return if not @onGround

			if not @lastEntry
				if not @ParentCall('GetDisableHoofsteps', false)
					sound = @@RandHoof()
					filter = @EmitSound(sound, 50, 0.8 * @GetVolume(), 65)

					return if not @ParentCall('GetCallPlayerFootstepHook', true)
					@nextWalkPos += 1
					@nextWalkPos %= 4
					RecallPlayerFootstep(@ply, @@GetPosForSide(@nextWalkPos, @ply), @nextWalkPos, sound, 0.8 * @GetVolume(), filter)

				return

			@EmitSound(@@RandHoof(), 50, 0.8 * @GetVolume(), 65) if @lastEntry\ShouldPlayHoofclap() and not @ParentCall('GetDisableHoofsteps', false)
			return if @ParentCall('GetDisableStepSounds', false)
			sound = @lastEntry\GetWalkSound()
			return if not sound

			filter = @EmitSound(sound, 40, 0.8 * @GetVolume(), 55)

			return true if not @ParentCall('GetCallPlayerFootstepHook', true)
			@nextWalkPos += 1
			@nextWalkPos %= 4
			RecallPlayerFootstep(@ply, @@GetPosForSide(@nextWalkPos, @ply), @nextWalkPos, sound, 0.8 * @GetVolume(), filter)

			return true

		@lambdaEmitRun = ->
			return if not @ply\IsValid()
			return if not @onGround

			if not @lastEntry
				if not @ParentCall('GetDisableHoofsteps', false)
					sound = @@RandHoof()
					filter = @EmitSound(sound, 60, @GetVolume(), 70)

					return if not @ParentCall('GetCallPlayerFootstepHook', true)
					@nextRunPos += 1
					@nextRunPos %= 4
					RecallPlayerFootstep(@ply, @@GetPosForSide(@nextRunPos, @ply), @nextRunPos, sound, @GetVolume(), filter)

				return

			@EmitSound(@@RandHoof(), 60, @GetVolume(), 70) if @lastEntry\ShouldPlayHoofclap() and not @ParentCall('GetDisableHoofsteps', false)
			return if @ParentCall('GetDisableStepSounds', false)
			sound = @lastEntry\GetRunSound()
			return if not sound
			filter = @EmitSound(sound, 40, 0.7 * @GetVolume(), 60)

			return true if not @ParentCall('GetCallPlayerFootstepHook', true)
			@nextRunPos += 1
			@nextRunPos %= 4
			RecallPlayerFootstep(@ply, @@GetPosForSide(@nextRunPos, @ply), @nextRunPos, sound, 0.7 * @GetVolume(), filter)

			return true

	@GetPosForSide = (side = 0, ply) =>
		if data = ply\GetPonyData()
			return ply\GetPos() if not @soundBones[side + 1]
			return ply\GetPos() + @soundBones[side + 1] * data\GetPonySize()

		return ply\GetPos() if not @soundBones[side + 1]
		return ply\GetPos() + @soundBones[side + 1]

	IsValid: => @ply\IsValid() and not @playedWanderSound

	ParentCall: (func, ifNone) =>
		if data = @ply\GetPonyData()
			return data[func](data)

		return ifNone

	GetVolume: => @ParentCall('GetHoofstepVolume', 1)

	Validate: =>
		newMatType = @lastTrace.MatType == 0 and MAT_DEFAULT or @lastTrace.MatType
		return if @lastMatType == newMatType
		@lastMatType = newMatType
		@lastEntry = PPM2.MaterialSoundEntry\Ask(@lastMatType)

	@RandHoof: => 'player/ppm2/hooves' .. math.random(1, 3) .. '.ogg'

	EmitSound: (name, level = 75, volume = 1, levelIfOnServer = level) => LEmitSound(@ply, name, level, volume, levelIfOnServer)

	PlayWalk: =>
		timer.Simple 0.13, @lambdaEmitWalk
		timer.Simple 0.21, @lambdaEmitWalk
		--timer.Simple 0.19, @lambdaEmitWalk
		return @lambdaEmitWalk()

	PlayWander: =>
		@playedWanderSound = true
		timer.Simple 0.13, @lambdaEmitWander
		timer.Simple 0.17, @lambdaEmitWander
		--timer.Simple 0.27, @lambdaEmitWander
		@lambdaEmitWander()

	PlayRun: =>
		timer.Simple 0.18, @lambdaEmitRun
		--timer.Simple 0.13, @lambdaEmitRun
		--timer.Simple 0.17, @lambdaEmitRun
		return @lambdaEmitRun()

	TraceNow: => @@TraceNow(@ply)

	@TraceNow: (ply, dropToGround) =>
		mins, maxs = ply\GetHull()

		trData = {
			start: ply\GetPos()
			endpos: ply\GetPos() - Vector(0, 0, not dropToGround and 5 or 15)
			:mins, :maxs
			filter: ply
		}

		return util.TraceHull(trData)

	PlayerFootstep: (ply) =>
		return if RECALL
		return if ply ~= @ply
		return true if CLIENT and @ply ~= LocalPlayer()
		@lastTrace = @TraceNow()
		@Validate()

		if @running
			return @PlayRun()
		else
			return @PlayWalk()

	Think: =>
		@lastVelocity = @ply\GetVelocity()
		vlen = @lastVelocity\Length()
		@onGround = @ply\OnGround()
		@running = vlen >= @runSpeed

		if vlen < @walkSpeed * 0.2
			@ply.__ppm2_walkc = nil
			@PlayWander()

PPM2.MaterialSoundEntry('concrete', MAT_CONCRETE, 11, 11, 5)
PPM2.MaterialSoundEntry('dirt', MAT_DIRT, 11, 11, 5)\AddLandSounds(4)\DisableHoofclap()
PPM2.MaterialSoundEntry('grass', MAT_GRASS, 10, 4, 6)\DisableHoofclap()
PPM2.MaterialSoundEntry('gravel', MAT_DEFAULT, 11, 11, 3)\DisableHoofclap() -- e
PPM2.MaterialSoundEntry('metalbar', MAT_METAL, 11, 11, 6)
PPM2.MaterialSoundEntry('metalbox', MAT_VENT, 10, 9, 4)
PPM2.MaterialSoundEntry('mud', MAT_SLOSH, 10, 9, 4)\DisableHoofclap()
PPM2.MaterialSoundEntry('sand', MAT_SAND, 11, 11, 0)\DisableHoofclap()
PPM2.MaterialSoundEntry('snow', MAT_SNOW, 11, 11, 5)\DisableHoofclap()
PPM2.MaterialSoundEntry('squeakywood', MAT_WOOD, 11, 0, 7)

if CLIENT
	net.receive 'ppm2_workaround_emitsound', ->
		return if DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool()
		ply, sound, level, volume = net.ReadPlayer(), SOUND_STRINGS_POOL_INV[net.ReadUInt8()], net.ReadUInt8(), net.ReadUInt8() / 100
		return if not IsValid(ply)
		ply\EmitSound(sound, level, 100, volume)

hook.Add 'PlayerFootstep', 'PPM2.Hoofstep', (pos, foot, sound, volume, filter) =>
	return if RECALL
	return if CLIENT and game.SinglePlayer()
	return if not @IsPonyCached() or DISABLE_HOOFSTEP_SOUND_CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool() or DISABLE_HOOFSTEP_SOUND\GetBool()
	return if @__ppm2_walkc
	return PPM2.PlayerFootstepsListener(@)\PlayerFootstep(@)

LEmitSoundRecall = (sound, level, volume, levelIfOnServer = level, side) =>
	return if not @IsValid()
	filter = LEmitSound(@, sound, level, volume, levelIfOnServer)
	RecallPlayerFootstep(@, PPM2.PlayerFootstepsListener\GetPosForSide(side, @), side, sound, volume, filter)
	return filter

ProcessFalldownEvents = (cmd) =>
	return if not @IsPonyCached()
	return if DISABLE_HOOFSTEP_SOUND_CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool() or DISABLE_HOOFSTEP_SOUND\GetBool()

	if @GetMoveType() ~= MOVETYPE_WALK
		@__ppm2_jump = false
		return

	self2 = @GetTable()
	ground = @OnGround()
	jump = cmd\KeyDown(IN_JUMP)

	modifier = 1
	disableFalldown = false
	disableJumpSound = false
	disableHoofsteps = false
	disableWalkSounds = false

	if data = @GetPonyData()
		modifier = data\GetHoofstepVolume()
		disableFalldown = data\GetDisableFalldownSound()
		disableJumpSound = data\GetDisableJumpSound()
		disableHoofsteps = data\GetDisableHoofsteps()
		disableWalkSounds = data\GetDisableStepSounds()

	if @__ppm2_jump and ground
		@__ppm2_jump = false

		tr = PPM2.PlayerFootstepsListener\TraceNow(@)
		entry = PPM2.MaterialSoundEntry\Ask(tr.MatType == 0 and MAT_DEFAULT or tr.MatType)

		if entry
			if sound = entry\GetLandSound()
				LEmitSound(@, sound, 60, modifier, 75) if not disableFalldown
			elseif not @__ppm2_walkc and not disableWalkSounds
				if sound = entry\GetWalkSound()
					LEmitSoundRecall(@, sound, 45, 0.2 * modifier, 55, 0)
					timer.Simple 0.04, -> LEmitSoundRecall(@, sound, 45, 0.3 * modifier, 55, 1)
					timer.Simple 0.07, -> LEmitSoundRecall(@, sound, 45, 0.3 * modifier, 55, 2)
					timer.Simple 0.1, -> LEmitSoundRecall(@, sound, 45, 0.3 * modifier, 55, 3)

			if not entry\ShouldPlayHoofclap()
				return

		if not disableFalldown
			filter = LEmitSound(@, 'player/ppm2/falldown.ogg', 60, 1, 75)
			for i = 0, 3
				timer.Simple i * 0.1, -> RecallPlayerFootstep(@, PPM2.PlayerFootstepsListener\GetPosForSide(i, @), i, 'player/ppm2/falldown.ogg', 1, filter) if @IsValid()
	elseif jump and not ground and not @__ppm2_jump
		@__ppm2_jump = true
		LEmitSound(@, 'player/ppm2/jump.ogg', 50, 1, 65) if not disableJumpSound

		tr = PPM2.PlayerFootstepsListener\TraceNow(@, true)
		entry = PPM2.MaterialSoundEntry\Ask(tr.MatType == 0 and MAT_DEFAULT or tr.MatType)

		if (not entry or entry\ShouldPlayHoofclap()) and not disableHoofsteps
			LEmitSoundRecall(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 0)
			timer.Simple 0.04, -> LEmitSoundRecall(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 1)
			timer.Simple 0.07, -> LEmitSoundRecall(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 2)
			timer.Simple 0.1, -> LEmitSoundRecall(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4 * modifier, 65, 3)

hook.Add 'StartCommand', 'PPM2.Hoofsteps', ProcessFalldownEvents
