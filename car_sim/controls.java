import java.util.ArrayList;
import java.lang.Math; 

class Interlock{
    // for now, use mode to switch between different interlocks
    // 0: simple one lane 2 car scenario, braking distance scales with relative
    //    velocity 
    float max_decel;
    float max_accel;
    float length;
    float width;
    float T_s;
    ArrayList<Car_Info> old_cars = new ArrayList<Car_Info>();
    Interlock(float max_accel, float max_decel, float length, float width){
        this.max_accel = max_accel;
        this.max_decel = max_decel;
        this.length = length;
        this.width = width;
    }

    boolean is_scenario_safe(float T_s, float dt, float speed, float x, float y, ArrayList<Car_Info> cars){
        /*
        Evaluates if a scenario is safe given the interlock rules.
        dt: the time passed since interlock last ran
        cars: an arraylist of the cars detected, not including self
        */
        // implement interlock logic here to decide if the scenario is safe
        if (old_cars.size() < 1){
            this.old_cars = new ArrayList<>(cars);
            return true;
        }

        if (cars.size() > 1){
            // unhandled: we don't know what to do when there are multiple
            // cars on the road. 
            return false;
        }

        Car_Info lead_car = cars.get(0);
        double dx = (lead_car.x - this.old_cars.get(0).x);
        double dy = (lead_car.y - this.old_cars.get(0).y);

        float d = (float)Math.sqrt(dx*dx + dy*dy);
        float lead_car_v = d/dt;

        //safe_sep = max(speed*speed/(2.0*MAX_DECEL)+0.5*LENGTH - lead_car_v*lead_car_v/(2.0*MAX_DECEL), +0.5*LENGTH); // Assume other car has same MAX_DECEL as ego car
        //float safe_sep = max((float)(speed*speed/(2.0*this.max_accel)+.5*this.length - lead_car_v*lead_car_v/(2.0*this.max_decel)), (float)(.5*this.length));
        float safe_sep = (float)Math.max(speed*speed/(2.0*this.max_accel)+.5*this.length - lead_car_v*lead_car_v/(2.0*this.max_decel), .5*this.length);

        //sensor_envelope = speed*T_s + MAX_ACCEL*T_s*T_s/2 - lead_car_v*T_s + MAX_DECEL*T_s*T_s/2;
        float sensor_envelope = speed*T_s + this.max_accel*T_s*T_s/2 - lead_car_v*T_s + this.max_decel*T_s*T_s/2;
        boolean safe = d - .5*cars.get(0).get_l() >= (safe_sep + sensor_envelope + 0.1);
        this.old_cars = new ArrayList<>(cars);
        return safe;
    }
}

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
