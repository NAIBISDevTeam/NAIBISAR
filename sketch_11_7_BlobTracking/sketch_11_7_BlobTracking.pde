// Daniel Shiffman
// http://codingrainbow.com
// http://patreon.com/codingrainbow
// Code for: https://youtu.be/ce-2l2wRqO8

import processing.video.*;

Capture video;

color trackColor; 
float threshold = 20;
float distThreshold = 75;

ArrayList<Blob> blobs = new ArrayList<Blob>();

// Daniel Shiffman
// http://codingrainbow.com
// http://patreon.com/codingrainbow
// Code for: https://youtu.be/ce-2l2wRqO8
PImage img;


class Blob {
  float minx;
  float miny;
  float maxx;
  float maxy;

  Blob(float x, float y) {
    minx = x;
    miny = y;
    maxx = x;
    maxy = y;
  }

  void show() {
    stroke(0);
    fill(255);
    strokeWeight(2);
    rectMode(CORNERS);
    image(img, minx, miny, maxx - minx, maxy - miny);
  }

  void add(float x, float y) {
    minx = min(minx, x);
    miny = min(miny, y);
    maxx = max(maxx, x);
    maxy = max(maxy, y);
  }
  
  float size() {
    return (maxx-minx)*(maxy-miny); 
  }

  boolean isNear(float x, float y) {
    float cx = (minx + maxx) / 2;
    float cy = (miny + maxy) / 2;

    float d = distSq(cx, cy, x, y);
    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}

void setup() {
  size(640, 360);
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[3]);
  video.start();
  trackColor = color(180, 50, 25);
  img = loadImage("NAIBIS_Name.png");
}

void captureEvent(Capture video) {
  video.read();
}

void keyPressed() {
  if (key == 'a') {
    distThreshold++;
  } else if (key == 'z') {
    distThreshold--;
  }
  println(distThreshold);
}

void draw() {
  video.loadPixels();
  image(video, 0, 0);

  blobs.clear();

  //threshold = map(mouseX, 0, width, 0, 100);
  threshold = 80;

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d < threshold*threshold) {

        boolean found = false;
        for (Blob b : blobs) {
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }

        if (!found) {
          Blob b = new Blob(x, y);
          blobs.add(b);
        }
      }
    }
  }

  for (Blob b : blobs) {
    if (b.size() > 500) {
      b.show();
    }
  }
}


float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}


float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc];
}