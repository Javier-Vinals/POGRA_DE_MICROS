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
	dia:	 .byte 1
	mes:	 .byte 1
	mesunid: .byte 1
	mesdece: .byte 1

.cseg
.org 0x00
	JMP MAIN
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

	//Salidas 7SEG y buzzer
	LDI R16, 0b1111_1111	//Configuramos el puerto C como salidas de 7SEG
	OUT DDRD, R16

	//Transistores
	LDI R16, 0b0011_1111
	OUT DDRB, R16

	LDI R16, 0b0011_1000
	OUT DDRC, R16
	
	//Botones displays
	//Establece los pines como pullup 
	SBI PORTC, PC0
	SBI PORTC, PC1
	SBI PORTC, PC2
	//Establece los puertos de entrada y salida 
	CBI DDRC, PC0
	CBI DDRC, PC1
	CBI DDRC, PC2
	
	CALL INT_T0  //inicializacion del timer0

	SEI
	//Reiniciar las variables a sus valores iniciales
	CLR R17 //Reloj
	STS SEGUNID, R17
	STS SEGDECE, R17
	STS MINUNID, R17
	STS MINDECE, R17
	STS HORUNID, R17
	STS HORDECE, R17

	CLR R18//Fecha
	STS diadece, R18
	STS mesdece, R18
	LDI R18, 1
	STS diaunid, R18
	STS dia, R18	
	STS mes, R18
	STS mesunid, R18
	CLR R18

	CLR R19 //Unidades minutos ALARMA
	CLR R20 //Decenas minutos ALARMA
	LDI R21, 0 //Unidades horas ALARMA
	CLR R22 //Decenas horas ALARMA

	CLR R23 //Contador de interrupciones TIMER

	CLR R24 //Registro de MODOS

	CLR R16 //REGISTRO TEMPORAL
	clr R28	//7 SEGMENTOS
	CLR R27

;******************************************************************************
;LOOP
;******************************************************************************
LOOP:
CPI R24, 2
BREQ INC_DEC_MINUS
CPI R24, 3
BREQ INC_DEC_HORAS
CPI R24, 4
BREQ INC_DEC_DIA_jmp
CPI R24, 5
BREQ INC_DEC_MES_jmp
CPI R24, 6
BREQ INC_DEC_MIN_A_jmp
CPI R24, 7
BREQ INC_DEC_HOR_A_jmp
JMP LOOPRELOJ

INC_DEC_DIA_jmp:
	jmp INC_DEC_DIA

INC_DEC_MES_jmp:
	JMP INC_DEC_MES

INC_DEC_MIN_A_jmp:
	JMP INC_DEC_MIN_A

INC_DEC_HOR_A_jmp:
	JMP INC_DEC_HOR_A

INC_DEC_MINUS:
	SBIS PINC, PC1
	CALL INC_MINUS
	SBIS PINC, PC2
	CALL DEC_MINUS
	JMP LOOPRELOJ
	INC_MINUS:
	SBIS PINC, PC1
	JMP INC_MINUS
	LDS R17, minUNID
	INC R17
	STS minUNID, R17
	RET
	DEC_MINUS:
	SBIS PINC, PC2
	JMP DEC_MINUS
	LDS R17, minUNID
	DEC R17
	CPI R17, 0xFF
	BREQ ARREGLO_MIN
	STS minUNID, R17
	RET
	ARREGLO_MIN:
	LDI R17, 9
	STS minUNID, R17
	LDS R17, mindece
	DEC R17
	CPI R17, 0xFF
	BREQ UNDER_MINUS
	STS mindece, R17
	JMP LOOP
	UNDER_MINUS:
	LDI R17, 5
	STS mindece, R17
	JMP LOOP

INC_DEC_HORAS:
	SBIS PINC, PC1
	CALL INC_HORAS
	SBIS PINC, PC2
	CALL DEC_HORAS
	JMP LOOPRELOJ
	INC_HORAS:
	SBIS PINC, PC1
	JMP INC_HORAS
	LDS R17, HORUNID
	INC R17
	STS HORUNID, R17
	RET
	DEC_HORAS:
	SBIS PINC, PC2
	JMP DEC_HORAS
	LDS R17, HORUNID
	DEC R17
	CPI R17, 0xFF
	BREQ ARREGLO_HOR
	STS HORUNID, R17
	RET
	ARREGLO_HOR:
	LDI R17, 9
	STS horUNID, R17
	LDS R17, hordece
	DEC R17
	CPI R17, 0xFF
	BREQ UNDER_HORAS
	STS hordece, R17
	JMP LOOP
	UNDER_HORAS:
	LDI R17, 2
	STS hordece, R17
	LDI R17, 3
	STS horunid, R17
	JMP LOOP

