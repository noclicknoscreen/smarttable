/*--------------------------------------------------------------
  Description:  Autodetect Arduino port connection
  Date:         1 November 2012
  Author:       W.A. Smith, http://startingelectronics.org
--------------------------------------------------------------*/
import processing.serial.*;

Serial myPort;                // for serial port
int num_ports;
boolean device_detected = false;
String[] port_list;
String detected_port = "";

void serialSetup() {
    // get the number of detected serial ports
    num_ports = Serial.list().length;
    // save the current list of serial ports
    port_list = new String[num_ports];
    for (int i = 0; i < num_ports; i++) {
        port_list[i] = Serial.list()[i];
    }
}

void serialDetection(){
  // see if Arduino or serial device was plugged in
  if (!device_detected) {
    if ((Serial.list().length > num_ports)) {
      device_detected = true;
      boolean str_match = false;
      if (num_ports == 0) {
        detected_port = Serial.list()[0];
      }
      else {
        // go through the current port list
        for (int i = 0; i < Serial.list().length; i++) {
          // go through the saved port list
          for (int j = 0; j < num_ports; j++) {
            if (Serial.list()[i].equals(port_list[j])) {
                break;
            }
            if (j == (num_ports - 1)) {
                str_match = true;
                detected_port = Serial.list()[i];
                Connect(i);
            }
          }
        }
      }
      // Update port list : One more port
      println("Arduino was plugged at " + detected_port + ".");
      serialSetup();
    }
    else {
      if ((Serial.list().length < num_ports)) {
        println("Arduino was unplugged...");
        // Update port list : one less port
        serialSetup();
        device_detected = false;
      }
      else {
       // Waiting for Arduino plug/deplug...
      }
    }
  }
} 

public void Connect(int portIndex) {
  myPort = new Serial(this, Serial.list()[portIndex], 115200);
  myPort.clear();
  println("Connecting to " + Serial.list()[portIndex]);
  myPort.write('S');
}
