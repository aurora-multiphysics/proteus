#include "CoaxialElbow1Phase.h"
#include "CoaxialPipe1Phase.h"
#include "InputParameters.h"
#include "Registry.h"
#include <cmath>
#include <cstdio>

registerMooseObject("ProteusApp", CoaxialElbow1Phase);

namespace {
// Compute momentum loss per unit length using Handbook of Hydraulic Resistance
// p. 195
Real getElbowKPrime(const Real &R_c, const Real &D_h) {
  const Real length = 0.5 * pi * R_c;
  Real k;
  if (R_c / D_h > 1.)
    k = 0.21 / sqrt(R_c / D_h);
  else
    k = 0.21 / pow(R_c / D_h, 2.5);

  return k / length;
}
} // namespace

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

  // Momentum losses provided by minor loss formula
  params.suppressParameter<std::vector<std::string>>("inner_closures");
  params.suppressParameter<std::vector<std::string>>("outer_closures");
  params.suppressParameter<std::vector<std::string>>("closures");
  // f set to zero
  params.suppressParameter<FunctionName>("inner_f");
  params.suppressParameter<FunctionName>("outer_f");
  params.suppressParameter<FunctionName>("f");

  params.addClassDescription("Bent pipe for 1-phase coaxial flow");

  return params;
}

CoaxialElbow1Phase::CoaxialElbow1Phase(const InputParameters &params)
    : Coaxial1PhaseBase(params) {

  auto start_angle = getParam<Real>("start_angle");
  auto end_angle = getParam<Real>("end_angle");

  // This component is for 90 degree bends
  if (!MooseUtils::relativeFuzzyEqual(abs(start_angle - end_angle), 90.))
    mooseError("Difference between start and end angles should be 90 degrees.");

  // Closure has been removed as a parameter to be specified but we must specify
  // it
  auto closure_params = _factory.getValidParams("Closures1PhaseSimple");
  closure_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();
  closure_params.set<Logger *>("_logger") = &(getTHMProblem().log());
  getTHMProblem().addClosures("Closures1PhaseSimple", name() + "_closure",
                              closure_params);

  AddElbowInner();
  AddElbowOuter();
}

void CoaxialElbow1Phase::AddElbowInner() {

  const std::string component_name = name() + "/inner";
  Real radius = getParam<Real>("tube_inner_radius");
  const Real d_h = 2 * radius;

  // Add elbow geometry for inner pipe and pipe information
  {
    const std::string class_name = "ElbowPipe1Phase";
    auto pipe_params = _factory.getValidParams(class_name);
    pipe_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

    CopyParamFromParamWithGlobal<UserObjectName>("fp", "inner_fp", "fp",
                                                 pipe_params);

    pipe_params.set<std::vector<std::string>>("closures") = {name() +
                                                             "_closure"};
    pipe_params.set<FunctionName>("f") = CreateFunctionFromValue("inner_f", 0.);

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

  // Add form loss from Handbook of Hydraulic Resistance p. 195
  {
    const std::string class_name = "FormLossFromFunction1Phase";
    auto loss_params = _factory.getValidParams(class_name);
    loss_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();
    loss_params.set<std::string>("flow_channel") = component_name;

    const Real r_c = getParam<Real>("radius");

    loss_params.set<FunctionName>("K_prime") =
        CreateFunctionFromValue("inner_k_prime", getElbowKPrime(r_c, d_h));

    getTHMProblem().addComponent(class_name, component_name + "_loss",
                                 loss_params);
  }
}

void CoaxialElbow1Phase::AddElbowOuter() {

  Real tube_radius = getParam<Real>("tube_inner_radius");
  auto tube_widths = getParam<std::vector<Real>>("tube_widths");
  Real inner_radius =
      tube_radius + std::accumulate(tube_widths.begin(), tube_widths.end(), 0.);
  Real outer_radius = getParam<Real>("shell_inner_radius");
  const Real d_h = 2 * (outer_radius - inner_radius);

  // Add elbow geometry for outer annulus
  const std::string component_name = name() + "/outer";
  {
    const std::string class_name = "ElbowPipe1Phase";
    auto pipe_params = _factory.getValidParams(class_name);
    pipe_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

    CopyParamFromParamWithGlobal<UserObjectName>("fp", "outer_fp", "fp",
                                                 pipe_params);

    pipe_params.set<std::vector<std::string>>("closures") = {name() +
                                                             "_closure"};
    pipe_params.set<FunctionName>("f") = CreateFunctionFromValue("outer_f", 0.);

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
    loss_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();
    loss_params.set<std::string>("flow_channel") = component_name;

    auto r_c = getParam<Real>("radius");

    loss_params.set<FunctionName>("K_prime") =
        CreateFunctionFromValue("outer_k_prime", getElbowKPrime(r_c, d_h));

    getTHMProblem().addComponent(class_name, component_name + "_loss",
                                 loss_params);
  }
}
