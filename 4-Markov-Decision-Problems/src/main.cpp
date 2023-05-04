#include "World.h"

int main(int argc, char **argv) {

  World world;

  if (argc > 1) {
    if (!world.loadWorldParametersFromFile(argv[1])) {
      std::cerr << "Failed to load world parameters from file " << argv[1] << std::endl;
      return 1;
    }

    // Parse gamma from command line argument
    if (argc > 2) world.setGamma(std::atof(argv[2]));

    // Parse epsilon from command line argument
    if (argc > 3) world.setEpsilon(std::atof(argv[3]));

    world.printWorldParameters();
  } else {
    std::cerr << "Usage: " << argv[0] << " <file_name> [<gamma> <epsilon>]" << std::endl;
    return 1;
  }
}