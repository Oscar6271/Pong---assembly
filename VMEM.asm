	/*Funktioner som andra program fr anvnda (resterande r privata):

		HW_INIT(): stt start pos och frg p boll och spelare. stt register fr SPI

		ERASE_VMEM(): Tar bort allt i VMEM frutom anod (mnstret fr raden)

		RESET_VMEM() -> r19=BSPEEDY, r16=BSPEEDX: sparar bollens nya position(5,4), rensar och stter tillbaka spelare och boll

		SET_RIGHT_PLAYER(): stter bitmnster fr hgra spelare
		SET_LEFT_PLAYER(): stter bitmnster fr vnstra spelare
		SET_BALL(): stter bitmnster fr bollen

		CLEAR_RIGHT_PLAYER: tar bort hger spelare
		CLEAR_LEFT_PLAYER: tar bort vnster spelare
		CLEAR_BALL: tar bort bollen frn videominnet

	*/	
	.equ	RED	= 2
	.equ	GREEN = 1
	.equ	BLUE = 0

	.equ	VMEM_SZ	= 32
	.equ	VMEM_SECTION_SZ = 4
	.equ	VMEM_COLOR_SECTION_SZ = 3

	.equ	SS = PB4
	.equ	MOSI = PB5
	.equ	SCK = PB7


	.dseg
.org SRAM_START
	VMEM:		.byte VMEM_SZ		//Bl, Grn, Rd, Rad
	
	BPOSX:		.byte 1
	BPOSY:		.byte 1
	BCOLOR:		.byte 1
	BSPEEDX:	.byte 1
	BSPEEDY:	.byte 1

.org SRAM_START+100
	RPOSY:		.byte 1

.org SRAM_START+110
	RCOLOR:		.byte 1

.org SRAM_START+120
	RPOINT:		.byte 1

.org SRAM_START+130
	LPOSY:		.byte 1

.org SRAM_START+140
	LCOLOR:		.byte 1

.org SRAM_START+150
	LPOINT:		.byte 1

.org SRAM_START+160
	LINE:		.byte 1	
	.cseg

//////////////////////////////////RESET_VMEM() -> r19=BSPEEDY, r16=BSPEEDX: sparar bollens nya position(4,4), rensar och stter tillbaka spelare och boll
RESET_VMEM:
	call	ERASE_VMEM
	call	SET_LEFT_PLAYER
	call	SET_RIGHT_PLAYER
	ldi		r17,4
	sts		BPOSX,r17
	ldi		r17,4
	sts		BPOSY,r17
	
	sts		BSPEEDX,r20
	clr		r19
	sts		BSPEEDY,r19
	ret

//////////////////////////////////SET_RIGHT_PLAYER(): stter bitmnster fr hgra spelare
SET_RIGHT_PLAYER:
	ldi		r17,$01
	ldi		ZL,LOW(VMEM)
	ldi		ZH,HIGH(VMEM)

	lds		r18,RPOSY
	lds		r19,RCOLOR
	call	SET_PLAYER_PRIVATE

	ret


//////////////////////////////////SET_LEFT_PLAYER(): stter bitmnster fr vnstra spelare
SET_LEFT_PLAYER:
	ldi		r17,$80
	ldi		ZL,LOW(VMEM)
	ldi		ZH,HIGH(VMEM)

	lds		r18,LPOSY
	lds		r19,LCOLOR
	call	SET_PLAYER_PRIVATE

	ret


//////////////////////////////////SET_BALL(): stter bitmnster fr bollen
SET_BALL:
	ldi		ZL,LOW(BPOSX)
	ldi		ZH,HIGH(BPOSX)

	call	SETPOS

	lds		r18,BPOSY
	lds		r19,BCOLOR
	call	CHECK_Y_POS

	ld		r18,Z
	or		r16,r18
	st		Z,r16
	ret


/////////////////////////////////CLEAR_BALL: tar bort bollen frn videominnet
CLEAR_BALL:
	lds		r18,BPOSY
	lds		r19,BCOLOR
	ldi		ZL,LOW(VMEM)
	call	CHECK_Y_POS

	ld		r17,Z
	andi	r17,0b10000001
	st		Z,r17
	ret	


//////////////////////////////////CLEAR_LEFT_PLAYER: tar bort vnster spelare
CLEAR_LEFT_PLAYER:
	push	r20

	lds		r18,LPOSY
	lds		r19,LCOLOR
	ldi		r20,0b01111111
	call	CLEAR_PLAYER

	pop		r20
	ret


//////////////////////////////////CLEAR_RIGHT_PLAYER: tar bort hger spelare
CLEAR_RIGHT_PLAYER:
	push	r20

	lds		r18,RPOSY
	lds		r19,RCOLOR
	ldi		r20,0b11111110
	call	CLEAR_PLAYER

	pop		r20
	ret

//////////////////////////////////HW_INIT: stt start pos och frg p boll och spelare. stt register fr SPI och annat
HW_INIT:
	call	ERASE_VMEM
	call	INTERRUPT_INIT
	call	SPI_INIT

	ldi		r17,$FE
	call	SET_ANOD

	clr		r20

	call	RIGHT8_WRITE
	call	LEFT8_WRITE

	sts		LINE,r20

	ret

PLAYER_INIT:
	ldi		r17,5
	sts		LPOSY,r17

	ldi		r17,RED
	sts		LCOLOR,r17

	ldi		r17,5
	sts		RPOSY,r17

	ldi		r17,BLUE
	sts		RCOLOR,r17

	ldi		r17,3
	sts		BPOSX,r17

	ldi		r17,4
	sts		BPOSY,r17

	ldi		r17,GREEN
	sts		BCOLOR,r17

	ldi		r17,1
	sts		BSPEEDX,r17

	clr		r17
	sts		BSPEEDY,r17

	sts		LPOINT,r17
	sts		RPOINT,r17

	call	ERASE_VMEM

	call	SET_LEFT_PLAYER
	call	SET_RIGHT_PLAYER
	call	SET_BALL

	ret

