# This will simulate the transient behavior
[Mesh]
  type = FileMesh
  file = Export_Cubit_1D_Cs_sink.e
  #elem_type = QUAD4
  second_order = true
[]

[MeshModifiers]
# interface between the fuel source and the pore region
  [./interface_from_s_l]
    type = SideSetsBetweenSubdomains
    master_block = 'fuel_l'
    paired_block = 'pore'
    new_boundary = master_fuel_l_interface
  [../]

  [./interface_from_s_r]
    type = SideSetsBetweenSubdomains
    master_block = 'fuel_r'
    paired_block = 'pore'
    new_boundary = master_fuel_r_interface
  [../]


# interface between the pore and the fuel
  [./interface_from_pore_l]
    type = SideSetsBetweenSubdomains
    master_block = 'pore'
    paired_block = 'fuel_l'
    new_boundary = master_pore_l_interface
  [../]

  [./interface_from_pore_r]
    type = SideSetsBetweenSubdomains
    master_block = 'pore'
    paired_block = 'fuel_r'
    new_boundary = master_pore_r_interface
  [../]


[]


[Variables]
  # For more accurate solutions, use a higher order (second)
  [./S_precipitate]
    order = SECOND
    family = LAGRANGE
    block = 'fuel_l fuel_r'

  [../]

  [./S_dissolve]
    order = SECOND
    family = LAGRANGE
    block = 'fuel_l fuel_r'

    #initial_condition = 0.0

  [../]

  [./L_dissolve]
    order = SECOND
    family = LAGRANGE
    block = 'pore'

    #initial_condition = 0.0

  [../]

  [./L_precipitate]
    order = SECOND
    family = LAGRANGE
    block = 'pore'

    #initial_condition = 0.0

  [../]

[]


#[ICs]
#  [./S_dissolve_IC]
#    type = BoundingBoxIC
#    x1 = 0
#    x2 = 5.0
#    y1 = 0.0
#    y2 = 30.0
#    inside = 2000
#    outside = 0
#    variable = L_dissolve
#    block = 'pore'
#  [../]
#[]

[AuxVariables]

  [./T]
    order = FIRST
    family = LAGRANGE
    block = 'fuel_l pore fuel_r'
  [../]

  [./Solid_solubility_Ln]
    order = FIRST
    family = LAGRANGE
    block = 'fuel_l fuel_r'
  [../]

  [./Liquid_solubility_Ln]
    order = FIRST
    family = LAGRANGE
    block = 'pore'
  [../]

  []

[Functions]
  [./Temp_Interpolation]

    type = ParsedFunction
    value = 'origin_temp + gradient_x * abs(x - startpoint_x)'
    vars = 'origin_temp startpoint_x gradient_x'
    vals = '855 0.0 -0.05'

  [../]

  [./Ln_Generation_Rate]
     type = ParsedFunction
     value = 'Concentration_Sat * speed * exp (-speed * t)'
     vars = 'Concentration_Sat speed'
     vals = '3e4 1e-4'

  [../]

#   Postprocessor Functions
  [./Ln_sum_all_blocks]
    type = ParsedFunction
    value = 'sum_S_dissolve + sum_S_precipitate + sum_L_dissolve + sum_L_precipitate'
    vals =  'sum_S_dissolve sum_S_precipitate sum_L_dissolve sum_L_precipitate'
    vars =  'sum_S_dissolve sum_S_precipitate sum_L_dissolve sum_L_precipitate'
  [../]

[]

[Kernels]
###--- L_dissolve -----------------------------------------------

[./liquid_porereaction_solute_dot]
  type = TimeDerivative
  variable = L_dissolve
  block = 'pore'
[../]


# (a) L_dissolve diffusion
[./liquid_reactionpore_solute_diffusion]
  type = MatDiffusion
  variable = L_dissolve
  block = 'pore'
  # Materials Properties
  D_name = diffusivity_liquid
[../]

### Soret diffusion
[./liquid_pore_Ln_solute_diffuse_Soret]
  type = SoretDiffusion
  variable = L_dissolve
  block = 'pore'
  T = T  # The later is the temperature name in the auxkernel
  # Materials Properties
  diff_name = diffusivity_liquid
  Q_name = Qheat_liquid  # Provide the transport heat

[../]

# (b) L_dissolve PrecipitationDissolution
[./lquid_porereaction_Ln_solute_precipitate]
  type = Precipitation_liquid
  variable = L_dissolve
  block = 'pore'
  precipitate_variable = L_precipitate

  # Artifical parameters
  scale_factor = scale_liquid
  # Materials properties
  #diffusivity = diffusivity_liquid
  solubility = solubility_liquid

  unit_scalor = 3.7425e+10
