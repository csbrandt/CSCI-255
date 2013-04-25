; /////////////////////////
; Christopher Brandt
; CSCI 255
; Lab 7
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

	; Start with 'A'
	mov R0, #041h

	ALPHA_LOOP:

	lcall PRINT_CHAR

	; Increment character

	mov a, R0
	inc a
	
	; Print line feed after each char

	mov R0, #0Ah
	lcall PRINT_CHAR

	; Restore char to R0
	mov R0, a

	cjne R0, #05Bh, ALPHA_LOOP

	BUSY:

	nop

	jmp BUSY

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




end


