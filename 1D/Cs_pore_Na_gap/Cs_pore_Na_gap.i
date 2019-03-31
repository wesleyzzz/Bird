[Mesh]
  type = MeshGeneratorMesh
[]

[MeshGenerators]
  [mesh_split]
    type = CartesianMeshGenerator
    dim = 1
    dx = '1 17 1 1 1 1 16 1 1 1 1 16 1.6 0.4'
    ix = '4 17 5 20 10 5 16 5 10 10 5 16 8 10'
    subdomain_id = '0 0 0 0 1 1 1 1 1 2 2 2 2 2'
  []
[]

[MeshModifiers]
  [renameblock]
    type = RenameBlock
    old_block_id = '0 1 2'
    new_block_name = 'fuel_l pore gap_r'
  []
  [interface_from_s_l]
    type = SideSetsBetweenSubdomains
    master_block = '0'
    paired_block = '1'
    new_boundary = 'master_fuel_l_interface'
  []
  [interface_from_pore_l]
    type = SideSetsBetweenSubdomains
    master_block = '1'
    paired_block = '0'
    new_boundary = 'master_pore_l_interface'
  []
  [interface_from_pore_r]
    type = SideSetsBetweenSubdomains
    master_block = '1'
    paired_block = '2'
    new_boundary = 'master_pore_r_interface'
  []
  [interface_from_g_r]
    type = SideSetsBetweenSubdomains
    master_block = '2'
    paired_block = '1'
    new_boundary = 'master_gap_r_interface'
  []
  [surface_gap_right_end]
    type = SideSetsFromNormals
    normals = '1 0 0'
    variance = 1e-3
    new_boundary = 'master_gap_r_end'
  []
[]

[Variables]
  # For more accurate solutions, use a higher order (second)
  [S_precipitate]
    order = FIRST
    family = LAGRANGE
    block = 'fuel_l'
  []
  [S_dissolve]
    order = FIRST
    family = LAGRANGE
    block = 'fuel_l'
  []
  [L_dissolve]
    order = FIRST
    family = LAGRANGE
    block = 'pore gap_r'
  []
  [L_precipitate]
    order = FIRST
    family = LAGRANGE
    block = 'pore gap_r'
  []
[]

[AuxVariables]
  [T]
    order = FIRST
    family = LAGRANGE
    block = 'fuel_l pore gap_r'
  []
  [Solid_solubility_Ln]
    order = FIRST
    family = LAGRANGE
    block = 'fuel_l'
  []
  [Liquid_solubility_Ln]
    order = FIRST
    family = LAGRANGE
    block = 'pore gap_r'
  []
  [bounds_dummy]
  []
[]

[Functions]
  # Postprocessor Functions
  [Temp_Interpolation]
    type = ParsedFunction
    value = 'origin_temp + gradient_x * abs(x - startpoint_x)'
    vars = 'origin_temp startpoint_x gradient_x'
    vals = '855 0.0 -0.05'
  []
  [Ln_Generation_Rate]
    type = ParsedFunction
    value = 'Concentration_Sat * speed * exp (-speed * t)'
    vars = 'Concentration_Sat speed'
    vals = '3e4 1e-4'
  []
  [Ln_sum_all_blocks]
    type = ParsedFunction
    value = 'sum_S_dissolve + sum_S_precipitate + sum_L_dissolve + sum_L_precipitate'
    vals = 'sum_S_dissolve sum_S_precipitate sum_L_dissolve sum_L_precipitate'
    vars = 'sum_S_dissolve sum_S_precipitate sum_L_dissolve sum_L_precipitate'
  []
[]

