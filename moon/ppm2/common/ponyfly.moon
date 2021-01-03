
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

PPM2.FLIGHT_IMPULSE = 188
vector_origin = Vector()

ALLOW_FLIGHT = CreateConVar('ppm2_sv_flight', '1', {FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow flight for pegasus and alicorns. It obeys PlayerNoClip hook.')
FORCE_ALLOW_FLIGHT = CreateConVar('ppm2_sv_flight_force', '0', {FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Ignore PlayerNoClip hook')
SUPPRESS_CLIENTSIDE_CHECK = CreateConVar('ppm2_sv_flight_nocheck', '0', {FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Suppress PlayerNoClip clientside check (useful with bad coded addons. known are - ULX, Cinema, FAdmin)')
FLIGHT_DAMAGE = CreateConVar('ppm2_sv_flightdmg', '1', {FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Damage players in flight')

class PonyflyController
	new: (controller) =>
		@controller = controller
		@speedMult = 0.5
		@speedMultDirections = 1.25
		@dragMult = 0.95
		@obbCenter = Vector(0, 0, 0)
		@obbMins = Vector(0, 0, 0)
		@obbMaxs = Vector(0, 0, 0)
		@speedMultDiv = 2
		@speedMultLift = 2
		@pitch = 0
		@yaw = 0
		@roll = 0
		@angleLerp = 1

	GetEntity: => @controller\GetEntity()
	GetData: => @controller
	GetController: => @controller

	Switch: (status = false, movedata) =>
		ply = @GetEntity()
		return if not IsValid(ply) or not ply\IsPlayer()

		if not status
			{:p, :y, :r} = ply\EyeAngles()
			newAng = Angle(p, y, 0)
			ply\SetEyeAngles(newAng)
			ply\SetMoveType(MOVETYPE_WALK)
			@roll = 0
			@pitch = 0
			@yaw = 0

			movedata\SetVelocity(ply\GetNW2Vector('ppm2_fly_last_vel') * 50) if movedata
			ply\SetNW2Vector('ppm2_fly_last_vel', vector_origin)
		else
			ply\SetNW2Vector('ppm2_fly_last_vel', vector_origin)
			ply\SetNW2Vector('ppm2_fly_init_vel', ply\GetVelocity() * 0.01)
			ply\SetNW2Bool('ppm2_fly_init', true)
			ply\SetMoveType(MOVETYPE_CUSTOM)
			@obbCenter = ply\OBBCenter()
			@obbMins = ply\OBBMins()
			@obbMaxs = ply\OBBMaxs()
			@roll = 0
			@pitch = 0
			@yaw = 0

	Think: (movedata, ply) =>
		ang     = movedata\GetAngles()
		fwd     = ang\Forward()
		bcwd    = -fwd
		right   = ang\Right()
		left    = -right
		up      = ang\Up()
		down    = -up
		W       = movedata\KeyDown(IN_FORWARD)
		S       = movedata\KeyDown(IN_BACK)
		D       = movedata\KeyDown(IN_MOVERIGHT)
		A       = movedata\KeyDown(IN_MOVELEFT)
		CTRL    = movedata\KeyDown(IN_DUCK)
		MULT    = FrameTime() * 66

		velocity = movedata\GetVelocity()

		if ply\GetNW2Bool('ppm2_fly_init')
			ply\SetNW2Bool('ppm2_fly_init', false)
			velocity = ply\GetNW2Vector('ppm2_fly_init_vel')

		cSpeed = velocity\Length()
		cSpeed = 1 if cSpeed < 1
		dragSqrt = math.min(math.sqrt(cSpeed) / cSpeed * 2, 0.99)
		cSpeedMult = @speedMultDiv / cSpeed
		cSpeedMult = @speedMultDiv if cSpeedMult ~= cSpeedMult
		cSpeedLiftMult = @speedMultLift / cSpeed
		cSpeedLiftMult = @speedMultLift if cSpeedLiftMult ~= cSpeedLiftMult

		dragCalc = math.clamp(@dragMult / dragSqrt, 0, 0.99)
		pitch = 0
		yaw = 0
		roll = 0

		hit = false
		hitLift = false

		if W
			velocity += fwd * MULT * @speedMult * cSpeedMult * @speedMultDirections
			hit = true
			pitch += 20

		if S
			velocity += bcwd * MULT * @speedMult * cSpeedMult * @speedMultDirections
			hit = true
			pitch -= 20

		if A
			velocity += left * MULT * @speedMult * cSpeedMult * @speedMultDirections
			hit = true
			roll -= 20

		if D
			velocity += right * MULT * @speedMult * cSpeedMult * @speedMultDirections
			hit = true
			roll += 20

		if CTRL
			velocity += Vector(0, 0, -MULT * @speedMult * cSpeedLiftMult)
			hitLift = true

		if @isLiftingUp
			velocity += Vector(0, 0, MULT * @speedMult * cSpeedLiftMult)
			hitLift = true

		if CLIENT
			lerpMult = game.GetTimeScale() * engine.TickInterval() * @angleLerp
			{:p, :y, :r} = ang
			p -= @pitch
			y -= @yaw
			@pitch = Lerp(lerpMult, @pitch, pitch)
			@yaw = Lerp(lerpMult, @yaw, yaw)
			@roll = Lerp(lerpMult, @roll, roll)
			p += @pitch
			y += @yaw
			r = @roll + math.sin(CurTime()) * 2
			newAng = Angle(p, y, r)
			ply\SetEyeAngles(newAng)

		if not hit
			velocity.x *= dragCalc
			velocity.y *= dragCalc

		if not hitLift
			velocity.z *= dragCalc
			velocity.z += math.sin(CurTime() * 2) * .01

		movedata\SetVelocity(velocity)

	SetupMove: (movedata, cmd) =>
		@isLiftingUp = movedata\KeyDown(IN_JUMP)
		if @isLiftingUp
			movedata\SetButtons(movedata\GetButtons() - IN_JUMP)
		cmd\SetButtons(cmd\GetButtons() - IN_JUMP) if cmd\KeyDown(IN_JUMP)

	FinishMove: (movedata, nativeEntity) =>
		velocity = movedata\GetVelocity()
		mvPos = movedata\GetOrigin() + velocity
		pos = nativeEntity\GetPos()
		rpos = pos
		tryMove = util.TraceHull({
			filter: (ent) ->
				return false if nativeEntity == ent
				return true if not IsValid(ent)
				collision = ent\GetCollisionGroup()
				return collision ~= COLLISION_GROUP_WORLD and
					collision ~= COLLISION_GROUP_DEBRIS_TRIGGER and
					collision ~= COLLISION_GROUP_WEAPON and
					collision ~= COLLISION_GROUP_PASSABLE_DOOR and
					collision ~= COLLISION_GROUP_DEBRIS and
					ent\GetOwner() ~= nativeEntity and
					ent\GetParent() ~= nativeEntity and
					ent\IsSolid()
			mins: @obbMins
			maxs: @obbMaxs
			start: rpos
			endpos: mvPos
		})

		newVelocity = velocity
		length = velocity\Length()

		if not tryMove.Hit
			nativeEntity\SetPos(mvPos)
			movedata\SetOrigin(mvPos)
		else
			if IsValid(tryMove.Entity)
				newVelocity = Vector(0, 0, 0)
				movedata\SetVelocity(newVelocity)
				newPos = tryMove.HitPos + tryMove.HitNormal
				nativeEntity\SetPos(newPos)
				movedata\SetOrigin(newPos)
			else
				newVelocity = velocity - tryMove.HitNormal * velocity\Dot(tryMove.HitNormal * 1.1)
				movedata\SetVelocity(newVelocity)
				newPos = tryMove.HitPos + tryMove.HitNormal
				nativeEntity\SetPos(newPos)
				movedata\SetOrigin(newPos)
			if length > 7 and SERVER and FLIGHT_DAMAGE\GetBool()
				dmgInfo = DamageInfo()
				dmgInfo\SetAttacker(nativeEntity)
				dmgInfo\SetInflictor(nativeEntity)
				dmgInfo\SetDamageType(DMG_CRUSH)
				calcDamage = math.Clamp((length / 4) ^ 2, 1, 100)
				if calcDamage >= 100
					nativeEntity\EmitSound('physics/flesh/flesh_bloody_break.wav', 100)
				elseif calcDamage > 70
					nativeEntity\EmitSound('physics/flesh/flesh_bloody_break.wav', 100)
				elseif calcDamage > 50
					nativeEntity\EmitSound("physics/body/body_medium_break#{math.random(2, 4)}.wav", 75)
				elseif calcDamage > 25
					nativeEntity\EmitSound("physics/body/body_medium_impact_hard#{math.random(1, 6)}.wav", 75)
				elseif calcDamage > 10
					nativeEntity\EmitSound("physics/body/body_medium_impact_soft#{math.random(1, 7)}.wav", 75)
				else
					nativeEntity\EmitSound("physics/flesh/flesh_impact_bullet#{math.random(1, 5)}.wav", 75)
				dmgInfo\SetDamage(calcDamage)
				nativeEntity\TakeDamageInfo(dmgInfo)

		nativeEntity\SetNW2Vector('ppm2_fly_last_vel', velocity)

PPM2.PonyflyController = PonyflyController

import IsPonyCached, GetPonyData, GetTable, SetIK, IsNewPonyCached from FindMetaTable('Entity')
import AnimRestartGesture, AnimResetGestureSlot from FindMetaTable('Player')

SwitchFlight = (data, flyController, movedata) =>
	if @GetNW2Bool('ppm2_fly')
		if FORCE_ALLOW_FLIGHT\GetBool() or hook.Run('PlayerNoClip', @, false) or hook.Run('PPM2Fly', @, false)
			@SetNW2Bool('ppm2_fly', false)
			flyController\Switch(false, movedata)

		return

	return if @GetPonyRaceFlags()\band(PPM2.RACE_HAS_WINGS) == 0

	if FORCE_ALLOW_FLIGHT\GetBool() or hook.Run('PlayerNoClip', @, true) or hook.Run('PPM2Fly', @, true)
		@SetNW2Bool('ppm2_fly', true)
		flyController\Switch(true)

hook.Add 'SetupMove', 'PPM2.Ponyfly', (movedata, cmd) =>
	return if not ALLOW_FLIGHT\GetBool()
	return if not IsPonyCached(@)
	return if not @IsPonyCached()
	data = @GetPonyData()
	return if not data
	flight = data\GetFlightController()
	return if not flight

	if @GetMoveType() ~= MOVETYPE_CUSTOM and @GetNW2Bool('ppm2_fly')
		@SetNW2Bool('ppm2_fly', false)
		flight\Switch(false)

	SwitchFlight(@, data, flight, movedata) if cmd\GetImpulse() == PPM2.FLIGHT_IMPULSE
	return flight\SetupMove(movedata, cmd) if @GetNW2Bool('ppm2_fly')

hook.Add 'Move', 'PPM2.Ponyfly', (movedata) =>
	return if not @GetNW2Bool('ppm2_fly')
	return if not IsPonyCached(@)
	data = GetPonyData(@)
	return if not data
	flight = data\GetFlightController()
	return if not flight
	return flight\Think(movedata, @)

hook.Add 'FinishMove', 'PPM2.Ponyfly', (movedata) =>
	return if not @GetNW2Bool('ppm2_fly')
	return if not IsPonyCached(@)
	data = GetPonyData(@)
	return if not data
	flight = data\GetFlightController()
	return if not flight
	return flight\FinishMove(movedata, @)

hook.Add 'CalcMainActivity', 'PPM2.Ponyfly', (movedata) =>
	return if not IsNewPonyCached(@)

	if @GetNW2Bool('ppm2_fly')
		if not @isPlayingPPM2Anim
			@isPlayingPPM2Anim = true
			AnimRestartGesture(@, GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false)
			SetIK(@, false) if CLIENT

		return ACT_GMOD_NOCLIP_LAYER, 370
	else
		if @isPlayingPPM2Anim
			@isPlayingPPM2Anim = false
			AnimResetGestureSlot(@, GESTURE_SLOT_CUSTOM)
			SetIK(@, true) if CLIENT

if CLIENT
	concommand.Add 'ppm2_fly', -> RunConsoleCommand('impulse', tostring(PPM2.FLIGHT_IMPULSE))

	lastDouble = 0
	lastMessage = 0
	lastMessage2 = 0
	FLIGHT_BIND = CreateConVar('ppm2_flight_djump', '1', {FCVAR_ARCHIVE}, 'Double press of Jump activates flight')

	hook.Add 'PlayerBindPress', 'PPM2.Ponyfly', (bind = '', pressed = false) =>
		return if not ALLOW_FLIGHT\GetBool()
		return if not FLIGHT_BIND\GetBool()
		return if not pressed
		return if bind ~= '+jump' and bind ~= 'jump'

		_lastDouble = lastDouble
		lastDouble = RealTimeL() + 0.2

		return if _lastDouble <= RealTimeL()
		return if not @IsPonyCached()
		data = @GetPonyData()
		return if not data

		if @GetPonyRaceFlags()\band(PPM2.RACE_HAS_WINGS) == 0
			if lastMessage < RealTimeL()
				lastMessage = RealTimeL() + 1
				PPM2.LChatPrint('info.ppm2.fly.pegasus')

			return

		if not FORCE_ALLOW_FLIGHT\GetBool() and not SUPPRESS_CLIENTSIDE_CHECK\GetBool()
			can = hook.Run('PlayerNoClip', @, not @GetNW2Bool('ppm2_fly')) or hook.Run('PPM2Fly', @, not @GetNW2Bool('ppm2_fly'))

			if not can
				if lastMessage2 < RealTimeL()
					lastMessage2 = RealTimeL() + 1
					PPM2.LChatPrint('info.ppm2.fly.cannot', @GetNW2Bool('ppm2_fly') and 'land' or 'fly')

				return

		RunConsoleCommand('impulse', tostring(PPM2.FLIGHT_IMPULSE))
		lastDouble = 0

