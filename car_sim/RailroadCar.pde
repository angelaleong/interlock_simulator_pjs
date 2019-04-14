class RailroadCar extends Car {
  Road road;
  Lane cur_lane;
  float last_error = 0;
  boolean lane_changing = false;

  RailroadCar(Road _road, int which_lane, float offset, int type) {
    super(type);
    road = _road;
    if (which_lane >= _road.lanes.size()) {
      println("Selected lane (" + str(which_lane) + ") is not in road (max " + str(road.lanes.size()-1) + ")");
    }
    cur_lane = _road.lanes.get(which_lane);
    orientation = cur_lane.orientation;
    position = new PVector(cur_lane.a.x, cur_lane.a.y);
    PVector d = new PVector(offset, 0);
    d.rotate(orientation);
    position.add(d);
  }

  RailroadCar path_follow(float p, float d, float i) {
    float error = cur_lane.path.dist_to_path(position);
    steering_command = p*error - d*(last_error-error);
    last_error = error;
    return this;
  }
  
  // LANE CHANGING LOGIC:
  // if (ego car must decelerate if it stays in the same lane):
  //    if (there are neighboring lanes):
  //        if (lane change is valid):
  //            change lanes
  //        else:
  //            stay and decelerate
  //    else:
  //        decelerate
  
  float envelope_controller(float cur_acc) {    
    // INSTANTANEOUS LANE CHANGE
    //if (!overlap) return cur_acc;
    
    //if (cur_lane.index - 1 >= 0) {
    //  Lane new_lane = road.lanes.get(cur_lane.index - 1);
    //  if (valid_lane_change(new_lane)) {
    //    instant_lane_change(new_lane);
    //  }
    //} else if (cur_lane.index + 1 < road.lanes.size()) {
    //  Lane new_lane = road.lanes.get(cur_lane.index + 1);
    //  if (valid_lane_change(new_lane)) {
    //    instant_lane_change(new_lane);
    //  }
    //}
    
    //return -MAX_DECEL;
      
    // SMOOTH LANE CHANGE
    if (!overlap) {
      if (!weak_overlap) {
        lane_changing = false;
        return cur_acc;
      } 
      else {
        if (cur_lane.index - 1 >= 0) {
          Lane new_lane = road.lanes.get(cur_lane.index - 1);
          if (valid_smooth_lane_change(new_lane)) {
            if (!lane_changing) smooth_lane_change(new_lane);
            lane_changing = true;
            return cur_acc;
          }
        } else if (cur_lane.index + 1 < road.lanes.size()) {
          Lane new_lane = road.lanes.get(cur_lane.index + 1);
          if (valid_smooth_lane_change(new_lane)) {
            if (!lane_changing) smooth_lane_change(new_lane);
            lane_changing = true;
            return cur_acc;
          }
        }
      }
    }
    
    return -MAX_DECEL;
  }
  
  boolean valid_lane_change(Lane new_lane) {
    PVector offset = PVector.sub(position, cur_lane.a);
    PVector new_position = PVector.add(new_lane.a, offset);
    
    for (float i = 0; i < int(LENGTH*pixels_per_meter); i++) {
      for (float j = 0; j < int(WIDTH*pixels_per_meter); j++) {
        float x = i - LENGTH*pixels_per_meter/2;
        float y = j - WIDTH*pixels_per_meter/2;
        PVector a = new PVector(x, y);
        a.rotate(orientation);
        int x_index = int(new_position.x*pixels_per_meter+a.x)+int(world.x_offset);
        int y_index = int(new_position.y*pixels_per_meter+a.y)+int(world.y_offset);
        if (x_index < 0 || x_index >= world.w-1 || y_index < 0 || y_index >= world.h-1) continue;
        if (world.envelope_grid[x_index][y_index] == 1) return false;
      }
    }
    return true;
  }
  
  boolean valid_smooth_lane_change(Lane new_lane) {
    PVector offset = PVector.sub(position, cur_lane.a);
    PVector new_position = PVector.add(new_lane.a, offset);
    
    for (float i = 0; i < int((LENGTH+lane_change_envelope)*pixels_per_meter); i++) {
      for (float j = 0; j < int(WIDTH*pixels_per_meter); j++) {
        float x = i - LENGTH*pixels_per_meter/2;
        float y = j - WIDTH*pixels_per_meter/2;
        PVector a = new PVector(x, y);
        a.rotate(orientation);
        int x_index = int(new_position.x*pixels_per_meter+a.x)+int(world.x_offset);
        int y_index = int(new_position.y*pixels_per_meter+a.y)+int(world.y_offset);
        if (x_index < 0 || x_index >= world.w-1 || y_index < 0 || y_index >= world.h-1) continue;
        if (world.envelope_grid[x_index][y_index] > 0) return false;
      }
    }
    return true;
  }

  RailroadCar instant_lane_change(Lane new_lane) {
    PVector offset = PVector.sub(position, cur_lane.a);
    position = PVector.add(new_lane.a, offset);
    cur_lane = new_lane;
    return this;
  }
  
  RailroadCar smooth_lane_change(Lane new_lane) {
    cur_lane = new_lane;
    return this;
  }
  
  RailroadCar timestep(float dt) {
    path_follow(0.05, 3, 0);
    ArrayList<Car_Info.Car_Info> car_info = new ArrayList<Car_Info.Car_Info>();
    if (lidar != null) {
      car_info = lidar.scan(false);
    }
    if (type == 0) {
      update_envelopes(dt, w.query_cars());
    } else {
      other_car_safe_sep = w.get_safe_sep(this);
      other_car_sensor_envelope = w.get_sensor_envelope(this);
      prob_envelopes = w.get_prob_envelopes(this);
    }
    if (controller_on) {
      //acceleration = controller(dt, accel_input, car_info);
      //acceleration = envelope_controller(accel_input);
      acceleration = p_controller(dt, accel_input, w.query_cars(), w.query_prob_envelopes());
    } else {
      acceleration = accel_input;
    }
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

    check_overlap();
    check_collision();

    return this;
  }

  void display_car(float pixels_per_meter, int car_index) {
    if (type == 0) cur_lane.draw_lane(true);
    super.display_car(pixels_per_meter, car_index);
  }
}
