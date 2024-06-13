
INCLUDE "hardware.inc/hardware.inc"
INCLUDE "res/charmap.asm"
	setcharmap vwf

	rev_Check_hardware_inc 4.0


def TEXT_WIDTH_TILES equ 16
def TEXT_HEIGHT_TILES equ 8
	EXPORT TEXT_WIDTH_TILES
	EXPORT TEXT_HEIGHT_TILES
def BTN_ANIM_PERIOD equ 16

macro lb
	ld \1, (\2) << 8 | (\3)
endm


; For demonstration purposes, all of these pieces of text are in different banks,
; and in a bank other than the VWF engine.
SECTION "Text", ROMX,BANK[3]

Text:
	db "<CLEAR>Hello World!"
	db "\nThis line should break here, automatically!<WAIT>"
	db "\n"
	db "\nText resumes printing when pressing A, but holding B works too.<WAIT>"

	db "<CLEAR>Let's tour through most of the functionality, shall we?<WAIT>"
	db "\n"
	db "\nThe engine is also aware of textbox height, and will replace newlines with commands to scroll the textbox (both manual ones, and those inserted automatically)."
	db "\n"
	db "\nIt also keeps track of how many lines have been written since the last input, and automagically inserts a pause to avoid scrolling off lines you didn't have time to read!"
	db "\nYou can witness that in action right now, given how long this paragraph is.<WAIT>"

	db "<CLEAR>Note that automatic hyphenation is not supported, but line breaking is hyphen-aware.<WAIT>"
	; Notice how the first ZWS doesn't trigger a line break, but the second one does!
	db "\nBreaking of long words can be hinted at using \"soft hyphens\". Isn't it totally a<ZWS>ma<ZWS>zing?<WAIT>"

	db "<CLEAR>It is, <DELAY>",5,"of course, <DELAY>",10,"possible to insert ma<DELAY>",20,"nu<DELAY>",20,"al<DELAY>",20," delays, manual line"
	db "\nbreaks, and, as you probably already noticed, manual button waits.<WAIT>"

	db "<CLEAR>The engine also supports synchronisation! It's <SYNC>how <SYNC>these <SYNC>words<DELAY>",1," are made to trigger sound effects. <DELAY>",20
	db "\nIt could be useful for RPG cutscenes or rhythm games?<WAIT>"

	db "<CLEAR>It's also possible to <SET_COLOR>",1,"change the color <SET_COLOR>",0,"of text!<WAIT>"
	db "\nYou can also switch to <SET_VARIANT>",1,"variations of the font<SET_VARIANT>",0,", <SET_FONT>",OPTIX,"a different font, or <SET_VARIANT>",1,"a variation of a different font<SET_FONT>",BASE_SEVEN,", why not!<WAIT>"
	db "\n"
	db "\nEach font can have up to 128 characters. The encoding is left up to you--make good use of RGBASM's `charmap` feature!<WAIT>"

PUSHS
; Note that cross-bank "call" is NOT supported!
; It is, after all, primarily intended for things like the player's name (which you'd store in RAM).
SECTION "Called text", ROMX[$5000],BANK[3]
CalledText:
	db "Toto, I don't think we're in the main block anymore...<END>"
POPS

	db "<CLEAR>The engine also supports a `call`-like mechanism. The following quote is pulled from ${X:CalledText}: \""
	; Control chars are also made available as exported `VWF_*` constants.
	db VWF_CALL, LOW(CalledText), HIGH(CalledText)
	db "\".<WAIT>"
	db "\nIt is intended for things like the player's name.<WAIT>"
	db "\n"
	db "\nA \"jump\" is also supported."
	db "\nThough you may want to check out the source code--it's all seamless to the player.<WAIT>"
	db VWF_JUMP, LOW(CreditsText), HIGH(CreditsText)

SECTION "Credits text", ROMX,BANK[3]

