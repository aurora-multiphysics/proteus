#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the residual and Jacobian contributions for the
 * UxB part of the Lorentz force term of the inductionless
 * resistive MHD incompressible Navier-Stokes momentum equation.
 */
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
