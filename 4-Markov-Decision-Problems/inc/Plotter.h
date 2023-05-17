#ifndef INC_PLOTTER_H_
#define INC_PLOTTER_H_

#include "matplotlibcpp.h"
#include "ValueIterationAlgorithm.h"
#include "QLearning.h"

namespace plt = matplotlibcpp;

class Plotter {
 public:
  Plotter() = default;
  static void plot(std::vector<ValueIterationAlgorithm::StateData> data);
  static void plot(std::vector<QLearning::StateData> data);
};

#endif // INC_PLOTTER_H_
