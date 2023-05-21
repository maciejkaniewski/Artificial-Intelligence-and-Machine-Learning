#include "Plotter.h"

void Plotter::plot(std::vector<ValueIterationAlgorithm::StateData> data) {

  const std::vector<std::string> colors = {
      "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728",
      "#9467bd", "#8c564b", "#e377c2", "#7f7f7f",
      "#bcbd22", "#17becf", "indigo", "lime", "blue", "olive", "darkorchid", "black"
  };

  std::vector<double> iterations(data[0].utilities.size());

  for (int i = 0; i < int(iterations.size()); i++) {
    iterations[i] = i;
  }

  plt::figure_size(1280, 720);

  int i = 0;

  for (auto const &state_utility : data) {
    std::vector<double> utilities = state_utility.utilities;
    std::string label = "(" + std::to_string(state_utility.x + 1) + "," + std::to_string(state_utility.y + 1) + ")";
    plt::named_plot(label, iterations, utilities, colors[i]);
    i = (i == int(colors.size()) - 1) ? 0 : (i + 1);
  }

  plt::title("The value iteration algorithm");
  plt::xlabel("Number of iterations");
  plt::ylabel("Utility estimates");
  plt::legend({{"loc", "lower right"}});
  plt::show();
}

void Plotter::plot(std::vector<QLearning::StateData> data) {

  const std::vector<std::string> colors = {
      "#1f77b4", "#ff7f0e", "#2ca02c", "#d62728",
      "#9467bd", "#8c564b", "#e377c2", "#7f7f7f",
      "#bcbd22", "#17becf", "indigo", "lime", "blue", "olive", "darkorchid", "black"
  };

  std::vector<double> iterations(data[0].utilities.size());

  for (int i = 0; i < int(iterations.size()); i++) {
    iterations[i] = i;
  }

  plt::figure_size(1280, 720);

  int i = 0;

  for (auto const &state_utility : data) {
    std::vector<double> utilities = state_utility.utilities;
    std::string label = "(" + std::to_string(state_utility.x + 1) + "," + std::to_string(state_utility.y + 1) + ")";
    plt::named_plot(label, iterations, utilities, colors[i]);
    i = (i == int(colors.size()) - 1) ? 0 : (i + 1);
  }

  plt::title("The Q-Learning algorithm");
  plt::xlabel("Number of iterations");
  plt::ylabel("Utility estimates");
  plt::legend({{"loc", "lower right"}});
  plt::show();
}