INC_DEC_DIA:
	SBIS PINC, PC1
	CALL INC_DIA
	SBIS PINC, PC2
	CALL DEC_DIA
	JMP LOOPRELOJ
	INC_DIA:
	SBIS PINC, PC1
	JMP INC_DIA
	LDS R17, DIAUNID
	INC R17
	STS DIAUNID, R17
	LDS R17, DIA
	INC R17
	STS DIA, R17
	RET
	DEC_DIA:
	SBIS PINC, PC2
	JMP DEC_DIA
	LDS R17, DIAunid
	DEC R17
	CPI R17, 0xFF
	BREQ ARREGLO_DIA
	STS DIAUNID, R17   
	LDS R17, dia
	dec r17 
	STS DIA, R17
	RET
	ARREGLO_DIA:
	LDI R17, 9
	STS DIAUNID, R17
	LDS R17, DIAdece
	DEC R17
	STS DIAdece, R17
	JMP LOOP

INC_DEC_MES:
	SBIS PINC, PC1
	CALL INC_MES
	SBIS PINC, PC2
	CALL DEC_MES
	JMP LOOPRELOJ
	INC_MES:
	SBIS PINC, PC1
	JMP INC_MES
	LDS R17, MESUNID
	INC R17
	STS MESUNID, R17
	LDS R17, MES
	INC R17
	STS MES, R17
	RET
	DEC_MES:
	SBIS PINC, PC2
	JMP DEC_MES
	LDS R17, MESunid
	DEC R17
	CPI R17, 0xFF
	BREQ ARREGLO_MES
	STS MESUNID, R17   
	LDS R17, MES
	dec r17 
	STS MES, R17
	RET
	ARREGLO_MES:
	LDI R17, 9
	STS MESUNID, R17
	//STS DIA, R17
	LDS R17, MESdece
	DEC R17
	STS MESdece, R17
	JMP LOOP

INC_DEC_MIN_A:
	SBIS PINC, PC1
	CALL INC_MIN_A
	SBIS PINC, PC2
	CALL DEC_MIN_A
	JMP LOOPRELOJ
	INC_MIN_A:
	SBIS PINC, PC1
	JMP INC_MIN_A
	INC R19
	RET
	DEC_MIN_A:
	SBIS PINC, PC2
	JMP DEC_MIN_A
	DEC R19
	CPI R19, 0xFF
	BREQ ARREGLO_MIN_A
	RET
	ARREGLO_MIN_A:
	LDI R19, 9
	DEC R20
	CPI R20, 0xFF
	BREQ UNDER_MIN_A
	JMP LOOP
	UNDER_MIN_A:
	LDI R20, 5
	JMP LOOP

INC_DEC_HOR_A:
	SBIS PINC, PC1
	CALL INC_HOR_A
	SBIS PINC, PC2
	CALL DEC_HOR_A
	JMP LOOPRELOJ
	INC_HOR_A:
	SBIS PINC, PC1
	JMP INC_HOR_A
	INC R21
	RET
	DEC_HOR_A:
	SBIS PINC, PC2
	JMP DEC_HOR_A
	DEC R21
	CPI R21, 0xFF
	BREQ ARREGLO_HOR_A
	RET
	ARREGLO_HOR_A:
	LDI R21, 9
	DEC R22
	CPI R22, 0xFF
	BREQ UNDER_HOR_A
	JMP LOOP
	UNDER_HOR_A:
	LDI R22, 2
	LDI R21, 3
	JMP LOOP


;******************************************************************************
;LOOP RELOJ
;******************************************************************************
LOOPRELOJ:
//ALARMA
	CPI R19, 10
	BREQ INCDMIN_A

	CPI R20, 6
	BREQ RSTMIN_A

	CPI R21, 10
	BREQ INCDHOR_A
	
	CPI R22, 2
	BREQ RSTHOR_A

	RELOJNORMAL:

