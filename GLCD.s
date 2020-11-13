#include <xc.inc>

global	GLCD_setup, GLCD_Asteroid
extrn	LCD_delay_ms
    
psect	udata_acs   ;access ram for variables
GLCD_ycounter:	ds  1	;for left/right
GLCD_xcounter:	ds  1	;for up/down

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    
        GLCD_E EQU 4		;defines pin 4 as enable
	GLCD_RS EQU 2		;defines pin 2 as RS

 psect	glcd_code,class=CODE
    
GLCD_setup:
	clrf	LATB, A
	movlw	0xC0		;turn off TRISB for 0-5 (output)
	movwf	TRISB, A
	clrf	LATD, A
	clrf	TRISD, A	;turn off input for all TRISD
	movlw	40
	call	LCD_delay_ms
	movlw	0x20		;turn on CS1&2, keep RST high (to avoid reset)
	movwf	PORTB, A	
	movlw	0x3F		;command to turn on GLCD
	movwf	PORTD, A
	call	GLCD_enable
	movlw	1
	call	LCD_delay_ms
	movlw	0x40		;command to set Y-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	movlw	1
	call	LCD_delay_ms
	movlw	0xB8		;command to set X-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	movlw	1
	call	LCD_delay_ms
	movlw	0xC0		;command to set Z-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	movlw	1
	call	LCD_delay_ms
	call	GLCD_clear
	return
GLCD_clear:
	movlw	0xB8
	movwf	GLCD_xcounter, A    ;pages in each display
clear_xloop:
	call	GLCD_yclear
	incf	GLCD_xcounter, F, A
	movff	GLCD_xcounter, PORTD
	call	GLCD_enable
	movlw	0xBF
	cpfsgt	GLCD_xcounter, A
	bra	clear_xloop
	return
GLCD_yclear:
	clrf	GLCD_ycounter, A    ;columns in each page
clear_yloop:
	call	blank
	incf	GLCD_ycounter, F, A
	movlw	0x3F		;63 as there are 64 columns
	cpfsgt	GLCD_ycounter, A
	bra	clear_yloop
	return
blank:
	bsf	LATB, GLCD_RS, A
	clrf	PORTD, A
	call	GLCD_enable
	bcf	LATB, GLCD_RS, A
	return
GLCD_Asteroid:
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	Asteroid_P1	    ;draws rhombus drawing
	call	Asteroid_P2
	call	Asteroid_P3
	call	Asteroid_P4
	call	Asteroid_P4
	call	Asteroid_P3
	call	Asteroid_P2
	call	Asteroid_P1
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	return
Asteroid_P1:
	movlw	0x18		;asteroid P1 is two dots on left/right
	movwf	PORTD, A
	call	GLCD_enable
	return
Asteroid_P2:
	movlw	0x3C		;asteroid P2 is four dots
	movwf	PORTD, A
	call	GLCD_enable
	return
Asteroid_P3:	
	movlw	0x7E		;asteroid P3 is six dots
	movwf	PORTD, A
	call	GLCD_enable
	return
Asteroid_P4:
	movlw	0xFF		;asteroid P4 is eight dot middle
	movwf	PORTD, A
	call	GLCD_enable
	return
GLCD_enable:
	nop			;each command is 250ns, at 16MHz
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	LATB, GLCD_E, A	;sets E on
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	LATB, GLCD_E, A	;sets E off
	movlw	0x01
	call	LCD_delay_ms
	return
	