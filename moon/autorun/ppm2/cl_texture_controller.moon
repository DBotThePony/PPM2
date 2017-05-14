
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

-- Texture indexes
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
    @BODY_TEX_ID_FEMALE = surface.GetTextureID('models/ppm/base/body')
    @BODY_TEX_ID_MALE = surface.GetTextureID('models/ppm/base/bodym')

    @BODY_MATERIAL_MALE = Material('models/ppm/base/render/bodym')
    @BODY_MATERIAL_FEMALE = Material('models/ppm/base/render/bodyf')

    new: (ent = NULL, data, compile = true, apply = true) =>
        @ent = ent
        @networkedData = data
        @id = ent\EntIndex()
        @CompileTextures() if compile
        @ApplyTextures() if compile and apply
    GetBody: =>
        if @networkedData\GetGender() == PPM2.GENDER_FEMALE
            return @FemaleMaterial
        else
            return @MaleMaterial
    CompileTextures: =>
        @CompileBody()
    ApplyTextures: =>
        @ent\SetSubMaterial(3, "!#{@GetBody()\GetName()}")
    
    @QUAD_POS_CONST = Vector(0, 0, 0)
    @QUAD_FACE_CONST = Vector(0, 0, -1)
    @QUAD_SIZE_CONST = 512
    __compileBodyInternal: (rt, oldW, oldH, r, g, b, bodyMat) =>
        render.PushRenderTarget(rt)
        render.OverrideAlphaWriteEnable(true, true)
        render.SuppressEngineLighting(true)
        render.ResetModelLighting(1, 1, 1)
        cam.IgnoreZ(true)
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
            print mat, detailID
            continue if not mat
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(0, 0, 512, 512)

        cam.End2D()
        render.SuppressEngineLighting(false)
        cam.IgnoreZ(false)
        render.SetViewPort(0, 0, oldW, oldH)
        render.PopRenderTarget()
        return rt
    CompileBody: =>
        textureMale = {
            'name': "PPM2.#{@id}.Body.vmale10"
            'shader': 'VertexLitGeneric'
            'data': {
                '$basetexture': 'models/ppm/base/bodym'

                '$color': '{255 255 255}'
                '$color2': '{255 255 255}'
            }
        }

        textureFemale = {
            'name': "PPM2.#{@id}.Body.vfemale10"
            'shader': 'VertexLitGeneric'
            'data': {k, v for k, v in pairs textureMale.data}
        }

        textureFemale.data['$basetexture'] = 'models/ppm/base/body'

        @MaleMaterial = CreateMaterial(textureMale.name, textureMale.shader, textureMale.data)
        @FemaleMaterial = CreateMaterial(textureFemale.name, textureFemale.shader, textureFemale.data)

        --PPM2.ApplyMaterialData(@MaleMaterial, textureMale.data)
        --PPM2.ApplyMaterialData(@FemaleMaterial, textureFemale.data)

        {:r, :g, :b} = @networkedData\GetBodyColor()
        oldW, oldH = ScrW(), ScrH()

        Target = GetRenderTarget("#{textureMale.name}_RenderTargetMale", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        @BodyTextureMale = @__compileBodyInternal(Target, oldW, oldH, r, g, b, @@BODY_MATERIAL_MALE)
        Target = GetRenderTarget("#{textureFemale.name}_RenderTargetFemale", @@QUAD_SIZE_CONST, @@QUAD_SIZE_CONST, false)
        @BodyTextureFemale = @__compileBodyInternal(Target, oldW, oldH, r, g, b, @@BODY_MATERIAL_FEMALE)

        @MaleMaterial\SetTexture('$basetexture', @BodyTextureMale)
        @FemaleMaterial\SetTexture('$basetexture', @BodyTextureFemale)

        return @MaleMaterial, @FemaleMaterial

PPM2.PonyTextureController = PonyTextureController
