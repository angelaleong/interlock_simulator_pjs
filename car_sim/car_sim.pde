World w;
RailroadCar test;
Road main;

int buttonX, buttonY; // position of play button
int buttonSize = 50;
color buttonColor, mouseoverButtonColor;
color currentColor;
boolean buttonOver = false;
boolean paused = false;

float seconds_per_frame = 1/90.0;
float pixels_per_meter = 6.705;

ArrayList<Car> all_cars = new ArrayList<Car>();
ArrayList<Road> all_roads = new ArrayList<Road>();

void setup() {
  size(1280, 740, P2D);
  mouseoverButtonColor = color(255);
  buttonColor = color(100);
  currentColor = buttonColor;
  buttonX = width-100;
  buttonY = height-100;
  pixelDensity(2);

  // TODO: Set up display of ego car's aggregate probability of collision
  start();

  // turn off aliasing
  noSmooth();
}

void start() {
  all_cars.clear();
  // separating start from setup so that we can
  // restart simulation upon collision
  if (args != null) {
    String r_name = "";
    int num_lanes = 5;
    float start_x = -90;
    float start_y = 0;
    float end_x = 90;
    float end_y = 0;
    float lane_w = 5;
    
    String name = "";
    int which_lane = 0;
    float offset = 0;
    float speed = 0;
    float accel = 0;
    
    Road road = new Road(num_lanes, new PVector(start_x, start_y), new PVector(end_x, end_y), lane_w);
    int new_road_start_index = 0;
    int cars_start_index = 0;
    
    for (int i = 0; i < args.length; i++) {
      if (args[i].length() > 2 && args[i].substring(0, 2).equals("-r")) {
        new_road_start_index = i;
        r_name = args[i].substring(1);
        continue;
      }
      int j = i - new_road_start_index;
      if (j < 7) {
        switch (j) {
          case 1:
            num_lanes = Integer.parseInt(args[i]);
            break;
          case 2:
            start_x = Float.parseFloat(args[i]);
            break;
          case 3:
            start_y = Float.parseFloat(args[i]);
            break;
          case 4:
            end_x = Float.parseFloat(args[i]);
            break;
          case 5:
            end_y = Float.parseFloat(args[i]);
            break;
          case 6:
            lane_w = Float.parseFloat(args[i]);
            road = new Road(num_lanes, new PVector(start_x, start_y), new PVector(end_x, end_y), lane_w);
            if (i/7 == 0) {
              main = road;
            }
            all_roads.add(road);
            break;
        }
      } else if (j == 7) {
        cars_start_index = i;
      } else {
        int c_index = (i - cars_start_index) % 5;
        switch (c_index) {
          case 0:
            name = args[i];
            break;
          case 1:
            which_lane = Integer.parseInt(args[i]);
            break;
          case 2:
            offset = Float.parseFloat(args[i]);
            break;
          case 3:
            speed = Float.parseFloat(args[i]);
            break;
          case 4:
            accel = Float.parseFloat(args[i]);
            if (i == 11) { // first entry must be the ego car
              test = new RailroadCar(road, which_lane, offset, 0);
              test.set_init_speed(speed);
              test.set_init_accel(accel);
              test.set_color(color(0, 255, 0));
            } else {
              Car other = new RailroadCar(road, which_lane, offset, 1);
              other.set_name(name);
              other.set_init_speed(speed);
              other.set_init_accel(accel);
              all_cars.add(other);
            }
        }
      }
    }
  } else {
    System.out.println("args == null"); 
  }

  w = new World(width, height);
  w.coordinate_offset(width/2, height/2);
  w.add_car(test);
  for (Car c : all_cars) {
    w.add_car(c);
  }

  test.set_lidar();
  test.controller_on();
  
  set_up_prob(all_cars);
}

void set_up_prob(ArrayList<Car> other_cars) {
  // HashMap {x : y} where x = probability of decelerating at y, y = % of MAX_DECEL
  HashMap<Float, Float> front_car_pt = new HashMap<Float, Float>();
  front_car_pt.put(0.05, 1.0);
  front_car_pt.put(0.1, 0.75);
  front_car_pt.put(0.2, 0.5);
  front_car_pt.put(0.65, 0.0);
  other_cars.get(0).set_prob_table(front_car_pt);
}

void draw() {
  update(mouseX, mouseY);
  background(250);

  // draw play/pause button
  stroke(0);
  currentColor = buttonOver ? mouseoverButtonColor : buttonColor;

  fill(currentColor);
  ellipse(buttonX, buttonY, buttonSize, buttonSize);

  fill(color(200));
  // check if the simulation is paused
  if (paused) {
    w.halt = true;
    triangle(buttonX-buttonSize/6, buttonY+buttonSize/4,
      buttonX-buttonSize/6, buttonY-buttonSize/4,
      buttonX+buttonSize/3.5, buttonY);
  } else {
    w.halt = false;
    rect(buttonX-1, buttonY, buttonSize/2.5, buttonSize/2.5);
  }

  // render world model
  w.timestep(seconds_per_frame);
  pushMatrix();
  translate(width/2, height/2);
  for (Road r : all_roads) {
    r.draw_road();
  }

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
    test.accelerate(-10);
  }
  if (key == '=' || key == '+') {
    pixels_per_meter += 1;
  }
  if (key == '-' || key == '_') {
    pixels_per_meter -= 1;
  }
  if (key == 'k') {
    for (Car car : all_cars) {
      car.accelerate(-10); // TODO: map different keys to different % of MAX_DECEL
    }
  }
  if (key == '1' || key == '2' || key == '3' || key == '4' || key == '5'){
    test.cur_lane = main.lanes.get(key-49);
  }
  if (key == 'l') {
    test.toggle_lidar();
  } 
}

// MANUAL STEERING
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
