INCLUDE "hardware.inc/hardware.inc"


; Write a section definition to control where the VWF engine itself ends up;
; however, other sections are defined afterwards for the RAM variables.
SECTION "VWF engine", ROM0


; Charset definition. Note that it is not possible to define per-font characters!
; Please consult the manual for information on how to do that (TODO)
	chars " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*",  "+",  ",",  "-", ".", "/"
	chars "0", "1",  "2", "3", "4", "5", "6", "7", "8", "9", ":",  ";",  "<",  "=", ">", "?"
	chars "@", "A",  "B", "C", "D", "E", "F", "G", "H", "I", "J",  "K",  "L",  "M", "N", "O"
	chars "P", "Q",  "R", "S", "T", "U", "V", "W", "X", "Y", "Z",  "[", "\\",  "]", "^", "_"
	chars "`", "a",  "b", "c", "d", "e", "f", "g", "h", "i", "j",  "k",  "l",  "m", "n", "o"
	chars "p", "q",  "r", "s", "t", "u", "v", "w", "x", "y", "z", "\{",  "|", "\}", "~", "△"
	chars "¡", "¢",  "£", "€", "↑", "↓", "←", "→", "♡", "♥", "©",  "®",  "™",  "²", "√", "¿"
	chars "Á", "Ä",  "Æ", "Ç", "É", "Í", "Ñ", "Ó", "Ö", "Ú", "Ü",                   "Þ", "µ"
	chars "á", "ä",  "æ", "ç", "é", "í", "ñ", "ó", "ö", "ú", "ü",                   "þ", "ß"

	font BASE_SEVEN,      res/fonts/BaseSeven.vwf
	font BASE_SEVEN_BOLD, res/fonts/BaseSevenBold_vx8.vwf
	font OPTIX,           res/fonts/optix.vwf
	font OPTIX_BOLD,      res/fonts/optixBold.vwf
def NB_VARIANT_BITS equ 1 ; This demo only uses two variants (plain and bold) per font family.

; Custom control characters.
	control_char !,CLEAR, ClearTextbox


; Macros required by `vwf.asm`.

macro switch_rom_bank
	ldh [hCurROMBank], a ; For interrupt safety, the HRAM variable *must* be updated BEFORE the actual switch!
	ld [rROMB0], a
endm

def VWF_EMPTY_TILE_ID equ $00 ; TODO


; It's possible to export otherwise "private" symbols from `vwf.asm`, like so:
	EXPORT wTileBuffer, wTileBuffer.end, wLookahead.nbTilesRemaining, FontBASE_SEVENPtr
; Please note that anything exported like this is not covered by backwards compatibility!
