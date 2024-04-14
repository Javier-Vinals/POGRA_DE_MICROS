#define F_CPU 16000000

#include <avr/interrupt.h>
#include <util/delay.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdio.h>

void Botones(void);
void initADC(void);
void display1(void);
void display2(void);
void LEDS(void);
void Alarma(void);

volatile uint8_t Contador = 0;
uint8_t valor_adc = 0x00;
uint8_t dig1 ;
uint8_t dig2 ;


int main(void)
{
	cli();
	UCSR0B = 0;
	// DECLARAR PUERTOS 7SEG
	DDRB |= (1 << PB4) | (1 << PB5);
	DDRC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	PORTB &= ~(1 << PB4);
	PORTB &= ~(1 << PB5);
	PORTC &= ~(1 << PC0);
	PORTC &= ~(1 << PC1);
	PORTC &= ~(1 << PC2);
	PORTC &= ~(1 << PC3);
	PORTC &= ~(1 << PC4);
	
	// DECLARAR LOS PUERTOS DE LOS TRANSISTORES
	DDRB |= (1 << PB2) | (1 << PB3);
	PORTB &= ~(1 << PB2);
	PORTB &= ~(1 << PB3);
	
	//DECLARAR PUESRTOS LEDS
	DDRD = 0xFF;
	PORTD = 0;
	
	//DECLARAR PUERTOS 
	DDRB &= ~(1 << PB0);
	DDRB &= ~(1 << PB1);
	PORTB  |= (1 << PB0) | (1 << PB1);
	
	//DECLARAR PUERTO ALARMA
	DDRC |= (1 << PC5);
	PORTC &= ~(1 << PC5);
	
	Botones();
	initADC();
	
	sei();
	while (1)
	{
		PORTD =	Contador;
		ADCSRA |= (1<<ADSC);  // INICIAMOS LA SECUENCIA
		LEDS();
		Alarma();
	}
}

void LEDS(){
	//_delay_ms(3);
	PORTB &= ~(1 << PB4);
	PORTB &= ~(1 << PB5);
	PORTC &= ~(1 << PC0);
	PORTC &= ~(1 << PC1);
	PORTC &= ~(1 << PC2);
	PORTC &= ~(1 << PC3);
	PORTC &= ~(1 << PC4);
	display1();
	PORTB |= (1 << PB2);
	_delay_ms(3);
	PORTB &= ~(1 << PB2);
	
	//_delay_ms(3);
	PORTB &= ~(1 << PB4);
	PORTB &= ~(1 << PB5);
	PORTC &= ~(1 << PC0);
	PORTC &= ~(1 << PC1);
	PORTC &= ~(1 << PC2);
	PORTC &= ~(1 << PC3);
	PORTC &= ~(1 << PC4);
	display2();
	PORTB |= (1 << PB3);
	_delay_ms(3);
	PORTB &= ~(1 << PB3);
}


void Botones(void){
	PCICR |= (1 << PCIE0);
	PCMSK0 |= (1 << PCINT0) | (1 << PCINT1);
}

void initADC(){
	ADMUX = 0; // INICIO EN 0
	// REFERENCIA AVCC = 5V
	ADMUX |= (1 << REFS0);
	ADMUX &= ~(1 << REFS1);
	// SELECCIONO EL ADC[5] = 0110
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

void display1(){
	
	if (dig1 == 0x00){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x01){
		PORTB |= (1 << PB4);
		PORTC |= (1 << PC4);

	}
	else if (dig1 == 0x02){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC1) | (1 << PC2) | (1 << PC3);
	}
	else if (dig1 == 0x03){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |=  (1 << PC1) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x04){
		//disp1 = 0x66;
		PORTB |= (1 << PB4);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC4);
	}
	else if (dig1 == 0x05){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x06){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x07){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC4);

	}
	else if (dig1 == 0x08){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x09){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x0A){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC4);
	}
	else if (dig1 == 0x0B){
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x0C){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC2) | (1 << PC3);
	}
	else if (dig1 == 0x0D){
		PORTB |= (1 << PB4);
		PORTC |= (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig1 == 0x0E){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3);
	}
	else if (dig1 == 0x0F){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2);
	}
}
void display2(){
	
	if (dig2 == 0x00){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x01){
		PORTB |= (1 << PB4);
		PORTC |= (1 << PC4);

	}
	else if (dig2 == 0x02){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC1) | (1 << PC2) | (1 << PC3);
	}
	else if (dig2 == 0x03){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |=  (1 << PC1) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x04){
		//disp1 = 0x66;
		PORTB |= (1 << PB4);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC4);
	}
	else if (dig2 == 0x05){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x06){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x07){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC4);
	}
	else if (dig2 == 0x08){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x09){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x0A){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC4);
	}
	else if (dig2 == 0x0B){
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x0C){
		PORTB |= (1 << PB4) | (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC2) | (1 << PC3);
	}
	else if (dig2 == 0x0D){
		PORTB |= (1 << PB4);
		PORTC |= (1 << PC1) | (1 << PC2) | (1 << PC3) | (1 << PC4);
	}
	else if (dig2 == 0x0E){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3);
	}
	else if (dig2 == 0x0F){
		PORTB |= (1 << PB5);
		PORTC |= (1 << PC0) | (1 << PC1) | (1 << PC2);
	}
}

void Alarma(){
	if(Contador == valor_adc){
	PORTC |= (1 << PC5);	
	}
	else{
	PORTC &= ~(1 << PC5);	
	}
}


ISR(PCINT0_vect){
	uint8_t BotIn = PINB & (1<<PINB0);
	uint8_t BotDe = PINB & (1<<PINB1);
	
	if(BotIn == 0){
		Contador++;
	}
	else if(BotDe == 0){
		Contador--;
	}
	
	PCIFR |= (1<<PCIF0);
}


ISR(ADC_vect){

	valor_adc = ADCH;
	dig1 = valor_adc >> 4;
	dig2 = valor_adc & 0x0F;
	
	// APAGAR LA BANDERA DE INTERRUPCION DEL ADC
	ADCSRA |= (1 << ADIF);
}




