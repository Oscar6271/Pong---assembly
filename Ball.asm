
//////////////////////////////////////CHANGE_BALL_POS(): Tar bort bollen från VMEM, ändrar dess position och lägger till i VMEM igen
CHANGE_BALL_POS:
	call	CLEAR_BALL
	call	UPDATE_BALL
	call	SET_BALL
	ret


//////////////////////////////////////UPDATE_BALL(): Ändrar bollens position
UPDATE_BALL:
	call	MOVE_BALL_X
	call	MOVE_BALL_Y	
	call	CHECK_SCORED
	ret



//////////////////////////////////////CHECK_SCORED(): kollar om någon spelare ska få poäng
CHECK_SCORED:
	lds		r17,BPOSX
	ldi		r16,8

	cpse	r17,r16
	jmp		CHECK_SCORED_RIGHT
	call	RIGHT_PLAYER_SCORED
	jmp		CHECK_SCORED_END

CHECK_SCORED_RIGHT:
	ldi		r16,-1
	cpse	r17,r16
	jmp		CHECK_SCORED_END
	call	LEFT_PLAYER_SCORED
CHECK_SCORED_END:
	ret



//////////////////////////////////////MOVE_BALL_X(): Flyttar bollen i x-led
MOVE_BALL_X:
	lds		r17,BPOSX
	lds		r16,BSPEEDX
	call	CHECK_BOUNCE_X
	
	cpi		r16,$ff
	brne	POSITIVE_SPEEDX

	dec		r17
	jmp		SPEEDX_DONE
POSITIVE_SPEEDX:
	inc		r17
SPEEDX_DONE:
	sts		BPOSX,r17
	ret


//////////////////////////////////////MOVE_BALL_Y(): Flyttar bollen i y-led
MOVE_BALL_Y:
	lds		r16,BSPEEDY
	lds		r17,BPOSY
	call	CHECK_BOUNCE_Y

	cpi		r16,$ff
	breq	NEGATIVE_SPEEDY
	cpi		r16,1
	breq	POSITIVE_SPEEDY
	jmp		SPEEDY_DONE
	
NEGATIVE_SPEEDY:
	dec		r17
	jmp		SPEEDY_DONE
POSITIVE_SPEEDY:
	inc		r17
SPEEDY_DONE:
	sts		BPOSY,r17
	ret


//////////////////////////////////////CHECK_BOUNCE_Y(r17=BPOSX, r16=BSPEEDX): laddar BSPEEDX och BSPEEDY med den nya hastigheten
CHECK_BOUNCE_X:
	push	r20

	lds		r19,BSPEEDY
	ldi		r20,6
	cpse	r17,r20
	jmp		CHECK_BOUNCE_X_RIGHT
	call	CHECK_BOUNCE_X_PLAYER_LEFT

CHECK_BOUNCE_X_RIGHT:
	ldi		r20,1
	cpse	r17,r20
	jmp		CHECK_BOUNCE_X_DONE
	call	CHECK_BOUNCE_X_PLAYER_RIGHT

CHECK_BOUNCE_X_DONE:
	sts		BSPEEDX,r16
	sts		BSPEEDY,r19

	pop		r20

	ret


//////////////////////////////////////CHECK_BOUNCE_X_PLAYER_LEFT(r19=BSPEEDY) -> r16=BSPEEDX, r19=BSPEEDY
CHECK_BOUNCE_X_PLAYER_LEFT:
	push	r17
	lds		r18,BPOSY
	ldi		r17,1
	
CHECK_X_LEFT:
	lds		r20,LPOSY

	cp		r20,r18
	breq	HIT_TOP_LEFT

	dec		r20
	cp		r20,r18
	breq	HIT_MIDDLE_LEFT

	dec		r20
	cp		r20,r18
	breq	HIT_BOTTOM_LEFT
	dec		r17
	brmi	LEFT_MOVE_DONE
	
	call	PRE_MOVE
	jmp		CHECK_X_LEFT
LEFT_MOVE_DONE:
	jmp		CHECK_BOUNCE_X_RIGHT_DONE

HIT_TOP_LEFT:
	ldi		r16,-1
	ldi		r19,1
	call	SOUND_LEFT
	jmp		CHECK_BOUNCE_X_LEFT_DONE

HIT_MIDDLE_LEFT:
	ldi		r16,-1
	clr		r19
	call	SOUND_LEFT
	jmp		CHECK_BOUNCE_X_LEFT_DONE

HIT_BOTTOM_LEFT:
	ldi		r16,-1
	ldi		r19,-1
	call	SOUND_LEFT
	jmp		CHECK_BOUNCE_X_LEFT_DONE

