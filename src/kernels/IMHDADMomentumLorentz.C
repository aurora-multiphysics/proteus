#include "IMHDADMomentumLorentz.h"

registerMooseObject("ProteusApp", IMHDADMomentumLorentz);

InputParameters
IMHDADMomentumLorentz::validParams()
{
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription(
      "The Lorentz force term ($\\vec{J} \\times \\vec{B}_0$), "
      "with the weak form of ($\\phi_u, \\vec{J} \\times \\vec{B}_0$)."
      "The Jacobian is computed using automatic differentiation.");
  params.addRequiredCoupledVar("currentDensity", "The variable representing the electric current density");
  params.addParam<FunctionName>("magneticFieldFunction",
                                "A function defining a vectorValue method that describes the imposed magnetic field");
  params.addParam<FunctionName>(
      "magneticFieldFunction_x", "0", "A function that describes the x-component of the imposed magnetic field");
  params.addParam<FunctionName>(
      "magneticFieldFunction_y", "0", "A function that describes the y-component of the imposed magnetic field");
  params.addParam<FunctionName>(
      "magneticFieldFunction_z", "0", "A function that describes the z-component of the imposed magnetic field");

  return params;
}

IMHDADMomentumLorentz::IMHDADMomentumLorentz(const InputParameters & parameters)
  : ADVectorKernelValue(parameters),
  _current_density(adCoupledVectorValue("currentDensity")),
  _magnetic_field(isParamValid("magneticFieldFunction") ? &getFunction("magneticFieldFunction") : nullptr),
  _magnetic_field_x(getFunction("magneticFieldFunction_x")),
  _magnetic_field_y(getFunction("magneticFieldFunction_y")),
  _magnetic_field_z(getFunction("magneticFieldFunction_z"))
{
  if (_magnetic_field && parameters.isParamSetByUser("_magnetic_field_x"))
    paramError("magneticFieldFunction_x", "The 'magneticFieldFunction' and 'magneticFieldFunction_x' parameters cannot both be set.");
  if (_magnetic_field && parameters.isParamSetByUser("_magnetic_field_y"))
    paramError("magneticFieldFunction_y", "The 'magneticFieldFunction' and 'magneticFieldFunction_y' parameters cannot both be set.");
  if (_magnetic_field && parameters.isParamSetByUser("_magnetic_field_z"))
    paramError("magneticFieldFunction_z", "The 'magneticFieldFunction' and 'magneticFieldFunction_z' parameters cannot both be set.");
}

ADRealVectorValue
IMHDADMomentumLorentz::precomputeQpResidual()
{
  if (_magnetic_field)
    return -_current_density[_qp].cross(_magnetic_field->vectorValue(_t, _q_point[_qp]));
  else
    return -_current_density[_qp].cross(RealVectorValue(_magnetic_field_x.value(_t, _q_point[_qp]),
                                                        _magnetic_field_y.value(_t, _q_point[_qp]),
                                                        _magnetic_field_z.value(_t, _q_point[_qp])));
}
