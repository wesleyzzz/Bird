
#include "Precipitation_liquid.h"
#include <cmath>

template<>
InputParameters validParams<Precipitation_liquid>()
{
  InputParameters params = validParams<Kernel>();
  params.addCoupledVar("precipitate_variable", "Ln solute in liquid precipitate.");
  params.addCoupledVar("dissolve_variable", "Ln precipitation in liquid redissolve.");
  // params.addParam<Real>("unit_scalor", 1e6, "scale factor of the precipitation");
  params.addParam<MaterialPropertyName>("scale_factor", 1.0, "scale factor of the precipitation");
  // params.addParam<MaterialPropertyName>("diffusivity", 1.0, "Name of diffusivity material properties");
  params.addParam<MaterialPropertyName>("solubility", 0.0, "Solubility of the Ln solute in corresponding media");
  params.addParam<PostprocessorName>("Ave_l_p", -1.0, "Test value of l_p average value in the pore from Postprocessors");

  return params;
}

Precipitation_liquid::Precipitation_liquid(const InputParameters & parameters) :
  Kernel(parameters),
  // _unit_scalor(getParam<Real>("unit_scalor")),
  _scale_factor(getMaterialProperty<Real>(getParam<MaterialPropertyName>("scale_factor"))),
  _has_coupled_precipitate(isCoupled("precipitate_variable")),
  _has_coupled_dissolve(isCoupled("dissolve_variable")),
  _sign((_has_coupled_precipitate) ? -1 : 1),
  _coupled_variable((_has_coupled_precipitate) ? coupledValue("precipitate_variable") : coupledValue("dissolve_variable")),
  // _diffusivity(getMaterialProperty<Real>(getParam<MaterialPropertyName>("diffusivity"))),
  _solubility(getMaterialProperty<Real>(getParam<MaterialPropertyName>("solubility"))),
  _Ave_l_p(getPostprocessorValue("Ave_l_p"))
{}

Real
Precipitation_liquid::computeQpResidual()
{
  Real r = 0.0;
  Real prefactor = _scale_factor[_qp] * _sign;

  if (_has_coupled_precipitate)
  {
     if (_u[_qp] > _solubility[_qp])      
//if (_u[_qp] > _solubility[_qp] || _coupled_variable[_qp] > 0.0)  // will cause a bad performance, rapid shrinking of timestep, do not make a comparison here
      r = prefactor * (_u[_qp] - _solubility[_qp]);
  }
  else if (_has_coupled_dissolve)
  {
      if (_coupled_variable[_qp] > _solubility[_qp])
    //if (_coupled_variable[_qp] > _solubility[_qp] || _u[_qp] > 0.0)
      r = prefactor * (_coupled_variable[_qp] - _solubility[_qp]);
  }
  else
    mooseError("Either precipitate_variable or dissolve_variable must be provided");

  return -_test[_i][_qp] * r;
}


Real
Precipitation_liquid::computeQpJacobian()
{
  Real jac = 0.0;
  Real prefactor = _scale_factor[_qp] * _sign;

  if (_has_coupled_precipitate)
  {
    if (_u[_qp] > _solubility[_qp])
    //if (_u[_qp] > _solubility[_qp] || _coupled_variable[_qp] > 0.0)
      jac = prefactor * _phi[_j][_qp];
  }
  else if (_has_coupled_dissolve)
  {
    if (_coupled_variable[_qp] > _solubility[_qp])
    //if (_coupled_variable[_qp] > _solubility[_qp] || _u[_qp] > 0.0)
      jac = 0.0;
  }
  else
    mooseError("Either precipitate_variable or dissolve_variable must be provided");

  return -_test[_i][_qp] * jac;
}
