.var music = LoadSid("dmj-01.sid")
.pc=music.location "Music"
.fill music.size, music.getData(i)

.print ""
.print "SID Data"
.print "--------"
.print "location=$"+toHexString(music.location)
.print "init=$"+toHexString(music.init)
.print "play=$"+toHexString(music.play)
.print "songs="+music.songs
.print "startSong="+music.startSong
.print "size=$"+toHexString(music.size)
.print "name="+music.name
.print "author="+music.author
.print "copyright="+music.copyright

.print ""
.print "Additional tech data"
.print "--------------------"
.print "header="+music.header
.print "header version="+music.version
.print "flags="+toBinaryString(music.flags)
.print "speed="+toBinaryString(music.speed)
.print "startpage="+music.startpage
.print "pagelength="+music.pagelength

.pc = $2000 "Sprite Data 1"
.import c64 "EN1sprite-T0-S5-M1_B-M2_1.prg"

.pc = $0801 "Basic Upstart" 
:BasicUpstart(start) 

.pc = $0820 "Main Program" 
start: 

// set up sprite

sprites:
	lda sp0ct
	sta 2040	// sprite 0 data pointer
	lda #10
	sta 53287	// sprite 0 color register
	lda #0
	sta 53248	// sprite 0 x-position
	lda #100
	sta 53249	// sprite 0 y-position 

	lda sp0ct
	sta 2041	// sprite 1 data pointer
	lda #3
	sta 53288	// sprite 1 color register
	lda #0
	sta 53250	// sprite 1 x-position
	lda #13
	sta 53251	// sprite 1 y-position 

	lda sp0ct
	sta 2042	// sprite 2 data pointer
	lda #7
	sta 53289	// sprite 2 color register
	lda #10
	sta 53252	// sprite 2 x-position
	lda #13
	sta 53253	// sprite 2 y-position 

	lda #7
	sta 53269	// sprite enabler
	lda #2
	sta 53285	// multi-color 0 register
	lda #1
	sta 53286	// multi-color 1 register
	lda #7
	sta 53276	// multi-color register

	ldx #0
	ldy #0
	lda #music.startSong-1
	jsr music.init

	sei
	lda #$7f
	sta 56333
	sta 56589
	lda #$01
	sta 53274
	
	lda #$1b
	ldx #$08
	ldy #$14
	sta 53265
	stx 53270
	sty 53272
	
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	
	ldy #00
	sty 53266

	lda 56333
	lda 56589
	asl 53273
	cli
	
	lda #15
	sta 646	// text colour
	
	jsr $e544

	ldx #$00
msgloop:
	lda scnl1,x
	and #$3f
	sta $0428,x
	lda scnl2,x
	and #$3f
	sta $0478,x
	inx
	cpx #39
	bne msgloop

	ldx #08
crloop:
	lda #$0d
	jsr $ffd2
	dex
	bne crloop

gfxbord:
	lda #0
	sta mycnt+1
	lda #192
	sta $3fff

dontQuit:
	jmp dontQuit
	
	rts

irq:
	lda #11
	sta $d020
	lda #12
	sta $d021
	
	lda #<irq2
	sta $0314
	lda #>irq2
	sta $0315
	
	ldy #80
	sty $d012
	asl $d019

	jmp $ea81
	
irq2:
	lda #3
	sta $d020
	lda #12
	sta $d021
	
	lda #<irq3
	sta $0314
	lda #>irq3
	sta $0315
	
	ldy #100
	sty $d012
	asl $d019

	jmp $ea81
	
irq3:
	lda #14
	sta $d020
	nop
	nop
	nop
	lda #6
	sta $d021
	
	lda #<irq4
	sta $0314
	lda #>irq4
	sta $0315
	
	ldy #120
	sty $d012
	asl $d019

	inc mycnt
	lda mycnt
	cmp #8
	bne irqnc
	lda #0
	sta mycnt

// move sprite 0	
	jsr rotspr0
	jsr movspr0
	jsr movspr0
	jsr movspr0
	jsr movspr0
	jsr movspr0
	jsr movspr0
		
irqnc:	
	jmp $ea81
	
irq4:
	lda #3
	sta $d020
	nop
	nop
	nop
	nop
	lda #12
	sta $d021
	
	lda #<irq5
	sta $0314
	lda #>irq5
	sta $0315
	
	ldy #180
	sty $d012
	asl $d019

	jmp $ea81
	
