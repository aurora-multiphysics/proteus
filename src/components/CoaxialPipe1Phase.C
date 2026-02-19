#include "CoaxialPipe1Phase.h"
#include "Component1D.h"
#include "FEProblemBase.h"
#include "Factory.h"
#include "FlowModel.h"
#include "IdealGasFluidProperties.h"
#include "InputParameters.h"
#include "MooseEnum.h"
#include "MooseError.h"
#include "MooseTypes.h"
#include "Registry.h"
#include "SinglePhaseFluidProperties.h"
#include "THMProblem.h"
#include "libmesh/libmesh_common.h"
#include <memory>
#include <numeric>
#include <string>

registerMooseObject("ProteusApp", CoaxialPipe1Phase);

InputParameters CoaxialPipe1Phase::validParams() {
  // add basic parameters such n_elems, position, etc.
  InputParameters params = Component1D::validParams();

  params.addClassDescription(
      "A 1D single-phase coaxial pipe. `inner' refers to the inner fluid pipe, "
      "`tube' indicates the solid annulus between the inner and outer flow "
      "channels, `outer' refers to the annular flow channel outside of the "
      "tube, `shell' indicates the solid annulus on the outside of the outer "
      "flow annulus. The boundary condition on the outside of the "
      "`shell' should be specified using a `HSBoundary*' component.");

  // add parameters for the inner pipe
  params.addParam<UserObjectName>("inner_fp", "Fluid property for inner pipe.");
  params.addParam<std::vector<std::string>>("inner_closures",
                                            "Fluid property for inner pipe.");
  params.addParam<FunctionName>("inner_initial_T",
                                "Initial inner pipe temperature.");
  params.addParam<FunctionName>("inner_initial_p",
                                "Initial inner pipe pressure.");
  params.addParam<FunctionName>("inner_initial_vel",
                                "Initial inner pipe velocity.");
  params.addParam<FunctionName>("inner_f", "Friction factor for inner tube.");
  params.addParamNamesToGroup(
      "inner_fp inner_closures inner_initial_T inner_initial_p "
      "inner_initial_vel inner_f",
      "inner");

  // add parameters for the outer annulus
  params.addParam<UserObjectName>("outer_fp",
                                  "Fluid property for outer annulus.");
  params.addParam<std::vector<std::string>>(
      "outer_closures", "Fluid property for outer annulus.");
  params.addParam<FunctionName>("outer_initial_T",
                                "Initial outer annulus temperature.");
  params.addParam<FunctionName>("outer_initial_p",
                                "Initial outer annulus pressure.");
  params.addParam<FunctionName>("outer_initial_vel",
                                "Initial outer annulus velocity.");
  params.addParam<FunctionName>("outer_f",
                                "Friction factor for outer annulus.");
  params.addParamNamesToGroup(
      "outer_fp outer_closures outer_initial_T outer_initial_p "
      "outer_initial_vel outer_f",
      "outer");

  // Add parameters for the solid tube
  params.addRequiredParam<std::vector<std::string>>(
      "tube_names", "Name of radial parts of solid tube.");
  params.addRequiredParam<std::vector<Real>>(
      "tube_widths", "Name of radial parts of solid tube.");
  params.addRequiredParam<std::vector<UserObjectName>>(
      "tube_materials", "Name of radial parts of solid tube.");
  params.addRequiredParam<std::vector<unsigned int>>(
      "tube_n_elems", "Name of radial parts of solid tube.");
  params.addRequiredParam<std::vector<Real>>(
      "tube_T_ref", "Reference temperature for tube materials.");
  params.addParam<FunctionName>("tube_initial_T", "Initial tube temperature.");
  params.addRequiredParam<Real>("tube_inner_radius", "inner radius of tube");
  params.addParamNamesToGroup(
      "tube_names tube_widths tube_materials tube_n_elems tube_T_ref "
      "tube_initial_T tube_inner_radius",
      "tube");

  // Add parameters for the solid shell
  params.addRequiredParam<std::vector<std::string>>(
      "shell_names", "Name of radial parts of solid tube.");
  params.addRequiredParam<std::vector<Real>>(
      "shell_widths", "widths of radial parts of solid tube.");
  params.addRequiredParam<std::vector<UserObjectName>>(
      "shell_materials", "Materials in radial parts of solid tube.");
  params.addRequiredParam<std::vector<unsigned int>>(
      "shell_n_elems", "Number of radial elements in each part of solid tube.");
  params.addRequiredParam<std::vector<Real>>(
      "shell_T_ref", "Reference temperature for shell materials.");
  params.addParam<FunctionName>("shell_initial_T",
                                "Initial shell temperature.");
  params.addRequiredParam<Real>("shell_inner_radius", "inner radius of shell");
  params.addParamNamesToGroup(
      "shell_names shell_widths shell_materials shell_n_elems shell_T_ref "
      "shell_initial_T shell_inner_radius",
      "shell");

  // heat transfer coefficients
  params.addParam<FunctionName>(
      "inner_tube_Hw", "Manually specified HTC for inner pipe to tube.");
  params.addParam<FunctionName>(
      "outer_tube_Hw", "Manually specified HTC for annular pipe to tube.");
  params.addParam<FunctionName>(
      "outer_shell_Hw", "Manually specified HTC for annular pipe to shell.");

  // Parameters for ambient convection
  params.addParam<bool>("use_ambient_convection", false,
                        "Whether to apply ambient convection to the external "
                        "surface of the shell");
  params.addParam<Real>("T_ambient", 298, "Ambient temperature [K].");
  params.addParam<Real>("p_ambient", 101325, "Ambient pressure [Pa].");

  MooseEnum ambient_properties("air", "air");
  params.addParam<MooseEnum>("ambient_properties", ambient_properties,
                             "Ambient fluid properties");

  // Add global parameter options
  params.addParam<UserObjectName>(
      "fp", "Global fluid properties. Overriden by inner_fp and outer_fp.");
  params.addParam<std::vector<std::string>>(
      "closures",
      "Global fluid closures. Overriden by inner_closure and outer_closure.");
  params.addParam<FunctionName>("initial_T",
                                "Global temperature initialisation");
  params.addParam<FunctionName>("initial_p", "Global pressure initialisation");
  params.addParam<FunctionName>("initial_vel",
                                "Global velocity initialisation");
  params.addParam<RealVectorValue>(
      "gravity_vector", RealVectorValue{0, 0, 9.81}, "gravity vector.");
  params.addParam<FunctionName>("f", "Global friction factor");
  params.addParamNamesToGroup(
      "fp closures initial_T initial_p initial_vel gravity_vector f", "global");

  return params;
}

