#ifndef BIRDTESTAPP_H
#define BIRDTESTAPP_H

#include "MooseApp.h"

class BirdTestApp;

template <>
InputParameters validParams<BirdTestApp>();

class BirdTestApp : public MooseApp
{
public:
  BirdTestApp(InputParameters parameters);
  virtual ~BirdTestApp();

  static void registerApps();
  static void registerObjects(Factory & factory);
  static void associateSyntax(Syntax & syntax, ActionFactory & action_factory);
};

#endif /* BIRDTESTAPP_H */
