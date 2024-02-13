
;******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de Microcontroladores 
;Antirebote.asm
;Autor; Javier Viñals
;Proyecto; LAB 1
;Hardware: Atemega328P
;Creado: 29/01/2024
;Ultima modificacion: 05/02/2024
;******************************************************************************


;******************************************************************************
;Encabezado
;******************************************************************************
.include "M328PDEF.inc"
.cseg

.org 0x00

;******************************************************************************
;Stack
;******************************************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17

;******************************************************************************
; Configuracion
;******************************************************************************

SetupTimer:
CALL INIT_T0

Setup:
	LDI R16, 0b1000_0000
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16			;Habilita el prescaler
	LDI R16, 0b0000_0011
	STS CLKPR, R16			;DEFINIENDO EL PRESCALER DE 8 Fcpu = 2MHz

	CBI DDRC, PC1		;PC1 como entrada
	SBI PORTC, PC1		;pullup

	CBI DDRC, PC2 
	SBI PORTC, PC2	

	//7 SEGMENTOS
	SBI DDRB, PB1	//b
	SBI DDRB, PB0	//a
	SBI DDRD, PD7	//f
	SBI DDRD, PD6	//g
	SBI DDRD, PD5	//c
	SBI DDRD, PD4	//d
	SBI DDRD, PD3	//e

;******************************************************************************
;Contador
;******************************************************************************
	SBI DDRB, PB5
	SBI DDRB, PB4
	SBI DDRB, PB3
	SBI DDRB, PB2 

;******************************************************************************
SEG7:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	CBI PORTD, 7	//f
	CBI PORTD, 6	//g
	SBI PORTD, 5	//c
	CBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP Delay
SEG8:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP Delay
SEG9:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP Delay


LOOP:
CPI R21, 0x00
BREQ SEG0
CPI R21, 0x01
BREQ SEG1
CPI R21, 0x02
BREQ SEG2
CPI R21, 0x03
BREQ SEG3
CPI R21, 0x04
BREQ SEG4
CPI R21, 0x05
BREQ SEG5
CPI R21, 0x06
BREQ SEG6
CPI R21, 0x07
BREQ SEG7
CPI R21, 0x08
BREQ SEG8
CPI R21, 0x09
BREQ SEG9
SEG0:
	SBI PORTB, 1	//b //set
	SBI PORTB, 0	//a //clear
	SBI PORTD, 7	//f
	CBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP Delay
SEG1:
	SBI PORTB, 1	//b //set
	CBI PORTB, 0	//a //clear
	CBI PORTD, 7	//f
	CBI PORTD, 6	//g
	SBI PORTD, 5	//c
	CBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP Delay
SEG2:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	CBI PORTD, 7	//f
	SBI PORTD, 6	//g
	CBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP Delay
SEG3:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	CBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP Delay
SEG4:
	SBI PORTB, 1	//b  
	CBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	CBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP Delay
SEG5:
	CBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP Delay
SEG6:
	CBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP Delay

DELAY:
	LDI R16, 255
	DelayInc:
		DEC	R16
		BRNE DelayInc

	SBIS PINC, PC1
	RJMP DELAY
	RJMP TIMER

	TIMER:
IN R16, TIFR0
CPI R16, (1 << TOV0)
BRNE TIMER

LDI R16, 100
OUT TCNT0, R16

SBI TIFR0, TOV0

INC R20
CPI R20, 2
BRNE TIMER

CLR R20

JMP INCREMENTO1


INCREMENTO1:
INC R21
SBRC R21, 4
LDI R21, 0x00
JMP LOOP

INIT_T0:

LDI R16, (1 << CS02) | (1 << CS00)
OUT TCCR0B, R16

LDI R16, 255
OUT TCNT0, R16

JMP Setup