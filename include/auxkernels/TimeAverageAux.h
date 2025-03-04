#pragma once

#include "AuxKernel.h"
#include "MooseArray.h"
#include "MooseTypes.h"

class TimeAverageAux : public AuxKernel
{
public:
  static InputParameters validParams();

  TimeAverageAux(const InputParameters & parameters);

protected:
  Real computeValue() override;

  std::vector<const VariableValue*> _scalars;
  std::vector<const VariableValue*> _scalars_old;

};