#include "PointForcingFunction3DEquivalent.h"

#include "Function.h"

registerMooseObject("ProteusApp", PointForcingFunction3DEquivalent);

InputParameters
PointForcingFunction3DEquivalent::validParams()
{
  InputParameters params = NodalKernel::validParams();
  params.addRequiredParam<FunctionName>("function",
					"The forcing function");
  params.addRequiredCoupledVar("nodal_area",
			       "AuxVariable containing the nodal area");
  params.addRequiredParam<PostprocessorName>("total_area_postprocessor",
					     "The name of the postprocessor that is going to be computing the "
					     "total area of the section.");
  params.addClassDescription("This object distributes the specified magnitude of a force to all nodes "
			     "on a 2D boundary and weighs them by their tributary surface area. This "
			     "modelling approach is analogous with applying a concentrated force to a "
			     "1D beam element.");
  return params;
}

PointForcingFunction3DEquivalent::PointForcingFunction3DEquivalent(const InputParameters & parameters)
  : NodalKernel(parameters),
    _func(getFunction("function")),
    _nodal_area(coupledValue("nodal_area")),
    _total_area(getPostprocessorValue("total_area_postprocessor"))
{
}

Real
PointForcingFunction3DEquivalent::computeQpResidual()
{
  return -_func.value(_t, (*_current_node)) * _nodal_area[_qp] / _total_area;
}
