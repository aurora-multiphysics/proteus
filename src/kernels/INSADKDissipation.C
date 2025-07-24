#include "INSADKDissipation.h"

registerMooseObject("ProteusApp", INSADKDissipation);

InputParameters
INSADKDissipation::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("This class computes the residual and Jacobian contributions for "
                             "turbulent kinetic energy dissipation.");
  params.addRequiredCoupledVar("epsilon", "Turbulent kinetic energy dissipation variable");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");
  return params;
}

INSADKDissipation::INSADKDissipation(const InputParameters & parameters)
  : ADKernelValue(parameters),
    _epsilon(adCoupledValue("epsilon")),
    _rho(getADMaterialProperty<Real>("rho_name"))
{
}

ADReal
INSADKDissipation::precomputeQpResidual()
{
  return _rho[_qp] * _epsilon[_qp];
}
