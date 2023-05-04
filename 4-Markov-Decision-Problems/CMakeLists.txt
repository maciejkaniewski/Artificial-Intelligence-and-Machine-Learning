cmake_minimum_required(VERSION 3.25)
project(Markov-Decision-Problems)

set(CMAKE_CXX_STANDARD 17)

include_directories(inc)

set(SOURCES src/main.cpp src/World.cpp)

add_executable(markov-decision-problems ${SOURCES})
target_compile_options(markov-decision-problems PRIVATE -Wall -Wextra -pedantic -Werror)