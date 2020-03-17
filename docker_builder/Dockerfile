# Use plain ubuntu image as base
FROM docker.io/ubuntu:18.04 as ros-base
ENV DEBIAN_FRONTEND=noninteractive

# Add packages.bit-bots.de to apt
RUN apt-get update && \
    apt-get install -y gnupg2
ADD packages.bit-bots.de.list /etc/apt/sources.list.d/packages.bit-bots.de.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4C4EDF893374591687621C75C2F8DBB6A37B2874

# Install ros
RUN apt-get update && \
    apt-get install -y ros-melodic-ros-base python3-empy

# Install system dependencies
RUN apt-get update && \
    apt-get install -y sudo python3-pip python3-pip python3-coverage python-xmlrunner python3-rospkg python3-catkin-pkg python3-catkin-lint python3-rosdep dia python3-sphinx python3-sphinx-rtd-theme python3-breathe python3-rospkg git
RUN python3 -m pip install exhale git+https://github.com/catkin/catkin_tools

# Install sudoers file
ADD sudoers /etc/sudoers

# Add user
ARG UID=150
RUN useradd -M -d /catkin_ws -s /bin/bash -u $UID builder

# Build empty install space in shared install space
ARG SHARED_INSTALL_SPACE="/srv/catkin_install"
RUN . /opt/ros/melodic/setup.sh && \
    mkdir -p /catkin_ws/src && cd /catkin_ws && \
    catkin init >/dev/null && \
    catkin config -DPYTHON_VERSION=3 && \
    catkin config --install --merge-install --install-space $SHARED_INSTALL_SPACE >/dev/null && \
    catkin build && \
    chown -R builder:builder $SHARED_INSTALL_SPACE && \
    rm -r /catkin_ws

# Setup catkin workspace
RUN . /opt/ros/melodic/setup.sh && \
    mkdir -p /catkin_ws/src; cd /catkin_ws && \
    catkin init && \
    catkin config -DPYTHON_VERSION=3 && \
    catkin config --profile default --extend $SHARED_INSTALL_SPACE --install --isolate-install && \
    catkin config --profile install --extend $SHARED_INSTALL_SPACE --install --merge-install --install-space $SHARED_INSTALL_SPACE && \
    catkin build && \
    chown -R builder:builder /catkin_ws && \
    chmod -R 740 /catkin_ws

# Setup rosdep
RUN rosdep init
RUN su -c "rosdep update" builder

# Setup runtime
ENV DEBIAN_FRONTEND=readline
VOLUME ["/srv/catkin_install"]
USER builder:builder
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
