#include <xc.inc>

global	Boom
    
psect	udata_acs   ;access ram for variables
Touch_boom:	ds  1

;PORTB: 0=CS1 (1=left screen), 1=CS2 (1=right screen), 2=RS (0=instruction, 1=data)
    ;3=R/W (0=write, 1=read), 4=E (0=disable, 1=enable signal), 5=RST (0=reset)
    	
	AsteroidMove_RS EQU 2		;defines pin 2 as RS
	AsteroidMove_RW	EQU 3		;defines pin 3 as R/W
        AsteroidMove_E EQU 4		;defines pin 4 as enable

 psect	touch_code,class=CODE	
    
 
Boom:
    incf    Touch_boom
    return


