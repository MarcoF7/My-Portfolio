#include <OneWire.h>
#include <DallasTemperature.h>

#define pHSensorPin 0      
// Entrada Analogica A0 del arduino sera destinada para el sensor de pH
#define Pin_Temp_Sensor 2  
// Pin donde se conectará la DATA de Temperatura (Pin Digital 2)

OneWire ourWire(Pin_Temp_Sensor); 
//Se establece el pin declarado como bus para la comunicación OneWire

DallasTemperature sensors(&ourWire); 
//Se instancia la librería DallasTemperature

float Temp_Centig = 0;     // Temperatura en centrigrados
float pHValue = 0;         // Valor de pH
unsigned long int avgValue;// avgValue almacenara el valor promedio de las mediciones de pH
int buf[10],temp = 0;      // en buf[] se almacenaran los 10 valores medidos de pH 
                           //temp es una variable temporal
int Sensor_Sup = 0;        // Almacenara el estado del sensor de nivel superior del tanque
int Sensor_Inf = 0;        // Almacenara el estado del sensor de nivel inferior del tanque
int Flag_Up = 1;    //inicializo bandera de llenado del tanque
int Flag_Down = 0;  // inicializo bandera de vaciado del tanque
int Estado_Calefac = 0; //inicializo estado calefactor apagado
int Flag_Bajo_pH = 0;  // inicializo nivel pH OK
int Flag_Alto_pH = 0;  // inicializo nivel pH OK


void CambiarAgua()
{
    if((Sensor_Sup == LOW) && (Flag_Up == 1))
    {
      digitalWrite(5, HIGH); //activo valvula Superior
    }
    else 
// entra a else cuando el nivel del agua llega al limite superior (Sensor_Sup == HIGH)
    {
      digitalWrite(5, LOW); //desactivo valvula Superior
      Flag_Down = 1; //ahora activo el Flag_Down para que pase a vaciarse el tanque
      Flag_Up = 0;
    }

    if((Sensor_Inf == LOW) &&(Flag_Down==1))
    {
      digitalWrite(6, HIGH); //activo valvula Inferior
    }
    else 
// entra a else cuando el nivel del agua llega al limite inferior (Sensor_Inf == HIGH)
    {
      digitalWrite(6, LOW); //desactivo valvula Inferior
      Flag_Up = 1;  //ahora activo el Flag_Up para que pase a llenarse el tanque
      Flag_Down = 0;
    }
}


void setup()
{
  pinMode(2,INPUT);      // Sensor Temperatura
  pinMode(3,OUTPUT);      // Indicador Luminoso de Temperatura
  pinMode(4,OUTPUT);      // Indicador Luminoso de pH
  pinMode(5,OUTPUT);      // Valvula Solenoide Superior 1/4"
  pinMode(6,OUTPUT);      // Valvula Solenoide Inferior 1/4"
  pinMode(7,INPUT);       // Sensor Nivel Superior
  pinMode(8,INPUT);       // Sensor Nivel Inferior
  pinMode(9,OUTPUT);      // Calefactor Electrico Resistivo
  
  Serial.begin(9600);  
  sensors.begin(); //Se inician los sensores Temperatura
  Serial.println("Ready");    //Probando el Monitor Serial
}


