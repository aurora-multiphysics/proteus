#pragma once

#include "Coaxial1PhaseBase.h"

class CoaxialElbow1Phase : public Coaxial1PhaseBase {
public:
  CoaxialElbow1Phase(const InputParameters &params);

public:
  static InputParameters validParams();

protected:
  void AddElbowInner();

  void AddElbowOuter();
};
