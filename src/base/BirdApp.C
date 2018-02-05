#include "BirdApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

#include "InterfaceForce_ld.h"
#include "InterfaceForce_lp.h"
#include "InterfaceForce_sp.h"
#include "Precipitation.h"
#include "Precipitation_liquid.h"
#include "PorousReaction_ld_sd.h"
#include "PorousReaction_ld_sp.h"
#include "PorousReaction_sd_lp.h"

template <>
InputParameters
validParams<BirdApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

BirdApp::BirdApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  BirdApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  BirdApp::associateSyntax(_syntax, _action_factory);
}

BirdApp::~BirdApp() {}

// External entry point for dynamic application loading
extern "C" void
BirdApp__registerApps()
{
  BirdApp::registerApps();
}
void
BirdApp::registerApps()
{
  registerApp(BirdApp);
}

void
BirdApp::registerObjectDepends(Factory & /*factory*/)
{
}

// External entry point for dynamic object registration
extern "C" void
BirdApp__registerObjects(Factory & factory)
{
  BirdApp::registerObjects(factory);
}
void
BirdApp::registerObjects(Factory & factory)
{


 registerKernel(InterfaceForce_ld); // <- registration
 registerKernel(InterfaceForce_lp);
 registerKernel(InterfaceForce_sp);
 registerKernel(Precipitation);
 registerKernel(Precipitation_liquid);
 registerKernel(PorousReaction_ld_sd);
 registerKernel(PorousReaction_ld_sp);
 registerKernel(PorousReaction_sd_lp);
}

void
BirdApp::associateSyntaxDepends(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
}

// External entry point for dynamic syntax association
extern "C" void
BirdApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  BirdApp::associateSyntax(syntax, action_factory);
}
void
BirdApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
}
