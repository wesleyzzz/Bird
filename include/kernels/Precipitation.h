
#ifndef PRECIPITATION_H
#define PRECIPITATION_H

#include "Kernel.h"

// Forward Declaration
class Precipitation;

template<>
InputParameters validParams<Precipitation>();

class Precipitation : public Kernel
{
public:
  Precipitation(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const Real PI;
  // const Real _unit_scalor;
  const MaterialProperty<Real> & _scale_factor;
  const bool _has_coupled_precipitate;
  const bool _has_coupled_dissolve;
  const int _sign;
  const VariableValue & _coupled_variable;
  // const Real _radius;
  // const MaterialProperty<Real> & _radius;
  // const MaterialProperty<Real> & _a_0;
  const MaterialProperty<Real> & _diffusivity;
  const MaterialProperty<Real> & _solubility;
  const Real & _Ave_l_p;
};
#endif //PRECIPITATION_H