[Kernels]
  [Insolid_fuel_Ln_Generation_l]
    # For now assume a constant Ln generation rate only in the fuel block
    # function = Ln_Generation_Rate
    type = BodyForce
    value = 7.9399 # per second
    variable = S_dissolve
    block = 'fuel_l'
  []
  [InSolid_fuel_solute_dot]
    type = TimeDerivative
    variable = S_dissolve
    block = 'fuel_l'
  []
  [Insolid_fuel_solute_diffusion]
    # Material properties
    type = MatDiffusion
    variable = S_dissolve
    block = 'fuel_l'
    D_name = diffusivity_solid_sd
  []
  [Insolid_fuel_solute_Soret]
    # Materials Properties
    type = SoretDiffusion
    variable = S_dissolve
    block = 'fuel_l'
    T = 'T' # The later is the temperature name in the auxkernel
    diff_name = diffusivity_solid_sd
    Q_name = Qheat_solid_sd # Provide the transport heat
  []
  [Insolid_fuel_solute_precipitate]
    # Artifical parameters
    # Materials properties
    type = Precipitation
    unit_scalor = '3.7425e+10'
    variable = S_dissolve
    block = 'fuel_l'
    precipitate_variable = 'S_precipitate'
    scale_factor = scale_solid
    diffusivity = diffusivity_solid_sd
    solubility = solubility_solid
  []
  [Insolid_fuel_precipitation_dot]
    type = TimeDerivative
    variable = S_precipitate
    block = 'fuel_l'
  []
  [Insolid_fuel_precipitatate_redissolve]
    # Artifical parameters
    # Materials properties
    type = Precipitation
    unit_scalor = '3.7425e+10'
    variable = S_precipitate
    block = 'fuel_l'
    dissolve_variable = 'S_dissolve'
    scale_factor = scale_solid
    diffusivity = diffusivity_solid_sd
    solubility = solubility_solid
  []
  [Inliquid_solute_dot]
    type = TimeDerivative
    variable = L_dissolve
    block = 'pore gap_r'
  []
  [Inliquid_solute_diffusion]
    type = MatDiffusion
    variable = L_dissolve
    block = 'pore gap_r'
    D_name = diffusivity_liquid
  []
  [Inliquid_solute_Soret]
    # Materials Properties
    type = SoretDiffusion
    variable = L_dissolve
    block = 'pore gap_r'
    T = 'T' # The later is the temperature name in the auxkernel
    diff_name = diffusivity_liquid # Can get the materials properties
    Q_name = Qheat_liquid # Provide the transport heat
  []
  [Inliquid_solute_precipitate]
    # Artifical parameters
    # Materials properties
    type = Precipitation_liquid
    unit_scalor = '3.7425e+10'
    variable = L_dissolve
    block = 'pore gap_r'
    precipitate_variable = 'L_precipitate'
    scale_factor = scale_liquid
    solubility = solubility_liquid
  []
  [Inliquid_precipitation_dot]
    type = TimeDerivative
    variable = L_precipitate
    block = 'pore gap_r'
  []
  [Inliquid_precipitate_redissolve]
    # Artifical parameters
    # Materials properties
    type = Precipitation_liquid
    unit_scalor = '3.7425e+10'
    variable = L_precipitate
    block = 'pore gap_r'
    dissolve_variable = 'L_dissolve'
    scale_factor = scale_liquid
    solubility = solubility_liquid
  []
[]

[AuxKernels]
  [Temperature_Interpolation]
    type = FunctionAux
    variable = T
    function = Temp_Interpolation
  []
  [Solubility_fuel_relate_temperature]
    type = ParsedAux
    variable = Solid_solubility_Ln
    constant_names = 'fraction density_fuel'
    constant_expressions = '0.003 4.6719e10'
    function = 'fraction * density_fuel'
    block = 'fuel_l'
  []
  [Solubility_pore_relate_temperature]
    # # Use the relationship of Ce in liquid Cs
    type = ParsedAux
    variable = Liquid_solubility_Ln
    args = 'T'
    constant_names = 'density Q_s Ln_S0 k'
    constant_expressions = '8.04012e9 0.66739735 -4.22401343 8.61733e-5'
    function = 'density * exp (-Q_s/k/T) * exp(Ln_S0)'
    block = 'pore'
  []
  [Solubility_gap_relate_temperature]
    # Use the relationship of Ce in liquid Na
    type = ParsedAux
    variable = Liquid_solubility_Ln
    args = 'T'
    constant_names = 'density Q_s Ln_S0 k'
    constant_expressions = '2.1077e10 0.22056278 -15.57626517 8.61733e-5'
    function = 'density * exp (-Q_s/k/T) * exp(Ln_S0)'
    block = 'gap_r'
  []
