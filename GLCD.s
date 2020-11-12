#include <xc.inc>

global	GLCD_setup, GLCD_write
extrn	LCD_delay_ms
    
psect	glcd_code,class=CODE

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    
        GLCD_E EQU 4		;defines pin 4 as enable
    
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
	movlw	0xC0
	movwf	PORTD, A
	call	GLCD_enable
	movlw	1
	call	LCD_delay_ms
	return
GLCD_write:
	movlw	0x26		;turn on CS2, RS, & RST high to avoid reset
	movwf	PORTB, A
	movlw	0xF0		;sample data
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
	return
	