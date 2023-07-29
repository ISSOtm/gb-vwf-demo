#!/bin/bash
set -euo pipefail

LDFLAGS=(-d)
FIXFLAGS=(-v -p 0xFF -m MBC3)

readarray -d '' SRCS < <(find src -name '*.asm' -type f -print0 | tee >(redo-stamp))
OBJS=()
for src in "${SRCS[@]}"; do
	OBJ="obj/${src#*/}.o"
	redo-ifchange "$OBJ"
	OBJS+=("$OBJ")
done

{
	echo '@debugfile 1.0.0'
	for obj in "${OBJS[@]}"; do
		printf '@include "%s"\n' "${obj%.o}.dbg"
	done
} >vwf.dbg

rgbasm -DPRINT_TBL -DVWF_CFG_FILE=vwf_config.inc -I src src/gb-vwf/vwf.asm >vwf.tbl

rgblink "${LDFLAGS[@]}" "${OBJS[@]}" -o - -m vwf.map -n vwf.sym | rgbfix "${FIXFLAGS[@]}" >vwf.gb
