#pragma once

#include "ADVolumeJunction1PhaseUserObject.h"
#include "InputParameters.h"

class ADElbow0D1PhaseUserObject : public ADVolumeJunction1PhaseUserObject {
public:
  static InputParameters validParams();

  ADElbow0D1PhaseUserObject(const InputParameters &params);

protected:
  void computeFluxesAndResiduals(const unsigned int &c) override;

  const Real &_r_curv;

  const Real &_d_h;
};
