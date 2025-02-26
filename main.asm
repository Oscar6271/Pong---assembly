	.org	$0
	jmp		START_GAME
	
	.org	INT0addr
	jmp		MUX
	
.include "VMEM.asm"
.include "Ball.asm"
.include "speaker.asm"
.include "WRITE_7SEG.asm"

START_GAME:
	ldi		r16,LOW(RAMEND)
	out		SPL,r16
	ldi		r16,HIGH(RAMEND)
	out		SPH,r16

	call	HW_INIT
RUN_GAME:
	call	CHANGE_BALL_POS
	jmp		RUN_GAME	


GAME_OVER:
	jmp		GAME_OVER