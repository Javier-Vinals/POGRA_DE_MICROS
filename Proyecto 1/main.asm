;******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de microcontrladores
;Autor: Javier Viñals
;PROYECTO_1.asm
;
; Created: 13/02/2024
;******************************************************************************
;Encabezado
;******************************************************************************
.include "M328PDEF.INC"
.dseg 
	segunid: .byte 1
	segdece: .byte 1
	minunid: .byte 1
	mindece: .byte 1
	horunid: .byte 1  
	hordece: .byte 1

	diaunid: .byte 1
	diadece: .byte 1
	mes:	 .byte 1
	mesunid: .byte 1
	mesdece: .byte 1

.cseg
.org 0x00
	JMP MAIN
.org 0x0002
	JMP ISR_INT0	//interrupcion INT0	PD2
.org 0x0020
	JMP INT_TIMER0  //interrupccion de timer

MAIN:
;******************************************************************************
;Stack pointer
;******************************************************************************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
;******************************************************************************
;SETTING
;******************************************************************************
Setup:

	LDI	R16, 0x00		;Deshabilitando RX y TX
	STS	UCSR0B, R16

	//Configuracion reloj
	LDI R16, 0b1000_0000     //el timer se establece a 8MHz   
	LDI R16, (1 << CLKPCE)
	STS CLKPR, R16

	LDI R16, 0b0000_0001	//divisor 2
	STS CLKPR, R16

	//Salidas 7SEG y transistores
	LDI R16, 0b0111_1111	//Configuramos el puerto C como salidas de 7SEG
	OUT DDRC, R16
	//Transistores y buzzer
	LDI R16, 0b1110_0011
	OUT DDRD, R16
	//Transistores, Leds indicadores y Led reloj
	LDI R16, 0b0011_1111
	OUT DDRB, R16


	//Botones displays
	//Establece los pines como pullup 
	SBI PORTD, PD3
	SBI PORTD, PD4
	//Establece los puertos de entrada y salida 
	CBI DDRD, PD3
	CBI DDRD, PD4
	//Interrupciones botones
	//Establece los pines como pullup 
	SBI PORTD, PD2
	//Establece los puertos de entrada y salida 
	CBI DDRD, PD2
	//Activacion cuando flanco alto
	LDI R18, (1 << ISC01)|(1 << ISC00)//|(1 << ISC11)|(1 << ISC10)
	STS EICRA, R16
	//Activar interrupciones
	SBI EIMSK, INT0

	SEI

	CALL INT_T0  //inicializacion del timer0

	CLR R17 //Reloj

	CLR R18//Fecha

	CLR R19 //Unidades minutos ALARMA
	CLR R20 //Decenas minutos ALARMA
	CLR R21 //Unidades horas ALARMA
	CLR R22 //Decenas horas ALARMA

	CLR R23 //Contador de interrupciones TIMER

	CLR R24 //Registro de MODOS

	CLR R16 //REGISTRO TEMPORAL

;******************************************************************************
;LOOP RELOJ
;******************************************************************************
RJMP LOOPRELOJ

RESETHORA:
	LDS R17, horunid
	SBRS R17, 4
	RET
	CLR R17
	STS horunid, r17
	sts hordece, R17
	LDS R18, diaunid
	INC R18
	STS diaunid, R18
	JMP LOOPRELOJ

LOOPRELOJ:
	CPI R23, 50//50	// INCrementa Unidades SEGundos , Reseteo incrementos
	BREQ INCUSEG

	LDS R17, segunid
	CPI R17, 10
	BREQ INCDSEG //INCrementa Decenas SEGundos

	LDS R17, segdece
	CPI R17, 6
	BREQ INCUMIN //INCrementa Unidades MINutos

	LDS R17, minunid
	CPI R17, 10
	BREQ INCDMIN  //INCrementa Decenas MINutos

	LDS R17, mindece
	CPI R17, 6
	BREQ INCUHOR

	LDS R17, horunid
	CPI R17, 10
	BREQ INCDHOR

	LDS R17, hordece
	CPI R17, 2
	BREQ RESETHORA

	JMP LOOPFECHA

INCUSEG:	//Aumenta cada segundo
	CLR R23
	LDS R17, segunid
	INC R17	
	STS segunid, R17 
	RET

