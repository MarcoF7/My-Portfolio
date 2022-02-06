
	/*
 * proyecto2.cpp
 *
 * Created: 08/11/2016 ESTE TIENE EL SONIDO MAS ALTO
 *  Author: HJLR, MARCO
 */ 

#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <string.h>

#define F_CPU 8000000UL // Frecuencia del CPU = 8 Mhz
#define Debouncing 40; //Queremos verificar que la senial de JD se ponga en 0 por lo menos 25ms para descartar ruido
const unsigned int Baudios=103;

volatile int DebPD0=Debouncing;
volatile int DebPD1=Debouncing;
volatile int DebPC0=Debouncing;
volatile int SensorNivelPD1=0;
volatile int SensorNivelPD0=0;

volatile int valueAdc = 0;
volatile long cuenta_15seg = 0;

//volatile int Suma_Sensor_Nivel2 = 0;
//volatile int Sensor_Nivel2 = 0;

//volatile float dato1 = 0;
//volatile float distancia = 0;





#define NOTE_B0  31
#define NOTE_C1  33
#define NOTE_CS1 35
#define NOTE_D1  37
#define NOTE_DS1 39
#define NOTE_E1  41
#define NOTE_F1  44
#define NOTE_FS1 46
#define NOTE_G1  49
#define NOTE_GS1 52
#define NOTE_A1  55
#define NOTE_AS1 58
#define NOTE_B1  62
#define NOTE_C2  65
#define NOTE_CS2 69
#define NOTE_D2  73
#define NOTE_DS2 78
#define NOTE_E2  82
#define NOTE_F2  87
#define NOTE_FS2 93
#define NOTE_G2  98
#define NOTE_GS2 104
#define NOTE_A2  110
#define NOTE_AS2 117
#define NOTE_B2  123
#define NOTE_C3  131
#define NOTE_CS3 139
#define NOTE_D3  147
#define NOTE_DS3 156
#define NOTE_E3  165
#define NOTE_F3  175
#define NOTE_FS3 185
#define NOTE_G3  196
#define NOTE_GS3 208
#define NOTE_A3  220
#define NOTE_AS3 233
#define NOTE_B3  247
#define NOTE_C4  262
#define NOTE_CS4 277
#define NOTE_D4  294
#define NOTE_DS4 311
#define NOTE_E4  330
#define NOTE_F4  349
#define NOTE_FS4 370
#define NOTE_G4  392
#define NOTE_GS4 415
#define NOTE_A4  440
#define NOTE_AS4 466
#define NOTE_B4  494
#define NOTE_C5  523
#define NOTE_CS5 554
#define NOTE_D5  587
#define NOTE_DS5 622
#define NOTE_E5  659
#define NOTE_F5  698
#define NOTE_FS5 740
#define NOTE_G5  784
#define NOTE_GS5 831
#define NOTE_A5  880
#define NOTE_AS5 932
#define NOTE_B5  988
#define NOTE_C6  1047
#define NOTE_CS6 1109
#define NOTE_D6  1175
#define NOTE_DS6 1245
#define NOTE_E6  1319
#define NOTE_F6  1397
#define NOTE_FS6 1480
#define NOTE_G6  1568
#define NOTE_GS6 1661
#define NOTE_A6  1760
#define NOTE_AS6 1865
#define NOTE_B6  1976
#define NOTE_C7  2093
#define NOTE_CS7 2217
#define NOTE_D7  2349
#define NOTE_DS7 2489
#define NOTE_E7  2637
#define NOTE_F7  2794
#define NOTE_FS7 2960
#define NOTE_G7  3136
#define NOTE_GS7 3322
#define NOTE_A7  3520
#define NOTE_AS7 3729
#define NOTE_B7  3951
#define NOTE_C8  4186
#define NOTE_CS8 4435
#define NOTE_D8  4699
#define NOTE_DS8 4978

