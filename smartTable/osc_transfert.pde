import oscP5.*;
import netP5.*;
long msg_sent = 0;

void oscSetup() {
}

void oscSend(OscP5 remote, NetAddress address, OscMessage msg) {
    /* send the message */
    remote.send(msg, address); 
    msg_sent++;
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  theOscMessage.print();
  println("Sent OSC messages : ", msg_sent);
}

