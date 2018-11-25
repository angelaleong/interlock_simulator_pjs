class Road {

  float x_start, y_start, x_end, y_end;
  float width;
  float orientation;  // angle w.r.t world X axis
  ArrayList<Car> cars = new ArrayList<Car>();
  color paint = color(192,192,192);

  // float curvature;
  // int priority;
  // ArrayList<Lane> lanes = new ArrayList<Lane>();

  Road(float x_start_, float y_start_, float x_end_, float y_end_, float width_) {
    x_start = x_start_;
    y_start = y_start_;
    x_end = x_end_;
    y_end = y_end_;
    width = width_;

    orientation = atan2(y_end - y_start, x_end - x_start);
  }

  Road add_car(RailroadCar car) {
    cars.add(car);
    return this;
  }

  void display_road(float pixels_per_meter) {
    pushMatrix();

    translate((abs(x_end+x_start)/2.0)*pixels_per_meter, (abs(y_end+y_start)/2.0)*pixels_per_meter);
    rotate(orientation);
    rectMode(CENTER);
    noStroke();

    fill(paint);
    float LENGTH = sqrt(pow((y_end - y_start), 2) + pow((x_end - x_start),2));
    rect(0, 0, LENGTH*pixels_per_meter, int(width*pixels_per_meter)%2==0 ?
         int(width*pixels_per_meter) : int(width*pixels_per_meter) + 1);

    popMatrix();
  }
}
