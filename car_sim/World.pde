class World {

  int[][] occupancy_grid;  // the global occupancy grid, where 0 is unoccupied
  ArrayList<Road> roads = new ArrayList<Road>();
  ArrayList<Car> cars = new ArrayList<Car>();
  float x_offset, y_offset;
  int w, h;
  boolean halt = false;

  World(int w_, int h_) {
    w = w_;
    h = h_;
    occupancy_grid = new int[w][h];
  }

  World coordinate_offset(float x_offset_, float y_offset_) {
    x_offset = x_offset_;
    y_offset = y_offset_;
    return this;
  }

  World add_road(Road road) {
    roads.add(road);
    return this;
  }

  World add_car(Car car) {
    cars.add(car);
    car.set_world(this);
    return this;
  }

  World timestep(float dt) {
    if (halt) {
      return this;
    }

    for (Car car : cars) {
      if (car.collision) {
        console.log("some cars collided; halting");
        halt = true;
      } else {
        car.timestep(dt);
      }
    }
    return this;
  }

  World display_roads(float pixels_per_meter) {
    for (Road road : roads) {
      road.display_road(pixels_per_meter);
    }
    return this;
  }

  World display_cars(float pixels_per_meter) {
    for (Car car : cars) {
      car.display_car(pixels_per_meter);
    }
    return this;
  }
}
