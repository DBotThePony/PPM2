
rm lua -rf
mkdir lua || { exit 1; }
moonc -t lua moon/* || { exit 1; }
cp moon/autorun lua -r