#define melodyPin 3
//Mario main theme melody
int melody[] = {
	NOTE_E7, NOTE_E7, 0, NOTE_E7,
	0, NOTE_C7, NOTE_E7, 0,
	NOTE_G7, 0, 0,  0,
	NOTE_G6, 0, 0, 0,
	
	NOTE_C7, 0, 0, NOTE_G6,
	0, 0, NOTE_E6, 0,
	0, NOTE_A6, 0, NOTE_B6,
	0, NOTE_AS6, NOTE_A6, 0,
	
	NOTE_G6, NOTE_E7, NOTE_G7,
	NOTE_A7, 0, NOTE_F7, NOTE_G7,
	0, NOTE_E7, 0, NOTE_C7,
	NOTE_D7, NOTE_B6, 0, 0,
	
	NOTE_C7, 0, 0, NOTE_G6,
	0, 0, NOTE_E6, 0,
	0, NOTE_A6, 0, NOTE_B6,
	0, NOTE_AS6, NOTE_A6, 0,
	
	NOTE_G6, NOTE_E7, NOTE_G7,
	NOTE_A7, 0, NOTE_F7, NOTE_G7,
	0, NOTE_E7, 0, NOTE_C7,
	NOTE_D7, NOTE_B6, 0, 0
};
//Mario main them tempo
int tempo[] = {
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
	
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
	
	9, 9, 9,
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
	
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
	
	9, 9, 9,
	12, 12, 12, 12,
	12, 12, 12, 12,
	12, 12, 12, 12,
};
//Underworld melody
int underworld_melody[] = {
	NOTE_C4, NOTE_C5, NOTE_A3, NOTE_A4,
	NOTE_AS3, NOTE_AS4, 0,
	0,
	NOTE_C4, NOTE_C5, NOTE_A3, NOTE_A4,
	NOTE_AS3, NOTE_AS4, 0,
	0,
	NOTE_F3, NOTE_F4, NOTE_D3, NOTE_D4,
	NOTE_DS3, NOTE_DS4, 0,
	0,
	NOTE_F3, NOTE_F4, NOTE_D3, NOTE_D4,
	NOTE_DS3, NOTE_DS4, 0,
	0, NOTE_DS4, NOTE_CS4, NOTE_D4,
	NOTE_CS4, NOTE_DS4,
	NOTE_DS4, NOTE_GS3,
	NOTE_G3, NOTE_CS4,
	NOTE_C4, NOTE_FS4, NOTE_F4, NOTE_E3, NOTE_AS4, NOTE_A4,
	NOTE_GS4, NOTE_DS4, NOTE_B3,
	NOTE_AS3, NOTE_A3, NOTE_GS3,
	0, 0, 0
};
//Underwolrd tempo
int underworld_tempo[] = {
	12, 12, 12, 12,
	12, 12, 6,
	3,
	12, 12, 12, 12,
	12, 12, 6,
	3,
	12, 12, 12, 12,
	12, 12, 6,
	3,
	12, 12, 12, 12,
	12, 12, 6,
	6, 18, 18, 18,
	6, 6,
	6, 6,
	6, 6,
	18, 18, 18, 18, 18, 18,
	10, 10, 10,
	10, 10, 10,
	3, 3, 3
};












int c[5]={131,262,523,1046,2093};       // frecuencias 4 octavas de Do
int cs[5]={139,277,554,1108,2217};      // Do#
int d[5]={147,294,587,1175,2349};       // Re
int ds[5]={156,311,622,1244,2489};    // Re#
int e[5]={165,330,659,1319,2637};      // Mi
int f[5]={175,349,698,1397,2794};       // Fa
int fs[5]={185,370,740,1480,2960};     // Fa#
int g[5]={196,392,784,1568,3136};     // Sol
int gs[5]={208,415,831,1661,3322};   // Sol#
int a[5]={220,440,880,1760,3520};      // La
int as[5]={233,466,932,1866,3729};    // La#
int b[5]={247,494,988,1976,3951};      // Si
	




