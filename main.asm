	.org	$0
	jmp		START_GAME
	
	.org	OVF0addr
	jmp		MUX
	
.include "VMEM.asm"
.include "Ball.asm"
.include "speaker.asm"
.include "WRITE_7SEG.asm"

.include "Effects.asm"
.include "Start_Button.asm"

.include "spelare.asm"

START_GAME:
	ldi		r16,LOW(RAMEND)
	out		SPL,r16
	ldi		r16,HIGH(RAMEND)
	out		SPH,r16
	
	call	HW_INIT

	ldi		r17, 3
	call	START_BUTTON
	call	START_EFFECT
	
	call	PLAYER_INIT
RUN_GAME:
	call	Joystick_Input

	call	DELAY_GAME
	call	CHANGE_BALL_POS


	jmp		RUN_GAME	

	

DELAY_GAME:
	push	r17
	ldi		r19,$10
DELAY_GAME_Yttre_YTTRE_LOOP:
	ldi		r18, $FF
DELAY_GAME_YttreLoop:
	ldi		r17, $FF
DELAY_GAME_InreLoop:
	dec		r17
	brne	DELAY_GAME_InreLoop
	dec		r18
	brne	DELAY_GAME_YttreLoop
	dec		r19
	brne	DELAY_GAME_Yttre_YTTRE_LOOP
	pop		r17
	ret


LEFT_WON:
	ldi		r19, 0b00000100 // Tre sista bitarna ändrar färg, RGB
	call	GAME_OVER_EFFECT

	jmp		START_GAME


RIGHT_WON:
	ldi		r19, 0b00000001 // Tre sista bitarna ändrar färg, RGB
	call	GAME_OVER_EFFECT

	jmp		START_GAME
