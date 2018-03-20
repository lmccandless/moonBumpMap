import java.awt.Color;
PImage imgHSV;
PImage imgBW; 

PGraphics work;
void setup() {
  size(640, 480, P2D);
  imgHSV = loadImage("moonElv.png");
  imgHSV.loadPixels();
  work = createGraphics(imgHSV.width, imgHSV.height, P2D);
}

//boolean f = false;
float off =  0.365;//mouseX/float(width);
void draw() {
  println(off);
  hsvToBW();
  println("saved");
  exit();
}

int rollOver(float k) {
  float g = k - off;
  if (g < 0.0) g += 1.0;
  return int(255*g);
}

void hsvToBW() {
  imgBW = createImage(imgHSV.width, imgHSV.height, RGB);
  imgHSV.loadPixels();

  for (int i = 0; i < imgHSV.pixels.length; i++) {
    color hsv = imgHSV.pixels[i];
    float hsba[] = new float[4];
    Color.RGBtoHSB((int)(255-red(hsv)), (int) (255-green(hsv)), (int)(255-blue(hsv)), hsba);
    imgBW.pixels[i] = color(rollOver(hsba[0]));
    background(off*255);
  }

  imgBW.loadPixels();
  work.beginDraw();
  work.image(imgBW, 0, 0);
  work.endDraw();
  work.save("bump.png");
  image(work, 0, 0);
}