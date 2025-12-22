# Counterflowing coaxial pipe
#
# This example shows a coaxial pipe with counterflowing core and annulus with the shell having
# three layers of insulations. The working fluid is Helium, modelled as an ideal gas. Heat loss
# to the environment is modelled using ambient convection Nusselt number correlation.

T_h = ${fparse 850 + 273.15} # Hot inlet temperature in centre
T_c = ${fparse 450 + 273.15} # Cold inlet temperature in annulus
T_a = ${fparse 25 + 273.15}

mdot = 0.5 # nominal mass flow rate for each
press = 7e6 # operating pressure

D_h = 0.1 # diameter of core pipe

Dc_o = 0.25 # outer diameter of annulus
Dc_i = 0.15 # inner diameter of annulus

L = 2. # length of pipe
shell_layer_thickness = 0.025

# Total diameter of coaxial pipe
Do_coaxial = ${fparse Dc_o + 3*shell_layer_thickness}

# Prandtl number of ideal gas
Pr = 0.7

[GlobalParams]
  initial_p = ${press}
  initial_vel = 2
  closures = thm_closures
  verbose = true
  fp = he
[]

# properties come from https://www-pub.iaea.org/MTCD/Publications/PDF/IAEA-THPH_web.pdf
# Taking average of properties at 6MPa and 8MPa
[FluidProperties]
  [he]
    type = IdealGasFluidProperties
    gamma = 1.6
    k = 0.33
    molar_mass = 0.004
    mu = 0.00003579
  []
[]

# Use correlation for ambient heat convection based on Rayleigh number and properties for air.
# See https://volupe.com/support/empirical-correlations-for-convective-heat-transfer-coefficients/
[Functions]
  [Ra_cylinder]
    type = ParsedFunction
    expression = '(rho*beta*(Th-Ta)*D*D*D*g)/(mu*k/(rho*cp))'
    symbol_names = "rho beta Ta Th D g mu k cp"
    symbol_values = '1.2 ${fparse 1./298} ${T_a} T_wall ${Do_coaxial} 9.81 1.823e-05 0.02568 1003.413793'
  []
  [Nu_cylinder]
    type = ParsedFunction
    expression = 'pow(0.6 + (0.387*pow(Ra,1./6.))/pow(1 + pow(0.559/Pr,9./16.),8/27), 2)'
    symbol_names = "Ra Pr"
    symbol_values = "Ra_cylinder ${Pr}"
  []
  [h_cylinder]
    type = ParsedFunction
    # assume Nu = 10 for now
    symbol_names =  'Nu k L'
    symbol_values = 'Nu_cylinder 0.02568 ${Do_coaxial}'
    expression = Nu*k/L
  []
[]

# record wall temperature in outer insulation layer
[Postprocessors]
  [T_wall]
    type = NodalExtremeValue
    variable = 'T_solid'
    block = 'coaxial/shell:insul2'
    value_type = min
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[SolidProperties]
  [tube_material] # between core and annulus
    type = ThermalFunctionSolidProperties
    cp = 5193
    k = 0.4
    rho = 4.6
  []
  [steel] # first layer of shell insulation
    type = ThermalSS316Properties
  []
  [insul1] # second layer of shell insulation
    type = ThermalFunctionSolidProperties
    cp = 1140
    k = 0.16
    rho = 160
  []
  [insul2] # third layer of shell insulation
    type = ThermalFunctionSolidProperties
    cp = 840
    k = 0.1
    rho = 80
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
      T = ${T_h}
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
      input = coaxial/outer:out
  []
  [coaxial]
    type = CoaxialPipe1Phase
    length = ${L}
    n_elems = 20
    orientation = '1 0 0'
    position = '0 0 0'
    shell_inner_radius = ${fparse 0.5*Dc_o}
    shell_materials = 'steel insul1 insul2'
    shell_n_elems = '5 5 5'
    shell_names = 'shell insul1 insul2'
    shell_widths = '${shell_layer_thickness} ${shell_layer_thickness} ${shell_layer_thickness}'
    shell_T_ref = '${T_c} ${T_c} ${T_c}'
    tube_T_ref = ${fparse 0.5*(T_c + T_h)}
    tube_initial_T = ${fparse 0.5*(T_c + T_h)}
    shell_initial_T = ${fparse 0.5*(T_a + T_c)}
    tube_inner_radius = ${fparse 0.5*D_h}
    tube_materials = 'tube_material'
    tube_n_elems = '5'
    tube_names = 'tube'
    tube_widths = '${fparse 0.5*(Dc_i - D_h)}'
    inner_initial_T = ${T_h}
    outer_initial_T = ${T_c}
  []
  [outlet_outer]
    type =Outlet1Phase
    input = coaxial/outer:in
    p = ${press}
  []
  [convection]
    type = HSBoundaryAmbientConvection
    T_ambient = ${fparse 273.15 + 25}
    boundary = coaxial/shell:outer
    hs = coaxial/shell
    htc_ambient = h_cylinder
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

  dt = 0.05
  end_time = 2000

  line_search = basic
  solve_type = NEWTON

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-6
  nl_max_its = 25

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
