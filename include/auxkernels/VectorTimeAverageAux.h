#pragma once

#include "AuxKernel.h"
#include "MooseArray.h"
#include "MooseTypes.h"

class VectorTimeAverageAux : public VectorAuxKernel
{
public:
  static InputParameters validParams();

  VectorTimeAverageAux(const InputParameters & parameters);

protected:
  RealVectorValue computeValue() override;

  std::vector<const VariableValue*> _scalars;
  std::vector<const VariableValue*> _scalars_old;

  std::vector<const VectorVariableValue*> _vectors;
  std::vector<const VectorVariableValue*> _vectors_old;
};