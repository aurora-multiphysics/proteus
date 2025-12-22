# Energy balance test
# ===================
#
# Apply 10 kW/m^2 to outer surface of the
# shell and check the increase in temperature at the fluid outlets

T_in = ${fparse 50 + 273.15} # Cold inlet temperature in annulus
mdot = 0.1 # nominal mass flow rate for primary
press = 1e5 # operating pressure

L = 1. # length of pipe

qw = 1e4


[GlobalParams]
  initial_p = ${press}
  closures = thm_closures
  initial_T = ${T_in}
[]

[FluidProperties]
  [fluid] # mimic of water
    type = SimpleFluidProperties
    cv = 4000
  []
  [fluid2] # mimic of water
    type = SimpleFluidProperties
    cv = 40
    thermal_conductivity = 50
  []
[]

[SolidProperties]
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
      m_dot = 0
      input = coaxial/outer:in
  []
  [coaxial]
    type = CoaxialPipe1Phase
    length = ${L}
    n_elems = 100
    orientation = '1 0 0'
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
    inner_tube_Hw = 1e4
    outer_tube_Hw = 1e4
    outer_shell_Hw = 1e4
    inner_fp = fluid
    outer_fp = fluid2
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
  [heat_flux]
    type = HSBoundaryHeatFlux
    boundary = coaxial/shell:outer
    hs = coaxial/shell
    q = ${qw}
  []
[]


[Postprocessors]
  [T_outlet_outer]
    type = SideAverageValue
    boundary = coaxial/outer:out
    variable = T
  []
  [T_outlet_inner]
    type = SideAverageValue
    boundary = coaxial/inner:out
    variable = T
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

  dt = 0.25
  end_time = 4000

  line_search = basic
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-6
  nl_max_its = 25
  automatic_scaling = true
  steady_state_detection = true
  steady_state_tolerance = 2.e-7
[]

[Outputs]
  exodus = false
  csv = true
  [console]
    type = Console
    max_rows = 1
    execute_postprocessors_on = FINAL
    outlier_variable_norms = false
  []
  print_linear_residuals = false
[]
