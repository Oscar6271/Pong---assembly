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

	ldi		r17, 3			; välj L1
	call	START_BUTTON
	call	START_EFFECT
	call	PLAYER_INIT

RUN_GAME:
	call	Joystick_Input
	call	DELAY_GAME
	call	CHANGE_BALL_POS
	jmp		RUN_GAME	

DELAY_GAME:
	ldi		r19,$15
	ldi		r24,$2
	ldi		r25,$2
	
DELAY_GAME_Yttre_YTTRE_LOOP:
	call	DELAY_16
	dec		r19
	brne	DELAY_GAME_Yttre_YTTRE_LOOP
	ret
DELAY_16:
	sbiw	r24,2
	brne	DELAY_16
	ret


LEFT_WON:
	ldi		r19, 0b00000100 // Tre sista bitarna ändrar färg, RGB
	call	GAME_OVER_EFFECT
	jmp		START_GAME


RIGHT_WON:
	ldi		r19, 0b00000001 // Tre sista bitarna ändrar färg, RGB
	call	GAME_OVER_EFFECT
	jmp		START_GAME