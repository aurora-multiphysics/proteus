#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the residual and Jacobian contributions for the 
 * U cross B term of the electric current density equation.
 */
class IMHDADCurrentUxB : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  IMHDADCurrentUxB(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVectorVariableValue & _velocity;
  const ADVectorVariableValue & _magnetic_field;
};
