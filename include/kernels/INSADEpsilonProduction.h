#pragma once

#include "ADKernelValue.h"

class INSADEpsilonProduction;

class INSADEpsilonProduction : public ADKernelValue
{
public:
  static InputParameters validParams();

  INSADEpsilonProduction(const InputParameters & parameters);

 protected:
  virtual ADReal precomputeQpResidual() override;

  const ADVectorVariableGradient & _grad_velocity;

  const ADVariableValue & _k;

  const ADMaterialProperty<Real> & _rho;

  const ADMaterialProperty<Real> & _mu_turb;

  const ADReal & _C_eps1;
};
