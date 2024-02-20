;******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de microcontroladores
;Autor: Javier Viñals
;LAB_3.asm
;
; Created: 20/02/2024
;******************************************************************************
;Encabezado
;******************************************************************************
.include "M328PDEF.INC"
.cseg 
.org 0x00
	JMP MAIN
.org 0x0020
	JMP INT_TIMER0  //interrupccion de timer
;******************************************************************************
;Stack
;******************************************************************************
MAIN:
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17 
;******************************************************************************
; Configuracion
;******************************************************************************
Setup:

	LDI R16, 0b1000_0000     //el timer se establece a 8MHz
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16

	LDI R16, 0b0000_0001
	STS CLKPR, R16

	LDI R16, 0b1111_1111	//Configuramos el puerto D como salidas de 7SEG
	OUT DDRD, R16

	SBI DDRC, PC5	//transistor DECENAS
	SBI DDRC, PC4	//TRANSISTOR UNIDADES


	LDI R19, 0x00	//Registro de cotador 7SEG DECENAS
	LDI R20, 0x00	//registro de contador 7SEG UNIDADES
	LDI R21, 0x00	//registro contador 1000ms

	SEI

	CALL INT_T0  //inicializacion del timer0

;******************************************************************************
;LOOP
;******************************************************************************
LOOP:

	CPI R20, 10
	BREQ RESETUNI

	CPI R19, 6
	BREQ RESETDECE

	CPI R20, 255	//50
	BREQ INC7SEG

//Unidades
	SBI PORTC, 4  //ENCENDER UNIDADES
	CBI PORTC, 5	//APAGAR DECENAS
	
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R20
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 

	//Decenas
	CBI PORTC, 4  //APAGAR UNIDADES
	SBI PORTC, 5	//ENCENDER DECENAS

	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R19
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 


	JMP LOOP
;******************************************************************************
;Subrutinas
;******************************************************************************
RESETUNI: 
	LDI R20, 0
	INC R19
	JMP LOOP

	RESETDECE: 
	LDI R19, 0
	LDI R20, 0
	JMP LOOP

INC7SEG:
	LDI R21, 0
	INC R20
	JMP LOOP

INT_T0:
	LDI R26, 0
	OUT TCCR0A, R26      //inicializacion de timer 0 como contador 
	
	LDI R26, (1<<CS02) | (1<<CS00)     //seleccion de prescaler de 1024 
	OUT TCCR0B, R26       
	
	LDI R26, 100        //valor de conteo inicial 
	OUT TCNT0, R26

	LDI R26, (1<<TOIE0)   
	STS TIMSK0, R26
	RET

	INT_TIMER0:
	PUSH R16        //guardamos el valor de R16
 	IN R16, SREG
	PUSH R16

	LDI R16, 100
	OUT TCNT0, R16      
	SBI TIFR0, TOV0		//10ms
	
	INC R21           //Contador de interrupciones

	POP R16
	OUT SREG, R16  
	POP R16         //Devolvemos el valor antes guardado
	RETI


TABLA7SEG: .DB 0xEE, 0x22, 0xD6, 0x76, 0x3A, 0x7C, 0xFC, 0x26, 0xFE, 0x3E 
//ver los pines en el circuito