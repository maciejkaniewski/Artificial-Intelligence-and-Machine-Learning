#include "Plotter.h"

void Plotter::plot(std::vector<ValueIterationAlgorithm::StateData> data) {
  std::vector<double> iterations(data[0].utilities.size());

  for (int i = 0; i < int(iterations.size()); i++) {
    iterations[i] = i;
  }

  plt::figure_size(1280, 720);

  for (auto const &state_utility : data) {
    std::vector<double> utilities = state_utility.utilities;
    std::string label = "(" + std::to_string(state_utility.x + 1) + "," + std::to_string(state_utility.y + 1) + ")";
    plt::named_plot(label, iterations, utilities);
  }

  plt::title("The value iteration algorithm");
  plt::xlabel("Number of iterations");
  plt::ylabel("Utility estimates");
  plt::legend();
  plt::show();
}