[]

[InterfaceKernels]
  [interface_ld_reaction_l]
    # Materials properties
    # Artifical parameters
    type = InterfaceForce_ld
    variable = L_dissolve
    neighbor_var = 'S_dissolve'
    boundary = 'master_pore_l_interface'
    coupled_l_p = 'L_precipitate'
    coupled_s_p = 'S_precipitate'
    diffusivity_in_liquid = diffusivity_liquid
    diffusivity_in_solid = diffusivity_solid_sd
    solubility_in_liquid = solubility_liquid
    solubility_in_solid = solubility_solid
    driving_rate = k_sd_ld
    unit_scalor = 3.7425e+10
  []
  [interface_pureLn_reaction_l]
    # Materials properties
    # Artifical parameters
    type = InterfaceForce_lp
    variable = L_precipitate
    neighbor_var = 'S_dissolve'
    boundary = 'master_pore_l_interface'
    coupled_s_p = 'S_precipitate'
    diffusivity_in_solid_sd = diffusivity_solid_sd
    solubility_in_solid = solubility_solid
    driving_rate = k_sd_lp
    unit_scalor = 3.7425e+10
    stop_threshold = 3.7425e+10
  []
  [interface_sp_reaction_l]
    # Artifical parameters
    # Materials properties
    type = InterfaceForce_sp
    variable = L_dissolve
    neighbor_var = 'S_precipitate'
    boundary = 'master_pore_l_interface'
    coupled_l_p = 'L_precipitate'
    driving_rate = k_sp_ld
    diffusivity_in_solid_sd = diffusivity_solid_sd
    solubility_in_liquid = solubility_liquid
    unit_scalor = 3.7425e+10
    stop_threshold = 3.7425e+10
  []
[]

[BCs]
  # use natural BC, no need to set BCs
[]

