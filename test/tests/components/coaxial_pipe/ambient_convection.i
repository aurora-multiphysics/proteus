# Ambient convection correlation test

T_solid = 350
T_ambient = 300

[GlobalParams]
  initial_p = 1e5
  initial_T = ${T_solid}
  initial_vel = 0.1
  closures = thm_closures
  fp = fluid
[]

[FluidProperties]
  [fluid]
    type = SimpleFluidProperties
    cv = 4000
  []
[]

[SolidProperties]
  [solid]
    type = ThermalFunctionSolidProperties
    cp = 500
    k = 10
    rho = 1000
  []
[]

[Closures]
  [thm_closures]
    type = Closures1PhaseTHM
  []
[]

[Components]
  [inlet_inner]
    type = InletMassFlowRateTemperature1Phase
    T = ${T_solid}
    m_dot = 0.1
    input = coaxial/inner:in
  []
  [inlet_outer]
    type = InletMassFlowRateTemperature1Phase
    T = ${T_solid}
    m_dot = 0.1
    input = coaxial/outer:in
  []
  [coaxial]
    type = CoaxialPipe1Phase
    position = '0 0 0'
    orientation = '1 0 0'
    length = '0.4 0.6'
    n_elems = '1 1'
    axial_region_names = 'section_1 section_2'

    tube_inner_radius = 0.025
    tube_names = tube
    tube_widths = 0.025
    tube_materials = solid
    tube_n_elems = 1
    tube_T_ref = ${T_solid}

    shell_inner_radius = 0.075
    shell_names = shell
    shell_widths = 0.025
    shell_materials = solid
    shell_n_elems = 1
    shell_T_ref = ${T_solid}

    use_ambient_convection = true
    T_ambient = ${T_ambient}
  []
  [outlet_inner]
    type = Outlet1Phase
    input = coaxial/inner:out
    p = 1e5
  []
  [outlet_outer]
    type = Outlet1Phase
    input = coaxial/outer:out
    p = 1e5
  []
[]

[Postprocessors]
  [Ra]
    type = ADElementExtremeFunctorValue
    functor = Ra
    block = coaxial/shell:shell
    execute_on = INITIAL
  []
  [Nu]
    type = ADElementExtremeFunctorValue
    functor = Nu
    block = coaxial/shell:shell
    execute_on = INITIAL
  []
  [Hw]
    type = ADElementExtremeFunctorValue
    functor = Hw
    block = coaxial/shell:shell
    execute_on = INITIAL
  []
[]

[Problem]
  solve = false
[]

[Executioner]
  type = Steady
[]

[Outputs]
  csv = true
  execute_on = INITIAL
  show = 'Ra Nu Hw'
[]
