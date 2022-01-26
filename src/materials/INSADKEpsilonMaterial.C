#include "INSADKEpsilonMaterial.h"

registerMooseObject("ProteusApp", INSADKEpsilonMaterial);

template <>
InputParameters
validParams<INSADKEpsilonMaterial>()
{
  InputParameters params = validParams<Material>();

  params.addClassDescription("Material class for INS turbulence modeling.");
  params.addRequiredCoupledVar("k", "The turbulent kinetic energy");
  params.addRequiredCoupledVar("epsilon", "The turbulent dissipation");
  params.addParam<Real>("mu", 1, "The dynamic viscosity");
  params.addParam<Real>("rho", 1, "The density");
  params.addParam<Real>("C_mu", 0.09, "C_mu parameter");
  return params;
}

INSADKEpsilonMaterial::INSADKEpsilonMaterial(const InputParameters & parameters)
  : Material(parameters),
    _k(adCoupledValue("k")),
    _epsilon(adCoupledValue("epsilon")),
    _user_mu(getParam<Real>("mu")),
    _user_rho(getParam<Real>("rho")),
    _Cmu(getParam<Real>("C_mu")),
    _mu_lam(declareADProperty<Real>("mu_lam")),
    _rho(declareADProperty<Real>("rho")),
    _mu_turb(declareADProperty<Real>("mu_turb")),
    _mu(declareADProperty<Real>("mu"))
{
}

void
INSADKEpsilonMaterial::computeQpProperties()
{
  _mu_lam[_qp] = _user_mu;
  _rho[_qp] = _user_rho;
  _mu_turb[_qp] = _epsilon[_qp] > 0 ? _user_rho * _Cmu * _k[_qp] * _k[_qp] / _epsilon[_qp] : 0;
  _mu[_qp] = _user_mu + _mu_turb[_qp];
}
