#include "INSADKProduction.h"

registerMooseObject("ProteusApp", INSADKProduction);

InputParameters
INSADKProduction::validParams()
{
  InputParameters params = ADKernelValue::validParams();
  params.addClassDescription("This class computes the residual and Jacobian contributions for "
                             "turbulent kinetic energy production.");
  params.addRequiredCoupledVar("velocity", "The velocity");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");
  params.addParam<MaterialPropertyName>(
      "mu_turb_name", "mu_turb", "The name of the turbulent viscosity");
  return params;
}

INSADKProduction::INSADKProduction(const InputParameters & parameters)
  : ADKernelValue(parameters),
    _grad_velocity(adCoupledVectorGradient("velocity")),
    _rho(getADMaterialProperty<Real>("rho_name")),
    _mu_turb(getADMaterialProperty<Real>("mu_turb_name"))
{
}

ADReal
INSADKProduction::precomputeQpResidual()
{
  auto divu = _grad_velocity[_qp](0, 0) + _grad_velocity[_qp](1, 1) + _grad_velocity[_qp](2, 2);
  return -1 *
         ((2.0 / 3.0) * _rho[_qp] * _u[_qp] * divu +
          _mu_turb[_qp] * ((divu * divu) + (_grad_velocity[_qp](0, 0) * _grad_velocity[_qp](0, 0)) +
                           (_grad_velocity[_qp](0, 1) * _grad_velocity[_qp](0, 1)) +
                           (_grad_velocity[_qp](0, 2) * _grad_velocity[_qp](0, 2)) +
                           (_grad_velocity[_qp](1, 0) * _grad_velocity[_qp](1, 0)) +
                           (_grad_velocity[_qp](1, 1) * _grad_velocity[_qp](1, 1)) +
                           (_grad_velocity[_qp](1, 2) * _grad_velocity[_qp](1, 2)) +
                           (_grad_velocity[_qp](2, 0) * _grad_velocity[_qp](2, 0)) +
                           (_grad_velocity[_qp](2, 1) * _grad_velocity[_qp](2, 1)) +
                           (_grad_velocity[_qp](2, 2) * _grad_velocity[_qp](2, 2))));
}
