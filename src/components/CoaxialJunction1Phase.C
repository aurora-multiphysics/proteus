#include "CoaxialJunction1Phase.h"
#include "Component.h"
#include "InputParameters.h"
#include "MooseTypes.h"
#include "Registry.h"

registerMooseObject("ProteusApp", CoaxialJunction1Phase);

namespace {
// Splits component name into component and boundary pair and checks validity
inline std::pair<std::string, std::string>
getComponentAndBoundary(const ComponentName &component) {
  auto it = component.rfind(":");
  if (it == component.size())
    mooseError("No boundary specified. 'coaxial_connections' must be specified "
               "as <coaxial>:<boundary>.");

  auto comp = component.substr(0, it);
  auto boundary = component.substr(it + 1);

  if (!(boundary == "in" || boundary == "out"))
    mooseError("Boundary must be 'in' or 'out', not '", boundary, "'.");

  return {comp, boundary};
}
} // namespace

InputParameters CoaxialJunction1Phase::validParams() {
  auto params = Component::validParams();
  params.addRequiredParam<std::vector<ComponentName>>(
      "coaxial_connections", "Coaxial pipes boundaries to connect. "
                             "<name>:in indicates start of the pipe, "
                             "<name>:out indicates the end of the pipe.");

  // Passed to 2D coupler
  params.addRequiredParam<FunctionName>("tube_htc",
                                        "HTC used for coupling tube regions.");
  params.addRequiredParam<FunctionName>("shell_htc",
                                        "HTC used for coupling shell regions.");

  // Allows other componenets such as pumps to be inserted instead
  params.addParam<bool>("connect_inner", true,
                        "Whether to connect inner pipe.");
  params.addParam<bool>("connect_outer", true,
                        "Whether to connect the outer annulus.");

  return params;
}

CoaxialJunction1Phase::CoaxialJunction1Phase(const InputParameters &params)
    : Component(params) {

  auto coaxials = params.get<std::vector<ComponentName>>("coaxial_connections");

  if (coaxials.size() != 2)
    mooseError("'coaxial_connections' must have size 2.");

  ConnectSolidRegion("tube", coaxials[0], coaxials[1]);
  ConnectSolidRegion("shell", coaxials[0], coaxials[1]);

  if (params.get<bool>("connect_inner")) {
    ConnectFlowRegion("inner", coaxials[0], coaxials[1]);
  }
  if (params.get<bool>("connect_outer")) {
    ConnectFlowRegion("outer", coaxials[0], coaxials[1]);
  }
}

void CoaxialJunction1Phase::ConnectSolidRegion(
    const std::string &region_name, const ComponentName &component1,
    const ComponentName &component2) {
  auto comp_boundary1 = getComponentAndBoundary(component1);
  auto comp_boundary2 = getComponentAndBoundary(component2);

  const std::string class_name = "HeatStructure2DCoupler";
  auto params = _factory.getValidParams(class_name);
  params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  // The ends of the solid regions are called start and end rather than in and
  // out
  auto boundary1 = (comp_boundary1.second == "in") ? "start" : "end";
  auto boundary2 = (comp_boundary2.second == "in") ? "start" : "end";

  params.set<std::string>("primary_heat_structure") =
      comp_boundary1.first + "/" + region_name;
  params.set<BoundaryName>("primary_boundary") =
      comp_boundary1.first + "/" + region_name + ":" + boundary1;

  params.set<std::string>("secondary_heat_structure") =
      comp_boundary2.first + "/" + region_name;
  params.set<BoundaryName>("secondary_boundary") =
      comp_boundary2.first + "/" + region_name + ":" + boundary2;

  params.set<FunctionName>("heat_transfer_coefficient") =
      parameters().get<FunctionName>(region_name + "_htc");

  getTHMProblem().addComponent(class_name,
                               name() + "/" + region_name + "_coupler", params);
}

void CoaxialJunction1Phase::ConnectFlowRegion(const std::string &region_name,
                                              const ComponentName &component1,
                                              const ComponentName &component2) {
  auto comp_boundary1 = getComponentAndBoundary(component1);
  auto comp_boundary2 = getComponentAndBoundary(component2);

  // In the future, we could create a component to account for form
  // loss due to geometry changes
  const std::string class_name = "JunctionOneToOne1Phase";
  auto params = _factory.getValidParams(class_name);
  params.set<THMProblem *>("_thm_problem") = &getTHMProblem();

  std::vector<BoundaryName> connections = {
      comp_boundary1.first + "/" + region_name + ":" + comp_boundary1.second,
      comp_boundary2.first + "/" + region_name + ":" + comp_boundary2.second,
  };
  params.set<std::vector<BoundaryName>>("connections") = connections;

  getTHMProblem().addComponent(
      class_name, name() + "/" + region_name + "_junction", params);
}
