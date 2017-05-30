
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

ALLOW_FLIGHT = CreateConVar('ppm2_sv_flight', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Allow flight for pegasus and alicorns. It obeys PlayerNoClip hook.')
FORCE_ALLOW_FLIGHT = CreateConVar('ppm2_sv_flight_force', '0', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Ignore PlayerNoClip hook')
FLIGHT_DAMAGE = CreateConVar('ppm2_sv_flightdmg', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Damage players in flight')

class PonyflyController
    new: (data) =>
        @controller = data
        @ent = data.ent
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
    
    GetEntity: => @ent
    GetData: => @controller
    GetController: => @controller

    Switch: (status = false) =>
        @ent = @controller.ent
        return if not IsValid(@ent)
        return if @lastState == status
        @lastState = status
        if not status
            {:p, :y, :r} = @ent\EyeAngles()
            newAng = Angle(p, y, 0)
            @ent\SetEyeAngles(newAng)
            @ent\SetMoveType(MOVETYPE_WALK)
            @roll = 0
            @pitch = 0
            @yaw = 0
            @ent\SetVelocity(@lastVelocity * 50)
            @lastVelocity = Vector(0, 0, 0)
        else
            @lastVelocity = Vector(0, 0, 0)
            @ent\SetVelocity(-@ent\GetVelocity() * .97)
            @ent\SetMoveType(MOVETYPE_CUSTOM)
            @obbCenter = @ent\OBBCenter()
            @obbMins = @ent\OBBMins()
            @obbMaxs = @ent\OBBMaxs()
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
            r = @roll + math.sin(RealTime()) * 2
            newAng = Angle(p, y, r)
            @ent\SetEyeAngles(newAng)

        if not hit
            velocity.x *= dragCalc
            velocity.y *= dragCalc

        if not hitLift
            velocity.z *= dragCalc
            velocity.z += math.sin(RealTime() * 2) * .01

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
        mvPos = movedata\GetOrigin()
        pos = @ent\GetPos()
        rpos = pos
        tryMove = util.TraceHull({
            filter: (ent) ->
                return false if @ent == ent
                return true if not IsValid(ent)
                collision = ent\GetCollisionGroup()
                return false if collision == COLLISION_GROUP_WORLD
                return false if collision == COLLISION_GROUP_DEBRIS
                return false if collision == COLLISION_GROUP_DEBRIS_TRIGGER
                return false if collision == COLLISION_GROUP_WEAPON
                return false if collision == COLLISION_GROUP_PASSABLE_DOOR
                return true
            mins: @obbMins
            maxs: @obbMaxs
            start: rpos
            endpos: mvPos
        })

        velocity = movedata\GetVelocity()
        newVelocity = velocity
        length = velocity\Length()

        if not tryMove.Hit
            @ent\SetPos(mvPos)
        else
            if IsValid(tryMove.Entity)
                newVelocity = Vector(0, 0, 0)
                movedata\SetVelocity(newVelocity)
                newPos = tryMove.HitPos + tryMove.HitNormal
                @ent\SetPos(newPos)
                movedata\SetOrigin(newPos)
            else
                newVelocity = velocity - tryMove.HitNormal * velocity\Dot(tryMove.HitNormal * 1.1)
                movedata\SetVelocity(newVelocity)
                newPos = tryMove.HitPos + tryMove.HitNormal
                @ent\SetPos(newPos)
                movedata\SetOrigin(newPos)
            if length > 7 and SERVER and FLIGHT_DAMAGE\GetBool()
                dmgInfo = DamageInfo()
                dmgInfo\SetAttacker(@ent)
                dmgInfo\SetInflictor(@ent)
                dmgInfo\SetDamageType(DMG_CRUSH)
                calcDamage = math.Clamp((length / 4) ^ 2, 1, 100)
                if calcDamage >= 100
                    @ent\EmitSound('physics/flesh/flesh_bloody_break.wav', 100)
                elseif calcDamage > 70
                    @ent\EmitSound('physics/flesh/flesh_bloody_break.wav', 100)
                elseif calcDamage > 50
                    @ent\EmitSound("physics/body/body_medium_break#{math.random(2, 4)}.wav", 75)
                elseif calcDamage > 25
                    @ent\EmitSound("physics/body/body_medium_impact_hard#{math.random(1, 6)}.wav", 75)
                elseif calcDamage > 10
                    @ent\EmitSound("physics/body/body_medium_impact_soft#{math.random(1, 7)}.wav", 75)
                else
                    @ent\EmitSound("physics/flesh/flesh_impact_bullet#{math.random(1, 5)}.wav", 75)
                dmgInfo\SetDamage(calcDamage)
                @ent\TakeDamageInfo(dmgInfo)
        @lastVelocity = newVelocity

PPM2.PonyflyController = PonyflyController

hook.Add 'SetupMove', 'PPM2.Ponyfly', (movedata, cmd) =>
    return if not @IsPonyCached()
    data = @GetPonyData()
    return if not data
    return if not data\GetFly()
    flight = data\GetFlightController()
    return if not flight
    return flight\SetupMove(movedata, cmd)

hook.Add 'Move', 'PPM2.Ponyfly', (movedata) =>
    return if not @IsPonyCached()
    data = @GetPonyData()
    return if not data
    return if not data\GetFly()
    flight = data\GetFlightController()
    return if not flight
    return flight\Think(movedata)

hook.Add 'FinishMove', 'PPM2.Ponyfly', (movedata) =>
    return if not @IsPonyCached()
    data = @GetPonyData()
    return if not data
    return if not data\GetFly()
    flight = data\GetFlightController()
    return if not flight
    return flight\FinishMove(movedata)

hook.Add 'CalcMainActivity', 'PPM2.Ponyfly', (movedata) =>
    return if not @IsPonyCached()
    data = @GetPonyData()
    return if not data
    return if not data\GetFly()
    return ACT_SWIM, 370

if SERVER
    concommand.Add 'ppm2_fly', =>
        return if not ALLOW_FLIGHT\GetBool()
        return if not IsValid(@)
        return if not @IsPonyCached()
        data = @GetPonyData()
        return if not data
        if data\GetFly()
            return data\SetFly(false) if FORCE_ALLOW_FLIGHT\GetBool()
            can = hook.Run('PlayerNoClip', @, false)
            data\SetFly(false) if can ~= false
        else
            return if data\GetRace() ~= PPM2.RACE_PEGASUS and data\GetRace() ~= PPM2.RACE_ALICORN
            return data\SetFly(true) if FORCE_ALLOW_FLIGHT\GetBool()
            can = hook.Run('PlayerNoClip', @, true)
            data\SetFly(true) if can ~= false
else
    lastDouble = 0
    lastMessage = 0
    lastMessage2 = 0
    hook.Add 'PlayerBindPress', 'PPM2.Ponyfly', (bind = '', pressed = false) =>
        return if not ALLOW_FLIGHT\GetBool()
        return if not pressed
        return if bind ~= '+jump' and bind ~= 'jump'
        if lastDouble > RealTime()
            return if not @IsPonyCached()
            data = @GetPonyData()
            return if not data
            if data\GetRace() ~= PPM2.RACE_PEGASUS and data\GetRace() ~= PPM2.RACE_ALICORN
                if lastMessage < RealTime()
                    lastMessage = RealTime() + 1
                    PPM2.ChatPrint('You need to be a Pegasus or an Alicorn to fly!')
                return
            can = hook.Run('PlayerNoClip', @, not data\GetFly())
            if can == false
                if lastMessage2 < RealTime()
                    lastMessage2 = RealTime() + 1
                    PPM2.ChatPrint("You can not #{data\GetFly() and 'land' or 'fly'} right now.")
                return
            RunConsoleCommand('ppm2_fly')
            lastDouble = 0
            return
        lastDouble = RealTime() + 0.2
