[Mesh]
  [mesh]
    type = FileMeshGenerator
    file = cooling_channel.e
    show_info = true
  []
[]

[Variables]
  [temperature]
    initial_condition = 0
  []
[]

[Kernels]
  [heat_conduction]
    type = ADHeatConduction
    variable = temperature
  []
  [heat_source]
    type = ADMatHeatSource
    variable = temperature
    material_property = volumetric_heat
    block = 1
  []
[]

[BCs]
  [inlet_temperature]
    type = DirichletBC
    variable = temperature
    boundary = Inlet
    value = 0
  []
  [walls_temperature] # don't know if this is needed?
    type = NeumannBC
    variable = temperature
    boundary = 'Outlet Walls'
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

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
  execute_on = nonlinear
[]