[../]

###--- L_precipitate ---------------------------------------------
[./liquid_porereaction_precipitate_dot]
  type = TimeDerivative
  variable = L_precipitate
  block = 'pore'
[../]

##(a) )Diffusion Process
#
#[./solid_porereaction_Ln_precipitation_diffuse_Soret]
#  type = DecrVarSoretDiffusion
#  variable = L_precipitate
#  block = 'pore'
#  T = T  # The later is the temperature name in the auxkernel
#  # Materials Properties
#  diff_name = diffusivity_liquid    # Can get the materials properties
#  Q_name = Qheat_solid_lp  # Provide the transport heat
#  # Conditions
#  test_variable = L_dissolve
#  solubility = solubility_liquid
#  stop_Ave_Precipitate = 9e5
#[../]


#(b) liquid precipitation redissolve
[./liquid_porereaction_precipitate_redissolve]
  type = Precipitation_liquid
  variable = L_precipitate
  block = 'pore'
  dissolve_variable = L_dissolve
  # Artifical parameters
  scale_factor = scale_liquid
  # Materials properties
  #diffusivity = diffusivity_liquid
  solubility = solubility_liquid

  unit_scalor = 3.7425e+10
[../]


###--- S_precipitate ---------------------------------------------
[./solid_fuelreaction_precipitation_dot]
  type = TimeDerivative
  variable = S_precipitate
  block = 'fuel_l fuel_r'
[../]

[./solid_fuelreaction_precipitatation_redissolve]
  type = Precipitation
  variable = S_precipitate
  block = 'fuel_l fuel_r'
  dissolve_variable = S_dissolve
  # Artifical parameters
  scale_factor = scale_solid
  # Materials properties
  diffusivity = diffusivity_solid_sd
  solubility = solubility_solid

  unit_scalor = 3.7425e+10
[../]

###--- S_dissolve -------------------------------------------------
# (a) Source
[./Ln_Generation]
  # For now assume a constant Ln generation rate only in the fuel block
  type = BodyForce
  #function = Ln_Generation_Rate

  value = 7.9399           # per minute
  variable = S_dissolve
  block = 'fuel_l fuel_r'
[../]

[./Solid_Ln_solute_dot]
  type = TimeDerivative
  variable = S_dissolve
  block = 'fuel_l fuel_r'
[../]

#(b) )Diffusion Process
[./solid_fuelreaction_Ln_solute_diffuse]
  type = MatDiffusion
  variable = S_dissolve
  block = 'fuel_l fuel_r'
  # Material properties
  D_name = diffusivity_solid_sd    # Can get the materials properties

[../]

[./solid_fuelreaction_Ln_solute_diffuse_Soret]
  type = SoretDiffusion
  variable = S_dissolve
  block = 'fuel_l fuel_r'
  T = T  # The later is the temperature name in the auxkernel
  # Materials Properties
  diff_name = diffusivity_solid_sd    # Can get the materials properties
  Q_name = Qheat_solid_sd  # Provide the transport heat

[../]

#(c) S_dissolve precipitation/dissolution in the fuel
[./solid_fuelreaction_solute_precipitate]
  type = Precipitation
  variable = S_dissolve
  block = 'fuel_l fuel_r'
  precipitate_variable = S_precipitate
  # Artifical parameters
  scale_factor = scale_solid
  # Materials properties
  diffusivity = diffusivity_solid_sd
  solubility = solubility_solid

  unit_scalor = 3.7425e+10

[../]

[]


[AuxKernels]

  [./Temperature_Interpolation]
  ## use a Parsedfunction to calculate the Temperature
    type = FunctionAux

    variable = T
    function = Temp_Interpolation
  [../]

  [./Solubility_fuel_relate_temperature]
    type = ParsedAux
    variable = Solid_solubility_Ln

    constant_names = 'fraction density_fuel'
    constant_expressions = '0.003 4.6719e10'
    function = 'fraction * density_fuel'
    block = 'fuel_l fuel_r'
  [../]

  [./Solubility_pore_relate_temperature]
    type = ParsedAux
    variable = Liquid_solubility_Ln

    args = T
    constant_names = 'density Q_s Ln_S0 k'

    ## Use the relationship of Ce in liquid Cs
    constant_expressions = '8.04012e9 0.66739735 -4.22401343 8.61733e-5'

    # Use the relationship of Ce in liquid Na
    #constant_expressions = '2.1077e10 0.22056278 -15.57626517 8.61733e-5'

    function = 'density * exp (-Q_s/k/T) * exp(Ln_S0)'
    block = 'pore'
  [../]

