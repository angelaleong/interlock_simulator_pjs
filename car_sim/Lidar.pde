class Lidar {
  float range, min_angle, max_angle, angular_resolution;
  World world;
  Car car;
  ArrayList<ArrayList<Car_Info.Car_Info>> buffer = new ArrayList<ArrayList<Car_Info.Car_Info>>();

  Lidar(float range_, float min_angle_, float max_angle_, 
    float angular_resolution_, World world_, Car car_) {
    range = range_;
    min_angle = min_angle_;
    max_angle = max_angle_;
    angular_resolution = angular_resolution_;
    world = world_;
    car = car_;
  }

  // returns an arraylist of all visible cars. each element of array list is of the form [relative_x, relative_y, orientation, width, length]
  ArrayList<Car_Info.Car_Info> delayed_scan(float sensor_delay, float dt, boolean show_current, boolean show_delayed) {
    buffer.add(scan(show_current));
    if (buffer.size() > int(sensor_delay/dt)) {
      buffer.remove(0);
      if (show_delayed) {
        pushMatrix();
        translate(world.x_offset, world.y_offset);
        for (Car_Info.Car_Info c : buffer.get(0)) {
          pushMatrix();
          translate(c.get_x()*pixels_per_meter, c.get_y()*pixels_per_meter);
          rotate(c.get_orientation());
          pushStyle();
          rectMode(CENTER);
          fill(0, 255, 0);
          noStroke();
          rect(0, 0, c.get_l()*pixels_per_meter+4, c.get_w()*pixels_per_meter+4);
          fill(155);
          rect(0, 0, c.get_l()*pixels_per_meter, c.get_w()*pixels_per_meter);
          popStyle();
          popMatrix();
        }
        popMatrix();
        return buffer.get(0);
      }
    }
    return null;
  }

  ArrayList<Car_Info.Car_Info> scan(boolean show) {
    ArrayList<Car_Info.Car_Info> visible_cars = new ArrayList<Car_Info.Car_Info>();
    for (Car c : world.cars) {
      if (c != this.car && c.current_occupancy != null && dist(c.position.x, c.position.y, car.position.x, car.position.y) < range+dist(0, 0, c.LENGTH*0.5, c.WIDTH*0.5)+dist(0, 0, car.LENGTH*0.5, car.WIDTH*0.5)) {
        stroke(155);
        for (PVector loc : c.current_occupancy) {

          boolean valid = true;

          if (dist(loc.x-world.x_offset, loc.y-world.y_offset, car.position.x*pixels_per_meter, car.position.y*pixels_per_meter) <= range*pixels_per_meter) {
            ArrayList<PVector> points = bresenham(loc.x-world.x_offset, loc.y-world.y_offset, car.position.x*pixels_per_meter, car.position.y*pixels_per_meter, 1);
            for (int i = 1; i < points.size(); i++) {
              PVector p = points.get(i);

              int x_index = int(p.x+world.x_offset);
              int y_index = int(p.y+world.y_offset);

              if (x_index < 0 || x_index >= world.w-1 || y_index < 0 || y_index >= world.h-1) continue;
              boolean occupied = world.occupancy_grid[x_index][y_index] > 0;

              p.mult(1.0/pixels_per_meter);  // in units of meters now
              if (occupied) {

                // if not within car
                if (p.x < car.position.x - car.WIDTH*0.5 -3|| p.x > car.position.x + car.WIDTH*0.5 +3||   // dunno why but sometimes small regions right outside the car will show up as occupied
                  p.y < car.position.y - car.LENGTH*0.5 -3 || p.y > car.position.y + car.LENGTH*0.5+3) {

                  valid = false;
                  break;
                }
                // is within car
              }
            }
          } else {
            valid = false;
          }
          // as soon as we find an uninterrupted line from c to car, we're good to go
          if (valid) {
            pushMatrix();
            translate(world.x_offset, world.y_offset);
            stroke(255, 0, 0);
            line(c.position.x*pixels_per_meter, c.position.y*pixels_per_meter, car.position.x*pixels_per_meter, car.position.y*pixels_per_meter);
            visible_cars.add(new Car_Info.Car_Info(c.position.x, c.position.y, c.orientation, c.WIDTH, c.LENGTH));
            popMatrix();
            break;
          }
        }
      }
    }
    if (show) {
      pushMatrix();
      translate(car.position.x*pixels_per_meter+world.x_offset, car.position.y*pixels_per_meter+world.y_offset);
      for (Car_Info.Car_Info c : visible_cars) {
        pushMatrix();
        translate(c.get_x()*pixels_per_meter, c.get_y()*pixels_per_meter);
        rotate(c.get_orientation());
        pushStyle();
        rectMode(CENTER);
        fill(0, 255, 0);
        noStroke();
        rect(0, 0, c.get_l()*pixels_per_meter+4, c.get_w()*pixels_per_meter+4);
        fill(155);
        rect(0, 0, c.get_l()*pixels_per_meter, c.get_w()*pixels_per_meter);
        popStyle();
        popMatrix();
      }
      popMatrix();
    }
    //for (Car c : visible_cars){
    //  c.display_car(pixels_per_meter);
    //}
    return visible_cars;
  }

  ArrayList<Car> detect_cars() {
    ArrayList<Car> detected_cars = new ArrayList<Car>();
    for (Car c : world.cars) {
      if (c != this.car && c.current_occupancy != null && dist(c.position.x, c.position.y, car.position.x, car.position.y) < range+dist(0, 0, c.LENGTH*0.5, c.WIDTH*0.5)+dist(0, 0, car.LENGTH*0.5, car.WIDTH*0.5)) {
        for (PVector loc : c.current_occupancy) {

          boolean valid = true;

          if (dist(loc.x-world.x_offset, loc.y-world.y_offset, car.position.x*pixels_per_meter, car.position.y*pixels_per_meter) <= range*pixels_per_meter) {
            ArrayList<PVector> points = bresenham(loc.x-world.x_offset, loc.y-world.y_offset, car.position.x*pixels_per_meter, car.position.y*pixels_per_meter, 1);
            for (int i = 1; i < points.size(); i++) {
              PVector p = points.get(i);

              int x_index = int(p.x+world.x_offset);
              int y_index = int(p.y+world.y_offset);

              boolean occupied = world.occupancy_grid[x_index][y_index] > 0;

              p.mult(1.0/pixels_per_meter);  // in units of meters now
              if (occupied) {

                // if not within car
                if (p.x < car.position.x - car.WIDTH*0.5 -3|| p.x > car.position.x + car.WIDTH*0.5 +3||   // dunno why but sometimes small regions right outside the car will show up as occupied
                  p.y < car.position.y - car.LENGTH*0.5 -3 || p.y > car.position.y + car.LENGTH*0.5+3) {

                  valid = false;
                  break;
                }
                // is within car
              }
            }
          } else {
            valid = false;
          }
          // as soon as we find an uninterrupted line from c to car, we're good to go
          if (valid) {
            detected_cars.add(c);
          }
        }
      }
    }
    return detected_cars;
  }
  
  void show_boundary(boolean scans) {
    pushMatrix();
    translate(car.position.x*pixels_per_meter, car.position.y*pixels_per_meter);
    rotate(car.orientation);
    pushStyle();
    stroke(155);
    strokeWeight(1);
    noFill();
    if (scans) {
      ellipse(0, 0, 2*range*pixels_per_meter, 2*range*pixels_per_meter); 
      arc(0, 0, 2*range*pixels_per_meter, 2*range*pixels_per_meter, min_angle, max_angle, PIE);
    }
    //if (scans){
    //    for (float i = min_angle; i <= max_angle; i+=angular_resolution){
    //        line(0,0,range*cos(i)*pixels_per_meter, range*sin(i)*pixels_per_meter);
    //    }
    //}
    popStyle();
    popMatrix();
  }
}
