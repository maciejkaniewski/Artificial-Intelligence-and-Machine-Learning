#include "World.h"
#include "ValueIterationAlgorithm.h"
#include "matplotlibcpp.h"
namespace plt = matplotlibcpp;

int main(int argc, char **argv) {

  World world;

  if (argc > 1 && argc <= 4) {

    // Validate file and load world parameters
    if (!world.loadWorldParametersFromFile(argv[1])) return 1;

    // Parse gamma from command line argument
    if (argc > 2 && !world.setGamma(std::stod(argv[2]))) return 1;

    // Parse epsilon from command line argument
    if (argc > 3) world.setEpsilon(std::stod(argv[3]));

    world.printWorldParameters();
    world.constructWorld();
    ValueIterationAlgorithm::start(world);
    world.displayWorld();

    std::vector<double> iterations(ValueIterationAlgorithm::saved_state_utilities_[0].utilities.size());

    for (int i = 0; i <= int(iterations.size()); i++) {
      iterations[i] = i;
    }

    plt::figure_size(1280, 720);

    for (auto const & state_utility : ValueIterationAlgorithm::saved_state_utilities_) {
      std::vector<double> utilities = state_utility.utilities;
      std::string label  = "(" + std::to_string(state_utility.x+1) + "," + std::to_string(state_utility.y+1) + ")";
      plt::named_plot(label,iterations,utilities);
    }

    plt::title("The value iteration algorithm");
    plt::xlabel("Number of iterations");
    plt::ylabel("Utility estimates");
    plt::legend();
    plt::show();

  } else {
    std::cerr << "Usage: " << argv[0] << " <file_name> [<gamma> <epsilon>]" << std::endl;
    return 1;
  }
}