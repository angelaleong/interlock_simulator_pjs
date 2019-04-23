// CURRENT CASE:
// - ego car behind a lead car in a single lane

class Controller {
  float clock; // tracks time elapsed
  float LENGTH; // TODO: read from a file
  float MAX_DECEL; // TODO: read from a file
  
  boolean brake = false;
  float accel; // ACTION. for the CURRENT CASE, simply an acceleration output
  ArrayList<Car_Info> evidence; // EVIDENCE
  
  // parameters specific for CURRENT CASE
  PVector lead_car_last_pos; // TODO: substitute PVector usage for ROS integration
  float safe_sep;
  
  Controller(float t, float l, float max_decel) {
    clock = t;
    LENGTH = l;
    MAX_DECEL = max_decel;
  }
  
  void timestep(float dt, float cur_acc, ArrayList<Car_Info> cars,
                PVector position, float speed) {    
    // CASE 1: Controller is unresponsive
    //if (clock >= 2 && clock < 3) clock += 0;
    //else clock += dt;
    clock += dt;

    if (cars == null || cars.size() == 0) {
      brake = false;
      accel = cur_acc;
      evidence = new ArrayList<Car_Info>();
    } else { // check if lead car is within safe separation distance
      boolean safe = check(dt, cars, position, speed);
      if (safe) {
        
        // CASE 2: Controller tells car to brake when it shouldn't
        if (clock >= 2 && clock < 3) {
          brake = true;
          accel = -MAX_DECEL;
        } else {
          brake = false;
          accel = cur_acc;
        }
        //brake = false;
        //accel = cur_acc;
        evidence = new ArrayList<Car_Info>();
      } else {
        // CASE 3: Controller doesn't tell car to brake when it should
        //if (clock >= 2 && clock < 3) {
        //  brake = false;
        //  accel = cur_acc;
        //} else {
        //  brake = true;
        //  accel = -MAX_DECEL;
        //}
        brake = true;
        accel = -MAX_DECEL;
        evidence = cars;
      }
    }
  }
  
  boolean check(float dt, ArrayList<Car_Info> cars, PVector position, float speed) {
    if (lead_car_last_pos == null) {
      lead_car_last_pos = new PVector(cars.get(0).x, cars.get(0).y);
      return true;
    }
    
    PVector lead_car_cur_pos = new PVector(cars.get(0).x, cars.get(0).y);
    PVector d = PVector.sub(lead_car_cur_pos, lead_car_last_pos);
    float lead_car_v = d.mag()/dt;
    safe_sep = max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - lead_car_v*lead_car_v/(2.0*MAX_DECEL), +0.5*LENGTH); // Assume other car has same MAX_DECEL as ego car
    
    lead_car_last_pos = lead_car_cur_pos.copy();
    return PVector.sub(position, lead_car_cur_pos).mag()-0.5*cars.get(0).get_l()  >= (safe_sep + 0.1);
  }
  
}
