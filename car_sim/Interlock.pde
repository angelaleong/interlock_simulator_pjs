class Interlock {
  float clock; // tracks time elapsed
  float t_threshold = 0.5;
  float MAX_DECEL;
  
  Interlock(float t, float max_decel) {
    clock = t;
    MAX_DECEL = max_decel;
  }
  
  float timestep(float dt, float c_clock, boolean brake, float cur_accel, float c_accel, ArrayList<Car_Info> evidence) {
    clock += dt;
    if (abs(c_clock - clock) > t_threshold) return -MAX_DECEL; // if controller has been offline for longer than the threshold period
    
    if (!brake) { // if the controller does not suggest that the car brake... 
      if (evidence.isEmpty()) { // ... AND provides evidence of no cars ahead
        return c_accel; // then the interlock accepts the controller's suggested acceleration
      } else { // ... BUT there is evidence of another car ahead
        println(Float.toString(clock) + ": BRAKE");
        return -MAX_DECEL; // then the interlock triggers braking
      }
    }
    //} else { // if controller wants the car to brake...
    //  if (evidence.isEmpty()) { // .. BUT there is no evidence of another car ahead
    //    println(Float.toString(clock) + ": DON'T BRAKE");
    //    return cur_accel;
    //  } else { // ... AND there is evidence of another car ahead
    //    return c_accel;
    //  }
    //}
    return c_accel;
  }
  
}
