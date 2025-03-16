	.equ	ADDR_LEFT8 = $24
	.equ	ADDR_RIGHT8 = $25

	.equ	SCL = PC0
	.equ	SDA = PC1

NUMBER_TABLE:
	.db		$3F,$6,$5B,$4F,$66,$6D,$7D,$7,$7F,$6F, $77, $7C, $39, $5E, $79, $71
			;0,  1, 2,  3,  4,  5,  6,  7, 8,  9,   A,   B,   C,    D,   E,   F	


//////////////////////////////////////LEFT8_WRITE(r20=poäng som ska visas): skriver till vänstra 7-segmentet
LEFT8_WRITE:
	push	r18
	push	r20
	push	r21
	
	ldi		r18,8
	call	LOOK_UP

	ldi		r21, ADDR_LEFT8
	call	TWI_WRITE

	pop		r21
	pop		r20
	pop		r18

	ret

//////////////////////////////////////RIGHT8_WRITE(r20=poäng som ska visas): skriver till högra 7-segmentet
RIGHT8_WRITE:
	push	r18
	push	r20
	push	r21
	
	ldi		r18,8
	call	LOOK_UP

	ldi		r21, ADDR_RIGHT8
	call	TWI_WRITE

	pop		r21
	pop		r20
	pop		r18

	ret

//////////////////////////////////////TWI_WRITE(r21=adress, r23=data)
TWI_WRITE:
	call	START

	lsl		r21
	call	TWI_SEND81
	mov		r21, r23
	call	TWI_SEND81

	call	STOP
	ret

//////////////////////////////////////TWI_SEND(r21=data (addres eller data som ska skickas))
TWI_SEND81:
	lsl		r21
	brcc	NUMBER_IS_0
	brcs	NUMBER_IS_1			
NUMBER_IS_0:
	call	SDL
	jmp		DEC_LOOP
NUMBER_IS_1:
	call	SDH
DEC_LOOP:
	dec		r18
	brne	TWI_SEND81
	ldi		r18,8
	call	SDH				
	ret

//////////////////////////////////////LOOK_UP(r20=siffra) -> r23=bitmönster
LOOK_UP:
	mov		r23,r20
	ldi		ZH,HIGH(NUMBER_TABLE*2)
	ldi		ZL,LOW(NUMBER_TABLE*2)
	add		ZL,r23
	clr		r23
	adc		ZH,r23
	lpm		r23,Z
	inc		r20
	cpi		r20, 16
	breq	RESET_R20
	jmp		END_LOOK_UP
RESET_R20:
	clr		r20
END_LOOK_UP:
	ret














START:					//sätter bussens tillstånd till START (1)
	sbi		DDRC,SDA
	call	WAIT
	sbi		DDRC,SCL
	call	WAIT
	ret

STOP:					//sätter bussens tillstånd till STOP (0)
	sbi		DDRC,SDA
	call	WAIT
	cbi		DDRC, SCL
	call	WAIT
	cbi		DDRC,SDA
	call	WAIT
	ret

SDL:					//skickar en 0:a som data och klockar igenom det
	sbi		DDRC,SDA
	call	WAIT
	cbi		DDRC,SCL
	call	WAIT
	sbi		DDRC,SCL
	call	WAIT
	ret

SDH:					//skickar en 1:a som data och klockar igenom det
	cbi		DDRC,SDA
	call	WAIT
	cbi		DDRC,SCL
	call	WAIT
	sbi		DDRC,SCL
	call	WAIT
	ret

//////////////////////////////////////WAIT(TWI-delay, borde ge ungefär 10 mikrosekunders delay	)
WAIT:	
	ldi		r24,10
	ldi		r25,1
	
	call	DELAY_16
	ret