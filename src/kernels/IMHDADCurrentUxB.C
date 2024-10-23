#include "IMHDADCurrentUxB.h"

registerMooseObject("ProteusApp", IMHDADCurrentUxB);

InputParameters
IMHDADCurrentUxB::validParams()
{
  InputParameters params = ADVectorKernelValue::validParams();
  params.addClassDescription(
      "The electric current velocity source term ($-\\vec{U} \\times \\vec{B}$), "
      "with the weak form of ($\\phi_u, -\\vec{U} \\times \\vec{B}$). "
      "The Jacobian is computed using automatic differentiation.");
  params.addRequiredCoupledVar("velocity", "The variable representing the velocity");
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

IMHDADCurrentUxB::IMHDADCurrentUxB(const InputParameters & parameters)
  : ADVectorKernelValue(parameters),
  _velocity(adCoupledVectorValue("velocity")),
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
IMHDADCurrentUxB::precomputeQpResidual()
{
  if (_magnetic_field)
    return -_velocity[_qp].cross(_magnetic_field->vectorValue(_t, _q_point[_qp]));
  else
    return -_velocity[_qp].cross(RealVectorValue(_magnetic_field_x.value(_t, _q_point[_qp]),
                                                        _magnetic_field_y.value(_t, _q_point[_qp]),
                                                        _magnetic_field_z.value(_t, _q_point[_qp])));
}
