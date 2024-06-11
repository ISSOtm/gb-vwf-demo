mkdir -p "${2%/*}"
redo-ifchange ../src/gb-vwf/font_encoder/target/release/font_encoder "../src/$2.png"
../src/gb-vwf/font_encoder/target/release/font_encoder "../src/$2.png" "$1"
mv "$1" "$3"
