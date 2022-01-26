#pragma once

#include "ADMaterial.h"

class INSADKEpsilonMaterial;

class INSADKEpsilonMaterial : public ADMaterial
{
public:
  static InputParameters validParams();

  INSADKEpsilonMaterial(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  const ADVariableValue & _k;
  const ADVariableValue & _epsilon;

  const Real _user_mu;
  const Real _user_rho;
  const Real _Cmu;

  ADMaterialProperty<Real> & _mu_lam;
  ADMaterialProperty<Real> & _rho;
  ADMaterialProperty<Real> & _mu_turb;
  ADMaterialProperty<Real> & _mu;
};
