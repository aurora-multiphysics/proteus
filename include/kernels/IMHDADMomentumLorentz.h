#pragma once

#include "ADKernelValue.h"
#include "Function.h"

class Function;

/**
 * This class computes the residual and Jacobian contributions for the
 * Lorentz force term of the incompressible inductionless MHD momentum equation
 * using a coupled current density variable and an imposed magnetic field
 * function.
 */
class IMHDADMomentumLorentz : public ADVectorKernelValue {
public:
  static InputParameters validParams();

  IMHDADMomentumLorentz(const InputParameters &parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVectorVariableValue &_current_density;

  /// Optional vectorValue function
  const Function *const _magnetic_field;

  /// Optional component function value
  const Function &_magnetic_field_x;
  const Function &_magnetic_field_y;
  const Function &_magnetic_field_z;
};
