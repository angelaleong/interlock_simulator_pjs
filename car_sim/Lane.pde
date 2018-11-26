class Lane{
  PVector a, b;
  float w;
  float orientation;
  float l;
  Path path;
  
  Lane(PVector start, PVector end, float w_){
    a = start;
    b = end;
    w = w_;
    orientation = PVector.sub(b, a).heading();
    l = PVector.sub(b, a).mag();
    path = new Path(a, orientation);
  }
  
  void draw_lane(boolean selected){
    
    pushStyle();
    rectMode(CENTER);
    noStroke();
    fill(70);
    if (selected) fill(155);
    pushMatrix();
    translate(pixels_per_meter*0.5*(a.x+b.x), pixels_per_meter*0.5*(a.y+b.y));
    rotate(orientation);
    rect(0,0, l*pixels_per_meter, w*pixels_per_meter);
    fill(195,195,0);
    rect(0,0.5*w*pixels_per_meter,l*pixels_per_meter, 0.5*pixels_per_meter);
    rect(0,-0.5*w*pixels_per_meter,l*pixels_per_meter, 0.5*pixels_per_meter);
    popMatrix();
    popStyle();
  }
}
