import oscP5.*;
import netP5.*;
long msg_sent = 0;

// -------------------------------------------------------------------
// Envoie d'un message OSC
// -------------------------------------------------------------------
void oscSend(OscP5 remote, NetAddress address, OscMessage msg) {
    /* send the message */
     int val = msg.get(0).intValue();
     print("\nSending "+msg.addrPattern(), val);
     StatusLineOsc = "\nSending "+ msg.addrPattern() + "/" + val;
    remote.send(msg, address); 
    msg_sent++;
}

// -------------------------------------------------------------------
// Callback du listener OSC local (utile pour le débug)
// incoming osc message are forwarded to the oscEvent method.
// -------------------------------------------------------------------
void oscEvent(OscMessage theOscMessage) {
  //theOscMessage.print();
  StatusLineNbOsc ="\nSent OSC messages : " + msg_sent;
}

