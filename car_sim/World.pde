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
}
