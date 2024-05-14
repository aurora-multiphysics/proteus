#include "IMHDADMomentumLorentz.h"

registerMooseObject("ProteusApp", IMHDADMomentumLorentz);

InputParameters
IMHDADMomentumLorentz::validParams()
{
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription(
      "The Lorentz force term ($\\vec{J} \\times \\vec{B}_0$), "
      "with the weak form of ($\\phi_u, \\vec{J} \\times \\vec{B}_0$)."
      "The Jacobian is computed using automatic differentiation.");
  params.addRequiredCoupledVar("currentDensity", "The variable representing the electric current density");
  params.addRequiredCoupledVar("magneticField", "The variable representing the magnetic field");

  return params;
}

IMHDADMomentumLorentz::IMHDADMomentumLorentz(const InputParameters & parameters)
  : ADVectorKernelValue(parameters),
  _current_density(adCoupledVectorValue("currentDensity")),
  _magnetic_field(adCoupledVectorValue("magneticField"))
{
}

ADRealVectorValue
IMHDADMomentumLorentz::precomputeQpResidual()
{
  return _current_density[_qp].cross(_magnetic_field[_qp]);
}
