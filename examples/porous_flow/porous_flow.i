[Mesh]
  [mesh]
    type = FileMeshGenerator
    file = cooling_channel.e
    show_info = true
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Variables]
  [porepressure]
  []
  # [temperature]
  # []
[]

[PorousFlowBasicTHM] # just fluid, no thermal coupling
  porepressure = porepressure
  coupling_type = Hydro         # change this for thermal coupling
  gravity = '0 0 0'
  fp = the_simple_fluid         # this assumes constant fluid bulk modulus and viscosity
  multiply_by_density = false
[]

[BCs]
  [constant_outlet_pressure]
    type = DirichletBC
    variable = porepressure
    value = 0
    boundary = Outlet
  []
  # [constant_inlet_velocity]
  #   type = NeumannBC
  #   variable = porepressure   # maybe "porepressure" is rescaled somehow?
  #   # value = 0.2               # this seems to give a more correct answer
  #   # # value = 8               # this makes more sense mathematically
  #   value = -8
  #   boundary = Inlet
  # []
  [inlet_source]
    type = PorousFlowSink
    boundary = Inlet
    variable = porepressure
    flux_function = -0.2  # This should be (- density * inlet velocity), but that gives the wrong answer
                          # using velocity here gives the right answer; why???
  []
[]

[FluidProperties]
  [the_simple_fluid] # all placeholder
    type = SimpleFluidProperties
    bulk_modulus = 2E9 # don't have this specified, should drop out
    viscosity = 1.0E-3
    density0 = 1000.0 # this is different in the solid; what impact does this have? Is it a 2-phase flow?
    # should also set various other things: https://mooseframework.inl.gov/moose/source/userobjects/SimpleFluidProperties.html
  []
[]

# blocks:
# 1 = heat source
# 3 = fluid
# 6 = internal solid
# 7 = external solid
# Need differences in k (temperature only), kappa, rho, and cp (temperature only)

[Materials]
  [permeability_fluid]
    type = PorousFlowPermeabilityConst
    block = 3
    permeability = '2.5E-5 0 0   0 2.5E-5 0   0 0 2.5E-5'
  []
  [permeability_solid]
    type = PorousFlowPermeabilityConst
    block = '1 6 7'
    permeability = '2.5E-11 0 0   0 2.5E-11 0   0 0 2.5E-11'
  []
[]

[Preconditioning]
  active = basic
  [basic]
    type = SMP
    full = true
  []
  [preferred_but_might_not_be_installed]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  type = Steady
  solve_type = Newton
  # nl_abs_tol = 1E-13
[]

[Outputs]
  exodus = true
[]