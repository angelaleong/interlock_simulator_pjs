class Road{
  ArrayList<Lane> lanes = new ArrayList<Lane>();
  PVector a, b;
  Road(int num_lanes, PVector start, PVector end, float lane_w){
    a = start;
    b = end;
    PVector ortho = PVector.sub(b, a).rotate(PI/2);
    int j = 0;
    for (float i = -0.5*lane_w*(num_lanes-1); i <= 0.5*lane_w*(num_lanes-1); i+=lane_w){
      PVector delta = ortho.copy();
      delta.setMag(i);
      lanes.add(new Lane(PVector.add(a, delta), PVector.add(b, delta), lane_w, j));
      j++;
    }
  }
  void draw_road(){
    for (Lane lane : lanes) {
      lane.draw_lane(false);
    }
  }
}
