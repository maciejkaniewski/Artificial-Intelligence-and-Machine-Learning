#include "QLearning.h"

void QLearning::setIteration(int iteration) {
  iteration_ = iteration;
  isIterationDefinedByUser_ = true;
}

void QLearning::start(World &world) {

  reward_ = world.getReward();
  gamma_ = world.getGamma();
  epsilon_ = world.getEpsilon();
  constructed_world_ = world.getConstructedWorld();

  // Get world size, width, height
  width_ = int(constructed_world_.size());
  height_ = int(constructed_world_[0].size());

  // Define iterations
  if(!isIterationDefinedByUser_) iteration_ = 10000;
  std::cout << iteration_ << "\n";

}

