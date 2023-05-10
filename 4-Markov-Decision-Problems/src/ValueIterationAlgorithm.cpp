#include "ValueIterationAlgorithm.h"

float ValueIterationAlgorithm::updateProbability(char action, std::vector<float> p) {
  switch (action) {
    case '^':return p[0];
    case '<':return p[1];
    case '>':return p[2];
    case 'v':return 1.0f - p[0] - p[1] - p[2];
    default: return 0;
  }
}

bool ValueIterationAlgorithm::isPositionOutOfTheWorld(int x, int y, int width, int height) {
  return (x < 0 || x >= width || y < 0 || y >= height);
}

bool ValueIterationAlgorithm::isPositionForbidden(int x,
                                                  int y,
                                                  std::vector<std::vector<World::Cell>> constructed_world) {
  return constructed_world[x][y].state == "F";
}

bool ValueIterationAlgorithm::isPositionTerminal(int x,
                                                 int y,
                                                 std::vector<std::vector<World::Cell>> constructed_world) {
  return constructed_world[x][y].state == "T";
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

float ValueIterationAlgorithm::calculateNewUtility(float reward, float gamma, std::vector<float> action_utilities) {
  return reward + gamma * (*std::max_element(action_utilities.begin(), action_utilities.end()));
}
char ValueIterationAlgorithm::getBestPolicy(std::vector<char> actions, std::vector<float> action_utilities) {
  return actions[std::distance(action_utilities.begin(), std::max_element(action_utilities.begin(), action_utilities.end()))];
}


void ValueIterationAlgorithm::start(World &world) {

  // Get world parameters
  auto constructed_world = world.getConstructedWorld();
  auto reward = world.getReward();
  auto gamma = world.getGamma();
  auto p = world.getP();

  // Get world size, width, height
  auto width = int(constructed_world.size());
  auto height = int(constructed_world[0].size());

  // Actions vector for up, left, right, down
  std::vector<char> actions = {'^', '<', '>', 'v'};

  float utility = 0.0f;

  std::vector<float> action_utilities;

  for (int iteration = 0; iteration < 100; iteration++) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {

        if (isPositionTerminal(x, y, constructed_world) || isPositionForbidden(x, y, constructed_world)) {
          continue;
        }

        for (const auto &action : actions) {
          if (action == '^') {

            utility = 0.0f;

            for (const auto &action_i : actions) {

              auto [dx, dy] = updatePositionChanges(action_i, action);
              auto [new_x, new_y] = calculateNewPosition(x, y, dx, dy);
              auto p_current = updateProbability(action_i, p);

              if (isPositionOutOfTheWorld(new_x, new_y, width, height)
                  || isPositionForbidden(new_x, new_y, constructed_world)) {
                utility += p_current * constructed_world[x][y].utility;
              } else {
                utility += p_current * constructed_world[new_x][new_y].utility;
              }
            }
            action_utilities.emplace_back(utility);
          }

          if (action == '<') {

            utility = 0.0f;

            for (const auto &action_i : actions) {

              auto [dx, dy] = updatePositionChanges(action_i, action);
              auto [new_x, new_y] = calculateNewPosition(x, y, dx, dy);
              auto p_current = updateProbability(action_i, p);

              if (isPositionOutOfTheWorld(new_x, new_y, width, height)
                  || isPositionForbidden(new_x, new_y, constructed_world)) {
                utility += p_current * constructed_world[x][y].utility;
              } else {
                utility += p_current * constructed_world[new_x][new_y].utility;
              }
            }
            action_utilities.emplace_back(utility);
          }

          if (action == '>') {

            utility = 0.0f;

            for (const auto &action_i : actions) {

              auto [dx, dy] = updatePositionChanges(action_i, action);
              auto [new_x, new_y] = calculateNewPosition(x, y, dx, dy);
              auto p_current = updateProbability(action_i, p);

              if (isPositionOutOfTheWorld(new_x, new_y, width, height)
                  || isPositionForbidden(new_x, new_y, constructed_world)) {
                utility += p_current * constructed_world[x][y].utility;
              } else {
                utility += p_current * constructed_world[new_x][new_y].utility;
              }
            }
            action_utilities.emplace_back(utility);
          }

          if (action == 'v') {

            utility = 0.0f;

            for (const auto &action_i : actions) {

              auto [dx, dy] = updatePositionChanges(action_i, action);
              auto [new_x, new_y] = calculateNewPosition(x, y, dx, dy);
              auto p_current = updateProbability(action_i, p);

              if (isPositionOutOfTheWorld(new_x, new_y, width, height)
                  || isPositionForbidden(new_x, new_y, constructed_world)) {
                utility += p_current * constructed_world[x][y].utility;
              } else {
                utility += p_current * constructed_world[new_x][new_y].utility;
              }
            }
            action_utilities.emplace_back(utility);
          }
        }

        auto new_policy = getBestPolicy(actions,action_utilities);
        auto new_utility = calculateNewUtility(reward,gamma,action_utilities);

        action_utilities.clear();

        world.updateContructedWorldCellUtilityAndPolicy(x, y, new_utility, new_policy);
        constructed_world = world.getConstructedWorld();
      }
    }
  }
  world.displayWorld();
}