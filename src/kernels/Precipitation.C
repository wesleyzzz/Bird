
#include "Precipitation.h"
#include <cmath>

template<>
InputParameters validParams<Precipitation>()
{
  InputParameters params = validParams<Kernel>();
  // params.addParam<Real>("sign", 1.0, "Sign of the kernel");
  params.addCoupledVar("precipitate_variable", "Ln solute in liquid precipitate.");
  params.addCoupledVar("dissolve_variable", "Ln precipitation in liquid redissolve.");
  // params.addParam<Real>("radius", 1.0, "Radius of the spherical sink");
  // params.addParam<Real>("unit_scalor", 1e6, "scale factor of the precipitation");
  params.addParam<MaterialPropertyName>("scale_factor", 1.0, "scale factor of the precipitation");
  // params.addParam<MaterialPropertyName>("radius", 1.0, "Radius of the spherical sink");
  // params.addParam<MaterialPropertyName>("a_0", 0.001, "The crystal lattice");
  params.addParam<MaterialPropertyName>("diffusivity", 1.0, "Name of diffusivity material properties");
  params.addParam<MaterialPropertyName>("solubility", 0.0, "Solubility of the Ln solute in corresponding media");
  params.addParam<PostprocessorName>("Ave_l_p", -1.0, "Test value of l_p average value in the pore from Postprocessors");

  return params;
}

Precipitation::Precipitation(const InputParameters & parameters) :
  Kernel(parameters),
  PI(3.1415926),
  // _unit_scalor(getParam<Real>("unit_scalor")),
  // _scale_factor(getParam<Real>("scale_factor")),
  _scale_factor(getMaterialProperty<Real>(getParam<MaterialPropertyName>("scale_factor"))),
  _has_coupled_precipitate(isCoupled("precipitate_variable")),
  _has_coupled_dissolve(isCoupled("dissolve_variable")),
  _sign((_has_coupled_precipitate) ? -1 : 1),
  _coupled_variable((_has_coupled_precipitate) ? coupledValue("precipitate_variable") : coupledValue("dissolve_variable")),
  // _radius(getParam<Real>("radius")),
  // _radius(getMaterialProperty<Real>(getParam<MaterialPropertyName>("radius"))),
  // _a_0(getMaterialProperty<Real>(getParam<MaterialPropertyName>("a_0"))),
  _diffusivity(getMaterialProperty<Real>(getParam<MaterialPropertyName>("diffusivity"))),
  _solubility(getMaterialProperty<Real>(getParam<MaterialPropertyName>("solubility"))),
  _Ave_l_p(getPostprocessorValue("Ave_l_p"))
{}

Real
Precipitation::computeQpResidual()
{
  Real r = 0.0;
  // Moose::out << "PI value is: " << PI << std::endl;
  // Moose::out << "_sign value is " << _sign << std::endl;
  Real prefactor = 4.0 * PI * _scale_factor[_qp] * _sign * _diffusivity[_qp];
  // Real prefactor = _scale_factor[_qp] * _sign * 4 * PI * _diffusivity[_qp] * _radius[_qp] / (std::pow(_a_0[_qp], 3));
  // Moose::out << "_sign value is: " << _sign << std::endl;
  // Moose::out << "_scale_factor value is: " << _scale_factor[_qp] << std::endl;
  // Moose::out << "_radius value is: " << _radius[_qp] << std::endl;
  // Moose::out << "The diffusivtity of solid: " << _diffusivity[_qp] << std::endl;
  // Moose::out << "cubic of the a_0: " << std::pow(_a_0[_qp], 3) << std::endl;
  // Moose::out << "prefactor calculated:  " << prefactor << std::endl;
  // Moose::out << std::endl;

  if (_has_coupled_precipitate)
  {
    if (_u[_qp] > _solubility[_qp] || _coupled_variable[_qp] > 0.0)
      r = prefactor * (_u[_qp] - _solubility[_qp]);
  }
  else if (_has_coupled_dissolve)
  {
    if (_coupled_variable[_qp] > _solubility[_qp] || _u[_qp] > 0.0)
      r = prefactor * (_coupled_variable[_qp] - _solubility[_qp]);
  }
  else
    mooseError("Either precipitate_variable or dissolve_variable must be provided");

  // Moose::out << "result value is : " << r << std::endl;
  // Moose::out << std::endl;
  return -_test[_i][_qp] * r;
}


Real
Precipitation::computeQpJacobian()
{
  Real jac = 0.0;
  // Real prefactor = _sign * 4 * PI * _diffusivity[_qp] * _radius / (std::pow(_a_0[_qp], 3));
  Real prefactor = 4.0 * PI * _scale_factor[_qp] * _sign * _diffusivity[_qp];

  if (_has_coupled_precipitate)
  {
    if (_u[_qp] > _solubility[_qp] || _coupled_variable[_qp] > 0.0)
      jac = prefactor * _phi[_j][_qp];
  }
  else if (_has_coupled_dissolve)
  {
    if (_coupled_variable[_qp] > _solubility[_qp] || _u[_qp] > 0.0)
      jac = 0.0;
  }
  else
    mooseError("Either precipitate_variable or dissolve_variable must be provided");

  return -_test[_i][_qp] * jac;
}
