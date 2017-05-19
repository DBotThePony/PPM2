
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

class PonyRenderController
    @AVALIABLE_CONTROLLERS = {}
    @MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}
    @__inherited: (child) =>
        child.MODELS_HASH = {mod, true for mod in *child.MODELS}
        @AVALIABLE_CONTROLLERS[mod] = child for mod in *child.MODELS
    @__inherited(@)

    CompileTextures: => @GetTextureController()\CompileTextures()
    new: (data) =>
        @networkedData = data
        @ent = data.ent
        @modelCached = data\GetModel()
        @IGNORE_DRAW = false
        @CompileTextures() if @ent
        @CreateLegs() if @ent == LocalPlayer()
        @socksModel = data\GetSocksModel()
        @CreateFlexController() if @ent
    GetEntity: => @ent
    GetData: => @networkedData
    GetModel: => @networkedData\GetModel()

    GetLegs: =>
        return NULL if @ent ~= LocalPlayer()
        @CreateLegs() if not IsValid()
        return @legsModel
    CreateLegs: =>
        return NULL if @ent ~= LocalPlayer()
        for ent in *ents.GetAll()
            if ent.isPonyLegsModel
                ent\Remove()
        @legsModel = ClientsideModel(@modelCached)
        with @legsModel
            .isPonyLegsModel = true
            \SetNoDraw(true)
            .__PPM2_PonyData = @GetData()
        
        @GetData()\GetWeightController()\UpdateWeight(@legsModel)

        @lastLegUpdate = CurTime()
        @legClipPlanePos = Vector(0, 0, 0)
        @legBGSetup = CurTime()
        @legUpdateFrame = 0
        @legClipDot = 0
        @duckOffsetHack = @@LEG_CLIP_OFFSET_STAND
        @legsClipPlane = @@LEG_CLIP_VECTOR
        return @legsModel
    
    @LEG_SHIFT_CONST = 24
    @LEG_SHIFT_CONST_VEHICLE = 14
    @LEG_Z_CONST = 0
    @LEG_Z_CONST_VEHICLE = 20
    @LEG_ANIM_SPEED_CONST = 1
    @LEG_CLIP_OFFSET_STAND = 28
    @LEG_CLIP_OFFSET_DUCK = 12
    @LEG_CLIP_OFFSET_VEHICLE = 11

    UpdateLegs: =>
        return unless IsValid(@legsModel)
        return if @legUpdateFrame == FrameNumber()
        @legUpdateFrame = FrameNumber()
        ctime = CurTime()
        ply = @ent
        seq = ply\GetSequence()

        if seq ~= @legSeq
            @legSeq = seq
            @legsModel\ResetSequence(seq)
        
        if @legBGSetup < ctime
            @legBGSetup = ctime + 1
            for group in *ply\GetBodyGroups()
                @legsModel\SetBodygroup(group.id, ply\GetBodygroup(group.id))
        
        with @legsModel
            \FrameAdvance(ctime - @lastLegUpdate)
            \SetPlaybackRate(@@LEG_ANIM_SPEED_CONST * ply\GetPlaybackRate())
            @lastLegUpdate = ctime
            \SetPoseParameter('move_x',       (ply\GetPoseParameter('move_x')     * 2) - 1)
            \SetPoseParameter('move_y',       (ply\GetPoseParameter('move_y')     * 2) - 1)
            \SetPoseParameter('move_yaw',     (ply\GetPoseParameter('move_yaw')   * 360) - 180)
            \SetPoseParameter('body_yaw',     (ply\GetPoseParameter('body_yaw')   * 180) - 90)
            \SetPoseParameter('spine_yaw',    (ply\GetPoseParameter('spine_yaw')  * 180) - 90)
        
        if ply\InVehicle()
            veh = ply\GetVehicle()
            vehAng = veh\GetAngles()
            eyepos = EyePos()
            vehAng\RotateAroundAxis(vehAng\Up(), 90)

            clipAng = Angle(vehAng.p, vehAng.y, vehAng.r)
            clipAng\RotateAroundAxis(clipAng\Right(), -90)

            @legsClipPlane = clipAng\Forward()
            @legsModel\SetRenderAngles(vehAng)

            legClipPlanePos = Vector(0, 0, @@LEG_CLIP_OFFSET_VEHICLE)
            legClipPlanePos\Rotate(vehAng)
            @legClipPlanePos = eyepos - legClipPlanePos
            
            drawPos = Vector(@@LEG_SHIFT_CONST_VEHICLE, 0, @@LEG_Z_CONST_VEHICLE)
            drawPos\Rotate(vehAng)
            @legsModel\SetRenderOrigin(eyepos - drawPos)
        else
            @legsClipPlane = @@LEG_CLIP_VECTOR
            eangles = EyeAngles()
            yaw = eangles.y - ply\GetPoseParameter('head_yaw') * 180 + 90
            newAng = Angle(0, yaw, 0)
            rad = math.rad(yaw)
            sin, cos = math.sin(rad), math.cos(rad)
            pos = ply\GetPos()
            {:x, :y, :z} = pos
            newPos = Vector(x - cos * @@LEG_SHIFT_CONST, y - sin * @@LEG_SHIFT_CONST, z + @@LEG_Z_CONST)
            if ply\Crouching()
                @duckOffsetHack = @@LEG_CLIP_OFFSET_DUCK
            else
                @duckOffsetHack = Lerp(0.1, @duckOffsetHack, @@LEG_CLIP_OFFSET_STAND)
            
            @legClipPlanePos = Vector(x, y, z + @duckOffsetHack)
            @legsModel\SetRenderAngles(newAng)
            @legsModel\SetRenderOrigin(newPos)
        @legClipDot = @legsClipPlane\Dot(@legClipPlanePos)
    
    @LEG_CLIP_VECTOR = Vector(0, 0, -1)
    DrawLegs: (start3D = true) =>
        @CreateLegs() unless IsValid(@legsModel)
        return unless IsValid(@legsModel)
        return if @ent\ShouldDrawLocalPlayer()
        @UpdateLegs()

        oldClip = render.EnableClipping(true)
        render.PushCustomClipPlane(@legsClipPlane, @legClipDot)
        cam.Start3D() if start3D

        @PreDraw()
        @legsModel\DrawModel()
        @PostDraw()

        render.PopCustomClipPlane()
        cam.End3D() if start3D
        render.EnableClipping(oldClip)
    
    PlayerRespawn: =>
        @flexes\PlayerRespawn() if @flexes

    PreDraw: (ent = @ent) =>
        return if @IGNORE_DRAW
        @GetTextureController()\PreDraw(ent)
        @flexes\Think() if @flexes
    PostDraw: (ent = @ent) =>
        return if @IGNORE_DRAW
        textures = @GetTextureController()
        textures\PostDraw(ent)

        @IGNORE_DRAW = true
        if @GetData()\IsNetworked()
            @socksModel = @ent\GetNWEntity('PPM2.SocksModel') if not IsValid(@socksModel)

        @socksModel = @GetData()\GetSocksModel() if not IsValid(@socksModel)

        if IsValid(@socksModel)
            @socksModel\SetNoDraw(true)
            textures\PreDrawSocks()
            @socksModel\DrawModel()
            textures\PostDrawSocks()
        @IGNORE_DRAW = false

    @ARMS_MATERIAL_INDEX = 0
    PreDrawArms: (ent) =>
        if ent and not @armsWeightSetup
            @armsWeightSetup = true
            weight = @GetData()\GetWeight()
            vec = Vector(weight, weight, weight)
            for i = 1, 13
                ent\ManipulateBoneScale(i, vec)
        render.MaterialOverrideByIndex(@@ARMS_MATERIAL_INDEX, @GetTextureController()\GetBody())
    PostDrawArms: (ent) =>
        render.MaterialOverrideByIndex(@@ARMS_MATERIAL_INDEX)

    DataChanges: (state) =>
        return if not @ent
        @GetTextureController()\DataChanges(state)
        @flexes\DataChanges(state) if @flexes
        switch state\GetKey()
            when 'Weight'
                @armsWeightSetup = false
                @GetData()\GetWeightController()\UpdateWeight(@legsModel) if IsValid(@legsModel)
            when 'SocksModel'
                @socksModel = @GetData()\GetSocksModel()
                @socksModel\SetNoDraw(true) if IsValid(@socksModel)
            when 'NoFlex'
                if state\GetValue()
                    @flexes\ResetSequences() if @flexes
                    @flexes = nil
                else
                    @CreateFlexController()
    GetTextureController: =>
        if not @renderController
            cls = PPM2.GetTextureController(@modelCached)
            @renderController = cls(@)
        @renderController.ent = @ent
        return @renderController
    CreateFlexController: =>
        return if not @ent\IsPlayer()
        return if @GetData()\GetNoFlex()
        if not @flexes
            cls = PPM2.GetFlexController(@modelCached)
            return if not cls
            @flexes = cls(@)
        @flexes.ent = @ent
        return @flexes
    GetFlexController: => @flexes

