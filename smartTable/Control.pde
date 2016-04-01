// -------------------------------------------------------------------
// Formulaire de contrôle : choix du port Arduino, commandes d'init
// -------------------------------------------------------------------
import processing.serial.*;
import controlP5.*;
ControlP5 cp5;
DropdownList dSerial;
Button bCalibrate, bSetup;

// -------------------------------------------------------------------
// Setup des éléments d'IHM
// -------------------------------------------------------------------
void setupControl() {
  cp5 = new ControlP5(this);

  bCalibrate = cp5.addButton("Calibrate")
                  .setValue(0)
                  .setPosition(120,10)
                  .setColorBackground(color(60))
                  .setColorActive(color(255, 128));

  bSetup = cp5.addButton("Setup")
                  .setValue(0)
                  .setPosition(120,30)
  		  .setColorBackground(color(60))
                  .setColorActive(color(255, 128));

  dSerial = cp5.addDropdownList("Serial-List").setPosition(10, 20);
  dSerial.captionLabel().set("Connect");
  for (int i=0; i<Serial.list ().length; i++) {
    dSerial.addItem(Serial.list()[i], i);
  }
  dSerial.setColorBackground(color(60));
  dSerial.setColorActive(color(255, 128));
 
}

// -------------------------------------------------------------------
//  Callback des évents de l'IHM
// -------------------------------------------------------------------
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup()) {

      if (portIndex!= -1) myPort.stop();
      portIndex = int(dSerial.getValue());
    
      myPort = new Serial(this, Serial.list()[portIndex], 115200);
      myPort.clear();
      println("Connecting to " + Serial.list()[portIndex] +"..");
      StatusLine="Connecting to " + Serial.list()[portIndex]+"..";
    
  }
}

// -------------------------------------------------------------------
// Fonction de connexion sur le bon port.
// -------------------------------------------------------------------
public void Connect(int portIndex) {
      if (portIndex!= -1) myPort.stop();
    
      myPort = new Serial(this, Serial.list()[portIndex], 115200);
      myPort.clear();
      println("Connecting to " + Serial.list()[portIndex]);
      StatusLine="Connecting to " + Serial.list()[portIndex];
}

// -------------------------------------------------------------------
// Envoie de la commande de calibration du 3D PAd à L'Arduino
// -------------------------------------------------------------------
public void Calibrate(int value) {
	myPort.write('A');
}

// -------------------------------------------------------------------
// Envoie de la commande d'exécution du setup à L'Arduino
// -------------------------------------------------------------------
public void Setup(int value) {
	myPort.write('S');
}
