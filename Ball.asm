
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
	ret

MOVE_BALL_X:
	lds		r17,BPOSX
	lds		r16,BSPEEDX
	call	CHECK_BOUNCE_X
	
	cpi		r16,$ff
	brne	POSITIVE_SPEEDX

	subi	r17,1
	jmp		SPEEDX_DONE
POSITIVE_SPEEDX:
	add		r17,r16
SPEEDX_DONE:
	
	sts		BPOSX,r17
	ret

MOVE_BALL_Y:
	lds		r16,BSPEEDY
	lds		r17,BPOSY
	call	CHECK_BOUNCE_Y

	cpi		r16,$ff
	brne	POSITIVE_SPEEDY

	subi	r17,1
	jmp		SPEEDY_DONE
POSITIVE_SPEEDY:
	add		r17,r16
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
	lds		r20,LPOSY
	lds		r18,BPOSY

	cp		r20,r18
	breq	HIT_TOP_LEFT

	dec		r20
	cp		r20,r18
	breq	HIT_MIDDLE_LEFT

	dec		r20
	cp		r20,r18
	breq	HIT_BOTTOM_LEFT
	call	RIGHT_PLAYER_SCORED
	jmp		CHECK_BOUNCE_X_LEFT_DONE

HIT_TOP_LEFT:
	ldi		r16,-1
	ldi		r19,-1
	call	SOUND
	jmp		CHECK_BOUNCE_X_LEFT_DONE

HIT_MIDDLE_LEFT:
	ldi		r16,-1
	clr		r19
	call	SOUND
	jmp		CHECK_BOUNCE_X_LEFT_DONE

HIT_BOTTOM_LEFT:
	ldi		r16,-1
	ldi		r19,1
	call	SOUND
	jmp		CHECK_BOUNCE_X_LEFT_DONE

CHECK_BOUNCE_X_LEFT_DONE:
	ret


//////////////////////////////////////CHECK_BOUNCE_X_PLAYER_RIGHT(r19=BSPEEDY) -> r16=BSPEEDX, r19=BSPEEDY
CHECK_BOUNCE_X_PLAYER_RIGHT:
	lds		r20,RPOSY
	lds		r18,BPOSY

	cp		r20,r18
	breq	HIT_TOP_RIGHT

	dec		r20
	cp		r20,r18
	breq	HIT_MIDDLE_RIGHT

	dec		r20
	cp		r20,r18
	breq	HIT_BOTTOM_RIGHT

	call	LEFT_PLAYER_SCORED
	jmp		CHECK_BOUNCE_X_RIGHT_DONE

HIT_TOP_RIGHT:
	ldi		r16,1
	ldi		r19,-1
	call	SOUND
	jmp		CHECK_BOUNCE_X_RIGHT_DONE

HIT_MIDDLE_RIGHT:
	ldi		r16,1
	clr		r19
	call	SOUND
	jmp		CHECK_BOUNCE_X_RIGHT_DONE

HIT_BOTTOM_RIGHT:
	ldi		r16,1
	ldi		r19,1
	call	SOUND
	jmp		CHECK_BOUNCE_X_RIGHT_DONE
	
CHECK_BOUNCE_X_RIGHT_DONE:
	ret



//////////////////////////////////////LEFT_PLAYER_SCORED(): tar bort allt ur videominnet och sätter tillbaka bollen i mitten av planen, ökar poängen
LEFT_PLAYER_SCORED:
	call	RESET_VMEM	
	lds		r20,LPOINT
	inc		r20
	cpi		r20,10
	breq	LEFT_WON
	sts		LPOINT,r20
	call	LEFT8_WRITE
	jmp		LEFT_PLAYER_SCORED_END
LEFT_WON:
	call	GAME_OVER
LEFT_PLAYER_SCORED_END:
	ret


//////////////////////////////////////RIGHT_PLAYER_SCORED(): tar bort allt ur videominnet och sätter tillbaka bollen i mitten av planen, ökar poängen
RIGHT_PLAYER_SCORED:
	call	RESET_VMEM
	lds		r20,RPOINT
	inc		r20
	cpi		r20,10
	breq	RIGHT_WON
	sts		RPOINT,r20
	call	RIGHT8_WRITE
	jmp		RIGHT_PLAYER_SCORED_END
RIGHT_WON:
	call	GAME_OVER
RIGHT_PLAYER_SCORED_END:
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
SOUND:
	push	r16
	push	r17

	ldi		r17,3
	ldi		r16,10
	call	BEEP

	pop		r17
	pop		r16

	ret