/*
 * Effects.asm
 *
 *  Created: 2025-02-26 11:33:49
 *   Author: ludbr478
 */ 
 //r17 bitmönster

 //BGR rad


  COLOR_TABLE:
	.db		4,6,2

 START_EFFECT:
	
	ldi		ZH,HIGH(COLOR_TABLE*2)
	ldi		ZL,LOW(COLOR_TABLE*2)
	ldi		r18,3
	ldi		r20,0
START_EFFECT_LOOP:
	push	r18
	push	ZH
	push	ZL
	add		ZL,r20
	
	lpm		r19,Z
	inc		r20
	push	r20
	call	EFFECT
	call	EFFECT_DELAY

	ldi		r16,150
	ldi		r17,25
	cli
	call	BEEP
	sei
	pop		r20
	pop		ZL
	pop		ZH
	pop		r18
	dec		r18
	brne	START_EFFECT_LOOP
	
	ret

GAME_OVER_EFFECT:
	ldi		r18,2
GAME_OVER_EFFECT_LOOP:
	push	r18
	call	EFFECT
	call	EFFECT_DELAY

	ldi		r16,150
	ldi		r17,25
	cli
	call	BEEP
	sei

	pop		r18
	dec		r18
	brne	GAME_OVER_EFFECT_LOOP
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
	push	r18
	ldi		r18,4
	ldi		r24,$2
	ldi		r25,$2
EFFECT_LONG_DELAY:
	call	DELAY_16
	dec		r18
	brne	EFFECT_LONG_DELAY
	pop		r18
	ret