CreditsText:
	db "<CLEAR>♥ Credits ♥"
	db "\nVWF engine by ISSOtm; graphics by BlitterObject; fonts by PinoBatch & Optix, with edits by ISSOtm.<WAIT>"
	db "\n"
	db "\nText will now end, press START to begin again.<END>"

SECTION "Static text", ROMX,BANK[2]

StaticText:
	db "<SET_FONT>",0,"VWF engine 2.0.0"
	db "\ngithub.com/ISSOtm/gb-vwf<END>"


; This is intentionally placed in bank 2 to demonstrate the VWF engine working fine from ROMX
SECTION "Animation", ROMX,BANK[2]
assert BANK(FontBASE_SEVENPtr) != BANK(@) ; We demonstrate how to use the engine from a different ROM bank than the fonts.

PerformAnimation:
	ld a, BTN_ANIM_PERIOD
	ld [wBtnAnimCounter], a


	;;;;;;;;;;;;;;;; TEXT ENGINE LOCAL INIT ;;;;;;;;;;;;;;;;;;;;;
	; We will be insta-printing this string.
	xor a
	ld [wNbTicksBetweenPrints], a
	; Specify that string's "tile pool".
	ld a, LOW(vStaticTextTiles / 16)
	ld [wCurTileID], a
	ld [wCurTileID.min], a
	ld a, LOW(vStaticTextTiles.end / 16)
	ld [wCurTileID.max], a
	; Specify that string's "textbox".
	ld a, LOW(vStaticText)
	ld [wTextbox.origin], a
	ld [wPrinterHeadPtr], a
	ld a, HIGH(vStaticText)
	ld [wTextbox.origin + 1], a
	ld [wPrinterHeadPtr + 1], a
	ld a, 15
	ld [wTextbox.width], a
	ld a, 2
	ld [wTextbox.height], a
	ld [wNbLinesRead], a
	; Setup the print.
	assert VWF_NEW_STR == 0
	xor a
	ld hl, StaticText
	ld b, BANK(StaticText)
	call SetupVWFEngine

: ; Actually do the printing.
	call Far_TickVWFEngine
	call PrintVWFChars
	ld a, [wSourceStack.len]
	and a
	jr nz, :-


	;;;;;;;;;;;;;;; This is "local" initialization for printing the "main" text ;;;;;;;;;;;;;;;;;
	ld a, 1
	ld [wNbTicksBetweenPrints], a
	; Setting up the "tile pool"...
	ld a, LOW(vTextTiles / 16)
	ld [wCurTileID], a
	ld [wCurTileID.min], a
	ld a, LOW(vTextTiles.end / 16)
	ld [wCurTileID.max], a

.restartText
	ld a, VWF_NEW_STR
	ld hl, Text
	ld b, BANK(Text)
	call SetupVWFEngine
	ld a, LOW(vText)
	ld [wTextbox.origin], a
	ld [wPrinterHeadPtr], a
	ld a, HIGH(vText)
	ld [wTextbox.origin + 1], a
	ld [wPrinterHeadPtr + 1], a
	ld a, TEXT_WIDTH_TILES
	ld [wTextbox.width], a
	ld a, TEXT_HEIGHT_TILES
	ld [wTextbox.height], a

.loop
	rst WaitVBlank

	call Far_TickVWFEngine
	call PrintVWFChars

	ld hl, wFlags
	bit 6, [hl]
	jr z, .noBeep
	res 6, [hl]
	; Picked using https://daid.github.io/gbsfx-studio/
	ld  a, $B6
	ldh [rNR11], a
	ld  a, $F0
	ldh [rNR12], a
	ld  a, $D4
	ldh [rNR13], a
	ld  a, $C7
	ldh [rNR14], a
.noBeep

	; Draw a button animation if waiting for button input
	assert TEXTB_WAITING == 7
	bit 7, [hl]
	ld a, SCRN_Y + 16
	jr z, .notWaiting
	ldh a, [hHeldButtons]
	bit PADB_B, a
	jr nz, .stopWaiting
	ldh a, [hPressedButtons]
	bit PADB_A, a
	jr z, .keepWaiting
