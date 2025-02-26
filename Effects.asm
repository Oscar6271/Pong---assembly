/*
 * Effects.asm
 *
 *  Created: 2025-02-26 11:33:49
 *   Author: ludbr478
 */ 
 //r17 bitmönster

 //BGR rad
 START_EFFECT:
	ldi		ZL,LOW(VMEM)
	ldi		r18,8
	ldi		r17,$FF
	clr		r21
	ldi		r19, 0b00001010 // Tre sista bitarna ändrar färg, RGB
START_EFFECT_OUTERLOOP:
	ldi		r16,VMEM_COLOR_SECTION_SZ	;3
	mov		r20,r19
START_EFFECT_INNERLOOP:
	sbrc	r20,0
	st		Z+,r17
	sbrs	r20,0
	st		Z+,r21

	call	EFFECT_DELAY

	lsr		r20
	dec		r16
	brne	START_EFFECT_INNERLOOP
	inc		ZL
	dec		r18
	brne	START_EFFECT_OUTERLOOP

	ldi		r16,100
	ldi		r17,50
	call	BEEP
	ret


EFFECT_DELAY:
	push	r16
	push	r17
	ldi		r16,100		; Decimal bas
EFFECT_delayYttreLoop:
	ldi		r17,$FF
EFFECT_delayInreLoop:
	dec		r17
	brne	EFFECT_delayInreLoop
	dec		r16
	brne	EFFECT_delayYttreLoop
	pop		r17
	pop		r16
	ret

