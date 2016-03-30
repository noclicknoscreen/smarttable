OscP5 viewer3D;
OscP5 diffServer;
NetAddress viewer3DRemoteLocation;
NetAddress diffServerRemoteLocation;

String precedentMove = "";
int current_state_index = 0;
int precendent_state_index = 0;
int val = 0;
int lastMoveTime;
int lastDepth = 300;


void smartTableSetup() {
  oscObjectsSetup();
  current_state_index = 1;
  precendent_state_index = current_state_index;
  println("Mode : " + prez[current_state_index]);
}

private void oscObjectsSetup() {
  // Setup du listener du viewer
  viewer3D = new OscP5(this,OSC_LISTENER_VIEWER_PORT);
  viewer3DRemoteLocation = new NetAddress(OSC_LISTENER_VIEWER_ADDR,OSC_LISTENER_VIEWER_PORT);
  // Setup du listener de diffusion
  diffServer = new OscP5(this,OSC_LISTENER_DIFFUSION_PORT);
  diffServerRemoteLocation = new NetAddress(OSC_LISTENER_DIFFUSION_ADDR,OSC_LISTENER_DIFFUSION_PORT);
  lastMoveTime = millis();
}

// Fonction qui filtre les gestes
// Renvoie une chaine vide si le geste doit être filtré.
// Pfff... Need optimization ??
String filterGesture(String move, String[] skip) {
  for (int i=0; i<skip.length;i++) {
     if (skip[i] == move)  {
       precedentMove = move;
       return "";
     }
  }
  return move;
}

// Pilotage du viewer Visite virtuelle
void viewer3DTransfert(String addressPattern, String move) {
  val = 1;
  if (precedentMove != move && move != "") {
    OscMessage gestureMsg = new OscMessage("/" + addressPattern + "/" + move.toLowerCase());
    gestureMsg.add(val); /* add an int to the osc message */
    gestureMsg.print();
    // Envoie du message OSC au viewer3D
    oscSend(viewer3D, viewer3DRemoteLocation, gestureMsg);
    precedentMove = move;
    lastMoveTime = millis();
  }
  
  // Envoyer aussi la profondeur
  if (lastDepth != z) {
    OscMessage depthMsg = new OscMessage("/" + addressPattern + "/depth");
    depthMsg.add(z); /* add an int to the osc message */
    oscSend(viewer3D, viewer3DRemoteLocation, depthMsg);
    lastDepth = z;
  }
}

// Pilotage du viewer Visite virtuelle
void diffServerTransfert(String addressPattern, String move) {
  val = 1;
  if (precedentMove != move && move != "") {
    /* in the following different ways of creating osc messages are shown by example */
    OscMessage gestureMsg = new OscMessage("/" + addressPattern + "/" + move.toLowerCase());
    gestureMsg.add(val); /* add an int to the osc message */
    gestureMsg.print();
    // Envoie du message OSC au viewer3D
    oscSend(diffServer, diffServerRemoteLocation, gestureMsg);
    precedentMove = move;
    lastMoveTime = millis();
  } 
}

// Voir comment il faut envoyer les messages osc et à qui ?
// Sur "TurnR" on passe du mode 1 au mode 2.
// Sur "TurnL" on passe du mode 2 au mode 1.
// Sur un timeout On retour à la présentation (mode 0)
void decideWhatToDo(String move) {
  
  // On regarde si on a des TURNs pour changer de mode
  if (move == "TurnR" && current_state_index == 1) {
    precendent_state_index = current_state_index;
    current_state_index = 2;
    println("Mode : " + prez[current_state_index]);
  }
  if (move == "TurnL" && current_state_index == 2) {
    precendent_state_index = current_state_index;
    current_state_index = 1;
    println("Mode : " + prez[current_state_index]);
  }
//  // Si on a un timeout, on revient au mode d'attent (mode 0, présentation)
//  if(millis() - lastMoveTime >= returnTimeout) {
//  println("lastMoveTime=",lastMoveTime);
//    precendent_state_index = current_state_index;
//    current_state_index = 0;
//  }
  // transformer tous les "OUT" en "STOP" car OUT est un mot réservé dans le viewer.
  if (move == "OUT") {
    move = "STOP";
  }
  // Rediriger sur le bon mode.
  switch(current_state_index) {
  case 0: // "PRESENTATION":
    break;
  case 1: //"VISITEVIRTUELLE":
    String skippedMoveVV[] = { "IN", "OUT", "TurnR", "TurnL", "PUSH" };
    viewer3DTransfert("cam", filterGesture(move, skippedMoveVV));
    break;
  case 2: //"OBJETS3D":
    String skippedMove3D[] = { "IN", "OUT", "TurnR", "TurnL", "PUSH" };
    diffServerTransfert("3DObj", filterGesture(move, skippedMove3D));
    break;
  }
}
