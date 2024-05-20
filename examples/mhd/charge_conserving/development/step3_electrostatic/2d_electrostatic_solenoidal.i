sigma = 1

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 50
    ny = 50
    xmax =  1
    ymax =  1
    xmin = -1
    ymin = -1
    elem_type = QUAD9
  []
[]

[Functions]
  [solenoid]
    type = ParsedVectorFunction
    expression_x =  y
    expression_y = -x
    div = 0
  []
[]

[Variables]
  [currentDensity]
    family = RAVIART_THOMAS
    order = FIRST
  []
  [electricPotential]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[Kernels]
  [currentDensityConductivity]
    type = IMHDADCurrentDensity
    variable = currentDensity
  []
  [electricField]
    type = GradField
    variable = currentDensity
    coupled_scalar_variable = electricPotential
    coeff = -1
  []
  [currentDensitySource]
    type = VectorBodyForce
    variable = currentDensity
    function = solenoid
  []

  [divergenceFree]
    type = DivField
    variable = electricPotential
    coupled_vector_variable = currentDensity
  []
[]

[BCs]
  [current_wall_value]
    type = VectorPenaltyDirichletBC
    variable = currentDensity
    x_exact_sln = ${Functions/solenoid/expression_x}
    y_exact_sln = ${Functions/solenoid/expression_y}
    penalty = 1e3
    boundary = 'left right top bottom'
  []
[]

[Postprocessors]
  [L2Error]
    type = ElementVectorL2Error
    variable = currentDensity
    function = solenoid
  []
  [HDivSemiError]
    type = ElementHDivSemiError
    variable = currentDensity
    function = solenoid
  []
  [HDivError]
    type = ElementHDivError
    variable = currentDensity
    function = solenoid
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names =  'conductivity'
    prop_values = '${sigma}'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = ' bjacobi'
[]

[Outputs]
  exodus = true
  execute_on = 'NONLINEAR'
[]