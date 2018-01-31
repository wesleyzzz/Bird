
#ifndef PRECIPITATION_LIQUID_H
#define PRECIPITATION_LIQUID_H

#include "Kernel.h"

// Forward Declaration
class Precipitation_liquid;

template<>
InputParameters validParams<Precipitation_liquid>();

class Precipitation_liquid : public Kernel
{
public:
  Precipitation_liquid(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  // const Real _unit_scalor;
  const MaterialProperty<Real> & _scale_factor;
  const bool _has_coupled_precipitate;
  const bool _has_coupled_dissolve;
  const int _sign;
  const VariableValue & _coupled_variable;
  const MaterialProperty<Real> & _solubility;
  const Real & _Ave_l_p;
};
#endif //PRECIPITATION_LIQUID_H
