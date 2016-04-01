import java.util.Map;

OscP5 viewer3D;
OscP5 diffServer;
NetAddress viewer3DRemoteLocation;
NetAddress diffServerRemoteLocation;

String precedentMove = "";
int current_state_index = 0;
int precendent_state_index = 0;
int val = 0;
int lastDepth = 300;

String resolumeLayer = "layer3";
String resolumePrefix = "video";
String resolumeAction = "";

void smartTableSetup() {
  oscSetup();
  oscObjectsSetup();
  setState("OUT", 0);
}

private void oscObjectsSetup() {
  // Setup du listener du viewer
  viewer3D = new OscP5(this,OSC_LISTENER_VIEWER_PORT);
  viewer3DRemoteLocation = new NetAddress(OSC_LISTENER_VIEWER_ADDR,OSC_LISTENER_VIEWER_PORT);
  // Setup du listener de diffusion
  diffServer = new OscP5(this,OSC_LISTENER_DIFFUSION_PORT);
  diffServerRemoteLocation = new NetAddress(OSC_LISTENER_DIFFUSION_ADDR,OSC_LISTENER_DIFFUSION_PORT);
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
  // transformer tous les "OUT" en "STOP" car OUT est un mot réservé dans le viewer.
  if (move == "OUT") {
    move = "STOP";
  }
  val = 1;
  if (precedentMove != move && move != "") {
    OscMessage gestureMsg = new OscMessage("/" + addressPattern + "/" + move.toLowerCase());
    gestureMsg.add(val); /* add an int to the osc message */
    // Envoie du message OSC au viewer3D
    oscSend(viewer3D, viewer3DRemoteLocation, gestureMsg);
    precedentMove = move;
  }
  
  // Envoyer aussi la profondeur
  if (lastDepth != z && z <= 300) {
    OscMessage depthMsg = new OscMessage("/" + addressPattern + "/depth");
    depthMsg.add(z); /* add an int to the osc message */
    oscSend(viewer3D, viewer3DRemoteLocation, depthMsg);
    lastDepth = z;
  }
}

// Pilotage des objets 3D
void diffServerTransfert(String addressPattern, String move) {
  // Interpréter ici les mouvements pour Resolume
   if (move == "LEFT" ) {
      resolumeAction = "direction";
      val = 0;
   }
   if (move == "RIGHT" ) {
      resolumeAction = "direction";
      val = 1;
   }
   if (move == "UP" ) {
      resolumeAction = "col";
      val = 1;
   }
   if (move == "DOWN" ) {
      resolumeAction = "col";
      val = 0;
   }
  if (precedentMove != move && move != "") {
    /* in the following different ways of creating osc messages are shown by example */
    OscMessage gestureMsg = new OscMessage("/" + addressPattern + "/" + resolumeLayer +  "/" + resolumePrefix + "/" + resolumeAction);
    gestureMsg.add(val); /* add an int to the osc message */
    // Envoie du message OSC au viewer3D
    oscSend(diffServer, diffServerRemoteLocation, gestureMsg);
    precedentMove = move;
  } 
}

// Faire évoluer l'état de la navigation dans les 3 scénarii
void setState(String move, int idx) {
  precendent_state_index = current_state_index;
  current_state_index = idx;
  println("Mode : " + prez[current_state_index]);
  precedentMove = move;
  StatusLineMode = "\nMode : " + prez[current_state_index];
}

// Voir comment il faut envoyer les messages osc et à qui ?
// Sur "TurnR" 
// on passe du mode 1 au mode 2.
// Sur "TurnL" on passe du mode 2 au mode 1.
// Sur un timeout On retour à la présentation (mode 0)
void decideWhatToDo(String move) {
  // Si on a un timeout, on revient au mode d'attent (mode 0, présentation)
  if(millis() - lastMoveTime >= returnTimeout && (current_state_index != 0)) {
    setState(move, 0);
  }
  // Le mouvement IN interrompt la présentation (mode 0) pour passer au mode 1
  // TurnL : le mode prcédent 2 -> 1
  if (
      (move == "IN" && current_state_index == 0) || 
     (move == "TurnL" && current_state_index == 2)
     ) {
    setState(move, 1);
  }
  // TurnR le mode suivant 1 -> 2
  if (move == "TurnR" && current_state_index == 1) {
    setState(move, 2);
  }

  // Rediriger sur le bon mode.
  switch(current_state_index) {
  case 0: // "PRESENTATION":
    break;
  case 1: //"VISITEVIRTUELLE":
    String skippedMoveVV[] = { "IN", "TurnR", "TurnL", "PUSH" };
    viewer3DTransfert("cam", filterGesture(move, skippedMoveVV));
    break;
  case 2: //"OBJETS3D":
    String skippedMove3D[] = { "IN", "OUT", "TurnR", "TurnL", "PUSH" };
    diffServerTransfert(resolumePrefix, filterGesture(move, skippedMove3D));
    break;
  }
}