CHECK_BOUNCE_X_LEFT_DONE:
	pop		r17
	ret



PRE_MOVE:
	lds		r21,BSPEEDY

	cpi		r21,-1
	breq	NEGATIVE_Y
	add		r18,r21
	jmp		MOVE_DONE
NEGATIVE_Y:
	dec		r18

MOVE_DONE:
	ret


//////////////////////////////////////CHECK_BOUNCE_X_PLAYER_RIGHT(r19=BSPEEDY) -> r16=BSPEEDX, r19=BSPEEDY
CHECK_BOUNCE_X_PLAYER_RIGHT:
	push	r17
	lds		r18,BPOSY
	ldi		r17,1
	
CHECK_X_RIGHT:
	lds		r20,RPOSY

	cp		r20,r18
	breq	HIT_TOP_RIGHT

	dec		r20
	cp		r20,r18
	breq	HIT_MIDDLE_RIGHT

	dec		r20
	cp		r20,r18
	breq	HIT_BOTTOM_RIGHT

	dec		r17
	brmi	RIGHT_MOVE_DONE
	
	call	PRE_MOVE
	jmp		CHECK_X_RIGHT
RIGHT_MOVE_DONE:
	jmp		CHECK_BOUNCE_X_RIGHT_DONE
	

HIT_TOP_RIGHT:
	ldi		r16,1
	ldi		r19,1
	call	SOUND_RIGHT
	jmp		CHECK_BOUNCE_X_RIGHT_DONE

HIT_MIDDLE_RIGHT:
	ldi		r16,1
	clr		r19
	call	SOUND_RIGHT
	jmp		CHECK_BOUNCE_X_RIGHT_DONE

HIT_BOTTOM_RIGHT:
	ldi		r16,1
	ldi		r19,-1
	call	SOUND_RIGHT
	jmp		CHECK_BOUNCE_X_RIGHT_DONE
	
CHECK_BOUNCE_X_RIGHT_DONE:
	pop		r17
	ret



//////////////////////////////////////LEFT_PLAYER_SCORED(): tar bort allt ur videominnet och sätter tillbaka bollen i mitten av planen, ökar poängen
LEFT_PLAYER_SCORED:
	call	SOUND_LEFT
	ldi		r20,-1
	call	RESET_VMEM	
	lds		r20,LPOINT
	inc		r20
	cpi		r20,10
	breq	END_GAME_LEFT
	brne	DISPLAY_LEFT_SCORE
END_GAME_LEFT:
	call	LEFT_WON
DISPLAY_LEFT_SCORE:
	sts		LPOINT,r20
	call	LEFT8_WRITE
	ret


//////////////////////////////////////RIGHT_PLAYER_SCORED(): tar bort allt ur videominnet och sätter tillbaka bollen i mitten av planen, ökar poängen
RIGHT_PLAYER_SCORED:
	call	SOUND_RIGHT
	ldi		r20,1
	call	RESET_VMEM
	lds		r20,RPOINT
	inc		r20
	cpi		r20,10
	breq	END_GAME_RIGHT
	brne	DISPLAY_RIGHT_SCORE
END_GAME_RIGHT:
	call	RIGHT_WON
DISPLAY_RIGHT_SCORE:
	sts		RPOINT,r20
	call	RIGHT8_WRITE
	ret


//////////////////////////////////////CHECK_BOUNCE_Y(r17=BPOSY, r16=BSPEEDY): laddar BSPEEDY med den nya hastigheten
CHECK_BOUNCE_Y:
	cpi		r17,7
	brsh	SET_SPEEDY_DOWN
	jmp		CHECK_BOUNCE_Y_LOWER

SET_SPEEDY_DOWN:
	ldi		r16,-1
	call	SOUND

CHECK_BOUNCE_Y_LOWER:
	cpi		r17,0
	breq	SET_SPEEDY_UP
	jmp		BOUNCE_Y_DONE

SET_SPEEDY_UP:
	ldi		r16,1
	call	SOUND
BOUNCE_Y_DONE:
	sts		BSPEEDY,r16
	ret


//////////////////////////////////////SOUND(): laddar r16 och r17 med pitch och length på tonen
SOUND_LEFT:
	push	r16
	push	r17

	ldi		r17,80
	ldi		r16,60
	call	BEEP

	pop		r17
	pop		r16

	ret

SOUND_RIGHT:
	push	r16
	push	r17

	ldi		r17,75
	ldi		r16,75
	call	BEEP

	pop		r17
	pop		r16
	ret

SOUND:
	push	r16
	push	r17

	ldi		r17,100
	ldi		r16,50
	call	BEEP

	pop		r17
	pop		r16

	ret
