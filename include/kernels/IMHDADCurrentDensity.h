#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the residual and Jacobian contributions for the 
 * left-hand-side of the explicit calculation of the electric current density equation.
 */
class IMHDADCurrentDensity : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  IMHDADCurrentDensity(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADMaterialProperty<Real> & _conductivity;
};
