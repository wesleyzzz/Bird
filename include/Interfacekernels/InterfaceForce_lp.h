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

#ifndef INTERFACEFORCE_LP_H
#define INTERFACEFORCE_LP_H

#include "InterfaceKernel.h"
#include "PostprocessorInterface.h"
#include "VectorPostprocessorInterface.h"

class InterfaceForce_lp;

template<>
InputParameters validParams<InterfaceForce_lp>();

class InterfaceForce_lp :
  public InterfaceKernel,
  public PostprocessorInterface,
  protected VectorPostprocessorInterface
{
public:
  InterfaceForce_lp(const InputParameters & parameters);
  virtual const PostprocessorValue & getPostprocessorValue(const std::string & name);
  virtual const PostprocessorValue & getPostprocessorValueByName(const PostprocessorName & name);


protected:
  virtual Real computeQpResidual(Moose::DGResidualType type);
  virtual Real computeQpJacobian(Moose::DGJacobianType type);

  /// Depend UserObjects
  std::set<std::string> _depend_uo;
  const Real _unit_scalor;
  const Real _stop_threshold;
  const MaterialProperty<Real> & _driving_rate;
  const VariableValue & _coupled_s_p;
  // const Real _driving_rate;
  // const MaterialProperty<Real> & _a_0;
  // const Real _a_0;
  const MaterialProperty<Real> & _solubility_in_solid;
  const MaterialProperty<Real> & _diffusivity_in_solid_sd;
  const MaterialProperty<Real> & _diffusivity_in_solid_lp;
  // const Real & _Ave_s_d;
  // const Real & _Ave_l_p;
};

#endif