INCDSEG:	//Aumenta decenas de SEGUNDOS
	LDS R17, segunid
	CLR R17
	STS segunid, R17

	LDS R17, segdece
	INC R17
	STS segdece, R17
	RET

INCUMIN://Aumenta unidades de MINUTOS
	LDS R17, segdece
	CLR R17
	STS segdece, R17
	LDS R17, minunid
	INC R17
	STS minunid, R17
	RET

INCDMIN://Aumenta decenas de MINUTOS
	LDS R17, minunid
	CLR R17
	STS minunid, R17
	LDS R17, mindece
	INC R17
	STS mindece, R17
	RET
	//RJMP LOOPRELOJ

INCUHOR://Aumenta unidades de HORAS
	LDS R17, mindece
	CLR R17
	STS mindece, R17
	LDS R17, horunid
	INC R17
	STS horunid, R17
	RET

INCDHOR:
	CLR R17
	STS mindece, R17
	LDS R17, mindece
	INC R17
	STS horunid, R17
	RET

;******************************************************************************
;LOOP FECHA
;******************************************************************************
LOOPFECHA:
	LDS R18, diaunid
	CPI R18, 10
	BREQ INCUDIA //INCrementa Unidad DIA

//AQUI SE PONDRA FEO
	CPI R18, 2
	BREQ BYE_FEBRERO_1 //Febrero 2024

	LDS R18, diadece
	BREQ SELECTMES //buscara meses de 30 y 31 dias

	JMP SELECTOR

INCUDIA:
	CLR R18
	STS diaunid, R18
	LDS R18, diadece
	INC R18
	STS diadece, R18
	RET

BYE_FEBRERO_1:
	LDS R18, diadece
	CPI R18, 2
	BREQ BYE_FEBRERO_2
	RET
BYE_FEBRERO_2:
	LDS R18, diaunid
	CPI R18, 9
	BREQ BYE_MES
	RET


SELECTMES:
	LDS R18, diadece
	CPI R18, 1
	BREQ SELECTMES_30
	CPI R18, 2
	BREQ SELECTMES_31
	RET
SELECTMES_30:
	LDS R18, mes
	CPI R18, 4 //abril
	BREQ BYE_MES
	CPI R18, 6 //JUNIO
	BREQ BYE_MES
	CPI R18, 9//SEPTIEMBRE
	BREQ BYE_MES
	CPI R18, 11//NOVIEMBRE
	BREQ BYE_MES
	RET
SELECTMES_31:
	LDS R18, mes
	CPI R18, 1//enero
	BREQ BYE_MES
	CPI R18, 3//marzo
	BREQ BYE_MES
	CPI R18, 5//MAYO
	BREQ BYE_MES
	CPI R18, 7//JULIO
	BREQ BYE_MES
	CPI R18, 8//AGOSTO
	BREQ BYE_MES
	CPI R18, 10//OCTUBRE
	BREQ BYE_MES
	CPI R18, 12//DICIEMBRE
	BREQ BYE_MES
	RET

BYE_MES:
	LDS R18, mes
	INC R18
	STS mesunid, R18
	CLR R18
	STS diadece, R18
	LDI R18, 0b0000_0001
	STS diaunid, R18

	LDS R18, mes
	CPI R18, 13
	BREQ RST_ANYO
	RJMP SELECTOR

	RST_ANYO:
	LDS R18, mes
	LDI R18, 0b0000_0001
	STS mes, R18
	RET
;******************************************************************************
;SELECTOR MODOS
;******************************************************************************
SELECTOR:
	CPI R24, 6
	BREQ RESETSELEC

	CPI R24, 0
	BREQ MODRELOJ
	CPI R24, 1
	BREQ MODFECHA
	CPI R24, 2
	BREQ MODRELOJCONF_HORA
	CPI R24, 3
	BREQ MODRELOJCONF_MINU
	CPI R24, 4
	BREQ MODFECHACONG_MES
	CPI R24, 5
	BREQ MODFECHACONG_DIA
/*	CPI R24, 6
	BREQ MODALARMA_HORA
	CPI R24, 7
	BREQ MODALARMA_MINU*/

	RESETSELEC:
	CLR R24
	RET

	MODRELOJ:
		JMP RELOJ
	MODFECHA:
		JMP FECHA
	MODRELOJCONF_HORA:
		JMP RELOJCONF_HORA
	MODRELOJCONF_MINU:
		JMP RELOJCONF_MINU
	MODFECHACONG_MES:
		JMP FECHACONF_MES
	MODFECHACONG_DIA:
		JMP FECHACONF_DIA
	/*MODALARMA_HORA:
		JMP ALARMA_HORA
	MODALARMA_MINU:
		JMP ALARMA_MINU*/
