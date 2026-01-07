#include "CoaxialElbow1Phase.h"
#include "InputParameters.h"
#include "VolumeJunction1Phase.h"

InputParameters CoaxialElbow1Phase::validParams() {
  auto params = VolumeJunction1Phase::validParams();

  params.addRequiredParam<Real>("r_curv", "Radius of curvature [m].");
  return params;
}

CoaxialElbow1Phase::CoaxialElbow1Phase(const InputParameters &params)
    : VolumeJunction1Phase(params), _r_curv(getParam<Real>("r_curv")) {}