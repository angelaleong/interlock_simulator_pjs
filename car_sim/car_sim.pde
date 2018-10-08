//import controlP5.*;

Car test;

float seconds_per_frame = 1/60.0;
float pixels_per_meter = 4.705;

void setup() {
  size(1280, 740, P2D);
  test = new Car();
}

void draw() {
  test.timestep(seconds_per_frame);
  background(255);
  pushMatrix();
  translate(width/2, height/2);
  test.display_car(pixels_per_meter);
  popMatrix();
}

void keyPressed() {
  if (key == 'a') {
    test.boolean_steering(-0.01);
  }
  if (key == 'd') {
    test.boolean_steering(0.01);
  }
  if (key == 'w') {
    test.accelerate(8);
  }
  if (key == 's') {
    test.accelerate(-8);
  }
  if (key == '=' || key == '+'){
    pixels_per_meter += 1;
  }
  if (key == '-' || key == '_'){
    pixels_per_meter -= 1;
  }
}

void keyReleased() {
  if (key == 'a' || key == 'd') {
    test.boolean_steering(0);
  }
  if (key == 'w') {
    test.accelerate(0);
  }
  if (key == 's') {
    test.accelerate(0);
  }
}

//class Car{
//    // TODO: eventually want to read in these params from a file
//    PVector position = new PVector(0,0);
//    float acceleration = 0;

//    float orientation = 0;  // angle w.r.t world X axis
//    float steering_angle = 0;  // positive for left, negative for right
//    float steering_command = 0;

//    float speed = 10;  // a scalar, since we're always moving in the
//                           // car's steering direction
    
//    float MAX_STEERING_DELTA = 1;  // maximum steering that can be applied, 
//                                     // radians/s per second
//    float rear_axle_offset = - 1.35;
//    float front_axle_offset = 1.35;
    
//    float WIDTH = 1.7;  // width in meters
//    float LENGTH = 4.5; 

//    color paint = color(255,0,0);
//    float tire_width = 0.215;  // meters
//    float tire_diameter = 0.66;  // meters

//    float ongoing_steer = 0;
    
//    Car(){
//        // instantiation
//    }

//    Car set_init_orientation(float a){
//        orientation = a;
//        return this;
//    }

//    Car set_init_position(PVector a){
//        position = a.copy();
//        return this;
//    }

//    Car set_init_speed(float a){
//        speed = a;
//        return this;
//    }

//    Car apply_steering_command(float angle){
//        steering_command = angle;
//        return this;
//    }

//    float ackermann_turn_radius(float steering_angle){
//        if (steering_angle != 0){
//            float axle_d = abs(front_axle_offset) + abs(rear_axle_offset);
//            return  axle_d / tan(steering_angle);
//        }
//        return 0;
//    }

//    Car boolean_steering(float dir){
//        ongoing_steer = dir;
//        return this;
//    }
    
//    Car accelerate(float accel){
//      acceleration = accel;
//      return this;
//    }

//    Car timestep(float dt){
//        speed = (speed + acceleration*dt > 0) ? speed + acceleration * dt : 0;
//        float steer_dt = MAX_STEERING_DELTA*dt; 
//        if (ongoing_steer != 0){
//            if (abs(steering_command + ongoing_steer) < PI/6){
//                steering_command += ongoing_steer;
//            }
//        }
//        // steering will increase/decrease until matches input steering command,
//        if (steering_angle < steering_command && steering_angle + steer_dt < steering_command){
//            steering_angle += steer_dt;
//        }
//        else if (steering_angle > steering_command && steering_angle - steer_dt > steering_command){
//            steering_angle -= steer_dt;
//        } else {
//          steering_angle = steering_command;
//        }

//        float r = ackermann_turn_radius(steering_angle);  // meters
        
//        // adjust orientation and position if turning
//        if (r != 0){
//            float th = abs(dt*speed/r);
//            PVector d = new PVector(abs(r) * sin(th), r - r*cos(th));
//            d.rotate(orientation);
//            position.add(d);
//            orientation += r*th/abs(r);
//        } else {
//          PVector d = new PVector(dt*speed, 0);
//          d.rotate(orientation);
//          position.add(d);
//        }
        
//        return this;
//    }

//    void display_car(float pixels_per_meter){
//        // convert all meter measurements to pixels!
//        pushMatrix();
//        translate(position.x*pixels_per_meter, position.y*pixels_per_meter);
//        rotate(orientation);
//        stroke(255,0,0);
//        line(0,0,50, 0);   // positive x dir
//        stroke(0,0,255);
//        line(0,0,0, 50);   // positive y dir
//        rectMode(CENTER);
//        noStroke();
//        fill(paint);
//        rect(0,0, LENGTH*pixels_per_meter, WIDTH*pixels_per_meter);

//        stroke(0);
//        line(rear_axle_offset*pixels_per_meter, 0, 
//            rear_axle_offset*pixels_per_meter,ackermann_turn_radius(steering_angle)*pixels_per_meter);
        
//        // rear wheels
//        fill(0);
//        rectMode(CENTER);
//        rect(rear_axle_offset*pixels_per_meter, WIDTH*pixels_per_meter*0.5, tire_diameter*pixels_per_meter, tire_width*pixels_per_meter);
//        rect(rear_axle_offset*pixels_per_meter, -WIDTH*pixels_per_meter*0.5, tire_diameter*pixels_per_meter, tire_width*pixels_per_meter);

//        // front wheels
//        pushMatrix();
//        translate(front_axle_offset*pixels_per_meter, WIDTH*pixels_per_meter*0.5);
//        rotate(steering_angle);
//        rect(0, 0, tire_diameter*pixels_per_meter, tire_width*pixels_per_meter);
//        popMatrix();

//        pushMatrix();
//        translate(front_axle_offset*pixels_per_meter, -WIDTH*pixels_per_meter*0.5);
//        rotate(steering_angle);
//        rect(0, 0, tire_diameter*pixels_per_meter, tire_width*pixels_per_meter);
//        popMatrix();
        


//        // display the steering angle
//        translate(front_axle_offset*pixels_per_meter,0);
//        rotate(steering_angle);
//        stroke(0,255,0);
//        line(0,0,50,0);
//        popMatrix();
        
//    }
//}

////void gui_setup() {
////  ControlP5 cp5 = new ControlP5(this);
////  cp5.addSlider("pixels_per_meter")
////    .setPosition(10,10)
////    .setSize(10,500)
////    .setRange(0.01,6)
////    .setValue(4.705);
////}
////
