// -------------------------------------------------------------------
// SmartTable
// Strongly Inspired of 3DPAD DEMO SOFTWARE 
// Based on an original idea from www.ootsidebox.com
// -------------------------------------------------------------------
PFont Font;
String StatusLine;
String StatusLineOsc = "";
String StatusLineNbOsc = "";
String StatusLineMode = "";

// -------------------------------------------------------------------
// Setup Processing
// -------------------------------------------------------------------
void setup()
{
  size(600, 600);
  if (frame != null) frame.setResizable(true);
  Font = loadFont("ArialMT-24.vlw");
  textFont(Font);
  println("3Dpad> ");
  StatusLine= "3DPad> please CONNECT";
  setupControl();
  smartTableSetup();
} 

// -------------------------------------------------------------------
// Boucle Draw processing
// -------------------------------------------------------------------
void draw()
{
  background(0);
  noStroke();
//  fill(0, 255, 0);
//  if (z<250)
//   {
//    if (z > 40) ellipse(x, y, z, z);
//    else ellipse(x, y, 40, 40);
//    
//    fill(153);
//    ellipse(dynX, dynY, 10, 10);
//    
//    stroke(255);
//    line(dynX,dynY,x,dynY);
//    line(dynX,dynY,dynX,y);
//  }
  fill(255);
  text(StatusLine,10,80);
  fill(255,0,100);
  text(StatusLineMode,10,80);
  fill(255,100,0);
  text(StatusLineOsc,10,100);
  fill(0,255,100);
  text(StatusLineNbOsc,10,120);
  
  fill(124,190,47);
  text("clip" + clipIndex,10,170);

  // Controleur de la smarttable
  smartTableController(detectedMotion);
}

// -------------------------------------------------------------------
// gestion des entrée clavier
// -------------------------------------------------------------------
void keyPressed() 
{
  print("\n\rKeyboard -> "+key);
  print("\n\r");
  myPort.write(key);
}
