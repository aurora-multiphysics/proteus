#pragma once

#include "Coaxial1PhaseBase.h"

class CoaxialElbow1Phase : public Coaxial1PhaseBase {
public:
  static InputParameters validParams();

  CoaxialElbow1Phase(const InputParameters &params);

protected:
  // Add elbow geometry and form loss for inner pipe
  void AddElbowInner();

  // Add elbow geometry and form loss for outer annulus
  void AddElbowOuter();
};