[]

[InterfaceKernels]
  [./interface_reaction_l]
    type = InterfaceForce_ld
    variable = L_dissolve
    neighbor_var = S_dissolve
    boundary = master_pore_l_interface
    coupled_l_p = L_precipitate
    coupled_s_p = S_precipitate

    # Materials properties
    diffusivity_in_liquid = diffusivity_liquid
    diffusivity_in_solid = diffusivity_solid_sd
    solubility_in_liquid = solubility_liquid
    solubility_in_solid = solubility_solid

    # Artifical parameters
    driving_rate = k_sd_ld

    unit_scalor = 3.7425e+10
  [../]

  [./interface_reaction_r]
    type = InterfaceForce_ld
    variable = L_dissolve
    neighbor_var = S_dissolve
    boundary = master_pore_r_interface
    coupled_l_p = L_precipitate
    coupled_s_p = S_precipitate

    # Materials properties
    diffusivity_in_liquid = diffusivity_liquid
    diffusivity_in_solid = diffusivity_solid_sd
    solubility_in_liquid = solubility_liquid
    solubility_in_solid = solubility_solid

    # Artifical parameters
    driving_rate = k_sd_ld

    unit_scalor = 3.7425e+10
  [../]

  [./interface_pureLn_reaction_l]
    type = InterfaceForce_lp
    variable = L_precipitate
    neighbor_var = S_dissolve
    boundary = master_pore_l_interface
    coupled_s_p = S_precipitate

    # Materials properties
    diffusivity_in_solid_sd = diffusivity_solid_sd
    solubility_in_solid = solubility_solid

    # Artifical parameters
    driving_rate = k_sd_lp

    unit_scalor = 3.7425e+10
    stop_threshold = 3.7425e+10
  [../]

  [./interface_pureLn_reaction_r]
    type = InterfaceForce_lp
    variable = L_precipitate
    neighbor_var = S_dissolve
    boundary = master_pore_r_interface
    coupled_s_p = S_precipitate

    # Materials properties
    diffusivity_in_solid_sd = diffusivity_solid_sd
    solubility_in_solid = solubility_solid

    # Artifical parameters
    driving_rate = k_sd_lp

    unit_scalor = 3.7425e+10
    stop_threshold = 3.7425e+10
  [../]

  [./interface_sp_reaction_l]
    type = InterfaceForce_sp
    variable = L_dissolve
    neighbor_var = S_precipitate
    boundary = master_pore_l_interface
    coupled_l_p = L_precipitate

    # Artifical parameters
    driving_rate = k_sp_ld

    # Materials properties
    diffusivity_in_solid_sd = diffusivity_solid_sd
    solubility_in_liquid = solubility_liquid

    unit_scalor = 3.7425e+10
    stop_threshold = 3.7425e+10
  [../]

  [./interface_sp_reaction_r]
    type = InterfaceForce_sp
    variable = L_dissolve
    neighbor_var = S_precipitate
    boundary = master_pore_r_interface
    coupled_l_p = L_precipitate

    # Artifical parameters
    driving_rate = k_sp_ld

    # Materials properties
    diffusivity_in_solid_sd = diffusivity_solid_sd
    solubility_in_liquid = solubility_liquid

    unit_scalor = 3.7425e+10
    stop_threshold = 3.7425e+10
  [../]


[]

[BCs]
  #[./interface_solidmaster_left]
  #  type = DirichletBC
  #  variable = S_precipitate
  #  boundary = master_s_l_interface
  #  value = 0.0
  #[../]
  #[./interface_solidmaster_right]
  #  type = DirichletBC
  #  variable = S_precipitate
  #  boundary = master_s_r_interface
  #  value = 0.0
  #[../]

[]

[Materials]
  # The materials blocks correspond to the mesh blocks
###--- diffusion process----------------------------
#[./Diffusivity_Solid_fuel]
#  type = GenericConstantMaterial
#
#  prop_names = 'diffusivity_solid_sd Qheat_solid_sd'
#  prop_values = '0.05 10.0'      # per minute
#  block = 'fuel_l fuel_r pore'
#[../]

