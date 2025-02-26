;
; Lab2 TSIU51 Read.asm
;
; Created: 2025-02-05 13:05:18
; Author : emian774
;
// En rutin för ett start tillstånd som väntar på ett knapptryck från l1 och då kommer gå ut ur loopen
// START_BUTTON() r17=Val av knapp
// Accepterade värden på r17:
// 1=R1 ; 2=R2 ; 3=L1 ; 4=L2 ; 5=JOYSTICK_L ; 6=JOYSTICK_R



.equ ADDR_BUTTONS = $27

;address 0100111


START_BUTTON:
	ldi		r21,ADDR_BUTTONS
	lsl		r21
	ori		r21,1
	call	TWI_READ_BUTTON
	call	TRANSLATE

	cp		r16,r17
	breq	START_BUTTON1
	jmp		START_BUTTON
START_BUTTON1:
	;call	ROTLED_GREEN
	ret


// Translate avkodar den avlästa datan från r22 och gör om det till siffror 0-6 i r16
TRANSLATE:
	cpi		r22,2
	breq	RI1
	cpi		r22,4
	breq	RI2
	cpi		r22,8
	breq	LE1
	cpi		r22,16
	breq	LE2
	cpi		r22,32
	breq	JOY_RIGHT
	cpi		r22,64
	breq	JOY_LEFT
	ldi		r16,0
	jmp		TRA_DONE
RI1:
	ldi		r16,1
	jmp		TRA_DONE
RI2:
	ldi		r16,2
	jmp		TRA_DONE
LE1:
	ldi		r16,3
	jmp		TRA_DONE
LE2:
	ldi		r16,4
	jmp		TRA_DONE
JOY_LEFT:
	ldi		r16,5
	jmp		TRA_DONE
JOY_RIGHT:
	ldi		r16,6
	jmp		TRA_DONE
TRA_DONE:
	ret

// Skickar adress och read-bit + läser data
TWI_READ_BUTTON:
	call	START
	mov		r19,r21
	call	TWI_81_WRITE_BUTTON	;skickar addressen r21
	call	SWITCHES
	call	STOP
	ret

// Läser in data till r22
SWITCHES:
	push	r20

	ldi		r20,8				;loop x 8
SWITCHES_1:
	cbi		DDRC, SCL			;Höjer klockpulsen
	
	sbic	PINC, SDA			;skippar om SDA är hög
	ori		r22,0
	
	sbis	PINC, SDA			;skippar om SDA är låg
	ori		r22,1

	call	WAIT

	lsl		r22					;left shiftar
	sbi		DDRC, SCL			;sänker klockpulsen
	call	WAIT
	
	dec		r20
	brne	SWITCHES_1
	call	SDH

	pop		r20
	ret

TWI_81_WRITE_BUTTON:				;Skickar adressen från r21
	push	r20
	push	r19

	ldi		r20,8
	
TWI_81_WRITE_BUTTON_1:
	sbrc	r19,7
	call	SDH

	sbrs	r19,7
	call	SDL
	lsl		r19
	dec		r20
	brne	TWI_81_WRITE_BUTTON_1
	call	CLK

	pop		r19
	pop		r20
	ret

CLK:
	cbi		DDRC , SCL
	call	WAIT
	sbi		DDRC , SCL
	call	WAIT
	ret