[Materials]
  # ## Fitting parameters from Theta Ce from Ogata
  # Liquid-state diffusivity in the pore (Cs_filled)
  # Liquid-state diffusivity in the gap (Na_filled)
  # ##--- precipitation/dissolution process --------------------
  # ##--- Artifical parameters ----
  # ## --------- solubility -------------
  [Diffusivity_Solid_fuel_SoretHeat]
    type = GenericConstantMaterial
    prop_names = 'Qheat_solid_sd'
    prop_values = '1.0'
    block = 'fuel_l pore'
  []
  [Diffusivity_Solid_fuel]
    # Arrhenius equation
    # Use the relationship of Ce in solid U-Zr
    # Convert to mcro^2/s
    type = ParsedMaterial
    f_name = diffusivity_solid_sd
    args = 'T'
    constant_names = 'D0_d Q_d k'
    constant_expressions = '3.61e-8 1.171 8.61733e-5'
    function = '1e8 * D0_d * exp (-Q_d/k/T)'
    block = 'fuel_l pore'
  []
  [Diffusivity_Liquid_pore]
    # Arrhenius equation
    # # Use the relationship of Ce in liquid Cs
    # Use the relationship of Ce in liquid Na
    # constant_expressions = '6.658e-4 0.2226 8.61733e-5'
    # Convert to mcro^2/s
    type = ParsedMaterial
    f_name = diffusivity_liquid
    args = 'T'
    constant_names = 'D0_d Q_d k'
    constant_expressions = '1.56e-4 0.144 8.61733e-5'
    function = '1e8 * D0_d * exp (-Q_d/k/T)' # per minute
    block = 'pore'
  []
  [Diffusivity_Liquid_gap]
    # Arrhenius equation
    # # Use the relationship of Ce in liquid Cs
    # constant_expressions = '1.56e-4 0.144 8.61733e-5'
    # Use the relationship of Ce in liquid Na
    # Convert to mcro^2/s
    type = ParsedMaterial
    f_name = diffusivity_liquid
    args = 'T'
    constant_names = 'D0_d Q_d k'
    constant_expressions = '6.658e-4 0.2226 8.61733e-5'
    function = '1e8 * D0_d * exp (-Q_d/k/T)' # per minute
    block = 'gap_r'
  []
  [Diffusivity_Liquid_Soret]
    type = GenericConstantMaterial
    prop_names = 'Qheat_liquid'
    prop_values = '1.0'
    block = 'pore gap_r'
  []
  [Interface_Ln_Driving_force_constant]
    type = GenericConstantMaterial
    prop_names = 'k_sd_ld k_sd_lp k_sp_ld'
    prop_values = '2e-5 1e3 1e3'
    block = 'fuel_l pore'
  []
  [scale_factor_Ln_precipitation]
    type = GenericConstantMaterial
    prop_names = 'scale_solid scale_liquid'
    prop_values = '1e1 1e1'
    block = 'fuel_l pore gap_r'
  []
  [Solubility_Solid]
    # Arrhenius equation
    # this will be called at interface kernel calculation so it has to include pore domain
    type = ParsedMaterial
    f_name = solubility_solid
    constant_names = 'fraction density_solid'
    constant_expressions = '0.003 4.6719e10'
    function = 'fraction * density_solid'
    block = 'fuel_l pore'
    outputs = 'exodus'
  []
  [Solubility_Liquid_pore]
    # Arrhenius equation
    # # Use the relationship of Ce in liquid Cs
    type = ParsedMaterial
    f_name = solubility_liquid
    args = 'T'
    constant_names = 'density Q_s Ln_S0 k'
    constant_expressions = '8.04012e9 0.66739735 -4.22401343 8.61733e-5'
    function = 'density * exp (-Q_s/k/T) * exp(Ln_S0)'
    block = 'pore'
    outputs = 'exodus'
  []
  [Solubility_Liquid_gap]
    # Arrhenius equation
    # Use the relationship of Ce in liquid Na
    type = ParsedMaterial
    f_name = solubility_liquid
    args = 'T'
    constant_names = 'density Q_s Ln_S0 k'
    constant_expressions = '2.1077e10 0.22056278 -15.57626517 8.61733e-5'
    function = 'density * exp (-Q_s/k/T) * exp(Ln_S0)'
    block = 'gap_r'
    outputs = 'exodus'
  []
[]

[Postprocessors]
  # ##=========== L_precipitate =========###
  # ##=========== L_dissolve =========###
  # Average values in the cell
  # ## Postprocessors for the mass conservation check
  # ## ======= Sum of different values ========= ###
  [dt]
    type = TimestepSize
    outputs = 'console exodus'
  []
  [L_precipitate_Ave_side_l]
    type = SideAverageValue
    variable = 'L_precipitate'
    boundary = 'master_pore_l_interface'
    outputs = 'exodus'
  []
  [L_precipitate_Ave_side_r]
    type = SideAverageValue
    variable = 'L_precipitate'
    boundary = 'master_gap_r_end'
    outputs = 'exodus console'
  []
  [L_dissolve_Ave_side_l]
    type = SideAverageValue
    variable = 'L_dissolve'
    boundary = 'master_pore_l_interface'
    outputs = 'exodus'
  []
  [L_dissolve_Ave_side_r]
    type = SideAverageValue
    variable = 'L_dissolve'
    boundary = 'master_gap_r_end'
    outputs = 'exodus console'
  []
  [avg_L_precipitate_pore_gap_r]
    type = ElementAverageValue
    variable = 'L_precipitate'
    block = 'pore gap_r'
    outputs = 'exodus'
  []
  [avg_L_dissolve_pore_gap_r]
    type = ElementAverageValue
    variable = 'L_dissolve'
    block = 'pore gap_r'
    outputs = 'exodus'
  []
  [avg_S_precipitate_fuel_l]
    type = ElementAverageValue
    variable = 'S_precipitate'
    block = 'fuel_l'
    outputs = 'exodus'
  []
  [avg_S_dissolve_fuel_l]
    type = ElementAverageValue
    variable = 'S_dissolve'
    block = 'fuel_l'
    outputs = 'exodus'
  []
  [sum_S_dissolve]
    type = ElementIntegralVariablePostprocessor
    variable = 'S_dissolve'
    block = 'fuel_l'
    outputs = 'exodus'
  []
  [sum_S_precipitate]
    type = ElementIntegralVariablePostprocessor
    variable = 'S_precipitate'
    block = 'fuel_l'
    outputs = 'exodus'
  []
  [sum_L_dissolve]
    type = ElementIntegralVariablePostprocessor
    variable = 'L_dissolve'
    block = 'pore gap_r'
    outputs = 'exodus'
  []
  [sum_L_precipitate]
    type = ElementIntegralVariablePostprocessor
    variable = 'L_precipitate'
    block = 'pore gap_r'
    outputs = 'exodus'
  []
  [Total_Ln_sum]
    type = FunctionValuePostprocessor
    function = Ln_sum_all_blocks
    outputs = 'exodus console'
  []