const uint8_t sine[256]PROGMEM={127,130,133,136,139,143,146,149,152,155,158,161,164,167,170,173,176,178,
	181,184,187,189,192,195,197,200,203,205,207,210,212,214,217,219,221,223,225,227,229,231,232,234,236,
	237,239,240,242,243,244,245,246,248,248,249,250,251,251,252,253,253,253,254,254,254,254,254,254,254,
	253,253,253,252,252,251,250,250,249,248,247,246,245,243,242,241,239,238,236,235,233,231,229,227,225,
	224,221,219,217,215,213,210,208,206,203,201,198,195,193,190,187,185,182,179,176,173,170,167,164,161,
	158,155,152,149,146,143,140,137,134,131,128,125,121,118,115,112,109,106,103,100,97,94,91,88,85,82,79,
	76,73,71,68,65,62,60,57,55,52,50,47,45,42,40,38,36,34,31,29,27,26,24,22,20,19,17,15,14,13,11,10,9,8,7,
	6,5,4,3,3,2,2,1,1,0,0,0,0,0,0,0,1,1,1,2,2,3,4,4,5,6,7,8,9,10,12,13,14,16,17,19,21,22,24,26,28,30,32,34,
	36,39,41,43,45,48,50,53,55,58,61,63,66,69,72,74,77,80,83,86,89,92,95,98,101,104,107,110,113,116,119,122,
};

void ConfiguraPuertos(void)
{
	DDRB=0x36; //salida:OC0 (PB4)chato  OC1A (PB5)jdd; PANEL LED: PB1,PB2,PB6; AHORA PB6 ENTRADA PARA LEER EL SHARP DEL ARDUINO
	DDRE=0x08; //salida: OC3A (PE3) tibu
	DDRD=0xE0; // salida:pines de tibu (PD6,PD7);   entrada: (PD0,PD1) Jdd;   PANEL LED: PD5
	DDRC=0xC0; //entrada:(PC0) Jdd; PC1 y PC2 entradas fin carrera;  PC7 (salida),PC6 (salida) (Ahora para comunicar Arduino)
	DDRF=0x00; // PF0 y PF1 son para el PIR y el SHARP    
	DDRA = 0xFF; // todas salidas
	
	PORTC &= ~(1<<PINC7); //inicialmente PC7 = 0
	PORTC &= ~(1<<PINC6); //inicialmente PC6 = 0   Ambos para comunicar con el Arduino
	
	PORTD &= 0x00;
	PORTB |= (1<<PINB6); // activo pull up para entrada que vendra del arduino
	
}


int readAdc()
{
	int valueAdc;
	
	ADCSRA  |= (1<<ADSC);					/* Start ADC Conversion */
	while((ADCSRA & (1<<ADIF)) != 0x10);	/* Wait till conversion is complete */
	valueAdc   = ADC;
	ADCSRA  |= (1 << ADIF);					/* Clear ADC Conversion Interrupt Flag */
	
	return valueAdc;
}


ISR(TIMER2_COMP_vect){
	
	//	PORTF ^= 1<<PINF0;
	
	int aux = readAdc();
	valueAdc += aux;
	valueAdc >>= 1;
	/*
	Sensor_Nivel2 = PIND&(1<<PIND1);
	Suma_Sensor_Nivel2 += Sensor_Nivel2;
	Suma_Sensor_Nivel2 >>= 1;
	*/
	cuenta_15seg++;
	
	chkPD1(); // cada ms analizamos el estado del sensor de JD
	chkPD0();
	
	
	//dato1=0.004887585532*valueAdc;
	//distancia=28*pow(dato1,-1.2);
	
	
	//return;
	// Modula PWM1
	//analiza_SensoresNivel();
}



void conf_timer2(void){

	TCCR2 = (1<<WGM21) |(0<<WGM20)|(0<<CS22)|(1<<CS21)|(1<<CS20);
	OCR2  = 125; // T = 1ms
	TIMSK = 1<<OCIE2;
}


void ConfiguraPWMBUZZER()
{
	// Generador de ondas del timer 0 en modo 4
	// WGM01...00 = 11, modo fast pwm
	// COM01..00 = 10,
	// CS02..00 = 001,  sin prescalador
	TCCR0=(1<<WGM00)|(1<<WGM01)|(1<<COM01)|(0<<COM00)|(0<<CS02)|(0<<CS01)|(1<<CS00); // cambie frecuencia aqui
	OCR0 = 255;
}

