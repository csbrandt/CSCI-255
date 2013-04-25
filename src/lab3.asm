; Christopher Brandt
; CSCI 255
; Lab 3

START:
	mov r1, a
	cpl a
	mov r0, a
	cpl a

	mov b, #0Ah
	div ab
	mov a, r1   ; Restore the value of a after division

	; // Display binary value on LED bank

        mov P0, r0 ; Move value from reg 1 to p0 (LED bank)

	; ////////////////////////////////


	; // Display ones digit on 7-Segment

	mov r1, b
	lcall DRAW7 

	; ////////////////////////////////

	lcall SLEEP ; nop 1 second

	inc a

	cjne a, #0ffh, START

	; After 256 seconds, light all lights on P0 for 1 second
	; and reset a to 0

	lcall RESETS

	ljmp START

SLEEP:
	mov r1, #0     ; Register 1 00000000

LOOP1:

	mov r0, #0     ; Register 0 00000000

LOOP0:
	inc r0
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	cjne r0, #0ffh, LOOP0

	inc r1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	cjne r1, #0ffh, LOOP1

	ret

RESETS:

        mov P2, #0ffh
	lcall SLEEP ; nop 1 second
	mov P2, #0

	clr a

	ret


; Uses value in r1
; Moves 


DRAW7:

	cjne r1, #0, D1

	jmp D0

	ret

D0:

	mov P1, #0c0h

	ret

D1:

	dec r1
	cjne r1, #0, D2
	
	mov P1, #0f9h

	ret

D2:

	
	dec r1
	cjne r1, #0, D3
	
	mov P1, #0a4h

	ret

D3:

	
	dec r1
	cjne r1, #0, D4
	
	mov P1, #0b0h

	ret

D4:

	dec r1
	cjne r1, #0, D5
	
	mov P1, #099h

	ret

D5:

	dec r1
	cjne r1, #0, D6
	
	mov P1, #092h

	ret

D6:
	
	dec r1
	cjne r1, #0, D7
	
	mov P1, #082h

	ret

D7:

	dec r1
	cjne r1, #0, D8
	
	mov P1, #0f8h

	ret

D8:

	dec r1
	cjne r1, #0, D9
	
	mov P1, #080h

	ret

D9:

	dec r1
	
	mov P1, #090h

	ret

end

