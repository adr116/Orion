#include <xc.inc>

global	Touch_Boom, ADC_Setup
    
extrn	LCD_delay_ms
extrn	BranchHub
    
psect	udata_acs   ;access ram for variables
Touch_counter:	ds  1
Touch_ADH:	ds  1
Touch_ADL:	ds  1

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    	
	Touch_READY EQU 2		;defines pin 2 as SET-Y (PORTF)
	Touch_READX EQU 5		;defines pin 5 as SET-X (PORTF)
	Touch_DRIVEA EQU 4		;defines pin 4 as DRIVEA (PORTE)
        Touch_DRIVEB EQU 5		;defines pin 5 as DRIVEB (PORTE)

 psect	touch_code,class=CODE	
    
 
Touch_Boom:
	;incf    Touch_counter, F, A
	;bcf	PORTF, Touch_READY, A
	;bsf	PORTF, Touch_READX, A
	call    xaxis			;measures page (vertical)
	movff	ADRESH, Touch_ADH, A	;stores high analogue bits for reference
	movff	ADRESL, Touch_ADL, A	;stores low analogue bits for reference
	;call	comparisonx
	call	yaxis			;measures horizontal position
	movff	ADRESH, Touch_ADH, A
	movff	ADRESL, Touch_ADL, A
	call	comparisony		;checks if asteroid is hit
	return
xaxis:
	movlw   00011101B        ; select AN7 for measurement and turn ADC on
	movwf   ADCON0, A  
	bcf	LATE, Touch_DRIVEA, A    ;deactivates yaxis measurement before xaxis
	bsf	LATE, Touch_DRIVEB, A    ;activates xaxis measurement
	movlw   0x01            ;loop to slow 1
	call    LCD_delay_ms
	call    ADC_Read
	return
yaxis:
	movlw	00101001B
	movwf	ADCON0, A
	bcf	LATE, Touch_DRIVEB, A    ;deactivates xaxis measurement before yaxis
	bsf	LATE, Touch_DRIVEA, A    ;activates yaxis measurement
	movlw	0x01
	call	LCD_delay_ms
	call	ADC_Read
	return
;comparisonx:				;resets asteroid if correct page hit
	;movlw	0x00			;where one can hit the asteroid
	;cpfslt	Touch_ADH, A		;is a hit if less than w
	;return
	;call	BranchHub
comparisony:				;resets asteroid if correct column hit
	movlw	0x00			;registering if there is any touch
	cpfsgt	Touch_ADH, A		
	return
	movlw	0x02
	cpfsgt	Touch_ADH, A			;does not hit asteroid if greater than w
	call	BranchHub
	return
ADC_Setup:		    ;should initialize F2 & F5 pins for analogue
	bcf	TRISE, Touch_DRIVEA, A ;sets DRIVEA pin to input
	bcf	TRISE, Touch_DRIVEB, A ;sets DRIVEB pin to input
	bsf	TRISF, PORTF_RF2_POSN, A ; pin RF2==AN7 input
	bsf	TRISF, PORTF_RF5_POSN, A ; pin RF5==AN10 input
	banksel ANCON0
	bsf	ANSEL7		; set AN7 to analog
	bsf	ANSEL10		; set AN10 to analog
	movlw	0x30		; Select 4.096V positive reference
	movwf	ADCON1, A	; 0V for -ve reference and -ve input
	movlw	0xF6		; Right justified output
	movwf	ADCON2, A	; Fosc/64 clock and acquisition times
	return
ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return

