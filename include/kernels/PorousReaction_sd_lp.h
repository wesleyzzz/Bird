
#ifndef POROUSREACTION_SD_LP_H
#define POROUSREACTION_SD_LP_H

#include "Kernel.h"

// Forward Declaration
class PorousReaction_sd_lp;

template<>
InputParameters validParams<PorousReaction_sd_lp>();

class PorousReaction_sd_lp : public Kernel
{
public:
  PorousReaction_sd_lp(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const bool _has_coupled_s_d;
  const bool _has_coupled_l_p;
  const int _sign;
  const VariableValue & _coupled_variable;

  const Real _unit_scalor;
  const Real _stop_threshold;
  const MaterialProperty<Real> & _reaction_rate;

  const MaterialProperty<Real> & _solubility_in_solid;
  const MaterialProperty<Real> & _diffusivity_in_solid_sd;
  const MaterialProperty<Real> & _diffusivity_in_solid_lp;
  const MaterialProperty<Real> & _porosity;
};
#endif //POROUSREACTION_SD_LP_H
