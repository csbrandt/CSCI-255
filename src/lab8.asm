; /////////////////////////
; Christopher Brandt
; CSCI 255
; Lab 8
;
; http://www.c4micros.com/c4micros_009.htm // ref
;
; PCON.7 is cleared
; TH1 = 256 - ((Crystal / 384) / Baud)
; TH1 = 256 - ((11059200 / 384) / 150)
;
; /////////////////////////

org 0h
ljmp MAIN

; /////////////////////////

MAIN:

	mov a, pcon        ; pcon.7 wouldnt work
	anl a, #07Fh
	mov pcon, a

	; 8-bit UART set by timer 1  
 
	mov R0, #040h 
	lcall SETUP_SERIAL_PORT

	; Timer 1 8-bit autoreload for 150 baud rate

	mov R0, #020h
	mov R1, #0
	mov R2, #040h

	lcall SETUP_TIMER1
	lcall START_TIMER1

	CALC_LOOP:

	lcall SCAN_4X4_KEYPAD
	lcall GET_4X4_DIGIT

	cjne R2, #0, OPR1

	; A digit button was not pressed

	ljmp CALC_LOOP
	;-------------



	OPR1:
	
	mov a, R2
	mov R0, a
	mov R3, a              ; Save ASCII value of OPD1
	lcall PRINT_CHAR         ; Print OPD1

	lcall SCAN_4X4_KEYPAD
	lcall GET_4X4_OPERATOR

	cjne R2, #0, OPD2

	; An operator was not pressed

	ljmp OPR1  
	;-------------           

	

	OPD2:
	
	mov a, R2
	mov R0, a
	mov R4, a               ; Save ASCII value of OPR1
	lcall PRINT_CHAR         ; Print OPR1


	lcall SCAN_4X4_KEYPAD
	lcall GET_4X4_DIGIT

	cjne R2, #0, OPR2

	; A digit button was not pressed

	ljmp OPD2
	;-------------

	

	OPR2:

	mov a, R2
	mov R0, a              
	mov R5, a              ; Save ASCII value of OPD2
	lcall PRINT_CHAR        ; Print OPD2
	;-------------



	RESULT:

	lcall SCAN_4X4_KEYPAD

	cjne R1, #07Dh, RESULT

	; The hash, used as equals is pressed

	mov R0, #03Dh

	lcall PRINT_CHAR

	; Print result

	; Convert ASCII

	mov a, R3
	subb a, #030h
	mov R3, a

	mov a, R5
	subb a, #030h
	mov R5, a

	lcall GET_BIN_OP_RESULT

	mov a, R6
	mov b, #0Ah

	div ab

	add a, #030h
	mov R0, a

	lcall PRINT_CHAR

	mov a, b
	add a, #030h
	mov R0, a

	lcall PRINT_CHAR

	; Print newline

	mov R0, #0Dh

	lcall PRINT_CHAR
	;-------------


	ljmp CALC_LOOP


reti


; /////////////////////////
; Takes the value in R0 to ORL with the byte in scon
; Then loads the result of the ORL op into scon
; Uses a, R0

SETUP_SERIAL_PORT:

	mov a, scon
	ORL a, R0
	mov scon, a

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
; Takes the value 040h to ORL with the byte in tcon
; Then loads the result of the ORL op into tcon
; Uses a

START_TIMER1:

	mov a, tcon
	ORL a, #040h
	mov tcon, a

ret


; /////////////////////////
; Takes the byte in R0 to 
; print out to the serial port
; Uses R0

PRINT_CHAR:

	clr ti

	mov sbuf, R0

	; Wait until ti bit is set to continue
	jnb ti, $
	
ret


; /////////////////////////
; Scan all rows of 4x4 keypad
; Returns the button pressed (Low byte R1)
; and the row in which it was pressed (High byte R1)
; Uses a, R0, R1

SCAN_4X4_KEYPAD:


	; Start at row 0, #0EFh

	ROW0:

	mov R0, #0EFh

	READ_ROW:

	mov P1, R0        ; Select row, write 1's
	mov a, P1         ; Read row

	mov R1, a

	anl a, #0Fh

	; Shift R1 from MSB to LSB
	; Puts in R1 the next row to check
	
	mov a, R0
	rl a
	mov R0, a

	; If the first four bits are all still set
        ; Check next row

	cjne a, #0Fh, BUTTON_PRESS

	; No button pressed 

	; Check if the last row was already read

	cjne R0, #0FEh, READ_ROW

	ljmp ROW0

	BUTTON_PRESS:

	; A button has been pressed
	; R0 contains the button pressed 
	; and the row it was pressed in 

ret


; /////////////////////////
; Takes a numeric value in R1
; Returns the equivalent ASCII digit R2
; on 4x4 keypad
; Uses R1, R2

GET_4X4_DIGIT:

	cjne R1, #07Bh, D1
	jmp D0

ret

D0:

	mov R2, #030h

ret

D1:

	cjne R1, #0E7h, D2
	mov R2, #031h

ret

D2:

	cjne R1, #0EBh, D3
	mov R2, #032h

ret

D3:

	cjne R1, #0EDh, D4
	mov R2, #033h

ret

D4:

	cjne R1, #0D7h, D5
	mov R2, #034h

ret

D5:

	cjne R1, #0DBh, D6
	mov R2, #035h

ret

D6:

	cjne R1, #0DDh, D7
	mov R2, #036h

ret

D7:

	cjne R1, #0B7h, D8
	mov R2, #037h

ret

D8:

	cjne R1, #0BBh, D9
	mov R2, #038h

ret

D9:

	cjne R1, #0BDh, NAN
	mov R2, #039h

ret

NAN:

	; A number was not pressed
	mov R2, #0

ret


; /////////////////////////
; Takes a numeric value in R1
; Returns the equivalent operator 
; on 4x4 keypad
; Uses R1, R2

GET_4X4_OPERATOR:

	cjne R1, #0EEh, MINUS
	jmp PLUS

ret

PLUS:
	
	mov R2, #02Bh

ret

MINUS:

	cjne R1, #0DEh, MULT
	mov R2, #02Dh

ret

MULT:

	cjne R1, #0BEh, DIVIDE
	mov R2, #02Ah

ret

DIVIDE:

	cjne R1, #07Eh, NAO
	mov R2, #05Ch

ret

NAO:

	; An operator was not pressed
	mov R2, #0

ret


; /////////////////////////
; Takes R3 for operand 1
; Takes R4, ASCII value for binary operator
; Takes R5 for operand 2
; Returns result in R6
; Uses a, R3, R4, R5, R6

GET_BIN_OP_RESULT:

	cjne R4, #02Bh, MINUS_RESULT
	jmp PLUS_RESULT

ret

PLUS_RESULT:

	mov a, R3
	add a, R5
	mov R6, a
	
ret

MINUS_RESULT:

	cjne R4, #02Dh, MULT_RESULT

	mov a, R5
	subb a, R3
	mov R6, a

ret

MULT_RESULT:

	cjne R1, #02Ah, DIVIDE_RESULT

	mov a, R3
	mov b, R5
	mul ab
	mov R6, a
	
ret

DIVIDE_RESULT:

	mov a, R3
	mov b, R5
	div ab
	mov R6, a

ret




end