#include "PWM1.h"
#include <avr/io.h>
#include <stdint.h>

void initPWM1FastA(uint8_t inverted, uint16_t precaler){
	DDRB |= (1<<DDB1);
	
	TCCR1A = 0;
	if (inverted) {
		TCCR1A |= (1<<COM1A1)|(1<<COM1A0);
		} else {
		TCCR1A |= (1<<COM1A1);
	}
	
	TCCR1A |= (1<<WGM10);
	TCCR1B |= (1<<WGM12);
	
	if (precaler == 1024) {
		TCCR1B |= (1<<CS12)|(1<<CS10);
	}
}

void initPWM1FastB(uint8_t inverted, uint16_t precaler){
	DDRB |= (1 << DDB2);
	
	//TCCR1A = 0;
	if (inverted) {
		TCCR1A |= (1<<COM1B1)|(1<<COM1B0);
		} else {
		TCCR1A |= (1<<COM1B1);
	}
	
	TCCR1A |= (1<<WGM10);
	TCCR1B |= (1<<WGM12);
	
	TCCR1B |= (1<<CS12)|(1<<CS10);
}


void updateDCA1(uint8_t duty){
	OCR1A = duty;
}

void updateDCB1(uint8_t duty){
	OCR1B = duty;
}

