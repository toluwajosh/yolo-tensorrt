cmake_minimum_required(VERSION 3.1) 
project(yolov3-trt)            

file(GLOB_RECURSE sources     	modules/*.hpp modules/*.cpp modules/*.h modules/*.cu extra/*.h)
add_executable(yolov3-trt samples/sample_detector.cpp)

find_Package(gflags REQUIRED)

if(gflags_FOUND)
message("-- gflags found")
endif()

set(CMAKE_CXX_COMPILIER "/usr/bin/g++")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wno-write-strings")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-rpath -Wl,$ORIGIN")

#cudaS
find_package(CUDA REQUIRED)

message("-- CUDA version:$(CUDA_VERSION)")

if(CUDA_VERSION_MAJOR GREATER 9)
	message("-- CUDA ${CUDA_VERSION_MAJOR} detected")
	set(
		CUDA_NVCC_FLAGS
		${CUDA_NVCC_FLAGS}; 
		-gencode arch=compute_53,code=sm_53
	)
find_package(OpenCV 4 REQUIRED)
endif()

# TensorRT
find_path(TENSORRT_INCLUDE_DIR NvInfer.h
  HINTS ${TENSORRT_ROOT} ${CUDA_TOOLKIT_ROOT_DIR}
  PATH_SUFFIXES include)
MESSAGE(STATUS "Found TensorRT headers at ${TENSORRT_INCLUDE_DIR}")
find_library(TENSORRT_LIBRARY_INFER nvinfer
  HINTS ${TENSORRT_ROOT} ${TENSORRT_BUILD} ${CUDA_TOOLKIT_ROOT_DIR}
  PATH_SUFFIXES lib lib64 lib/x64)
find_library(TENSORRT_LIBRARY_INFER_PLUGIN nvinfer_plugin
  HINTS  ${TENSORRT_ROOT} ${TENSORRT_BUILD} ${CUDA_TOOLKIT_ROOT_DIR}
  PATH_SUFFIXES lib lib64 lib/x64)
if(WIN32)
  find_library(TENSORRT_LIBRARY_MYELIN myelin64_1
    HINTS  ${TENSORRT_ROOT} ${TENSORRT_BUILD} ${CUDA_TOOLKIT_ROOT_DIR}
    PATH_SUFFIXES lib lib64 lib/x64)
else()
  find_library(TENSORRT_LIBRARY_MYELIN myelin
    HINTS  ${TENSORRT_ROOT} ${TENSORRT_BUILD} ${CUDA_TOOLKIT_ROOT_DIR}
    PATH_SUFFIXES lib lib64 lib/x64)
endif()
set(TENSORRT_LIBRARY ${TENSORRT_LIBRARY_INFER} ${TENSORRT_LIBRARY_INFER_PLUGIN} ${TENSORRT_LIBRARY_MYELIN})
MESSAGE(STATUS "Find TensorRT libs at ${TENSORRT_LIBRARY}")
find_package_handle_standard_args(
  TENSORRT DEFAULT_MSG TENSORRT_INCLUDE_DIR TENSORRT_LIBRARY)
if(NOT TENSORRT_FOUND)
  message(ERROR "Cannot find TensorRT library.")
endif()


cuda_add_library(detector SHARED ${sources})
target_include_directories(detector
							PRIVATE
							modules/
							extra/
							gflags::gflags
							${OpenCV_INCLUDE_DIRS}
							${CUDA_TOOLKIT_ROOT_DIR}/include
							${TENSORRT_INCLUDE_DIR}
							${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES})

# target_link_libraries(${OpenCV_LIBS}) # or the next one?
# target_link_libraries(${OpenCV_LIBRARIES})
target_include_directories(yolov3-trt PRIVATE modules/ extra/)
target_link_libraries(detector nvinfer nvinfer_plugin nvcaffe_parser gflags "stdc++fs" ${TENSORRT_LIBRARY} ${OpenCV_LIBS})
				   
if(CUDA_VERSION_MAJOR GREATER 9)
	target_link_libraries(yolov3-trt detector opencv_core opencv_calib3d opencv_dnn)
endif()





