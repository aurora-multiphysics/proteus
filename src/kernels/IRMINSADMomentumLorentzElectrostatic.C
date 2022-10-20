#include "IRMINSADMomentumLorentzElectrostatic.h"

registerMooseObject("ProteusApp", IRMINSADMomentumLorentzElectrostatic);

InputParameters
IRMINSADMomentumLorentzElectrostatic::validParams()
{
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription( // need to correct this
      "The Lorentz force velocity term ($\\sigma (\\vec{u} \\times \\vec{B}_0) \\times \\vec{B}_0), "
      "with the weak form of $(\\phi_i, \\sigma (\\vec{u} \\times \\vec{B}_0) \\times \\vec{B}_0). "
      "The Jacobian is computed using automatic differentiation");
  // need _grad_electic_potential
  params.addRequiredCoupledVar("magneticField", "The variable representing the magnetic field.");
  params.addParam<MaterialPropertyName>("conductivity", "conductivity", "The name of the conductivity");

  return params;
}

IRMINSADMomentumLorentzElectrostatic::IRMINSADMomentumLorentzElectrostatic(const InputParameters & parameters)
  : ADVectorKernelValue(parameters),
  // need _grad_electric_potential
  _magnetic_field(adCoupledVectorValue("magneticField")),
  _conductivity(getADMaterialProperty<Real>("conductivity"))
{
}

ADRealVectorValue
IRMINSADMomentumLorentzElectrostatic::precomputeQpResidual()
{
  // auto gradEPxB = _grad_electric_potential[_qp].cross(_magnetic_field[_qp]);
  // return _conductivity[_qp] * gradEPxB;
  return _magnetic_field[_qp]; //dummy
}