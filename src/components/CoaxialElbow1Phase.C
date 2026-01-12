#include "CoaxialElbow1Phase.h"
#include "CoaxialPipe1Phase.h"
#include "InputParameters.h"

InputParameters CoaxialElbow1Phase::validParams() {

  InputParameters params = CoaxialPipe1Phase::validParams();
  params.addRequiredParam<Real>("radius", "Radius of the pipe [m]");
  params.addRequiredParam<Real>("start_angle",
                                "Angle at which the pipe starts [degrees]");
  params.addRequiredParam<Real>("end_angle",
                                "Angle at which the pipe ends [degrees]");

  // Suppress length. Also need to set it to something, because it is required
  // in the parent class
  params.set<std::vector<Real>>("length") = {0.0};
  params.suppressParameter<std::vector<Real>>("length");

  params.addClassDescription("Bent pipe for 1-phase coaxial flow");

  return params;
}

CoaxialElbow1Phase::CoaxialElbow1Phase(const InputParameters &params)
    : Coaxial1PhaseBase(params) {
  AddElbowInner();
  AddElbowOuter();
}

void CoaxialElbow1Phase::AddElbowInner() {
  const std::string class_name = "ElbowPipe1Phase";

  auto pipe_params = _factory.getValidParams(class_name);
  pipe_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  CopyParamFromParamWithGlobal<UserObjectName>("fp", "inner_fp", "fp",
                                               pipe_params);

  CopyParamFromParamWithGlobal<std::vector<std::string>>(
      "closures", "inner_closures", "closures", pipe_params);

  passParameter<std::vector<unsigned int>>("n_elems", pipe_params);
  passParameter<Point>("position", pipe_params);
  passParameter<RealVectorValue>("orientation", pipe_params);

  Real radius = getParam<Real>("tube_inner_radius");

  auto area = pi * radius * radius;
  pipe_params.set<FunctionName>("A") =
      CreateFunctionFromValue("inner_area", area);

  auto d_h = 2 * radius;
  pipe_params.set<FunctionName>("D_h") =
      CreateFunctionFromValue("inner_dh", d_h);

  CopyParamFromParamWithGlobal<FunctionName>("initial_T", "inner_initial_T",
                                             "initial_T", pipe_params);
  CopyParamFromParamWithGlobal<FunctionName>("initial_p", "inner_initial_p",
                                             "initial_p", pipe_params);
  CopyParamFromParamWithGlobal<FunctionName>("initial_vel", "inner_initial_vel",
                                             "initial_vel", pipe_params);

  passParameter<Real>("radius", pipe_params);
  passParameter<Real>("start_angle", pipe_params);
  passParameter<Real>("end_angle", pipe_params);

  getTHMProblem().addComponent(class_name, name() + "/inner", pipe_params);
}

void CoaxialElbow1Phase::AddElbowOuter() {
  const std::string class_name = "ElbowPipe1Phase";
  auto pipe_params = _factory.getValidParams(class_name);
  pipe_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  CopyParamFromParamWithGlobal<UserObjectName>("fp", "outer_fp", "fp",
                                               pipe_params);

  CopyParamFromParamWithGlobal<std::vector<std::string>>(
      "closures", "outer_closures", "closures", pipe_params);

  passParameter<std::vector<unsigned int>>("n_elems", pipe_params);
  passParameter<Point>("position", pipe_params);
  passParameter<RealVectorValue>("orientation", pipe_params);

  Real tube_radius = getParam<Real>("tube_inner_radius");
  auto tube_widths = getParam<std::vector<Real>>("tube_widths");
  Real inner_radius =
      tube_radius + std::accumulate(tube_widths.begin(), tube_widths.end(), 0.);
  Real outer_radius = getParam<Real>("shell_inner_radius");

  auto area = pi * (outer_radius * outer_radius - inner_radius * inner_radius);
  pipe_params.set<FunctionName>("A") =
      CreateFunctionFromValue("outer_area", area);

  auto d_h = 2 * (outer_radius - inner_radius);
  pipe_params.set<FunctionName>("D_h") =
      CreateFunctionFromValue("outer_dh", d_h);

  CopyParamFromParamWithGlobal<FunctionName>("initial_T", "outer_initial_T",
                                             "initial_T", pipe_params);
  CopyParamFromParamWithGlobal<FunctionName>("initial_p", "outer_initial_p",
                                             "initial_p", pipe_params);
  CopyParamFromParamWithGlobal<FunctionName>("initial_vel", "outer_initial_vel",
                                             "initial_vel", pipe_params);

  passParameter<Real>("radius", pipe_params);
  passParameter<Real>("start_angle", pipe_params);
  passParameter<Real>("end_angle", pipe_params);

  getTHMProblem().addComponent(class_name, name() + "/outer", pipe_params);
}
