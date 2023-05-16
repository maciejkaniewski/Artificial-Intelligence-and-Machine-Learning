#ifndef INC_QLEARNING_H_
#define INC_QLEARNING_H_

#include "World.h"

class QLearning {
 public:
  QLearning() = default;
  static void start(World &world);
  static void setIteration(int iteration);
 private:
  static float inline reward_;
  static float inline gamma_;
  static float inline epsilon_;
  static std::vector<std::vector<World::Cell>> inline constructed_world_;
  static int inline width_;
  static int inline height_;
  static int inline iteration_;
  static int inline isIterationDefinedByUser_;
};

#endif // INC_QLEARNING_H_
