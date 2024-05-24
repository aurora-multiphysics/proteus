#include "IMHDADCurrentUxB.h"

registerMooseObject("ProteusApp", IMHDADCurrentUxB);

InputParameters
IMHDADCurrentUxB::validParams()
{
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription(
      "The electric current velocity source term ($-\\vec{U} \\times \\vec{B}$), "
      "with the weak form of ($\\phi_u, -\\vec{U} \\times \\vec{B}$). "
      "The Jacobian is computed using automatic differentiation.");
  params.addRequiredCoupledVar("velocity", "The variable representing the velocity");
  params.addRequiredCoupledVar("magneticField", "The variable representing the magnetic field");

  return params;
}

IMHDADCurrentUxB::IMHDADCurrentUxB(const InputParameters & parameters)
  : ADVectorKernelValue(parameters),
  _velocity(adCoupledVectorValue("velocity")),
  _magnetic_field(adCoupledVectorValue("magneticField"))
{
}

ADRealVectorValue
IMHDADCurrentUxB::precomputeQpResidual()
{
  return -_velocity[_qp].cross(_magnetic_field[_qp]);
}
