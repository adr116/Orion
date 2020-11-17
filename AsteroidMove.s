#include <xc.inc>

global	AsteroidMove_Page
extrn	GLCD_Asteroid, GLCD_enable, GLCD_yclear
extrn	LCD_delay_ms
    
psect	udata_acs   ;access ram for variables
AsteroidMove_xaddress:	ds  1

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    	
	AsteroidMove_RS EQU 2		;defines pin 2 as RS
	AsteroidMove_RW	EQU 3		;defines pin 3 as R/W
        AsteroidMove_E EQU 4		;defines pin 4 as enable

 psect	asteroidmove_code,class=CODE	
    
	
AsteroidMove_Page:
	movlw	0xB8			;sets page to 0
	movwf	AsteroidMove_xaddress, A
	bcf	LATB, AsteroidMove_RS, A
	bcf	LATB, AsteroidMove_RW, A
	movwf	PORTD, A
	call	GLCD_enable
	call	PageLoop
	return

PageLoop:
	call	GLCD_yclear		;empties page
	incf	AsteroidMove_xaddress, F, A
	movff	AsteroidMove_xaddress, PORTD
	call	GLCD_enable
	movlw	0x40		    ;sets y-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	call    GLCD_Asteroid
	movlw	0xFFFF		    ;loop to slow 1
	call	LCD_delay_ms
	movlw	0xFFFF		    ;loop to slow 2
	call	LCD_delay_ms
	movlw	0xFFFF		    ;loop to slow 3
	call	LCD_delay_ms
	movlw	0xFFFF		    ;loop to slow 4
	call	LCD_delay_ms
	movlw	0xBF		    ;maximum x-address value for loop
	cpfsgt	AsteroidMove_xaddress, A
	bra	PageLoop
	return