//RELOJ NORMAL
	LDS R17, mindece
	CPI R17, 6
	BREQ INCUHOR

	LDS R17, horunid
	CPI R17, 10
	BREQ INCDHOR//_jmp

	LDS R17, hordece
	CPI R17, 2
	BREQ RESETHORA//_JMP
	//JMP LOOPFECHA
	JMP C_ALARMA

INCDMIN_A:
	CLR R19
	INC R20
	JMP LOOPRELOJ

RSTMIN_A:
	CLR R20
	JMP LOOPRELOJ

INCDHOR_A:
	CLR R21
	INC R22
	JMP LOOPRELOJ

RSTHOR_A:
	SBRS R21, 2
	JMP RELOJNORMAL
	CLR R21
	CLR R22
	JMP RELOJNORMAL

INCUHOR://Aumenta unidades de HORAS
	LDS R17, mindece
	CLR R17
	STS mindece, R17
	LDS R17, horunid
	INC R17
	STS horunid, R17
	JMP LOOPRELOJ

INCDHOR:
	LDS R17, horunid
	CLR R17
	STS horunid, R17
	LDS R17, hordece
	INC R17
	STS hordece, R17
	JMP LOOPRELOJ

	RESETHORA:
	LDS R17, horunid
	SBRS R17, 2
	JMP SELECTOR
	CLR R17
	STS horunid, r17
	sts hordece, R17
	LDS R18, dia
	INC R18
	STS dia, R18
	LDS R18, diaunid
	INC R18
	STS diaunid, R18
	JMP LOOPRELOJ

;******************************************************************************
;COMPARACION ALARMA
;******************************************************************************
C_ALARMA:
	LDS R17, hordece
	CP R17, R22
	BREQ C_U_HOR_ALARMA
	CBI PORTD, PD7
	JMP LOOPFECHA

	C_U_HOR_ALARMA:
	LDS R17, horunid
	CP R17, R21
	BREQ C_D_MIN_ALARMA
	CBI PORTD, PD7
	JMP LOOPFECHA

	C_D_MIN_ALARMA:
	LDS R17, mindece
	CP R17, R20   
	BREQ C_U_MIN_ALARMA
	CBI PORTD, PD7
	JMP LOOPFECHA

	 C_U_MIN_ALARMA:
	 LDS R17, minunid
	 CP R17, R19
	 BREQ C_VERIFY
	 CBI PORTD, PD7
	 JMP LOOPFECHA

	 C_VERIFY:
	 LDS R17, segdece
	 CPI R17, 0
	 BREQ ALARMA_ON
	 CBI PORTD, PD7
	 JMP LOOPFECHA

	 ALARMA_ON:
	 SBI PORTD, PD7
	 JMP LOOPFECHA

;******************************************************************************
;LOOP FECHA
;******************************************************************************
LOOPFECHA:
	LDS R18, diaunid
	CPI R18, 10
	BREQ INCDDIA

	LDS R18, dia
	CPI R18, 30 
	BREQ MES_29//FEBRERO
	CPI R18, 31//30 DIAS
	BREQ MES_30
	CPI R18, 32//31 DIAS
	BREQ MES_30
	
	JMP SELECTOR

INCDDIA:
	CLR R18
	STS diaunid, R18
	LDS R18, diadece
	INC R18
	STS diadece, R18
	JMP LOOPFECHA

MES_29:
	LDS R18, mes
	CPI R18, 2
	BREQ BYE_MES
	JMP selectmes1
	//JMP FECHA

SELECTMES1:
	LDS R18, dia
	CPI R18, 31//30 DIAS
	BREQ MES_30
	JMP SELECTMES2

MES_30:
	LDS R18, mes
	CPI R18, 4 //abril
	BREQ BYE_MES
	CPI R18, 6 //JUNIO
	BREQ BYE_MES
	CPI R18, 9//SEPTIEMBRE
	BREQ BYE_MES
	CPI R18, 11//NOVIEMBRE
	BREQ BYE_MES
	CPI R18, 2//febrero
	BREQ BYE_MES
	jmp SELECTMES2
	//JMP FECHA

