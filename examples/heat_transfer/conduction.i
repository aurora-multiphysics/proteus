[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 200
  ny = 10
  nz = 20
  xmax = 0.20
  ymax = 0.01
  zmax = 0.02
[]

[Variables]
  [T]
    [InitialCondition]
      type = ConstantIC
      value = 2
    []
  []
[]

[Kernels]
  [conduction]
    type = HeatConduction
    variable = T
  []

  [conduction_time]
    type = HeatConductionTimeDerivative
    variable = T
    specific_heat_dT = specific_heat_dT
    density_name_dT = density_dT
  []
[]

[ICs]
[]

[BCs]
  [hot]
    type = DirichletBC
    variable = T
    boundary = 'left'
    value = 4
  []
  [cold]
    type = DirichletBC
    variable = T
    boundary = 'right'
    value = 1
  []
[]

[Functions]
  [spheat]
    type = ParsedFunction
    expression = 't^4'
  []
  [thcond]
    type = ParsedFunction
    expression = 'exp(t)'
  []
[]

[Materials]
  [constant]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = thcond
    specific_heat_temperature_function = spheat
    temp = T
  []
  [density]
    type = ParsedMaterial
    property_name = density
    coupled_variables = T
    expression = 'T^3 + 2/T'
  []
  [density_dT]
    type = ParsedMaterial
    property_name = density_dT
    coupled_variables = T
    expression = '3 * T^2 - 2/T/T'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  num_steps = 100
  dt = 0.1
  dtmin = 0.1
  nl_max_its = 10
  l_max_its = 100
  nl_abs_tol = 1e-8
[]

[Outputs]
  [out]
    type = Exodus
    execute_on = 'initial failed final'
  []
[]
