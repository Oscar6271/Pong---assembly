	/*Funktioner som andra program f�r anv�nda (resterande �r privata):

		HW_INIT(): s�tt start pos och f�rg p� boll och spelare. s�tt register f�r SPI

		ERASE_VMEM(): Tar bort allt i VMEM f�rutom anod (m�nstret f�r raden)

		RESET_VMEM() -> r19=BSPEEDY, r16=BSPEEDX: sparar bollens nya position(5,4), rensar och s�tter tillbaka spelare och boll

		SET_RIGHT_PLAYER(): s�tter bitm�nster f�r h�gra spelare
		SET_LEFT_PLAYER(): s�tter bitm�nster f�r v�nstra spelare
		SET_BALL(): s�tter bitm�nster f�r bollen

		CLEAR_RIGHT_PLAYER: tar bort h�ger spelare
		CLEAR_LEFT_PLAYER: tar bort v�nster spelare
		CLEAR_BALL: tar bort bollen fr�n videominnet

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
	VMEM:		.byte VMEM_SZ		//Bl�, Gr�n, R�d, Rad

	LPOSX:		.byte 1
	LPOSY:		.byte 1
	LCOLOR:		.byte 1
	LPOINT:		.byte 1

	RPOSX:		.byte 1
	RPOSY:		.byte 1
	RCOLOR:		.byte 1
	RPOINT:		.byte 1
	
	BPOSX:		.byte 1
	BPOSY:		.byte 1
	BCOLOR:		.byte 1
	BSPEEDX:	.byte 1
	BSPEEDY:	.byte 1

	LINE:		.byte 1	
	.cseg

//////////////////////////////////RESET_VMEM() -> r19=BSPEEDY, r16=BSPEEDX: sparar bollens nya position(5,4), rensar och s�tter tillbaka spelare och boll
RESET_VMEM:
	call	ERASE_VMEM
	call	SET_LEFT_PLAYER
	call	SET_RIGHT_PLAYER
	ldi		r17,5
	sts		BPOSX,r17
	ldi		r17,4
	sts		BPOSY,r17
	ldi		r16,1
	clr		r19
	ret

//////////////////////////////////SET_RIGHT_PLAYER(): s�tter bitm�nster f�r h�gra spelare
SET_RIGHT_PLAYER:
	ldi		ZL,LOW(RPOSX)
	ldi		ZH,HIGH(RPOSX)
	call	SETPOS
	mov		r17,r16
	lds		r18,RPOSY
	lds		r19,RCOLOR
	call	SET_PLAYER_PRIVATE

	ret


//////////////////////////////////SET_LEFT_PLAYER(): s�tter bitm�nster f�r v�nstra spelare
SET_LEFT_PLAYER:
	ldi		ZL,LOW(LPOSX)
	ldi		ZH,HIGH(LPOSX)
	call	SETPOS
	mov		r17,r16
	lds		r18,LPOSY
	lds		r19,LCOLOR
	call	SET_PLAYER_PRIVATE

	ret


//////////////////////////////////SET_BALL(): s�tter bitm�nster f�r bollen
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


/////////////////////////////////CLEAR_BALL: tar bort bollen fr�n videominnet
CLEAR_BALL:
	lds		r18,BPOSY
	lds		r19,BCOLOR
	ldi		ZL,LOW(VMEM)
	call	CHECK_Y_POS

	ld		r17,Z
	andi	r17,0b10000001
	st		Z,r17
	ret	


//////////////////////////////////CLEAR_LEFT_PLAYER: tar bort v�nster spelare
CLEAR_LEFT_PLAYER:
	push	r20

	lds		r18,LPOSY
	lds		r19,LCOLOR
	ldi		r20,0b01111111
	call	CLEAR_PLAYER

	pop		r20
	ret


//////////////////////////////////CLEAR_RIGHT_PLAYER: tar bort h�ger spelare
CLEAR_RIGHT_PLAYER:
	push	r20

	lds		r18,RPOSY
	lds		r19,RCOLOR
	ldi		r20,0b11111110
	call	CLEAR_PLAYER

	pop		r20
	ret

//////////////////////////////////HW_INIT: s�tt start pos och f�rg p� boll och spelare. s�tt register f�r SPI och annat
HW_INIT:
	ldi		r17,7
	sts		LPOSX,r17

	ldi		r17,6
	sts		LPOSY,r17

	ldi		r17,RED
	sts		LCOLOR,r17

	ldi		r17,0
	sts		RPOSX,r17

	ldi		r17,5
	sts		RPOSY,r17

	ldi		r17,BLUE
	sts		RCOLOR,r17

	ldi		r17,5
	sts		BPOSX,r17

	ldi		r17,4
	sts		BPOSY,r17

	ldi		r17,GREEN
	sts		BCOLOR,r17

	ldi		r17,-1
	sts		BSPEEDX,r17

	clr		r17
	sts		BSPEEDY,r17

	sts		LPOINT,r17
	sts		RPOINT,r17

	call	ERASE_VMEM

	ldi		r17,$FE
	call	SET_ANOD

	call	SPI_INIT

	call	SET_LEFT_PLAYER
	call	SET_RIGHT_PLAYER
	call	SET_BALL

	ret

//////////////////////////////////SPI_INIT(): Initierar allt med SPI
SPI_INIT:
	ldi		r17,(1<<MOSI) | (1<<SCK) | (1<<SS) //�ndra s� att man skriver MSB f�rst ist�llet f�r LSB, eller tv�rtom
	out		DDRB,r17

	ldi		r17,(1<<SPE) | (1<<MSTR) | (1<<SPR0)
	out		SPCR,r17
	sei

	ret


//////////////////////////////////ERASE_VMEM(): Tar bort allt i VMEM f�rutom anod
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


//////////////////////////////////SET_ANOD(r17=m�nstret f�r f�rsta raden): s�tter m�nstret f�r varje rad
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

//////////////////////////////////MUX(): multiplexar sk�rmen
MUX:
	push	r16
	push	r17
	push	r18

	ldi		ZL,LOW(VMEM)
	ldi		ZH,HIGH(VMEM)

	lds		r17,LINE
	add		ZL,r17

	ldi		r18,4
MUX_LOOP:
	ld		r16,Z+
	call	SPI_SEND
	inc		r17
	dec		r18
	brne	MUX_LOOP

	sbi		PORTB,SS
	cbi		PORTB,SS

	cpi		r17,32
	brlo	LINE_OK
	clr		r17
LINE_OK:
	sts		LINE,r17

	pop		r18
	pop		r17
	pop		r16

	ret


//////////////////////////////////SPI_SEND(r16=data): skickar data till diodmatrisen
SPI_SEND:
	out		SPDR,r16
WAIT_TRANSFER:
	sbis	SPSR,SPIF
	jmp		WAIT_TRANSFER

	ret


//////////////////////////////////CLEAR_PLAYER(r20=0b11111110 om man vill ta bort h�gra spelaren, 0b01111111 f�r v�nstra,
											 //r18=spelarens y-pos, r19=spelarens f�rg): tar bort spelaren fr�n spelplanen
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


//////////////////////////////////SETPOS(Z=spelarens x-position, r18=1 f�r h�gerspelare, 0 f�r v�nster, r19=f�rg)->r17=nya bitm�nstret f�r raden
SETPOS:
	ld		r17,Z+
	call	SETBIT
	ld		r17,Z			//laddar in y-positionen

	ldi		ZL,LOW(VMEM)
	add		r17,r19			
	add		ZL,r17			//s�tter Z p� VMEM+(y.pos)+f�rg
	ld		r17,Z			//laddar in det v�rdet. Kan bli fel, kanske beh�ver CHECK_Y_POS h�r

	ldi		ZL,LOW(VMEM)	//beh�vs f�r att man ska starta fr�n b�rjan av VMEM, annars blir det fel i CHECK_Y_POS
	or		r17,r16
	ret



//////////////////////////////////SET_PLAYER_PRIVATE(Z=rad och f�rg d�r spelare ska sparas): G�r spelaren till 3 dioder stor
SET_PLAYER_PRIVATE:
	call	CHECK_Y_POS
	ldi		r21,3
SET_PLAYER_LOOP:
	clr		r16
	mov		r16,r17
	ld		r18,Z				//Beh�vs f�r att man inte ska ta bort
	or		r16,r18				//det som finns p� raden sen tidigare
	st		Z,r16
	subi	ZL,VMEM_SECTION_SZ	
	dec		r21
	brne	SET_PLAYER_LOOP	 

	ret


//////////////////////////////////CHECK_Y_POS(r18=Y-position,r19=f�rg): s�tter in Z-pekaren p� r�tt rad och f�rg i VMEM
CHECK_Y_POS:
	lsl		r18
	lsl		r18
	add		ZL,r18
	add		ZL,r19

	ret


//////////////////////////////////SETBIT(r17=X-position)
SETBIT:
	ldi		r16,1
SETBIT_LOOP:
	dec		r17
	brmi	SETBIT_END
	lsl		r16
	jmp		SETBIT_LOOP
SETBIT_END:
	ret