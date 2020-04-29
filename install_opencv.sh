sudo add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"
sudo apt update
sudo apt-get install -y build-essential \
                        cmake \
                        git \
                        libgtk2.0-dev \
                        pkg-config \
                        libavcodec-dev \
                        libavformat-dev \
                        libswscale-dev \
                        python-dev \
                        python-numpy \
                        libtbb2 \
                        libtbb-dev \
                        libjpeg-dev \
                        libpng-dev \
                        libtiff-dev \
                        libjasper1 \
                        libjasper-dev \
                        libdc1394-22-dev
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
cd opencv
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib ..