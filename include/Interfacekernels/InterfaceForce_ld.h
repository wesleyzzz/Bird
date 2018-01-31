/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef INTERFACEFORCE_LD_H
#define INTERFACEFORCE_LD_H

#include "InterfaceKernel.h"
#include "PostprocessorInterface.h"
#include "VectorPostprocessorInterface.h"

class InterfaceForce_ld;

template<>
InputParameters validParams<InterfaceForce_ld>();

class InterfaceForce_ld :
  public InterfaceKernel,
  public PostprocessorInterface,
  protected VectorPostprocessorInterface
{
public:
  InterfaceForce_ld(const InputParameters & parameters);
  virtual const PostprocessorValue & getPostprocessorValue(const std::string & name);
  virtual const PostprocessorValue & getPostprocessorValueByName(const PostprocessorName & name);


protected:
  virtual Real computeQpResidual(Moose::DGResidualType type);
  virtual Real computeQpJacobian(Moose::DGJacobianType type);

  /// Depend UserObjects
  std::set<std::string> _depend_uo;
  const Real _unit_scalor;
  const MaterialProperty<Real> & _driving_rate;
  const VariableValue & _coupled_l_p;
  const VariableValue & _coupled_s_p;
  // const Real _driving_rate;
  // const Real _a_0;
  // const MaterialProperty<Real> & _a_0;
  const MaterialProperty<Real> & _solubility_in_liquid;
  const MaterialProperty<Real> & _solubility_in_solid;
  // const Real _solubility_in_liquid;
  // const Real _solubility_in_solid;
  const MaterialProperty<Real> & _diffusivity_in_liquid;
  const MaterialProperty<Real> & _diffusivity_in_solid;
  // const Real & _Ave_s_d;
  // const Real & _Ave_l_d;
  // const Real & _Ave_l_p;
};

#endif