void loop()
{

  // Lectura Sensor Temperatura y Calentador

  sensors.requestTemperatures(); 
  //Prepara el sensor de Temperatura para la lectura

  Temp_Centig = sensors.getTempCByIndex(0);
  Serial.print(Temp_Centig); 
  //Se lee e imprime la temperatura en grados Celsius con 2 puntos decimales
  Serial.println(" grados Centigrados");

  if(Temp_Centig < 27.5)
  {
    digitalWrite(3, HIGH); 
 // Para indicar que el nivel de Temperatura esta fuera del rango permitido
  }
  else
  {
    digitalWrite(3, LOW); 
 // Temperatura esta en el rango deseado, apago LED
  }
  
  if((Estado_Calefac==0) && (Temp_Centig < 27.5)) 
  //si el calefactor esta apagado y se detecta < 27.5 grados
  {    
      digitalWrite(9, HIGH); // Enciendo al calefactor
      Estado_Calefac=1;      // Indica que el calefactor esta encendido
  }

  if((Estado_Calefac==1) && (Temp_Centig > 29.5))  
  //si el calefactor esta encendido y se detecta > 29.5 grados
  {    
      digitalWrite(9, LOW);  // Apago al calefactor  
      Estado_Calefac=0;      // Indica que el calefactor esta apagado
  } 


// Lectura de los sensores de Nivel
  
  Sensor_Sup = digitalRead(7);
  Sensor_Inf = digitalRead(8);

  if(Sensor_Sup == HIGH) // si el agua esta en su maximo nivel
  {
    digitalWrite(5, LOW); //desactivo valvula Superior
  }

  if(Sensor_Inf == HIGH) // si el agua esta en su minimo nivel
  {
    digitalWrite(6, LOW); //desactivo valvula Inferior
  }

// Lectura del sensor de pH
 
  for(int i=0;i<10;i++)       
//Se almacenan 10 medidas del sensor de pH 
//para tener una medida mas exacta
  { 
    buf[i]=analogRead(pHSensorPin); 
//Arduino lee valores de 0 a 1023 (ADC de 10 bits)
    delay(10);
  }
  for(int i=0;i<9;i++)  //ordeno de menor a mayor
  {
    for(int j=i+1;j<10;j++)
    {
      if(buf[i]>buf[j])
      {
        temp=buf[i];
        buf[i]=buf[j];
        buf[j]=temp;
      }
    }
  }
  
  avgValue=0;  //Inicializo
  for(int i=2;i<8;i++)                
    avgValue+=buf[i];
  //Tomo los 6 valores mas centrados y los promedio
  
  pHValue=(float)avgValue*5.0/1024/6; 
  //convierto el Valor Analogico a Voltios
  pHValue = 3.5*pHValue;             
  //convierto Volts a valor de pH (4*3.5 = 14)
  //Recordar que este sensor de pH entregara
  //como maximo 4Volts y como minimo 0V
  Serial.print("    pH:");  
  Serial.print(pHValue,2);
  Serial.println(" ");


  // Analisis de pH

  if(pHValue < 6.5) // si el pH es muy bajo
  {
     Flag_Bajo_pH = 1; // esta bandera se usara para la histeresis de pH
     digitalWrite(4, HIGH); //Indicamos que el nivel de pH esta fuera del rango
  }
  else if(pHValue > 7.5)  // si el pH es muy alto
  {
     Flag_Alto_pH = 1; // esta bandera se usara para la histeresis de pH
     digitalWrite(4, HIGH); //Indicamos que el nivel de pH esta fuera del rango 
  }
  else // si el pH esta en el rango optimo
  {
     digitalWrite(4, LOW); //Caso contrario apago el LED
  }


  if((Flag_Bajo_pH == 1) && (pHValue < 7.0)) 
  {
// Para que se apague el Cambio de Agua, el pHValue ya no debe  
//superar 6.5, ahora debe superar el nuevo limite: 7.0 (histeresis)
      CambiarAgua();
  }
  else // Entra cuando pHValue aumente a 7.0 o un poco mas
  {
      Flag_Bajo_pH = 0; 
    // Ahora si podemos detener el cambio de agua, el pH ya es 7.0
  }


  if((Flag_Alto_pH == 1) && (pHValue > 7.0))
  {
// Para que se apague el Cambio de Agua el pHValue ya no debe 
//ser menor a 7.5, ahora debe ser inferior al nuevo limite: 7.0
// (principio basico de histeresis)
      CambiarAgua(); 
  }
  else // Entra cuando pHValue disminuye a 7.0 o un poco menos
  {
      Flag_Alto_pH = 0; 
    // Ahora si podemos detener el cambio de agua, el pH ya es 7.0
  }
}



     



