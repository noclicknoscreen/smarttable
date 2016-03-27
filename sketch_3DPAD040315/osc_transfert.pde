import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

String precedentMove = "";
int val = 0;

void oscSetup() {
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress("192.168.43.50",12000);
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //print("### received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  theOscMessage.print();
  //print(" data: "+theOscMessage[0]);
  //println(" typetag: "+theOscMessage.typetag());
}

void osc_transfert(String move) {
  if (precedentMove != move) {
    /* in the following different ways of creating osc messages are shown by example */
    OscMessage myMessage = new OscMessage("/gest/" + move.toLowerCase());
    // Init value with 0 or 1.
    if (move == "OUT") {
        val = 0;
    }
    else {
      val = 1;
    }
    // if move is a "Turn", modify value with index 
    if (move == "TurnR") {
        val = turnR;
        precedentMove = "TurnL"; 
    }
    if (move == "TurnL") {
        val = turnL;
        precedentMove = "TurnR";
    }
    myMessage.add(val); /* add an int to the osc message */
    myMessage.print();
  
    /* send the message */
    oscP5.send(myMessage, myRemoteLocation); 

    precedentMove = move;
  } 
}
