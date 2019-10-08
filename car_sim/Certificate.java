package Certificate;

import java.util.ArrayList;
//import Car_Info.Car_Info;

//import java.io.*;
//import java.lang.Math; 

public class Certificate {
  float speed_timestamp;
  float speed;
  
  float lidar_timestamp;
  float lidar_range;
  //ArrayList<Car_Info.Car_Info> lidar_points;
  
  float d; // what the planner claims is the distance between ego car and lead car 
  
  float x; // what the planner claims is the current x-position of the ego car
  float y; // what the planner claims is the current y-position of the ego car
  
  public Certificate() {
  }
  
  public void increment_speed_timestamp(float dt) {
    speed_timestamp += dt;
  }
  
  public float get_speed_timestamp() {
    return speed_timestamp;
  }
  
  public float get_speed() {
    return speed;
  }
  
  public void increment_lidar_timestamp(float dt) {
    lidar_timestamp += dt;
  }
  
  public float get_lidar_timestamp() {
    return lidar_timestamp;
  }
  
  //public ArrayList<Car_Info.Car_Info> get_lidar_points() {
  //  return lidar_points;
  //}
  
  public float get_d(){
    return d;
  }
}
