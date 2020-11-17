#include <xc.inc>

global	Touch_Boom
    
psect	udata_acs   ;access ram for variables
Touch_counter:	ds  1

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    	
	Touch_DRIVEA EQU 4		;defines pin 4 as DRIVEA
        Touch_DRIVEB EQU 5		;defines pin 5 as DRIVEB

 psect	touch_code,class=CODE	
    
 
Touch_Boom:
    incf    Touch_counter, F, A
    return


