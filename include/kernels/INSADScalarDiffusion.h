#pragma once

#include "ADKernelGrad.h"

class INSADScalarDiffusion;

class INSADScalarDiffusion : public ADKernelGrad
{
public:
  static InputParameters validParams();

  INSADScalarDiffusion(const InputParameters & parameters);

protected:
  virtual ADRealVectorValue precomputeQpResidual() override;

  const ADMaterialProperty<Real> & _mu_lam;

  const ADMaterialProperty<Real> & _mu_turb;

  const Real _sigma;
};
