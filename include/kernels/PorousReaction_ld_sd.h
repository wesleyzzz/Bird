
#ifndef POROUSREACTION_LD_SD_H
#define POROUSREACTION_LD_SD_H

#include "Kernel.h"

// Forward Declaration
class PorousReaction_ld_sd;

template<>
InputParameters validParams<PorousReaction_ld_sd>();

class PorousReaction_ld_sd : public Kernel
{
public:
  PorousReaction_ld_sd(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const VariableValue & _coupled_l_p;
  const bool _has_coupled_s_d;
  const bool _has_coupled_l_d;
  const int _sign;
  const VariableValue & _coupled_solute;

  const Real _unit_scalor;
  const MaterialProperty<Real> & _reaction_rate;

  const MaterialProperty<Real> & _solubility_in_liquid;
  const MaterialProperty<Real> & _solubility_in_solid;
  const MaterialProperty<Real> & _diffusivity_in_liquid;
  const MaterialProperty<Real> & _diffusivity_in_solid;
  const MaterialProperty<Real> & _porosity;
};
#endif //POROUSREACTION_LD_SD_H
