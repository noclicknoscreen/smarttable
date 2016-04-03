import oscP5.*;
import netP5.*;
long msg_sent = 0;

// -------------------------------------------------------------------
// Envoie d'un message OSC
// -------------------------------------------------------------------
void oscSend(OscP5 remote, NetAddress address, OscMessage msg) {
    /* send the message */
     //float val = float(msg.get(0).intValue());
     //StatusLineOsc = "\nSending "+ msg.addrPattern(); //+ "/" + val;
    //msg.print();
    remote.send(msg, address); 
    msg_sent++;
}

// -------------------------------------------------------------------
// Callback du listener OSC local (utile pour le débug)
// incoming osc message are forwarded to the oscEvent method.
// -------------------------------------------------------------------
void oscEvent(OscMessage theOscMessage) {
  int activeClipNumber;
  String s = theOscMessage.addrPattern();
  String list[] = split(s, "/");
  if (list != null) {
    // Le split nous met un élément vide dans list[0] du fait que l'adressePattern OSC commence par un '/'
    if (list[1].equals("layer1") && list[3].equals("connect")) {
      activeClipNumber = int(list[2].replace("clip", ""));
      clipIndex = activeClipNumber;
    }
    
  }
  StatusLineNbOsc ="\nReceived OSC messages : " + msg_sent;
}

