#ifndef INC_WORLD_H
#define INC_WORLD_H

#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <tuple>
#include <vector>

class World {

 public:
  World() = default;
  bool loadWorldParametersFromFile(const std::string &file_name);
  void printWorldParameters() const;
  void setGamma(float gamma) { gamma_ = gamma; };
  void setEpsilon(float epsilon) { epsilon_ = epsilon; };

 private:
  int width_x_ = 0; // Defines the horizontal world size
  int height_y_ = 0; // Defines the vertical world size
  int start_x_ = 0; // Specifies the horizontal coordinate of the start state
  int start_y_ = 0; // Specifies the vertical coordinate of the start state
  std::vector<float> p_ = {0, 0, 0}; // Uncertainty distribution
  float reward_ = 0; // Default reward parameter
  float gamma_ = 0; // Discounting parameter
  float epsilon_ = 0; // Exploration parameter
  std::vector<std::tuple<int, int, float>> terminal_states_ = {}; // Terminal states (X,Y) and their reward
  std::vector<std::tuple<int, int, float>> special_states_ = {}; // Special states (X,Y) and their reward
  std::vector<std::pair<int, int>> forbidden_states_ = {}; // Forbidden states (X,Y)
};

#endif //INC_WORLD_H