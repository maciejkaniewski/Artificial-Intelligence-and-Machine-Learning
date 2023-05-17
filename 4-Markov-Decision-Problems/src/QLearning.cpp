#include "QLearning.h"

void QLearning::setIteration(int iteration) {
  iteration_ = iteration;
  isIterationDefinedByUser_ = true;
}

bool QLearning::isPositionOutOfTheWorld(int x, int y) {
  return (x < 0 || x >= width_ || y < 0 || y >= height_);
}

bool QLearning::isPositionForbidden(int x, int y) {
  return constructed_world_[x][y].state == "F";
}

bool QLearning::isPositionTerminal(int x, int y) {
  return constructed_world_[x][y].state == "T";
}

float QLearning::updateProbability(char action) {
  switch (action) {
    case '^':return p_[0];
    case '<':return p_[1];
    case '>':return p_[2];
    case 'v':return (1.0f - p_[0] - p_[1] - p_[2] < 1e-10) ? 0 : 1.0f - p_[0] - p_[1] - p_[2];
    default:return 0;
  }
}

void QLearning::updateCellPolicy(int x, int y, char new_policy) {
  constructed_world_[x][y].policy = new_policy;
}

void QLearning::updateCellUtility(int x, int y, float new_utility) {
  constructed_world_[x][y].utility = new_utility;
}

void QLearning::updateFrequency(int x, int y, char currentAction) {
  constructed_world_[x][y].n.at(currentAction) += 1;
}

std::vector<std::tuple<int, int>> QLearning::updateActions(char desiredOrientation) {
  switch (desiredOrientation) {
    case '^':return {{0, 1}, {-1, 0}, {1, 0}, {0, -1}};
    case '<':return {{-1, 0}, {0, -1}, {0, 1}, {1, 0}};
    case '>':return {{1, 0}, {0, 1}, {0, -1}, {-1, 0}};
    case 'v':return {{0, -1}, {1, 0}, {-1, 0}, {0, 1}};
    default:return {{0, 0}, {0, 0}, {0, 0}, {0, 0}};
  }
}

std::pair<int, int> QLearning::updatePositionChanges(char action, char currentOrientation) {

  auto actions = updateActions(currentOrientation);

  switch (action) {
    case '^': {
      auto [dx_u, dy_u] = actions[0];
      return std::make_pair(dx_u, dy_u);
    }
    case '<': {
      auto [dx_l, dy_l] = actions[1];
      return std::make_pair(dx_l, dy_l);
    }
    case '>': {
      auto [dx_r, dy_r] = actions[2];
      return std::make_pair(dx_r, dy_r);
    }
    case 'v': {
      auto [dx_d, dy_d] = actions[3];
      return std::make_pair(dx_d, dy_d);
    }
    default: {
      return std::make_pair(0, 0);
    }
  }
}

float QLearning::getStateReward(int x, int y) {
  return constructed_world_[x][y].reward;
}

double QLearning::getQ(int x, int y, char currentAction) {
  return constructed_world_[x][y].q.at(currentAction);
}

int QLearning::getFrequencyOfAction(int x, int y, char currentAction) {
  return constructed_world_[x][y].n.at(currentAction);
}

std::pair<char, double> QLearning::getBestPolicyAndMaxQ(int x, int y) {
  char best_policy = ' ';
  auto max_q = std::numeric_limits<double>::lowest();
  for (const auto &[policy, q] : constructed_world_[x][y].q) {
    if (q > max_q) {
      max_q = q;
      best_policy = policy;
    }
  }
  return std::make_pair(best_policy, max_q);
}

std::pair<int, int> QLearning::calculateNewPosition(int x, int y, int dx, int dy) {
  return std::make_pair(x + dx, y + dy);
}


void QLearning::sumAndRemoveDuplicates(std::vector<Point> &points) {
  std::map<std::pair<int, int>, float> sumMap;

  for (const Point &point : points) {
    std::pair<int, int> key = std::make_pair(point.x, point.y);
    if (sumMap.count(key) > 0) {
      sumMap[key] += point.p;
    } else {
      sumMap[key] = point.p;
    }
  }

  points.clear();

  for (const auto &pair : sumMap) {
    if (pair.second != 0.0f) {
      Point newPoint;
      newPoint.x = pair.first.first;
      newPoint.y = pair.first.second;
      newPoint.p = pair.second;
      points.push_back(newPoint);
    }
  }
}

