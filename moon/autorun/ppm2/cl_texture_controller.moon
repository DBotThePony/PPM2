
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

-- Texture indexes (-1)
-- 1    =   models/ppm/base/eye_l
-- 2    =   models/ppm/base/eye_r
-- 3    =   models/ppm/base/body
-- 4    =   models/ppm/base/horn
-- 5    =   models/ppm/base/wings
-- 6    =   models/ppm/base/hair_color_1
-- 7    =   models/ppm/base/hair_color_2
-- 8    =   models/ppm/base/tail_color_1
-- 9    =   models/ppm/base/tail_color_2
-- 10   =   models/ppm/base/cmark
-- 11   =   models/ppm/base/eyelashes

PPM2.BodyDetailsMaterials = {
    Material('models/ppm/partrender/body_leggrad1.png')
    Material('models/ppm/partrender/body_lines1.png')
    Material('models/ppm/partrender/body_stripes1.png')
    Material('models/ppm/partrender/body_headstripes1.png') 
    Material('models/ppm/partrender/body_freckles.png')
    Material('models/ppm/partrender/body_hooves1.png')
    Material('models/ppm/partrender/body_hooves2.png')
    Material('models/ppm/partrender/body_headmask1.png')
    Material('models/ppm/partrender/body_hooves1_crit.png')
    Material('models/ppm/partrender/body_hooves2_crit.png')
    Material('models/ppm/partrender/body_spots1.png')
}

PPM2.UpperManeDetailsMaterials = {
    [4]: {Material('models/ppm/partrender/upmane_5_mask0.png')}
    [5]: {Material('models/ppm/partrender/upmane_6_mask0.png')}
    [7]: {Material('models/ppm/partrender/upmane_8_mask0.png'), Material('models/ppm/partrender/upmane_8_mask1.png')}
    [8]: {Material('models/ppm/partrender/upmane_9_mask0.png'), Material('models/ppm/partrender/upmane_9_mask1.png'), Material('models/ppm/partrender/upmane_9_mask2.png')}
    [9]: {Material('models/ppm/partrender/upmane_10_mask0.png')}
    [10]: {Material('models/ppm/partrender/upmane_11_mask0.png'), Material('models/ppm/partrender/upmane_11_mask1.png'), Material('models/ppm/partrender/upmane_11_mask2.png')}
    [11]: {Material('models/ppm/partrender/upmane_12_mask0.png')}
    [12]: {Material('models/ppm/partrender/upmane_13_mask0.png')}
    [13]: {Material('models/ppm/partrender/upmane_14_mask0.png')}
    [14]: {Material('models/ppm/partrender/upmane_15_mask0.png')}
}

PPM2.DownManeDetailsMaterials = {
    [4]: {Material('models/ppm/partrender/dnmane_5_mask0.png')}
    [7]: {Material('models/ppm/partrender/dnmane_8_mask0.png'), Material('models/ppm/partrender/dnmane_8_mask1.png')}
    [8]: {Material('models/ppm/partrender/dnmane_9_mask0.png'), Material('models/ppm/partrender/dnmane_9_mask1.png')}
    [9]: {Material('models/ppm/partrender/dnmane_10_mask0.png'), Material('models/ppm/partrender/dnmane_10_mask1.png'), Material('models/ppm/partrender/dnmane_10_mask2.png')}
    [10]: {Material('models/ppm/partrender/dnmane_11_mask0.png'), Material('models/ppm/partrender/dnmane_11_mask1.png')}
    [11]: {Material('models/ppm/partrender/dnmane_12_mask0.png')}
}

PPM2.TailDetailsMaterials = {
    [4]: {Material('models/ppm/partrender/tail_5_mask0.png')}
    [7]: {Material('models/ppm/partrender/tail_8_mask0.png'), Material('models/ppm/partrender/tail_8_mask1.png'), Material('models/ppm/partrender/tail_8_mask2.png'), Material('models/ppm/partrender/tail_8_mask3.png'), Material('models/ppm/partrender/tail_8_mask4.png')}
    [9]: {Material('models/ppm/partrender/tail_10_mask0.png')}
    [10]: {Material('models/ppm/partrender/tail_11_mask0.png'), Material('models/ppm/partrender/tail_11_mask1.png'), Material('models/ppm/partrender/tail_11_mask2.png')}
    [11]: {Material('models/ppm/partrender/tail_12_mask0.png'), Material('models/ppm/partrender/tail_12_mask1.png')}
    [12]: {Material('models/ppm/partrender/tail_13_mask0.png')}
    [13]: {Material('models/ppm/partrender/tail_14_mask0.png')}
}

