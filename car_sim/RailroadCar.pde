class RailroadCar extends Car {
  Lane cur_lane;
  RailroadCar(Road road, int which_lane, float offset) {
    super();
    if (which_lane >= road.lanes.size()){
      println("Selected lane (" + str(which_lane) + ") is not in road (max " + str(road.lanes.size()-1) + ")");
    }
    cur_lane = road.lanes.get(which_lane);
    orientation = cur_lane.orientation;
    position = new PVector(cur_lane.a.x, cur_lane.a.y);
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
