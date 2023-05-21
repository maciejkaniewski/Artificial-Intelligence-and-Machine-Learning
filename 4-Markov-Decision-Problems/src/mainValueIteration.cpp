#include "World.h"
#include "Plotter.h"
#include "ValueIterationAlgorithm.h"
#include "CommandLineParser.h"

int main(int argc, char **argv) {

  CommandLineParser args = CommandLineParser::parseValueIteration(argc, argv);

  if (args.dataFile.empty()) return 1;

  World world;

  if (!world.loadWorldParametersFromFile(args.dataFile, false)) return 1;
  if (args.hasGamma && !world.setGamma(args.gamma)) return 1;

  world.printWorldParameters();
  world.constructWorld();
  ValueIterationAlgorithm::start(world);
  world.displayWorld();

  if (args.shouldPlot) {
    Plotter::plot(ValueIterationAlgorithm::saved_state_utilities_);
  }

  return 0;
}