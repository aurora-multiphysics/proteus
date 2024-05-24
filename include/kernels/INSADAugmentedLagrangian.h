#pragma once

#include "ADKernel.h"

/**
 * This class computes the residual and Jacobian contributions for the 
 * augmented Lagrangian stabilisation term.
 */
class INSADAugmentedLagrangian : public ADVectorKernel
{
public:
  static InputParameters validParams();

  INSADAugmentedLagrangian(const InputParameters & parameters);

protected:
  // virtual ADRealVectorValue computeQpResidual() override;
  virtual ADReal computeQpResidual() override;

  /// div of the vector variable
  const VectorVariableDivergence & _div_u;

  /// div of the vector test function
  const VectorVariableTestDivergence & _div_test;

  /// scalar coefficient
  ADReal _coeff;
};
