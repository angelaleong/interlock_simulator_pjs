class RailroadCar extends Car {
  Lane cur_lane;
  float last_error = 0;

  RailroadCar(Road road, int which_lane, float offset) {
    super();
    if (which_lane >= road.lanes.size()) {
      println("Selected lane (" + str(which_lane) + ") is not in road (max " + str(road.lanes.size()-1) + ")");
    }
    cur_lane = road.lanes.get(which_lane);
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

  RailroadCar timestep(float dt) {
    path_follow(0.01,3,0);
    ArrayList<Car_Info> cars = new ArrayList<Car_Info>();
    if (lidar != null) {
      cars = lidar.scan(false);
    }
    if (controller_on) {
      acceleration = controller(dt, accel_input, cars);
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

    check_collision();

    return this;
  }
}
