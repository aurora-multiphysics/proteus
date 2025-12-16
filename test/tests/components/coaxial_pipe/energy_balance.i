T_c = ${fparse 50 + 273.15} # Cold inlet temperature in annulus

mdot = 0.1 # nominal mass flow rate for primary
press = 1e5 # operating pressure

L = 1. # length of pipe



[GlobalParams]
  initial_p = ${press}
  initial_vel = 2
  closures = thm_closures
  verbose = true
[]

# properties come from https://www-pub.iaea.org/MTCD/Publications/PDF/IAEA-THPH_web.pdf
# Taking average of properties at 6MPa and 8MPa
[FluidProperties]
  [he]
    type = SimpleFluidProperties
  []
[]

[SolidProperties]
  [steel]
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

[Functions]
  [k_eff_tube]
    type = PiecewiseLinear
    x = '273.15 ${fparse 273.15+150} ${fparse 273.15+250} ${fparse 273.15+350} ${fparse 273.15+450} ${fparse 273.15+550} ${fparse 273.15+650} ${fparse 273.15+1000}'
    y = '0.32 0.32 0.36 0.41 0.45 0.50 0.54 0.54'
    extrap = false # We could get this to extrapolate
  []
  [k_fiberfrax]
    type = PiecewiseLinear
    x = '273.15 ${fparse 273.15+600} ${fparse 273.15+800} ${fparse 273.15+1000}'
    y = '0.11 0.11 0.16 0.21'
    extrap = false # We could get this to extrapolate
  []
  [k_prorox]
    type = PiecewiseLinear
    x = '273.15 ${fparse 273.15+50} ${fparse 273.15+200} ${fparse 273.15+400} ${fparse 273.15+640}'
    y = '0.039 0.039 0.062 0.112 0.213'
  []
[]

[Components]
  [inlet_inner]
      type = InletMassFlowRateTemperature1Phase
      T = ${T_c}
      m_dot = ${mdot}
      input = coaxial/inner:in
  []

  [outlet_inner]
      type =Outlet1Phase
      input = coaxial/inner:out
      p = ${press}
  []
  [inlet_outer]
      type = InletMassFlowRateTemperature1Phase
      T = ${T_c}
      m_dot = ${mdot}
      input = coaxial/outer:in
  []
  [coaxial]
    type = CoaxialPipe1Phase
    length = ${L}
    n_elems = 100
    orientation = '1 0 0'
    position = '0 0 0'
    shell_inner_radius = 0.075
    shell_materials = 'steel'
    shell_n_elems = '10'
    shell_names = 'shell'
    shell_widths = '0.025'
    shell_T_ref = '${T_c}'
    tube_T_ref = ${T_c}
    tube_inner_radius = 0.025
    tube_materials = 'steel'
    tube_n_elems = '10'
    tube_names = 'tube'
    tube_widths = '0.025'
    inner_fp = he
    outer_fp = he
    shell_initial_T = ${T_c}
    tube_initial_T = ${T_c}
    inner_initial_T = ${T_c}
    outer_initial_T = ${T_c}
  []
  [outlet_outer]
    type =Outlet1Phase
    input = coaxial/outer:out
    p = ${press}
  []
  [convection]
    type = HSBoundaryHeatFlux
    boundary = coaxial/shell:outer
    hs = coaxial/shell
    q = 1e4
  []
[]


[Postprocessors]
  [T_wall]
    type = NodalExtremeValue
    variable = 'T_solid'
    block = 'coaxial/shell:shell'
    value_type = min
  []
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
  end_time = 2000

  line_search = basic
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-4
  nl_abs_tol = 1e-6
  nl_max_its = 25
  automatic_scaling = true
  steady_state_detection = true
  steady_state_tolerance = 2e-7
[]

[Outputs]
  exodus = true
  csv = true
  [console]
    type = Console
    max_rows = 1
    outlier_variable_norms = false
  []
  print_linear_residuals = false
[]
