#include <avr/io.h>
#include <stdint.h>
#include "PWM2.h"

float map2(float duty, float Imin, float Imax, float Omin, float Omax){
	return ((duty - Imin)*(Omax - Omin)/(Imax - Imin)) + Omin;
}

void initPWM0FastA2(uint8_t inverted, uint16_t prescaler){
	DDRB |= (1<<DDB3);						//PIN B3 COMO SALIDA
	if(inverted){
		TCCR2A |= (1<<COM2A1)|(1<<COM2A0);	//OC0A INVERTIDO
		}else{
		TCCR2A |= (1<<COM2A1);				//OC0A NO INVERTIDO
	}
	
	TCCR2A |= ((1<<WGM20)|(1<<WGM21));		//MODO PWM FAST, 8 bits
	if(prescaler==1024){
		TCCR2B |= (1<<CS22)|(1<<CS20);//PRESCALER DE 1024
	}
}

void initPWM0FastB2(uint8_t inverted, uint16_t prescaler){
	DDRD |= (1<<DDD3);						//PIN D3 COMO SALIDA
	if(inverted){
		TCCR2A |= (1<<COM2B1)|(1<<COM2B0);	//OC0B INVERTIDO
		}else{
		TCCR2A |= (1<<COM2B1);				//OC0B NO INVERTIDO
		
	}
	
	TCCR2A |= ((1<<WGM20)|(1<<WGM21));		//MODO PWM FAST, 8 bits
	if(prescaler==1024){
		TCCR2B |= (1<<CS22)|(1<<CS20);			//PRESCALER DE 1024
	}
}


void updateDutyCycleA2(uint8_t duty){
	duty = map2(duty, 0, 255, 6, 40);
	OCR2A = duty;
	
}

void updateDutyCycleB2(uint8_t duty){
	duty = map2(duty, 0, 255, 6, 40);
	OCR2B = duty;	
}