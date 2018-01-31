#ifndef BIRDAPP_H
#define BIRDAPP_H

#include "MooseApp.h"

class BirdApp;

template <>
InputParameters validParams<BirdApp>();

class BirdApp : public MooseApp
{
public:
  BirdApp(InputParameters parameters);
  virtual ~BirdApp();

  static void registerApps();
  static void registerObjects(Factory & factory);
  static void registerObjectDepends(Factory & factory);
  static void associateSyntax(Syntax & syntax, ActionFactory & action_factory);
  static void associateSyntaxDepends(Syntax & syntax, ActionFactory & action_factory);
};

#endif /* BIRDAPP_H */
