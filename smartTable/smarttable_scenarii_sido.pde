import java.util.Map;

OscP5 viewer3D;
OscP5 diffServer;
OscP5 diffServerBackMsg;
NetAddress viewer3DRemoteLocation;
NetAddress diffServerRemoteLocation;
NetAddress diffServerBackMsgRemoteLocation;

String precedentMove = "";
int current_state_index = 0;
int precedent_state_index = 0;
int val = 0;
int lastDepth = 300;
int clipIndex = 1;

// -------------------------------------------------------------------
// Setup des scenarii smarttable
// appelé par le setup général de processing
// -------------------------------------------------------------------
void smartTableSetup() {
  oscObjectsSetup();
  setState("OUT", 0);
  resolumeSend("/layer1/video/opacity/values", 0.0);
  resolumeSend("/layer2/video/opacity/values", 0.0);
  resolumeSend("/layer3/video/opacity/values", 1.0);
  resolumeSend("layer3/select", 1);
  
}

// -------------------------------------------------------------------
// Déclaration des objets OSC
// -------------------------------------------------------------------
private void oscObjectsSetup() {
  // Setup du listener du viewer
  viewer3D = new OscP5(this,OSC_LISTENER_VIEWER_PORT);
  viewer3DRemoteLocation = new NetAddress(OSC_LISTENER_VIEWER_ADDR,OSC_LISTENER_VIEWER_PORT);
  // Setup du listener de diffusion
  diffServer = new OscP5(this,OSC_LISTENER_DIFFUSION_PORT);
  diffServerRemoteLocation = new NetAddress(OSC_LISTENER_DIFFUSION_ADDR,OSC_LISTENER_DIFFUSION_PORT);
  // Ecouter les messages de retour su serveur Resolume.
  diffServerBackMsg = new OscP5(this,OSC_LOCALHOST_PORT);
  diffServerBackMsgRemoteLocation = new NetAddress(OSC_LOCALHOST_ADDR,OSC_LOCALHOST_PORT);
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

// -------------------------------------------------------------------
// Pilotage du viewer Visite virtuelle
// -------------------------------------------------------------------
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
// -------------------------------------------------------------------
// Pilotage des objets 3D
// -------------------------------------------------------------------
void resolumeSend(String addressPattern, int value) {
    /* in the following different ways of creating osc messages are shown by example */
    OscMessage gestureMsg = new OscMessage("/" + addressPattern);
    gestureMsg.add(value); /* add an int to the osc message */
    // Envoie du message OSC au viewer3D
    oscSend(diffServer, diffServerRemoteLocation, gestureMsg);
}

void resolumeSend(String addressPattern, float value) {
    /* in the following different ways of creating osc messages are shown by example */
    OscMessage gestureMsg = new OscMessage("/" + addressPattern);
    gestureMsg.add(value); /* add an int to the osc message */
    // Envoie du message OSC au viewer3D
    oscSend(diffServer, diffServerRemoteLocation, gestureMsg);  
}

void resolumeChangeOpacity() {
  // /layer1/video/opacity/values 0.0 1.0
  println("/layer"+ (current_state_index+1) +"/video/opacity/values 1.0");
  resolumeSend("/layer"+ (current_state_index+1) +"/video/opacity/values", 1.0);
  resolumeSend("/layer" + (precedent_state_index+1) + "/video/opacity/values", 0.0);
//    for (float f = 0.0; f <= 1.0; f+=0.05) {
//      println("/layer"+ (current_state_index+1) +"/video/opacity/values "+f);
//      resolumeSend("/layer"+ (current_state_index+1) +"/video/opacity/values", f);
//      resolumeSend("/layer" + (precedent_state_index+1) + "/video/opacity/values", 1.0-f);
////      resolumeSend("/activelayer/video/opacity/values", f);
//      delay(50);
//    }
}

// -------------------------------------------------------------------
// Gestion de l'état de la navigation dans les 3 scénarii
// -------------------------------------------------------------------
void setState(String move, int idx) {
  precedent_state_index = current_state_index;
  current_state_index = idx;
  precedentMove = move;
  StatusLineMode = "\nMode : " + prez[current_state_index];
  resolumeChangeOpacity();

}

// -------------------------------------------------------------------
// Controleur d'action en fonction de mouvements
//
// Voir comment il faut envoyer les messages osc et à qui ?
// Sur "TurnR" 
// on passe du mode 1 au mode 2.
// Sur "TurnL" on passe du mode 2 au mode 1.
// Sur un timeout On retour à la présentation (mode 0)
// -------------------------------------------------------------------
void smartTableController(String move) {

  // Si on a un timeout, on revient au mode d'attent (mode 0, présentation)
  if(millis() - lastMoveTime >= returnTimeout && (current_state_index != 0)) {
    if (precedent_state_index != current_state_index) {
      resolumeSend("layer3/select", 1);
      //resolumeOpacity();
    } 
    setState(move, 0);
  }
  // Le mouvement IN interrompt la présentation (mode 0) pour passer au mode 1
  // TurnL : le mode prcédent 2 -> 1
  if (
      (move == "IN" && current_state_index == 0) || 
     (move == "TurnL" && current_state_index == 2)
     ) {
    setState(move, 1);
    if (precedent_state_index != current_state_index) {
      resolumeSend("layer2/select", 1);
    } 
  }
  // TurnR le mode suivant 1 -> 2
  if (move == "TurnR" && current_state_index == 1) {
    setState(move, 2);
    // Piloter rasolume
    if (precedent_state_index != current_state_index) {
      resolumeSend("layer1/select", 1);
      resolumeSend("layer1/clip1/connect", 1);
      resolumeSend("layer1/clip1/preview", 1);
    } 
  }

  // Rediriger sur le bon mode.
  switch(current_state_index) {
  case 0: // "PRESENTATION":
    // rien à faire, ça défile tout seul
    break;
  case 1: //"VISITEVIRTUELLE":
    String skippedMoveVV[] = { "IN", "TurnR", "TurnL", "PUSH" };
    // Piloter le viewer
    viewer3DTransfert("cam", filterGesture(move, skippedMoveVV));
    break;
  case 2: //"OBJETS3D":
    //String skippedMove3D[] = { "IN", "OUT", "TurnR", "TurnL", "PUSH" };
   if (move == "UP" && precedentMove != move) {
      //clipIndex++;
      println("i="+clipIndex+ " / UP");
      resolumeSend("layer1/clip" + (clipIndex+1) + "/connect", 1);
      resolumeSend("layer1/clip" + (clipIndex+1) + "/preview", 1);
   }
   if (move == "DOWN" && precedentMove != move) {
      //clipIndex--;
      println("i="+clipIndex+ " / DOWN");
      resolumeSend("layer1/clip" + (clipIndex-1) + "/connect", 1);
      resolumeSend("layer1/clip" + (clipIndex-1) + "/preview", 1);
   }
   if (rawx < 50) {
     resolumeSend("activeclip/video/position/direction", 0);
   } else {
     resolumeSend("activeclip/video/position/direction", 1);
   }
   float velocity = map(abs(rawx-50)-10, 0, 40, 0.1, 1);
   resolumeSend("activeclip/video/position/speed", velocity);
   precedentMove = move;
   break;
  }
}
