package PointController;
import java.util.ArrayList;
import java.lang.Math;

public class PointController{
    double last_d_angle = 0; 
    double p_gain = 0.015;
    double d_gain = 0.0;

    public PointController(){
    }
    public double[] calcServoCommands(double x, double y, double orientation, double[] goal){
        double dx = goal[0] - x;
        double dy = goal[1] - y;
        double d_angle = Math.atan(dy/dx); 
        System.out.println("Orientation: "+orientation+", Goal angle: " + d_angle);

        d_angle -= orientation;  //TODO must verify the sign

        double d = dx*dx + dy*dy;

        double steer_effort = -(p_gain*d_angle + d_gain*(d_angle - this.last_d_angle));

        //System.out.println("Steer effort: "+steer_effort);

        this.last_d_angle = d_angle; 

        double[] result = {0,0};
        result[0] = steer_effort;
        result[1] = goal[2];

        return result;
    }
}
