======
Vision
======

The observation of the environment and accurate detection of
various objects is made possible by multiple specialized modules
that form our vision.
Each module is responsible for identifying or classifying a
specific aspect of the picture for further feature extraction,
creating a structure that allows the modules to function mostly
independent from each other and only use other modules end results.

Starting the Vision
===================

Starting the vision using terminals:

Terminal 1:
::
    # If you do not source ROS in your .zshrc you need to do this first (not recomended).
    cd catkin_ws
    source devel/setup.zsh

    roslaunch bitbots_vision_common vision_startup.launch debug:=true


- *catkin_ws* is the name of the folder in which the source (src) of *bitbots_meta* is located.
- *zsh* is the name of the shell that is used. *bash* is the default shell for Ubuntu
- the parameters at the end of the last line can be excluded; their default value is false
    - *debug*:  activates publishing of several debug images
    - *sim*: activates simulation time, switches to simulation color settings and deactivates launching of an image provider
    - *dummyball*: does not start the ball detection to save resources
    - *camera*: launches an image provider to get images from a camera (unless sim:=true)
    - *basler*: launches the basler camera driver instead of the wolves image provider
    - *use_game_settings*: loads additional game settings

Terminal 2:
::
    # If you do not source ROS in your .zshrc you need to do this first (not recomended).
    cd catkin_ws
    source devel/setup.zsh
    # Launch the ROS rqt tool
    rqt

This starts the visual display for the debug information. Now select the image plugin and the `debug_image` topic to view the debug image.

To configure the vision launch the dynamic reconfigure plugin and select the vision node. These changes are only temporarly.

Terminal 3:
::
    # Now you see why its recomended to add it into the .zshrc...
    cd catkin_ws
    source devel/setup.zsh

    rosbag play <PATH to your ROS bag> -l


Modules
=======

**DebugImage** (debug.py)

The debug module creates useful debug information using cv2 if *debug* is
set to *true* when starting the vision or debugging options are selected in dynamic reconfigure.
It is capable of displaying the normal and convex field boundary
(red and yellow lines), the best and discarded ball candidates
(green and red circles), the goalposts (white bounding boxes), and different obstacles
(black: unknown, red: red robot, blue: blue robot).

**RuntimeEvaluator** (evaluator.py)

This module calculates the average time a method (e.g. get_candidates)
needs to work on a single image. It thereby allows improved evaluation
and comparison of different methods. In order to use it you need to import
the RuntimeEvaluator to your class and call
*self._runtime_evaluator.start_timer()* before
and *self._runtime_evaluator.stop_timer()* after the method you want to test.
Use *self._runtime_evaluator.print_timer()*.

**FCNN03** (live_fcnn_03.py)

Tensorflow network definition of the FCNN03 model.

**CandidateFinder** (candidate.py)

The CandidateFinder is an abstract class that requires its subclasses
to contain the methods *get_candidates()* and *get_top_candidates()*.
For example subclasses are *ObstacleDetector*,
*DummyClassifier*, *FcnnHandler* and *YOLOHandler*.
They usually produce a set of so called *Candidates* which are instaces of the
*Candidate* class which is also defined there and provdes different getters for
different propaties of the candidate.

**FcnnHandler** (fcnn_handler.py)

The FCNN handler runs the FCNN neural network and manages its predictions.

**DummyClassifier** (dummy_ballfinder.py)

This CandidateFinder returns an empty set of ball candidates and therefore
replaces the ordinary ball detection.
It is only used if *dummyball* is set to *true* when starting the vision.
The DummyClassifier is useful for debugging as you don't always want the
ball detection to slow down the vision and create unnecessary debug info.


**ColorDetector** (color.py)

As many of the modules rely on the color classification of
pixels to generate their output, the color detector module matches their
color to a given color space. These color spaces are configured for the colors of
the field or objects like goalposts and team markers. Two types of color space
definitions are implemented:

Either it is defined by minimum and maximum values of all three HSV channels
or by predefined lookup tables (provided asa Pickle file or YAML, a data-serialization language).
The HSV color model is used for the representation of white and the robot marker colors, red and blue.
The values of the HSV channels can be easily adjusted by a human before a competition
to match the white of the lines and goal or the team colors of the enemy team respectively.
This is necessary as teams may have different tones of red or blue as their marker color.
On the other hand, the color of the field is provided as a YAML or
Pickle file to include more various and nuanced tones of green.

**FieldBoundary** (field_boundary.py)

The task of the field boundary detector module is the localisation of the edges
of the field. It returns a list of points that form this so called field boundary.
It requires the ColorDetector to find the green pixels that resemble
the field in the picture.
The green pixels of the ordinary horizon are found by traversing the picture
from left to right and from top to bottom in steps of a given length.
Because obstacles obscure the edges of the field however, sometimes the
first green pixel from the top of the picture is found at the bottom
of the respective obstacle.
Therefore not all of the points lie in a straight line and the horizon
contains multiple dents.
Additionally white field markings and green pixels in the field that
are falsely not part of the field color set can rarely create small dents too.
Besides the normal horizon, the HorizonDetector can also create a convex
horizon that forms a convex hull over the dents of the normal horizon and
therefore is completely straight (with the exception of the corners
of the field).


**LineDetector** (lines.py)

The line detection module is responsible for finding the white field markings
that are especially important for the localisation of the robot.
It mainly uses the ColorDetector and HorizonDetector because white lines
should only be found on the field (and therefore under the horizon).
At first the module creates lists of random x and y coordinates
below the horizon and then checks wherever the resembling points are part
of the white color mask. Afterwards a list is returned that contains
these white points that are most likely part of a white field marking.

**LineDetector2** (lines2.py)

**ObstacleDetector** (obstacle.py)

The obstacle detection module is a CandidateFinder that is capable
of finding obstructions including robots and goalposts. In order to perform
its task it uses the HorizonDetector or more specifically the horizon and/or
convex horizon depending on the method used. Given that the horizon contains
dents where objects obstruct the edge of the field and consists of a list
of points, the obstacle detection module can find these objects by comparing
the height of adjacent horizon-points. Alternatively objects can be found by
measuring the distance between the ordinary horizon and the convex horizon
which is a slightly less efficient but more accurate method.

**ObstaclePostDetector** (goalpost.py)

The obstacle post detection module is a CandidateFinder that uses the
ColorDetector and ObstacleDetector in order to fing goalposts. Instead of
finding the goalposts on its own, this module converts white candidates
given by the ObstacleDetection into so called expanded candidates that
resemble goalposts.


