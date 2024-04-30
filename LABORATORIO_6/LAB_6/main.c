#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>


volatile char bufferRX;

void initUART9600(void);
void WriteUART(char* caracter);

int main(void)
{

	cli();
	initUART9600();
	sei();
	
	WriteUART("Hola Mundo Progra de Micros\n");
	WriteUART("Este Laboratorio me hace feliz\n");

	
	while (1){
	}
}


void initUART9600(void){
	//Paso 1: confugrar tx y rx
	DDRD &= ~(1<<DDD0);
	DDRD |= (1<<DDD1);
	
	//PASO 2:  CONFIGURAR REGISTRO A MODO FAST
	UCSR0A = 0;
	UCSR0A |= (1<<U2X0);
	
	//PASO 3: CONFIGURAR REGISTRO B HABILITAR ISR RX Y TX
	UCSR0B =0;
	UCSR0B |=(1<<RXCIE0)|(1<<RXEN0)|(1<<TXEN0);
	
	//PASO 4: CONGIFURAR REGISTRO C, FRAME: 8 BITS, NO PARIDAD, 1 BIT STOP
	UCSR0C = 0;
	UCSR0C |= (1<<UCSZ01)|(1<<UCSZ00);
	//PASO 5
	UBRR0 = 207;
}

void WriteUART(char* caracter){
	uint8_t i;
	for (i = 0; caracter[i] != '\0'; i++){
		while(!(UCSR0A & (1 << UDRE0)));
			UDR0 = caracter[i];
	}
}


ISR(USART_RX_vect){
	bufferRX = UDR0;
	
	while(!(UCSR0A & (1<<UDRE0)));
	UDR0 = bufferRX;
}