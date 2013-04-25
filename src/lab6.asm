; /////////////////////////
; Christopher Brandt
; CSCI 255
; Lab 6
;
; http://www.c4micros.com/c4micros_009.htm // ref
;
; values for 1/20th of a second: 0.05 * 921583 = 46079, 65536 - 46079 = 19457 (4C01h)
;
; /////////////////////////

org 0h
ljmp INIT

org 0Bh
ljmp INC_DISPLAY

; /////////////////////////

INIT:

	mov a, ie
	ORL a, #082h           ; Timer 0 / Global interrupt enable
	mov ie, a	

; /////////////////////////
; Main program loop

MAIN:

	clr a 
	mov R5, a
	mov R6, a

	; Zero counter

	mov R1, #0
	lcall DRAW_DUAL7
	
	lcall WAIT_BUTTON0_PRESS

	; Button 0 is pressed start counting	

	mov R0, #01h
	mov R1, #01h
	mov R2, #04Ch

	lcall SETUP_TIMER0
	lcall START_TIMER0

	; Wait for button press

	lcall WAIT_BUTTON0_PRESS

	lcall STOP_TIMER0

	; Wait for button press

	lcall WAIT_BUTTON0_PRESS

	; Reset timer

ljmp MAIN
	
; /////////////////////////
; Interrupt handler for timer 0
; Counts and displays seconds on two 7-segment displays
; Uses a, R0, R1, R2, R5, R6

INC_DISPLAY:

	; Re-initialize timer 0

	mov R0, #01h
	mov R1, #01h
	mov R2, #04Ch

	lcall SETUP_TIMER0
	lcall START_TIMER0

	cjne R5, #013h, INC_20TH

	mov R5, #0         ; Reset 1/20th second count

	mov a, R6          ; Inc digit count
	inc a              ;
	mov R6, a          ;

	; Check for 100
	cjne R6, #064h, DRAW_CURRENT

	mov R6, #0         ; Reset digit count

	jmp DRAW_CURRENT

	INC_20TH:

	mov a, r5          ; Inc 1/20th second count
	inc a              ;
	mov R5, a          ;

	DRAW_CURRENT:

	mov a, R6
	mov R1, a

	lcall DRAW_DUAL7

reti

; /////////////////////////
; Waits until the button at P2.0 is pressed
; Implements a button debounce algorithm
; Uses a, R3, P2.0

WAIT_BUTTON0_PRESS:

	setb P2.0
	
	WB_LOOP0:

	jnb P2.0, WB_LOOP1
	mov R3, #014h          ; ms count
	
	WB_LOOP1:

	jb P2.0, WB_LOOP2

	lcall WAIT_MS

	mov a, R3	       ; Decrement ms count
	dec a                  ;
	mov R3, a              ;

	cjne R3, #0, WB_LOOP1

	WB_LOOP2:

	cjne R3, #0, WB_LOOP0

ret

; /////////////////////////
; Takes the value in R0 to set the timer 0 mode
; Takes the value in R1 for setting low byte of timer 0
; Takes the value in R2 for setting high byte of timer 0
; Uses a

SETUP_TIMER0:

	mov a, tmod
	ORL a, R0
	mov tmod, a

	mov TL0,  R1
	mov TH0,  R2

ret

; /////////////////////////
; Takes the value in R0 to set the timer 0 mode
; Takes the value in R1 for setting low byte of timer 0
; Takes the value in R2 for setting high byte of timer 0
; Uses a

SETUP_TIMER1:

	mov a, tmod
	ORL a, R0
	mov tmod, a

	mov TL1,  R1
	mov TH1,  R2

ret

; /////////////////////////
; Takes the value 010h to ORL with the byte in tcon
; Then loads the result of the ORL op into tcon
; Uses a

START_TIMER0:

	mov a, tcon
	ORL a, #010h
	mov tcon, a

ret

; /////////////////////////
; Takes the value 040h to ORL with the byte in tcon
; Then loads the result of the ORL op into tcon
; Uses a

START_TIMER1:

	mov a, tcon
	ORL a, #040h
	mov tcon, a

ret

; /////////////////////////
; Stops timer 0
; Uses a

STOP_TIMER0:

	mov a, tcon
	anl a, #0EFh
	mov tcon, a

ret

; /////////////////////////
; Waits one millisecond
; Uses a, R0, R1, R2

WAIT_MS:

	; Setup timer 1 to count in ms
	mov R0, #010h
	mov R1, #066h
	mov R2, #0FCh

	; Reset overflow bit
	mov a, tcon
	anl a, #07Fh
	mov tcon, a

	lcall SETUP_TIMER1
	lcall START_TIMER1

	WAIT:

	mov a, tcon
	anl a, #080h
	
	cjne a, #080h, WAIT
	
ret

; /////////////////////////
; Takes value in r1 and draws to dual 7-segment displays
; Uses r1, a, b, P3, P1

DRAW_DUAL7:

	mov b, #0Ah
	mov a, R1

	div ab

	mov R1, a
	
	lcall GET7SEG_DIGIT
	mov P1, R2          ; Ones digit
	
	mov R1, b

	lcall GET7SEG_DIGIT
	mov P3, R2          ; Tens digit

ret

; /////////////////////////
; Takes a numeric value in R1
; Returns a 7-segment compatible value to R2
; Uses R1, R2

GET7SEG_DIGIT:

	cjne R1, #0, D1
	jmp D0
	ret

D0:

	mov R2, #081h
	ret

D1:

	cjne R1, #01h, D2
	mov R2, #0CFh
	ret

D2:

	cjne R1, #02h, D3
	mov R2, #092h
	ret

D3:

	cjne R1, #03h, D4
	mov R2, #086h
	ret

D4:

	cjne R1, #04h, D5
	mov R2, #0CCh
	ret

D5:

	cjne R1, #05h, D6
	mov R2, #0A4h
	ret

D6:

	cjne R1, #06h, D7
	mov R2, #0A0h
	ret

D7:

	cjne R1, #07h, D8
	mov R2, #08Fh
	ret

D8:

	cjne R1, #08h, D9
	mov R2, #080h
	ret

D9:

	mov R2, #084h
	ret

end

