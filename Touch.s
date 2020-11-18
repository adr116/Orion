#include <xc.inc>

global	Touch_Boom
    
psect	udata_acs   ;access ram for variables
Touch_counter:	ds  1

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    	
	Touch_SETY EQU 2		;defines pin 2 as SET-Y (PORTF)
	Touch_SETX EQU 5		;defines pin 5 as SET-X (PORTF)
	Touch_DRIVEA EQU 4		;defines pin 4 as DRIVEA (PORTE)
        Touch_DRIVEB EQU 5		;defines pin 5 as DRIVEB (PORTE)

 psect	touch_code,class=CODE	
    
 
Touch_Boom:
    incf    Touch_counter, F, A
    return
ADC_Setup:		    ;should initialize F2 pin for analogue
	bsf	TRISF, PORTF_RF2_POSN, A  ; pin RF2==AN0 input
	bsf	ANSEL0	    ; set AN0 to analog
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return
ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

