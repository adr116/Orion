#include <xc.inc>

global	GLCD_setup, GLCD_Asteroid, GLCD_enable, GLCD_yclear, GLCD_GameOver, GLCD_Lives_3, GLCD_Lives_2, GLCD_Lives_1
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
	movlw	0x22		;turn on CS1, keep RST high (to avoid reset)
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
	movlw	0xB8		;command to set X-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	call	GLCD_Asteroid
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
GLCD_GameOver:
	movlw	0xB8			;sets page to 0
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x40		    ;sets y-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	Display_G	;drawing the letters
	call	Display_A
	call	Display_M
	call	Display_E
	movlw	0x00	    ;extra space before next word
	movwf	PORTD, A
	call	GLCD_enable
	call	Display_O
	call	Display_V
	call	Display_E
	call	Display_R
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	goto	$
GLCD_Lives_3:
	movlw	0xBF			;sets page to 7
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x61		    ;sets y-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	Display_L	    ;draws rhombus drawing
	call	Display_I
	call	Display_V
	call	Display_E
	call	Display_S_Colon
	call	Display_3
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	return
GLCD_Lives_2:
	movlw	0xBF			;sets page to 7
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x61		    ;sets y-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	Display_L	    ;draws rhombus drawing
	call	Display_I
	call	Display_V
	call	Display_E
	call	Display_S_Colon
	call	Display_2
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	return
GLCD_Lives_1:
	movlw	0xBF			;sets page to 7
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x61		    ;sets y-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	bsf	LATB, GLCD_RS, A    ;turns on RS pin to read/write data
	call	Display_L	    ;draws rhombus drawing
	call	Display_I
	call	Display_V
	call	Display_E
	call	Display_S_Colon
	call	Display_1
	bcf	LATB, GLCD_RS, A    ;turns off RS pin to avoid read/write data
	return
Display_G:
	movlw	0x7C		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x82
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0xA2
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x64
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0xE0
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_A:
	movlw	0xF8		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x24
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x22
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0xFE
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_M:
	movlw	0xFE		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x08
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x10
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x20
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x10
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x08	    
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0xFE
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return	
Display_E:
	movlw	0xFE		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x92
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x92
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x82
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_O:
	movlw	0x7C		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x82
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x82
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x7C
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_V:
	movlw	0x3E		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x40
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x80
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x40
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x3E
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_R:
	movlw	0xFE		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x22
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x62
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x9C
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_L:
	movlw	0xFE		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x80
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x80
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x80
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_I:
	movlw	0xFE	    ;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_S_Colon:
	movlw	0x4C		;drawing each column in the letters
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x92
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x92
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x64
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before colon
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x28	    ;colon
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next letter
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_1:
	movlw	0x08		;drawing each column in the number
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x04
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0xFE
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next number
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_2: 
	movlw	0xC4		;drawing each column in the number
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0xA2
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x92
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x8C
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next number
	movwf	PORTD, A
	call	GLCD_enable
	return
Display_3: 
	movlw	0x44		;drawing each column in the number
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x92
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x92
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x6C
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x00	    ;space before next number
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
