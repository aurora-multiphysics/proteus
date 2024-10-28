#pragma once

#include "ADKernelValue.h"
#include "Function.h"

class Function;

/**
 * This class computes the residual and Jacobian contributions for the 
 * U cross B term of the electric current density equation
 * using a coupled velocity variable and an imposed magnetic field function.
 */
class IMHDADCurrentUxB : public ADVectorKernelValue
{
public:
  static InputParameters validParams();

  IMHDADCurrentUxB(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVectorVariableValue & _velocity;
  
  /// Optional vectorValue function
  const Function * const _magnetic_field;

  /// Optional component function value
  const Function & _magnetic_field_x;
  const Function & _magnetic_field_y;
  const Function & _magnetic_field_z;
};
