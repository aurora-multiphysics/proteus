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

[Functions]
  [potentialGradient]
    type = ParsedFunction
    expression = x
  []
  [currentFlow]
    type = ParsedVectorFunction
    expression_x =  -${sigma}
    expression_y = 0
    div = 0
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

  [divergenceFree]
    type = DivField
    variable = electricPotential
    coupled_vector_variable = currentDensity
  []
[]

[BCs]
  [electricPotentialWall]
    type = FunctionPenaltyDirichletBC
    variable = electricPotential
    function = potentialGradient
    penalty = 1e5
    boundary = 'left right top bottom'
  []
[]

[ICs]
  [start]
    type = FunctionIC
    variable = electricPotential
    function = potentialGradient
  []
[]

[Postprocessors]
  [L2Error]
    type = ElementVectorL2Error
    variable = currentDensity
    function = currentFlow
  []
  [HDivSemiError]
    type = ElementHDivSemiError
    variable = currentDensity
    function = currentFlow
  []
  [HDivError]
    type = ElementHDivError
    variable = currentDensity
    function = currentFlow
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