//////////////////////////////////SPI_INIT(): Initierar allt med SPI
SPI_INIT:
	ldi		r17,(1<<MOSI) | (1<<SCK) | (1<<SS) 
	out		DDRB,r17

	ldi		r17,(1<<SPE) | (1<<MSTR) | (1<<SPR0)
	out		SPCR,r17
	
	ret

//////////////////////////////////INTERRUPT_INIT(): Initierar timer0 för avbrott
INTERRUPT_INIT:
	ldi		r17, (1<<CS01) | (1<<CS00)
	out		TCCR0,r17

	ldi		r17, (1<<TOIE0)
	out		TIMSK, r17

	sei
	ret

//////////////////////////////////ERASE_VMEM(): Tar bort allt i VMEM frutom anod
ERASE_VMEM:
	ldi		ZL,LOW(VMEM)
	ldi		r18,8
	clr		r17
ERASE_VMEM_OUTERLOOP:
	ldi		r16,VMEM_COLOR_SECTION_SZ	
ERASE_VMEM_INNERLOOP:
	st		Z+,r17
	dec		r16
	brne	ERASE_VMEM_INNERLOOP
	inc		ZL
	dec		r18
	brne	ERASE_VMEM_OUTERLOOP
	ret


//////////////////////////////////SET_ANOD(r17=mnstret fr frsta raden): stter mnstret fr varje rad
SET_ANOD:
	ldi		ZL,LOW(VMEM)
	ldi		r16,VMEM_COLOR_SECTION_SZ
	add		ZL,r16
	st		Z,r17
	ldi		r18,7
SET_ANOD_LOOP:
	lsl		r17
	ori		r17,1
	ldi		r16,VMEM_SECTION_SZ
	add		ZL,r16
	st		Z,r17
	dec		r18
	brne	SET_ANOD_LOOP
	ret

//////////////////////////////////MUX(): multiplexar skrmen
MUX:
	push	r16
	in		r16,SREG
	push	r16
	push	r17
	push	r18
	push	ZL
	push	ZH

	ldi		ZL,LOW(VMEM)
	ldi		ZH,HIGH(VMEM)

	sbi		PORTB,SS

	lds		r17,LINE
	add		ZL,r17

	ldi		r18,4
MUX_LOOP:
	ld		r16,Z+

	out		SPDR,r16			//SPI_SEND(r16=data): skickar data till diodmatrisen
WAIT_TRANSFER:
	sbis	SPSR,SPIF
	jmp		WAIT_TRANSFER

	inc		r17
	dec		r18
	brne	MUX_LOOP

	cbi		PORTB,SS

	cpi		r17,32
	brlo	LINE_OK
	clr		r17
LINE_OK:
	sts		LINE,r17

	pop		ZH
	pop		ZL
	pop		r18
	pop		r17
	pop		r16
	out		SREG,r16
	pop		r16

	reti


//////////////////////////////////CLEAR_PLAYER(r20=0b11111110 om man vill ta bort hgra spelaren, 0b01111111 fr vnstra,
											 //r18=spelarens y-pos, r19=spelarens frg): tar bort spelaren frn spelplanen
CLEAR_PLAYER:
	ldi		ZL,LOW(VMEM)
	call	CHECK_Y_POS
	ldi		r16,3
CLEAR_PLAYER_LOOP:
	ld		r17,Z
	and		r17,r20
	st		Z,r17
	subi	ZL,VMEM_SECTION_SZ
	dec		r16
	brne	CLEAR_PLAYER_LOOP
	ret


//////////////////////////////////SETPOS(Z=spelarens x-position, r18=1 fr hgerspelare, 0 fr vnster, r19=frg)->r17=nya bitmnstret fr raden
SETPOS:
	ld		r17,Z+
	call	SETBIT
	ld		r17,Z			//laddar in y-positionen

	ldi		ZL,LOW(VMEM)
	add		r17,r19			
	add		ZL,r17			//stter Z p VMEM+(y.pos)+frg
	ld		r17,Z			//laddar in det vrdet. Kan bli fel, kanske behver CHECK_Y_POS hr

	ldi		ZL,LOW(VMEM)	//behvs fr att man ska starta frn brjan av VMEM, annars blir det fel i CHECK_Y_POS
	or		r17,r16
	ret



//////////////////////////////////SET_PLAYER_PRIVATE(Z=rad och frg dr spelare ska sparas): Gr spelaren till 3 dioder stor
SET_PLAYER_PRIVATE:
	call	CHECK_Y_POS
	ldi		r21,3
SET_PLAYER_LOOP:
	clr		r16
	mov		r16,r17
	ld		r18,Z				//Behvs fr att man inte ska ta bort
	or		r16,r18				//det som finns p raden sen tidigare
	st		Z,r16
	subi	ZL,VMEM_SECTION_SZ	
	dec		r21
	brne	SET_PLAYER_LOOP	 

	ret


//////////////////////////////////CHECK_Y_POS(r18=Y-position,r19=frg): stter in Z-pekaren p rtt rad och frg i VMEM
CHECK_Y_POS:
	lsl		r18
	lsl		r18
	add		ZL,r18
	add		ZL,r19

	ret


//////////////////////////////////SETBIT(r17=X-position)
SETBIT:
	clr		r16
	ldi		r16,1
SETBIT_LOOP:
	dec		r17
	brmi	SETBIT_END
	lsl		r16
	jmp		SETBIT_LOOP
SETBIT_END:
	ret
