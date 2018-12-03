Car test;
Car stationary, s1, s2, s3;
World w;

int buttonX, buttonY; // position of play button
int buttonSize = 50;
color buttonColor, pausedButtonColor;
color currentColor;
boolean buttonOver = false;
boolean paused = true;

float seconds_per_frame = 1/90.0;
float pixels_per_meter = 6.705;

ArrayList<Car> all_cars = new ArrayList<Car>();
Road road = new Road(5, new PVector(-90, 0), new PVector(90, 0), 5);

void setup() {
  size(1280, 740, P2D);
  buttonColor = color(255);
  pausedButtonColor = color(100);
  currentColor = pausedButtonColor;
  buttonX = width-100;
  buttonY = height-100;
  pixelDensity(2);

  start();

  // turn off aliasing
  noSmooth();
}

void start() {
  all_cars.clear();
  // separating start from setup so that we can
  // restart simulation upon collision
  test = new RailroadCar(road, 5,0);
  //test.set_init_position(new PVector(-90, 0))
  //  .set_name("test")
  //  .set_init_speed(5);


  w = new World(width, height);
  w.coordinate_offset(width/2, height/2);
  w.add_car(test);
  for (Car c : all_cars) {
    w.add_car(c);
  }

  test.set_lidar();
  test.controller_on();
}

void draw() {
  update(mouseX, mouseY);
  background(250);

  // draw play/pause button
  stroke(0);
  if (buttonOver) {
    currentColor = paused ? buttonColor : pausedButtonColor;
  } else {
    currentColor = paused ? pausedButtonColor : buttonColor;
  }

  fill(currentColor);
  ellipse(buttonX, buttonY, buttonSize, buttonSize);

  fill(color(200));


  // check if the simulation is paused
  if (!paused) {
    w.halt = false;
    triangle(buttonX-buttonSize/4, buttonY+buttonSize/3,
      buttonX-buttonSize/4, buttonY-buttonSize/3,
      buttonX+buttonSize/3, buttonY);
  } else {
    w.halt = true;
    rect(buttonX-1, buttonY, buttonSize/2, buttonSize/2);
  }

  // render world model
  //fill(155);
  //noStroke();
  //rect(width/2, height/2, width, 60);
  w.timestep(seconds_per_frame);
  pushMatrix();
  translate(width/2, height/2);
  road.draw_road();

  stroke(0);
  w.display_cars(pixels_per_meter);
  popMatrix();
}

void update(int x, int y) {
  if (overButton(buttonX, buttonY, buttonSize)) {
    buttonOver = true;
  } else {
    buttonOver = false;
  }
}

void mousePressed() {
  if (buttonOver) {
    paused = !paused;
  } else {
    // click on anywhere to restart
    start();
  }
}

boolean overButton(int x, int y, int d) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < d/2) {
    return true;
  } else {
    return false;
  }
}

void keyPressed() {
  if (key == 'a') {
    test.keyboard_steering(-0.01);
  }
  if (key == 'd') {
    test.keyboard_steering(0.01);
  }
  if (key == 'w') {
    test.accelerate(8);
  }
  if (key == 's') {
    test.accelerate(-8);
  }
  if (key == '=' || key == '+') {
    pixels_per_meter += 1;
  }
  if (key == '-' || key == '_') {
    pixels_per_meter -= 1;
  }
  if (key == 'k') {
    for (Car car : all_cars) {
      car.accelerate(-8);
    }
  }
}

void keyReleased() {
  if (key == 'a' || key == 'd') {
    test.keyboard_steering(0);
  }
  if (key == 'w') {
    test.accelerate(0);
  }
  if (key == 's') {
    test.accelerate(0);
  }
}