std::vector<QLearning::Point> QLearning::calculateNewPositionsPossibilitiesForAllActions(int x,
                                                                                         int y,
                                                                                         const char &action) {
  std::vector<Point> points;
  Point point = {0, 0, 0};

  for (const auto &action_i : actions_) {

    auto [dx, dy] = updatePositionChanges(action_i, action);
    auto [new_x, new_y] = calculateNewPosition(x, y, dx, dy);
    auto p_current = updateProbability(action_i);

    point.x = new_x;
    point.y = new_y;
    point.p = p_current;

    if (isPositionOutOfTheWorld(new_x, new_y) || isPositionForbidden(new_x, new_y)) {
      point.x -= dx;
      point.y -= dy;
    }
    points.push_back(point);
  }
  sumAndRemoveDuplicates(points);
  return points;
}

char QLearning::generateRandomAction(char currentPolicy) {
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_real_distribution<> dis(0.0, 1.0);
  double random_number = dis(gen);

  if (random_number < epsilon_ || currentPolicy == ' ') {
    random_number = dis(gen);
    if (random_number < 0.25) return '^';
    if (random_number < 0.50) return '<';
    if (random_number < 0.75) return '>';
    return 'v';
  } else {
    return currentPolicy;
  }
}

std::pair<int, int> QLearning::executeAgentMove(int x, int y, std::vector<Point> possibleMoves) {
  std::random_device rd;
  std::mt19937 gen(rd());
  std::uniform_real_distribution<> dis(0.0, 1.0);
  double random_number = dis(gen);
  for (auto const &move : possibleMoves) {
    if (random_number < move.p) return std::make_pair(move.x, move.y);
    random_number -= move.p;
  }
  return std::make_pair(x, y);
}

void QLearning::displayProgressBar(int currentIteration, int totalIterations, int barWidth = 50) {
  float progress = static_cast<float>(currentIteration) / totalIterations;
  int filledWidth = static_cast<int>(progress * barWidth);

  std::cout << "  QLearning: [";
  for (int i = 0; i < barWidth; ++i) {
    if (i < filledWidth)
      std::cout << "=";
    else if (i == filledWidth)
      std::cout << ">";
    else
      std::cout << " ";
  }
  std::cout << "] " << static_cast<int>(progress * 100.0) << "%\r";
  std::cout.flush();
}

void QLearning::initSavedStateUtilities() {
  for (int y = 0; y < height_; y++) {
    for (int x = 0; x < width_; x++) {
      StateData state = {x, y, std::vector<double>()};
      saved_state_utilities_.push_back(state);
      saveStateUtility(x, y);
    }
  }
}

void QLearning::saveStateUtility(int x, int y) {
  saved_state_utilities_[x + y * width_].utilities.push_back(constructed_world_[x][y].utility);
}

void QLearning::start(World &world) {

  p_ = world.getP();
  reward_ = world.getReward();
  gamma_ = world.getGamma();
  epsilon_ = world.getEpsilon();
  constructed_world_ = world.getConstructedWorld();

  width_ = int(constructed_world_.size());
  height_ = int(constructed_world_[0].size());

  actions_ = {'^', '<', '>', 'v'};

  if (!isIterationDefinedByUser_) iteration_ = 10000;

  initSavedStateUtilities();

  for (int i = 0; i < iteration_; ++i) {
    displayProgressBar(i + 1, iteration_);
    auto [x, y] = world.getCoordinatesOfState("S");
    int current_x = x;
    int current_y = y;
    while (true) {

      if (isPositionTerminal(current_x, current_y)) break;

      auto current_action = generateRandomAction(constructed_world_[current_x][current_y].policy);
      auto test = calculateNewPositionsPossibilitiesForAllActions(current_x, current_y, current_action);
      auto [new_x, new_y] = executeAgentMove(current_x, current_y, test);

      updateFrequency(current_x,current_y,current_action);

      double alpha = 1.0 / getFrequencyOfAction(current_x,current_y,current_action);
      double old_q = getQ(current_x,current_y,current_action);

      auto [new_best_policy, new_max_q] = getBestPolicyAndMaxQ(new_x, new_y);

      if (isPositionTerminal(new_x, new_y)) new_max_q = getStateReward(new_x, new_y);

      double new_q = getStateReward(current_x, current_y) + gamma_ * new_max_q;
      constructed_world_[current_x][current_y].q.at(current_action) = old_q + alpha * (new_q - old_q);
      if(!isPositionTerminal(new_x,new_y)) updateCellPolicy(new_x, new_y, new_best_policy);

      auto [current_best_policy, current_max_q] = getBestPolicyAndMaxQ(current_x, current_y);

      updateCellUtility(current_x, current_y, float(current_max_q));
      current_x = new_x;
      current_y = new_y;
    }
    for (int yy = 0; yy < height_; yy++) {
      for (int xx = 0; xx < width_; xx++) {
        saveStateUtility(xx, yy);
      }
    }
  }
  std::cout<<"\n\n";
  world.updateConstructedWorld(constructed_world_);
}
