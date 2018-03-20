int ptsW, ptsH;

PImage tex;
PImage bump;

int numPointsW;
int numPointsH_2pi; 
int numPointsH;

float[] coorX;
float[] coorY;
float[] coorZ;
float[] multXZ;

float rot = 0, rotX = 0, rotY = 0;
float drawRad = 10;
int drawOp  = 20;

boolean keyDown = false;

float lTween = 3.49;
float uTween = 3.15;

PShape moonTexBump;

void setup() {
  size(800, 600, P3D);

  noStroke();
  bump=loadImage("bump.png");
  tex=loadImage("moon.png");

  ptsW=650;
  ptsH=650;
  // Parameters below are the number of vertices around the width and height
  initializeSphere(ptsW, ptsH);
  createTextureBumpSphere(200, tex, bump, lTween, uTween);
}


void keyPressed() {
  keyDown = true;
}
void keyReleased() {
  keyDown = false;
}

void mouseDragged() {
  float xd = pmouseX - mouseX;
  float yd = pmouseY - mouseY;
  rotX += -xd/300.0;
  rotY += yd/300.0;
}

void hud() {
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  fill(255);
  int y = -5, yS = 15;
  text("lowerTween(1/2):"+ nf(lTween, 0, 2) + " upperTween(3/4):" + nf(uTween, 0, 2), 10, y+=yS);
  text("rotate wasd", 10, y+=yS);
  text("fps " + (int)frameRate, 10, y+=yS);
}

void keyHandle() {
  if (keyDown) {
    if (key == 'a') rotX += 0.01;
    if (key == 'w') rotY += 0.01;
    if (key == 'd') rotX -= 0.01;
    if (key == 's') rotY -= 0.01;

    boolean reShape = false;
    if (key == '1') {
      lTween -= 0.01;  
      reShape = true;
    }
    if (key == '2') {
      lTween += 0.01; 
      reShape = true;
    }
    if (key == '3') {
      uTween -= 0.01; 
      reShape = true;
    }
    if (key == '4') {
      uTween += 0.01; 
      reShape = true;
    }

    if (reShape) createTextureBumpSphere(200, tex, bump, lTween, uTween);
    drawOp = constrain(drawOp, 1, 255);
  }
}

void draw() {
  keyHandle();

  background(0);
  hud();
  lights();
  camera(
    width/2+map(0, 0, width, -2*width, 2*width), 
    height/2+map(0, 0, height, -height, height), 
    height/2/tan(PI*30.0 / 180.0), 
    width, height/2.0, 0, 
    0, 1, 0);
  pushMatrix();
  translate(width/2, height/2, 0); 
  rotateY(rotX);
  rotateX(rotY);


  shape(moonTexBump);
  popMatrix();
}

void initializeSphere(int numPtsW, int numPtsH_2pi) {
  // The number of points around the width and height
  numPointsW=numPtsW+1;
  numPointsH_2pi=numPtsH_2pi;  // How many actual pts around the sphere (not just from top to bottom)
  numPointsH=ceil((float)numPointsH_2pi/2)+1;  // How many pts from top to bottom (abs(....) b/c of the possibility of an odd numPointsH_2pi)

  coorX=new float[numPointsW];   // All the x-coor in a horizontal circle radius 1
  coorY=new float[numPointsH];   // All the y-coor in a vertical circle radius 1
  coorZ=new float[numPointsW];   // All the z-coor in a horizontal circle radius 1
  multXZ=new float[numPointsH];  // The radius of each horizontal circle (that you will multiply with coorX and coorZ)

  for (int i=0; i<numPointsW; i++) {  // For all the points around the width
    float thetaW=i*2*PI/(numPointsW-1);
    coorX[i]=sin(thetaW);
    coorZ[i]=cos(thetaW);
  }
  for (int i=0; i<numPointsH; i++) {  // For all points from top to bottom
    if (int(numPointsH_2pi/2) != (float)numPointsH_2pi/2 && i==numPointsH-1) {  // If the numPointsH_2pi is odd and it is at the last pt
      float thetaH=(i-1)*2*PI/(numPointsH_2pi);
      coorY[i]=cos(PI+thetaH); 
      multXZ[i]=0;
    } else {
      //The numPointsH_2pi and 2 below allows there to be a flat bottom if the numPointsH is odd
      float thetaH=i*2*PI/(numPointsH_2pi);

      //PI+ below makes the top always the point instead of the bottom.
      coorY[i]=cos(PI+thetaH); 
      multXZ[i]=sin(thetaH);
    }
  }
}



void createTextureBumpSphere(float rx, PImage tex, PImage bump, float lowerTween, float upperTween) { 
  moonTexBump = createShape();
  // These are so we can map certain parts of the image on to the shape 
  float changeU=tex.width/(float)(numPointsW); //-1
  float changeV=tex.height/(float)(numPointsH); //-1
  float u=0;  // Width variable for the texture
  float v=0;  // Height variable for the texture


  moonTexBump.beginShape(TRIANGLE_STRIP);
  moonTexBump.texture(tex);
  for (int i=0; i<(numPointsH-1); i++) {  // For all the rings but top and bottom
    // Goes into the array here instead of loop to save time
    float coory=coorY[i];
    float cooryPlus=coorY[i+1];
    float multxz=multXZ[i];
    float multxzPlus=multXZ[i+1];
    float rad;
    for (int j=0; j<numPointsW; j++) { // For all the pts in the ring
      rad = rx *  map( brightness(bump.get((int)u, (int)v)), 0, 255, lowerTween, upperTween);
      moonTexBump.normal(-coorX[j]*multxz, -coory, -coorZ[j]*multxz);
      moonTexBump.vertex(coorX[j]*multxz*rad, coory*rad, coorZ[j]*multxz*rad, u, v);

      rad = rx *  map( brightness(bump.get((int)u, (int)(v+1.0*changeV))), 0, 255, lowerTween, upperTween);
      moonTexBump.normal(-coorX[j]*multxzPlus, -cooryPlus, -coorZ[j]*multxzPlus);
      moonTexBump.vertex(coorX[j]*multxzPlus*rad, cooryPlus*rad, coorZ[j]*multxzPlus*rad, u, v+changeV);
      u+=changeU;
    }
    v+=changeV;
    u=0;
  }
  moonTexBump.endShape();
}