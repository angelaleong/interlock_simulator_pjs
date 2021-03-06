Road road1;
Road road2;
Car test;
Car stationary;
Car single_lane_follower;
World w;

int buttonX, buttonY; // position of play button
int buttonSize = 50;
color buttonColor, pausedButtonColor;
color currentColor;
boolean buttonOver = false;
boolean paused = true;

float seconds_per_frame = 1/60.0;
float pixels_per_meter = 7; // 4.705

void setup() {
  size(1280, 740, P2D);
  buttonColor = color(255);
  pausedButtonColor = color(100);
  currentColor = pausedButtonColor;
  buttonX = width-100;
  buttonY = height-100;

  start();

  // turn off aliasing
  noSmooth();
}

void start() {
  // separating start from setup so that we can
  // restart simulation upon collision
  road1 = new Road(-70, 0, 100, 0, 8);
  road2 = new Road(0, 70, 0, -100, 8);

  test = new RailroadCar(road1, 0);
  test.set_colour(color(0, 255, 0))
    .set_name("test");

  stationary = new RailroadCar(road1, 70);
  stationary
    .set_init_speed(0)
    .set_colour(color(255, 0, 0))
    .set_name("stationary");

  //single_lane_follower = new SingleLaneFollower();
  //single_lane_follower.set_init_position(new PVector(-100, -8))
  //  .set_name("single_lane_follower")
  //  .set_colour(color(0, 255, 0));

  w = new World(width, height);
  w.coordinate_offset(width/2, height/2)
    .add_road(road1)
  //  .add_road(road2)
    .add_car(stationary)
    .add_car(test);
  //  .add_car(single_lane_follower);

  //single_lane_follower.set_front_car_pos(0);

  // turn off aliasing
  // noSmooth();
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
  w.timestep(seconds_per_frame);
  pushMatrix();
  translate(width/2, height/2);
  w.display_roads(pixels_per_meter);
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

void overButton(int x, int y, int d) {
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
  if (key == 'l') {
    single_lane_follower.accelerate(8);
  }
  if (key == 'k') {
    single_lane_follower.accelerate(-8);
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
  if (key == 'l') {
    test.accelerate(0);
  }
  if (key == 'k') {
    test.accelerate(0);
  }
}
