
-- Copyright (C) 2017-2019 DBot

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

DISABLE_HOOFSTEP_SOUND_CLIENT = CreateConVar('ppm2_cl_no_hoofsound', '0', {FCVAR_ARCHIVE, FCVAR_USERINFO}, 'Disable hoofstep sound play time') if CLIENT
DISABLE_HOOFSTEP_SOUND = CreateConVar('ppm2_no_hoofsound', '0', {FCVAR_REPLICATED}, 'Disable hoofstep sound play time')

hook.Remove('PlayerStepSoundTime', 'PPM2.Hooks')
hook.Add 'PlayerStepSoundTime', 'PPM2.Hoofstep', (stepType = STEPSOUNDTIME_NORMAL, isWalking = false) =>
	return if not @IsPonyCached() or CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool() or DISABLE_HOOFSTEP_SOUND\GetBool()
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
SOUND_STRINGS_POOL_INV = {}
AddSoundString = (sound) ->
	nextid = #SOUND_STRINGS_POOL_INV + 1
	SOUND_STRINGS_POOL[sound] = nextid
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
AddSoundString('player/ppm2/jump.ogg')

LEmitSound = (ply, name, level = 75, volume = 1, levelIfOnServer = level) ->
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

class PPM2.PlayerFootstepsListener
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

		@lambdaEmitWander = ->
			return if not @ply\IsValid()
			return if not @onGround
			return if not @lastEntry
			sound = @lastEntry\GetWanderSound()
			return if not sound
			@EmitSound(sound, 50, 1, 70)

		@lambdaEmitWalk = ->
			return if not @ply\IsValid()
			return if not @onGround

			if not @lastEntry
				@EmitSound(@@RandHoof(), 50, 0.8, 65)
				return

			@EmitSound(@@RandHoof(), 50, 0.8, 65) if @lastEntry\ShouldPlayHoofclap()
			sound = @lastEntry\GetWalkSound()
			return if not sound
			@EmitSound(sound, 40, 0.8, 55)
			return true

		@lambdaEmitRun = ->
			return if not @ply\IsValid()
			return if not @onGround

			if not @lastEntry
				@EmitSound(@@RandHoof(), 60, 1, 70)
				return

			@EmitSound(@@RandHoof(), 60, 1, 70) if @lastEntry\ShouldPlayHoofclap()
			sound = @lastEntry\GetRunSound()
			return if not sound
			@EmitSound(sound, 40, 0.7, 60)
			return true

	IsValid: => @ply\IsValid() and not @playedWanderSound

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
	return if CLIENT and game.SinglePlayer()
	return if not @IsPonyCached() or CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool() or DISABLE_HOOFSTEP_SOUND\GetBool()
	return if @__ppm2_walkc
	return PPM2.PlayerFootstepsListener(@)\PlayerFootstep(@)

ProcessFalldownEvents = (cmd) =>
	return if not @IsPonyCached()
	return if CLIENT and DISABLE_HOOFSTEP_SOUND_CLIENT\GetBool() or DISABLE_HOOFSTEP_SOUND\GetBool()

	if @GetMoveType() ~= MOVETYPE_WALK
		@__ppm2_jump = false
		return

	self2 = @GetTable()
	ground = @OnGround()
	jump = cmd\KeyDown(IN_JUMP)

	if @__ppm2_jump and ground
		@__ppm2_jump = false

		tr = PPM2.PlayerFootstepsListener\TraceNow(@)
		entry = PPM2.MaterialSoundEntry\Ask(tr.MatType == 0 and MAT_DEFAULT or tr.MatType)

		if entry
			if sound = entry\GetLandSound()
				LEmitSound(@, sound, 60, 1, 75)
			elseif not @__ppm2_walkc
				if sound = entry\GetWalkSound()
					LEmitSound(@, sound, 45, 0.2, 55)
					timer.Simple 0.04, -> LEmitSound(@, entry\GetWalkSound(), 45, 0.2, 55)
					timer.Simple 0.07, -> LEmitSound(@, entry\GetWalkSound(), 45, 0.2, 55)
					timer.Simple 0.1, -> LEmitSound(@, entry\GetWalkSound(), 45, 0.2, 55)

			if not entry\ShouldPlayHoofclap()
				return

		LEmitSound(@, 'player/ppm2/falldown.ogg', 60, 1, 75)
	elseif jump and not ground and not @__ppm2_jump
		@__ppm2_jump = true
		LEmitSound(@, 'player/ppm2/jump.ogg', 50, 1, 65)

		tr = PPM2.PlayerFootstepsListener\TraceNow(@, true)
		entry = PPM2.MaterialSoundEntry\Ask(tr.MatType == 0 and MAT_DEFAULT or tr.MatType)

		if not entry or entry\ShouldPlayHoofclap()
			LEmitSound(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4, 65)
			timer.Simple 0.04, -> LEmitSound(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4, 65)
			timer.Simple 0.07, -> LEmitSound(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4, 65)
			timer.Simple 0.1, -> LEmitSound(@, PPM2.PlayerFootstepsListener.RandHoof(), 55, 0.4, 65)

hook.Add 'StartCommand', 'PPM2.Hoofsteps', ProcessFalldownEvents
