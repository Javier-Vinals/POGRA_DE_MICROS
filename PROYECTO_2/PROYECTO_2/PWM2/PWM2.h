#ifndef PWM2_H_
#define PWM2_H_

#include <avr/io.h>
#include <stdint.h>

#define invertido 1
#define no_invertido 0

void initPWM0FastA2(uint8_t inverted, uint16_t precaler);
void updateDutyCycleA2(uint8_t duty);

void initPWM0FastB2(uint8_t inverted, uint16_t precaler);
void updateDutyCycleB2(uint8_t duty);

#endif
