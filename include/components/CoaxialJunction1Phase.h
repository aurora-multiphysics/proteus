#pragma once

#include "Component.h"
#include "InputParameters.h"

class CoaxialJunction1Phase : public Component {
public:
  static InputParameters validParams();

  CoaxialJunction1Phase(const InputParameters &params);

protected:
  /// Connects the same solid region of two coaxial pipes
  void ConnectSolidRegion(const std::string &region_name,
                          const ComponentName &component1,
                          const ComponentName &component2);

  /// Connects the same flow region of two coaxial pipes
  void ConnectFlowRegion(const std::string &region_name,
                         const ComponentName &component1,
                         const ComponentName &component2);
};