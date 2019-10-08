class Car {
  World world = null;
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
  float safe_sep;
  float lead_car_d;
  float sensor_envelope;
  
  int type; // 0 = ego, negative values are cars behind ego, positive values are cars in front of ego
  HashMap<Car, PVector> last_pos = new HashMap<Car, PVector>();
  float other_car_safe_sep = 0;
  float other_car_sensor_envelope = 0;
  float lane_change_envelope = 0;
  
  ArrayList<PVector> lane_change_envelope_occupancy = null;
  ArrayList<PVector> envelope_occupancy = null;
  boolean overlap = false;
  boolean weak_overlap = false;
  
  // for probability-of-collision envelopes
  HashMap<Float, Float> prob_table = new HashMap<Float, Float>();
  HashMap<Float, Float> prob_envelopes = new HashMap<Float, Float>();
  float p_threshold = 0.65;
  
  float clock = 0;

  Interlock.Interlock interlock = new Interlock.Interlock(MAX_ACCEL, MAX_DECEL, LENGTH, WIDTH);

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
    return this;
  }
  
  Car set_type(int _type) {
    type = _type;
    return this;
  }
  
  Car set_prob_table(HashMap<Float, Float> pt) {
    prob_table = pt;
    return this;
  }
  
  float p_controller(float dt, float cur_acc, ArrayList<Car> cars, HashMap<Car, HashMap<Float, Float>> p_envelopes) {
    if (cars == null || cars.size() == 0) return cur_acc;

    for (int i = 1; i < cars.size(); i++) {
      Car c = cars.get(i);
      float safe_sep = p_envelopes.get(c).get(p_threshold);
      if (PVector.sub(position, c.position).mag()-0.5*c.LENGTH < safe_sep) return -MAX_DECEL;
    }
    
    return cur_acc;
  }
  
  void update_envelopes(float dt, ArrayList<Car> cars) {
    if (cars == null || cars.size() == 0) return;
    for (int i = 1; i < cars.size(); i++) {
      Car c = cars.get(i);
      PVector c_pos = c.position;
      if (!last_pos.containsKey(c)) {
        last_pos.put(c, c_pos);
      }
      PVector d = PVector.sub(c_pos, last_pos.get(c));
      float c_v = d.mag()/dt;
      float c_safe_sep = max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - c_v*c_v/(2.0*MAX_DECEL), +0.5*LENGTH);
      w.update_safe_sep(c, c_safe_sep);
      
      float c_sensor_envelope = speed*T_s + MAX_ACCEL*T_s*T_s/2 - c_v*T_s + MAX_DECEL*T_s*T_s/2;
      w.update_sensor_envelope(c, c_sensor_envelope);
      
      // for probability-of-collision envelopes
      HashMap<Float, Float> new_prob_table = new HashMap<Float, Float>();
      for (float prob : c.prob_table.keySet()) {
        float c_decel = c.prob_table.get(prob)*MAX_DECEL;
        float case_1 = max(speed*speed/(2.0*MAX_DECEL) - c_v*c_v/(2.0*c_decel) + 0.5*LENGTH + 0.1, +0.5*LENGTH);
        println("Case 1: " + case_1);
        float case_2 = max(((speed - c_v)*(speed - c_v))/(2*(MAX_DECEL - c_decel)) + 0.5*LENGTH + 0.1, +0.5*LENGTH);
        println("Case 2: " + case_2);
        float new_safe_sep = 0;
        // 3 CASES W/O DELAYS
        if (c_decel >= MAX_DECEL) {
          new_safe_sep = case_1;
        } else if (speed > c_v) {
          new_safe_sep = case_2;
        }
        println("safe_sep: " + new_safe_sep);
        //float new_safe_sep = c_decel >= MAX_DECEL ? max(speed*speed/(2.0*MAX_DECEL) - c_v*c_v/(2.0*c_decel) + 0.5*LENGTH + 0.1, +0.5*LENGTH)
        //                                          : max(((speed - c_v)*(speed - c_v))/(2*(MAX_DECEL - c_decel)*(MAX_DECEL - c_decel)) + 0.5*LENGTH + 0.1, +0.5*LENGTH);
        // 3 CASES W/ DELAYS
        //float new_safe_sep = c_decel >= MAX_DECEL ? max(speed*speed/(2.0*MAX_DECEL) - c_v*c_v/(2.0*c_decel) + 0.5*LENGTH + 0.1 + speed*e + MAX_ACCEL*e*e/2 - (c_v*e - c_decel*e*e/2), +0.5*LENGTH)
        //                                          : max(((speed - c_v)*(speed - c_v))/(2*(MAX_DECEL - c_decel)*(MAX_DECEL - c_decel)) + 0.5*LENGTH + 0.1 + + speed*e + MAX_ACCEL*e*e/2 - (c_v*e - c_decel*e*e/2), +0.5*LENGTH);                                          
        // 3 CASES W/ DELAYS, trying to account for cars behind
        //float new_safe_sep = c.type > 0 ? max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - c_v*c_v/(2.0*c_decel), +0.5*LENGTH) 
        //                              : max(-speed*speed/(2.0*acceleration)+0.5*LENGTH + c_v*c_v/(2.0*c_decel), +0.5*LENGTH);
        // 1 CASE W/ DELAYS
        //float new_safe_sep = max((speed + MAX_ACCEL*e - c_v + c_decel*e)*(speed + MAX_ACCEL*e - c_v + c_decel*e)/(2*(MAX_DECEL - c_decel)*(MAX_DECEL - c_decel))
        //                          + speed*e + MAX_ACCEL*e*e/2 - (c_v*e - c_decel*e*e/2) + 0.5*LENGTH, +0.5*LENGTH);                       
        new_prob_table.put(prob, new_safe_sep);
      }
      w.update_prob_envelopes(c, new_prob_table);
      
      last_pos.put(c, c_pos.copy());
    }
  }
  
  float controller(float dt, float cur_acc, ArrayList<Car_Info.Car_Info> cars) {
    boolean safe = interlock.is_scenario_safe(this.T_s, dt, this.speed, this.position.x, this.position.y, cars);
    //if (cars == null || cars.size() == 0) return cur_acc;
    //if (lead_car_last_pos == null) {
    //  lead_car_last_pos = new PVector(cars.get(0).x, cars.get(0).y);
    //  return cur_acc;
    //}
    //PVector lead_car_cur_pos = new PVector(cars.get(0).x, cars.get(0).y);
    //PVector d = PVector.sub(lead_car_cur_pos, lead_car_last_pos);
    //float lead_car_v = d.mag()/dt;
    ////float safe_sep = max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - lead_car_v*lead_car_v/(2.0*8)+0.1, +0.5*LENGTH)+0.5;
    //safe_sep = max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - lead_car_v*lead_car_v/(2.0*MAX_DECEL), +0.5*LENGTH); // Assume other car has same MAX_DECEL as ego car
    //lead_car_d = PVector.sub(lead_car_cur_pos, position).mag();
    //sensor_envelope = speed*T_s + MAX_ACCEL*T_s*T_s/2 - lead_car_v*T_s + MAX_DECEL*T_s*T_s/2;
    //boolean safe = PVector.sub(position, lead_car_cur_pos).mag()-0.5*cars.get(0).get_l()  >= (safe_sep + sensor_envelope + 0.1);
    
    //lead_car_last_pos = lead_car_cur_pos.copy();
    if (safe) return cur_acc;
    return -MAX_DECEL;
  }
  
  Car timestep(float dt) {
    clock += dt;
    ArrayList<Car_Info.Car_Info> cars = new ArrayList<Car_Info.Car_Info>();
    if (lidar != null) {
      cars = lidar.scan(show_lidar);
    }
    if (controller_on) {
      acceleration = controller(dt, accel_input, cars);
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

  void check_overlap() {
    if (type != 0 && lane_change_envelope_occupancy != null) {
      for (PVector loc : lane_change_envelope_occupancy) {
        world.envelope_grid[int(loc.x)][int(loc.y)] -= 0.5;
      }
    } else {
      lane_change_envelope_occupancy = new ArrayList<PVector>();
    }
    lane_change_envelope_occupancy.clear();
    
    if (envelope_occupancy != null) {
      for (PVector loc : envelope_occupancy) {
        world.envelope_grid[int(loc.x)][int(loc.y)] -= 1;
      }
    } else {
      envelope_occupancy = new ArrayList<PVector>();
    }
    envelope_occupancy.clear();
    
    boolean[][] prevent_repeats = new boolean[world.w][world.h];
    boolean cur_overlap = false;
    boolean cur_weak_overlap = false;
        
    for (float i = -(other_car_safe_sep + other_car_sensor_envelope + lane_change_envelope)*pixels_per_meter; i < LENGTH*pixels_per_meter/2; i++) {
      for (float j = 0; j < int(WIDTH*pixels_per_meter); j++) {
        float x = i;
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
          if (type != 0) {
            if (i < -(other_car_safe_sep + other_car_sensor_envelope)*pixels_per_meter) {
              world.envelope_grid[x_index][y_index] += 0.5;
              lane_change_envelope_occupancy.add(loc);
            } else {
              world.envelope_grid[x_index][y_index] += 1;
              envelope_occupancy.add(loc);
            }
          }
          if (type == 0) {
            if (world.envelope_grid[x_index][y_index] == 1) {
              overlap = true;
              cur_overlap = true;
            } else if (world.envelope_grid[x_index][y_index] == 0.5) {
              weak_overlap = true;
              cur_weak_overlap = true;
            }
          }
          prevent_repeats[x_index][y_index] = true;
        }
      }
    }
    if (!cur_overlap) overlap = false;
    if (!cur_weak_overlap) weak_overlap = false;
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
    //ellipse(0, 0, 2*(safe_sep)*pixels_per_meter, 2*(safe_sep)*pixels_per_meter);
    popStyle();
    popMatrix();
    
    pushMatrix();

    translate(position.x*pixels_per_meter, position.y*pixels_per_meter);
    rotate(orientation);
    noStroke();
    
    // DRAW RECTANGULAR ENVELOPES
    //pushStyle();
    //rectMode(CENTER);
    //color c1 = color(255, 165, 0);
    //color c2 = color(255, 255, 51);
    //color c3 = color(0, 0, 255, 65);
    //if (!is_ego) {
    //  fill(c1);
    //  rect(-other_car_safe_sep/2*pixels_per_meter, 0, other_car_safe_sep*pixels_per_meter, WIDTH*pixels_per_meter);
    //  fill(c2);
    //  rect((-other_car_safe_sep-other_car_sensor_envelope/2)*pixels_per_meter, 0, other_car_sensor_envelope*pixels_per_meter, WIDTH*pixels_per_meter);
    //  fill(c3);
    //  rect((-other_car_safe_sep-other_car_sensor_envelope-lane_change_envelope/2)*pixels_per_meter, 0, 
    //    lane_change_envelope*pixels_per_meter, WIDTH*pixels_per_meter);
    //}
    //popStyle();    
    if (type != 0) draw_prob_envelopes();
    
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
  
  void draw_prob_envelopes() {
    pushStyle();
    noFill();
    
    for (float prob : prob_envelopes.keySet()) {
      float safe_sep_for_prob = prob_envelopes.get(prob);
      stroke((1-prob)*255, 0, 0);
      ellipse(0, 0, 2*safe_sep_for_prob*pixels_per_meter, -2*safe_sep_for_prob*pixels_per_meter);
      String label = String.format("%.1f", prob*100.0) + "%";
      text(label, 0, -max(safe_sep_for_prob, 0.5*LENGTH)*pixels_per_meter - 5);
    }
    
    popStyle();    
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