CoaxialPipe1Phase::CoaxialPipe1Phase(const InputParameters &params)
    : Coaxial1PhaseBase(params) {
  // Add components
  AddInnerPipe(params);
  AddOuterAnnulus(params);
  AddSolidTube(params);
  AddSolidShell(params);

  // Add connections between fluid and solid
  AddHeatTransferConnection("inner", "tube", "INNER",
                            params.get<Real>("tube_inner_radius"));

  auto tube_widths = params.get<std::vector<Real>>("tube_widths");
  Real outer_radius =
      params.get<Real>("tube_inner_radius") +
      std::accumulate(tube_widths.begin(), tube_widths.end(), 0.);
  AddHeatTransferConnection("outer", "tube", "OUTER", outer_radius);
  AddHeatTransferConnection("outer", "shell", "INNER",
                            params.get<Real>("shell_inner_radius"));

  if (getParam<bool>("use_ambient_convection")) {
    AddAmbientConvection(getParam<Real>("T_ambient"),
                         getParam<Real>("p_ambient"),
                         getParam<MooseEnum>("ambient_properties"));
  }
}

void CoaxialPipe1Phase::AddInnerPipe(const InputParameters &params) {
  const std::string class_name = "FlowChannel1Phase";
  auto pipe_params = _factory.getValidParams(class_name);
  pipe_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  CopyParamFromParamWithGlobal<UserObjectName>("fp", "inner_fp", "fp",
                                               pipe_params);

  CopyParamFromParamWithGlobal<std::vector<std::string>>(
      "closures", "inner_closures", "closures", pipe_params);

  pipe_params.set<std::vector<unsigned int>>("n_elems") =
      params.get<std::vector<unsigned int>>("n_elems");
  pipe_params.set<Point>("position") = params.get<Point>("position");
  pipe_params.set<RealVectorValue>("orientation") =
      params.get<RealVectorValue>("orientation");
  pipe_params.set<std::vector<Real>>("length") =
      params.get<std::vector<Real>>("length");
  pipe_params.set<std::vector<std::string>>("axial_region_names") =
      params.get<std::vector<std::string>>("axial_region_names");
  pipe_params.set<RealVectorValue>("gravity_vector") =
      params.get<RealVectorValue>("gravity_vector");

  Real radius = params.get<Real>("tube_inner_radius");

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

  getTHMProblem().addComponent(class_name, name() + "/inner", pipe_params);
}

