#pragma once

#include "ADKernelValue.h"

class INSADEpsilonDissipation;

class INSADEpsilonDissipation : public ADKernelValue
{
public:
  static InputParameters validParams();

  INSADEpsilonDissipation(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpResidual() override;

  const ADVariableValue & _k;

  const ADMaterialProperty<Real> & _rho;

  const ADReal & _C_eps2;
};
