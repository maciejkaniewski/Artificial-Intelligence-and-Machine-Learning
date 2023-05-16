#ifndef INC_QLEARNING_H_
#define INC_QLEARNING_H_

#include "World.h"

#include <random>
#include <map>

class QLearning {
 public:
  QLearning() = default;
  static void start(World &world);
  static void setIteration(int iteration);

  struct Point {
    int x;
    int y;
    float p;
  };

 private:
  static bool isPositionOutOfTheWorld(int x, int y);
  static bool isPositionForbidden(int x, int y);
  static bool isPositionTerminal(int x, int y);

  static float updateProbability(char action);
  static std::pair<int, int> calculateNewPosition(int x, int y, int dx, int dy);
  static std::vector<std::tuple<int, int>> updateActions(char desired_orientation);
  static std::pair<int, int> updatePositionChanges(char action, char current_orientation);

  static char generateRandomAction(char currentPolicy);

  static void sumAndRemoveDuplicates(std::vector<Point> &points);
  static std::vector<Point> calculateNewPositionsPossibilitiesForAllActions(int x, int y, const char &action);
  static std::pair<int,int> executeAgentMove(int x, int y, std::vector<Point> possibleMoves);
  static void updateCellUtility(int x, int y, float new_utility);
  static void updateCellPolicy(int x, int y, char new_policy);

  static std::vector<float> inline p_;
  static float inline reward_;
  static float inline gamma_;
  static float inline epsilon_;
  static std::vector<std::vector<World::Cell>> inline constructed_world_;
  static int inline width_;
  static int inline height_;
  static int inline iteration_;
  static int inline isIterationDefinedByUser_;

  static std::vector<char> inline actions_;
};

#endif // INC_QLEARNING_H_
