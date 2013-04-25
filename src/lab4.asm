; Christopher Brandt
; CSCI 255
; Lab 4

; http://www.c4micros.com/c4micros_009.htm

; values for 1/20th of a second: 0.05 * 921583 = 46079, 65536 - 46079 = 19457 (4C01h)
; values for 1/50th of a second: 0.02 * 921583 = 18432, 65536 - 18432 = 47104 (B800h)










; Takes the value in R0 to set the timer 0 mode
; Takes the value in R1 for setting low byte of timer 0
; Takes the value in R2 for setting high byte of timer 0
SETUP_TIMER0:

mov tmod, R0
mov TL0, R1
mov TH0, R2

ret


; Takes the value 010h to ORL with the byte in tcon
; Then loads the result of the ORL op into tcon
; Uses a
START_TIMER0:

mov a, tcon
ORL a, #010h
mov tcon, a

ret

; Waits until timer 0 overflow bit is set
; Sets overflow bit back to 0 then returns
; Uses a
WAIT_T0_OVERFLOW:

mov a, tcon
ORL a, #020h

CHECK_OVERFLOW:

nop

cjne a, tcon, CHECK_OVERFLOW

; set overflow bit back

ret








end