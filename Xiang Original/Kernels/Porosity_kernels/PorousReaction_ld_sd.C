
#include "PorousReaction_ld_sd.h"
#include <cmath>

template<>
InputParameters validParams<PorousReaction_ld_sd>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("coupled_l_p", "Ln precipitation in liquid metal solution.");
  params.addCoupledVar("coupled_s_d", "couple Ln solute in the solid fuel.");
  params.addCoupledVar("coupled_l_d", "couple Ln solute in liquid metal solution.");
  // materials properties: solubility and diffusivity
  params.addRequiredParam<Real>("unit_scalor", "unit_scalor for the precipitate");
  params.addParam<MaterialPropertyName>("reaction_rate", 1.0, "driving force rate between the interface");
  params.addParam<MaterialPropertyName>("solubility_in_liquid", 0.0, "Name of solubility material in the liquid");
  params.addParam<MaterialPropertyName>("solubility_in_solid", 0.0, "Name of solubility material in the solid");
  params.addParam<MaterialPropertyName>("diffusivity_in_liquid", 0.0, "Name of diffusivity material in the liquid");
  params.addParam<MaterialPropertyName>("diffusivity_in_solid", 0.0, "Name of diffusivity material in the solid");

  params.addParam<MaterialPropertyName>("porosity", 0.1, "Name of porosity in porous media");
  return params;
}

PorousReaction_ld_sd::PorousReaction_ld_sd(const InputParameters & parameters) :
  Kernel(parameters),
  _coupled_l_p(coupledValue("coupled_l_p")),
  // conditional coupled variables
  _has_coupled_s_d(isCoupled("coupled_s_d")),
  _has_coupled_l_d(isCoupled("coupled_l_d")),
  _sign((_has_coupled_s_d) ? 1 : -1),
  _coupled_solute((_has_coupled_s_d) ? coupledValue("coupled_s_d") : coupledValue("coupled_l_d")),
  // Materials properties
  // _reaction_rate(getParam<Real>("reaction_rate")),
  _unit_scalor(getParam<Real>("unit_scalor")),
  _reaction_rate(getMaterialProperty<Real>(getParam<MaterialPropertyName>("reaction_rate"))),
  _solubility_in_liquid(getMaterialProperty<Real>(getParam<MaterialPropertyName>("solubility_in_liquid"))),
  _solubility_in_solid(getMaterialProperty<Real>(getParam<MaterialPropertyName>("solubility_in_solid"))),
  _diffusivity_in_liquid(getMaterialProperty<Real>(getParam<MaterialPropertyName>("diffusivity_in_liquid"))),
  _diffusivity_in_solid(getMaterialProperty<Real>(getParam<MaterialPropertyName>("diffusivity_in_solid"))),
  _porosity(getMaterialProperty<Real>(getParam<MaterialPropertyName>("porosity")))
{}

Real
PorousReaction_ld_sd::computeQpResidual()
{
  Real r = 0.0;
  Real prefactor = _sign * _diffusivity_in_solid[_qp] * _porosity[_qp];

  if (_has_coupled_s_d)
  {
    Real Force_eff = _reaction_rate[_qp] * (_coupled_solute[_qp] / _solubility_in_solid[_qp] - _u[_qp] / _solubility_in_liquid[_qp]);
    r = prefactor * Force_eff * (1.0 - _coupled_l_p[_qp] / _unit_scalor);
  }
  else if (_has_coupled_l_d)
  {
    Real Force_eff = _reaction_rate[_qp] * (_u[_qp] / _solubility_in_solid[_qp] - _coupled_solute[_qp] / _solubility_in_liquid[_qp]);
    r = prefactor * Force_eff * (1.0 - _coupled_l_p[_qp] / _unit_scalor);
  }
  else
    mooseError("Either s_d_variable or l_d_variable must be provided");

  return -_test[_i][_qp] * r;
}

Real
PorousReaction_ld_sd::computeQpJacobian()
{
  Real jac = 0.0;
  Real prefactor = _sign * _reaction_rate[_qp] * _diffusivity_in_solid[_qp] * (1.0 - _coupled_l_p[_qp] / _unit_scalor) * _porosity[_qp];

  if (_has_coupled_s_d)
  {
    jac = prefactor * (-_phi[_j][_qp] / _solubility_in_liquid[_qp]);
  }
  else if (_has_coupled_l_d)
  {
    jac = prefactor * (_phi[_j][_qp] / _solubility_in_solid[_qp]);
  }
  else
    mooseError("Either s_d_variable or l_d_variable must be provided");

  return -_test[_i][_qp] * jac;
}
