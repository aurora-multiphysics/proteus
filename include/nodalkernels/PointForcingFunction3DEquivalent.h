#pragma once

// MOOSE includes
#include "NodalKernel.h"

// Forward Declarations
class PointForcingFunction3DEquivalent;

template <>
InputParameters validParams<PointForcingFunction3DEquivalent>();

/*
 * This object distributes the specified magnitude of a force to all nodes
 * on a 2D boundary and weighs them by their tributary surface area. This
 * modelling approach is analogous with applying a concentrated force to a
 * 1D beam element.
 */
class PointForcingFunction3DEquivalent : public NodalKernel
{
 public:
  PointForcingFunction3DEquivalent(const InputParameters & parameters);

 protected:
  virtual Real computeQpResidual() override;

  const Function & _func;
  const VariableValue & _nodal_area;
  const PostprocessorValue & _total_area;
};
