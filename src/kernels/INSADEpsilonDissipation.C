#include "INSADEpsilonDissipation.h"

registerMooseObject("ProteusApp", INSADEpsilonDissipation);

InputParameters
INSADEpsilonDissipation::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("This class computes the residual and Jacobian contributions for "
			     "turbulent dissipation rate dissipation.");
  params.addRequiredCoupledVar("k", "Turbulent kinetic energy variable");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");
  params.addParam<Real>("C_eps2", 1.92, "C_epsilon2");
  return params;
}

INSADEpsilonDissipation::INSADEpsilonDissipation(const InputParameters & parameters)
  : ADKernelValue(parameters),
    _k(adCoupledValue("k")),
    _rho(getADMaterialProperty<Real>("rho_name")),
    _C_eps2(getParam<Real>("C_eps2"))
{
}

ADReal
INSADEpsilonDissipation::precomputeQpResidual()
{
  if (_k[_qp] <= 0) {
    return 0;
  }
  return _C_eps2 * _rho[_qp] * _u[_qp] * _u[_qp] / _k[_qp];
}
