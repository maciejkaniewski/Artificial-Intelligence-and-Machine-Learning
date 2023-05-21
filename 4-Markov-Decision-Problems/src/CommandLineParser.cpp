#include "CommandLineParser.h"

CommandLineParser CommandLineParser::parseValueIteration(int argc, char **argv) {
  CommandLineParser args;

  if (argc < 2 || argc > 5) {
    std::cerr << "Usage: " << argv[0] << " <data_file> [-g <gamma>] [-p]" << std::endl;
    args.dataFile = "";
    return args;
  }

  args.dataFile = argv[1];
  args.hasGamma = false;
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


CommandLineParser CommandLineParser::parseQLearning(int argc, char **argv) {
  CommandLineParser args;

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