;******************************************************************************
;MODOS
;******************************************************************************
//RELOJ
RELOJ:

	SBI PORTB, PB4
	CBI PORTB, PB3
	CBI PORTD, PD0

//Unidades Segundos
	SBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7
	CBI PORTB, PB0
	CBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, segunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays }
	CALL DELAY

//Decenas Segundos
	CBI PORTD, PD5
	SBI PORTD, PD6	//DECENAS SEGUNDOS
	CBI PORTD, PD7
	CBI PORTB, PB0
	CBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, segdece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

//Unidades Minutos
	CBI PORTD, PD5
	CBI PORTD, PD6
	SBI PORTD, PD7
	CBI PORTB, PB0
	CBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, minunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25   //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

//Decenas Minutos
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7
	SBI PORTB, PB0
	CBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, mindece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25    //se envia el valor al puerto para verlo en los displays
	CALL DELAY

//Unidades Horas
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7
	CBI PORTB, PB0
	SBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, horunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

//Decenas Horas
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7
	CBI PORTB, PB0
	CBI PORTB, PB1
	SBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, hordece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	JMP LOOPRELOJ

//FECHA
FECHA:
	CBI PORTB, PB4
	SBI PORTB, PB3
	CBI PORTD, PD0

	LDS R18, mesunid
	LDS R16, mes
	MOV R18, R16
	STS mesunid, R18
	LDS R18, mesdece
	CLR R18
	STS mesdece, R18

	LDS R18, mesunid
	CPI R18, 10
	BREQ FECHA_10
	CPI R18, 11
	BREQ FECHA_11
	CPI R18, 12
	BREQ FECHA_12
	RJMP FECHA_ARREGLADA

FECHA_10:
	LDI R18, 0b0000_0001
	STS mesdece, R18
	LDI R18, 0b0000_0000
	STS mesdece, R18
	RJMP FECHA_ARREGLADA

FECHA_11:
	LDI R18, 0b0000_0001
	STS mesdece, R18
	LDI R18, 0b0000_0001
	STS mesdece, R18
	RJMP FECHA_ARREGLADA
FECHA_12:
	LDI R18, 0b0000_0001
	STS mesdece, R18
	LDI R18, 0b0000_0010
	STS mesdece, R18
	RJMP FECHA_ARREGLADA

FECHA_ARREGLADA:
	SBI PORTB, PB2	//DECENAS HORAS
	CBI PORTB, PB1
	CBI PORTB, PB0
	CBI PORTD, PD7
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, mesdece
	ADD ZL, R18
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

	CBI PORTB, PB2
	SBI PORTB, PB1	//UNIDADES HORAS
	CBI PORTB, PB0
	CBI PORTD, PD7
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, mesunid
	ADD ZL, R18
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

	CBI PORTB, PB2
	CBI PORTB, PB1
	SBI PORTB, PB0	//DECENAS MINUTOS
	CBI PORTD, PD7
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, diadece
	ADD ZL, R18
	LPM R25, Z
	OUT PORTC, R25    //se envia el valor al puerto para verlo en los displays
	CALL DELAY

	CBI PORTB, PB2
	CBI PORTB, PB1
	CBI PORTB, PB0
	SBI PORTD, PD7	//UNIDADES MINUTOS
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, diaunid
	ADD ZL, R18
	LPM R25, Z
	OUT PORTC, R25   //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	JMP LOOPRELOJ

//RELOJ CONF HORA
RELOJCONF_HORA:
	SBI PORTB, PB4
	SBI PORTB, PB3
	CBI PORTD, PD0

//UNIDADES Horas
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7
	CBI PORTB, PB0
	SBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, horunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
//Decenas Horas
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7
	CBI PORTB, PB0
	CBI PORTB, PB1
	SBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, hordece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

IN R16, PIND
	SBRC R16, PD4
	JMP INC_HOR_UNI
	SBRC R16, PD3
	JMP DEC_HOR_UNI


	INC_HOR_UNI:
	CALL DELAY
	LDS R17, horunid
	INC R17
	STS horunid, R17
	RET 

	DEC_HOR_UNI:
	CALL DELAY
	LDS R17, horunid
	DEC R17
	STS horunid, R17
	RET

	JMP LOOPRELOJ

