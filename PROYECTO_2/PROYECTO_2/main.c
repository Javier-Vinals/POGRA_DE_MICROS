#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include "PWM0/PWM0.h"
#include "PWM2/PWM2.h"
#include <stdlib.h>
#include <avr/eeprom.h>

volatile char bufferRX = '0';

int seleccion = 1;
int dato_uart;

char servo1;
char servo2;
char servo3;
char servo4;

void initADC(void);
void initUART9600(void);
void WriteMessage(char* caracter);
void WriteUART(char caracter);

uint16_t valorADC (uint8_t canal) {
	ADMUX &= 0xF0;
	ADMUX |= canal;
	ADCSRA |= (1 << ADSC);
	while (ADCSRA & (1 << ADSC));
	return ADCH;
}

int main(void)
{
	cli();
	//Salidas LEDS
	DDRD |=(1<<4)|(1<<7); //PD4, PD7
	DDRB |=(1<<0); //PB0
	//Entradas	
	DDRD &= ~(1<<2); //PD2, INT0
	PORTD |= (1<<2);
	DDRB &= ~(1<<5);//PB5
	PORTB |= (1<<5);
	DDRC &= ~(1<<0);//PC0
	PORTC |= (1<<0);
	DDRC &= ~(1<<1);//PC1
	PORTC |= (1<<1);
	DDRC &= ~(1<<2);//PC2
	PORTC |= (1<<2);
		
	EICRA = 0b00000010; //Interrupcion por flanco de bajada
	EIMSK = 0b00000001; //Habilitar interrupcion externa INT0
	EIFR = 0; //0 a 0 para detectar interrupciones
	
	initPWM0FastA0(0,1024);
	initPWM0FastB0(0,1024);
	initPWM0FastA2(0,1024);
	initPWM0FastB2(0,1024);
	initADC();
	initUART9600();
	
	uint16_t dutyCycle1 = valorADC(7);
	uint16_t dutyCycle2 = valorADC(6);
	uint16_t dutyCycle3 = valorADC(5);
	uint16_t dutyCycle4 = valorADC(4);
	sei();
	// WriteUART('A');
	//WriteMessage("MODOS\n1. Manual\n2. UART\n3. Guardar EEPROM\n4. Leer EEPROM" );
	
    while (1){	
			if (seleccion==1){
				//LEDS Seleccion
				PORTB |=(1<<0);
				PORTD &= ~(1<<7);
				PORTD &= ~(1<<4);
				//cambios con potenciometro
				dutyCycle1 = valorADC(7);
				updateDutyCycleA0(dutyCycle1);
				_delay_ms(200);
				
				dutyCycle2 = valorADC(6);
				updateDutyCycleB0(dutyCycle2);
				_delay_ms(200);
				
				dutyCycle3 = valorADC(5);
				updateDutyCycleA2(dutyCycle3);
				_delay_ms(200);

				dutyCycle4 = valorADC(4);
				updateDutyCycleB2(dutyCycle4);
				_delay_ms(200);
				
			_delay_ms(25);
				bufferRX = '0';
			}
			else if (seleccion==2){
				//LEDS Seleccion
				PORTB &= ~(1<<0);
				PORTD |= (1<<7);
				PORTD &= ~(1<<4);
				//comunicacion UART
				WriteMessage("\n\n1. Ojos a la izquierda\n2. Ojos a la derecha\n3. Parpados arriba\n4. Parpados abajo\nSeleccion:" );
				//bufferRX = '0';
				//while (bufferRX == '0');
					if (bufferRX == '1'){
					//	dutyCycle1 = dato_uart;
						updateDutyCycleA0(255);
					//	dutyCycle2 = dato_uart;
						updateDutyCycleB0(255);
					}
					
					else if (bufferRX == '2'){
					//	dutyCycle1 = dato_uart;
						updateDutyCycleA0(0);
					//	dutyCycle2 = dato_uart;
						updateDutyCycleB0(0);
					}
						
					else if (bufferRX == '3'){
					//	dutyCycle1 = dato_uart;
						updateDutyCycleA2(255);
					//	dutyCycle2 = dato_uart;
						updateDutyCycleB2(255);
					}
						
					else if (bufferRX == '4'){
					//	dutyCycle1 = dato_uart;
						updateDutyCycleA2(0);
					//	dutyCycle2 = dato_uart;
						updateDutyCycleB2(0);
					}
			}
			else if (seleccion==3){ 
				//LEDS Seleccion
				PORTB &= ~(1<<0);
				PORTD &= ~(1<<7);
				PORTD |= (1<<4);
				//movimiento de servos por medio de potenciometros
				dutyCycle1 = valorADC(6);
				_delay_ms(10);
				updateDutyCycleA0(dutyCycle1);

				dutyCycle2 = valorADC(7);
				_delay_ms(10);
				updateDutyCycleB0(dutyCycle2);
				
				//Ojo derecho
				dutyCycle3 = valorADC(5);
				_delay_ms(10);
				updateDutyCycleA2(dutyCycle3);

				dutyCycle4 = valorADC(4);
				_delay_ms(10);
				updateDutyCycleB2(dutyCycle4);
				
				_delay_ms(25);
				
				//guardar en EEPROM
				if(PINB5 == 1){
					eeprom_write_byte((uint8_t*)0x00, dutyCycle1);
				}
				else if (PINC0 == 1){
					eeprom_write_byte((uint8_t*)0x01, dutyCycle2);
				}
				else if (PINC1 == 1){
					eeprom_write_byte((uint8_t*)0x03, dutyCycle3);
				}
				else if (PINC2 == 1){
					eeprom_write_byte((uint8_t*)0x04, dutyCycle4);
				}
			}
			else if (seleccion==4){
				//LEDS Seleccion
				PORTB &= ~(1<<0);
				PORTD |= (1<<7);
				PORTD |= (1<<4);
				//leer del EEPROM
				servo1 = eeprom_read_byte((uint8_t*)0x00);
				servo2 = eeprom_read_byte((uint8_t*)0x01);
				servo3 = eeprom_read_byte((uint8_t*)0x03);
				servo4 = eeprom_read_byte((uint8_t*)0x04);
				
				updateDutyCycleA0(servo1);
				updateDutyCycleB0(servo2);
				updateDutyCycleA2(servo3);
				updateDutyCycleA2(servo4);
		}
    }
}

void initADC(void){
	ADMUX = 0;
	
	ADMUX |= (1<<REFS0);
	ADMUX &= ~(1<<REFS1);
	ADMUX |= (1<<ADLAR);

	ADCSRA = 0;
	
	ADCSRA |= (1<<ADEN);
	
	ADCSRA |= (ADPS2)|(ADPS1)|(ADPS0);
	
	DIDR0 |= (1<<ADC5D);
	
	DIDR0 |= (1<<ADC4D);
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

ISR(INT0_vect){
	seleccion++;
	if(seleccion>=5){
		seleccion = 1;
	}
	_delay_ms(100);
}

ISR(USART_RX_vect){
	bufferRX = UDR0;
	
	while(!(UCSR0A & (1<<UDRE0)));
	UDR0 = bufferRX;
}

