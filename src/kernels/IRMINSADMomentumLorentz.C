#include "IRMINSADMomentumLorentz.h"

registerMooseObject("ProteusApp", IRMINSADMomentumLorentz);

InputParameters IRMINSADMomentumLorentz::validParams() {
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription(
      "Adds the Lorentz force term to the (IRM)INS momentum equation. "
      "This kernel uses strong residuals for the electrostatic and flow terms, "
      "which are calculated in IRMINSADMaterial and added to the total "
      "momentum strong residual in "
      "IRMINSADTauMaterial.");
  return params;
}

IRMINSADMomentumLorentz::IRMINSADMomentumLorentz(
    const InputParameters &parameters)
    : ADVectorKernelValue(parameters),
      _lorentz_electrostatic_strong_residual(
          getADMaterialProperty<RealVectorValue>(
              "lorentz_electrostatic_strong_residual")),
      _lorentz_flow_strong_residual(getADMaterialProperty<RealVectorValue>(
          "lorentz_flow_strong_residual")) {}

ADRealVectorValue IRMINSADMomentumLorentz::precomputeQpResidual() {
  return _lorentz_electrostatic_strong_residual[_qp] +
         _lorentz_flow_strong_residual[_qp];
}
