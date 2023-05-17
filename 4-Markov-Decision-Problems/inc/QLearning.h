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

  struct StateData {
    int x;
    int y;
    std::vector<double> utilities;
  };

  static std::vector<StateData> inline saved_state_utilities_;

 private:
  static bool isPositionOutOfTheWorld(int x, int y);
  static bool isPositionForbidden(int x, int y);
  static bool isPositionTerminal(int x, int y);

  static float updateProbability(char action);
  static void updateCellPolicy(int x, int y, char newPolicy);
  static void updateCellUtility(int x, int y, float newUtility);
  static void updateFrequency(int x, int y, char currentAction);
  static std::vector<std::tuple<int, int>> updateActions(char desiredOrientation);
  static std::pair<int, int> updatePositionChanges(char action, char currentOrientation);

  static float getStateReward(int x, int y);
  static double getQ(int x, int y, char currentAction);
  static int getFrequencyOfAction(int x, int y, char currentAction);
  static std::pair<char, double> getBestPolicyAndMaxQ(int x, int y);

  static void sumAndRemoveDuplicates(std::vector<Point> &points);
  static std::pair<int, int> calculateNewPosition(int x, int y, int dx, int dy);
  static std::vector<Point> calculateNewPositionsPossibilitiesForAllActions(int x, int y, const char &action);

  static char generateRandomAction(char currentPolicy);
  static std::pair<int,int> executeAgentMove(int x, int y, std::vector<Point> possibleMoves);
  static void displayProgressBar(int currentIteration, int totalIterations, int barWidth);

  static void initSavedStateUtilities();
  static void saveStateUtility(int x, int y);

  static int inline width_;
  static int inline height_;
  static float inline gamma_;
  static float inline reward_;
  static float inline epsilon_;
  static int inline iteration_;
  static std::vector<float> inline p_;
  static std::vector<char> inline actions_;
  static int inline isIterationDefinedByUser_;

  static std::vector<std::vector<World::Cell>> inline constructed_world_;
};

#endif // INC_QLEARNING_H_
