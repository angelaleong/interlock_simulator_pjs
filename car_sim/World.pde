class World {

  int[][] occupancy_grid;  // the global occupancy grid, where 0 is unoccupied
  float[][] envelope_grid;  // the global occupancy grid inclusive of envelopes, where 0 is unoccupied
  ArrayList<Car> cars = new ArrayList<Car>();
  HashMap<Car, Float> safe_sep = new HashMap<Car, Float>();
  HashMap<Car, Float> sensor_envelope = new HashMap<Car, Float>();
  float x_offset, y_offset;
  int w, h;
  boolean halt = false;

  World(int w_, int h_) {
    w = w_;
    h = h_;
    occupancy_grid = new int[w][h];
    envelope_grid = new float[w][h];
  }

  World coordinate_offset(float x_offset_, float y_offset_) {
    x_offset = x_offset_;
    y_offset = y_offset_;
    return this;
  }

  World add_car(Car car) {
    cars.add(car);
    car.set_world(this);
    return this;
  }
  
  World update_safe_sep(Car car, float d) {
    safe_sep.put(car, d);
    return this;
  }
  
  World update_sensor_envelope(Car car, float d) {
    sensor_envelope.put(car, d);
    return this;
  }

  float get_safe_sep(Car car) {
    return safe_sep.get(car);
  }
  
  float get_sensor_envelope(Car car) {
    return sensor_envelope.get(car);
  }
  
  ArrayList<Car> query() {
    return cars;
  }
  
  World timestep(float dt) {
    if (halt) {
      return this;
    }

    for (Car car : cars) {
      if (car.collision) {
        //console.log("some cars collided; halting");
        halt = true;
      }

      car.timestep(dt);
    }
    //System.out.println(safe_sep);
    return this;
  }

  World display_cars(float pixels_per_meter) {
    for (Car car : cars) {
      car.display_car(pixels_per_meter);
    }
    return this;
  }
  
  //World display_contours(ArrayList<Car> other_cars, Road road, float sd_x, float sd_y, float alpha, float h_c) {
  //  System.out.println(occupancy_grid.length);
  //  System.out.println(occupancy_grid[0].length);
  //  color col = color(255,255,0);
  //  for (int i = 0; i < w; i++) {
  //    for (int j = 0; j < h; j++) {
  //      // if (i, j) falls in road
  //      float h_pixel = 0;
  //      for (Car c : other_cars) {
  //        PVector d_i = PVector.sub(new PVector(i, j), c.position);
  //        // TODO: verify that I'm getting the x- and y-components of velocity correctly
  //        h_pixel += Math.exp(-Math.pow(d_i.x, 2)/Math.pow(sd_x, 2) - Math.pow(d_i.y, 2)/Math.pow(sd_y, 2))/
  //          (1 + Math.exp(-alpha*(d_i.x * c.speed*cos(c.orientation) + d_i.y * c.speed*sin(c.orientation))));
  //      }
  //      if (h_pixel >= h_c && occupancy_grid[i][j] == 0) {
  //        set(i, j, col);
  //      }
  //    }
  //  }
  //  return this;
  //}
}
