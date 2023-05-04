cmake_minimum_required(VERSION 3.25)
project(Markov-Decision-Problems)

set(CMAKE_CXX_STANDARD 14)

add_executable(markov-decision-problems main.cpp)
target_compile_options(markov-decision-problems PRIVATE -Wall -Wextra -pedantic -Werror)