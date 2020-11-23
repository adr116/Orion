#include <xc.inc>

global	Touch_Boom, ADC_Setup
    
extrn	LCD_delay_ms
    
psect	udata_acs   ;access ram for variables
Touch_counter:	ds  1
Touch_ADH:	ds  2
Touch_ADL:	ds  2

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
	call    xaxis
	movff	ADRESH, Touch_ADH, A	;stores high analogue bits for reference
	movff	ADRESL, Touch_ADL, A	;stores low analogue bits for reference
	
	call	yaxis

	return
xaxis:
	bcf	LATE, Touch_DRIVEA, A    ;deactivates yaxis measurement before xaxis
	bsf	LATE, Touch_DRIVEB, A    ;activates xaxis measurement
	movlw	0x01		    ;loop to slow 1
	call	LCD_delay_ms
	call	ADC_Read
	return
yaxis:
	bcf	LATE, Touch_DRIVEB, A    ;deactivates xaxis measurement before yaxis
	bsf	LATE, Touch_DRIVEA, A    ;activates yaxis measurement
	movlw	0x01
	call	LCD_delay_ms
	call	ADC_Read
	return
ADC_Setup:		    ;should initialize F2 & F5 pins for analogue
	bcf	TRISE,	Touch_DRIVEA, A	    ;sets DRIVEA pin to input
	bcf	TRISE,	Touch_DRIVEB, A	    ;sets DRIVEB pin to input
	bsf	TRISF, PORTF_RF2_POSN, A  ; pin RF2==AN7 input
	banksel ANCON0
	bsf	ANSEL7	    ; set AN7 to analog
	movlw   0x01	    ; select AN7 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	bsf	TRISF, PORTF_RF5_POSN, A  ; pin RF5==AN10 input
	bsf	ANSEL10	    ; set AN10 to analog
	movlw   0x01	    ; select AN10 for measurement
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

