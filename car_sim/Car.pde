class Car {
  World world = null;
  // TODO: eventually want to read in these params from a file'
  String name = "default_car";
  ArrayList<PVector> current_occupancy = null;
  int current_occupancy_valid = 0;
  PVector position = new PVector(0, 0);
  float acceleration = 0;

  float orientation = 0;  // angle w.r.t world X axis
  float steering_angle = 0;  // positive for left, negative for right
  float steering_command = 0;

  float speed = 10;  // a scalar, since we're always moving in the
  // car's steering direction

  float MAX_STEERING_DELTA = 1;  // maximum steering that can be applied, 
  // radians/s per second
  float rear_axle_offset = - 1.35;
  float front_axle_offset = 1.35;

  float WIDTH = 1.7;  // width in meters
  float LENGTH = 4.5; 

  color paint = color(255, 0, 0);

  float keyboard_steer = 0;
  float tire_width = 0.215;  // meters
  float tire_diameter = 0.66;  // meters
  boolean collision = false;
  Car() {
  }

  Car set_world(World new_world) {
    world = new_world;
    return this;
  }

  Car set_colour(color c) {
    paint = c;
    return this;
  }

  Car set_init_orientation(float a) {
    orientation = a;
    return this;
  }

  Car set_init_position(PVector a) {
    position = a;
    return this;
  }

  Car set_init_speed(float a) {
    speed = a;
    return this;
  }

  Car apply_steering_command(float angle) {
    steering_command = angle;
    return this;
  }

  Car set_name(String a) {
    name = a;
    return this;
  }

  float ackermann_turn_radius(float steering_angle) {
    if (steering_angle != 0) {
      float axle_d = abs(front_axle_offset) + abs(rear_axle_offset);
      return  axle_d / tan(steering_angle);
    }
    return 0;
  }

  Car keyboard_steering(float dir) {
    keyboard_steer = dir;
    return this;
  }

  Car accelerate(float accel) {
    acceleration = accel;
    return this;
  }

  Car timestep(float dt) {
    speed = (speed + acceleration*dt > 0) ? speed + acceleration * dt : 0;
    steering_step(dt);

    float r = ackermann_turn_radius(steering_angle);  // meters

    // adjust orientation and position if turning
    if (r != 0) {
      float th = abs(dt*speed/r);
      float phi = atan2(abs(rear_axle_offset), abs(r));
      PVector d = new PVector(abs(r) * sin(th), r - r*cos(th));
      d.rotate(orientation+phi*r/abs(r));
      position.add(d);
      orientation += r*th/abs(r);
    } else {
      PVector d = new PVector(dt*speed, 0);
      d.rotate(orientation);
      position.add(d);
    }

    check_collision();

    return this;
  }

  void check_collision() {
    /*
    Check for collisions using the world's occupancy grid
    */
    
    // current_occupancy is an arraylist that holds the coordinates belonging to 
    // this car, it starts uninitialized
    if (current_occupancy != null) {
      // deoccupy the old position of the car
      for (PVector loc : current_occupancy) {
        world.occupancy_grid[int(loc.x)][int(loc.y)] -= 1;
      }
    } else {
      current_occupancy = new ArrayList<PVector>();
    }
    // now we populate current_occupancy using the new position of the car
    current_occupancy.clear();  

    /*rounding may cause the same coordinate pair to appear in
    current_occupancy, which causes false positives. Use this boolean array to 
    keep track of which pixels were already accounted for
    */
    boolean[][] prevent_repeats = new boolean[world.w][world.h]; 

    // loop over all the pixels inside the car
    for (float i = 0; i < int(LENGTH*pixels_per_meter); i++) {
      for (float j = 0; j < int(WIDTH*pixels_per_meter); j++) {
        float x = i - LENGTH*pixels_per_meter/2;
        float y = j - WIDTH*pixels_per_meter/2;
        PVector a = new PVector(x, y);
        a.rotate(orientation);
        int x_index = int(position.x*pixels_per_meter+a.x)+int(world.x_offset);
        int y_index = int(position.y*pixels_per_meter+a.y)+int(world.y_offset);
        if (x_index < 0 || x_index >= world.w-1 || 
            y_index < 0 || y_index >= world.h-1) {
          continue;
        }
        PVector loc = new PVector(x_index, y_index);
        if (!prevent_repeats[x_index][y_index]) {
          world.occupancy_grid[x_index][y_index] += 1;
          current_occupancy.add(loc);
          if (world.occupancy_grid[x_index][y_index] > 1) {
            collision = true;
          } 
          prevent_repeats[x_index][y_index] = true;
        } 
      }
    }
  }

  void steering_step(float dt) {
    /*
    Adjust the steering angle based on input, based on a number of seconds 
    elapsed (dt)
    */
    float steer_dt = MAX_STEERING_DELTA*dt; 

    // increment steering if button pressed
    if (keyboard_steer != 0) {
      if (abs(steering_command + keyboard_steer) < PI/6) {
        steering_command += keyboard_steer;
      }
    }

    // steering will increase/decrease until matches input steering command,
    if (steering_angle < steering_command && 
        steering_angle + steer_dt < steering_command) {
      steering_angle += steer_dt;
    } else if (steering_angle > steering_command && 
               steering_angle - steer_dt > steering_command) {
      steering_angle -= steer_dt;
    } else {
      steering_angle = steering_command;
    }
  }

  void display_car(float pixels_per_meter) {

    pushMatrix();

    translate(position.x*pixels_per_meter, position.y*pixels_per_meter);
    rotate(orientation);
    rectMode(CENTER);
    noStroke();
    // body

    fill(paint);
    //noFill();
    //stroke(0);
    rect(0, 0, LENGTH*pixels_per_meter, int(WIDTH*pixels_per_meter)%2==0 ?
         int(WIDTH*pixels_per_meter) : int(WIDTH*pixels_per_meter) + 1);

    // rear wheels
    fill(0);
    rectMode(CENTER);
    rect(rear_axle_offset*pixels_per_meter, int(WIDTH*pixels_per_meter)*0.5,
      tire_diameter*pixels_per_meter, min(int(tire_width*pixels_per_meter), 2));
    rect(rear_axle_offset*pixels_per_meter, int(-WIDTH*pixels_per_meter)*0.5,
      tire_diameter*pixels_per_meter, min(int(tire_width*pixels_per_meter), 2));


    // front wheels
    pushMatrix();
    translate(front_axle_offset*pixels_per_meter,
      int(WIDTH*pixels_per_meter)*0.5);
    rotate(steering_angle);
    rect(0, 0, tire_diameter*pixels_per_meter,
      min(tire_width*pixels_per_meter, 2));
    popMatrix();

    pushMatrix();
    translate(front_axle_offset*pixels_per_meter, 
      int(-WIDTH*pixels_per_meter)*0.5);
    rotate(steering_angle);
    rect(0, 0, tire_diameter*pixels_per_meter,
      min(tire_width*pixels_per_meter, 2));
    popMatrix();

    draw_origin(true);
    draw_turn_radius(true);
    draw_steering_angle(true);
    popMatrix();
  }
  void draw_origin(boolean draw) {
    /*draw the car's origin, assume coordinate system centered on car centroid,
     aligned with car orientation*/
    if (!draw) return;
    stroke(255, 0, 0);
    line(0, 0, 50, 0);   // positive x dir
    stroke(0, 255, 0);
    line(0, 0, 0, 50);   // positive y dir
  }
  void draw_turn_radius(boolean draw) {
    /*draw the car's turning radius, assume coordinate system centered on car 
     centroid, aligned with car orientation*/
    if (!draw) return;
    // ackermann steering 
    stroke(0);
    line(rear_axle_offset*pixels_per_meter, 0, 
      rear_axle_offset*pixels_per_meter,
      ackermann_turn_radius(steering_angle)*pixels_per_meter);
  }

  void draw_steering_angle(boolean draw) {
    /*draw the car's steering angle, assume coordinate system centered on car 
    centroid, aligned with car orientation*/
    if (!draw) return;
    translate(front_axle_offset*pixels_per_meter, 0);
    rotate(steering_angle);
    stroke(255, 0, 255);
    line(0, 0, 50, 0);
  }
}
