#include "Precipitation.h"
#include <cmath>

template<>
InputParameters validParams<Precipitation>()
{
  InputParameters params = validParams<Kernel>();
  params.addCoupledVar("precipitate_variable", "Ln solute in liquid precipitate.");
  params.addCoupledVar("dissolve_variable", "Ln precipitation in liquid redissolve.");
  params.addParam<MaterialPropertyName>("scale_factor", 1.0, "scale factor of the precipitation");
  params.addParam<MaterialPropertyName>("diffusivity", 1.0, "Name of diffusivity material properties");
  params.addParam<MaterialPropertyName>("solubility", 0.0, "Solubility of the Ln solute in corresponding media");
  params.addParam<PostprocessorName>("Ave_l_p", -1.0, "Test value of l_p average value in the pore from Postprocessors");
  return params;
}

Precipitation::Precipitation(const InputParameters & parameters) :
  Kernel(parameters),
  PI(3.1415926),
  _scale_factor(getMaterialProperty<Real>(getParam<MaterialPropertyName>("scale_factor"))),
  _has_coupled_precipitate(isCoupled("precipitate_variable")),
  _has_coupled_dissolve(isCoupled("dissolve_variable")),
  _sign((_has_coupled_precipitate) ? -1 : 1),
  _coupled_variable((_has_coupled_precipitate) ? coupledValue("precipitate_variable") : coupledValue("dissolve_variable")),
  _diffusivity(getMaterialProperty<Real>(getParam<MaterialPropertyName>("diffusivity"))),
  _solubility(getMaterialProperty<Real>(getParam<MaterialPropertyName>("solubility"))),
  _Ave_l_p(getPostprocessorValue("Ave_l_p"))
{}

Real
Precipitation::computeQpResidual()
{
  Real r = 0.0;
  Real prefactor = 4.0 * PI * _scale_factor[_qp] * _sign * _diffusivity[_qp];

  if (_has_coupled_precipitate)
  {
    if (_u[_qp] > _solubility[_qp])
      r = prefactor * (_u[_qp] - _solubility[_qp]);
  }
  else if (_has_coupled_dissolve)
  {
    if (_coupled_variable[_qp] > _solubility[_qp])
      r = prefactor * (_coupled_variable[_qp] - _solubility[_qp]);
  }
  else
    mooseError("Either precipitate_variable or dissolve_variable must be provided");

  return -_test[_i][_qp] * r;
}


Real
Precipitation::computeQpJacobian()
{
  Real jac = 0.0;
  Real prefactor = 4.0 * PI * _scale_factor[_qp] * _sign * _diffusivity[_qp];

  if (_has_coupled_precipitate)
  {
    if (_u[_qp] > _solubility[_qp])
      jac = prefactor * _phi[_j][_qp];
  }
  else if (_has_coupled_dissolve)
  {
    if (_coupled_variable[_qp] > _solubility[_qp])
      jac = 0.0;
  }
  else
    mooseError("Either precipitate_variable or dissolve_variable must be provided");

  return -_test[_i][_qp] * jac;
}
