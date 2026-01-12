#include "CoaxialElbow1Phase.h"
#include "CoaxialPipe1Phase.h"
#include <cmath>

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

  auto start_angle = getParam<Real>("start_angle");
  auto end_angle = getParam<Real>("end_angle");

  if (!MooseUtils::relativeFuzzyEqual(abs(start_angle - end_angle), 90.))
    mooseError("Difference between start and end angles should be 90 degrees.");

  AddElbowInner();
  AddElbowOuter();
}

void CoaxialElbow1Phase::AddElbowInner() {

  // Create elbow geometry
  const std::string component_name = name() + "/inner";
  Real radius = getParam<Real>("tube_inner_radius");
  auto d_h = 2 * radius;

  {
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

    auto area = pi * radius * radius;
    pipe_params.set<FunctionName>("A") =
        CreateFunctionFromValue("inner_area", area);

    pipe_params.set<FunctionName>("D_h") =
        CreateFunctionFromValue("inner_dh", d_h);

    CopyParamFromParamWithGlobal<FunctionName>("initial_T", "inner_initial_T",
                                               "initial_T", pipe_params);
    CopyParamFromParamWithGlobal<FunctionName>("initial_p", "inner_initial_p",
                                               "initial_p", pipe_params);
    CopyParamFromParamWithGlobal<FunctionName>(
        "initial_vel", "inner_initial_vel", "initial_vel", pipe_params);

    passParameter<Real>("radius", pipe_params);
    passParameter<Real>("start_angle", pipe_params);
    passParameter<Real>("end_angle", pipe_params);

    getTHMProblem().addComponent(class_name, component_name, pipe_params);
  }

  // Add form loss
  {
    const std::string class_name = "FormLossFromFunction1Phase";
    auto loss_params = _factory.getValidParams(class_name);
    loss_params.set<std::string>("flow_channel") = component_name;
    Real rad_curv = getParam<Real>("radius");
    Real k_prime = (0.21 / (sqrt(rad_curv / d_h))) / (rad_curv * pi / 2);
    loss_params.set<FunctionName>("K_prime") =
        CreateFunctionFromValue("inner_loss", k_prime);
  }
}

void CoaxialElbow1Phase::AddElbowOuter() {

  Real tube_radius = getParam<Real>("tube_inner_radius");
  auto tube_widths = getParam<std::vector<Real>>("tube_widths");
  Real inner_radius =
      tube_radius + std::accumulate(tube_widths.begin(), tube_widths.end(), 0.);
  Real outer_radius = getParam<Real>("shell_inner_radius");
  auto d_h = 2 * (outer_radius - inner_radius);

  const std::string component_name = name() + "/outer";
  {
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

    auto area =
        pi * (outer_radius * outer_radius - inner_radius * inner_radius);
    pipe_params.set<FunctionName>("A") =
        CreateFunctionFromValue("outer_area", area);

    pipe_params.set<FunctionName>("D_h") =
        CreateFunctionFromValue("outer_dh", d_h);

    CopyParamFromParamWithGlobal<FunctionName>("initial_T", "outer_initial_T",
                                               "initial_T", pipe_params);
    CopyParamFromParamWithGlobal<FunctionName>("initial_p", "outer_initial_p",
                                               "initial_p", pipe_params);
    CopyParamFromParamWithGlobal<FunctionName>(
        "initial_vel", "outer_initial_vel", "initial_vel", pipe_params);

    passParameter<Real>("radius", pipe_params);
    passParameter<Real>("start_angle", pipe_params);
    passParameter<Real>("end_angle", pipe_params);

    getTHMProblem().addComponent(class_name, component_name, pipe_params);
  }

  {
    const std::string class_name = "FormLossFromFunction1Phase";
    auto loss_params = _factory.getValidParams(class_name);
    loss_params.set<std::string>("flow_channel") = component_name;
    Real rad_curv = getParam<Real>("radius");
    Real k_prime = (0.21 / (sqrt(rad_curv / d_h))) / (rad_curv * pi / 2);
    loss_params.set<FunctionName>("K_prime") =
        CreateFunctionFromValue("inner_loss", k_prime);
  }
}
