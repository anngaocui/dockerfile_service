# create registry.cn-shenzhen.aliyuncs.com/tsinghua_gd/MonocularTotalCapture:base

# Pull base image.
FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

LABEL maintainer Aaron "aaronwlj@foxmail.com"

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    openssh-server
    
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-dev \
        python3-pip \
        git \
        g++ \
        make \
        wget \
        unzip \
        ffmpeg \
        vim

# pip 升级
# RUN python3 -m pip install --upgrade pip
    
# 安装基础库
RUN pip3 install -U setuptools \
    && pip3 --no-cache-dir install \
        numpy \
        pandas \
        scipy \
        scikit-learn \
        jupyterlab==1.0.2 \
        tqdm \
        matplotlib \
        imgaug
        
# Install tensorflow-gpu
RUN pip3 --no-cache-dir install tensorflow-gpu==1.5.0

# Install OpenCV
RUN pip3 --no-cache-dir install opencv-python==3.4.2.17

# CMake
RUN apt-get install -y cmake
# google-glog + gflags
RUN apt-get install -y libgoogle-glog-dev
# BLAS & LAPACK
RUN apt-get install -y libatlas-base-dev
# Eigen3
RUN apt-get install -y libeigen3-dev
# SuiteSparse and CXSparse (optional)
# - If you want to build Ceres as a *static* library (the default)
#   you can use the SuiteSparse package in the main Ubuntu package
#   repository:
RUN apt-get install -y libsuitesparse-dev
# - However, if you want to build Ceres as a *shared* library, you must
#   add the following PPA:
RUN add-apt-repository ppa:bzindovic/suitesparse-bugfix-1319687
RUN apt-get update
RUN apt-get install -y libsuitesparse-dev

# 安装openpose
# ENV
ENV PYTHON_EXECUTABLE="/usr/bin/python3.5"
ENV PYTHON_LIBRARY="/usr/lib/x86_64-linux-gnu/libpython3.5m.so"

# replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2-Linux-x86_64.tar.gz && \
tar xzf cmake-3.14.2-Linux-x86_64.tar.gz -C /opt && \
rm cmake-3.14.2-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"

# get openpose
WORKDIR /opt/openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

# build it
WORKDIR /opt/openpose/build
RUN cmake -DBUILD_PYTHON=ON .. && make -j8 && make install
WORKDIR /rootcat

# 删除 apt lists
RUN rm -rf /var/lib/apt/lists/*

# 终端设置
# 默认值是dumb，这时在终端操作时可能会出现：terminal is not fully functional
ENV TERM xterm

# 解决时区问题
ENV TZ "Asia/Shanghai"
