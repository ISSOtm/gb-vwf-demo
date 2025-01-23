mkdir -p "${2%/*}"
redo-ifchange ../src/gb-vwf/target/release/font_encoder "../src/$2.png"
../src/gb-vwf/target/release/font_encoder "../src/$2.png" "$3" --widths "${1}len.tmp"
