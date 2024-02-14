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
.include "M328PDEF.INC"
.cseg 
.org 0x00
	JMP MAIN

.org 0x0002
	JMP ISR_INT0

.org 0x0004	
	JMP ISR_INT1


MAIN:
;******************************************************************************
;Stack pointer
;******************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17 


Setup:
;Establece los pines como pullup
	SBI PORTD, PD2
	SBI PORTD, PD3
;Establece los puertos de entrada y salida
	CBI DDRD, PD2
	CBI DDRD, PD3

	LDI R18, (1 << ISC01)|(1 << ISC00)|(1 << ISC11)|(1 << ISC10)
	STS EICRA, R16

	SBI EIMSK, INT0
	SBI EIMSK, INT1


	SBI DDRB, PB5//mas significativo
	CBI PORTB, PB5
	SBI DDRB, PB4
	CBI PORTB, PB4
	SBI DDRB, PB3
	CBI PORTB, PB3
	SBI DDRB, PB2 // menos significativo
	CBI PORTB, PB2

	SEI

Loop:
	RJMP Loop 

;******************************************************************************
;Subrutinas
;******************************************************************************

	
LEDS:
;Verificamos el registro 20 bit por bit para encender cada led
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
	RET	
	
ISR_INT0:
;Guardamos el R16 en la pila para no perderla
	PUSH R16
	IN R16, SREG 
	PUSH R16

;Colocar el codigo que queremos aqui 
	INC R21
	CALL LEDS

	POP R16
	OUT SREG, R16
	POP R16
	RETI

ISR_INT1:
;Guardamos el R16 en la pila para no perderla
	PUSH R16
	IN R16, SREG 
	PUSH R16

;Colocar el codigo que queremos aqui 
	DEC R21
	CALL LEDS
;Sacar el r16 de la pila
	POP R16
	OUT SREG, R16
	POP R16
	RETI

	


