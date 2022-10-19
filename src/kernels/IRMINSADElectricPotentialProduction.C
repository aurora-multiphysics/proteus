#include "IRMINSADElectricPotentialProduction.h"

registerMooseObject("ProteusApp", IRMINSADElectricPotentialProduction);

InputParameters
IRMINSADElectricPotentialProduction::validParams()
{
  InputParameters params = ADKernelGrad::validParams();
  params.addClassDescription(
      "The Electric Potential production term ($\\nabla \\cdot (\\vec{u} \\times \\vec{B}_0)), "
      "with the weak form of $(-\\nabla \\vec{\\phi_i}, (\\vec{u} \\times \\vec{B}_0)). "
      "The Jacobian is computed using automatic differentiation");
  params.addRequiredCoupledVar("velocity", "The variable representing the velocity.");
  params.addRequiredCoupledVar("magneticField", "The variable representing the magnetic field.");

  return params;
}

IRMINSADElectricPotentialProduction::IRMINSADElectricPotentialProduction(const InputParameters & parameters)
  : ADKernelGrad(parameters),
  _velocity(adCoupledVectorValue("velocity")),
  _magnetic_field(adCoupledVectorValue("magneticField"))
{
}

ADRealVectorValue
IRMINSADElectricPotentialProduction::precomputeQpResidual()
{
  return _velocity[_qp].cross(_magnetic_field[_qp]);
}