World w;
RailroadCar test;
Road main;
//Car stationary, s1, s2, s3;

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
//Road road = new Road(5, new PVector(-90, 0), new PVector(90, 0), 5);
//Road road2 = new Road(3, new PVector(0, -90), new PVector(0, 90), 9);

//float sd_x;
//float sd_y;
//float alpha = 0.1; // TODO: test different values of alpha
//float h_c;

void setup() {
  size(1280, 740, P2D);
  mouseoverButtonColor = color(255);
  buttonColor = color(100);
  currentColor = buttonColor;
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
  //test = new RailroadCar(road, 0, 0, false);
  //test.set_colour(color(0, 255, 0));
  //test.cur_lane = road.lanes.get(2);
  //test.set_init_position(new PVector(-90, 0))
  //  .set_name("test")
  //  .set_init_speed(5);
  //s1 = new RailroadCar(road, 2, 50, true).set_init_speed(10);
  //s2 = new RailroadCar(road, 0, 40, false).set_init_speed(5);
  //s3 = new RailroadCar(road, 4, 30, true).set_init_speed(20);
  //all_cars.add(s1);
  //all_cars.add(s2);
  //all_cars.add(s3);
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
    
    //Road road = new Road(5, new PVector(-90, 0), new PVector(90, 0), 5);
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
            if (i == 11) { // first entry is the ego car
              test = new RailroadCar(road, which_lane, offset, true, true);
              test.set_init_speed(speed);
              test.set_init_accel(accel);
              test.set_colour(color(0, 255, 0));
            } else {
              Car other = new RailroadCar(road, which_lane, offset, true, false);
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
  
  //// calculate standard deviation of x and y positions
  //// TODO: verify that this sd calculation should not include ego car
  //ArrayList<Float> all_x_pos = new ArrayList<Float>();
  //ArrayList<Float> all_y_pos = new ArrayList<Float>();
  //for (Car c : all_cars) {
  //  all_x_pos.add(c.position.x);
  //  all_y_pos.add(c.position.y);
  //}
  //sd_x = calculateSD(all_x_pos);
  //sd_y = calculateSD(all_y_pos);
  
  //// calculate overall cost H (eq. 7 in Rus paper)
  //float h = 0;
  //for (Car c : all_cars) {
  //  PVector d_i = PVector.sub(test.position, c.position);
  //  // TODO: verify that I'm getting the x- and y-components of velocity correctly
  //  h += Math.exp(-Math.pow(d_i.x, 2)/Math.pow(sd_x, 2) - Math.pow(d_i.y, 2)/Math.pow(sd_y, 2))/
  //    (1 + Math.exp(-alpha*(d_i.x * c.speed*cos(c.orientation) + d_i.y * c.speed*sin(c.orientation))));
  //}
  //h_c = h;
  
  //// get planning threshold H_p
  //float h_p = 0.5*h;
}

//float calculateSD(ArrayList<Float> numArray)
//{
//    float sum = 0.0, standardDeviation = 0.0;
//    int length = numArray.size();

//    for(float num : numArray) {
//        sum += num;
//    }

//    float mean = sum/length;

//    for(float num: numArray) {
//        standardDeviation += Math.pow(num - mean, 2);
//    }

//    return (float) Math.sqrt(standardDeviation/length);
//}

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
  //fill(155);
  //noStroke();
  //rect(width/2, height/2, width, 60);
  w.timestep(seconds_per_frame);
  pushMatrix();
  translate(width/2, height/2);
  for (Road r : all_roads) {
    r.draw_road();
  }
  //road.draw_road();
  //road2.draw_road();

  stroke(0);
  w.display_cars(pixels_per_meter);
  //w.display_contours(all_cars, road, sd_x, sd_y, alpha, h_c); // an attempt at drawing contours per the Rus paper
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
  if (key == '1' || key == '2' || key == '3' || key == '4' || key == '5'){
    test.cur_lane = main.lanes.get(key-49);
  }
  if (key == 'l') {
    test.toggle_lidar();
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