void CoaxialPipe1Phase::AddOuterAnnulus(const InputParameters &params) {
  const std::string class_name = "FlowChannel1Phase";
  auto pipe_params = _factory.getValidParams(class_name);
  pipe_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  CopyParamFromParamWithGlobal<UserObjectName>("fp", "outer_fp", "fp",
                                               pipe_params);

  CopyParamFromParamWithGlobal<std::vector<std::string>>(
      "closures", "outer_closures", "closures", pipe_params);

  pipe_params.set<std::vector<unsigned int>>("n_elems") =
      params.get<std::vector<unsigned int>>("n_elems");
  pipe_params.set<Point>("position") = params.get<Point>("position");
  pipe_params.set<RealVectorValue>("orientation") =
      params.get<RealVectorValue>("orientation");
  pipe_params.set<std::vector<Real>>("length") =
      params.get<std::vector<Real>>("length");
  pipe_params.set<std::vector<std::string>>("axial_region_names") =
      params.get<std::vector<std::string>>("axial_region_names");
  pipe_params.set<RealVectorValue>("gravity_vector") =
      params.get<RealVectorValue>("gravity_vector");

  Real tube_radius = params.get<Real>("tube_inner_radius");
  auto tube_widths = params.get<std::vector<Real>>("tube_widths");
  Real inner_radius =
      tube_radius + std::accumulate(tube_widths.begin(), tube_widths.end(), 0.);
  Real outer_radius = params.get<Real>("shell_inner_radius");

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

  getTHMProblem().addComponent(class_name, name() + "/outer", pipe_params);
}

void CoaxialPipe1Phase::AddSolidTube(const InputParameters &params) {
  const std::string class_name = "HeatStructureCylindrical";
  auto tube_params = _factory.getValidParams(class_name);
  tube_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  tube_params.set<std::vector<std::string>>("names") =
      params.get<std::vector<std::string>>("tube_names");
  tube_params.set<std::vector<Real>>("widths") =
      params.get<std::vector<Real>>("tube_widths");
  tube_params.set<std::vector<UserObjectName>>("solid_properties") =
      params.get<std::vector<UserObjectName>>("tube_materials");
  tube_params.set<std::vector<unsigned int>>("n_part_elems") =
      params.get<std::vector<unsigned int>>("tube_n_elems");
  tube_params.set<std::vector<Real>>("solid_properties_T_ref") =
      params.get<std::vector<Real>>("tube_T_ref");

  tube_params.set<Real>("inner_radius") = params.get<Real>("tube_inner_radius");

  tube_params.set<std::vector<unsigned int>>("n_elems") =
      params.get<std::vector<unsigned int>>("n_elems");
  tube_params.set<Point>("position") = params.get<Point>("position");
  tube_params.set<RealVectorValue>("orientation") =
      params.get<RealVectorValue>("orientation");
  tube_params.set<std::vector<Real>>("length") =
      params.get<std::vector<Real>>("length");
  tube_params.set<std::vector<std::string>>("axial_region_names") =
      params.get<std::vector<std::string>>("axial_region_names");

  CopyParamFromParamWithGlobal<FunctionName>("initial_T", "tube_initial_T",
                                             "initial_T", tube_params);

  getTHMProblem().addComponent(class_name, name() + "/tube", tube_params);
}

