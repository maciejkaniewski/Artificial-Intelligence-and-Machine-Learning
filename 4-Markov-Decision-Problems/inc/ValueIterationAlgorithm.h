#ifndef INC_VALUEITERATIONALGORITHM_H_
#define INC_VALUEITERATIONALGORITHM_H_

#include "World.h"

class ValueIterationAlgorithm {
 public:
  ValueIterationAlgorithm() = default;
  static void start(World &world);
 private:
  static bool isPositionOutOfTheWorld(int x, int y, int width, int height);
  static bool isPositionForbidden(int x, int y, std::vector<std::vector<World::Cell>> constructed_world);
  static bool isPositionTerminal(int x, int y, std::vector<std::vector<World::Cell>> constructed_world);

  static std::pair<int, int> calculateNewPosition(int x, int y, int dx, int dy);
  static float updateProbability(char action, std::vector<float> p);
  static std::vector<std::tuple<int, int>> updateActions(char desired_orientation);
  static std::pair<int, int> updatePositionChanges(char action, char current_orientation);

  static float calculateNewUtility(float reward, float gamma, std::vector<float> action_utilities);
  static char getBestPolicy(std::vector<char> actions, std::vector<float> action_utilities);
};

#endif //INC_VALUEITERATIONALGORITHM_H_
