#pragma once

#include "ADKernelGrad.h"

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
