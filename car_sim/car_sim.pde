Car test;

float seconds_per_frame = 1/60.0;
float pixels_per_meter = 4.705;

void setup() {
  size(1280, 740, P2D);
  test = new Car();
  //pixelDensity(2);
  test.set_init_position(new PVector(0,32)).set_init_orientation(PI/2);
}

void draw() {
  test.timestep(seconds_per_frame);
  background(255);
  pushMatrix();
  translate(width/2, height/2);
  test.display_car(pixels_per_meter);
  popMatrix();
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
  if (key == '=' || key == '+'){
    pixels_per_meter += 1;
  }
  if (key == '-' || key == '_'){
    pixels_per_meter -= 1;
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