.stopWaiting
	assert TEXTB_WAITING == 7
	res 7, [hl]
.keepWaiting
	ld a, 110 + 16
.notWaiting
	ld [wButtonSprites], a
	ld [wButtonSprites + 8], a
	add a, 16
	ld [wButtonSprites + 4], a
	ld [wButtonSprites + 12], a
	ld hl, wBtnAnimCounter
	dec [hl]
	jr nz, .noBtnAnim
	ld [hl], BTN_ANIM_PERIOD
	ld hl, wButtonSprites + OAMA_TILEID
	ld c, NB_BUTTON_SPRITES
.toggleBtnFrame
	ld a, [hl]
	xor LOW(vButtonTiles.frame0 / 16) ^ LOW(vButtonTiles.frame1 / 16)
	ld [hli], a
	inc l ; inc hl
	inc l ; inc hl
	inc l ; inc hl
	dec c
	jr nz, .toggleBtnFrame
.noBtnAnim


	ld a, [wSourceStack.len]
	and a
	jr nz, .loop

.waitRestart
	rst WaitVBlank
	ldh a, [hPressedButtons]
	and PADF_START
	jr z, .waitRestart
	jp .restartText


SECTION "VWF engine additions", ROM0

Far_TickVWFEngine:
	ldh a, [hCurROMBank]
	push af
	call TickVWFEngine
	pop af
	ldh [hCurROMBank], a
	ld [rROMB0], a
	ret

ClearTextbox::
	; Load the textbox's origin, and reset the "printer head" to point there.
	ld hl, wTextbox.origin
	ld a, [hli]
	ld [wPrinterHeadPtr], a
	ld h, [hl]
	ld l, a
	ld a, h
	ld [wPrinterHeadPtr + 1], a

	ld a, [wTextbox.width]
	ld [wLookahead.nbTilesRemaining], a
	ld a, [wTextbox.height]
	ld [wNbLinesRemaining], a ; Reset this, since we're resetting the "print head" as well.
	ld [wNbLinesRead], a ; Same.

	; Clear the textbox.
	ld b, a
.clearRow
	ld a, [wTextbox.width]
	ld c, a
.clear
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .clear
	; a = 0 here.
	ld [hli], a
	dec c
	jr nz, .clear
	ld a, [wTextbox.width]
	cpl
	add SCRN_VX_B + 1 ; a = SCRN_VX_B - [wTextbox.width]
	add a, l
	ld l, a
	adc a, h
	sub l
	ld h, a
	dec b
	jr nz, .clearRow

	; Ensure we'll start printing to a new tile.
	ld hl, wTileBuffer
	assert wTileBuffer.end == wNbPixelsDrawn
	ld c, wTileBuffer.end - wTileBuffer + 1
	xor a
.clearTileBuffer
	ld [hli], a
	dec c
	jr nz, .clearTileBuffer
	ret


SECTION "Header", ROM0[$100]

	di
	jr EntryPoint

	ds $150 - @, 0

EntryPoint:
	; Clear tilemap
	ld hl, _SCRN0
	ld de, SCRN_VX_B - SCRN_X_B
	ld c, SCRN_Y_B
.waitVBlank
	ldh a, [rLY]
	sub SCRN_Y
	jr nz, .waitVBlank
	; xor a ; ld a, 0
.clearTilemap
REPT SCRN_X_B
	ld [hli], a
ENDR
	add hl, de
	dec c
	jr nz, .clearTilemap
	; Init LCD regs
	; xor a ; ld a, 0
	ldh [rSCY], a
	ldh [rSCX], a
	ld a, %11100100
	ldh [rBGP], a
	ldh [rOBP0], a
	ld a, LCDCF_ON | LCDCF_BGON
	ldh [rLCDC], a

	; Init interrupt handler vars
	xor a
	ldh [hVBlankFlag], a
	dec a ; ld a, $FF
	ldh [hHeldButtons], a

	ld hl, OAMDMA
	lb bc, OAMDMA.end - OAMDMA, LOW(hOAMDMA)
