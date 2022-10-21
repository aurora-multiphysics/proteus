#pragma once

#include "ADKernelValue.h"

class IRMINSADMomentumLorentzElectrostatic : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  IRMINSADMomentumLorentzElectrostatic(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  // need _grad_electric_potential
  const ADVariableGradient & _grad_epot; // should this be in private?
  const ADVectorVariableValue & _magnetic_field;

  const ADMaterialProperty<Real> & _conductivity;
};
