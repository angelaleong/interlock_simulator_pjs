package PathFollower;
import java.util.ArrayList;
import java.io.*;
import java.lang.Math; 

public class PathFollower{
    String config_file = null;
    // each element has 3 components: x, y, speed
    public ArrayList<double[]> waypoints = new ArrayList<double[]>();
     
    int last_waypoint = 0;
    public PathFollower(){
        this.last_waypoint = 0;
    }

    public PathFollower loadPathFromArrayList(ArrayList<double[]> waypoints){
        this.waypoints = waypoints;
        return this;
    }

    public PathFollower loadPathFromFile(String file)
      throws IOException {
        /* loads a path from a file, each line is a waypoint on the path
        each line is a comma delinated list of x,y,speed
        */
        BufferedReader reader = new BufferedReader(new FileReader(file));
        String current_line;
        while (true){
            current_line = reader.readLine();
            if (current_line == null){
                break;
            }
            String[] arr = current_line.split(",");
            double[] coords = {0, 0, 0};
            coords[0] = (double)Float.parseFloat(arr[0]);
            coords[1] = (double)Float.parseFloat(arr[1]);
            coords[2] = (double)Float.parseFloat(arr[2]);
            this.waypoints.add(coords);
        }
        return this;
    }

    public double[] pickNextPoint(double x, double y, double cur_speed){
        for (int i = this.last_waypoint; i < this.waypoints.size(); i++){
            double[] pt = this.waypoints.get(i);
            double d = this.d(pt[0], pt[1], x, y) - Math.max(0.25, cur_speed);
            if (d > 0){
                this.last_waypoint = i;
                return this.waypoints.get(i);
            }
        }
        System.out.println("could not find a point");
        return this.waypoints.get(this.last_waypoint);
    }
    public double d(double x1, double y1, double x2, double y2){
        return Math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
    }
}
