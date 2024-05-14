#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the residual and Jacobian contributions for the 
 * Lorentz force term of the incompressible inductionless MHD momentum equation.
 */
class IMHDADMomentumLorentz : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  IMHDADMomentumLorentz(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVectorVariableValue & _current_density;

  const ADVectorVariableValue & _magnetic_field;
};
