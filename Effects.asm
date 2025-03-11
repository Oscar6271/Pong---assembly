/*
 * Effects.asm
 *
 *  Created: 2025-02-26 11:33:49
 *   Author: ludbr478
 */ 
 //r17 bitmönster

 //BGR rad
 START_EFFECT:
	ldi		r19, 0b00000100 // Tre sista bitarna ändrar färg, RGB
	call	EFFECT

	ldi		r16,200
	ldi		r17,100
	call	EFFECT_DELAY
	cli
	call	BEEP
	sei

	ldi		r19, 0b00000110 // Tre sista bitarna ändrar färg, RGB
	call	EFFECT

	ldi		r16,200
	ldi		r17,100
	call	EFFECT_DELAY
	cli
	call	BEEP
	sei

	ldi		r19, 0b00000010 // Tre sista bitarna ändrar färg, RGB
	call	EFFECT

	ldi		r16,200
	ldi		r17,100
	call	EFFECT_DELAY
	cli
	call	BEEP
	sei

	ret

GAME_OVER_EFFECT:
	
	call	EFFECT

	ldi		r16,100
	ldi		r17,100
	call	EFFECT_DELAY

	cli
	call	BEEP
	sei

	call	EFFECT

	ldi		r16,100
	ldi		r17,100

	call	EFFECT_DELAY

	cli
	call	BEEP
	sei

	ret

 EFFECT:
	ldi		ZL,LOW(VMEM)
	ldi		ZH,HIGH(VMEM)
	
	ldi		r18,8
	ldi		r17,$FF
	clr		r21
	
EFFECT_OUTERLOOP:
	ldi		r16,3			;VMEM_COLOR_SECTION_SZ	;3
	mov		r20,r19
EFFECT_INNERLOOP:
	sbrc	r20,0
	st		Z+,r17
	sbrs	r20,0
	st		Z+,r21

	call	EFFECT_DELAY

	lsr		r20
	dec		r16
	brne	EFFECT_INNERLOOP
	inc		ZL
	dec		r18
	brne	EFFECT_OUTERLOOP

	call	ERASE_VMEM
	
	ret


EFFECT_DELAY:
	push	r16
	push	r17
	push	r18
	ldi		r18,4
EFFECT_LONG_DELAY:
	
	ldi		r16,255		; Decimal bas
EFFECT_delayYttreLoop:
	ldi		r17,$A1
EFFECT_delayInreLoop:
	dec		r17
	brne	EFFECT_delayInreLoop
	dec		r16
	brne	EFFECT_delayYttreLoop
	dec		r18
	brne	EFFECT_LONG_DELAY
	pop		r18
	pop		r17
	pop		r16
	ret