.copyOAMDMA
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, .copyOAMDMA

	; Init OAM
	ld hl, wShadowOAM
	ld de, .sprites
	ld c, .spritesEnd - .sprites
	rst MemcpySmall
	; Send unused sprites off-screen
	ld c, NB_UNUSED_SPRITES * sizeof_OAM_ATTRS
	xor a ; ld a, 0
	rst MemsetSmall


	ld a, IEF_VBLANK
	ldh [rIE], a
	xor a
	ei
	ldh [rIF], a


	assert .spritesEnd == .tiles
	; ld de, .tiles
	ld hl, vButtonTiles
	ld bc, (.tilesEnd - .tiles) / 2
	call LCDMemcpy

	ld hl, vTextboxTopRow
	lb bc, LOW(vBorderTiles.top / 16), NB_BORDER_TOP_TILES
	assert NB_BORDER_TOP_TILES == TEXT_WIDTH_TILES + 1
.writeTopRow
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .writeTopRow
	ld a, b
	ld [hli], a
	inc b
	dec c
	jr nz, .writeTopRow

	ld hl, vText - 1
	ld c, TEXT_HEIGHT_TILES
	assert NB_BORDER_VERT_TILES == TEXT_HEIGHT_TILES * 2
.writeVertBorders
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .writeVertBorders
	ld a, b
	ld [hli], a
	inc b
	ld a, l
	add a, TEXT_WIDTH_TILES
	ld l, a
	ld a, b
	ld [hli], a
	inc b
	ld a, l
	add a, SCRN_VX_B - TEXT_WIDTH_TILES - 2
	ld l, a
	adc a, h
	sub l
	ld h, a
	dec c
	jr nz, .writeVertBorders

	inc hl
	ld c, TEXT_WIDTH_TILES + 1
	assert NB_BORDER_BOTTOM_TILES == TEXT_WIDTH_TILES + 1
.writeBottomRow
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .writeBottomRow
	ld a, b
	ld [hli], a
	inc b
	dec c
	jr nz, .writeBottomRow

	; Assuming OAM has correctly been written, start displaying sprites
	ld a, LCDCF_ON | LCDCF_OBJON | LCDCF_OBJ16 | LCDCF_BGON
	ldh [rLCDC], a


	;;;;;;;;;;;;;;;; TEXT ENGINE GLOBAL INIT ;;;;;;;;;;;;;;;;;;;;

	; You need to do the following at least once when the game starts.
	xor a
	ld [wNbPixelsDrawn], a


	ld a, BANK(PerformAnimation)
	ldh [hCurROMBank], a
	ld [rROMB0], a
	jp PerformAnimation


.sprites
	db 0, 142 + 8, LOW(vButtonTiles / 16) + 0, 0
	db 0, 142 + 8, LOW(vButtonTiles / 16) + 2, 0
	db 0, 150 + 8, LOW(vButtonTiles / 16) + 4, 0
	db 0, 150 + 8, LOW(vButtonTiles / 16) + 6, 0
.spritesEnd

.tiles
.buttonTiles
INCBIN "res/button.2bpp"
def NB_BUTTON_TILES equ (@ - .buttonTiles) / 16
def NB_BUTTON_SPRITES equ NB_BUTTON_TILES / 2

.borderTopTiles
INCBIN "res/border_top.2bpp"
def NB_BORDER_TOP_TILES equ (@ - .borderTopTiles) / 16
.borderVertTiles
INCBIN "res/border_vert.2bpp"
def NB_BORDER_VERT_TILES equ (@ - .borderVertTiles) / 16
.borderBottomTiles
INCBIN "res/border_bottom.2bpp"
def NB_BORDER_BOTTOM_TILES equ (@ - .borderBottomTiles) / 16

.tilesEnd


OAMDMA:
	ldh [rDMA], a
	ld a, OAM_COUNT
.wait
	dec a
	jr nz, .wait
	ret
.end


SECTION "LCDMemcpy", ROM0

