#include <xc.inc>

extrn	GLCD_setup, GLCD_Asteroid
extrn	AsteroidMove_Page, AsteroidMove_Setup
extrn	Touch_Boom, ADC_Setup
extrn	Score_Setup
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	GLCD_setup
	call	Score_Setup
	call	AsteroidMove_Setup
	call	ADC_Setup
	goto	start
	
start:
	call	AsteroidMove_Page
	goto	$		; goto current line in code

	end	rst