void ConfiguraPWM1() //sale del pin PB5
{
	// Generador de ondas del timer 1 en modo 4
	// WGM13...0 = 0100, modo CTC
	// COM1A1..0 = 01,
	// CS12..10 = 010, preescalador 8
	TCCR1A = (0<<COM1A1|1<<COM1A0|0<<WGM11|0<<WGM10);
	TCCR1B = (0<<WGM13|1<<WGM12|0<<CS12|1<<CS11|0<<CS10);
	// Cálculo: preescalador 8, Fpwm = 38.5Khz
	OCR1A = 12; //OCR1A=12
}

/*
void ConfiguraPWMMOTOR(){
	// Generador de ondas del timer 3 en modo 4
	// WGM33...0 = 0100, modo CTC
	// COM3C1..0 = 00,
	// CS32..10 = 010, preescalador 8
	
	
	TCCR3A = (0<<COM3A1|1<<COM3A0|0<<WGM31|0<<WGM30);
	TCCR3B = (0<<WGM33|1<<WGM32|0<<CS32|1<<CS31|0<<CS30);
	// Cálculo: preescalador 8, Fpwmmax=100Hhz 
	OCR3A = 4999; //100 Hz
	
}

*/

//Configura PWM Motor en modo Fast PWM para variar el ancho de pulso (la velocidad del Motor):


void ConfiguraPWMMOTOR(){
	// Generador de ondas del timer 3 en modo 4
	// Modo Fast PWM, 8 bits, TOP = 0x00FF (0-255)
	// Preescalador 1024
	// f = fclk/(N*256) = 30.51Hz  SI GIRA
	
	
	//Con preescalador 256 no gira: (No usar)
	//f = fclk/(N*256) = 122Hz  NO GIRA

	
	TCCR3A = (1<<COM3A1|1<<COM3A0|0<<WGM31|1<<WGM30);
	TCCR3B = (0<<WGM33|1<<WGM32|1<<CS32|0<<CS31|1<<CS30);
	OCR3A = 0; //inicialmente no gira
	//va de 0 a 255 -> 0 a 100% el duty cycle
}




int ConfiguraADC(void)
{
	ADMUX=(1<<REFS1)|(1<<REFS0)|(0<<ADLAR)|(0x01);	//ADC1
	ADCSRA=(1<<ADEN)|(1<<ADPS1)|(1<<ADPS0);
}

void ConfiguraUSART(){
	UBRR0H = (unsigned char)(Baudios>>8); // 9600 bps
	UBRR0L = (unsigned char) Baudios;
	UCSR0A = 1<<U2X0; // velocidad doble
	//Comunicación Asíncrona, sin paridad, 1 bit de parada, 8 bits de datos
	UCSR0C = (1<<UMSEL0)|(0<<UPM01)|(0<<UPM00)|(0<<USBS0)|(1<<UCSZ01)|(1<<UCSZ00);
	UCSR0B = (1<<RXEN0)|(1<<TXEN0)|(0<<UCSZ02); // Tx y Rx habilitadas
}
unsigned char Espera_Byte(void)
{
	unsigned char datoRx;
	while( !(UCSR0A & (1<<RXC0)) );
	datoRx= UDR0;
	return datoRx;
}

void transmite_caracter_2 (unsigned char dato)
{
	while( !(UCSR0A & (1<<UDRE0)) ); // Espera que se libere el buffer de transmisión
	UDR0 = dato;
}

void transmite_cadena_2( char cadena[])
{
	unsigned char i;
	
	for (i = 0; cadena[i]; i++)
	{
		transmite_caracter_2(cadena[i]);
	}
}


void nota(int frec, int t)
{
	OCR0 = frec;
	_delay_loop_2(t);                // para despues de un tiempo t
}

void chkPD1()
{	int EstPinD=PIND;
	
	if ((EstPinD & 0x02)== 0)			// Cae Botella o Ruido
	{
		if (--DebPD1==0)
		{	SensorNivelPD1&=0xFE; //pone a 0 el bit 0 (representa PD1)
			DebPD1=Debouncing;
		}
	}
	else								// No hay Nada
	{	SensorNivelPD1|=0x01; // pone a 1 el bit 0 (representa PD1)
		DebPD1=Debouncing;  
	}
}

