#pragma once

#include "ADKernelValue.h"

/**
 * This class computes the momentum equation residual and Jacobian
 * contributions for the Lorentz force term of the inductionless resistive MHD
 * incompressible Navier-Stokes momentum equation.
 */
class IRMINSADMomentumLorentz : public ADVectorKernelValue {
public:
  static InputParameters validParams();

  IRMINSADMomentumLorentz(const InputParameters &parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADMaterialProperty<RealVectorValue>
      &_lorentz_electrostatic_strong_residual;
  const ADMaterialProperty<RealVectorValue> &_lorentz_flow_strong_residual;
};
