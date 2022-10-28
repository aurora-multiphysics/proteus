#pragma once

#include "ADKernelValue.h"

class IRMINSADMomentumLorentzElectrostatic : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  IRMINSADMomentumLorentzElectrostatic(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVariableGradient & _grad_epot;

  const ADVectorVariableValue & _magnetic_field;

  const ADMaterialProperty<Real> & _conductivity;
};
