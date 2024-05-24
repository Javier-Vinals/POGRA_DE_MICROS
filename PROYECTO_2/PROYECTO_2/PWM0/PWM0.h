#ifndef PWM0_H_
#define PWM0_H_

#include <avr/io.h>
#include <stdint.h>

#define invertido 1
#define no_invertido 0

void initPWM0FastA0(uint8_t inverted, uint16_t precaler);
void updateDutyCycleA0(uint8_t duty);

void initPWM0FastB0(uint8_t inverted, uint16_t precaler);
void updateDutyCycleB0(uint8_t duty);

#endif