void chkPD0()
{	int EstPinD=PIND;
	
	if ((EstPinD & 0x01)== 0)			// Cae Botella o Ruido
	{
		if (--DebPD0==0)
		{	SensorNivelPD0&=0xFE; //pone a 0 el bit 0 (representa PD0)
			DebPD0=Debouncing;
		}
	}
	else								// No hay Nada
	{	SensorNivelPD0|=0x01; // pone a 1 el bit 0 (representa PD0)
		DebPD0=Debouncing;
	}
}




int main(void)
{

	ConfiguraPuertos();
	PORTD &= ~(1<<PIND7);
	PORTD &= ~(1<<PIND6); //apago motor
	
	ConfiguraPWMBUZZER();
	ConfiguraPWMMOTOR();
	ConfiguraPWM1();
	ConfiguraUSART();
	
	ConfiguraADC();
	conf_timer2(); // Timer 2 para el sensor SHARP y para variables de cuenta
	
	//OCR0=(pgm_read_byte_near(sine+100)*2)+1;
	//OCR0 = 30;
	
    float dato1 = 0;
    float distancia = 0;	

	int PIR_ant = 0;
	int PIR_new = 0;
	//int Sensores_Nivel_Basura = (PIND&((1<<PIND0)|(1<<PIND1)))|((PINC&(1<<PINC0))<<2);
	int bandera_PIR = 1;
	
	int bandera_SHARP = 0;
	
	int sonido = 0;
    
	int Sensor_Nivel1 = 1; //toma valor 0 o 1
	int Sensor_Nivel2 = 2; //toma valor 0 o 2
	int Sensor_Nivel3 = 1; //toma valor 0 o 1
	
	int fin_carrera_1 = 0;
	int fin_carrera_2 = 0;	
	
	char Arreglo1[] = {'M','e','m','p','h','i','s'};
		
	int p6 = 0;
	
	PORTC&= ~(1<<PINC7); //PC7 = 0 -> Apago Panel
	PORTC&= ~(1<<PINC6); //PC6 = 0
	
	//transmite_cadena_2("AT+CWMODE=1");
	//transmite_cadena_2("AT+CIPMUX=1");
	//transmite_cadena_2("AT+CIPSERVER=1,80");
	
	//transmite_cadena_2(Arreglo1);
	

	_delay_ms(30000); // es x 10^-4 en mi compu xq esta corrupta
	
	sei();
	

	while(1)
	{
		
		
		do 
		{
			
			
			PIR_new = (PINF&(1<<PINF0)); //PIR esta conectado a PF0
			
			if((PIR_ant == 0) && (PIR_new == 1))
			{
				bandera_PIR = 1; //ocurrio flanco de subida (detecto cambio de estado)
			}
			
			if(cuenta_15seg >= 15000) // si pasaron 20 segundos
			{
				bandera_PIR = 0;
				cuenta_15seg = 0;
				PORTC&= ~(1<<PINC7); //PC7 = 0 -> Apago Panel
				PORTC&= ~(1<<PINC6); //PC6 = 0
				OCR0=255; //apaga sonido
				
			}

			
			PIR_ant = PIR_new;
			
			if(bandera_PIR == 1)
			{
				sonido = 1;
				//OCR0=(pgm_read_byte_near(sine+55)*2)+1;
				
				PORTC|= (1<<PINC7); //PC7 = 1 -> Enciende panel LED "Feed me!"
				PORTC&= ~(1<<PINC6); //PC6 = 0			
																																											
			}	
				
			if((sonido >= 1) && (sonido <= 3))
			{
				uint8_t delay,n, i;
				for(delay=1;delay<=50;delay++)
				{
					for(n=0;n<(51-delay);n++)
					{
						for(i=0;i<=254;i++)
						{
							OCR0=(pgm_read_byte_near(sine+i)*2)+1;
							//OCR0=pgm_read_byte_near(sine+i);
							_delay_loop_2(delay);
							
						}
					}
				}
				
				sonido++;
				
			}
			
		    //dato1=0.004887585532*valueAdc;
		   // distancia=28*pow(dato1,-1.2);
			
			bandera_SHARP = PINB & (1<<PINB6);
				
		//} while ((distancia < 20) || (distancia > 60));
			}while(bandera_SHARP == 0);
	
			
		
		
		OCR3A = 120; //duty cycle 100%
		PORTD |= (1<<PIND7);
		PORTD &= ~(1<<PIND6);    //ABRE TAPA

		_delay_ms(4000);
		
		PORTD &= ~(1<<PIND7);
		PORTD &= ~(1<<PIND6); //apago motor
		

		/*
		do
		{
			fin_carrera_1 = (PINC&(1<<PINC1)); //PC1 es el k sta sin Molex
		} while (fin_carrera_1 == 0); //fin carrera abrir
		*/
		

	   
//JD

/*
		do
		{
			PORTD &= ~(1<<PIND7);
			PORTD &= ~(1<<PIND6); //apago motor
		} while ((SensorNivelPD1 == 1) && (SensorNivelPD0 == 1));
	*/
		
		
		cuenta_15seg = 0;
		do 
		{
			PORTC&= ~(1<<PINC7); //PC7 = 0 -> Enciende panel LED "Gracias!"
			PORTC|= (1<<PINC6); //PC6 = 1
		} while (cuenta_15seg <= 7000); // espera 7 segundos HASTA  K BOTE BASURA
		

		OCR3A = 120; //duty cycle 100%
		PORTD |= (1<<PIND6); //Cierra tapa, gira antihorario
		PORTD &= ~(1<<PIND7);
		
		_delay_ms(4000);
	
		
/*		
		do
		{
			PORTC&= ~(1<<PINC7); //PC7 = 0 -> Enciende panel LED "Gracias!"
			PORTC|= (1<<PINC6); //PC6 = 1
			
			fin_carrera_2 = (PINC&(1<<PINC2));
		} while (fin_carrera_2 == 0); //fin carrera cerrar
		
*/
		
		
		PORTD &= ~(1<<PIND7);
		PORTD &= ~(1<<PIND6); //apago motor
		
		_delay_ms(20000); //Espera a que la persona se vaya luego de botar la basura
		
        PORTC&= ~(1<<PINC7); //PC7 = 0 -> Apago Panel
        PORTC&= ~(1<<PINC6); //PC6 = 0
		
		_delay_ms(10000);
		
        OCR0=255; //apaga sonido
 	
	
	    cuenta_15seg = 0; 
		bandera_SHARP = 0;
	
		
	}

}








