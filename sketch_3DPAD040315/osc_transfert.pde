import oscP5.*;
import netP5.*;

void oscSetup() {
}

void oscSend(OscP5 remote, NetAddress address, OscMessage msg) {
    /* send the message */
    remote.send(msg, address); 
}


/* incoming osc message are forwarded to the oscEvent method. 
void oscEvent(OscMessage theOscMessage) {
  theOscMessage.print();
}

*/
