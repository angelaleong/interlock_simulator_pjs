package PointController;
import java.util.ArrayList;
import java.lang.Math;

public class PointController{
    double last_d_angle = 0; 
    double p_gain = 0.25;
    double d_gain = 0.0;

    public PointController(){
    }
    public double[] calcServoCommands(double x, double y, double orientation, double[] goal){
        double dx = x - goal[0];
        double dy = y - goal[1];
        double angle_to_goal = Math.atan(dy/dx) - Math.PI; 
        double angle_diff = angle_to_goal - orientation;
        if (angle_diff > Math.PI) {
            angle_diff -= 2*Math.PI;
        } else if (angle_diff < -Math.PI){
            angle_diff += 2*Math.PI;
        }

        double[] result = {0,0};
        result[0] = p_gain*angle_diff;
        result[1] = goal[2];

        return result;
    }
}