[]

[VectorPostprocessors]
  [S_dissolve_distribution]
    type = LineValueSampler
    variable = 'S_dissolve'
    start_point = '0 0 0'
    end_point = '60 0 0'
    num_points = 100
    sort_by = x
    outputs = 'CenterlineFinalValue'
  []
  [S_precipitate_distribution]
    type = LineValueSampler
    variable = 'S_precipitate'
    start_point = '0 0 0'
    end_point = '60 0 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  []
  [L_dissolve_distribution]
    type = LineValueSampler
    variable = 'L_dissolve'
    start_point = '0 0 0'
    end_point = '60 0 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  []
  [L_precipitate_distribution]
    type = LineValueSampler
    variable = 'L_precipitate'
    start_point = '50 0 0'
    end_point = '60 0 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  []
  [Ln_solubility_fuel_distribution]
    type = LineValueSampler
    variable = 'Solid_solubility_Ln'
    start_point = '0 0 0'
    end_point = '60 0 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  []
  [Ln_solubility_pore_distribution]
    type = LineValueSampler
    variable = 'Liquid_solubility_Ln'
    start_point = '0 0 0'
    end_point = '60 0 0'
    num_points = 600
    sort_by = x
    outputs = 'CenterlineFinalValue'
  []
  [Integeral_Ln_different_sum]
    type = VectorOfPostprocessors
    postprocessors = 'sum_S_dissolve sum_S_precipitate sum_L_dissolve sum_L_precipitate Total_Ln_sum'
    outputs = 'CenterlineFinalValue'
  []
  [Ave_gap_right_side_and_volume]
    type = VectorOfPostprocessors
    postprocessors = 'L_precipitate_Ave_side_r L_dissolve_Ave_side_r avg_L_precipitate_pore_gap_r avg_L_dissolve_pore_gap_r avg_S_precipitate_fuel_l avg_S_dissolve_fuel_l'
    outputs = 'CenterlineFinalValue'
  []
[]

[Executioner]
  # end_time = 2.48832e+7       ### 5% burnup for a fast test
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -snes_type'
  petsc_options_value = 'hypre boomeramg vinewtonrsls'
  dt = 100
  num_steps = 50000
  end_time = 4.97664e+7 # ## 288 effective full power days 5% burnup extend to 10%
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
    cutback_factor = 0.5
    growth_factor = 2
    optimal_iterations = 6
    iteration_window = 2
  []
[]

[Outputs]
  [console]
    type = Console
  []
  [exodus]
    type = Exodus
    execute_on = 'timestep_end'
  []
  [CenterlineFinalValue]
    type = CSV
    execute_on = 'FINAL'
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Bounds]
  [L_precipitate_bounds]
    # set this bound not below 0
    type = BoundsAux
    lower = 0
    bounded_variable = 'L_precipitate'
    variable = bounds_dummy
    block = 'pore gap_r'
  []
[]
