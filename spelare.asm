//Höger JOY_STICK
	.equ	Channel_JOY_RIGHT_Y	 = 1		; ADC3=PA3, PORTA bit 3 Y-led

//Vänster JOY_STICK
	.equ	Channel_JOY_LEFT_Y	 = 3		; ADC1=PA1


	.equ	Y_UP = 3
	.equ	Y_DOWN = 0


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


///////////////////////////////////////// Joystick_Input(): Själva funktion som MAIN filen får kalla 
Joystick_Input:
	call	CLEAR_LEFT_PLAYER
	call	CLEAR_RIGHT_PLAYER

	call	Input_P1
	
	call	Input_P2

	call	SET_RIGHT_PLAYER
	call	SET_LEFT_PLAYER
	
	ret



///////////////////////////////////////// Input(): <- data som skickad från Joystick
Input:
	out		ADMUX,r17

	ldi		r17, (1<<ADSC)|(1<<ADEN) | (7<<ADPS0)
	out		ADCSRA, r17

Wait_Joystick:
	sbic	ADCSRA, ADSC
	jmp		Wait_Joystick
	in		r16, ADCH

	ret




///////////////////////////////////////// Vänster Joystick
Input_P1:
	ldi		r17, (1<<REFS0)|(0<<ADLAR)|(Channel_JOY_LEFT_Y)		//För vänster joystick

	call	Input

Check_Y_1:
	cpi		r16, Y_UP
	breq	Y_1_INC

	cpi		r16, Y_DOWN
	breq	Y_1_DEC

	jmp		Y_1_DONE

Y_1_INC:
	lds		r16, LPOSY

	cpi		r16, 2					//Kollar om det är vid högsta, om det är ska det inte öka
	breq	Y_1_DONE
				
	DECSRAM LPOSY					//Else, ökar med 1

	jmp		Y_1_DONE

Y_1_DEC:
	lds		r16, LPOSY

	cpi		r16, 7					//Kollar om det är vid lägsta, om det är ska det inte minska
	breq	Y_1_DONE

	INCSRAM LPOSY					//Else, minskar med 1

	jmp		Y_1_DONE

Y_1_DONE:
	ret



///////////////////////////////////////// Höger Joystick
Input_P2:
	ldi		r17, (1<<REFS0)|(0<<ADLAR)|(Channel_JOY_RIGHT_Y)		//För höger joystick

	call	Input

Check_Y_2:
	cpi		r16, Y_UP
	breq	Y_2_INC

	cpi		r16, Y_DOWN
	breq	Y_2_DEC

	jmp		Y_2_DONE

Y_2_INC:
	lds		r16, RPOSY

	cpi		r16, 2					//Kollar om det är vid högsta, om det är ska det inte öka
	breq	Y_2_DONE
				
	DECSRAM RPOSY					//Else, ökar med 1

	jmp		Y_2_DONE

Y_2_DEC:
	lds		r16, RPOSY

	cpi		r16, 7					//Kollar om det är vid lägsta, om det är ska det inte minska
	breq	Y_2_DONE

	INCSRAM RPOSY					//Else, minskar med 1

	jmp		Y_2_DONE

Y_2_DONE:
	ret
