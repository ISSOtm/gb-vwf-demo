#!/usr/bin/env bash
set -euo pipefail

INCPATHS=(src/)
WARNINGS=(all  extra)
ASFLAGS=(-p 0xFF  "${INCPATHS[@]/#/-I}"  "${WARNINGS[@]/#/-W}")

rgbasm=${RGBASM:-${RGBDS:+$RGBDS/}rgbasm}

if [[ "$2" = "obj/gb-vwf/vwf.asm" ]]; then
	ASFLAGS+=(-DVWF_CFG_FILE=src/vwf_config.inc)
fi

# Look for sources in `src/`, but if not found, try in `obj/` as they might be auto-generated.
SRC="src/${2#obj/}"
if ! [[ -e "$SRC" ]]; then
	SRC="obj/${SRC#src/}"
fi
redo-ifchange "$SRC"

mkdir -p "${2%/*}" # Create the output directory.

# RGBASM exits with status 0 if either it completed successfully, or it encountered a missing dependency.
# To distinguish the two, we check for the output file, which is only produced in the former case.
# But if the output already exists, we may take the latter for the former; so, delete it.
rm -rf "$3"

while ! [[ -e "$3" ]]; do
	# Attempt to build and discover dependencies, passing each of them to `redo-ifchange` via `-M`.
	"$rgbasm" "${ASFLAGS[@]}" "$SRC" -o "$3" -M - -MG | cut -d : -f 2- | xargs redo-ifchange
	# We will keep retrying until all dependencies have been built, since then RGBASM will have generated the output file.
done

# Do it one last time to generate that file's associated debugfile.
"$rgbasm" -DPRINT_DEBUGFILE "${ASFLAGS[@]}" "$SRC" >"$2.dbg"
