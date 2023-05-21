#ifndef INC_COMMANDLINEPARSER_H_
#define INC_COMMANDLINEPARSER_H_

#include <iostream>
#include <string>

class CommandLineParser {
 public:
  std::string dataFile;
  bool hasGamma;
  double gamma;
  bool hasEpsilon;
  double epsilon;
  bool hasIteration;
  int iteration;
  bool shouldPlot;

  static CommandLineParser parseValueIteration(int argc, char** argv);
  static CommandLineParser parseQLearning(int argc, char** argv);
};

#endif // INC_COMMANDLINEPARSER_H_