SELECTMES2:
	LDS R18, dia
	CPI R18, 32//31 DIAS
	BREQ MES_31
	JMP SELECTOR
	//JMP FECHA

MES_31:
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
	LDS R18, mes
	CPI R18, 4 //abril
	BREQ BYE_MES
	CPI R18, 6 //JUNIO
	BREQ BYE_MES
	CPI R18, 9//SEPTIEMBRE
	BREQ BYE_MES
	CPI R18, 11//NOVIEMBRE
	BREQ BYE_MES
	CPI R18, 2//febrero
	BREQ BYE_MES

BYE_MES:
	CLR R18
	STS mesdece, R18
	LDS R18, mes
	INC R18
	STS mes, R18
	LDS R18, mesunid
	INC R18
	STS mesunid, R18
	CLR R18
	STS diadece, R18
	LDI R18, 1
	STS diaunid, R18
	STS dia, R18


	LDS R18, mes
	CPI R18, 13
	BREQ RST_ANYO
	JMP SELECTOR	

	RST_ANYO:
	LDS R18, mes
	LDI R18, 0b0000_0001
	STS mes, R18
	STS mesunid, R18
	CLR R18
	STS mesdece, R18
	JMP SELECTOR	
;******************************************************************************
;SELECTOR MODOS
;******************************************************************************
SELECTOR:

	SBIS PINC, PC0
	JMP CONTEOMODO
	JMP SELECTMOD

CONTEOMODO:
	SBI PORTB, PB4
	SBI PORTB, PB3
	SBI PORTB, PB2
	SBI PORTB, PB1
	SBI PORTB, PB0
	SBI PORTB, PB5

	CBI PORTD, PD0
	SBI PORTD, PD1
	CBI PORTD, PD2
	CBI PORTD, PD3
	CBI PORTD, PD4
	CBI PORTD, PD5
	CBI PORTD, PD6

	CALL DELAY
	SBIS PINC, PC0
	JMP CONTEOMODO
	CALL DELAY
	INC R24
	JMP SELECTMOD

SELECTMOD:
	CPI R24, 8
	BREQ RESETSELEC
	CPI R24, 0
	BREQ MODRELOJ
	CPI R24, 1	
	BREQ MODFECHA
	CPI R24, 2
	BREQ MODRELOJCONF_MINU
	CPI R24, 3
	BREQ MODRELOJCONF_HORA
	CPI R24, 4
	BREQ MODFECHACONG_DIA
	CPI R24, 5
	BREQ MODFECHACONG_MES
	CPI R24, 6
	BREQ MODALARMA_MINU
	CPI R24, 7
	BREQ MODALARMA_HORA

RESETSELEC:
	CLR R24
	JMP SELECTMOD

	MODRELOJ:
		JMP RELOJ
	MODFECHA:
		JMP FECHA
	MODRELOJCONF_MINU:
		JMP RELOJCONF_MINU
	MODRELOJCONF_HORA:
		JMP RELOJCONF_HORA
	MODFECHACONG_MES:
		JMP FECHACONF_MES
	MODFECHACONG_DIA:
		JMP FECHACONF_DIA
	MODALARMA_HORA:
		JMP ALARMA_HORA
	MODALARMA_MINU:
		JMP ALARMA_MINU
;******************************************************************************
;MODOS
;******************************************************************************
//RELOJ
RELOJ:

	CPI R27, 0
	BREQ LED_ON_R
	CPI R27, 1
	BREQ LED_OFF_R

	LED_ON_R:
	SBI PORTC, PC5
	//LDI R27, 1
	JMP RELOJ_ON_R

	LED_OFF_R:
	CBI PORTC, PC5
	//LDI R27, 0
	JMP RELOJ_ON_R


	 RELOJ_ON_R:

//Unidades Segundos
	LDI R28, 0b0001_0000
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, segunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays }
	CALL DELAY

//Decenas Segundos
	LDI R28, 0b0000_1000
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, segdece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

//Unidades Minutos
	LDI R28, 0b0000_0100
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, minunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25   //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

//Decenas Minutos
	LDI R28, 0b0000_0010
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, mindece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25    //se envia el valor al puerto para verlo en los displays
	CALL DELAY

