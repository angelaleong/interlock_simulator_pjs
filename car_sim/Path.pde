class Path{
  PVector origin;
  float orientation;
  float margin = 0.1;
  float m;
  
  Path(PVector a, float b){
    origin = a;
    orientation = b;
    m = tan(b);
  }
  
  float dist_to_path(PVector pos){
    PVector ref = new PVector(1,0);
    float d = (PVector.sub(pos, origin).cross(ref.rotate(orientation)).z > 0 ? 1 : -1) * (abs(m*pos.x - pos.y - m*origin.x + origin.y)/sqrt(m*m+1));
    return d;
  }

}
