/*
 * PWM1.h
 *
 * Created: 7/05/2024 09:21:10
 *  Author: Javier
 */ 
#ifndef PWM2_H_
#define PWM2_H_


#include <avr/io.h>
#include <stdint.h>

#define invertido 1
#define no_invertido 0

void initPWM1FastA(uint8_t inverted, uint16_t precaler);
void updateDCA1(uint8_t duty);

void initPWM1FastB(uint8_t inverted, uint16_t precaler);
void updateDCB1(uint8_t duty);

#endif
