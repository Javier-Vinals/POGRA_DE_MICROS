/******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de microcontrladores
;Autor: Javier Viñals
;LAB_4.asm
;
; Created: 9/04/2024
******************************************************************************/
#define F_CPU 16000000

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

uint8_t contador = 0; // Variable para almacenar el valor del contador

uint8_t valor_adc = 0x00;
uint8_t dig1 ;
uint8_t dig2 ;
/*uint8_t disp1 = 0x00;
uint8_t disp2 = 0x00;*/




void initADC(void);
void display1(void);
void display2(void);

void setup(){
	cli();
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
	
	UCSR0B = 0;
	
	// DECLARAR LOS PUERTOS DE LOS TRANSISTORES 
	DDRB |= (1 << PB2) | (1 << PB3);
	PORTB &= ~(1 << PB2);
	PORTB &= ~(1 << PB3);
	
	initADC();
	sei();
	
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



int main(void)
{
	// HACER EL SETUP DE LOS PUERTOS Y ENCENDER LAS INTERRUPCIONES 
	setup();
	// DECLARAR VARIABLES QUE SERVIRAN PARA SEPARAR EL VALOR DEL ADC EN 2 DISPLAYS
	dig1 = valor_adc >> 4;
	dig2 = valor_adc & 0x0F;
	
	
    while (1) 
    {
		ADCSRA |= (1<<ADSC);  // INICIAMOS LA SECUENCIA
		LEDS();
		}
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
	

ISR(ADC_vect){

	valor_adc = ADCH;
	dig1 = valor_adc >> 4;
	dig2 = valor_adc & 0x0F;
	
	// APAGAR LA BANDERA DE INTERRUPCION DEL ADC 
	ADCSRA |= (1 << ADIF);	
	
}