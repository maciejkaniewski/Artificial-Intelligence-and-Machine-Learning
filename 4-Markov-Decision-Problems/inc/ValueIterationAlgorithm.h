#ifndef INC_VALUEITERATIONALGORITHM_H_
#define INC_VALUEITERATIONALGORITHM_H_

#include "World.h"

class ValueIterationAlgorithm {
 public:
  ValueIterationAlgorithm() = default;
  static void start(World &world);
 private:
  static bool isPositionOutOfTheWorld(int x, int y);
  static bool isPositionForbidden(int x, int y);
  static bool isPositionTerminal(int x, int y);
  static bool isPositionSpecial(int x, int y);

  static std::pair<int, int> calculateNewPosition(int x, int y, int dx, int dy);
  static float updateProbability(char action);
  static std::vector<std::tuple<int, int>> updateActions(char desired_orientation);
  static std::pair<int, int> updatePositionChanges(char action, char current_orientation);

  static float calculateNewUtility(std::vector<float> action_utilities);
  static char getBestPolicy(std::vector<float> action_utilities);

  static void updateCellUtility(int x, int y, float new_utility);
  static void updateCellPolicy(int x, int y,char new_policy);

  static void calculateUtilitiesForAllActions(int x, int y, const char &action, std::vector<float> &action_utilities);

  static std::vector<float> inline p_;
  static float inline reward_;
  static float inline gamma_;
  static std::vector<std::vector<World::Cell>> inline constructed_world_;
  static int inline width_;
  static int inline height_;
  static std::vector<char> inline actions_;

};

#endif //INC_VALUEITERATIONALGORITHM_H_
