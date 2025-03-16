///////////////////////////////////////// Hger JOY_STICK
	.equ	Channel_JOY_RIGHT_Y	 = 1		; ADC1=PA1, PORTA bit 1 Y-led

///////////////////////////////////////// Vnster JOY_STICK
	.equ	Channel_JOY_LEFT_Y	 = 3		; ADC3=PA3

///////////////////////////////////////// Värdet som visar om joysticken åker upp eller ner
	.equ	JOY_UP = 3
	.equ	JOY_DOWN = 0

; ---------------------------------------
	; --- Macros for inc/dec-rementing
	; --- a byte in SRAM
	.macro INCSRAM	; inc byte in SRAM
		lds	r16, @0
		inc	r16
		sts	@0, r16
	.endmacro

	.macro DECSRAM	; dec byte in SRAM
		lds	r16, @0
		dec	r16
		sts	@0, r16
	.endmacro
; ---------------------------------------

///////////////////////////////////////// Joystick_Input(): Sjlva funktion som MAIN filen fr kalla 
Joystick_Input:
	call	CLEAR_LEFT_PLAYER
	call	CLEAR_RIGHT_PLAYER

	call	INPUT_PLAYER_LEFT
	call	INPUT_PLAYER_RIGHT

	call	SET_RIGHT_PLAYER
	call	SET_LEFT_PLAYER	
	ret

///////////////////////////////////////// Input(): <- data som skickad frn Joystick
Input:
	out		ADMUX,r17
	ldi		r17, (1<<ADSC)|(1<<ADEN)|7
	out		ADCSRA, r17
Wait_Joystick:
	sbic	ADCSRA, ADSC
	jmp		Wait_Joystick
	in		r16, ADCH
	ret

///////////////////////////////////////// Vnster Joystick
INPUT_PLAYER_LEFT:
	ldi		r17, (1<<REFS0)|(0<<ADLAR)|(Channel_JOY_LEFT_Y)		//Fr vnster joystick
	call	Input
	call	CHECK_LEFT_PLAYER
	ret

///////////////////////////////////////// Hger Joystick
INPUT_PLAYER_RIGHT:
	ldi		r17, (1<<REFS0)|(0<<ADLAR)|(Channel_JOY_RIGHT_Y)		//Fr hger joystick
	call	Input
	call	CHECK_RIGHT_PLAYER
	ret

///////////////////////////////////////// CHECK_LEFT_PLAYER(): Vänster spelare funktion
CHECK_LEFT_PLAYER:
	cpi		r16, JOY_UP
	breq	LEFT_PLAYER_INC
	cpi		r16, JOY_DOWN
	breq	LEFT_PLAYER_DEC
	jmp		LEFT_PLAYER_DONE

LEFT_PLAYER_INC:
	lds		r16, LPOSY
	cpi		r16, 2					//Kollar om det r vid hgsta, om det r ska det inte ka
	breq	LEFT_PLAYER_DONE			
	DECSRAM LPOSY					//Else, kar med 1
	jmp		LEFT_PLAYER_DONE

LEFT_PLAYER_DEC:
	lds		r16, LPOSY
	cpi		r16, 7					//Kollar om det r vid lgsta, om det r ska det inte minska
	breq	LEFT_PLAYER_DONE
	INCSRAM LPOSY					//Else, minskar med 1

LEFT_PLAYER_DONE:
	ret

///////////////////////////////////////// CHECK_RIGHT_PLAYER(): Högre spelare funktion
CHECK_RIGHT_PLAYER:
	cpi		r16, JOY_UP
	breq	RIGHT_PLAYER_INC
	cpi		r16, JOY_DOWN
	breq	RIGHT_PLAYER_DEC
	jmp		RIGHT_PLAYER_DONE

RIGHT_PLAYER_INC:
	lds		r16, RPOSY
	cpi		r16, 2					//Kollar om det r vid hgsta, om det r ska det inte ka
	breq	RIGHT_PLAYER_DONE			
	DECSRAM RPOSY					//Else, kar med 1
	jmp		RIGHT_PLAYER_DONE

RIGHT_PLAYER_DEC:
	lds		r16, RPOSY
	cpi		r16, 7					//Kollar om det r vid lgsta, om det r ska det inte minska
	breq	RIGHT_PLAYER_DONE
	INCSRAM RPOSY					//Else, minskar med 1

RIGHT_PLAYER_DONE:
	ret