irq5:
	lda #3
	sta $d020
	nop
	nop
	nop
	nop
	nop
	nop
	lda #4
	sta $d021

	lda #<irq6
	sta $0314
	lda #>irq6
	sta $0315
	
	ldy #230
	sty $d012
	asl $d019

	jmp $ea81

irq6:
// open the border
irq6a:
	lda $d012
	cmp #$fa
	bne irq6a
	lda #$13
	sta 53265

	lda #4
	sta $d020

	inc mycnt+1
	lda mycnt+1
	cmp #3
	bne noshift
	lda #0
	sta mycnt+1
	asl $3fff
	lda $3fff
	cmp #0
	bne noshift
	lda #$1
	sta $3fff
	
noshift:
	
irq6b:
	lda $d012
	cmp #$ff
	bne irq6b
	lda #$1b
	sta 53265

	lda #<irq7
	sta $0314
	lda #>irq7
	sta $0315
	
	jsr movspr1
	jsr movspr2
	jsr movspr2
	
	jmp $ea81

	
irq7:
	lda #4
	sta $d020
	sta $d021
	
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	
	ldy #0
	sty $d012
	asl $d019

	jsr music.play 

	jmp $ea81

pause:
	tay
psey:
	nop
	dey
	bne psey	
	dex
	bne pause
	rts

movspr1:
	lda sp1ct+1
	cmp #1
	beq movspr1MSB
	inc 53250
	lda 53250
	cmp #0
	beq rstmov1
	rts

movspr1MSB:
	inc 53250
	lda 53250
	cmp #80
	bne ms1MSB
	lda #0
	sta sp1ct+1
	sta 53250
	lda 53264
	and #%11111101
	sta 53264
ms1MSB:	
	rts

rstmov1:
	lda #1
	sta sp1ct+1
	lda 53264
	ora #%00000010
	sta 53264
	rts

movspr2:
	lda sp2ct+1
	cmp #1
	beq movspr2MSB
	inc 53252
	lda 53252
	cmp #0
	beq rstmov2
	rts

movspr2MSB:
	inc 53252
	lda 53252
	cmp #80
	bne ms2MSB
	lda #0
	sta sp2ct+1
	sta 53252
	lda 53264
	and #%11111011
	sta 53264
ms2MSB:	
	rts

rstmov2:
	lda #1
	sta sp2ct+1
	lda 53264
	ora #%00000100
	sta 53264
	rts

movspr0:
	lda sp0ct+2
//	sta $07d1
	cmp #1	
	bne revspr0	
	lda sp0ct+1
//	sta $07d0
	cmp #0
	bne movspr0MSB
	inc 53248
	lda 53248
	cmp #0
	beq rstmov0
	rts

revspr0:
	lda sp0ct+1
//	sta $07d0
	cmp #0
	bne revspr0MSB
	dec 53248
	lda 53248
	cmp #21
	bne rs0
	lda #1
	sta sp0ct+2
rs0:
	rts
	
rstmov0:
	lda #1
	sta sp0ct+1
	sta 53264
	rts

revspr0MSB:
	dec 53248
	lda 53248
	cmp #0
	bne rs0MSB
	lda #0
	sta 53264
	sta sp0ct+1
	lda #255
	sta 53248
rs0MSB:
	rts

movspr0MSB:
	inc 53248
	lda 53248
	cmp #66
	bne ms0MSB
	lda #0
//	sta $07d0
	sta sp0ct+2
//	sta 53280
ms0MSB:	
	
	rts

rotspr0:
	lda sp0ct+2
	cmp #1
	bne rotspr0r
	inc sp0ct
	lda sp0ct
	cmp #136
	bne rot0
	lda #128
rot0:
	sta sp0ct
	sta $7f8
	rts

rotspr0r:
	dec sp0ct
	lda sp0ct
	cmp #127
	bne rot0r
	lda #135
rot0r:
	sta sp0ct
	sta $7f8
	rts

scnl1:	.text "  **** DAMAJA UK  CBM 64 BASIC V2 **** "
scnl2:	.text " 64K RAM SYSTEM  38911 BASIC BYTES FREE"

mycnt: .byte 0,0
sp0ct: .byte 128, 0, 1	// Sprite pointer, msb, direction
sp1ct: .byte 128, 0, 1	// Sprite pointer, msb, direction
sp2ct: .byte 128, 0, 1	// Sprite pointer, msb, direction
