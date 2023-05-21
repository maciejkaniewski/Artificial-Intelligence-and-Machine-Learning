#ifndef INC_WORLD_H
#define INC_WORLD_H

#include <algorithm>
#include <cmath>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <tuple>
#include <utility>
#include <vector>
#include <unordered_map>

class World {

 public:
  World() = default;
  bool loadWorldParametersFromFile(const std::string &file_name, bool isQlearning);
  void printWorldParameters() const;
  bool setGamma(float gamma);
  void displayWorld() const;
  void displayQValues() const;
  void setEpsilon(float epsilon) { epsilon_ = epsilon; };

  struct Cell {
    std::string state = " "; // Name of the state
    float utility = 0.0f; // Utility value with 4 decimal places
    char policy = ' '; // Policy: <, >, v, ^, or empty
    float reward = 0.0f; // Reward for state

    // Below fields are used in Q learning
    std::unordered_map<char, double> q = {
        {'^', 0},
        {'<', 0},
        {'>', 0},
        {'v', 0}
    };

    std::unordered_map<char, int> n = {
        {'^', 0},
        {'<', 0},
        {'>', 0},
        {'v', 0}
    };
  };

  void constructWorld();

  std::vector<std::vector<Cell>> const getConstructedWorld() { return constructed_world_; };
  float getGamma() const { return gamma_; };
  float getEpsilon() const { return epsilon_; };
  float getReward() const { return reward_; };

  std::pair<int, int> getCoordinatesOfState(std::string_view targetState) const;

  std::vector<float> getP() const { return p_; };

  void updateConstructedWorld(std::vector<std::vector<Cell>> const &new_constructed_world) {
    constructed_world_ = new_constructed_world;
  }

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

  std::vector<std::vector<Cell>> constructed_world_;

  bool checkFileValidity(const std::string &file_name) const;
  bool checkParametersValidity() const;
  bool isInSpecialStates(const std::pair<int, int> &state);
  bool isInTerminalStates(const std::pair<int, int> &state);
};

#endif //INC_WORLD_H