#pragma once

#include "VolumeJunction1Phase.h"

class CoaxialElbow1Phase : public VolumeJunction1Phase {
public:
  CoaxialElbow1Phase(const InputParameters &params);

protected:
  void buildVolumeJunctionUserObject() override;

  // radius of curvature
  const Real _r_curv;

public:
  static InputParameters validParams();
};
