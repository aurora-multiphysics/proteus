#include "IMHDADCurrentDensity.h"

registerMooseObject("ProteusApp", IMHDADCurrentDensity);

InputParameters
IMHDADCurrentDensity::validParams()
{
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription(
      "The electric current term ($\\sigma^{-1}\\vec{J}$), "
      "with the weak form of ($\\phi_u, \\sigma^{-1}\\vec{J}$). "
      "The Jacobian is computed using automatic differentiation.");
  params.addParam<MaterialPropertyName>("conductivity", "conductivity", "The name of the conductivity");

  return params;
}

IMHDADCurrentDensity::IMHDADCurrentDensity(const InputParameters & parameters)
  : ADVectorKernelValue(parameters),
  _conductivity(getADMaterialProperty<Real>("conductivity"))
{
}

ADRealVectorValue
IMHDADCurrentDensity::precomputeQpResidual()
{
  return _u[_qp]/_conductivity[_qp];
}
