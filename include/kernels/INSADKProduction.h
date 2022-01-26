#pragma once

#include "ADKernelValue.h"

class INSADKProduction;

class INSADKProduction : public ADKernelValue
{
public:
  static InputParameters validParams();

  INSADKProduction(const InputParameters & parameters);

 protected:
  virtual ADReal precomputeQpResidual() override;

  const ADVectorVariableGradient & _grad_velocity;

  const ADMaterialProperty<Real> & _rho;

  const ADMaterialProperty<Real> & _mu_turb;
};
