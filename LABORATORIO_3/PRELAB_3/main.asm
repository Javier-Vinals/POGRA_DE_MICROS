;******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de microcontrladores
;Autor: Javier Viñals
;PRELAB_3.asm
;
; Created: 13/02/2024
;******************************************************************************
;Encabezado
;******************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN
.org 0x02
	JMP INCC1
.org 0X04
	JMP DECC1
;******************************************************************************
;Stack
;******************************************************************************
MAIN:
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R21, HIGH(RAMEND)
OUT SPH, R17
;******************************************************************************
; Configuracion
;******************************************************************************
Setup:

//boton 1 C1
	CBI DDRD, PD2 ; configuracion PD2 como entrada
	SBI PORTD, PD2	;Colocar PD2 como pullup
//boton 2 C1
	CBI DDRD, PD3 ; configuracion PD3 como entrada
	SBI PORTD, PD3	;Colocar PD3 como pullup

//Contador 1
	SBI DDRB, PB5//mas significativo
	CBI PORTB, PB5
	SBI DDRB, PB4
	CBI PORTB, PB4
	SBI DDRB, PB3
	CBI PORTB, PB3
	SBI DDRB, PB2 // menos significativo
	CBI PORTB, PB2

LDI R16, (1 << ISC11)|(1 << ISC10)|(1 << ISC01)|(1 << ISC00)
STS EICRA, R16

SBI EIMSK, INT0
SBI EIMSK, INT1

SEI

	//CONDICIONALES

LOOP:


	//LEDS ON
	SBRC R21, 0		; BIT 0 de R21 EN 1
	SBI PORTB, 2  ; LED EN PUERTO D2
	SBRC R21, 1		; BIT 1
	SBI PORTB, 3  ; PUERTO D3
	SBRC R21, 2		; BIT 2
	SBI PORTB, 4  ; PUERTO D4
	SBRC R21, 3		; BIT 3
	SBI PORTB, 5  ; PUERTO D5

	//LEDS OFF
	SBRS R21, 0
	CBI PORTB, 2
	SBRS R21, 1		; BIT 1
	CBI PORTB, 3  ; PUERTO D3
	SBRS R21, 2		; BIT 2
	CBI PORTB, 4  ; PUERTO D4
	SBRS R21, 3		; BIT 3
	CBI PORTB, 5  ; PUERTO D5

	RJMP LOOP


INCC1:
PUSH R16
IN R16, SREG
PUSH R16

INC R21

POP R16
OUT SREG, R16
POP R16
RETI

DECC1:
PUSH R16
IN R16, SREG
PUSH R16

DEC R21

POP R16
OUT SREG, R16
POP R16
RETI