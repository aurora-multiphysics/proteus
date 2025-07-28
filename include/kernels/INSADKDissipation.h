#pragma once

#include "ADKernelValue.h"

class INSADKDissipation;

class INSADKDissipation : public ADKernelValue {
public:
  static InputParameters validParams();

  INSADKDissipation(const InputParameters &parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  const ADVariableValue &_epsilon;

  const ADMaterialProperty<Real> &_rho;
};
