package Car_Info;
public class Car_Info {
  public float x, y, orientation, w, l;
  public Car_Info(float x_, float y_, float orientation_, float w_, float l_) {
    x = x_;
    y = y_;
    orientation = orientation_;
    w = w_;
    l = l_;
  }
  public float get_x() {
    return x;
  }
  public float get_y() {
    return y;
  }
  public float get_orientation(){
    return orientation;
  }
  public float get_w(){
    return w;
  }
  public float get_l(){
    return l;
  }
}
