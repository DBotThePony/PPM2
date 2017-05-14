
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

PPM2.ApplyMaterialData = (mat, matData) ->
    for k, v in pairs matData
        switch type(v)
            when 'string'
                mat\SetString(k, v)
            when 'number'
                mat\SetInt(k, v) if math.floor(v) == v
                mat\SetFloat(k, v) if math.floor(v) ~= v

class PonyTextureController
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

    @BODY_TEX_ID_FEMALE = surface.GetTextureID('models/ppm/base/body')
    @BODY_TEX_ID_MALE = surface.GetTextureID('models/ppm/base/bodym')

    @BODY_MATERIAL_MALE = Material('models/ppm/base/render/bodym')
    @BODY_MATERIAL_FEMALE = Material('models/ppm/base/render/bodyf')

    @NEXT_GENERATED_ID = 10000

    new: (ent = NULL, data, compile = true) =>
        @ent = ent
        @networkedData = data
        @id = ent\EntIndex()
        if @id == -1
            @id = @@NEXT_GENERATED_ID
            @@NEXT_GENERATED_ID += 1
        @compiled = false
        @CompileTextures() if compile
    GetBody: =>
        if @networkedData\GetGender() == PPM2.GENDER_FEMALE
            return @FemaleMaterial
        else
            return @MaleMaterial
    CompileTextures: =>
        @CompileBody()
        @compiled = true
    
    PreDraw: =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY, @GetBody())
    
    PostDraw: =>
        return unless @compiled
        render.MaterialOverrideByIndex(@@MAT_INDEX_BODY)
    
    @QUAD_POS_CONST = Vector(0, 0, 0)
    @QUAD_FACE_CONST = Vector(0, 0, -1)
    @QUAD_SIZE_CONST = 512
    __compileBodyInternal: (rt, oldW, oldH, r, g, b, bodyMat) =>
        render.PushRenderTarget(rt)
        render.SetViewPort(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        render.Clear(r, g, b, 255, true, true)
        cam.Start2D()
        surface.SetDrawColor(r, g, b)
        surface.DrawRect(0, 0, @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST)

        surface.SetMaterial(bodyMat)
        surface.DrawTexturedRect(0, 0, 512, 512)

        for i = 1, PPM2.MAX_BODY_DETAILS
            detailID = @networkedData["GetBodyDetail#{i}"](@networkedData)
            mat = PPM2.BodyDetailsMaterials[detailID]
            continue if not mat
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, 512, 512)

        cam.End2D()
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        return rt
    CompileBody: =>
        textureMale = {
            'name': "PPM2.#{@id}.Body.vmale14"
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
            'name': "PPM2.#{@id}.Body.vfemale14"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureMale.data}
        }

        textureFemale.data['$basetexture'] = 'models/ppm/base/body'

        @MaleMaterial = CreateMaterial(textureMale.name, textureMale.shader, textureMale.data)
        @FemaleMaterial = CreateMaterial(textureFemale.name, textureFemale.shader, textureFemale.data)

        {:r, :g, :b} = @networkedData\GetBodyColor()
        oldW, oldH = ScrW(), ScrH()

        TargetMale = GetRenderTarget("#{textureMale.name}_RenderTargetMale", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        TargetFemale = GetRenderTarget("#{textureFemale.name}_RenderTargetFemale", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        
        @BodyTextureMale = @__compileBodyInternal(TargetMale, oldW, oldH, r, g, b, @@BODY_MATERIAL_MALE)
        @BodyTextureFemale = @__compileBodyInternal(TargetFemale, oldW, oldH, r, g, b, @@BODY_MATERIAL_FEMALE)

        @MaleMaterial\SetTexture('$basetexture', @BodyTextureMale)
        @FemaleMaterial\SetTexture('$basetexture', @BodyTextureFemale)

        return @MaleMaterial, @FemaleMaterial

PPM2.PonyTextureController = PonyTextureController
