cmake_minimum_required(VERSION 3.18)
project(Markov-Decision-Problems)

set(CMAKE_CXX_STANDARD 17)

include_directories(inc)

set(SOURCES_A src/mainValueIteration.cpp src/World.cpp src/ValueIterationAlgorithm.cpp inc/ValueIterationAlgorithm.h src/Plotter.cpp inc/Plotter.h)
set(SOURCES_B src/mainQLearning.cpp src/World.cpp src/Plotter.cpp inc/Plotter.h src/QLearning.cpp inc/QLearning.h)

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt. ")
endif()

find_package(Python3 COMPONENTS Interpreter Development NumPy REQUIRED)
find_package(PythonLibs 3.0 REQUIRED)
include_directories(${PYTHON3_INCLUDE_DIRS} ${NumPy_INCLUDE_DIRS})

include(FetchContent)
FetchContent_Declare(
        matplotlib
        GIT_REPOSITORY https://github.com/lava/matplotlib-cpp.git
        GIT_TAG        ef0383f1315d32e0156335e10b82e90b334f6d9f
)
FetchContent_GetProperties(matplotlib)
if(NOT matplotlib_POPULATED)
    FetchContent_Populate(matplotlib)
endif()
include_directories(SYSTEM ${matplotlib_SOURCE_DIR})

add_executable(value_iteration ${SOURCES_A})
add_executable(qlearning ${SOURCES_B})

target_compile_options(value_iteration PRIVATE -Wall -Wextra -pedantic)
target_compile_options(qlearning PRIVATE -Wall -Wextra -pedantic)

target_link_libraries(value_iteration
        PRIVATE
        ${PYTHON_LIBRARIES}
        Python3::NumPy
        )

target_link_libraries(qlearning
        PRIVATE
        ${PYTHON_LIBRARIES}
        Python3::NumPy
        )