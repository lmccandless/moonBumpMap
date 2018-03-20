import java.awt.Color;
PImage bw;
PImage bq; 

PGraphics work;
void setup() {
  size(640, 480, P2D);
  //surface.setResizable(true);
  bw =loadImage("moonElv.png");
  bq =loadImage("moonElv.png");
  bw.loadPixels();
  bq.loadPixels();

work = createGraphics(bw.width,bw.height,P2D);

  /* for (int i = 0; i < bw.pixels.length; i++) {
   color hsv = bw.pixels[i];
   
   
   float hsba[] = new float[4];
   Color.RGBtoHSB((int)red(hsv),(int) green(hsv), (int)blue(hsv), hsba);
   
   
   bw.pixels[i] = color(hsba[0]*280);
   }*/
  //noLoop();
}

boolean f = false;
void draw() {
  hsvToBW();

  println("saved");
 // exit();
}

int rollOver(float k){
   float off = 0.01;
  float g = k - off;
  if (g < 0.0) g += 1.0;
  return int(255*g);
}

void hsvToBW() {
 // surface.setSize(bw.width, bw.height);
  bw = bq;
  bw.loadPixels();

  for (int i = 0; i < bw.pixels.length; i++) {
    color hsv = bw.pixels[i];


    float hsba[] = new float[4];
    Color.RGBtoHSB((int)(255-red(hsv)), (int) (255-green(hsv)), (int)(255-blue(hsv)), hsba);


    bw.pixels[i] = color(rollOver(hsba[0]));
  }

  work.beginDraw();
  work.image(bw,0,0);
  work.endDraw();
 // work.save("bump.png");
  image(work, 0, 0);

  // saveFrame("line-######.png");
}