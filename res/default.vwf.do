mkdir -p "${2%/*}"
redo-ifchange ../src/gb-vwf/make_font.py
python3 ../src/gb-vwf/make_font.py "../src/$2.png" "$3"
