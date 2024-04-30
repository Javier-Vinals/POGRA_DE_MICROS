/*
 * PRELAB_6.c
 *
 * Created: 22/04/2024 07:40:48
 * Author : Javier
 */ 
#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

uint8_t valor_adc = 0x00;
uint8_t valor_256 = 0xAA; //variable de prueba
volatile uint8_t LEDH = 0x00;
volatile uint8_t LEDL = 0x00;

volatile char bufferRX;

void setup(void);
void initUART9600(void);
void WriteMessage(char* caracter);
void WriteUART(char caracter);
void initADC(void);

int main(void)
{
    /* Replace with your application code */
	cli();
	setup();
	initADC();
	initUART9600();
	sei();
	
	WriteUART('H');
	WriteUART('O');
	WriteUART('L');
	WriteUART('A');
	WriteUART(valor_256); //prueba
	WriteUART('\n');
	
    while (1){
		WriteMessage("1. Leer Potenciometro \n2. Enviar ASCII\nEleccion: " );
		bufferRX = '0';
		while (bufferRX == '0');
		if (bufferRX == '1'){
			//Leer potenciometro
			WriteMessage("\nLeer potenciometro\n\n");
			WriteUART(valor_adc);
		}
		else if (bufferRX == '2'){
			//enviar ascii
			WriteMessage("Enviar ASCII\nEscibir digito (no usar '0')\n");
			bufferRX = '0';
			while (bufferRX == '0');
				PORTB = LEDH;
				PORTC = LEDL;
			
		}
		else{
			WriteMessage("Valor invalido\n\n");
		}
		
		UDR0 = 0;

	//	WriteUART(valor_adc);
    }
}

void setup(void){
		//4 PRIMEROS PINES B
		DDRB |= (1<<DDB0)|(1<<DDB1)|(1<<DDB2)|(1<<DDB3);
		//4 PRIMEROS PINES C
		DDRC |= (1<<DDC0)|(1<<DDC1)|(1<<DDC2)|(1<<DDC3);
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

void WriteMessage(char* caracter){
	uint8_t i;
	for (i = 0; caracter[i] != '\0'; i++){
		while(!(UCSR0A & (1 << UDRE0)));
		UDR0 = caracter[i];
	}
}

void WriteUART(char caracter){
	while(!(UCSR0A & (1<<UDRE0)));
	UDR0 = caracter;
}

void initADC(){
	ADMUX = '0'; 
	// REFERENCIA AVCC = 5V
	ADMUX |= (1 << REFS0);
	ADMUX &= ~(1 << REFS1);
	// SELECCIONO EL ADC[7] 
	ADMUX |= (1 << MUX2) | (1 << MUX1) | (1 << MUX0);
	// JUSTIFICACION A LA IZQUIERDA
	ADMUX |= (1 << ADLAR);
	
	ADCSRA = 0;
	// HABILITAR LA INTERRUPCION DEL ADC
	ADCSRA |= (1 << ADIE);
	// HABILITAMOS EL PRESCALER 128  FADC = 125 KHz
	ADCSRA |= (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
	// HABILITAMOS EL ADC
	ADCSRA |= (1 << ADEN);	
}

ISR(ADC_vect){
	valor_adc = ADCH;

	// APAGAR LA BANDERA DE INTERRUPCION DEL ADC
	ADCSRA |= (1<<ADIF);
}

ISR(USART_RX_vect){
	bufferRX = UDR0;
	
	LEDH = UDR0 >> 4;
	LEDL = UDR0 & 0x0F;
	
	while(!(UCSR0A & (1<<UDRE0)));
	UDR0 = bufferRX;
}