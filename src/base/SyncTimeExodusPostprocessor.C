#include "SyncTimeExodusPostprocessor.h"

registerMooseObject("ProteusApp", SyncTimeExodusPostprocessor);

InputParameters
SyncTimeExodusPostprocessor::validParams()
{
  InputParameters params = GeneralPostprocessor::validParams();
  params.addRequiredParam<double>(
      "time_increment",
      "The time increment for which sync_times is called at");
  return params;
}

SyncTimeExodusPostprocessor::SyncTimeExodusPostprocessor(const InputParameters & parameters)
  : GeneralPostprocessor(parameters),
    _time_increment(getParam<double>("time_increment"))
{
  Transient * _moose_executioner = dynamic_cast<Transient *>(_app.getExecutioner());
  if (_moose_executioner == NULL) {
    mooseError("Only Transient Executioners are currently supported for SyncTimeExodus")
  }
  synctimes_vals = _moose_executioner->syncTimes(); 
}

void
SyncTimeExodusPostprocessor::initialize()
{
}

void
SyncTimeExodusPostprocessor::execute()
{
}

double
SyncTimeExodusPostprocessor::getValue()
{ 
  _eof_set = synctimes_vals.end() -1;
  while (_time_increment <= synctimes_vals(_eof_set)) {
    _time_increment = _time_increment + _time_increment;
    return synctimes_vals(_time_increment);
  }
}