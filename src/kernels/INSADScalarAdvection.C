#include "INSADScalarAdvection.h"

registerMooseObject("ProteusApp", INSADScalarAdvection);

InputParameters
INSADScalarAdvection::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("This class computes the residual and Jacobian contributions for "
			     "scalar advection for a divergence free velocity field.");
  params.addRequiredCoupledVar("velocity", "The velocity");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");
  return params;
}

INSADScalarAdvection::INSADScalarAdvection(const InputParameters & parameters)
  : ADKernelValue(parameters),
    _velocity(adCoupledVectorValue("velocity")),
    _rho(getADMaterialProperty<Real>("rho_name"))
{
}

ADReal
INSADScalarAdvection::precomputeQpResidual()
{
  return _rho[_qp] * _velocity[_qp] * _grad_u[_qp];
}
