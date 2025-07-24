#include "TimeAverageAux.h"

registerMooseObject("ProteusApp", TimeAverageAux);

InputParameters
TimeAverageAux::validParams()
{
  InputParameters params = AuxKernel::validParams();

  params.addClassDescription("AuxKernel that performs time averaging of variables.");
  params.addRequiredCoupledVar("scalars",
                               "Scalar variables to be averaged. If multiple scalars are "
                               "given the average of their product is given.");
  return params;
}
TimeAverageAux::TimeAverageAux(const InputParameters & parameters)
  : AuxKernel(parameters),
    // Both the old and the current values to make average time integration second order
    _scalars(coupledValues("scalars")),
    _scalars_old(coupledValuesOld("scalars"))
{
}

Real
TimeAverageAux::computeValue()
{
  const Real coeff = _dt / _t;
  Real val = 1., val_old = 1.;

  // compute value and old value using product of input scalars
  for (auto & v : _scalars)
  {
    val *= (*v)[_qp];
  }
  for (auto & v : _scalars_old)
  {
    val_old *= (*v)[_qp];
  }

  // Add weighted contribution of current step. Average contribution
  // \frac{1}{T}\int_{0}^{T} f(t) dt
  // approximated using Trapezoid rule. For each step
  // \Delta t(f_2 + f_1)/2

  return (1. - coeff) * value()[_qp] + 0.5 * coeff * (val + val_old);
}
