#include <xc.inc>

global	AsteroidMove_Page, AsteroidMove_Setup
extrn	GLCD_Asteroid, GLCD_enable, GLCD_yclear, GLCD_GameOver, GLCD_Lives_3, GLCD_Lives_2, GLCD_Lives_1
extrn	LCD_delay_ms
extrn	Touch_Boom
    
psect	udata_acs   ;access ram for variables
AsteroidMove_xaddress:	ds  1
AsteroidCounter:    ds	1   ;counter for number of asteroids that pass the bottom
Lives:	ds  1	;number of remaining lives, can maybe replace AsteroidCounter
    
;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    	
	AsteroidMove_RS EQU 2		;defines pin 2 as RS
	AsteroidMove_RW	EQU 3		;defines pin 3 as R/W
        AsteroidMove_E EQU 4		;defines pin 4 as enable

 psect	asteroidmove_code,class=CODE	
    
AsteroidMove_Setup:
	movlw	0x00
	movwf	AsteroidCounter, A
	movlw	0x03
	movwf	Lives, A
	call	GLCD_Lives_3
	return
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
	call	Touch_Boom	    ;summons touch input for later use
	movlw	0xFFFF		    ;loop to slow 3
	call	LCD_delay_ms
	movlw	0xFFFF		    ;loop to slow 4
	call	LCD_delay_ms
	movlw	0xBE		    ;maximum x-address value for loop
	cpfsgt	AsteroidMove_xaddress, A
	bra	PageLoop
	call	AsteroidDespawn
	return
	
AsteroidDespawn:
	call	GLCD_yclear	    ;clear screen
	call	GLCD_enable
	dcfsnz	Lives, A	;decrement lives, calls game over if it reaches 0
	call	GLCD_GameOver
	movlw	0x01
	cpfsgt	Lives, A
	call	GLCD_Lives_1
	movlw	0x02
	cpfslt	Lives, A
	call	GLCD_Lives_2
	movlw	0xB8		;command to set X-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	movlw	0x40		    ;sets y-address to 0
	movwf	PORTD, A
	call	GLCD_enable
	call	GLCD_Asteroid
	movlw	0xFFFF		    ;loop to slow 1
	call	LCD_delay_ms
	movlw	0xFFFF		    ;loop to slow 2
	call	LCD_delay_ms
	movlw	0xFFFF		    ;loop to slow 3
	call	LCD_delay_ms
	movlw	0xFFFF		    ;loop to slow 4
	call	LCD_delay_ms
	goto	AsteroidMove_Page
	