PPM2.DefaultCutiemarksMaterials = [Material("models/ppm/cmarks/#{mark}") for mark in *PPM2.DefaultCutiemarks]

PPM2.AvaliablePonySuitsMaterials = [Material("models/ppm/texclothes/#{mat}.png") for mat in *{'clothes_royalguard', 'clothes_sbs_full', 'clothes_sbs_light', 'clothes_wbs_full', 'clothes_wbs_light'}]
PPM2.ApplyMaterialData = (mat, matData) ->
    for k, v in pairs matData
        switch type(v)
            when 'string'
                mat\SetString(k, v)
            when 'number'
                mat\SetInt(k, v) if math.floor(v) == v
                mat\SetFloat(k, v) if math.floor(v) ~= v

class PonyTextureController
    @AVALIABLE_CONTROLLERS = {}
    @MODELS = {'models/ppm/player_default_base.mdl', 'models/ppm/player_default_base_nj.mdl', 'models/cppm/player_default_base.mdl', 'models/cppm/player_default_base_nj.mdl'}
    @__inherited: (child) =>
        child.MODELS_HASH = {mod, true for mod in *child.MODELS}
        @AVALIABLE_CONTROLLERS[mod] = child for mod in *child.MODELS
    @__inherited(@)

    @UPPER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs PPM2.UpperManeDetailsMaterials}
    @LOWER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs PPM2.DownManeDetailsMaterials}
    @TAIL_DETAIL_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs PPM2.TailDetailsMaterials}

    @MAT_INDEX_EYE_LEFT = 0
    @MAT_INDEX_EYE_RIGHT = 1
    @MAT_INDEX_BODY = 2
    @MAT_INDEX_HORN = 3
    @MAT_INDEX_WINGS = 4
    @MAT_INDEX_HAIR_COLOR1 = 5
    @MAT_INDEX_HAIR_COLOR2 = 6
    @MAT_INDEX_TAIL_COLOR1 = 7
    @MAT_INDEX_TAIL_COLOR2 = 8
    @MAT_INDEX_CMARK = 9
    @MAT_INDEX_EYELASHES = 10

    @BODY_MATERIAL_MALE = Material('models/ppm/base/render/bodym')
    @BODY_MATERIAL_FEMALE = Material('models/ppm/base/render/bodyf')

    @HAIR_MATERIAL_COLOR = CreateMaterial('PPM2.ManeTextureBase', 'UnlitGeneric', {
        '$basetexture': 'models/debug/debugwhite'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    @TAIL_MATERIAL_COLOR = CreateMaterial('PPM2.TailTextureBase', 'UnlitGeneric', {
        '$basetexture': 'models/debug/debugwhite'
        '$ignorez': 1
        '$vertexcolor': 1
        '$vertexalpha': 1
        '$nolod': 1
    })

    @EYE_OVAL = Material('models/ppm/partrender/eye_oval.png')
    @EYE_GRAD = Material('models/ppm/partrender/eye_grad.png')
    @EYE_EFFECT = Material('models/ppm/partrender/eye_effect.png')
    @EYE_REFLECTION = Material('models/ppm/partrender/eye_reflection.png')

    @EYE_LINE_L_1 = Material('models/ppm/partrender/eye_line_l1.png')
    @EYE_LINE_R_1 = Material('models/ppm/partrender/eye_line_r1.png')

    @EYE_LINE_L_2 = Material('models/ppm/partrender/eye_line_l2.png')
    @EYE_LINE_R_2 = Material('models/ppm/partrender/eye_line_r2.png')

    @PONY_SOCKS = Material('models/ppm/texclothes/pony_socks.png')

    @NEXT_GENERATED_ID = 10000

    @MANE_UPDATE_TRIGGER = {'ManeType': true, 'ManeTypeLower': true}
    @TAIL_UPDATE_TRIGGER = {'TailType': true}
    @EYE_UPDATE_TRIGGER = {
        'EyeWidth': true
        'IrisSize': true
        'EyeLines': true
        'EyeBackground': true
        'EyeIrisLine1': true
        'EyeIrisLine2': true
        'EyeIris1': true
        'EyeHole': true
    }

    for i = 1, 6
        @MANE_UPDATE_TRIGGER["ManeColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["DownManeDetailColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["UpperManeDetailColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["DownManeDetail#{i}"] = true
        @MANE_UPDATE_TRIGGER["UpperManeDetail#{i}"] = true
        @MANE_UPDATE_TRIGGER["LowerManeColor#{i}"] = true
        @MANE_UPDATE_TRIGGER["UpperManeColor#{i}"] = true
        @TAIL_UPDATE_TRIGGER["TailColor#{i}"] = true
        @TAIL_UPDATE_TRIGGER["TailDetailColor#{i}"] = true
    
    DataChanges: (state) =>
        return if not @ent
        key = state\GetKey()
        switch key
            when 'BodyColor'
                @CompileBody()
                @CompileWings()
                @CompileHorn()
            when 'Socks'
                @CompileBody()
            when 'Bodysuit'
                @CompileBody()
            when 'CMark'
                @CompileCMark()
            when 'CMarkType'
                @CompileCMark()
            when 'CMarkURL'
                @CompileCMark()
            else
                if @@MANE_UPDATE_TRIGGER[key]
                    @CompileHair()
                elseif @@TAIL_UPDATE_TRIGGER[key]
                    @CompileTail()
                elseif @@EYE_UPDATE_TRIGGER[key]
                    @CompileEye(true)
                    @CompileEye(false)

    new: (controller, compile = true) =>
        @ent = controller\GetEntity()
        @networkedData = controller\GetData()
        @id = @ent\EntIndex()
        if @id == -1
            @id = @@NEXT_GENERATED_ID
            @@NEXT_GENERATED_ID += 1
        @compiled = false
        @CompileTextures() if compile
    GetData: =>
        @ent = @networkedData\GetEntity()
        return @networkedData
    GetEntity: => @ent
    GetBody: =>
        if @GetData()\GetGender() == PPM2.GENDER_FEMALE
            return @FemaleMaterial
        else
            return @MaleMaterial
    GetCMark: => @CMarkTexture
    GetGUICMark: => @CMarkTextureGUI
    GetCMarkGUI: => @CMarkTextureGUI
    GetHair: (index = 1) =>
        if index == 2
            return @HairColor2Material
        else
            return @HairColor1Material
    GetMane: (index = 1) =>
        if index == 2
            return @HairColor2Material
        else
            return @HairColor1Material
    GetTail: (index = 1) =>
        if index == 2
            return @TailColor2Material
        else
            return @TailColor1Material
    GetEye: (left = false) =>
        if left
            return @EyeMaterialL
        else
            return @EyeMaterialR
    GetHorn: => @HornMaterial
    GetWings: => @WingsMaterial
    CompileTextures: =>
        @CompileBody()
        @CompileHair()
        @CompileTail()
        @CompileHorn()
        @CompileWings()
        @CompileCMark()
        @CompileEye(false)
        @CompileEye(true)
        @compiled = true
    
    PreDraw: (ent = @ent) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT, @GetEye(true))
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT, @GetEye(false))
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN, @GetHorn())
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS, @GetWings())
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR1, @GetHair(1))
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR2, @GetHair(2))
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR1, @GetTail(1))
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR2, @GetTail(2))
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK, @GetCMark())
    
    PostDraw: (ent = @ent) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN)
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR1)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR2)
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR1)
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR2)
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK)
    
    @QUAD_POS_CONST = Vector(0, 0, 0)
    @QUAD_FACE_CONST = Vector(0, 0, -1)
    @QUAD_SIZE_CONST = 512
    __compileBodyInternal: (rt, oldW, oldH, r, g, b, bodyMat) =>
        rt\Download()
        render.PushRenderTarget(rt)
        render.SetViewPort(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        render.Clear(r, g, b, 255, true, true)
        cam.Start2D()
        surface.SetDrawColor(r, g, b)
        surface.DrawRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        surface.SetMaterial(bodyMat)
        surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        for i = 1, PPM2.MAX_BODY_DETAILS
            detailID = @networkedData["GetBodyDetail#{i}"](@networkedData)
            mat = PPM2.BodyDetailsMaterials[detailID]
            continue if not mat
            surface.SetDrawColor(@networkedData["GetBodyDetailColor#{i}"](@networkedData))
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)
        
        if @GetData()\GetSocks()
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(@@PONY_SOCKS)
            surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)
        
        suitType = @GetData()\GetBodysuit()
        if PPM2.AvaliablePonySuitsMaterials[suitType]
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(PPM2.AvaliablePonySuitsMaterials[suitType])
            surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        cam.End2D()
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        return rt
    CompileBody: =>
        textureMale = {
            'name': "PPM2.#{@id}.Body.vmale"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/ppm/base/bodym'

                '$color': '{255 255 255}'
                '$color2': '{255 255 255}'
                '$model': '1'
                '$phong': '1'
                '$basemapalphaphongmask': '1'
                '$phongexponent': '6'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                
                '$rimlight': 1
                '$rimlightexponent': 2
                '$rimlightboost': 1
            }
        }

        textureFemale = {
            'name': "PPM2.#{@id}.Body.vfemale"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureMale.data}
        }

        textureFemale.data['$basetexture'] = 'models/ppm/base/body'

        @MaleMaterial = CreateMaterial(textureMale.name, textureMale.shader, textureMale.data)
        @FemaleMaterial = CreateMaterial(textureFemale.name, textureFemale.shader, textureFemale.data)

        {:r, :g, :b} = @GetData()\GetBodyColor()
        oldW, oldH = ScrW(), ScrH()

        TargetMale = GetRenderTarget("PPM2_#{@id}_Body_Male_rt", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        TargetFemale = GetRenderTarget("PPM2_#{@id}_Body_Female_rt", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        
        @BodyTextureMale = @__compileBodyInternal(TargetMale, oldW, oldH, r, g, b, @@BODY_MATERIAL_MALE)
        @BodyTextureFemale = @__compileBodyInternal(TargetFemale, oldW, oldH, r, g, b, @@BODY_MATERIAL_FEMALE)

        @MaleMaterial\SetTexture('$basetexture', @BodyTextureMale)
        @FemaleMaterial\SetTexture('$basetexture', @BodyTextureFemale)

        return @MaleMaterial, @FemaleMaterial
    CompileHorn: =>
        textureData = {
            'name': "PPM2.#{@id}.Horn"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/ppm/base/horn'

                '$model': '1'
                '$phong': '1'
                '$phongexponent': '0.1'
                '$phongboost': '0.1'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                '$alpha': '1'
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        @HornMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)

        {:r, :g, :b} = @GetData()\GetBodyColor()

        @HornMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
        @HornMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))
        @HornMaterial\SetFloat('$alpha', 1)

        return @HornMaterial
    CompileWings: =>
        textureData = {
            'name': "PPM2.#{@id}.Wings"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite'

                '$model': '1'
                '$phong': '1'
                '$phongexponent': '0.1'
                '$phongboost': '0.1'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                '$alpha': '1'
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        @WingsMaterial = CreateMaterial(textureData.name, textureData.shader, textureData.data)

        {:r, :g, :b} = @GetData()\GetBodyColor()

        @WingsMaterial\SetVector('$color', Vector(r / 255, g / 255, b / 255))
        @WingsMaterial\SetVector('$color2', Vector(r / 255, g / 255, b / 255))
        @WingsMaterial\SetFloat('$alpha', 1)

        return @WingsMaterial
    
    GetManeType: => @GetData()\GetManeType()
    GetManeTypeLower: => @GetData()\GetManeTypeLower()
    GetTailType: => @GetData()\GetTailType()
    CompileHair: =>
        textureFirst = {
            'name': "PPM2.#{@id}.Mane.1"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite' 
                '$model': '1'
                '$phong': '1'
                '$basemapalphaphongmask': '1'
                '$phongexponent': '6'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                
                '$rimlight': 1
                '$rimlightexponent': 2
                '$rimlightboost': 1
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        textureSecond = {
            'name': "PPM2.#{@id}.Mane.2"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureFirst.data}
        }

        @HairColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
        @HairColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)
        oldW, oldH = ScrW(), ScrH()

        rt = GetRenderTarget("PPM2_#{@id}_Mane_rt_1", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        rt\Download()
        render.PushRenderTarget(rt)
        render.SetViewPort(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        -- First mane pass
        {:r, :g, :b} = @GetData()\GetManeColor1()
        render.Clear(r, g, b, 255, true, true)
        cam.Start2D()
        surface.SetDrawColor(r, g, b)
        surface.DrawRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        maneTypeUpper = @GetManeType()
        if @@UPPER_MANE_MATERIALS[maneTypeUpper]
            {:r, :g, :b} = @GetData()\GetManeDetailColor1()
            surface.SetDrawColor(r, g, b)
            for mat in *@@UPPER_MANE_MATERIALS[maneTypeUpper]
                continue if type(mat) == 'number'
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        cam.End2D()
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        @HairColor1Material\SetTexture('$basetexture', rt)

        -- Second mane pass
        rt = GetRenderTarget("PPM2_#{@id}_Mane_rt_2", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        rt\Download()
        render.PushRenderTarget(rt)
        render.SetViewPort(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        {:r, :g, :b} = @GetData()\GetManeColor2()
        render.Clear(r, g, b, 255, true, true)
        cam.Start2D()
        surface.SetDrawColor(r, g, b)
        surface.DrawRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        maneTypeLower = @GetManeTypeLower()
        if @@LOWER_MANE_MATERIALS[maneTypeLower]
            {:r, :g, :b} = @GetData()\GetManeDetailColor2()
            surface.SetDrawColor(r, g, b)
            for mat in *@@LOWER_MANE_MATERIALS[maneTypeLower]
                continue if type(mat) == 'number'
                surface.SetMaterial(mat)
                surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        cam.End2D()
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        @HairColor2Material\SetTexture('$basetexture', rt)

        return @HairColor1Material, @HairColor2Material
    CompileTail: =>
        textureFirst = {
            'name': "PPM2.#{@id}.Tail.1"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/debug/debugwhite' 
                '$model': '1'
                '$phong': '1'
                '$basemapalphaphongmask': '1'
                '$phongexponent': '6'
                '$phongboost': '0.05'
                '$phongalbedotint': '1'
                '$phongtint': '[1 .95 .95]'
                '$phongfresnelranges': '[0.5 6 10]'
                
                '$rimlight': 1
                '$rimlightexponent': 2
                '$rimlightboost': 1
                '$color': '[1 1 1]'
                '$color2': '[1 1 1]'
            }
        }

        textureSecond = {
            'name': "PPM2.#{@id}.Tail.2"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureFirst.data}
        }

        @TailColor1Material = CreateMaterial(textureFirst.name, textureFirst.shader, textureFirst.data)
        @TailColor2Material = CreateMaterial(textureSecond.name, textureSecond.shader, textureSecond.data)
        oldW, oldH = ScrW(), ScrH()

        -- First tail pass
        rt = GetRenderTarget("PPM2_#{@id}_Tail_rt_1", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        rt\Download()
        render.PushRenderTarget(rt)
        render.SetViewPort(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        {:r, :g, :b} = @GetData()\GetTailColor1()
        render.Clear(r, g, b, 255, true, true)
        cam.Start2D()
        surface.SetDrawColor(r, g, b)
        surface.DrawRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        surface.SetMaterial(@@HAIR_MATERIAL_COLOR)
        surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        tailType = @GetTailType()
        if @@TAIL_DETAIL_MATERIALS[tailType]
            i = 1
            for mat in *@@TAIL_DETAIL_MATERIALS[tailType]
                continue if type(mat) == 'number'
                surface.SetMaterial(mat)
                surface.SetDrawColor(@GetData()["GetTailDetailColor#{i}"](@GetData()))
                surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)
                i += 1

        cam.End2D()
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        @TailColor1Material\SetTexture('$basetexture', rt)

        -- Second tail pass
        rt = GetRenderTarget("PPM2_#{@id}_Tail_rt_2", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        rt\Download()
        render.PushRenderTarget(rt)
        render.SetViewPort(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        {:r, :g, :b} = @GetData()\GetTailColor2()
        render.Clear(r, g, b, 255, true, true)
        cam.Start2D()
        surface.SetDrawColor(r, g, b)
        surface.DrawRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        surface.SetMaterial(@@HAIR_MATERIAL_COLOR)
        surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        if @@TAIL_DETAIL_MATERIALS[tailType]
            i = 1
            for mat in *@@TAIL_DETAIL_MATERIALS[tailType]
                continue if type(mat) == 'number'
                surface.SetMaterial(mat)
                surface.SetDrawColor(@GetData()["GetTailDetailColor#{i}"](@GetData()))
                surface.DrawTexturedRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)
                i += 1

        cam.End2D()
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        @TailColor2Material\SetTexture('$basetexture', rt)

        return @TailColor1Material, @TailColor2Material
    CompileEye: (left = false) =>
        prefix = left and 'l' or 'r'
        prefixUpper = left and 'L' or 'R'
        EyeBackground = @GetData()\GetEyeBackground()
        EyeHole = @GetData()\GetEyeHole()
        HoleWidth = @GetData()\GetHoleWidth()
        IrisSize = @GetData()\GetIrisSize() * .75
        EyeIris1 = @GetData()\GetEyeIrisTop()
        EyeIris2 = @GetData()\GetEyeIrisBottom()
        EyeIrisLine1 = @GetData()\GetEyeIrisLine1()
        EyeIrisLine2 = @GetData()\GetEyeIrisLine2()
        EyeLines = @GetData()\GetEyeLines()
        HoleSize = @GetData()\GetHoleSize()
        oldW, oldH = ScrW(), ScrH()

        textureData = {
            'name': "PPM2.#{@id}.Eye.#{prefix}"
            'shader': 'eyes'
            'data': {
                '$iris': 'models/ppm/base/face/p_base'
                '$irisframe': '0'
                
                '$ambientoccltexture': 'models/ppm/base/face/black'
                '$envmap': 'models/ppm/base/face/black'
                '$corneatexture': 'models/ppm/base/face/white'
                '$lightwarptexture': 'models/ppm/clothes/lightwarp'
                
                '$eyeballradius': '3.7'
                '$ambientocclcolor': '[0.3 0.3 0.3]'
                '$dilation': '0.5'
                '$glossiness': '1'
                '$parallaxstrength': '0.1'
                '$corneabumpstrength': '0.1'

                '$halflambert': '1'
                '$nodecal': '1'

                '$raytracesphere': '1'
                '$spheretexkillcombo': '0'
                '$eyeorigin': '[0 0 0]'
                '$irisu': '[0 1 0 0]'
                '$irisv': '[0 0 1 0]'
                '$entityorigin': '4.0'
            }
        }

        @["EyeMaterial#{prefixUpper}"] = CreateMaterial(textureData.name, textureData.shader, textureData.data)

        rt = GetRenderTarget("PPM2_#{@id}_Eye_#{prefix}", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        rt\Download()
        render.PushRenderTarget(rt)
        render.SetViewPort(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        {:r, :g, :b} = EyeBackground
        render.Clear(r, g, b, 255, true, true)
        cam.Start2D()
        surface.SetDrawColor(r, g, b)
        surface.DrawRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        surface.SetDrawColor(EyeIris1)
        surface.SetMaterial(@@EYE_OVAL)
        IrisPos = @@QUAD_SIZE_CONST / 2 - @@QUAD_SIZE_CONST * IrisSize / 2
        IrisQuadSize = @@QUAD_SIZE_CONST * IrisSize
        surface.DrawTexturedRect(IrisPos, IrisPos, IrisQuadSize, IrisQuadSize)

        surface.SetDrawColor(EyeIris2)
        surface.SetMaterial(@@EYE_GRAD)
        surface.DrawTexturedRect(IrisPos, IrisPos, IrisQuadSize, IrisQuadSize)

        if EyeLines
            surface.SetDrawColor(EyeIrisLine1)
            surface.SetMaterial(@@["EYE_LINE_#{prefixUpper}_1"])
            surface.DrawTexturedRect(IrisPos, IrisPos, IrisQuadSize, IrisQuadSize)

            surface.SetDrawColor(EyeIrisLine2)
            surface.SetMaterial(@@["EYE_LINE_#{prefixUpper}_2"])
            surface.DrawTexturedRect(IrisPos, IrisPos, IrisQuadSize, IrisQuadSize)
        
        surface.SetDrawColor(EyeHole)
        surface.SetMaterial(@@EYE_OVAL)
        HoleQuadSize = @@QUAD_SIZE_CONST * IrisSize * HoleSize
        HolePos = @@QUAD_SIZE_CONST / 2
        surface.DrawTexturedRect(HolePos - HoleQuadSize * HoleWidth / 2, HolePos - @@QUAD_SIZE_CONST * (IrisSize * HoleSize) / 2, HoleQuadSize * HoleWidth, HoleQuadSize)

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(@@EYE_EFFECT)
        surface.DrawTexturedRect(IrisPos, IrisPos, IrisQuadSize, IrisQuadSize)

        surface.SetDrawColor(255, 255, 255, 127)
        surface.SetMaterial(@@EYE_REFLECTION)
        surface.DrawTexturedRect(IrisPos, IrisPos, IrisQuadSize, IrisQuadSize)

        cam.End2D()
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        @["EyeMaterial#{prefixUpper}"]\SetTexture('$iris', rt)
    @BuildCMarkHTML = (url = 'https://dbot.serealia.ca/illuminati.jpg', width = @QUAD_SIZE_CONST, height = @QUAD_SIZE_CONST) =>
        return "<html>
                    <head>
                        <style>
                            html, body {
                                background: transparent;
                                margin: 0;
                                padding: 0;
                                overflow: hidden;
                            }

                            #mainimage {
                                max-width: #{width * .66};
                                height: auto;
                                width: 100%;
                                max-height: #{height * .66};
                            }

                            #imgdiv {
                                width: #{width};
                                height: #{height};
                                overflow: hidden;
                                margin: 0;
                                padding: 0;
                                text-align: center;
                            }
                        </style>
                        <script>
                            window.onload = function() {
                                var img = document.getElementById('mainimage');
                                if (img.naturalWidth < img.naturalHeight) {
                                    img.style.setProperty('height', '100%');
                                    img.style.setProperty('width', 'auto');
                                }

                                img.style.setProperty('margin-top', (#{height} - img.height) / 2);
                            };
                        </script>
                    </head>
                    <body>
                        <div id='imgdiv'>
                            <img src='#{url}' id='mainimage' />
                        </div>
                    </body>
                </html>"
    CompileCMark: =>
        textureData = {
            'name': "PPM2.#{@id}.CMark"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/ppm/partrender/null'
                '$translucent': '1'
            }
        }

        textureDataGUI = {
            'name': "PPM2.#{@id}.CMark.GUI"
            'shader': 'UnlitGeneric'
            'data': {
                '$basetexture': 'models/ppm/partrender/null'
                '$translucent': '1'
            }
        }

        @CMarkTexture = CreateMaterial(textureData.name, textureData.shader, textureData.data)
        @CMarkTextureGUI = CreateMaterial(textureDataGUI.name, textureDataGUI.shader, textureDataGUI.data)

        unless @GetData()\GetCMark()
            @CMarkTexture\SetTexture('$basetexture', 'models/ppm/partrender/null')
            @CMarkTextureGUI\SetTexture('$basetexture', 'models/ppm/partrender/null')
            return @CMarkTexture, @CMarkTextureGUI
        
        URL = @GetData()\GetCMarkURL()

        if URL == '' or not URL\find('^https?://')
            mark = PPM2.DefaultCutiemarksMaterials[@GetData()\GetCMarkType() + 1]
            @CMarkTexture\SetTexture('$basetexture', mark\GetTexture('$basetexture')) if mark
            @CMarkTextureGUI\SetTexture('$basetexture', mark\GetTexture('$basetexture')) if mark
        else
            panel = vgui.Create('DHTML')
            timer.Simple 4, -> panel\Remove() if IsValid(panel)
            panel\SetVisible(false)
            panel\SetSize(@@QUAD_SIZE_CONST / 2, @@QUAD_SIZE_CONST / 2)
            panel\SetHTML(@@BuildCMarkHTML(URL, @@QUAD_SIZE_CONST / 2, @@QUAD_SIZE_CONST / 2))
            panel\Refresh()
            panel.ConsoleMessage = ->
            hookID = "PPM2.#{@id}.CMarkDL"

            hook.Add 'Think', hookID, ->
                if not IsValid(panel)
                    hook.Remove 'Think', hookID
                    return
                if not panel\IsLoading()
                    hook.Remove 'Think', hookID
                    timer.Simple 0.3, ->
                        return unless IsValid(panel)
                        panel\UpdateHTMLTexture()
                        htmlmat = panel\GetHTMLMaterial()
                        return if not htmlmat
                        texture = htmlmat\GetTexture('$basetexture')
                        texture\Download()
                        @CMarkTexture\SetTexture('$basetexture', texture)
                        @CMarkTextureGUI\SetTexture('$basetexture', texture)
                        hook.Remove 'Think', hookID
                        timer.Simple 0, -> panel\Remove() if IsValid(panel)
        
        return @CMarkTexture, @CMarkTextureGUI

-- [ 1] = "models/ppm/base/cmark"
-- [ 2] = "models/ppm/base/eyelashes"
-- [ 3] = "models/ppm/base/tongue"
-- [ 4] = "models/ppm/base/body"
-- [ 5] = "models/ppm/base/teeth"
-- [ 6] = "models/ppm/base/eye_l"
-- [ 7] = "models/ppm/base/eye_r"
-- [ 8] = "models/ppm/base/mouth"
-- [ 9] = "models/ppm/base/horn"
-- [10] = "models/ppm/base/wings"

class NewPonyTextureController extends PonyTextureController
    @MODELS = {'models/ppm/player_default_base_new.mdl'}

    @UPPER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs @UPPER_MANE_MATERIALS}
    @LOWER_MANE_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs @LOWER_MANE_MATERIALS}
    @TAIL_DETAIL_MATERIALS = {i, [val1 for val1 in *val] for i, val in pairs @TAIL_DETAIL_MATERIALS}

    @MAT_INDEX_CMARK = 0
    @MAT_INDEX_EYELASHES = 1
    @MAT_INDEX_TONGUE = 2
    @MAT_INDEX_BODY = 3
    @MAT_INDEX_TEETH = 4
    @MAT_INDEX_EYE_LEFT = 5
    @MAT_INDEX_EYE_RIGHT = 6
    @MAT_INDEX_MOUNTH = 7
    @MAT_INDEX_HORN = 8
    @MAT_INDEX_WINGS = 9

    @MAT_INDEX_HAIR_COLOR1 = 0
    @MAT_INDEX_HAIR_COLOR2 = 1

    @MAT_INDEX_TAIL_COLOR1 = 0
    @MAT_INDEX_TAIL_COLOR2 = 1

    DataChanges: (state) =>
        super(state)
        switch state\GetKey()
            when 'ManeTypeNew'
                @CompileHair()
            when 'ManeTypeLowerNew'
                @CompileHair()
            when 'TailTypeNew'
                @CompileTail()

    GetManeType: => @GetData()\GetManeTypeNew()
    GetManeTypeLower: => @GetData()\GetManeTypeLowerNew()
    GetTailType: => @GetData()\GetTailTypeNew()

    PreDrawMane: (ent = @ent, entMane) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR1, @GetMane(1))
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR2, @GetMane(2))

    PostDrawMane: (ent = @ent, entMane) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR1)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR2)

    PreDrawTail: (ent = @ent, entTail) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR1, @GetTail(1))
        render.MaterialOverrideByIndex(@@MAT_INDEX_HAIR_COLOR2, @GetTail(2))

    PostDrawTail: (ent = @ent, entTail) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR1)
        render.MaterialOverrideByIndex(@@MAT_INDEX_TAIL_COLOR2)

    PreDraw: (ent = @ent) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT, @GetEye(true))
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT, @GetEye(false))
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN, @GetHorn())
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS, @GetWings())
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK, @GetCMark())
    
    PostDraw: (ent = @ent) =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_LEFT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_EYE_RIGHT)
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY)
        render.MaterialOverrideByIndex(@@MAT_INDEX_HORN)
        render.MaterialOverrideByIndex(@@MAT_INDEX_WINGS)
        render.MaterialOverrideByIndex(@@MAT_INDEX_CMARK)


PPM2.NewPonyTextureController = NewPonyTextureController
PPM2.PonyTextureController = PonyTextureController
PPM2.GetTextureController = (model = 'models/ppm/player_default_base.mdl') -> PonyTextureController.AVALIABLE_CONTROLLERS[model\lower()] or PonyTextureController
