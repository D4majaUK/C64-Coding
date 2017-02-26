.pc = $0801 "Basic Upstart" 
:BasicUpstart(start) 

.pc = $1000 "Main Program" 
start: 
	lda #%01111111
	sta $dc0d
	and $d011
	sta $d011
	lda #210
	sta $d012
	
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	
	lda #%00000001
	sta $d01a

	jsr $e544

	ldx #$00
msgloop:
	lda scnl1,x
	and #$3f
	sta $0428,x
	lda scnl2,x
	and #$3f
	sta $0478,x
	lda ctrl1,x
	and #$3f
	sta $04c8,x
	lda ctrl2,x
	and #$3f
	sta $04f0,x
	lda exit,x
	and #$3f
	sta $0540,x
	inx
	cpx #39
	bne msgloop

// Draw game box
	ldx #$00
gmebox:
	lda #64
	sta $0591,x
	sta $0799,x
	inx
	cpx #38
	bne gmebox
	lda #85
	sta $0590
	lda #73
	sta $05b7
	lda #74
	sta $0798
	lda #75
	sta $07bf

/*	
gmeblx:	
	ldx #$00
gmebx1:
	lda #102
	sta $05c0,x
	sta $05fa,x
	sta $06b3,x
	sta $06d3,x
	sta $070e,x
	sta $0763,x
	inx
	cpx #5
	bne gmebx1
*/	

//Display the game board	

	ldx #$00
gmebrdlp:
	ldy #14
	lda gmebrd,x
	and #$3f
	cmp #1
	bne gmenblk
	ldy #1
	lda #102
gmenblk:
	sta $05b8,x
	tya
	sta $d9b8,x
	ldy #14
	lda gmebrd+240,x
	and #$3f
	cmp #1
	bne gmebspc
	ldy #1
	lda #102
gmebspc:
	sta $05b8+240,x
	tya
	sta $d9b8+240,x
	inx
	cpx #239
	bne gmebrdlp
	
	ldy #$00
	ldx #$00
gmeside:
	tya
	adc #40
	tay
	lda #66
	sta $058f,y
	sta $05b6,y
	sta $067f,y
	sta $06a6,y
	inx
	cpx #6
	bne gmeside

gmearw:
	lda #117
	sta $7e3
	lda #119
	sta $7e4
	lda #111
	sta $7e5
	lda #118
	sta $7e6
	
	lda #0
	sta mycnt
	sta mycnt+1
	
	jsr getloc

	lda #1
	sta $289
	lda #0
	sta $28a

keychk:		
	ldx #50
wait: 
	lda #$ff 
	cmp $d012 
	bne wait 
	dex
	bne	wait

	jsr $f142
	sta $07d0
	cmp #$00
	beq keychk

// check for space
chkspc:
	lda #127	//row
	sta $dc00
	lda $dc01
	cmp #239	//col
	beq finish	
	
// check for ','
chkcom:
	lda #223	//row
	sta $dc00
	lda $dc01
	cmp #127	//col
	bne chkdot

	dec gmeloc+1
	jsr getloc
nchkcom:
	jmp keychk
	
// check for '.'
chkdot:
	lda #223	//row
	sta $dc00
	lda $dc01
	cmp #239	//col
	bne chka

	inc gmeloc+1
	jsr getloc
nchkdot:
	jmp keychk
	
// check for 'a'
chka:
	lda #253	//row
	sta $dc00
	lda $dc01
	cmp #251	//col
	bne chkz
	
	dec gmeloc
	jsr getloc
nchka:
	jmp keychk
	
// check for 'z'
chkz:
	lda #253	//row
	sta $dc00
	lda $dc01
	cmp #239	//col
	bne nokey

	inc gmeloc
	jsr getloc
nchkz:	
	jmp keychk

// This is the end of the key checks
// nokey: is here to be clean :) 
 
nokey:
	jmp keychk

finish:
	lda #0
	sta $c6

	jsr $e544

	sei
	lda #$31
	sta $0314
	lda #$ea
	sta $0315
	
	lda #$1b
	sta $d011
	lda #$81
	sta $dc0d
	cli
	ldx #$00
extloop:
	lda scnl1,x
	and #$3f
	sta $0428,x
	lda scnl2,x
	and #$3f
	sta $0478,x
	lda fanx,x
	and #$3f
	sta $04f0,x
	lda #1
	sta $d8f0,x
	inx
	cpx #39
	bne extloop

	lda #14
	sta $d020
		
	ldx #08
rtnloop:
	lda #$0d
	jsr $ffd2
	dex
	bne rtnloop

	rts
	
getloc:	
	lda gmeloc		
	tax
	lda gmerow,x
	adc gmeloc+1
	tax

	lda gmeloc
	cmp #7
	bcc gmelow 
	lda #1
	sta $58f+240,x
	rts

gmelow:
	lda #1
	sta $58f,x

	rts

irq:
	pha
	lda $d019
	sta $d019
	txa
	pha
	tya
	pha
	
	lda #7
	sta $d020
	sta $d021
	
	lda #$1a
	sta $d011
	
	ldx #90
pause:
	nop
	nop
	nop
	dex
	bne pause
	
	lda #0
	sta $d020
	sta $d021
	
	lda #$1b
	sta $d011
	lda #$20
	sta $d012
		
	pla	
	tay	
	pla	
	tax	
	pla	
		
	lda #6	
	sta $d021	
		
	inc mycnt
	lda mycnt
	cmp #10
	bne cntout
	inc mycnt+1
	ldx mycnt+1
	cpx #10
	bne chgcol
	lda #0
	sta mycnt+1
chgcol:
	lda mycol,x
	sta $d82f
	sta $d830
	sta $d831
	sta $d832
	sta $d833
	sta $d834
	sta $d836
	sta $d837
	lda #0
	sta mycnt
cntout:	
	
	jmp $ea31
	
scnl1:	.text "  **** DAMAJA UK  CBM 64 BASIC V2 **** "
scnl2:	.text " 64K RAM SYSTEM  38911 BASIC BYTES FREE"
ctrl1:	.text " CONTROLS: 'A' FOR UP     'Z' FOR DOWN "
ctrl2:	.text "           ',' FOR LEFT   '.' FOR RIGHT"
exit:	.text " PRESS 'SPACE' TO EXIT                 "
fanx:	.text " THANKS FOR PLAYING                    "

gmebrd:	.text " AA       AA               AA  AAAAAAAA "
		.text " AAAAAA   AAAAAAAAA        AA  A     AA "
		.text " A    A   A        AAAAAA      A    AA  "
		.text " A AA A      AAAAA             AAAAAA   "
		.text " AA  AA   A      A    AAAAAA            "
		.text " AAAAAA   AAAAA  A               AAAAAA "
		.text " A AA A       A  AAAAA              A   "
		.text " AAAAAA       A           AAAAAAA       "
		.text "              AAAA                      "
		.text "    AAAAAAAA          AAAAAA   AAAAAAAA "
		.text "    A  AA  A          AAAAAA            "
		.text "    AAAAAA   AAAAAAA       AAAAAA     A "
gmeloc:	.byte 9, 20
gmerow:	.byte 0, 40, 80, 120, 160, 200, 200, 160, 120, 80, 40, 0

mycnt:	.byte 0, 0
mycol:	.byte 1,15,12,11,0,11,12,15,1,1