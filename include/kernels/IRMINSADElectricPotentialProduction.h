#pragma once

#include "ADKernelGrad.h"

/**
 * This class computes the weak form residual and Jacobian contributions
 * for the production term of the inductionless resistive incompressible
 * MHD electric potential equation.
 */
class IRMINSADElectricPotentialProduction : public ADKernelGrad
{
public:
  static InputParameters validParams();

  IRMINSADElectricPotentialProduction(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADVectorVariableValue & _velocity;
  const ADVectorVariableValue & _magnetic_field;
};
