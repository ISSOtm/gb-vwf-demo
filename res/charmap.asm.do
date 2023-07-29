cd ..
# Inherit all transitive deps, which includes `src/gb-vwf/vwf.asm`.
redo-ifchange obj/gb-vwf/vwf.asm.o

# stdout redirects to the target file, and "$3" isn't an absolute path!
rgbasm -DPRINT_CHARMAP -DVWF_CFG_FILE=vwf_config.inc -I src src/gb-vwf/vwf.asm
