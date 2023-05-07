#include "World.h"

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
    world.displayWorld();

  } else {
    std::cerr << "Usage: " << argv[0] << " <file_name> [<gamma> <epsilon>]" << std::endl;
    return 1;
  }
}