
#include "PorousReaction_ld_sp.h"
#include <cmath>

template<>
InputParameters validParams<PorousReaction_ld_sp>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredCoupledVar("coupled_l_p", "Ln precipitation in liquid metal solution.");
  params.addCoupledVar("coupled_s_p", "couple Ln solute in the solid fuel.");
  params.addCoupledVar("coupled_l_d", "couple Ln solute in liquid metal solution.");
  // materials properties: solubility and diffusivity
  params.addRequiredParam<Real>("unit_scalor", "unit_scalor for the precipitate");
  params.addParam<MaterialPropertyName>("reaction_rate", 1.0, "driving force rate between the interface");

  params.addParam<MaterialPropertyName>("porosity", 0.1, "Name of porosity in porous media");
  return params;
}

PorousReaction_ld_sp::PorousReaction_ld_sp(const InputParameters & parameters) :
  Kernel(parameters),
  _coupled_l_p(coupledValue("coupled_l_p")),
  // conditional coupled variables
  _has_coupled_s_p(isCoupled("coupled_s_p")),
  _has_coupled_l_d(isCoupled("coupled_l_d")),
  _sign((_has_coupled_s_p) ? 1 : -1),
  _coupled_variable((_has_coupled_s_p) ? coupledValue("coupled_s_p") : coupledValue("coupled_l_d")),
  // Materials properties
  // _reaction_rate(getParam<Real>("reaction_rate")),
  _unit_scalor(getParam<Real>("unit_scalor")),
  _reaction_rate(getMaterialProperty<Real>(getParam<MaterialPropertyName>("reaction_rate"))),
  _porosity(getMaterialProperty<Real>(getParam<MaterialPropertyName>("porosity")))
{}

Real
PorousReaction_ld_sp::computeQpResidual()
{
  Real r = 0.0;
  Real prefactor = _sign * _reaction_rate[_qp] * (1.0 - _coupled_l_p[_qp] / _unit_scalor) * _porosity[_qp];

  if (_has_coupled_s_p)
  {
    r = prefactor * _coupled_variable[_qp];
  }
  else if (_has_coupled_l_d)
  {
    r = prefactor * _u[_qp];
  }
  else
    mooseError("Either s_p_variable or l_d_variable must be provided");

  return -_test[_i][_qp] * r;
}

Real
PorousReaction_ld_sp::computeQpJacobian()
{
  Real jac = 0.0;
  Real prefactor = _sign * _reaction_rate[_qp] * (1.0 - _coupled_l_p[_qp] / _unit_scalor) * _porosity[_qp];

  if (_has_coupled_s_p)
  {
    jac = 0.0;
  }
  else if (_has_coupled_l_d)
  {
    jac = prefactor * _phi[_j][_qp];
  }
  else
    mooseError("Either s_p_variable or l_d_variable must be provided");

  return -_test[_i][_qp] * jac;
}
