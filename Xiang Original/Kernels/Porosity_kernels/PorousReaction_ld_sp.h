
#ifndef POROUSREACTION_LD_SP_H
#define POROUSREACTION_LD_SP_H

#include "Kernel.h"

// Forward Declaration
class PorousReaction_ld_sp;

template<>
InputParameters validParams<PorousReaction_ld_sp>();

class PorousReaction_ld_sp : public Kernel
{
public:
  PorousReaction_ld_sp(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const VariableValue & _coupled_l_p;
  const bool _has_coupled_s_p;
  const bool _has_coupled_l_d;
  const int _sign;
  const VariableValue & _coupled_variable;

  const Real _unit_scalor;
  const MaterialProperty<Real> & _reaction_rate;
  const MaterialProperty<Real> & _porosity;

};
#endif //POROUSREACTION_LD_SP_H
