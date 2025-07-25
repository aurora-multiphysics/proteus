#include "INSADEpsilonProduction.h"

registerMooseObject("ProteusApp", INSADEpsilonProduction);

InputParameters INSADEpsilonProduction::validParams() {
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription(
      "This class computes the residual and Jacobian contributions for "
      "turbulent dissipation rate production.");
  params.addRequiredCoupledVar("velocity", "The velocity");
  params.addRequiredCoupledVar("k", "Turbulent kinetic energy variable");
  params.addParam<MaterialPropertyName>("rho_name", "rho",
                                        "The name of the density");
  params.addParam<MaterialPropertyName>("mu_turb_name", "mu_turb",
                                        "The name of the turbulent viscosity");
  params.addParam<Real>("C_eps1", 1.44, "C_epsilon1");
  return params;
}

INSADEpsilonProduction::INSADEpsilonProduction(
    const InputParameters &parameters)
    : ADKernelValue(parameters),
      _grad_velocity(adCoupledVectorGradient("velocity")),
      _k(adCoupledValue("k")), _rho(getADMaterialProperty<Real>("rho_name")),
      _mu_turb(getADMaterialProperty<Real>("mu_turb_name")),
      _C_eps1(getParam<Real>("C_eps1")) {}

ADReal INSADEpsilonProduction::precomputeQpResidual() {
  if (_k[_qp] <= 0) {
    return 0;
  }
  auto divu = _grad_velocity[_qp](0, 0) + _grad_velocity[_qp](1, 1) +
              _grad_velocity[_qp](2, 2);
  return -1 * (_C_eps1 * _u[_qp] / _k[_qp]) *
         ((2.0 / 3.0) * _rho[_qp] * _u[_qp] * divu +
          _mu_turb[_qp] *
              ((divu * divu) +
               (_grad_velocity[_qp](0, 0) * _grad_velocity[_qp](0, 0)) +
               (_grad_velocity[_qp](0, 1) * _grad_velocity[_qp](0, 1)) +
               (_grad_velocity[_qp](0, 2) * _grad_velocity[_qp](0, 2)) +
               (_grad_velocity[_qp](1, 0) * _grad_velocity[_qp](1, 0)) +
               (_grad_velocity[_qp](1, 1) * _grad_velocity[_qp](1, 1)) +
               (_grad_velocity[_qp](1, 2) * _grad_velocity[_qp](1, 2)) +
               (_grad_velocity[_qp](2, 0) * _grad_velocity[_qp](2, 0)) +
               (_grad_velocity[_qp](2, 1) * _grad_velocity[_qp](2, 1)) +
               (_grad_velocity[_qp](2, 2) * _grad_velocity[_qp](2, 2))));
}
