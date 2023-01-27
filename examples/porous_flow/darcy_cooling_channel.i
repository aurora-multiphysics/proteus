[Mesh]
  [mesh]
    type = FileMeshGenerator
    file = cooling_channel.e
    show_info = true
  []
[]

[Variables]
  [pressure]
  []
  [temperature]
    initial_condition = 0
  []
[]

[AuxVariables]
  [velocity]
    order = CONSTANT
    family = MONOMIAL_VEC
  []
[]

[Kernels]
  [darcy_pressure]
    type = DarcyPressure
    variable = pressure
  []
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
  []
  [heat_convection]
    # this is the problematic kernel
    # but it's also the one that advects heat with the fluid
    # maybe the outlet condition is the problem?
    type = DarcyAdvection
    variable = temperature
    pressure = pressure
  []
  [heat_source]
    type = ADMatHeatSource
    variable = temperature
    material_property = volumetric_heat
    block = 1
  []
[]

[AuxKernels]
  [velocity]
    type = DarcyVelocity
    variable = velocity
    execute_on = nonlinear
    pressure = pressure
  []
[]

[BCs]
  [inlet]
    type = NeumannBC
    variable = pressure
    boundary = Inlet
    value = 0.2
  []
  [walls_pressure]
    type = NeumannBC
    variable = pressure
    boundary = Walls
    value = 0
  []
  [outlet]
    type = DirichletBC
    variable = pressure
    boundary = Outlet
    value = 0
  []
  [inlet_temperature]
    type = DirichletBC
    variable = temperature
    boundary = Inlet
    value = 0
  []
  [walls_temperature]
    type = NeumannBC
    variable = temperature
    boundary = Walls
    value = 0
  []
  [outlet_temperature]
    type = HeatConductionOutflow
    variable = temperature
    boundary = Outlet
  []
[]

[Materials]
  [fluid_region]
    type = ADGenericConstantMaterial
    prop_names = 'density permeability  viscosity thermal_conductivity  specific_heat   porosity'
    prop_values = '1000   2.5e-5        0.001     0.6                   4200            1'
    block = 3
  []
  [solid_region]
    type = ADGenericConstantMaterial
    prop_names = 'density permeability  viscosity thermal_conductivity  specific_heat   porosity'
    prop_values = '7800   2.5e-11       0.001     44                    460             1'
    block = '1 6 7'
  []
  [heat_source]
    type = ADGenericConstantMaterial
    prop_names = 'volumetric_heat'
    prop_values = '200e3'
    block = 1
  []
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  automatic_scaling = true

  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre boomeramg'

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'ilu' # works
[]

[Outputs]
  exodus = true
  execute_on = nonlinear
[]
