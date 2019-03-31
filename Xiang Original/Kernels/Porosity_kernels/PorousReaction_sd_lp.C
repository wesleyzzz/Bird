
#include "PorousReaction_sd_lp.h"
#include <cmath>

template<>
InputParameters validParams<PorousReaction_sd_lp>()
{
  InputParameters params = validParams<Kernel>();
  params.addCoupledVar("coupled_s_d", "couple Ln solute in the solid fuel.");
  params.addCoupledVar("coupled_l_p", "couple Ln precipitates from liquid metal solution.");
  // materials properties: solubility and diffusivity
  params.addRequiredParam<Real>("unit_scalor", "atomic density for the pure Ln");
  params.addParam<Real>("stop_threshold", 9.9e5, "Ln concentration stoping threshold for such flux");
  params.addParam<MaterialPropertyName>("reaction_rate", 1.0, "reaction rate constant between the elements in diffusion couple");
  params.addParam<MaterialPropertyName>("solubility_in_solid", 0.0, "Name of solubility material in the solid fuel");
  params.addParam<MaterialPropertyName>("diffusivity_in_solid_sd", 1.0, "Name of diffusivity material in the solid fuel");
  params.addParam<MaterialPropertyName>("diffusivity_in_solid_lp", 1.0, "Name of diffusivity material in the Ln precipitate from liquid");

  params.addParam<MaterialPropertyName>("porosity", 0.1, "Name of porosity in porous media");
  return params;
}

PorousReaction_sd_lp::PorousReaction_sd_lp(const InputParameters & parameters) :
  Kernel(parameters),
  // conditional coupled variables
  _has_coupled_s_d(isCoupled("coupled_s_d")),
  _has_coupled_l_p(isCoupled("coupled_l_p")),
  _sign((_has_coupled_s_d) ? 1 : -1),
  _coupled_variable((_has_coupled_s_d) ? coupledValue("coupled_s_d") : coupledValue("coupled_l_p")),
  // Materials properties
  // _reaction_rate(getParam<Real>("reaction_rate")),
  _unit_scalor(getParam<Real>("unit_scalor")),
  _stop_threshold(getParam<Real>("stop_threshold")),
  _reaction_rate(getMaterialProperty<Real>(getParam<MaterialPropertyName>("reaction_rate"))),
  _solubility_in_solid(getMaterialProperty<Real>(getParam<MaterialPropertyName>("solubility_in_solid"))),
  _diffusivity_in_solid_sd(getMaterialProperty<Real>(getParam<MaterialPropertyName>("diffusivity_in_solid_sd"))),
  _diffusivity_in_solid_lp(getMaterialProperty<Real>(getParam<MaterialPropertyName>("diffusivity_in_solid_lp"))),
  _porosity(getMaterialProperty<Real>(getParam<MaterialPropertyName>("porosity")))
{}

Real
PorousReaction_sd_lp::computeQpResidual()
{
  Real r = 0.0;
  Real prefactor = _sign * _diffusivity_in_solid_sd[_qp] * _porosity[_qp];

  if (_has_coupled_s_d)
  {
    Real Force_eff = _reaction_rate[_qp] * (_coupled_variable[_qp] / _solubility_in_solid[_qp] - _u[_qp] / _unit_scalor);
    if (Force_eff > 0.0)
      r = prefactor * Force_eff * (_u[_qp] / _unit_scalor) * (1.0 - _u[_qp] / _unit_scalor);    // The precipitation in the pore serves as a Ln sink
    else
      r = prefactor * Force_eff * _u[_qp] / _unit_scalor;    // The precipitation in the pore serves as a Ln pump
  }
  else if (_has_coupled_l_p)
  {
    Real Force_eff = _reaction_rate[_qp] * (_u[_qp] / _solubility_in_solid[_qp] - _coupled_variable[_qp] / _unit_scalor);
    if (Force_eff > 0.0)
      r = prefactor * Force_eff * (_coupled_variable[_qp] / _unit_scalor) * (1.0 - _coupled_variable[_qp] / _unit_scalor);    // The precipitation in the pore serves as a Ln sink
    else
      r = prefactor * Force_eff * _coupled_variable[_qp] / _unit_scalor;    // The precipitation in the pore serves as a Ln pump
  }
  else
    mooseError("Either s_d_variable or l_p_variable must be provided");

  return -_test[_i][_qp] * r;
}

Real
PorousReaction_sd_lp::computeQpJacobian()
{
  Real jac = 0.0;
  Real prefactor = _sign * _reaction_rate[_qp] * _diffusivity_in_solid_sd[_qp] * _porosity[_qp];

  if (_has_coupled_s_d)
  {
    Real Force_eff = _coupled_variable[_qp] / _solubility_in_solid[_qp] - _u[_qp] / _unit_scalor;
    if (Force_eff > 0.0)
      jac = prefactor * ((-_phi[_j][_qp] / _unit_scalor) * (_u[_qp] / _unit_scalor) * (1.0 - _u[_qp] / _unit_scalor) + (_coupled_variable[_qp] / _solubility_in_solid[_qp] - _u[_qp] / _unit_scalor) * (_phi[_j][_qp] / _unit_scalor - 2.0 * _phi[_j][_qp] * _u[_qp] / _unit_scalor / _unit_scalor));    // The precipitation in the pore serves as a Ln sink
    else
      jac = prefactor * (_coupled_variable[_qp] / _solubility_in_solid[_qp] * _phi[_j][_qp] / _unit_scalor - 2.0 * _phi[_j][_qp] * _u[_qp] / _unit_scalor / _unit_scalor);    // The precipitation in the pore serves as a Ln pump
  }
  else if (_has_coupled_l_p)
  {
    Real Force_eff = _u[_qp] / _solubility_in_solid[_qp] - _coupled_variable[_qp] / _unit_scalor;
    if (Force_eff > 0.0)
      jac = prefactor * (_phi[_j][_qp] / _solubility_in_solid[_qp]) * (_coupled_variable[_qp] / _unit_scalor) * (1.0 - _coupled_variable[_qp] / _unit_scalor);    // The precipitation in the pore serves as a Ln sink
    else
      jac = prefactor * (_phi[_j][_qp] / _solubility_in_solid[_qp]) * _coupled_variable[_qp] / _unit_scalor;    // The precipitation in the pore serves as a Ln pump
  }
  else
    mooseError("Either s_d_variable or l_p_variable must be provided");

  return -_test[_i][_qp] * jac;
}
