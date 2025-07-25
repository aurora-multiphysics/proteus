
#include "VectorTimeAverageAux.h"

registerMooseObject("ProteusApp", VectorTimeAverageAux);

InputParameters VectorTimeAverageAux::validParams() {
  InputParameters params = VectorAuxKernel::validParams();

  params.addClassDescription(
      "VectorAuxKernel that performs time averaging of vectors.");

  params.addRequiredCoupledVar(
      "vectors", "Vector variables to be time averaged."
                 "If multiple vectors are provided the average of their "
                 "component-wise multiplication is given. ");

  params.addCoupledVar(
      "scalars",
      "Scalar variables to be included in the time average. "
      "If scalars are are given the average of their product with the vector "
      "averages is given.");
  return params;
}
VectorTimeAverageAux::VectorTimeAverageAux(const InputParameters &parameters)
    : VectorAuxKernel(parameters),
      // Both the old and the current values to make average time integration
      // second order
      _scalars(coupledValues("scalars")),
      _scalars_old(coupledValuesOld("scalars")),
      _vectors(coupledVectorValues("vectors")),
      // There isn't a coupledVectorValuesOld method for some reason.
      // Elements must be set later
      _vectors_old(_vectors.size()) {

  // setting vectors old
  for (int i = 0; i < _vectors.size(); ++i) {
    _vectors_old[i] = &coupledVectorValueOld("vectors", i);
  }
}

RealVectorValue VectorTimeAverageAux::computeValue() {
  const Real coeff = _dt / _t;
  RealVectorValue val = {1., 1., 1.}, val_old = {1., 1., 1.};

  // Multiply value and value_old values by the scalars first
  for (auto &v : _scalars) {
    val *= (*v)[_qp];
  }
  for (auto &v : _scalars_old) {
    val_old *= (*v)[_qp];
  }

  // Multiply value and value_old values by the vectors component-wise
  for (auto &v : _vectors) {
    for (int i = 0; i < LIBMESH_DIM; ++i) {
      val(i) *= (*v)[_qp](i);
    }
  }
  for (auto &v : _vectors_old) {
    for (int i = 0; i < LIBMESH_DIM; ++i) {
      val_old(i) *= (*v)[_qp](i);
    }
  }

  // Add weighted contribution of current step. Average contribution
  // \frac{1}{T}\int_{0}^{T} f(t) dt
  // approximated using Trapezoid rule. For each step
  // \Delta t(f_2 + f_1)/2
  return (1. - coeff) * value()[_qp] + 0.5 * coeff * (val + val_old);
}
