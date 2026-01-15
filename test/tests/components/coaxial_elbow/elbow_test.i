# Elbow pressure drop tests
# ===================
#
# Check pressure drop matches correlations

T_in = ${fparse 50 + 273.15} # Arbitrary reference temperature
mdot = 0.5 # nominal mass flow rate for primary
press = 1e5 # operating pressure


[GlobalParams]
  initial_p = ${press}
  initial_T = ${T_in}
  fp=fluid
  gravity_vector = '0 0 0'
[]

[FluidProperties]
  [fluid] # mimic of water
    type = SimpleFluidProperties
  []
[]

[SolidProperties] # Not currently needed as solid heat transfer not considered yet
  [adamantium] # fake solid material that ensures solid heats quickly
    type = ThermalFunctionSolidProperties
    cp = 40
    k = 50
    rho = 100
  []
[]

[Closures] # defines friction factors and heat transfer coefficients
  [thm_closures]
    type = Closures1PhaseTHM # default Churchill friction factor, DB HTC
  []
[]

[Components]
  [inlet_inner]
      type = InletMassFlowRateTemperature1Phase
      T = ${T_in}
      m_dot = ${mdot}
      input = coaxial/inner:in
  []
  [inlet_outer]
      type = InletMassFlowRateTemperature1Phase
      T = ${T_in}
      m_dot = ${mdot}
      input = coaxial/outer:in
  []
  [coaxial]
    type = CoaxialElbow1Phase
    n_elems = 200
    orientation = '1 0 0'
    start_angle = 0.
    radius = 0.1
    end_angle = 90
    position = '0 0 0'
    shell_inner_radius = 0.075
    shell_materials = 'adamantium'
    shell_n_elems = '10'
    shell_names = 'shell'
    shell_widths = '0.025'
    shell_T_ref = '${T_in}'
    tube_T_ref = ${T_in}
    tube_inner_radius = 0.025
    tube_materials = 'adamantium'
    tube_n_elems = '10'
    tube_names = 'tube'
    tube_widths = '0.025'
    inner_initial_vel = 0.02
    outer_initial_vel = 0.05
  []
  [outlet_outer]
    type =Outlet1Phase
    input = coaxial/outer:out
    p = ${press}
  []
  [outlet_inner]
      type =Outlet1Phase
      input = coaxial/inner:out
      p = ${press}
  []
[]


[Postprocessors]
  [p_inlet_inner]
    type = SideAverageValue
    boundary = coaxial/inner:in
    variable = p
  []
  [p_outlet_inner]
    type = SideAverageValue
    boundary = coaxial/inner:out
    variable = p
  []
  [p_inlet_outer]
    type = SideAverageValue
    boundary = coaxial/outer:in
    variable = p
  []
  [p_outlet_outer]
    type = SideAverageValue
    boundary = coaxial/outer:out
    variable = p
  []
  [vel_inlet_inner]
    type = SideAverageValue
    boundary = coaxial/inner:in
    variable = vel_y
  []
  [vel_inlet_outer]
    type = SideAverageValue
    boundary = coaxial/outer:in
    variable = vel_y
  []
  [rho_inner]
    type = ADSideAverageMaterialProperty
    boundary = coaxial/inner:out
    property = rho
  []
  [rho_outer]
    type = ADSideAverageMaterialProperty
    boundary = coaxial/outer:out
    property = rho
  []
  [delta_p_inner]
    type = ParsedPostprocessor
    expression = 'p_out - p_in'
    pp_names = 'p_outlet_inner p_inlet_inner'
    pp_symbols = 'p_in p_out'
  []
  [delta_p_outer]
    type = ParsedPostprocessor
    expression = 'p_out - p_in'
    pp_names = 'p_outlet_outer p_inlet_outer'
    pp_symbols = 'p_in p_out'
  []
[]

[Preconditioning]
  [pc]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  start_time = 0

  dt = 0.025
  end_time = 2000

  line_search = basic
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-3
  nl_abs_tol = 1e-6
  nl_max_its = 25
  automatic_scaling = true
  steady_state_detection = true
  steady_state_tolerance = 5e-7
[]

[Outputs]
  exodus = true
  csv = true
  [console]
    type = Console
    max_rows = 1
    execute_postprocessors_on = final
    outlier_variable_norms = false
  []
  print_linear_residuals = false
[]
