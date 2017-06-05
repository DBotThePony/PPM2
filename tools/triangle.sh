
set $PATH="$PATH;/e/Steam/SteamApps/common/Source SDK Base 2013 Multiplayer/bin"

echo 'temp/triangle_base.miff'

magick montage \
'(' '-size' '100x100' 'xc:gold' -fill black -draw "path 'M 0,100  L 50,0  L 100,100 L 0,100 Z' " ')' \
'(' '-size' '100x100' 'xc:black' -fill gold -draw "path 'M 0,0  L 50,100  L 100,0 L 0,0 Z' " ')' \
-geometry '-24+0' \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
'-size' '20x20' '-tile' '2x' \
'temp/triangle_base.miff'

echo 'temp/triangle_base_tiled.miff'

magick montage \
'(' '-size' '100x100' 'xc:gold' -fill black -draw "path 'M 0,100  L 50,0  L 100,100 L 0,100 Z' " ')' \
'(' '-size' '100x100' 'xc:black' -fill gold -draw "path 'M 0,0  L 50,100  L 100,0 L 0,0 Z' " ')' \
-geometry '-24+0' \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
'-size' '20x20' '-tile' '2x' \
'temp/triangle_base_tiled.miff'

echo 'temp/triangle_texture.miff'
magick montage 'temp/triangle_base.miff' \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-geometry +0+0 \
-tile 9x \
'temp/triangle_texture.miff'

echo 'temp/triangle_texture_tiled.miff'
magick montage 'temp/triangle_base_tiled.miff' \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-clone 0 \
-geometry +0+0 \
-tile 20x \
'temp/triangle_texture_tiled.miff'

echo 'temp/triangle_texture_1.miff'
magick convert -alpha 'set' 'temp/triangle_texture.miff' -transparent 'gold' -channel RGB +level-colors white 'temp/triangle_texture_1.miff'
echo 'temp/triangle_texture_2.miff'
magick convert -alpha 'set' 'temp/triangle_texture.miff' -transparent 'black' -channel RGB +level-colors white 'temp/triangle_texture_2.miff'

echo 'temp/triangle_texture_1_tiled.miff'
magick convert -alpha 'set' 'temp/triangle_texture_tiled.miff' -transparent 'gold' -channel RGB +level-colors white -channel ALL -resize 1024 -crop 1024x1024 'temp/triangle_texture_1_tiled.miff'
echo 'temp/triangle_texture_2_tiled.miff'
magick convert -alpha 'set' 'temp/triangle_texture_tiled.miff' -transparent 'black' -channel RGB +level-colors white -channel ALL -resize 1024 -crop 1024x1024  'temp/triangle_texture_2_tiled.miff'

echo 'temp/triangle_texture_1_tiled_compose.miff'
magick composite -alpha 'set' 'socks_mask.png' 'temp/triangle_texture_1_tiled.miff[0]' -compose DstIn 'temp/triangle_texture_1_tiled_compose.miff'
echo 'temp/triangle_texture_2_tiled_compose.miff'
magick composite -alpha 'set' 'socks_mask.png' 'temp/triangle_texture_2_tiled.miff[0]' -compose DstIn 'temp/triangle_texture_2_tiled_compose.miff'

echo 'target/socks_triangles_1.tga'
magick convert 'temp/triangle_texture_1.miff' 'target/socks_triangles_1.tga'
echo 'target/socks_triangles_2.tga'
magick convert 'temp/triangle_texture_2.miff' 'target/socks_triangles_2.tga'

echo 'target/socks_tiled_triangles_1.png'
magick convert 'temp/triangle_texture_1_tiled_compose.miff' 'target/socks_tiled_triangles_1.png'
echo 'target/socks_tiled_triangles_2.png'
magick convert 'temp/triangle_texture_2_tiled_compose.miff' 'target/socks_tiled_triangles_2.png'

echo 'VTF'
vtex 'target/socks_triangles_1.tga' 'target/socks_triangles_1.vtf'
vtex 'target/socks_triangles_2.tga' 'target/socks_triangles_2.vtf'
