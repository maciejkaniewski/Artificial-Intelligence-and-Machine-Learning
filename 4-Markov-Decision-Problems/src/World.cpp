#include "World.h"

bool World::checkFileValidity(const std::string &file_name) const {

  if (!std::filesystem::exists(file_name)) {
    std::cerr << "Error: File " << file_name << " does not exist." << std::endl;
    return false;
  }

  bool has_w = false, has_p = false, has_r = false, has_t = false;
  std::ifstream infile(file_name);
  std::string line;

  while (std::getline(infile, line)) {
    std::istringstream iss(line);
    char c;
    iss >> c;
    if (c == 'W') {
      int width, height;
      if (!(iss >> width >> height)) {
        std::cerr << "Error: Invalid world dimensions definition after W option in file " << file_name << std::endl;
        return false;
      }
      has_w = true;
    } else if (c == 'P') {
      float p1, p2, p3;
      if (!(iss >> p1 >> p2 >> p3)) {
        std::cerr << "Error: Invalid uncertainty distribution definition after P option in file " << file_name
                  << std::endl;
        return false;
      }
      has_p = true;
    } else if (c == 'R') {
      if (float reward; !(iss >> reward)) {
        std::cerr << "Error: Invalid reward value definition after R option in file " << file_name << std::endl;
        return false;
      }
      has_r = true;
    } else if (c == 'T') {
      int x, y;
      if (float reward; !(iss >> x >> y >> reward)) {
        std::cerr << "Error: Invalid terminal state definition after T option in file " << file_name << std::endl;
        return false;
      }
      has_t = true;
    }
  }

  if (!has_w) {
    std::cerr << "Error: Mandatory option W is missing in file " << file_name << std::endl;
    return false;
  }
  if (!has_p) {
    std::cerr << "Error: Mandatory option P is missing in file " << file_name << std::endl;
    return false;
  }
  if (!has_r) {
    std::cerr << "Error: Mandatory option R is missing in file " << file_name << std::endl;
    return false;
  }
  if (!has_t) {
    std::cerr << "Error: Mandatory option T is missing in file " << file_name << std::endl;
    return false;
  }
  return true;
}

bool World::checkParametersValidity() const {

  // Check if start state is defined within world dimensions
  if (start_x_ <= 0 || start_x_ > width_x_ || start_y_ <= 0 || start_y_ > height_y_) {
    std::cerr << "Error: Start state (" << start_x_ << "," << start_y_ << ") is outside world dimensions"
              << std::endl;
    return false;
  }

  // Check if p1, p2, p3 >= 0.0 <= 1.0 and p1+p2+p3 <= 1.0
  if (p_[0] < 0.0 || p_[0] > 1.0) {
    std::cerr << "Error: Invalid uncertainty specified for p1, should be in the range [0.0, 1.0]" << std::endl;
    return false;
  } else if (p_[1] < 0.0 || p_[1] > 1.0) {
    std::cerr << "Error: Invalid uncertainty specified for p2, should be in the range [0.0, 1.0]" << std::endl;
    return false;
  } else if (p_[2] < 0.0 || p_[2] > 1.0) {
    std::cerr << "Error: Invalid uncertainty specified for p3, should be in the range [0.0, 1.0]" << std::endl;
    return false;
  } else if ((p_[0] + p_[1] + p_[2]) > 1.0) {
    std::cerr << "Error: Uncertainty distribution sums to more than 1.0." << std::endl;
    return false;
  }

  // Check if gamma is in range (0.0, 1.0]
  if (gamma_ <= 0.0 || gamma_ > 1.0) {
    std::cerr << "Error: Gamma should be in the range (0.0, 1.0]" << std::endl;
    return false;
  }

  // Check if terminal states are defined within world dimensions
  for (auto [x_t, y_t, reward_t] : terminal_states_) {
    if (x_t <= 0 || x_t > width_x_ || y_t <= 0 || y_t > height_y_) {
      std::cerr << "Error: Terminal state (" << x_t << "," << y_t << ") is outside world dimensions" << std::endl;
      return false;
    }
  }

  // Check if special states are defined within world dimensions
  for (auto [x_s, y_s, reward_s] : special_states_) {
    if (x_s <= 0 || x_s > width_x_ || y_s <= 0 || y_s > height_y_) {
      std::cerr << "Error: Special state (" << x_s << "," << y_s << ") is outside world dimensions" << std::endl;
      return false;
    }
  }

  // Check if forbidden states are defined within world dimensions
  for (auto [x_f, y_f] : forbidden_states_) {
    if (x_f <= 0 || x_f > width_x_ || y_f <= 0 || y_f > height_y_) {
      std::cerr << "Error: Forbidden state (" << x_f << "," << y_f << ") is outside world dimensions" << std::endl;
      return false;
    }
  }

  return true;
}

