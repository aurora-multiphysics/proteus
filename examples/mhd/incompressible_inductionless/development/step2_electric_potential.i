U_AVG = 1

[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 50
    ny = 20
    nz = 10
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 1
    zmin = -1
    zmax = 1
  []
[]

[Variables]
  [electricPotential]
    family = LAGRANGE
  []
[]

[AuxVariables]
  [magneticField]
    order = FIRST
    family = LAGRANGE_VEC
  []
  [velocity]
    order = FIRST
    family = LAGRANGE_VEC
  []
[]

[Kernels]
  [diffusion]
    type = ADDiffusion
    variable = electricPotential
  []
  [epotProduction]
    type = IRMINSADElectricPotentialProduction
    variable = electricPotential
    velocity = velocity
    magneticField = magneticField
  []
[]

[Functions]
  [magneticFieldFunction]
    type = ParsedVectorFunction
    expression_x = '0'
    expression_y = '20'
    expression_z = '0'
  []
  [velocityFunction]
    type = ParsedVectorFunction
    symbol_names = 'y_max z_max'
    symbol_values = '1     1'
    expression_x = '(9/4) * ${U_AVG} * (1 - (y * y) / (y_max * y_max)) * (1 - (z * z) / (z_max * z_max))'
    expression_y = '0'
    expression_z = '0'
  []
[]

[AuxKernels]
  [magneticFieldKernel]
    type = VectorFunctionAux
    variable = magneticField
    function = magneticFieldFunction
    execute_on = INITIAL
  []
  [velocityKernel]
    type = VectorFunctionAux
    variable = velocity
    function = velocityFunction
    execute_on = INITIAL
  []
[]

[BCs]
  [inlet]
    type = NeumannBC
    variable = electricPotential
    boundary = left
    value = 0
  []
  [outlet]
    type = NeumannBC
    variable = electricPotential
    boundary = right
    value = 0
  []
  [topWall]
    type = NeumannBC
    variable = electricPotential
    boundary = top
    value = 0
  []
  [bottomWall]
    type = NeumannBC
    variable = electricPotential
    boundary = bottom
    value = 0
  []
  [frontWall]
    type = NeumannBC
    variable = electricPotential
    boundary = front
    value = 0
  []
  [backWall]
    type = NeumannBC
    variable = electricPotential
    boundary = back
    value = 0
  []
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
[]
