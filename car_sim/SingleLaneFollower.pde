class SingleLaneFollower extends Car {
  int front_car_pos = 0; // x-index of the pixels representing the rearmost boundary of the front car
  boolean interlock = false;
  float accel_max = 2.68; // 0 to 60 mph in 10 seconds
  float accel_min = -4.572; // 15 fps^2 deceleration
  float t_p = 0.1; // amount of delay (period) between iterations of Interlock
  float t_s = 0.1; // sensor delay for distances (Lidar)
  float t_c = 0.1; // delay between Interlock sending the command and an actual reaction by the ego car’s physical actuators

  SingleLaneFollower() {
    super();
  }

  SingleLaneFollower set_front_car_pos(int pos) {
    front_car_pos = int((pos-LENGTH/2)*pixels_per_meter)+int(world.x_offset);
    return this;
  }

  SingleLaneFollower timestep(float dt) {
    // from Justine's slides
    float total_delay = t_p + t_s + t_c;
    console.log("speed: " + speed);
    float minimum_braking_dist = speed + accel_max * t_p + accel_max*total_delay; // TODO: accel_max or current accel?
    float dist_stop = accel_max * (t_p*t_p + total_delay*total_delay )/2 +
                        (speed + accel_max * t_p) * (2*t_p + t_s + t_c) +
                        minimum_braking_dist*minimum_braking_dist / (-2*accel_min);
    float dist_separation = get_dist_from_front();
    console.log("dist_stop: " + dist_stop);
    console.log("dist_separation: " + dist_separation);
    if (dist_separation < dist_stop) {
      interlock = true;
    } else {
      interlock = false;
    }

    float accel_output = interlock ? accel_min : acceleration;
    speed = (speed + accel_output*dt > 0) ? speed + accel_output * dt : 0;

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

  float get_dist_from_front() {
    if (current_occupancy != null) {
      int max_x = int(position.x * pixels_per_meter) + int(world.x_offset);
      for (float i = 0; i < int(LENGTH*pixels_per_meter); i++) {
        for (float j = 0; j < int(WIDTH*pixels_per_meter); j++) {
          float x = i - LENGTH*pixels_per_meter/2;
          float y = j - WIDTH*pixels_per_meter/2;
          PVector a = new PVector(x, y);
          a.rotate(orientation);
          int x_index = int(position.x*pixels_per_meter+a.x)+int(world.x_offset);
          max_x = Math.max(max_x, x_index);
        }
      }
      return (front_car_pos - max_x) / pixels_per_meter;
    } else {
      int x_index = int(position.x * pixels_per_meter) + int(world.x_offset);
      return (front_car_pos - x_index) / pixels_per_meter;
    }
  }
}
