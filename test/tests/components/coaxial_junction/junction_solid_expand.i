# Energy balance test
# ===================
#
# Apply 10 kW/m^2 to outer surface of the
# shell and check the increase in temperature at the fluid outlets

T_1 = 301
T_2 = 300
press = 1e5 # operating pressure

L = 1 # length of pipe

[GlobalParams]
  initial_p = ${press}
  closures = thm_closures
  fp=fluid
  gravity_vector = '0 0 0'
[]

[FluidProperties]
  [fluid] # mimic of water
    type = SimpleFluidProperties
    cv = 4000
  []
  [fluid2] # mimic of water
    type = SimpleFluidProperties
    cv = 2000
  []
[]

[SolidProperties]
  [adamantium] # fake solid material that ensures solid heats quickly
    type = ThermalFunctionSolidProperties
    cp = 1
    k = 1
    rho = 1
  []
  [ebony] # fake solid material that ensures solid heats quickly
    type = ThermalFunctionSolidProperties
    cp = 1
    k = 4
    rho = 16
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
      T = ${fparse 0.5*(T_1 + T_2)}
      m_dot = 0.
      input = coaxial1/inner:in
  []
  [inlet_outer]
      type = InletMassFlowRateTemperature1Phase
      T = ${fparse 0.5*(T_1 + T_2)}
      m_dot = 0.
      input = coaxial2/outer:out
  []
  [coaxial1]
    type = CoaxialPipe1Phase
    length = '${fparse L/3} ${fparse L/3} ${fparse L/3}'
    axial_region_names = 'part1 part2 part3'
    n_elems = '8 16 32'
    orientation = '1 0 0'
    position = '${fparse -L} 0 0'
    shell_inner_radius = 0.075
    shell_materials = 'adamantium'
    shell_n_elems = '2'
    shell_names = 'shell'
    shell_widths = '0.025'
    shell_T_ref = '${T_1}'
    tube_T_ref = ${T_1}
    tube_inner_radius = 0.025
    tube_materials = 'adamantium'
    tube_n_elems = '1'
    tube_names = 'tube'
    tube_widths = '0.025'
    inner_initial_vel = 0.
    outer_initial_vel = 0.
    initial_T = ${T_1}
    inner_tube_Hw = 0.
    outer_tube_Hw = 0.
    outer_shell_Hw = 0.
  []
  [jct]
    type = CoaxialJunction1Phase
    coaxial_connections = 'coaxial1:out coaxial2:in'
    shell_htc = 1e10
    tube_htc = 1e10
  []
  [coaxial2]
    type = CoaxialPipe1Phase
    length = '${fparse L/3} ${fparse L/3} ${fparse L/3}'
    axial_region_names = 'part1 part2 part3'
    n_elems = '32 16 8'
    orientation = '1 0 0'
    position = '0 0 0'
    shell_inner_radius = 0.08
    shell_materials = 'ebony'
    shell_n_elems = '2'
    shell_names = 'shell'
    shell_widths = '0.025'
    shell_T_ref = '${T_2}'
    tube_T_ref = ${T_2}
    tube_inner_radius = 0.025
    tube_materials = 'ebony'
    tube_n_elems = '1'
    tube_names = 'tube'
    tube_widths = '0.025'
    inner_initial_vel = 0.
    outer_initial_vel = 0.
    initial_T = ${T_2}
    inner_tube_Hw = 0.
    outer_tube_Hw = 0.
    outer_shell_Hw = 0.
  []
  [outlet_outer]
    type =Outlet1Phase
    input = coaxial1/outer:in
    p = ${press}
  []
  [outlet_inner]
      type =Outlet1Phase
      input = coaxial2/inner:out
      p = ${press}
  []
  [tube_start1]
    type = HSBoundarySpecifiedTemperature
    T = ${T_1}
    boundary = 'coaxial1/tube:start'
    hs = coaxial1/tube
  []
  [shell_start1]
    type = HSBoundarySpecifiedTemperature
    T = ${T_1}
    boundary = 'coaxial1/shell:start'
    hs = coaxial1/tube
  []
  [tube_end2]
    type = HSBoundarySpecifiedTemperature
    T = ${T_2}
    boundary = 'coaxial2/tube:end'
    hs = coaxial1/tube
  []
  [shell_end2]
    type = HSBoundarySpecifiedTemperature
    T = ${T_2}
    boundary = 'coaxial2/shell:end'
    hs = coaxial2/tube
  []

[]


[Postprocessors]
  [T_shell_out1]
    type = SideAverageValue
    boundary = coaxial1/shell:end
    variable = T_solid
  []
  [T_shell_in2]
    type = SideAverageValue
    boundary = coaxial2/shell:start
    variable = T_solid
  []
  [T_tube_out1]
    type = SideAverageValue
    boundary = coaxial1/tube:end
    variable = T_solid
  []
  [T_tube_in2]
    type = SideAverageValue
    boundary = coaxial2/tube:start
    variable = T_solid
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

  dt = 0.0001
  end_time = 0.01

  line_search = basic
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-6
  nl_max_its = 25
  automatic_scaling = true
  steady_state_detection = true
  # steady_state_tolerance = 2e-7
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
