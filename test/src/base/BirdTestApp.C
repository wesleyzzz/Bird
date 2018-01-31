#include "BirdTestApp.h"
#include "BirdApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

template <>
InputParameters
validParams<BirdTestApp>()
{
  InputParameters params = validParams<BirdApp>();
  return params;
}

BirdTestApp::BirdTestApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  BirdApp::registerObjectDepends(_factory);
  BirdApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  BirdApp::associateSyntaxDepends(_syntax, _action_factory);
  BirdApp::associateSyntax(_syntax, _action_factory);

  bool use_test_objs = getParam<bool>("allow_test_objects");
  if (use_test_objs)
  {
    BirdTestApp::registerObjects(_factory);
    BirdTestApp::associateSyntax(_syntax, _action_factory);
  }
}

BirdTestApp::~BirdTestApp() {}

// External entry point for dynamic application loading
extern "C" void
BirdTestApp__registerApps()
{
  BirdTestApp::registerApps();
}
void
BirdTestApp::registerApps()
{
  registerApp(BirdApp);
  registerApp(BirdTestApp);
}

// External entry point for dynamic object registration
extern "C" void
BirdTestApp__registerObjects(Factory & factory)
{
  BirdTestApp::registerObjects(factory);
}
void
BirdTestApp::registerObjects(Factory & /*factory*/)
{
}

// External entry point for dynamic syntax association
extern "C" void
BirdTestApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  BirdTestApp::associateSyntax(syntax, action_factory);
}
void
BirdTestApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
}
