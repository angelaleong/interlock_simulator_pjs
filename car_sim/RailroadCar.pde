class RailroadCar extends Car {

  RailroadCar(Road road, float offset) {
    super();
    orientation = road.orientation;
    position = new PVector(road.x_start, road.y_start);
    PVector d = new PVector(offset, 0);
    d.rotate(orientation);
    position.add(d);
  }

  RailroadCar timestep(float dt) {
    speed = (speed + acceleration*dt > 0) ? speed + acceleration * dt : 0;

    PVector d = new PVector(dt*speed, 0);
    d.rotate(orientation);
    position.add(d);

    check_collision();

    return this;
  }
}
