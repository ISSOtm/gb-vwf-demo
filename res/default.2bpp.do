rgbgfx=${RGBGFX:-${RGBDS:+$RGBDS/}rgbgfx}

redo-ifchange "../src/$2.png"
if [ -e "../src/$2.args" ]; then
	redo-ifchange "../src/$2.args"
	"$rgbgfx" -o "$3" @"../src/$2.args" "../src/$2.png"
else
	"$rgbgfx" -o "$3" "../src/$2.png"
fi