void CoaxialPipe1Phase::AddSolidShell(const InputParameters &params) {
  const std::string class_name = "HeatStructureCylindrical";
  auto tube_params = _factory.getValidParams(class_name);
  tube_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  tube_params.set<std::vector<std::string>>("names") =
      params.get<std::vector<std::string>>("shell_names");
  tube_params.set<std::vector<Real>>("widths") =
      params.get<std::vector<Real>>("shell_widths");
  tube_params.set<std::vector<UserObjectName>>("solid_properties") =
      params.get<std::vector<UserObjectName>>("shell_materials");
  tube_params.set<std::vector<unsigned int>>("n_part_elems") =
      params.get<std::vector<unsigned int>>("shell_n_elems");
  tube_params.set<std::vector<Real>>("solid_properties_T_ref") =
      params.get<std::vector<Real>>("shell_T_ref");

  tube_params.set<Real>("inner_radius") =
      params.get<Real>("shell_inner_radius");

  tube_params.set<std::vector<unsigned int>>("n_elems") =
      params.get<std::vector<unsigned int>>("n_elems");
  tube_params.set<Point>("position") = params.get<Point>("position");
  tube_params.set<RealVectorValue>("orientation") =
      params.get<RealVectorValue>("orientation");
  tube_params.set<std::vector<Real>>("length") =
      params.get<std::vector<Real>>("length");
  tube_params.set<std::vector<std::string>>("axial_region_names") =
      params.get<std::vector<std::string>>("axial_region_names");

  CopyParamFromParamWithGlobal<FunctionName>("initial_T", "shell_initial_T",
                                             "initial_T", tube_params);

  getTHMProblem().addComponent(class_name, name() + "/shell", tube_params);
}

void CoaxialPipe1Phase::AddHeatTransferConnection(
    const std::string &flow_channel, const std::string &hs,
    const std::string &hs_side, const Real radius) {
  const std::string class_name = "HeatTransferFromHeatStructure1Phase";
  auto ht_params = _factory.getValidParams(class_name);
  ht_params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  ht_params.set<std::string>("flow_channel") = name() + "/" + flow_channel;
  ht_params.set<std::string>("hs") = name() + "/" + hs;
  ht_params.set<MooseEnum>("hs_side") = hs_side;

  ht_params.set<FunctionName>("P_hf") = CreateFunctionFromValue(
      flow_channel + "_" + hs + "_p_hf", 2. * pi * radius);

  std::string hw_param_key{flow_channel + "_" + hs + "_Hw"};
  if (parameters().isParamSetByUser(hw_param_key))
    ht_params.set<FunctionName>("Hw") =
        parameters().get<FunctionName>(hw_param_key);

  getTHMProblem().addComponent(
      class_name, name() + "_" + flow_channel + "_" + hs, ht_params);
}

