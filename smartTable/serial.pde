// -------------------------------------------------------------------
// Fonction de gestion de la liaison série avec l'arduino
// -------------------------------------------------------------------
import processing.serial.*;

Serial myPort;
int portIndex=-1;
int counterTrame = 0;
int automateReceive = 0;
private String receivedString;
String rawValues;
String detectedMotion = "";
int lastMoveTime;


// -------------------------------------------------------------------
// Callback des Event provenant de la liaison série.
// -------------------------------------------------------------------
void serialEvent(Serial p)
{
  if (myPort.available() > 0)
  {
    char inByte = myPort.readChar();
    processSerial(inByte);
  }
}

// -------------------------------------------------------------------
// Gestion du protocole du 3D Pad / Arduino (ootsidebox code)
// -------------------------------------------------------------------
void processSerial(char chartmp) {

  if( chartmp == '.') 
  {
    print(".");
    StatusLine+=".";
  }
 
  switch(automateReceive) {
  case 0:
    if (chartmp == '>') automateReceive = 1; 
    break;
    
  case 1:
    if (chartmp == 'A') automateReceive = 2; 
    if (chartmp == 'G') automateReceive = 3; 
    if (chartmp == 'V') {
      automateReceive = 4;
      counterTrame = 0;
      receivedString = "";
    }
  break;
    
   case 2: //etats de l'automate 3Dpad
     print("\n\rState: "); 
     StatusLine="State: ";
     switch(chartmp)
     {
           case '0':
           case '1':
                     print("Calibration..");
                     StatusLine+="Calibration..";
                     break;
           case '2':
                     print("Setup ");
                     StatusLine+="Setup..";
                     break;
           case '3':
                     print("Run");
                     StatusLine+="Run";
                     break;
     }
     myPort.write('V');   
     automateReceive = 0;
   break;
    
  case 3: //gestures
     print("\n\rGest: "); 
     StatusLine="Gest: ";
     detectGesture(chartmp);
     automateReceive = 0;
     print(detectedMotion);    
     
  break;
  case 4:
    receivedString += chartmp;
    counterTrame++;
    if (counterTrame == 60) {
      rawValues=receivedString;
      calculateCoord();
      
      //println(rawValues);
      automateReceive = 0;
    }
    break;
  }
}

// -------------------------------------------------------------------
// Fonction de caractérisation des gestes
// -------------------------------------------------------------------
void detectGesture(char chartmp) {
  
  switch(chartmp) {
  case '0':
    detectedMotion = "OUT";
    break;
  case '1':
    detectedMotion = "IN";
    
    break;
  case '2':
    detectedMotion = "RIGHT";
    
    break;
  case '3':
    detectedMotion = "LEFT";
    
    break;
  case '4':
    detectedMotion = "UP";
   
    break;
  case '5':
    detectedMotion = "DOWN";
    
    break;
  case '6':
    //detectedMotion = "TurnL : "+ turnL;
    detectedMotion = "TurnL";
    break;
  case '7':
    //detectedMotion = "TurnR : " + turnR;
    detectedMotion = "TurnR";
    break;
  case '8':
    detectedMotion = "PUSH";
    break;
  }
   StatusLine+=detectedMotion;
   lastMoveTime = millis();
}
