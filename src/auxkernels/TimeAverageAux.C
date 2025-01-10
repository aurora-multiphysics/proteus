#include "TimeAverageAux.h"

registerMooseObject("ProteusApp", TimeAverageAux);

InputParameters
TimeAverageAux::validParams()
{
  InputParameters params = AuxKernel::validParams();

  params.addClassDescription("AuxKernel that performs time averaging of variables."
                             "");
  params.addRequiredCoupledVar("scalars",
                       "Scalar variables to be averaged");
  return params;
}
TimeAverageAux::TimeAverageAux(const InputParameters & parameters)
  : AuxKernel(parameters),
    // Both the old and the current values to make average time integration second order
    _scalars(coupledValues("scalars")),
    _scalars_old(coupledValuesOld("scalars"))
{
}

void TimeAverageAux::initialSetup()
{
  // size average arrays after initialisation
  _average.resize(_scalars[0]->size());
  _average_old.resize(_scalars_old[0]->size());
}

void TimeAverageAux::timestepSetup()
{
  // set average old for the time step
  _average_old = _average;
}

// template specialisation for Real
Real TimeAverageAux::computeValue()
{
  const Real coeff =  _dt/_t;
  Real value =1., value_old=1.;

  // compute value and old value using product of input scalars
  for (auto& v: _scalars){
    value *= (*v)[_qp];
  }
  for (auto& v: _scalars_old){
    value_old*= (*v)[_qp];
  }

  // Add weighted contribution of current step. Average contribution
  // \frac{1}{T}\int_{0}^{T} f(t) dt
  // approximated using Trapezoid rule. For each step
  // \Delta t(f_2 + f_1)/2
  _average[_qp] = (1. - coeff)*_average_old[_qp] + 0.5*coeff*(value + value_old);

  return _average[_qp];
}