#include "INSADAugmentedLagrangian.h"

registerMooseObject("ProteusApp", INSADAugmentedLagrangian);

InputParameters
INSADAugmentedLagrangian::validParams()
{
  InputParameters params = ADVectorKernel::validParams();
  params.addClassDescription(
      "The augmented Lagrangian term, "
      "with the weak form of ($\\alpha(\\nabla \\cdot \\phi_u, \\nabla \\cdot u)$), "
      "where $\\alpha>0$ is the scalar AL-stabilisation parameter. "
      "The Jacobian is computed using automatic differentiation.");
  params.addParam<ADReal>("coeff", 1.0, "The AL-stabilisation parameter")

  return params;
}

INSADAugmentedLagrangian::INSADAugmentedLagrangian(const InputParameters & parameters)
  : ADVectorKernel(parameters),
  
  _div_test(_var.divPhi()),
  _coeff(getParam<Real>("coeff"))
{
}

ADReal
INSADAugmentedLagrangian::precomputeQpResidual()
{
  return _coeff * _div_u[_qp] * _div_test[_qp];
}