[./Diffusivity_Solid_fuel_SoretHeat]
  type = GenericConstantMaterial

  prop_names = 'Qheat_solid_sd'
  prop_values = '1.0'      # per minute
  block = 'fuel_l fuel_r pore'
[../]

### Fitting parameters from Theta Ce from Ogata
[./Diffusivity_Solid_fuel]
  # Arrhenius equation
  type = ParsedMaterial

  f_name = diffusivity_solid_sd
  args = T
  constant_names = 'D0_d Q_d k'
  # Use the relationship of Ce in liquid U-Zr
  constant_expressions = '3.61e-8 1.171 8.61733e-5'
  # Convert to mcro^2/s
  function = '1e8 * D0_d * exp (-Q_d/k/T)'      # per minute
  block = 'fuel_l fuel_r pore'
[../]

### Constants for Gamma Ce from Charls ???
  ##  constant_expressions = '1.65e-6 1.99 8.61733e-5'

  ## Solid-state diffusivity in the pure Ln
  #[./Diffusivity_Solid_Ln_porereaction]
  #  type = GenericConstantMaterial
  #
  #  prop_names = 'diffusivity_solid_lp Qheat_solid_lp'
  #  prop_values = '0.5 20.0'      # per minute
  #  block = 'fuel_l fuel_r pore'
  #[../]

  # Liquid-state diffusivity in the pore (Cs_filled)
  [./Diffusivity_Liquid_pore]
    # Arrhenius equation
    type = ParsedMaterial

    f_name = diffusivity_liquid
    args = T
    constant_names = 'D0_d Q_d k'

    ## Use the relationship of Ce in liquid Cs
    constant_expressions = '1.56e-4 0.144 8.61733e-5'

    # Use the relationship of Ce in liquid Na
    #constant_expressions = '6.658e-4 0.2226 8.61733e-5'

    # Convert to mcro^2/s
    function = '1e8 * D0_d * exp (-Q_d/k/T)'      # per minute
    block = 'pore'
  [../]

  [./Diffusivity_Liquid_Soret]
    type = GenericConstantMaterial

    prop_names = 'Qheat_liquid'
    prop_values = '1.0'
    block = 'pore'
  [../]

###--- precipitation/dissolution process --------------------
###--- Artifical parameters ----
[./Interface_Ln_Driving_force_constant]
  type = GenericConstantMaterial
  prop_names = 'k_sd_ld k_sd_lp k_sp_ld'
  prop_values = '2e-5 1e3 1e5'
  block = 'fuel_l fuel_r pore'
[../]

[./scale_factor_Ln_precipitation]
  type = GenericConstantMaterial
  prop_names = 'scale_solid scale_liquid'
  prop_values = '1e1 1e1'
  block = 'fuel_l fuel_r pore'
[../]

  ### --------- solubility -------------
  [./Solubility_Solid]
    # Arrhenius equation
    type = ParsedMaterial

    f_name = solubility_solid
    constant_names = 'fraction density_solid'
    constant_expressions = '0.003 4.6719e10'
    function = 'fraction * density_solid'
    block = 'fuel_l pore fuel_r'

    outputs = exodus
  [../]

  [./Solubility_Liquid]
    # Arrhenius equation
    type = ParsedMaterial

    f_name = solubility_liquid
    args = T
    constant_names = 'density Q_s Ln_S0 k'

    ## Use the relationship of Ce in liquid Cs
    constant_expressions = '8.04012e9 0.66739735 -4.22401343 8.61733e-5'

    # Use the relationship of Ce in liquid Na
    #constant_expressions = '2.1077e10 0.22056278 -15.57626517 8.61733e-5'

    function = 'density * exp (-Q_s/k/T) * exp(Ln_S0)'
    block = 'pore'
    outputs = exodus
  [../]

[]

[Postprocessors]
  [./dt]
    type = TimestepSize
    outputs = 'console exodus'
  [../]

  #[./nl_its]
  #  type = NumNonlinearIterations
  #[../]

# Average value on the interface
  [./L_precipitate_Ave_side_l]
    type = SideAverageValue
    variable = L_precipitate
    boundary = master_pore_l_interface
    outputs = 'exodus'

  [../]

  [./L_precipitate_Ave_side_r]
    type = SideAverageValue
    variable = L_precipitate
    boundary = master_pore_r_interface

    outputs = 'exodus console'

  [../]

###=========== S_dissolve =========###
  [./S_dissolve_Ave_side_l]
    type = SideAverageValue
    variable = S_dissolve
    boundary = master_fuel_l_interface
    outputs = 'exodus'

  [../]

  [./S_dissolve_Ave_side_r]
    type = SideAverageValue
    variable = S_dissolve
    boundary = master_fuel_r_interface

    outputs = 'exodus console'

  [../]

