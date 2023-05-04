#include "World.h"

bool World::loadWorldParametersFromFile(const std::string &file_name) {

  if (!std::filesystem::exists(file_name)) return false;

  std::ifstream infile(file_name);
  std::string line;
  while (std::getline(infile, line)) {
    std::istringstream iss(line);
    char c;
    int x, y;
    float p1, p2, p3, reward;
    iss >> c;
    if (c == 'W') {
      iss >> width_x_ >> height_y_;
    } else if (c == 'S') {
      iss >> start_x_ >> start_y_;
    } else if (c == 'P') {
      iss >> p1 >> p2 >> p3;
      p_ = {p1, p2, p3};
    } else if (c == 'R') {
      iss >> reward_;
    } else if (c == 'G') {
      iss >> gamma_;
    } else if (c == 'E') {
      iss >> epsilon_;
    } else if (c == 'T') {
      iss >> x >> y >> reward;
      terminal_states_.emplace_back(x, y, reward);
    } else if (c == 'B') {
      iss >> x >> y >> reward;
      special_states_.emplace_back(x, y, reward);
    } else if (c == 'F') {
      iss >> x >> y;
      forbidden_states_.emplace_back(x, y);
    }
  }
  return true;
}

void World::printWorldParameters() const {
  std::cout << "World Parameters:" << std::endl;
  std::cout << "Width X: " << width_x_ << std::endl;
  std::cout << "Height Y: " << height_y_ << std::endl;
  std::cout << "Start X: " << start_x_ << std::endl;
  std::cout << "Start Y: " << start_y_ << std::endl;
  std::cout << "Uncertainty Distribution P: ";
  for (float p : p_) {
    std::cout << p << " ";
  }
  std::cout << std::endl;
  std::cout << "Reward: " << reward_ << std::endl;
  std::cout << "Discounting Parameter Gamma: " << gamma_ << std::endl;
  std::cout << "Exploration Parameter Epsilon: " << epsilon_ << std::endl;
  std::cout << "Terminal States:";
  for (auto [x, y, reward] : terminal_states_) {
    std::cout << " (" << x << "," << y << "," << reward << ")";
  }
  std::cout << std::endl;
  std::cout << "Special States:";
  for (auto [x, y, reward] : special_states_) {
    std::cout << " (" << x << "," << y << "," << reward << ")";
  }
  std::cout << std::endl;
  std::cout << "Forbidden States:";
  for (auto [x, y] : forbidden_states_) {
    std::cout << " (" << x << "," << y << ")";
  }
  std::cout << std::endl;
}