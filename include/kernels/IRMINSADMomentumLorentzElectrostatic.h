#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the residual and Jacobian contributions for the
 * velocity part of the Lorentz force term of the inductionless
 * resistive MHD incompressible Navier-Stokes momentum equation.
 */
class IRMINSADMomentumLorentzElectrostatic : public ADVectorKernelValue {
public:
  static InputParameters validParams();

  IRMINSADMomentumLorentzElectrostatic(const InputParameters &parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVariableGradient &_grad_epot;

  const ADVectorVariableValue &_magnetic_field;

  const ADMaterialProperty<Real> &_conductivity;
};
