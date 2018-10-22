class Car_Info {
  float x, y, orientation, w, l;
  Car_Info(float x_, float y_, float orientation_, float w_, float l_) {
    x = x_;
    y = y_;
    orientation = orientation_;
    w = w_;
    l = l_;
  }
  float get_x() {
    return x;
  }
  float get_y() {
    return y;
  }
  float get_orientation(){
    return orientation;
  }
  float get_w(){
    return w;
  }
  float get_l(){
    return l;
  }
}