###=========== L_dissolve =========###
  [./L_dissolve_Ave_side_l]
    type = SideAverageValue
    variable = L_dissolve
    boundary = master_pore_l_interface
    outputs = 'exodus'

  [../]

  [./L_dissolve_Ave_side_r]
    type = SideAverageValue
    variable = L_dissolve
    boundary = master_pore_r_interface

    outputs = 'exodus console'

  [../]

# Average values in the cell
  [./avg_L_precipitate_pore]
    type = ElementAverageValue
    variable = L_precipitate
    block = pore
    outputs = 'exodus'
  [../]
  [./avg_L_precipitate_fuel_l]
    type = ElementAverageValue
    variable = S_precipitate
    block = fuel_l
    outputs = 'exodus'
  [../]

### Postprocessors for the mass conservation check
### ======= Sum of different values ========= ###

  [./sum_S_dissolve]
    type = ElementIntegralVariablePostprocessor
    variable = S_dissolve
    block = 'fuel_l fuel_r'
    outputs = 'exodus'
  [../]

  [./sum_S_precipitate]
    type = ElementIntegralVariablePostprocessor
    variable = S_precipitate
    block = 'fuel_l fuel_r'
    outputs = 'exodus'
  [../]

  [./sum_L_dissolve]
    type = ElementIntegralVariablePostprocessor
    variable = L_dissolve
    block = 'pore'
    outputs = 'exodus'
  [../]

  [./sum_L_precipitate]
    type = ElementIntegralVariablePostprocessor
    variable = L_precipitate
    block = 'pore'
    outputs = 'exodus'
  [../]

  [./Total_Ln_sum]
    type = FunctionValuePostprocessor
    function = 'Ln_sum_all_blocks'
    outputs = 'exodus console'
  [../]

[]

[VectorPostprocessors]
  [./S_dissolve_distribution]
    type = LineValueSampler
    variable = S_dissolve
    start_point = '0 0.1 0'
    end_point = '60 0.1 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  [../]

  [./S_precipitate_distribution]
    type = LineValueSampler
    variable = S_precipitate
    start_point = '0 0.1 0'
    end_point = '60 0.1 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  [../]

  [./L_dissolve_distribution]
    type = LineValueSampler
    variable = L_dissolve
    start_point = '0 0.1 0'
    end_point = '60 0.1 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  [../]

  [./L_precipitate_distribution]
    type = LineValueSampler
    variable = L_precipitate
    start_point = '0 0.1 0'
    end_point = '60 0.1 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  [../]

  [./Ln_solubility_fuel_distribution]
    type = LineValueSampler
    variable = Solid_solubility_Ln
    start_point = '0 0.1 0'
    end_point = '60 0.1 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  [../]

  [./Ln_solubility_pore_distribution]
    type = LineValueSampler
    variable = Liquid_solubility_Ln
    start_point = '0 0.1 0'
    end_point = '60 0.1 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  [../]

  [./Integeral_Ln_different_sum]
    type = VectorOfPostprocessors
    postprocessors = 'sum_S_dissolve sum_S_precipitate sum_L_dissolve sum_L_precipitate Total_Ln_sum'
    outputs = 'CenterlineFinalValue'
  [../]

[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_linesearch_monitor -ksp_monitor_true_residual -ksp_monitor_singular_value -snes_view' 
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 150'
  dt = 100
  num_steps = 50000
  #end_time = 4.97664e+7     ### 288 effective full power days 5% burnup extend to 10%
  end_time = 2.48832e+7       ### 5% burnup for a fast test

  #nl_abs_tol = 1e-11
  #nl_rel_tol = 1e-08
  #l_tol = 1e-05
  #
  #ss_check_tol = 1e-08
  #trans_ss_check = true
  #
  #dtmax = 1e+4
  #dtmin = 1e-7

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
    cutback_factor = 0.5
    growth_factor = 2
    optimal_iterations = 6
    iteration_window = 2
  [../]
[]

[Outputs]
  [./console]
    type = Console
    #perf_log = true
    #max_rows = true

  [../]
  [./exodus]
    type = Exodus
    execute_on = 'timestep_end'
  [../]

  [./CenterlineFinalValue]
    type = CSV
    #time_data = true
    #time_column = true
    #execute_on = 'timestep_end'
    execute_on = 'final failed'
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
