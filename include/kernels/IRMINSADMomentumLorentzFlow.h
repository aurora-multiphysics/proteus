#pragma once

#include "ADKernelValue.h"

class IRMINSADMomentumLorentzFlow : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  IRMINSADMomentumLorentzFlow(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVectorVariableValue & _velocity;
  const ADVectorVariableValue & _magnetic_field;

  const ADMaterialProperty<Real> & _conductivity;
};
