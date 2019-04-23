class Car {
  World world = null;
  Controller controller = null;
  Interlock interlock = null;
  
  // TODO: eventually want to read in these params from a file
  String name = "default_car";
  ArrayList<PVector> current_occupancy = null;
  int current_occupancy_valid = 0;
  PVector position = new PVector(0, 0);
  float acceleration = 0;
  float accel_input = 0;
  float MAX_DECEL = 10;
  float MAX_ACCEL = 9;
  float T_s = 0.1; // sensor delay
  float T_a = 0.1; // actuator delay
  float T_i = 0.1; // interlock cycle
  float e = T_s + T_a + T_i;

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

  boolean controller_on = false;
  Lidar lidar = null;
  boolean show_lidar = false;
  
  // for old controller
  PVector lead_car_last_pos = null;
  
  // for envelopes and overlap check
  //float safe_sep;
  //float lead_car_d;
  //float sensor_envelope;
  
  int type; // 0 = ego, negative values are cars behind ego, positive values are cars in front of ego

  Car(int _type) {
    type = _type;
  }

  Car set_lidar() {
    if (world == null) {
      println("No world defined!");
      return this;
    }
    lidar = new Lidar(50, -2*PI/3.0, 2*PI/3.0, 2*PI/1000.0, world, this);
    return this;
  }
  
  Car toggle_lidar() {
    show_lidar = !show_lidar;
    return this;
  }

  Car set_world(World new_world) {
    world = new_world;
    return this;
  }

  Car set_color(color c) {
    paint = c;
    return this;
  }

  Car set_init_orientation(float a) {
    orientation = a;
    return this;
  }

  Car set_init_steering_angle(float a) {
    steering_command = a;
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
  
  Car set_init_accel(float a) {
    accel_input = a;
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
    accel_input = accel;
    return this;
  }

  Car controller_on() {
    controller_on = true;
    controller = new Controller(0, LENGTH, MAX_DECEL);
    interlock = new Interlock(0, MAX_DECEL);
    return this;
  }
  
  Car set_type(int _type) {
    type = _type;
    return this;
  }
  
  //float controller(float dt, float cur_acc, ArrayList<Car_Info> cars) {
  //  if (cars == null || cars.size() == 0) return cur_acc;
  //  if (lead_car_last_pos == null) {
  //    lead_car_last_pos = new PVector(cars.get(0).x, cars.get(0).y);
  //    return cur_acc;
  //  }
  //  PVector lead_car_cur_pos = new PVector(cars.get(0).x, cars.get(0).y);
  //  PVector d = PVector.sub(lead_car_cur_pos, lead_car_last_pos);
  //  float lead_car_v = d.mag()/dt;
  //  //float safe_sep = max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - lead_car_v*lead_car_v/(2.0*8)+0.1, +0.5*LENGTH)+0.5;
  //  safe_sep = max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - lead_car_v*lead_car_v/(2.0*MAX_DECEL), +0.5*LENGTH); // Assume other car has same MAX_DECEL as ego car
  //  lead_car_d = PVector.sub(lead_car_cur_pos, position).mag();
  //  sensor_envelope = speed*T_s + MAX_ACCEL*T_s*T_s/2 - lead_car_v*T_s + MAX_DECEL*T_s*T_s/2;
  //  boolean safe = PVector.sub(position, lead_car_cur_pos).mag()-0.5*cars.get(0).get_l()  >= (safe_sep + sensor_envelope + 0.1);
    
  //  lead_car_last_pos = lead_car_cur_pos.copy();
  //  if (safe) return cur_acc;
  //  return -MAX_DECEL;
  //}
  
  Car timestep(float dt) {
    ArrayList<Car_Info> cars = new ArrayList<Car_Info>();
    if (lidar != null) {
      cars = lidar.scan(show_lidar);
    }
    if (controller_on) {
      controller.timestep(dt, accel_input, cars, position, speed);
      acceleration = interlock.timestep(dt, controller.clock, controller.brake, accel_input, controller.accel, controller.evidence);
      //acceleration = controller(dt, accel_input, cars);
    } else {
      acceleration = accel_input;
    }
    speed = (speed + acceleration*dt > 0) ? speed + acceleration * dt : 0;
    
    // steering
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
    boolean cur_collision = false;
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
            cur_collision = true;
            println("COLLISION");
          }
          prevent_repeats[x_index][y_index] = true;
        }
      }
    }
    if (!cur_collision) collision = false;
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

  void display_car(float pixels_per_meter, int car_index) {
    pushMatrix();
    translate(position.x*pixels_per_meter, position.y*pixels_per_meter);
    pushStyle();
    noFill();
    stroke(0);
    if (controller_on) ellipse(0, 0, 2*(controller.safe_sep)*pixels_per_meter, 2*(controller.safe_sep)*pixels_per_meter);
    popStyle();
    popMatrix();
    
    pushMatrix();

    translate(position.x*pixels_per_meter, position.y*pixels_per_meter);
    rotate(orientation);
    noStroke();
    
    rectMode(CENTER);
    // body
    pushStyle();
    fill(paint);

    if (acceleration < 0 || speed == 0) {
      strokeWeight(2);
      stroke(0);
    }
    //noFill();
    //stroke(0);
    rect(0, 0, LENGTH*pixels_per_meter, int(WIDTH*pixels_per_meter)%2==0 ?
      int(WIDTH*pixels_per_meter) : int(WIDTH*pixels_per_meter) + 1);
    if (collision) {
      stroke(0);
      line(-0.5*LENGTH*pixels_per_meter, -0.5*WIDTH*pixels_per_meter, 0.5*LENGTH*pixels_per_meter, 0.5*WIDTH*pixels_per_meter);
      line(-0.5*LENGTH*pixels_per_meter, 0.5*WIDTH*pixels_per_meter, 0.5*LENGTH*pixels_per_meter, -0.5*WIDTH*pixels_per_meter);
    }
    popStyle();

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

    //draw_origin(true);
    //draw_turn_radius(true);
    //draw_steering_angle(true);
    display_dynamics(car_index);
    popMatrix();
    
    if (lidar != null) {
      lidar.show_boundary(show_lidar);
    }
  }
  
  void display_dynamics(int car_index) {
    pushMatrix();
    String speed_str = "speed: " + String.format("%.2f", speed) + " m/s";
    String accel_str = "accel.: " + String.format("%.2f", acceleration) + "m/s^2";
    
    pushStyle();
    if (car_index == 0) translate(0, -100);
    else translate(0, 100);
    rectMode(CENTER);
    fill(255);
    stroke(paint);
    rect(0, 0, 120, 40);
    fill(0);
    textAlign(LEFT);
    text(speed_str, -55, -4);
    text(accel_str, -55, 12); 
    popStyle();
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
