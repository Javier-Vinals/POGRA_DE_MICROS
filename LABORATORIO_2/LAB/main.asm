;******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de microcontrladores
;Autor: Javier Vi?als
;Laboratorio_2.asm
;
; Created: 30/01/2024
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
LDI R21, HIGH(RAMEND)
OUT SPH, R17
;******************************************************************************
; Configuracion
;******************************************************************************
Setup:

	LDI R16, 0b1000_0000
	STS CLKPR, R16  ; habilitar el prescaler
	//OUT DDRB, R16
	LDI R16, 0b0000_0011 
	STS CLKPR, R16  ; definiendo el prescaler de 8Fcpu = 2MHz

//boton 1 C1
	CBI DDRC, PC1 ; configuracion PC1 como entrada
	SBI PORTC, PC1	;Colocar PC1 como pullup
//boton 2 C1
	CBI DDRC, PC2 ; configuracion PC2 como entrada
	SBI PORTC, PC2	;Colocar PC2 como pullup


	//7 SEGMENTOS
	SBI DDRB, PB1	//b
	SBI DDRB, PB0	//a
	SBI DDRD, PD7	//f
	SBI DDRD, PD6	//g
	SBI DDRD, PD5	//c
	SBI DDRD, PD4	//d
	SBI DDRD, PD3	//e


	//CONDICIONALES
	LDI R21, 0x00 
	


LOOP:
	IN	R17, PINC	//Carga PIND a R17
	SBRS R17, 1
	JMP	INCC1
	SBRS R17, 2 
	JMP	DECC1
	JMP LEDS

	INCC1:
IN	R17, PINC
SBRS R17, 1
JMP	INCC1
LDI R16, 255
DelayINC:
	DEC	R16
	BRNE DelayINC
CPI	R21, 0x09
BREQ LOOP
INC R21
RJMP LEDS

	DECC1:
IN	R17, PINC
SBRS R17, 2 
JMP	DECC1
LDI R16, 255
DelayDEC:
	DEC	R16
	BRNE DelayDEC
CPI	R21, 0x00
BREQ LOOP
DEC R21
RJMP LEDS


SEG7:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	CBI PORTD, 7	//f
	CBI PORTD, 6	//g
	SBI PORTD, 5	//c
	CBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP LOOP
SEG8:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP LOOP
SEG9:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP LOOP


LEDS:

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
JMP LOOP


SEG0:
	SBI PORTB, 1	//b //set
	SBI PORTB, 0	//a //clear
	SBI PORTD, 7	//f
	CBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP LOOP
SEG1:
	SBI PORTB, 1	//b //set
	CBI PORTB, 0	//a //clear
	CBI PORTD, 7	//f
	CBI PORTD, 6	//g
	SBI PORTD, 5	//c
	CBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP LOOP
SEG2:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	CBI PORTD, 7	//f
	SBI PORTD, 6	//g
	CBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP LOOP
SEG3:
	SBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	CBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP LOOP
SEG4:
	SBI PORTB, 1	//b  
	CBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	CBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP LOOP
SEG5:
	CBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	CBI PORTD, 3	//e
	JMP LOOP
SEG6:
	CBI PORTB, 1	//b  
	SBI PORTB, 0	//a
	SBI PORTD, 7	//f
	SBI PORTD, 6	//g
	SBI PORTD, 5	//c
	SBI PORTD, 4	//d
	SBI PORTD, 3	//e
	JMP LOOP






