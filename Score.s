#include <xc.inc>

global	Score_Setup, Score_Digit, Score_Test_1, Score_Inc
extrn	LCD_delay_ms 
extrn	GLCD_Digit_Write, GLCD_enable, GLCD_Display_O
    
psect	udata_acs   ;access ram for variables
Score:  ds  1   ;the score
Quotient:   ds	1   ;result of division
Input:  ds	1   ;input of division
Remainder:  ds	1   ;remainder of division
Score_Digit:	ds  1	;stores current digit to be drawn

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    
        GLCD_E EQU 4		;defines pin 4 as enable
	GLCD_RS EQU 2		;defines pin 2 as RS

 psect	score_code,class=CODE

Score_Setup:
	movlw	0x00
	movwf	Score, A    ;reset score
	return
Score_Inc:
	incf	Score, F, A
	return
Score_DivMod_Setup:
	movlw	0x00
	movwf	Quotient, A
	movff	Score, Input
Score_DivMod:
	movlw	0x0A	;setting 10 as divisor
	subwf	Input, F, A	;subtract 10 from input
	incf	Quotient, F, A	;increment quotient
	movlw	0x09
	cpfsgt	Input, A	;stop when input less than 10
	bra	Score_DivMod_Epilogue
	bra	Score_DivMod
Score_DivMod_Epilogue:
	movff	Input, Remainder    ;the old input becomes the remainder of the division
	return
	
Score_Test_1:
	movlw	0x09
	cpfsgt	Score, A	;check if score is already less than 10 and doesn't need to broken down
	bra	Score_1_Digit
Score_Test_2:
	movlw	0x63
	cpfsgt	Score, A	;check if score is less than 100
	bra	Score_2_Digit
	bra	Score_3_Digit
	
Score_1_Digit:
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	GLCD_Display_O
	call	GLCD_Display_O	    ;First two digits always 0 if score < 10
	movff	Score, Score_Digit
	return		    ;test return to force score to be zero, remove after troubleshooting
	call	GLCD_Digit_Write
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	return
Score_2_Digit:
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	GLCD_Display_O	    ;First digit always 0 if score < 100 and >9
	call	Score_DivMod_Setup
	movff	Quotient, Score_Digit	;second digit is quotient of two digit score/10
	call	GLCD_Digit_Write
	movff	Remainder, Score_Digit	;third digit is remainder of two digit score/10
	call	GLCD_Digit_Write
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	return
Score_3_Digit:
	call	Score_DivMod_Setup
	movff	Remainder, Score_Digit	;third digit is remainder of 3 digit score/10
	movlw	0x67		    ;sets y-address to 39 (?)
	movwf	PORTD, A
	call	GLCD_enable
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	GLCD_Digit_Write
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	movff	Quotient, Score
	call	Score_DivMod_Setup
	movlw	0x5B		    ;sets y-address to 27 (?)
	movwf	PORTD, A
	call	GLCD_enable
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	movff	Quotient, Score_Digit	;first digit is quotient of previous two digit quotient/10
	call	GLCD_Digit_Write
	movff	Remainder, Score_Digit	;second digit is remainder of previous two digit quotient/10
	call	GLCD_Digit_Write
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	return
	