class NewPonyRenderController extends PonyRenderController
    @MODELS = {'models/ppm/player_default_base_new.mdl'}

    new: (data) =>
        @upperManeModel = data\GetUpperManeModel()
        @lowerManeModel = data\GetLowerManeModel()
        @tailModel = data\GetTailModel()
        @upperManeModel\SetNoDraw(true) if IsValid(@upperManeModel)
        @lowerManeModel\SetNoDraw(true) if IsValid(@lowerManeModel)
        @tailModel\SetNoDraw(true) if IsValid(@tailModel)
        super(data)
    
    DataChanges: (state) =>
        return if not @ent
        switch state\GetKey()
            when 'UpperManeModel'
                @upperManeModel = @GetData()\GetUpperManeModel()
                @upperManeModel\SetNoDraw(true) if IsValid(@upperManeModel)
            when 'LowerManeMode'
                @lowerManeModel = @GetData()\GetLowerManeModel()
                @lowerManeModel\SetNoDraw(true) if IsValid(@lowerManeModel)
            when 'TailModel'
                @tailModel = @GetData()\GetTailModel()
                @tailModel\SetNoDraw(true) if IsValid(@tailModel)
        super(state)

    PostDraw: (ent = @ent) =>
        return if @IGNORE_DRAW
        textures = @GetTextureController()
        @IGNORE_DRAW = true

        if @GetData()\IsNetworked()
            @upperManeModel = @ent\GetNWEntity('PPM2.UpperManeModel') if not IsValid(@upperManeModel)
            @lowerManeModel = @ent\GetNWEntity('PPM2.LowerManeModel') if not IsValid(@lowerManeModel)
            @tailModel = @ent\GetNWEntity('PPM2.TailModel') if not IsValid(@tailModel)

        @upperManeModel = @GetData()\GetUpperManeModel() if not IsValid(@upperManeModel)
        @lowerManeModel = @GetData()\GetLowerManeModel() if not IsValid(@lowerManeModel)
        @tailModel = @GetData()\GetTailModel() if not IsValid(@tailModel)

        if IsValid(@upperManeModel)
            @upperManeModel\SetNoDraw(true)
            textures\PreDrawUpperMane()
            @upperManeModel\DrawModel()
            textures\PostDrawUpperMane()

        if IsValid(@lowerManeModel)
            @lowerManeModel\SetNoDraw(true)
            textures\PreDrawLowerMane()
            @lowerManeModel\DrawModel()
            textures\PostDrawLowerMane()

        if IsValid(@tailModel)
            @tailModel\SetNoDraw(true)
            textures\PreDrawTail()
            @tailModel\DrawModel()
            textures\PostDrawTail()

        @IGNORE_DRAW = false
        super(ent)

PPM2.PonyRenderController = PonyRenderController
PPM2.NewPonyRenderController = NewPonyRenderController
PPM2.GetPonyRenderController = (model = 'models/ppm/player_default_base.mdl') -> PonyRenderController.AVALIABLE_CONTROLLERS[model\lower()] or PonyRenderController
PPM2.GetPonyRendererController = PPM2.GetPonyRenderController
PPM2.GetRenderController = PPM2.GetPonyRenderController
PPM2.GetRendererController = PPM2.GetPonyRenderController