//while(1)
//{
	
	//STARTS WARS 1
	
	/*
		OCR0 = 255;
		_delay_ms(5000);
		
		OCR0=38;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=38;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(800);
		OCR0=38;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=51;
		_delay_ms(4500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=76;
		_delay_ms(4500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=68;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=64;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=57;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=102;
		_delay_ms(4500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=76;
		_delay_ms(3000);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=68;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=64;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=57;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=102;
		_delay_ms(4500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=76;
		_delay_ms(3000);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=68;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=64;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=68;
		_delay_ms(1500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0=57;
		_delay_ms(4500);
		OCR0 = 255;
		_delay_ms(400);
		OCR0 = 255;
		_delay_ms(5000);
		//Ahora te paso con el modo PWM invertido
		OCR0 = 0;
		_delay_ms(10000);
		
		OCR0=38;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=38;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=38;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=51;
		_delay_ms(9000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=76;
		_delay_ms(9000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=68;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=64;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=57;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=102;
		_delay_ms(9000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=76;
		_delay_ms(6000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=68;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=64;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=57;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=102;
		_delay_ms(9000);
		OCR0 = 255;
		_delay_ms(800);
		OCR0=76;
		_delay_ms(6000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=68;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=64;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=68;
		_delay_ms(3000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0=57;
		_delay_ms(9000);
		OCR0 = 0;
		_delay_ms(800);
		OCR0 = 0;
		_delay_ms(10000);
		
		
	
	*/
	
	
	   //STARTS WARS TIBU
	   
	//1 1; 1 0 0
	//OCR0 = 255; _delay_ms(10000); OCR0=38; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=38; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=38; _delay_ms(3000); OCR0 = 255; _delay_ms(800); OCR0=51; _delay_ms(9000); OCR0 = 255; _delay_ms(500); OCR0=76; _delay_ms(9000); OCR0 = 255; _delay_ms(500); OCR0=68; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=64; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=57; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=102; _delay_ms(9000); OCR0 = 255; _delay_ms(800); OCR0=76; _delay_ms(7000); OCR0 = 255; _delay_ms(1200); OCR0=68; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=64; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=57; _delay_ms(1000); OCR0 = 255; _delay_ms(300); OCR0=102; _delay_ms(9000); OCR0 = 255; _delay_ms(800); OCR0=76; _delay_ms(7000); OCR0 = 255; _delay_ms(1200);OCR0=68; _delay_ms(1000); OCR0 = 255; _delay_ms(500); OCR0=64; _delay_ms(1000); OCR0 = 255; _delay_ms(500); OCR0=68; _delay_ms(1000); OCR0 = 255; _delay_ms(500); OCR0=57; _delay_ms(12000); OCR0 = 255; _delay_ms(1200); OCR0 = 255; _delay_ms(10000);
		
	
	
	/*
	uint8_t delay,n, i;
	for(delay=1;delay<=50;delay++)
	{
		for(n=0;n<(51-delay);n++)
		{
			for(i=0;i<=254;i++)
			{
				OCR0=(pgm_read_byte_near(sine+i)*2)+1;
				//OCR0=pgm_read_byte_near(sine+i);
				_delay_loop_2(delay);
				
			}
		}
	}
	
	for(delay=50;delay>=2;delay--)
	{
		for(n=0;n<(51-delay);n++)
		{
			for(i=0;i<=254;i++)
			{
				//OCR0=(pgm_read_byte_near(sine+i)*2)+1;
				OCR0=pgm_read_byte_near(sine+i);
				_delay_loop_2(delay);
				
			}
		}
	}
		
	*/	
		
		
	/*
	    OCR3A = 66;
		do
		{
			PORTC&= ~(1<<PINC7); //PC7 = 0 -> Apago Panel
			PORTC&= ~(1<<PINC6); //PC6 = 0
			
		} while ((SensorNivelPD1 == 1) && (SensorNivelPD0 == 1));
	
		//_delay_ms(10000);
		//OCR3A = 66;
		//PORTD |= (1<<PIND7);
		//PORTD &= ~(1<<PIND6);
		PORTC&= ~(1<<PINC6); // -> Enciende panel LED "Gracias!"
		PORTC|= ~(1<<PINC7); //
		//OCR0=(pgm_read_byte_near(sine+55)*2)+1;
		while(1);
		*/
	
	
		//}

//}














	





/*
					
				uint8_t delay,n, i;
				for(delay=1;delay<=50;delay++)
				{
					for(n=0;n<(51-delay);n++)
					{
						for(i=0;i<=254;i++)
						{
							OCR0=(pgm_read_byte_near(sine+i)*2)+1;
							//OCR0=pgm_read_byte_near(sine+i);
							_delay_loop_2(delay);
                     	    
						}
					}
				}
				
				for(delay=50;delay>=2;delay--)
				{
					for(n=0;n<(51-delay);n++)
					{
						for(i=0;i<=254;i++)
						{
							//OCR0=(pgm_read_byte_near(sine+i)*2)+1;
							OCR0=pgm_read_byte_near(sine+i);
							_delay_loop_2(delay);
                     	    
						}
					}
				}
				
							
	
	OCR0=155;
	_delay_ms(50000);
	
	OCR0=255;
	_delay_ms(50000);	
	
*/

		/*
		PORTC&= ~(1<<PINC7); //PC7 = 0
        _delay_ms(50000); // es 10(-4)
		
		PORTC|= (1<<PINC7); //PC7 = 1
		_delay_ms(50000); // es 10(-4)
		*/

