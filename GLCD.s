#include <xc.inc>

extrn	LCD_delay_ms
    
GLCD_setup:
	clrf	LATB, A
	movlw	0x3F		;turn on TRISB for 0-5 (input)
	movwf	TRISB, A
	movlw	40
	call	LCD_delay_ms
	movlw	0x33		;turn on CS1&2, E
	movwf	PORTB, A	
	setf	TRISD, A	;turn on input for all TRISD
	movlw	0x3F		;command to turn on GLCD
	movwf	PORTD
	movlw	1
	call	LCD_delay_ms
	return
GLCD_write:
	movlw	0x37	    ;turn on CS1&2, RS, E
	movwf	PORTB
	movlw	0xFF	    ;sample data
	movwf	PORTD