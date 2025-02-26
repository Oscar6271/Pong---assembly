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
	push	r18
BEEP_LOOP:
	sbi		PORTB,1
	mov		r18,r17
	call	DELAY_SPEAKER
	cbi		PORTB,1
	mov		r18,r17
	call	DELAY_SPEAKER
	dec		r16
	brne	BEEP_LOOP
	pop		r18
	ret


DELAY_SPEAKER:
	push	r17
DELAY_SPEAKER_YttreLoop:
	ldi		r17,$1F
DELAY_SPEAKER_InreLoop:
	dec		r17
	brne	DELAY_SPEAKER_InreLoop
	dec		r18
	brne	DELAY_SPEAKER_YttreLoop
	pop		r17
	ret

