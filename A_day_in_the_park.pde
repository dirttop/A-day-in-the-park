ArrayList<Leaf> pile = new ArrayList<Leaf>();
ArrayList<Rain> storm = new ArrayList<Rain>();
//array lists

Button wind, noGrav, rain, magnet;
//buttons

boolean windSwitch, rainSwitch, noGravSwitch, magSwitch, reset;

float floodX, treeX, treeY, stretch, tree2X, tree2Y, stretch2;

int topc, black;

float fraction, mouseLocation;

PImage tree1, tree2;

void setup() {
  size(1000, 800);

  //sets all booleans false
  windSwitch = false;
  noGravSwitch = false;
  rainSwitch = false;
  reset = false;

  //sets the position and size of the trees
  treeX = random(1, 1000);
  tree2X = random(1, 1000);
  treeY = 550;
  tree2Y = 600;
  stretch = 400;
  stretch2 = 400;

  //loads the trees
  tree1 = loadImage("tree1.png");
  tree2 = loadImage("tree2.png");

  //creates buttons
  wind = new Button(850, 100, "WIND");
  noGrav = new Button(850, 150, "NO GRAV");
  rain = new Button(850, 200, "RAIN");
  magnet = new Button(850, 250, "MAGNET");

  //creates new objects in the array
  for (int i = 0; i  < 15; i++) {
    pile.add(new Leaf());
  }
  for (int i = 0; i  < 100; i++) {
    storm.add(new Rain());
  }
}

void draw() {
  background(173, 216, 230);

  //since magnet messes with the position of the objects, the array gets reset when turning off magnet.
  if (reset == true) {
    storm.clear();
    pile.clear();
    for (int i = 0; i  < 15; i++) {
      pile.add(new Leaf());
    }
    for (int i = 0; i  < 100; i++) {
      storm.add(new Rain());
    }
    reset = false;
  }

  //code for stretching the trees, not all that realistic just thought it would be cool to try.
  if (noGravSwitch == true) {
    stretch = 600; 
    treeY = 500;
    stretch2 = 600; 
    tree2Y = 510;
  } else {
    stretch = 400; 
    treeY = 590;
    stretch2 = 400; 
    tree2Y = 600;
  }

  //creates the trees, would be more efficient as a class and an array.
  imageMode(CENTER);
  image(tree1, treeX, treeY, 500, stretch);
  image(tree2, tree2X, tree2Y, 500, stretch2);

  //creates the ground, ideally i would make a perlin noise ground, will add if resubmit.
  fill(210, 105, 30);
  rectMode(CENTER);
  rect(500, 790, 1000, 20);

  //displays the buttons
  wind.Display();
  noGrav.Display();
  rain.Display();
  magnet.Display();

  // Applying force for the leaves
  for (Leaf l : pile) {
    PVector gravity = new PVector(0, 1).setMag(l.mass*1); 
    PVector noGravity = new PVector(0, -1).setMag(l.mass*1);
    PVector windForce = new PVector(1, 0).setMag(l.mass*1);
    PVector lift = new PVector(0, -1).setMag(l.mass * l.mass * 0.13);
    //creates a new PVector for the mouse location
    PVector magnet = new PVector(mouseX, mouseY);
    //subtracts the location vector from the mouse location vector.
    PVector magnetForce = PVector.sub(magnet, l.location);

    l.applyForce(gravity);
    l.Move();
    l.Display();

    if (windSwitch == true) {
      l.applyForce(windForce);
      l.applyForce(lift);
    }
    //changes forces applied based on what is on/off
    if (rainSwitch == false && noGravSwitch == true) {
      l.applyForce(noGravity);
      l.applyForce(lift);
    }
    if (rainSwitch == true && noGravSwitch == false) {
      l.applyForce(windForce);
    }
    if (rainSwitch == true && noGravSwitch == true) {
      l.applyForce(noGravity);
      l.applyForce(lift);
    }
    if (magSwitch == true) {
      l.applyForce(magnetForce);
    }
  }
  //Applying force for the raindrops
  for (Rain r : storm) {
    PVector gravity = new PVector(0, 1).setMag(r.mass*1);
    PVector noGravity = new PVector(0, -1).setMag(r.mass*1);
    PVector windForce = new PVector(1, 0).setMag(r.mass*1);
    PVector lift = new PVector(0, -1).setMag(r.mass * r.mass * 0.13);
    PVector magnet = new PVector(mouseX, mouseY);
    PVector magnetForce = PVector.sub(magnet, r.location);
    if (rainSwitch == true) {
      r.applyForce(gravity);
      r.Display();
      r.Move();
    }
    if (windSwitch == true) {
      r.applyForce(windForce);
    }
    if (noGravSwitch == true) {
      r.applyForce(noGravity);
      r.applyForce(lift);
    }
    if (magSwitch == true) {
      r.applyForce(magnetForce);
    }
  }
  //creates the "stream" produced by the rain NOTE: THIS DID NOT WORK
  if (rainSwitch == true && noGravSwitch == false) {
    fill(0, 0, 200, 140); 
    rectMode(CENTER);
    noStroke();
    rect(0, 785, floodX, 30);
    for (int i = 0; i  < 2000; i++) {
      floodX = i;
    }
  }
}

