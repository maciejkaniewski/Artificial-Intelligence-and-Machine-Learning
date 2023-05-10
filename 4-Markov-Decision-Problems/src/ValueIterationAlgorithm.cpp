#include "ValueIterationAlgorithm.h"

float ValueIterationAlgorithm::updateProbability(char action) {
  switch (action) {
    case '^':return p_[0];
    case '<':return p_[1];
    case '>':return p_[2];
    case 'v':return 1.0f - p_[0] - p_[1] - p_[2];
    default: return 0;
  }
}

bool ValueIterationAlgorithm::isPositionOutOfTheWorld(int x, int y) {
  return (x < 0 || x >= width_ || y < 0 || y >= height_);
}

bool ValueIterationAlgorithm::isPositionForbidden(int x, int y) {
  return constructed_world_[x][y].state == "F";
}

bool ValueIterationAlgorithm::isPositionTerminal(int x, int y) {
  return constructed_world_[x][y].state == "T";
}

bool ValueIterationAlgorithm::isPositionSpecial(int x, int y) {
  return constructed_world_[x][y].state == "B";
}

std::pair<int, int> ValueIterationAlgorithm::calculateNewPosition(int x, int y, int dx, int dy) {
  return std::make_pair(x + dx, y + dy);
}

std::vector<std::tuple<int, int>> ValueIterationAlgorithm::updateActions(char desired_orientation) {
  switch (desired_orientation) {
    case '^':return {{0, 1}, {-1, 0}, {1, 0}, {0, -1}};
    case '<':return {{-1, 0}, {0, -1}, {0, 1}, {1, 0}};
    case '>':return {{1, 0}, {0, 1}, {0, -1}, {-1, 0}};
    case 'v':return {{0, -1}, {1, 0}, {-1, 0}, {0, 1}};
    default:return {{0, 0}, {0, 0}, {0, 0}, {0, 0}};
  }
}

std::pair<int, int> ValueIterationAlgorithm::updatePositionChanges(char action, char current_orientation) {

  auto actions = updateActions(current_orientation);

  switch (action) {
    case '^': {
      auto [dx_u, dy_u] = actions[0];
      return std::make_pair(dx_u, dy_u);
    }
    case '<': {
      auto [dx_l, dy_l] = actions[1];
      return std::make_pair(dx_l, dy_l);
    }
    case '>': {
      auto [dx_r, dy_r] = actions[2];
      return std::make_pair(dx_r, dy_r);
    }
    case 'v': {
      auto [dx_d, dy_d] = actions[3];
      return std::make_pair(dx_d, dy_d);
    }
    default: {
      return std::make_pair(0, 0);
    }
  }
}

float ValueIterationAlgorithm::calculateNewUtility(std::vector<float> action_utilities) {
  return reward_ + gamma_ * (*std::max_element(action_utilities.begin(), action_utilities.end()));
}
char ValueIterationAlgorithm::getBestPolicy(std::vector<float> action_utilities) {
  return actions_[std::distance(action_utilities.begin(),
                                std::max_element(action_utilities.begin(), action_utilities.end()))];
}

void ValueIterationAlgorithm::updateCellUtility(int x, int y, float new_utility) {
  constructed_world_[x][y].utility = new_utility;
}
void ValueIterationAlgorithm::updateCellPolicy(int x, int y,char new_policy) {
  constructed_world_[x][y].policy = new_policy;
}

void ValueIterationAlgorithm::calculateUtilitiesForAllActions(int x,
                                                              int y,
                                                              const char &action,
                                                              std::vector<float> &action_utilities) {
  float utility = 0.0f;

  for (const auto &action_i : actions_) {

    auto [dx, dy] = updatePositionChanges(action_i, action);
    auto [new_x, new_y] = calculateNewPosition(x, y, dx, dy);
    auto p_current = updateProbability(action_i);

    if (isPositionOutOfTheWorld(new_x, new_y) || isPositionForbidden(new_x, new_y)) {
      utility += p_current * constructed_world_[x][y].utility;
    } else {
      utility += p_current * constructed_world_[new_x][new_y].utility;
    }
  }
  action_utilities.emplace_back(utility);
}

void ValueIterationAlgorithm::start(World &world) {

  // Get world parameters
  p_ = world.getP();
  reward_ = world.getReward();
  gamma_ = world.getGamma();
  constructed_world_ = world.getConstructedWorld();

  // Get world size, width, height
  width_ = int(constructed_world_.size());
  height_ = int(constructed_world_[0].size());

  // Actions vector for up, left, right, down
  actions_ = {'^', '<', '>', 'v'};
  std::vector<float> action_utilities;

  for (int iteration = 0; iteration < 100; iteration++) {
    for (int y = 0; y < height_; y++) {
      for (int x = 0; x < width_; x++) {

        if (isPositionTerminal(x, y) || isPositionForbidden(x, y)) continue;

        for (const auto &action : actions_) {
          calculateUtilitiesForAllActions(x, y, action,action_utilities);
        }

        auto new_policy = getBestPolicy(action_utilities);
        auto new_utility = calculateNewUtility(action_utilities);

        action_utilities.clear();

        isPositionSpecial(x, y) ? updateCellPolicy(x, y, new_policy) : (updateCellUtility(x, y, new_utility), updateCellPolicy(x, y, new_policy));
      }
    }
  }
  world.updateConstructedWorld(constructed_world_);
}
