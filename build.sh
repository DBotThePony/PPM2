rm lua -rf
mkdir lua || { exit 1; }
moonc -t lua moon/* || { exit 1; }
cp -v 'moon/autorun/strong_entity_link.lua' 'lua/autorun/strong_entity_link.lua'