void mousePressed() {
  
  //This is all button collision detection
  
  if (mouseX>wind.x-50 && mouseX<wind.x+50 && mouseY>wind.y-20 && mouseY<wind.y+20) {
    windSwitch = !windSwitch;
  }
  if (mouseX>noGrav.x-50 && mouseX<noGrav.x+50 && mouseY>noGrav.y-20 && mouseY<noGrav.y+20) {
    noGravSwitch = !noGravSwitch;
  }
  if (mouseX>rain.x-50 && mouseX<rain.x+50 && mouseY>rain.y-20 && mouseY<rain.y+20) {
    rainSwitch = !rainSwitch;
  }
  if (mouseX>magnet.x-50 && mouseX<magnet.x+50 && mouseY>magnet.y-20 && mouseY<magnet.y+20) {
    magSwitch = !magSwitch;
    reset = true;
    //resets after switch
  }
}

class Leaf {
  PVector location, velocity, acceleration;
  float mass;
  color c;
  //Leaf Constructer
  Leaf() {
    mass = 8+random(0, 5);
    //sets the mass
    c = color(0, 128+random(0, 120), 0);
    location = new PVector(random(width), random(height));
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }
  void Move() {
    velocity.add(acceleration);
    //limits how fast the leaves can fall
    velocity.limit(3);
    if (location.y > height-20) {
      location.y = height-20;
      println(location.y);
    }
    location.add(velocity);
    acceleration.setMag(0);
    if (location.x>width) {
      location.x = 0;
    }
  }
  void Display() {
    fill(c);
    noStroke();
    ellipse(location.x, location.y, 40+mass, mass);
    //size changes based on mass
  }
  void applyForce(PVector f) {
    acceleration.add(f.copy().div(mass));
  }
}

class Rain {
  PVector location, velocity, acceleration;
  float mass;
  color c;
  Rain() {
    mass = 1+random(0, 3);
    c = color(0, 0, 120+random(0, 120));
    location = new PVector(random(width), random(height));
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
  }
  void Move() {
    velocity.add(acceleration);
    velocity.limit(9);
    location.add(velocity);
    acceleration.setMag(0);
    if (location.x>width) {
      location.x = 0;
    }
    if (location.y>height) {
      location.y = 0;
    }
  }
  void Display() {
    fill(c);
    noStroke();
    ellipse(location.x, location.y, mass, mass);
  }
  void applyForce(PVector f) {
    acceleration.add(f.copy().div(mass));
  }
}

//class Ground {
//  Ground() { 
//  }
//  void Display() {
//    }
//} 

//sets the parameters for the buttons
class Button {
  color c;
  float x, y;
  String name;
  Button(float _x, float _y, String _name) {
    c = color(50);
    x = _x;
    y = _y;
    name = _name;
  }
  void Display() {
    fill(c);
    noStroke();
    rectMode(CENTER);
    rect(x, y, 100, 40);
    fill(0);   
    textSize(20);
    textAlign(CENTER, CENTER);
    text(name, x, y-2.5);
  }
}