//Unidades Horas
	LDI R28, 0b0000_0001
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, horunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

//Decenas Horas
	LDI R28, 0b0010_0000
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, hordece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	JMP LOOP

//FECHA
FECHA:
	CBI PORTC, PC5

	LDS R18, mes
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
	STS mesunid, R18
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
//MES DECENAS
	LDI R28, 0b0010_0000
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, mesdece
	ADD ZL, R18
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//MES UNIDADES
	LDI R28, 0b0000_0001
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, mesunid
	ADD ZL, R18
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//DIA DECENAS
	LDI R28, 0b0000_0010
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, diadece
	ADD ZL, R18
	LPM R25, Z
	OUT PORTD, R25    //se envia el valor al puerto para verlo en los displays
	CALL DELAY
	//DIA UNIDADES
	LDI R28, 0b0000_0100
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, diaunid
	ADD ZL, R18
	LPM R25, Z
	OUT PORTD, R25   //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	JMP LOOP
	//JMP LOOPFECHA

//RELOJ CONF MINUTOS
RELOJCONF_MINU:
	CBI PORTC, PC5
	//Unidades Minutos
	LDI R28, 0b0000_0100
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, minunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//Decenas Minutos
	LDI R28, 0b0000_0010
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, mindece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//RAYITAS
	LDI R28, 0b0010_0001
	OUT PORTB, R28
	LDI R28, 2
	OUT PORTD, R28
	CALL DELAY
	//Letra H -- Hora
	LDI R28, 0b0001_0000
	OUT PORTB, R28
	LDI R28, 0b0101_1011
	OUT PORTD, R28
	CALL DELAY
	JMP LOOP


//RELOJ CONF HORAS
RELOJCONF_HORA:
	CBI PORTC, PC5
	//Unidades Horas
	LDI R28, 0b0000_0001
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, horunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//Decenas Horas
	LDI R28, 0b0010_0000
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, hordece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//RAYITAS
	LDI R28, 0b0000_0110
	OUT PORTB, R28
	LDI R28, 2
	OUT PORTD, R28
	CALL DELAY
	//Letra H -- Hora
	LDI R28, 0b0001_0000
	OUT PORTB, R28
	LDI R28, 0b0101_1011
	OUT PORTD, R28
	CALL DELAY
	JMP LOOP

//FECHA CONF MES
FECHACONF_DIA:
	CBI PORTC, PC5
	//Unidades Minutos
	LDI R28, 0b0000_0100
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, diaunid
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//Decenas Minutos
	LDI R28, 0b0000_0010
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R17, diadece
	ADD ZL, R17
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//RAYITAS
	LDI R28, 0b0010_0001
	OUT PORTB, R28
	LDI R28, 2
	OUT PORTD, R28
	CALL DELAY
	//Letra F -- Fecha
	LDI R28, 0b0001_0000
	OUT PORTB, R28
	LDI R28, 0b0001_0111
	OUT PORTD, R28
	CALL DELAY
	JMP LOOP

//FECHA CONF MES
FECHACONF_MES:
	CBI PORTC, PC5
//Unidades Minutos
	LDI R28, 0b0010_0000
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, mesdece
	ADD ZL, R18
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//MES UNIDADES
	LDI R28, 0b0000_0001
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	LDS R18, mesunid
	ADD ZL, R18
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

	//RAYITAS
	LDI R28, 0b0000_0110
	OUT PORTB, R28
	LDI R28, 2
	OUT PORTD, R28
	CALL DELAY
	//Letra F -- Fecha
	LDI R28, 0b0001_0000
	OUT PORTB, R28
	LDI R28, 0b0001_0111
	OUT PORTD, R28
	CALL DELAY
	JMP LOOP


//ALARMA CONF
 ALARMA_MINU:
	CBI PORTC, PC5
 //Unidades Minutos
	LDI R28, 0b0000_0100
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R19
	LPM R25, Z
	OUT PORTD, R25   //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

//Decenas Minutos
	LDI R28, 0b0000_0010
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R20
	LPM R25, Z
	OUT PORTD, R25    //se envia el valor al puerto para verlo en los displays
	CALL DELAY
	//RAYITAS
	LDI R28, 0b0010_0001
	OUT PORTB, R28
	LDI R28, 2
	OUT PORTD, R28
	CALL DELAY
	//Letra A -- Alarma
	LDI R28, 0b0001_0000
	OUT PORTB, R28
	LDI R28, 0b0101_1111
	OUT PORTD, R28
	CALL DELAY
	JMP LOOP

