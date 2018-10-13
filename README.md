# **ProcessingJS Interlock Simulator**

## **What are Processing and ProcessingJS?**
**[Processing](https://processing.org/)**: A language for graphic design and animation, built on top of Java and uses Java syntax.

**[ProcessingJS](http://processingjs.org/)**: Processing ported to JavaScript for ease of web use, can run native Processing files (*.pde) as JavaScript, just develop as you would with Processing and deploy using ProcessingJS. **WARNING** since ProcessingJS is in Javascript, it cannot import libraries written for Processing since those libraries are in Java.

## **Simulator Overview**

`processing.min.js` is the ProcessingJS source code, this is necessary for html to properly interpret and run native Processing code.

`interlock_simulator.html` contains all the html necessary to run the simulator. At minimum it only requires 2 lines:

```html
<script src="processing.min.js" type="text/javascript"></script>
<canvas data-src="car_sim/car_sim.pde car_sim/Car.pde"></canvas>
```

Note that line 2 has 2 files separated by a space. This is a space separated
list of all the source files needed for the Processing sketch.

`car_sim/` contains the Processing files that comprise the simulator. The
main file, `car_sim.pde`, can be run as a Java app from the Processing IDE
for ease of development and debugging. Inside of `car_sim` we have:
 - `car_sim.pde` contains the setup block and main loop.
 - `Car.pde` contains the definition of the Car class, an instance of which
 is an individual car, complete with steering, acceleration, and
 initializaiton methods. Each Car object must belong to a World object in order
 to use its collision check methods.
 - `World.pde` contains the definition of the World class, which should
 have methods to setup, run, and reset individual scenarios. Currently, cars
 can be added to the world, and all of them time-stepped and displayed using
 a single method. An occupancy grid is also implemented, allowing for collision
 detection (currently working) and line of sight calculations (in the occluded
 scenarios, not yet implemented)

## **Running the simulator**
Once you've cloned the repo go to repo directory and run
- `python -m SimpleHTTPServer` (for Python 2)
- `python -m http.server` (for Python 3)
 (Any Mac should have this natively installed.)
This will serve that directory on localhost. Point your browser to **http://localhost:8000/interlock_simulator.html** to start the simulation. **Works better on Chrome than Safari**

## **Using the simulator**
Currently, the simulator takes in steering commands via the A and D keys for left and rightward steering, respectively. W and S accelerate and decelerate. Make sure to click on the animation area first before trying keyboard input.

## **Issues Encountered**
 - Cannot import Processing libraries
 - IntList.hasValue() does not exist in ProcessingJS
 - ArrayList.contains() seems to be broken

## **Scenario: ego car behind lead car in a single lane**
 - I simulated a single lane scenario by adding a Car subclass called SingleLaneFollower to the x-axis where the stationary car is, and constraining its movements to the x-axis (i.e. no steering) so it approaches the stationary car at a constant, initial speed.
 - This SingleLaneFollower (green car that starts at left of screen) will slow down to a stop as it reaches the stationary car. I used Justine’s formula from the slides and in the [interlock.cc](https://github.com/justinej/drake/blob/master/automotive/interlock.cc) file in her fork of the drake repo to trigger interlock and apply the maximum braking deceleration when the separation distance dips below the stopping distance.
 - There is no IDM controller or equivalent at the moment, but you can speed up/slow down the ego car with the L/K keys. The ego car will still slow down to a stop before colliding with the stationary car. They do end up really close, but you can check for collisions in the console (indicated by "COLLISION").
 - You can also check the ego car speed, separation distance, and stopping distance in the console.

### Issues:
 - Justine’s formula uses the sensed distance (between the cars) and the sensed velocity of the ego car, but this simulation currently uses actual values of both. Perhaps an adjustable error term can be added to represent differences in the sensed and actual values.
 - The Interlock check for separation distance < stopping distance is in currently in the Car.timestep() method, which as I understand chains the Interlock period to the frame rate of the simulation. Next step is to find a way to run Interlock at its own frequency.
 - Separation distance is calculated using the leftmost pixel occupied the stationary car and the rightmost pixel occupied by the ego car. This works for this simple road geometry, but if the cars are oriented differently I believe the correct calculation would require finding the minimum distance between the two sets of points occupied by the two cars. That might be helpful for the case of unstructured roads. 
