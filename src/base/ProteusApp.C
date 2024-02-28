#include "ProteusApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
ProteusApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

ProteusApp::ProteusApp(InputParameters parameters) : MooseApp(parameters)
{
  ProteusApp::registerAll(_factory, _action_factory, _syntax);
}

ProteusApp::~ProteusApp() {}

void
ProteusApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<ProteusApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"ProteusApp"});
  Registry::registerActionsTo(af, {"ProteusApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
ProteusApp::registerApps()
{
  registerApp(ProteusApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
ProteusApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ProteusApp::registerAll(f, af, s);
}
extern "C" void
ProteusApp__registerApps()
{
  ProteusApp::registerApps();
}
