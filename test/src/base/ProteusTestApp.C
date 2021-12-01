//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "ProteusTestApp.h"
#include "ProteusApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
ProteusTestApp::validParams()
{
  InputParameters params = ProteusApp::validParams();
  return params;
}

ProteusTestApp::ProteusTestApp(InputParameters parameters) : MooseApp(parameters)
{
  ProteusTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

ProteusTestApp::~ProteusTestApp() {}

void
ProteusTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  ProteusApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"ProteusTestApp"});
    Registry::registerActionsTo(af, {"ProteusTestApp"});
  }
}

void
ProteusTestApp::registerApps()
{
  registerApp(ProteusApp);
  registerApp(ProteusTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
ProteusTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ProteusTestApp::registerAll(f, af, s);
}
extern "C" void
ProteusTestApp__registerApps()
{
  ProteusTestApp::registerApps();
}
