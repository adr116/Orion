#include <xc.inc>
    
global	keyboard_setup
extrn	LCD_delay_ms

psect	udata_acs
key_row: ds	    1
key_column: ds	    1
    
psect	keyboard_code,class=CODE

keyboard_setup:
	banksel	PADCFG1
	bsf	REPU
	movlb	0x00	    ;enables pull-up resistors
	clrf	LATE, A
	return
keyboard_read:
	movlw	0x0F	    ;input for 0-3, output for 4-7
	movwf	TRISE, A
	movlw	0x14	    ;delay 20ms to allow circuit to settle
	call	LCD_delay_ms
	movff	PORTE, key_row ;records which row has been pressed
	call	row_read
column_read:
	movlw	0xF0
	movwf	TRISE, A    ;output for 0-3, input  for 4-7
	movlw	0x14
	call	LCD_delay_ms ;delay 20ms
	movff	PORTE, key_column ;records which column has been pressed
	return
row_read:
	movlw	0x0F
	cpfslt	key_row, A
	call	null_check  ;calls null_check if row is 1111B
	movlw	0x0E
	cpfslt	key_row, A
	call	F321	    ;calls F321 if only pin 0 null
	movlw	0x0D
	cpfslt	key_row, A
	call	E654	    ;calls E654 if only pin 1 null
	movlw	0x0C
	cpfslt	key_row, A
	call	oopsie	    ;calls error if multiple pins are 0
	movlw	0x0B
	cpfslt	key_row, A
	call	D987	    ;calls D987 if only pin 2 null
	movlw	0x08
	cpfslt	key_row, A
	call	oopsie	    ;calls error if multiple pins are 0
	movlw	0x07
	cpfslt	key_row, A
	call	CB0A	    ;calls CB0A if only pin 3 null
	call	oopsie	    ;calls error if multiple pins are 0
	return
F321:
	call	column_read


