;
; speaker.asm
;
; Created: 2025-01-28 16:00:08
; Author : emaxv
;
;	BEEP(r16=LENGTH, r17=PITCH)
//===============================

///////////////////////////BEEP(r16=LENGTH, r17=PITCH)
BEEP:	
	sbi		DDRB,1
	sbi		PORTB,1
	mov		r25,r17
	call	DELAY_SPEAKER
	cbi		PORTB,1
	mov		r25,r17
	call	DELAY_SPEAKER
	dec		r16
	brne	BEEP
	ret


DELAY_SPEAKER:
	ldi		r24,$1E
	call	DELAY_16
	ret

