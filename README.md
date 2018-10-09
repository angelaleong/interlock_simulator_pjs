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