bool World::loadWorldParametersFromFile(const std::string &file_name) {

  if (!checkFileValidity(file_name)) return false;

  std::ifstream infile(file_name);
  std::string line;

  bool is_start_in_file = false;

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
      is_start_in_file = true;
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

  if(!is_start_in_file)
  {
    start_x_ = 1;
    start_y_ = 1;
    std::cout << "Info: S option isn't present in "<< file_name <<" file. It has been set to default (1,1) value" << std::endl;
  }

  return checkParametersValidity();
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

bool World::setGamma(float gamma) {

  if (gamma <= 0.0 || gamma > 1.0) {
    std::cerr << "Error: Gamma should be in the range (0.0, 1.0]" << std::endl;
    return false;
  } else {
    gamma_ = gamma;
    return true;
  }
};

void World::displayWorld() const {

  auto height = int(constructed_world_.size());
  auto width = int(constructed_world_[0].size());

  int maxChars = 0;

  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      float num = std::stof(std::to_string(constructed_world_[i][j].utility));
      int charsBeforeDecimal = std::to_string((int)num).length();
      if (num < 0) {
        charsBeforeDecimal++;
      }
      if (charsBeforeDecimal > maxChars) {
        maxChars = charsBeforeDecimal;
      }
    }
  }

  std::string line1;
  auto line2 = std::string(maxChars+5, ' ');
  int dash = 0;
  for (int i = 0; i < maxChars+5; i++) {
    line1 += "-";
    dash++;
  }
  line1 =  "+-" + line1 + "-+";
  dash = dash + 2;

  std::cout << "  +";
  for (int i = 0; i < width; ++i) {
    if (i == 0) {
      std::cout << line1.substr(1);
    } else {
      std::cout << " " <<line1;
    }
  }
  std::cout << std::endl;

  for (int y = height; y >= 1; --y) {
    for (int row = 0; row < 3; ++row) {
      if (row == 1) {
        std::cout << y << " |";
      } else {
        std::cout << "  |";
      }
      for (int x = 1; x <= width; ++x) {
        if (row == 1) {
          std::cout << " " << constructed_world_[y-1][x-1].policy << line2;
          if (x == width) {
            std::cout << "|";
          } else {
            std::cout << "| |";
          }
        } else if (row == 2) {

          float num = std::stof(std::to_string(constructed_world_[y-1][x-1].utility));
          int charsBeforeDecimal = std::to_string((int)num).length();

          auto line3 = std::string(dash-(charsBeforeDecimal+6), ' ');

          std::cout << " " << std::fixed << std::showpoint << std::setprecision(4) << constructed_world_[y-1][x-1].utility << line3;

          if (x == width) {
            std::cout << "|";
          } else {
            std::cout << "| |";
          }
        } else if (row == 0) {

          std::cout << " " << constructed_world_[y-1][x-1].state << line2;

          if (x == width) {
            std::cout << "|";
          } else {
            std::cout << "| |";
          }
        }
      }
      std::cout << std::endl;
    }

    if (y != 1) {
      std::cout << "  +";
      for (int i = 0; i < width; ++i) {
        if (i == 0) {
          std::cout << line1.substr(1);
        } else {
          std::cout << " " <<line1;
        }
      }
      std::cout << std::endl;
    }

    if (y != 1) {
      std::cout << "  +";
      for (int i = 0; i < width; ++i) {
        if (i == 0) {
          std::cout << line1.substr(1);
        } else {
          std::cout << " " <<line1;
        }
      }
      std::cout << std::endl;
    }
  }

  std::cout << "  +";
  for (int i = 0; i < width; ++i) {
    if (i == 0) {
      std::cout << line1.substr(1);
    } else {
      std::cout << " " <<line1;
    }
  }
  std::cout << std::endl;

  std::cout <<  "    ";
  auto line4 = std::string(dash/2-1, ' ');
  auto line5 = std::string(dash+2, ' ');
  for (int x = 1; x <= width; ++x) {
    if(x==1)
    {
      std::cout << line4<< x;
    }else
    {
      std::cout << line5 << x;
    }
  }
  std::cout << std::endl;
}

void World::constructWorld() {

  std::vector<std::vector<Cell>> world(height_y_, std::vector<Cell>(width_x_));

  for (int y = 1; y <= height_y_; y++) {
    for (int x = 1; x <= width_x_; x++) {
      Cell cell;

      for (const auto &[tx, ty, tr] : terminal_states_) {
        if (x == tx && y == ty) {
          cell.state = "T";
          cell.utility = tr;
        }
      }

      for (const auto &[sx, sy, sr] : special_states_) {
        if (x == sx && y == sy) {
          cell.state = "B";
          cell.utility = sr;
        }
      }

      for (const auto &[fx, fy] : forbidden_states_) {
        if (x == fx && y == fy) {
          cell.state = "F";
        }
      }
      world[y - 1][x - 1] = cell;
    }
  }

  world[start_y_ - 1][start_x_ - 1].state = "S";
  constructed_world_ = world;
}