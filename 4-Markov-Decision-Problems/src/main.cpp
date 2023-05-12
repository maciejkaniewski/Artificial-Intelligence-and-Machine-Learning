#include "World.h"
#include "Plotter.h"
#include "ValueIterationAlgorithm.h"

int main(int argc, char **argv) {

  World world;

  if (argc > 1 && argc <= 5) {

    // Validate file and load world parameters
    if (!world.loadWorldParametersFromFile(argv[1])) return 1;

    // Parse gamma from command line argument
    if (argc > 2 && std::string(argv[2]) != "-plot" && !world.setGamma(std::stod(argv[2]))) return 1;

    // Parse epsilon from command line argument
    if (argc > 3 && std::string(argv[3]) != "-plot") world.setEpsilon(std::stod(argv[3]));

    world.printWorldParameters();
    world.constructWorld();
    ValueIterationAlgorithm::start(world);
    world.displayWorld();

    for (int i = 2; i < argc; i++) {
      if (std::string(argv[i]) == "-plot") {
        Plotter::plot(ValueIterationAlgorithm::saved_state_utilities_);
        break;
      }
    }

  } else {
    std::cerr << "Usage: " << argv[0] << " <file_name> [<gamma>] [<epsilon>] [-plot]" << std::endl;
    return 1;
  }
}