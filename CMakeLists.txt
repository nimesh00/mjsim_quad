cmake_minimum_required(VERSION 3.5.1)
project(mjsim_quad)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(COMMON_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/custom/include)
set(COMMON_LIBRARY_DIR ${CMAKE_SOURCE_DIR}/custom/lib)
set(COMMON_INSTALL_DIR ${CMAKE_SOURCE_DIR}/custom/install)

list(APPEND CMAKE_INSTALL_RPATH ${COMMON_INSTALL_DIR}/lib)
list(APPEND CMAKE_INSTALL_RPATH ${COMMON_LIBRARY_DIR})


# INTERPROCEDURAL_OPTIMIZATION is enforced when enabled.
set(CMAKE_POLICY_DEFAULT_CMP0069 NEW)
# Default to GLVND if available.
set(CMAKE_POLICY_DEFAULT_CMP0072 NEW)

set(OpenGL_GL_PREFERENCE GLVND)

# set(mujoco_DIR ${COMMON_INSTALL_DIR}/lib/cmake/mujoco)
# set(THREADS_PREFER_PTHREAD_FLAG ON)

# find_package(mujoco CONFIG REQUIRED)
find_package(glfw3 REQUIRED)
find_package(Threads REQUIRED)

if(DEFINED ENV{USE_ROS_COMM})
    find_package(rclcpp REQUIRED)
    find_package(sensor_msgs REQUIRED)
    find_package(nav_msgs REQUIRED)
    find_package(geometry_msgs REQUIRED)
    find_package(std_msgs REQUIRED)
endif()

set(ROS_INCLUDE /opt/ros/$ENV{ROS_DISTRO}/include)


include_directories(
    ${COMMON_INSTALL_DIR}/include
    include
)

link_directories(${COMMON_INSTALL_DIR}/lib)


add_library(quad_communication SHARED
    src/communication/CommunicationManager.cpp
    src/communication/SHM.cpp
)

if(DEFINED ENV{USE_ROS_COMM})
    add_library(ros_comm SHARED
    src/communication/QuadROSComm.cpp
    )
    target_link_libraries(ros_comm
        ${rclcpp_LIBRARIES}
        ${sensor_msgs_LIBRARIES}
        ${nav_msgs_LIBRARIES}
        ${geometry_msgs_LIBRARIES}
        ${std_msgs_LIBRARIES}
    quad_communication
    )
    install(TARGETS
    ros_comm
    ARCHIVE DESTINATION ${COMMON_LIBRARY_DIR}
    LIBRARY DESTINATION ${COMMON_LIBRARY_DIR}
    )
endif()

add_executable(simulate src/sim_main.cpp)
if (DEFINED ENV{USE_ROS_COMM})
    add_definitions(-DUSE_ROS_COMM)
endif()
add_dependencies(simulate quad_communication)
target_link_libraries(simulate
    # mujoco::mujoco
    mujoco
    glfw
    Threads::Threads
    quad_communication
)
if (DEFINED ENV{USE_ROS_COMM})
    target_link_libraries(simulate
        ros_comm
    )
endif()
install(TARGETS simulate
    ARCHIVE DESTINATION ${COMMON_INSTALL_DIR}
    RUNTIME DESTINATION ${COMMON_INSTALL_DIR}
)
