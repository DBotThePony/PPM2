
magick montage \
'(' '-size' '100x100' 'xc:gold' -fill black -draw "path 'M 0,100  L 50,0  L 100,100 L 0,100 Z' " ')' \
'(' '-size' '100x100' 'xc:black' -fill gold -draw "path 'M 0,0  L 50,100  L 100,0 L 0,0 Z' " ')' \
-geometry '-24.9+0' \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
-clone 1 -clone 0 \
-clone 0 -clone 1 \
'-size' '20x20' '-tile' '2x' \
'temp/triangle_base.png'

magick montage 'temp/triangle_base.png' \
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
'temp/triangle_texture.png'