void CoaxialPipe1Phase::AddAmbientConvection(const Real T_ambient,
                                             const Real p_ambient,
                                             MooseEnum ambient_properties) {

  std::unique_ptr<SinglePhaseFluidProperties> fluid_props;
  if (ambient_properties == "air") {
    const std::string class_name = "IdealGasFluidProperties";
    auto params = _factory.getValidParams(class_name);

    fluid_props = std::make_unique<IdealGasFluidProperties>(params);
  }

  const Real mu = fluid_props->mu_from_p_T(p_ambient, T_ambient);
  const Real cp = fluid_props->cp_from_p_T(p_ambient, T_ambient);
  const Real k = fluid_props->k_from_p_T(p_ambient, T_ambient);

  auto widths = getParam<std::vector<Real>>("shell_widths");
  const Real Dshell = std::accumulate(widths.begin(), widths.end(), 0.) +
                      getParam<Real>("shell_inner_radius");

  // Create Rayleigh number property
  {
    const std::string class_name = "ADParsedMaterial";
    auto params = _factory.getValidParams(class_name);
    params.set<std::string>("property_name") = "Ra";
    params.set<std::string>("expression") =
        "abs(rho*beta*(Th-Ta)*D*D*D*g)/(mu*k/(rho*cp))";
    params.set<std::vector<std::string>>("functor_symbols") = {"rho", "beta"
                                                                      "mu"
                                                                      "k"
                                                                      "cp"};

    Real rho, drho_dt, drho_dp;
    fluid_props->rho_from_p_T(p_ambient, T_ambient, rho, drho_dt, drho_dp);
    const Real beta = -drho_dt / rho;

    std::vector<MooseFunctorName> functor_names{
        CreateFunctionFromValue("rho_conv", rho),
        CreateFunctionFromValue("beta_conv", beta),
        CreateFunctionFromValue("mu_conv", mu),
        CreateFunctionFromValue("k_conv", k),
        CreateFunctionFromValue("cp_conv", cp),
        "T_solid"};

    params.set<std::vector<MooseFunctorName>>("functor_names") = functor_names;
    params.set<std::vector<std::string>>("constant_names") = {"T_a", "D", "g"};

    params.set<std::vector<std::string>>("constant_expressions") = {
        std::to_string(T_ambient), std::to_string(Dshell), "-9.81"};

    params.set<std::vector<std::string>>("boundary") = {name() +
                                                        "/shell:outer"};
    getTHMProblem().addMaterial(class_name, name() + "/Ra_conv", params);
  }

  // Nusselt number
  {
    const std::string class_name = "ADParsedMaterial";
    auto params = _factory.getValidParams(class_name);
    params.set<std::string>("property_name") = "Nu";

    params.set<std::string>("expression") =
        "pow(0.6 + (0.387*pow(Ra,1./6.))/pow(1 + pow(0.559/Pr,9./16.),8/27), "
        "2)";

    params.set<std::vector<std::string>>("constant_names") = {"Pr"};
    params.set<std::vector<std::string>>("constant_expressions") = {
        std::to_string(mu * cp / k)};
    params.set<std::vector<std::string>>("material_property_names") = {"Ra"};
    params.set<std::vector<std::string>>("boundary") = {name() +
                                                        "/shell:outer"};
    getTHMProblem().addMaterial(class_name, name() + "/Nu_conv", params);
  }

  // HTC
  {
    const std::string class_name = "ADParsedMaterial";
    auto params = _factory.getValidParams(class_name);
    params.set<std::string>("property_name") = "Hw";
    params.set<std::vector<std::string>>("boundary") = {name() +
                                                        "/shell:outer"};

    params.set<std::string>("expression") = "Nu*k/L";
    params.set<std::vector<std::string>>("constant_names") = {"k", "L"};
    params.set<std::vector<std::string>>("constant_expressions") = {
        std::to_string(k), std::to_string(Dshell)};
    params.set<std::vector<std::string>>("material_property_names") = {"Nu"};
    getTHMProblem().addMaterial(class_name, name() + "/Hw_conv", params);
  }

  // Ambient convection
  {
    const std::string class_name = "HSBoundaryAmbientConvection";
    auto params = _factory.getValidParams(class_name);

    params.set<MooseFunctorName>("T_ambient") =
        CreateFunctionFromValue("T_ambient", T_ambient);
    params.set<std::vector<std::string>>("boundary") = {name() +
                                                        "/shell:outer"};
    params.set<std::string>("boundary") = {name() + "/shell"};
    params.set<MooseFunctorName>("htc_ambient") = "Hw";

    getTHMProblem().addComponent(class_name, name() + "/conv_ambient", params);
  }
}

FunctionName
CoaxialPipe1Phase::CreateFunctionFromValue(const std::string &suffix,
                                           const Real value) {
  auto func_params = _factory.getValidParams("ConstantFunction");
  func_params.set<Real>("value") = value;

  auto func_name = name() + "_" + suffix;
  getTHMProblem().addFunction("ConstantFunction", func_name, func_params);
  return func_name;
}