//RELOJ CONF MINUTOS
RELOJCONF_MINU:
	CBI PORTB, PB4
	CBI PORTB, PB3
	SBI PORTD, PD0

	//UNIDADES Minutos
	CBI PORTD, PD5
	CBI PORTD, PD6
	CBI PORTD, PD7
	SBI PORTB, PB0
	CBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, MINunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
//Decenas Horas
	CBI PORTD, PD5
	CBI PORTD, PD6
	SBI PORTD, PD7
	CBI PORTB, PB0
	CBI PORTB, PB1
	CBI PORTB, PB2
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, mindece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTC, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

IN R16, PIND
	SBRC R16, PD4
	JMP INC_MIN_UNI
	SBRC R16, PD3
	JMP DEC_MIN_UNI


	INC_MIN_UNI:
	CALL DELAY
	LDS R17, horunid
	INC R17
	STS horunid, R17
	RET 

	DEC_MIN_UNI:
	CALL DELAY
	LDS R17, horunid
	DEC R17
	STS horunid, R17
	RET

	JMP LOOPRELOJ

//FECHA CONF MES
FECHACONF_MES:

	JMP LOOPRELOJ

//FECHA CONF MES
FECHACONF_DIA:

	JMP LOOPRELOJ

/*
//ALARMA CONF
 ALARMA_HORA:
	IN R16, PIND

	SBRC R16, PD4
	JMP INC_HOR_UNI_ALA
	SBRC R16, PD3
	JMP DEC_HOR_UNI_ALA
	CPI R21, 0x18
	BREQ RESET_HORA_ALARMA_UNDER
	CPI R21, 0xFF
	BREQ RESET_HORA_ALARMA_OVER

	JMP LOOPRELOJ

	RESET_HORA_ALARMA_OVER:
	LDI R21, 0x18
	RESET_HORA_ALARMA_UNDER
	LDI R21, 0x00

	INC_HOR_UNI_ALA:
	CALL DELAY
	INC R21
	RET 

	DEC_HOR_UNI_ALA:
	CALL DELAY
	DEC R21
	RET 



ALARMA_MINU:
	IN R16, PIND

	SBRC R16, PD4
	JMP INC_MIN_UNI_ALA
	SBRC R16, PD3
	JMP INC_HOR_UNI_ALA

	INC_MIN_UNI_ALA:
	CALL DELAY
	INC R19
	RET 

	DEC_MIN_UNI_ALA:
	CALL DELAY
	DEC R19
	RET 

	JMP LOOPRELOJ

	*/
;******************************************************************************
;INTERRUPCIONES
;******************************************************************************
INT_T0:
	LDI R26, 0
	OUT TCCR0A, R26      //inicializacion de timer 0 como contador 
	
	LDI R26, (1<<CS02) | (1<<CS00)     //seleccion de prescaler de 1024 
	OUT TCCR0B, R26       
	
	LDI R26, 100      //valor de conteo inicial 
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
	SBI TIFR0, TOV0		//20ms
	
	INC R23        //Contador de interrupciones

	POP R16
	OUT SREG, R16  
	POP R16        //Devolvemos el valor antes guardado
	RETI


ISR_INT0:  //configuracion MODOS
	PUSH R16       //guardamos el valor de R16
 	IN R16, SREG
	PUSH R16

	INC R24
	CALL DELAY

	POP R16
	OUT SREG, R16  
	POP R16         //Devolvemos el valor antes guardado
	RETI
/*
DELAY:              
	LDI R16, 255
DELAY1:
	DEC R16
	BRNE DELAY1
	RET*/

	DELAY:              
	LDI R24, 255
DELAY1:
	DEC R24
	BRNE DELAY1
	RET 
	/*LDI R24, 255
DELAY2:
	DEC R24
	BRNE DELAY2
	LDI R24, 255
DELAY3:
	DEC R24
	BRNE DELAY3
	LDI R24, 255
DELAY4:
	DEC R24
	BRNE DELAY4*/

TABLA7SEG: .DB 0x77, 0x44, 0x6B, 0x6E, 0x5C, 0x3E, 0x3F, 0x64, 0x7F, 0x7E
//ver los pines en el circuito para verificar