ALARMA_HORA:
	CBI PORTC, PC5
	//Unidades Horas
	LDI R28, 0b0000_0001
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R21
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY

	//Decenas Horas
	LDI R28, 0b0010_0000
	OUT PORTB, R28
	LDI ZH, HIGH(TABLA7SEG << 1)  //se va a buscar detro de la tabla el valor que se desplegara en las decenas 
	LDI ZL, LOW(TABLA7SEG << 1)
	ADD ZL, R22
	LPM R25, Z
	OUT PORTD, R25     //se envia el valor al puerto para verlo en los displays 
	CALL DELAY
	//RAYITAS
	LDI R28, 0b0000_0110
	OUT PORTB, R28
	LDI R28, 2
	OUT PORTD, R28
	CALL DELAY
	//Letra A -- Alarma
	LDI R28, 0b0001_0000
	OUT PORTB, R28
	LDI R28, 0b0101_1111
	OUT PORTD, R28
	CALL DELAY
	JMP LOOP

;******************************************************************************
;INTERRUPCIONES
;******************************************************************************
INT_T0:
	LDI R16, 0
	OUT TCCR0A, R16      //inicializacion de timer 0 como contador 
	
	LDI R16, (1<<CS02) | (1<<CS00)     //seleccion de prescaler de 1024 
	OUT TCCR0B, R16       
	
	LDI R16, 100        //valor de conteo inicial 
	OUT TCNT0, R16
	LDI R16, (1<<TOIE0)   
	STS TIMSK0, R16
	RET

INT_TIMER0:
	PUSH R16        //guardamos el valor de R16
 	IN R16, SREG
	PUSH R16
	
	LDI R16, 100
	OUT TCNT0, R16      
	SBI TIFR0, TOV0		//20ms
	
	INC R23        //Contador de interrupciones

	CPI R23, 25
	BREQ LED_CON
	CPI R23, 50
	BREQ LED_CON
	JMP RELOJ_ON

	LED_CON:
	CPI R27, 0
	BREQ LED_ON
	CPI R27, 1
	BREQ LED_OFF
	JMP RELOJ_ON

	LED_ON:
	//SBI PORTC, PC5
	LDI R27, 1
	JMP RELOJ_ON

	LED_OFF:
	//CBI PORTC, PC5
	LDI R27, 0
	JMP RELOJ_ON

	RELOJ_ON:

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

	JMP SALTAR

	INCUSEG:	//Aumenta cada segundo
	CLR R23
	LDS R17, segunid
	INC R17	
	STS segunid, R17 
	CBI PORTC, PC5
	JMP SALTAR

INCDSEG:	//Aumenta decenas de SEGUNDOS
	CLR R17
	STS segunid, R17
	LDS R17, segdece
	INC R17
	STS segdece, R17
	CBI PORTC, PC5
	JMP SALTAR

INCUMIN://Aumenta unidades de MINUTOS
	CLR R17
	STS segdece, R17
	LDS R17, minunid
	INC R17
	STS minunid, R17
	CBI PORTC, PC5
	JMP SALTAR

INCDMIN://Aumenta decenas de MINUTOS
	LDS R17, minunid
	CLR R17
	STS minunid, R17
	LDS R17, mindece
	INC R17
	STS mindece, R17
	CBI PORTC, PC5
	JMP SALTAR

SALTAR:

	POP R16
	OUT SREG, R16  
	POP R16        //Devolvemos el valor antes guardado
	RETI

DELAY:
	LDI R18, 255
DELAY1:
	DEC R18
	BRNE DELAY1
	LDI R18, 255
DELAY2:
	DEC R18
	BRNE DELAY2
	LDI R18, 255
DELAY3:
	DEC R18
	BRNE DELAY3
	RET

	TABLA7SEG: .DB 0x7D, 0x48, 0x3E, 0x6E, 0x4B, 0x67, 0x77, 0x4C, 0x7F, 0x6F
//ver los pines en el circuito para verificar