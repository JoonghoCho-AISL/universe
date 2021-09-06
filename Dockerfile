FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y libav-tools \
    python3-numpy \
    python3-scipy \
    python3-setuptools \
    python3-pip \
    libpq-dev \
    libjpeg-dev \
    curl \
    cmake \
    swig \
    python3-opengl \
    libboost-all-dev \
    libsdl2-dev \
    wget \
    unzip \
    git \
    golang \
    net-tools \
    iptables \
    libvncserver-dev \
    software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN ln -sf /usr/bin/pip3 /usr/local/bin/pip \
    && ln -sf /usr/bin/python3 /usr/local/bin/python \
    && pip install -U pip
    # && python -m pip install pip==20.2.2
# Solve Error
RUN git clone https://github.com/openai/mujoco-py.git
RUN apt-get update
RUN apt-get install -y libgl1-mesa-dev libgl1-mesa-glx libosmesa6-dev python3-numpy python3-scipy
RUN wget https://bootstrap.pypa.io/pip/3.5/get-pip.py
RUN python3 get-pip.py && python3 -m pip install pip==18.1
RUN pip install cffi
RUN pip install cython
RUN pip install lockfile
RUN pip install -r ./mujoco-py/requirements.txt
RUN cd mujoco-py && python3 setup.py install

RUN wget https://bootstrap.pypa.io/pip/3.5/get-pip.py
RUN python3 get-pip.py && python3 -m pip install pip==18.1
RUN apt-get install make
RUN apt -y purge python2.7-minimal

COPY ./mujoco200_linux/ /.mujoco/mujoco200
COPY ./mjkey.txt /.mujoco/
RUN cd ./.mujoco/mujoco200/ && pip3 install -U 'mujoco-py<2.1,>=2.0'

RUN pip install opencv-python

RUN pip3 install -U 'mujoco-py<2.1,>=2.0'

COPY ./mjpro150/ /root/.mujoco/mjpro150
COPY ./mjkey.txt /root/.mujoco/

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/root/.mujoco/mjpro150/bin"

RUN apt install patchelf
# Install gym
RUN pip install gym[all]

# Get the faster VNC driver
RUN pip install go-vncdriver>=0.4.0

# Install pytest (for running test cases)
RUN pip install pytest

# Force the container to use the go vnc driver
ENV UNIVERSE_VNCDRIVER='go'

WORKDIR /usr/local/universe/

# Cachebusting
COPY ./setup.py ./
COPY ./tox.ini ./

RUN pip install -e .

# Upload our actual code
COPY . ./

# Just in case any python cache files were carried over from the source directory, remove them
RUN py3clean .
