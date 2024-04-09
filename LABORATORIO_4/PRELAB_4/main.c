/******************************************************************************
;Universidad del Valle de Guatemala
;IE2023: Programacion de microcontrladores
;Autor: Javier Viñals
;PRELAB_4.asm
;
; Created: 9/04/2024
******************************************************************************/

#include <avr/io.h>
#include <stdint.h>
//#include <util/delay.h>

#define aumento() (PINB & (1<<0))
#define decremento() (PINB & (1<<1))

uint8_t contador=6;

void setup(void);
void delay(uint8_t ciclos);
void seleccion(void);

int main(void)
{
	UCSR0B = 0;
	//PORTD |= (1 << PORTD4);
    setup();
	//LOOP
    while (1) 
    {
		PORTD = contador;
		seleccion();
		PORTD = contador;
    }
}
	
void setup(void) {
	DDRB &= ~(1 << DDB0);
	DDRB &= ~(1 << DDB1);
	DDRD |= 255;
	
	PORTB |= (1 << PORTB0);
	PORTB |= (1 << PORTB1);
	PORTD = 0x00;	
}

void delay(uint8_t ciclos) {
	for(uint8_t i=0; i < ciclos; i++){
		for(uint8_t j = 0; j < 255; j++){
		}
	}
}

void seleccion(void){
	if (aumento()!=0){
		while (aumento()!=0);
		contador++;	
		delay(255);
	}
	else if(decremento()!=0){
		while (decremento()!=0);
		contador--;
		delay(255);
	}
}
