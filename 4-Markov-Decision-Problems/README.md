# Markov Decision Problems

Markov Decision Problems is a project I realized in the first semester of my Master's studies within the Artificial Intelligence and Machine Learning course at the Wroclaw University of Technology in the field of Control Engineering and Robotics.
The main goal of this task was to compute solutions to the discrete Markov decision problems (MDP). 
The task consists of two parts.
In the first part the program directly solve the MDP problem of known parameters using the value iteration method. 
In the second part the program solve the MDP of unknown parameters using the Q-learning method.

## Setup
Prerequisites:
* Installed CMake 
* Installed Python3 with numpy and matplotlib

Run `build.sh` script:

    ./build.sh 

Script output:

    -- The C compiler identification is GNU 11.3.0
    -- The CXX compiler identification is GNU 11.3.0
    -- Detecting C compiler ABI info
    -- Detecting C compiler ABI info - done
    -- Check for working C compiler: /usr/bin/cc - skipped
    -- Detecting C compile features
    -- Detecting C compile features - done
    -- Detecting CXX compiler ABI info
    -- Detecting CXX compiler ABI info - done
    -- Check for working CXX compiler: /usr/bin/c++ - skipped
    -- Detecting CXX compile features
    -- Detecting CXX compile features - done
    -- Found Python3: /usr/bin/python3.10 (found version "3.10.6") found components: Interpreter Development NumPy Development.Module Development.Embed
    -- Found PythonLibs: /usr/lib/x86_64-linux-gnu/libpython3.10.so (found suitable version "3.10.6", minimum required is "3.0")
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /home/maciej/Projects/Artificial-Intelligence-and-Machine-Learning/4-Markov-Decision-Problems/build
    [  8%] Building CXX object CMakeFiles/value_iteration.dir/src/mainValueIteration.cpp.o
    [ 16%] Building CXX object CMakeFiles/value_iteration.dir/src/World.cpp.o
    [ 25%] Building CXX object CMakeFiles/value_iteration.dir/src/ValueIterationAlgorithm.cpp.o
    [ 33%] Building CXX object CMakeFiles/value_iteration.dir/src/Plotter.cpp.o
    [ 41%] Building CXX object CMakeFiles/value_iteration.dir/src/CommandLineParser.cpp.o
    [ 50%] Linking CXX executable value_iteration
    [ 50%] Built target value_iteration
    [ 58%] Building CXX object CMakeFiles/qlearning.dir/src/mainQLearning.cpp.o
    [ 66%] Building CXX object CMakeFiles/qlearning.dir/src/World.cpp.o
    [ 75%] Building CXX object CMakeFiles/qlearning.dir/src/Plotter.cpp.o
    [ 83%] Building CXX object CMakeFiles/qlearning.dir/src/QLearning.cpp.o
    [ 91%] Building CXX object CMakeFiles/qlearning.dir/src/CommandLineParser.cpp.o
    [100%] Linking CXX executable qlearning
    [100%] Built target qlearning
    Build completed successfully.


## Usage

## Acknowledgements

- [Markov decision process: value iteration with code implementation](https://medium.com/@ngao7/markov-decision-process-value-iteration-2d161d50a6ff)
- [Reinforcement learning: Q-learner with detailed example and code implementation](https://medium.com/@ngao7/reinforcement-learning-q-learner-with-detailed-example-and-code-implementation-f7578976473c)
- [matplotlib-cpp](https://github.com/lava/matplotlib-cpp)