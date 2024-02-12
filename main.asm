;******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de microcontrladores
;Autor: Javier Viñals
;Laboratorio_1.asm
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
//boton 1 C2
	CBI DDRC, PC3 ; configuracion PC3 como entrada
	SBI PORTC, PC3	;Colocar PC3 como pullup
//boton 2 C2
	CBI DDRC, PC4 ; configuracion PC4 como entrada
	SBI PORTC, PC4	;Colocar PC4 como pullup
//boton Suma
	CBI DDRC, PC5 ; configuracion PC5 como entrada
	SBI PORTC, PC5	;Colocar PC5 como pullup

//Contador 1
	SBI DDRB, PB5//mas significativo
	SBI DDRB, PB4
	SBI DDRB, PB3
	SBI DDRB, PB2 // menos significativo

//Contador 2
	SBI DDRB, PB1
	SBI DDRB, PD0
	SBI DDRD, PD7
	SBI DDRD, PD6

//Contador SUMA
	SBI DDRD, PD5
	SBI DDRD, PD4
	SBI DDRD, PD3
	SBI DDRD, PD2

	//CONDICIONALES
	LDI R18, 0x01
	LDI R21, 0x00 //registro de contador 1

LOOP:

	IN		R17, PINC			//Carga PIND a R17
	CPI	R17, 0x01 
	BREQ	INCC1

	CPI	R17, 0x02 //Compara con un inmediato, viendo si presiono el 3er botón
	BREQ	DECC1

	//LEDS ON
	SBRC R21, 0		; BIT 0 de R21 EN 1
	SBI PORTD, 2  ; LED EN PUERTO D2
	SBRC R21, 1		; BIT 1
	SBI PORTD, 3  ; PUERTO D3
	SBRC R21, 2		; BIT 2
	SBI PORTD, 4  ; PUERTO D4
	SBRC R21, 3		; BIT 3
	SBI PORTD, 5  ; PUERTO D5

	//LEDS OFF
	SBRS R21, 0
	CBI PORTD, 2
	SBRS R21, 1		; BIT 1
	CBI PORTD, 3  ; PUERTO D3
	SBRS R21, 2		; BIT 2
	CBI PORTD, 4  ; PUERTO D4
	SBRS R21, 3		; BIT 3
	CBI PORTD, 5  ; PUERTO D5

	RJMP LOOP


INCC1:
IN	R17, PINC
CPI	R17, 0x01
BREQ INCC1
CPI	R21, 0x0F
BREQ LOOP
INC R21
RJMP LOOP

DECC1:
IN	R17, PINC
CPI	R17, 0x02
BREQ DECC1
CPI	R21, 0x00
BREQ LOOP
DEC R21
RJMP LOOP

