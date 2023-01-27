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
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  automatic_scaling = true

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
  execute_on = nonlinear
[]
