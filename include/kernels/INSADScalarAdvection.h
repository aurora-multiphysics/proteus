#pragma once

#include "ADKernelValue.h"

class INSADScalarAdvection;

class INSADScalarAdvection : public ADKernelValue
{
public:
  static InputParameters validParams();

  INSADScalarAdvection(const InputParameters & parameters);

 protected:
  virtual ADReal precomputeQpResidual() override;

  const ADVectorVariableValue & _velocity;

  const ADMaterialProperty<Real> & _rho;
};
