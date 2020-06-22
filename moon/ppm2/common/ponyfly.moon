
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
		@lastVelocity = Vector(0, 0, 0)
		@lastState = false

	GetEntity: => @controller\GetEntity()
	GetData: => @controller
	GetController: => @controller

	Switch: (status = false) =>
		return if not IsValid(@GetEntity()) or not @GetEntity()\IsPlayer()
		return if @lastState == status
		@lastState = status
		if not status
			{:p, :y, :r} = @GetEntity()\EyeAngles()
			newAng = Angle(p, y, 0)
			@GetEntity()\SetEyeAngles(newAng)
			@GetEntity()\SetMoveType(MOVETYPE_WALK)
			@roll = 0
			@pitch = 0
			@yaw = 0
			@GetEntity()\SetVelocity(@lastVelocity * 50)
			@lastVelocity = Vector(0, 0, 0)
		else
			@lastVelocity = Vector(0, 0, 0)
			@GetEntity()\SetVelocity(-@GetEntity()\GetVelocity() * .97)
			@GetEntity()\SetMoveType(MOVETYPE_CUSTOM)
			@obbCenter = @GetEntity()\OBBCenter()
			@obbMins = @GetEntity()\OBBMins()
			@obbMaxs = @GetEntity()\OBBMaxs()
			@roll = 0
			@pitch = 0
			@yaw = 0
	Think: (movedata) =>
		pos     = movedata\GetOrigin()
		ang     = movedata\GetAngles()
		fwd     = ang\Forward()
		bcwd    = -ang\Forward()
		right   = ang\Right()
		left    = -ang\Right()
		up      = ang\Up()
		down    = -ang\Up()
		W       = movedata\KeyDown(IN_FORWARD)
		S       = movedata\KeyDown(IN_BACK)
		D       = movedata\KeyDown(IN_MOVERIGHT)
		A       = movedata\KeyDown(IN_MOVELEFT)
		CTRL    = movedata\KeyDown(IN_DUCK)
		MULT    = FrameTime() * 66

		velocity = movedata\GetVelocity()
		cSpeed = velocity\Length()
		cSpeed = 1 if cSpeed < 1
		dragSqrt = math.min(math.sqrt(cSpeed) / cSpeed * 2, 0.99)
		cSpeedMult = @speedMultDiv / cSpeed
		cSpeedMult = @speedMultDiv if cSpeedMult ~= cSpeedMult
		cSpeedLiftMult = @speedMultLift / cSpeed
		cSpeedLiftMult = @speedMultLift if cSpeedLiftMult ~= cSpeedLiftMult

		dragCalc = math.Clamp(@dragMult / dragSqrt, 0, 0.99)
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
			lerpMult = FrameTime() * @angleLerp
			{:p, :y, :r} = ang
			p -= @pitch
			y -= @yaw
			@pitch = Lerp(lerpMult, @pitch, pitch)
			@yaw = Lerp(lerpMult, @yaw, yaw)
			@roll = Lerp(lerpMult, @roll, roll)
			p += @pitch
			y += @yaw
			r = @roll + math.sin(RealTimeL()) * 2
			newAng = Angle(p, y, r)
			@GetEntity()\SetEyeAngles(newAng)

		if not hit
			velocity.x *= dragCalc
			velocity.y *= dragCalc

		if not hitLift
			velocity.z *= dragCalc
			velocity.z += math.sin(RealTimeL() * 2) * .01

		pos += velocity

		movedata\SetVelocity(velocity)
		movedata\SetOrigin(pos)
		return true

	SetupMove: (movedata, cmd) =>
		@isLiftingUp = movedata\KeyDown(IN_JUMP)
		if @isLiftingUp
			movedata\SetButtons(movedata\GetButtons() - IN_JUMP)
		cmd\SetButtons(cmd\GetButtons() - IN_JUMP) if cmd\KeyDown(IN_JUMP)

	FinishMove: (movedata) =>
		nativeEntity = @GetEntity()
		mvPos = movedata\GetOrigin()
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

		velocity = movedata\GetVelocity()
		newVelocity = velocity
		length = velocity\Length()

		if not tryMove.Hit
			nativeEntity\SetPos(mvPos)
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
		@lastVelocity = newVelocity

