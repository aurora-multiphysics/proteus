N_X = 200
N_Y_half = 10
U_AVG = 1
element_type = 'QUAD9'

[Mesh]
  [meshTop]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${N_X}
    ny = ${N_Y_half}
    xmin = 0
    xmax = 20
    ymin = 0
    ymax = 1
    bias_y = 0.8
    boundary_name_prefix = 'meshTop'
    elem_type = ${element_type}
  []
  [meshBottom]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${N_X}
    ny = ${N_Y_half}
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 0
    bias_y = 1.25
    boundary_name_prefix = 'meshBottom'
    elem_type = ${element_type}
  []
  [meshComplete]
    type = StitchedMeshGenerator
    inputs = 'meshTop meshBottom'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'meshTop_bottom meshBottom_top'
  []
  [meshRename]
    type = RenameBoundaryGenerator
    input = meshComplete
    old_boundary = '
      meshTop_right meshBottom_right
      meshTop_left meshBottom_left
      meshTop_top
      meshBottom_bottom
    '
    new_boundary = '
      right right
      left left
      top
      bottom
    '
  []
[]

[Variables]
  [velocity]
    family = LAGRANGE_VEC
    order = SECOND
  []
  [pressure]
    family = MONOMIAL
    order = FIRST
  []
[]

[AuxVariables]
  [magneticField]
    family = LAGRANGE_VEC
    order = FIRST
  []
[]

[ICs]
  [velocity]
    type = VectorFunctionIC
    variable = velocity
    function = velocityInlet
  []
[]

[Functions]
  [velocityInlet]
    type = ParsedVectorFunction
    symbol_names = 'y_max'
    symbol_values = '1'
    expression_x = '(3/2) * ${U_AVG} * (1 - (y * y) / (y_max * y_max))'
    expression_y = '0'
  []
  [magneticFieldFunction]
    type = ParsedVectorFunction
    expression_x = '0'
    expression_y = '20'
  []
[]

[BCs]
  [inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = left
    function = velocityInlet
  []
  [no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'top bottom'
    values = '0 0 0'
  []
  [pressure_set]
    type = PenaltyDirichletBC
    variable = pressure
    value = 0
    boundary = 'right'
    penalty = 1e5
  []
  # [pressure_set]
  #   type = DirichletBC
  #   variable = pressure
  #   boundary = 'right'
  #   value = 0
  # []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1  1'
  []
  [ins_mat]
    type = INSADTauMaterial
    velocity = velocity
    pressure = pressure
  []
[]

[Kernels]
  [mass]
    type = INSADMass
    variable = pressure
  []

  [momentum_convection]
    type = INSADMomentumAdvection
    variable = velocity
  []

  [momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
  []

  [momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    pressure = pressure
    integrate_p_by_parts = true
  []
[]

[AuxKernels]
  [magneticFieldKernel]
    type = VectorFunctionAux
    variable = magneticField
    function = magneticFieldFunction
    execute_on = INITIAL
  []
[]

[Problem]
  type = FEProblem
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
  l_max_its = 100
  nl_max_its = 1000
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'ilu'
[]

[Outputs]
  exodus = true
[]
