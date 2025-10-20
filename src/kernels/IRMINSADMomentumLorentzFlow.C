#include "IRMINSADMomentumLorentzFlow.h"

registerMooseObject("ProteusApp", IRMINSADMomentumLorentzFlow);

InputParameters IRMINSADMomentumLorentzFlow::validParams() {
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription(
      "The Lorentz force velocity term ($- \\sigma (\\vec{u} \\times "
      "\\vec{B}_0) \\times \\vec{B}_0), "
      "with the weak form of $(\\phi_i, - \\sigma (\\vec{u} \\times "
      "\\vec{B}_0) \\times \\vec{B}_0). "
      "The Jacobian is computed using automatic differentiation.");
  params.addRequiredCoupledVar("velocity",
                               "The variable representing the velocity");
  params.addRequiredCoupledVar("magneticField",
                               "The variable representing the magnetic field");
  params.addParam<MaterialPropertyName>("conductivity", "conductivity",
                                        "The name of the conductivity");

  return params;
}

IRMINSADMomentumLorentzFlow::IRMINSADMomentumLorentzFlow(
    const InputParameters &parameters)
    : ADVectorKernelValue(parameters),
      _velocity(adCoupledVectorValue("velocity")),
      _magnetic_field(adCoupledVectorValue("magneticField")),
      _conductivity(getADMaterialProperty<Real>("conductivity")) {}

ADRealVectorValue IRMINSADMomentumLorentzFlow::precomputeQpResidual() {
  auto UxB = _velocity[_qp].cross(_magnetic_field[_qp]);
  return -_conductivity[_qp] * UxB.cross(_magnetic_field[_qp]);
}