LCDMemcpy::
	; Increment B if C is nonzero
	dec bc
	inc b
	inc c
.loop
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .loop
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

LCDMemsetSmall::
	ld b, a
LCDMemsetSmallFromB::
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, LCDMemsetSmallFromB
	ld a, b
	ld [hli], a
	dec c
	jr nz, LCDMemsetSmallFromB
	ret


SECTION "Vectors", ROM0[0]

	ret
	ds $08 - @

WaitVBlank::
	ld a, 1
	ldh [hVBlankFlag], a
.wait
	halt
	jr .wait
	ds $10 - @

MemsetSmall:
	ld [hli], a
	dec c
	jr nz, MemsetSmall
	ret
	ds $18 - @

MemcpySmall:
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, MemcpySmall
	ret
	ds $20 - @

	ret
	ds $28 - @

	ret
	ds $30 - @

	ret
	ds $38 - @

	ret
	ds $40 - @

	; VBlank handler
	push af
	ld a, HIGH(wShadowOAM)
	call hOAMDMA

	ldh a, [hVBlankFlag]
	and a
	jr z, .noVBlank

	ld c, LOW(rP1)
	ld a, P1F_GET_DPAD
	ldh [c], a
	REPT 4
	ldh a, [c]
	ENDR
	or $F0
	ld b, a
	swap b
	ld a, P1F_GET_BTN
	ldh [c], a
	REPT 4
	ldh a, [c]
	ENDR
	or $F0
	xor b
	ld b, a
	ld a, P1F_GET_NONE
	ldh [c], a
	ldh a, [hHeldButtons]
	cpl
	and b
	ldh [hPressedButtons], a
	ld a, b
	ldh [hHeldButtons], a

	pop af ; Pop return address to exit `waitVBlank`
	xor a
	ldh [hVBlankFlag], a
.noVBlank
	pop af
	reti


SECTION UNION "8800 tiles", VRAM[$8800]

vButtonTiles:
.frame0
	ds 16 * NB_BUTTON_SPRITES
.frame1
	ds 16 * NB_BUTTON_SPRITES

vBorderTiles:
.top
	ds 16 * NB_BORDER_TOP_TILES
.vert
	ds 16 * NB_BORDER_VERT_TILES
.bottom
	ds 16 * NB_BORDER_BOTTOM_TILES

vStaticTextTiles:
	ds 16 * 32
.end


SECTION UNION "9000 tiles", VRAM[$9000]

vBlankTile:
	ds 16
vTextTiles:: ; Random position for demonstration purposes
	ds 16 * 127
.end

SECTION UNION "9800 tilemap", VRAM[_SCRN0]

	ds SCRN_VX_B * 3

	ds 1
vTextboxTopRow:
	ds TEXT_WIDTH_TILES + 2
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 3

	ds 2
vText::
.row0
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 2
.row1
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 2
.row2
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 2
.row3
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 2
.row4
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 2
.row5
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 2
.row6
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 2
.row7
	ds TEXT_WIDTH_TILES
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 2

	ds 1
vTextboxBottomRow:
	ds TEXT_WIDTH_TILES + 2
	ds SCRN_VX_B - TEXT_WIDTH_TILES - 3

	ds SCRN_VX_B

	ds 3
vStaticText:
	ds SCRN_VX_B - 3


SECTION "Shadow OAM", WRAM0,ALIGN[8]

wShadowOAM:
wButtonSprites:
	ds sizeof_OAM_ATTRS * NB_BUTTON_TILES / 4

def NB_UNUSED_SPRITES equ OAM_COUNT - (@ - wShadowOAM) / sizeof_OAM_ATTRS
	ds NB_UNUSED_SPRITES * sizeof_OAM_ATTRS

SECTION "WRAM0", WRAM0

wBtnAnimCounter:
	db


SECTION "HRAM", HRAM

hCurROMBank::
	db

hVBlankFlag:
	db
hHeldButtons::
	db
hPressedButtons::
	db
hOAMDMA:
	ds OAMDMA.end - OAMDMA
