
#include "VectorTimeAverageAux.h"

registerMooseObject("ProteusApp", VectorTimeAverageAux);

InputParameters
VectorTimeAverageAux::validParams()
{
  InputParameters params = VectorAuxKernel::validParams();

  params.addClassDescription("VectorAuxKernel that performs time averaging of vectors.");

  params.addRequiredCoupledVar("vectors",
                       "Vector variables to be time averaged."
                       "If multiple vectors are provided the average of their "
                       "component-wise multiplication is given. ");

  params.addCoupledVar("scalars",
                       "Scalar variables to be included in the time average. "
                       "If scalars are are given the average of their product with the vector "
                       "averages is given");
  return params;
}
VectorTimeAverageAux::VectorTimeAverageAux(const InputParameters & parameters)
  : VectorAuxKernel(parameters),
    // Both the old and the current values to make average time integration second order
    _scalars(coupledValues("scalars")),
    _scalars_old(coupledValuesOld("scalars")),
    _vectors(coupledVectorValues("vectors")),
    // There isn't a coupledVectorValuesOld method for some reason.
    // Elements must be set later
    _vectors_old(_vectors.size())
{

  // setting vectors old
  for (int i =0; i<_vectors.size(); ++i){
    _vectors_old[i] = &coupledVectorValueOld("vectors", i);
  }
}

void VectorTimeAverageAux::initialSetup()
{
  // size average arrays after initialisation
  _average.resize(_vectors[0]->size());
  _average_old.resize(_vectors_old[0]->size());
}

void VectorTimeAverageAux::timestepSetup()
{
  // set average old for the time step
  _average_old = _average;
}

RealVectorValue VectorTimeAverageAux::computeValue()
{
  const Real coeff =  _dt/_t;
  RealVectorValue value ={1., 1., 1.}, value_old={1., 1., 1.};

  // Multiply  value and value_old values by the scalars first
  for (auto& v: _scalars){
    value *= (*v)[_qp];
  }
  for (auto& v: _scalars_old){
    value_old*= (*v)[_qp];
  }

  // Multiply  value and value_old values by the vectors component-wise
  for (auto& v: _vectors){
    for (int i=0; i< LIBMESH_DIM; ++i){
      value(i) *= (*v)[_qp](i);
    }
  }
  for (auto& v: _vectors_old){
    for (int i=0; i< LIBMESH_DIM; ++i){
      value_old(i) *= (*v)[_qp](i);
    }
  }

  // Add weighted contribution of current step. Average contribution
  // \frac{1}{T}\int_{0}^{T} f(t) dt
  // approximated using Trapezoid rule. For each step
  // \Delta t(f_2 + f_1)/2
  _average[_qp] = (1. - coeff)*_average_old[_qp] + 0.5*coeff*(value + value_old);

  return _average[_qp];
}