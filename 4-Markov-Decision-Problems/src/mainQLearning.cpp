#include "World.h"
#include "Plotter.h"
#include "QLearning.h"
#include "CommandLineParser.h"

int main(int argc, char** argv) {

  CommandLineParser args = CommandLineParser::parseQLearning(argc, argv);

  if (args.dataFile.empty()) return 1;

  World world;

  if (!world.loadWorldParametersFromFile(args.dataFile,true)) return 1;
  if (args.hasGamma && !world.setGamma(args.gamma)) return 1;
  if (args.hasEpsilon) world.setEpsilon(args.epsilon);
  if (args.hasIteration) QLearning::setIteration(args.iteration);

  world.printWorldParameters();
  world.constructWorld();
//  QLearning::start(world);
  world.displayWorld();

  if (args.shouldPlot) {
    Plotter::plot(QLearning::saved_state_utilities_);
  }

  return 0;
}
