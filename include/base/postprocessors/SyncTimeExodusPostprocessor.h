#pragma once

#include "GeneralPostprocessor.h"

class SyncTimeExodusPostprocessor : public GeneralPostprocessor
{
public:
  static InputParameters validParams();

  SyncTimeExodusPostprocessor(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual double getValue() override;

protected:
  double _time_increment;
};