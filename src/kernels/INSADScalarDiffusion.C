#include "INSADScalarDiffusion.h"

registerMooseObject("ProteusApp", INSADScalarDiffusion);

InputParameters
INSADScalarDiffusion::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription("This class computes the residual and Jacobian contributions for "
			     "turbulent diffusion of a scalar.");
  params.addParam<MaterialPropertyName>("mu_lam_name", "mu_lam", "The name of the laminar viscosity");
  params.addParam<MaterialPropertyName>("mu_turb_name", "mu_turb", "The name of the turbulent viscosity");
  params.addParam<Real>("sigma", 1, "The sigma term in turbulent diffusion");
  return params;
}

INSADScalarDiffusion::INSADScalarDiffusion(const InputParameters & parameters)
  : ADKernelGrad(parameters),
    _mu_lam(getADMaterialProperty<Real>("mu_lam_name")),
    _mu_turb(getADMaterialProperty<Real>("mu_turb_name")),
    _sigma(getParam<Real>("sigma"))
{
}

ADRealVectorValue
INSADScalarDiffusion::precomputeQpResidual()
{
  return (_mu_lam[_qp] + _mu_turb[_qp] / _sigma) *  _grad_u[_qp];
}
