PFont fnt;                      // for font

void setup() {
    size(400, 200);                         // size of application window
    background(0);                          // black background
    fnt = createFont("Arial", 16, true);    // font displayed in window
    serialSetup();
}

void draw()
{
  background(0);
  if (!device_detected) {
    displayAutodetectionInstructions();
    serialDetection();
  }
  else {
    displayDetectedPort();
  }
}

void displayAutodetectionInstructions() {
    // display instructions to user
    textFont(fnt, 14);
    text("Please disconnect and reconnect Arduino...", 20, 30);
}

void displayDetectedPort() {
    // calculate and display serial port name
    if (device_detected) {
        text("Device detected:", 20, 110);
        textFont(fnt, 18);
        text(detected_port, 20, 150);
        delay(3000);
    }
}
