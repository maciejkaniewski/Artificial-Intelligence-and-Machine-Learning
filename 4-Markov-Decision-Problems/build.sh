#!/bin/bash

if [ ! -e "CMakeLists.txt" ]; then
  echo "Error: CMakeLists.txt not found."
  exit 1
fi

if ! cmake -S . -B build/ -D CMAKE_BUILD_TYPE=Release;
then
  echo "Error: CMake configuration failed."
  exit 1
fi

if ! cmake --build build;
then
  echo "Error: Build failed."
  exit 1
fi

echo "Build completed successfully."
exit 0
