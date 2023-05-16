#include "World.h"
#include "Plotter.h"
#include "QLearning.h"

struct CommandLineArguments {
  std::string dataFile;
  bool hasGamma;
  double gamma;
  bool hasEpsilon;
  double epsilon;
  bool hasIteration;
  int iteration;
  bool shouldPlot;
};

CommandLineArguments parseCommandLineArguments(int argc, char** argv) {
  CommandLineArguments args;

  if (argc < 2 || argc > 9) {
    std::cerr << "Usage: " << argv[0] << " <data_file> [-g <gamma>] [-e <epsilon>] [-i <iteration>] [-p]" << std::endl;
    args.dataFile = "";
    return args;
  }

  args.dataFile = argv[1];
  args.hasGamma = false;
  args.hasEpsilon = false;
  args.hasIteration = false;
  args.shouldPlot = false;

  for (int i = 2; i < argc; i++) {
    std::string arg = argv[i];

    if (arg == "-g") {
      if (i + 1 < argc) {
        args.gamma = std::stod(argv[i + 1]);
        args.hasGamma = true;
        i++;
      } else {
        std::cerr << "Error: Missing gamma value." << std::endl;
        args.dataFile = "";
        return args;
      }
    } else if (arg == "-e") {
      if (i + 1 < argc) {
        args.epsilon = std::stod(argv[i + 1]);
        args.hasEpsilon = true;
        i++;
      } else {
        std::cerr << "Error: Missing epsilon value." << std::endl;
        args.dataFile = "";
        return args;
      }
    } else if (arg == "-i") {
      if (i + 1 < argc) {
        args.iteration = std::stoi(argv[i + 1]);
        args.hasIteration = true;
        i++;
      } else {
        std::cerr << "Error: Missing iteration value." << std::endl;
        args.dataFile = "";
        return args;
      }
    } else if (arg == "-p") {
      args.shouldPlot = true;
    } else {
      std::cerr << "Error: Unknown option '" << arg << "'" << std::endl;
      args.dataFile = "";
      return args;
    }
  }
  return args;
}

int main(int argc, char** argv) {

  CommandLineArguments args = parseCommandLineArguments(argc, argv);

  if (args.dataFile.empty()) return 1;

  World world;

  if (!world.loadWorldParametersFromFile(args.dataFile)) return 1;
  if (args.hasGamma && !world.setGamma(args.gamma)) return 1; // Invalid gamma value
  if (args.hasEpsilon) world.setEpsilon(args.epsilon);
  if (args.hasIteration) QLearning::setIteration(args.iteration);

  world.printWorldParameters();
  world.constructWorld();
  QLearning::start(world);
//world.displayWorld();

  if (args.shouldPlot) {
// Plotting code here
  }

  return 0;
}
