Car test;
Car stationary;
World w;


float seconds_per_frame = 1/60.0;
float pixels_per_meter = 4.705;

void setup() {
  size(1280, 740, P2D);
  test = new Car();
  test.set_init_position(new PVector(0, 32))
    .set_init_orientation(-PI/4)
    .set_name("test");

  stationary = new Car();
  stationary.set_init_position(new PVector(0, -8))
    .set_init_speed(0)
    .set_colour(color(0, 0, 255))
    .set_name("stationary");

  w = new World(width, height);
  w.coordinate_offset(width/2, height/2)
    .add_car(stationary)
    .add_car(test);

  // turn off aliasing
  noSmooth();
}

void draw() {
  w.timestep(seconds_per_frame);
  background(255);
  pushMatrix();
  translate(width/2, height/2);
  w.display_cars(pixels_per_meter);
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
  if (key == '=' || key == '+') {
    pixels_per_meter += 1;
  }
  if (key == '-' || key == '_') {
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
