// -------------------------------------------------------------------
// Fonctions de calcul des coordonnées issues du 3D pad
// -------------------------------------------------------------------
int x, y;
int z=300;
int dynX, dynY, dynZ;
int turnL, turnR;
int rawx, rawy, rawz;
int rawDynX;

// -------------------------------------------------------------------
//  coordonnées x,y,z zt nb de tours, et composantes x/y du mouvement
// -------------------------------------------------------------------
void calculateCoord() {
           
      rawx = int(rawValues.substring(20, 24));
      rawy = int(rawValues.substring(25, 29));
      rawz = int(rawValues.substring(30, 34));
      rawDynX = int(rawValues.substring(35, 39));
      int rawDynY = int(rawValues.substring(40, 44));
      int rawDynZ = int(rawValues.substring(45, 49));
      
      x = rawx*width/100;
      y = (100-rawy)*height/100;
      z = rawz;
      
      dynX = rawDynX*width/100;
      dynY = (100-rawDynY)*height/100;
      dynZ = rawDynZ;
      
      turnL = int(rawValues.substring(50, 54));
      turnR = int(rawValues.substring(55, 59));
}
