#!/bin/bash
set -e

export ROS_PYTHON_VERSION=3
source /opt/ros/melodic/setup.bash
source /catkin_ws/devel/setup.bash

exec "$@"