PPM2.PonyflyController = PonyflyController

import IsPonyCached, GetPonyData, GetTable, SetIK, IsNewPonyCached from FindMetaTable('Entity')
import AnimRestartGesture, AnimResetGestureSlot from FindMetaTable('Player')

hook.Add 'SetupMove', 'PPM2.Ponyfly', (movedata, cmd) =>
	return if not IsPonyCached(@)
	data = GetPonyData(@)
	return if not data or not data\GetFly()
	flight = data\GetFlightController()
	return if not flight
	return flight\SetupMove(movedata, cmd)

hook.Add 'Move', 'PPM2.Ponyfly', (movedata) =>
	return if not IsPonyCached(@)
	data = GetPonyData(@)
	return if not data or not data\GetFly()
	flight = data\GetFlightController()
	return if not flight
	return flight\Think(movedata)

hook.Add 'FinishMove', 'PPM2.Ponyfly', (movedata) =>
	return if not IsPonyCached(@)
	data = GetPonyData(@)
	return if not data or not data\GetFly()
	flight = data\GetFlightController()
	return if not flight
	return flight\FinishMove(movedata)

hook.Add 'CalcMainActivity', 'PPM2.Ponyfly', (movedata) =>
	return if not IsNewPonyCached(@)
	if data = GetPonyData(@)
		if data\GetFly()
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

if SERVER
	concommand.Add 'ppm2_fly', =>
		return if not ALLOW_FLIGHT\GetBool()
		return if not IsValid(@)
		return if not @IsPonyCached()
		data = @GetPonyData()
		return if not data
		if data\GetFly()
			return data\SetFly(false) if FORCE_ALLOW_FLIGHT\GetBool()
			can = hook.Run('PlayerNoClip', @, false) or hook.Run('PPM2Fly', @, false)
			data\SetFly(false) if can
		else
			return if @GetPonyRaceFlags()\band(PPM2.RACE_HAS_WINGS) == 0
			return data\SetFly(true) if FORCE_ALLOW_FLIGHT\GetBool()
			can = hook.Run('PlayerNoClip', @, true) or hook.Run('PPM2Fly', @, true)
			data\SetFly(true) if can
else
	lastDouble = 0
	lastMessage = 0
	lastMessage2 = 0
	FLIGHT_BIND = CreateConVar('ppm2_flight_djump', '1', {FCVAR_ARCHIVE}, 'Double press of Jump activates flight')

	hook.Add 'PlayerBindPress', 'PPM2.Ponyfly', (bind = '', pressed = false) =>
		return if not ALLOW_FLIGHT\GetBool()
		return if not FLIGHT_BIND\GetBool()
		return if not pressed
		return if bind ~= '+jump' and bind ~= 'jump'
		if lastDouble > RealTimeL()
			return if not @IsPonyCached()
			data = @GetPonyData()
			return if not data

			if @GetPonyRaceFlags()\band(PPM2.RACE_HAS_WINGS) == 0
				if lastMessage < RealTimeL()
					lastMessage = RealTimeL() + 1
					PPM2.LChatPrint('info.ppm2.fly.pegasus')
				return

			if not FORCE_ALLOW_FLIGHT\GetBool() and not SUPPRESS_CLIENTSIDE_CHECK\GetBool()
				can = hook.Run('PlayerNoClip', @, not data\GetFly()) or hook.Run('PPM2Fly', @, not data\GetFly())
				if not can
					if lastMessage2 < RealTimeL()
						lastMessage2 = RealTimeL() + 1
						PPM2.LChatPrint('info.ppm2.fly.cannot', data\GetFly() and 'land' or 'fly')
					return

			RunConsoleCommand('ppm2_fly')
			lastDouble = 0
			return
		lastDouble = RealTimeL() + 0.2
