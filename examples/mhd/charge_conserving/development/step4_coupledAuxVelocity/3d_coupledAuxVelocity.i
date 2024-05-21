sigma = 1

U_AVG = 1

N_X = 50
N_Y_half = 10
N_Z_half = 10
ELEMENT_TYPE = HEX27

GRADING_R_Y = 5
GRADING_R_Z = 5
RATIO_Y_FWD = ${fparse GRADING_R_Y ^ (1/(N_Y_half - 1))}
RATIO_Y_INV = ${fparse 1/RATIO_Y_FWD}
RATIO_Z_FWD = ${fparse GRADING_R_Z ^ (1/(N_Z_half - 1))}
RATIO_Z_INV = ${fparse 1/RATIO_Z_FWD}

[Mesh]
  [meshTopBack]
    type = GeneratedMeshGenerator
    dim = 3
    nx = ${N_X}
    ny = ${N_Y_half}
    nz = ${N_Z_half}
    xmin = 0
    xmax = 20
    ymin = 0
    ymax = 1
    zmin = -1
    zmax = 0
    bias_y = ${RATIO_Y_INV}
    bias_z = ${RATIO_Z_FWD}
    elem_type = ${ELEMENT_TYPE}
    boundary_name_prefix = 'meshTopBack'
  []
  [meshTopFront]
    type = GeneratedMeshGenerator
    dim = 3
    nx = ${N_X}
    ny = ${N_Y_half}
    nz = ${N_Z_half}
    xmin = 0
    xmax = 20
    ymin = 0
    ymax = 1
    zmin = 0
    zmax = 1
    bias_y = ${RATIO_Y_INV}
    bias_z = ${RATIO_Z_INV}
    elem_type = ${ELEMENT_TYPE}
    boundary_name_prefix = 'meshTopFront'
  []
  [meshBottomBack]
    type = GeneratedMeshGenerator
    dim = 3
    nx = ${N_X}
    ny = ${N_Y_half}
    nz = ${N_Z_half}
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 0
    zmin = -1
    zmax = 0
    bias_y = ${RATIO_Y_FWD}
    bias_z = ${RATIO_Z_FWD}
    elem_type = ${ELEMENT_TYPE}
    boundary_name_prefix = 'meshBottomBack'
  []
  [meshBottomFront]
    type = GeneratedMeshGenerator
    dim = 3
    nx = ${N_X}
    ny = ${N_Y_half}
    nz = ${N_Z_half}
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 0
    zmin = 0
    zmax = 1
    bias_y = ${RATIO_Y_FWD}
    bias_z = ${RATIO_Z_INV}
    elem_type = ${ELEMENT_TYPE}
    boundary_name_prefix = 'meshBottomFront'
  []
  [meshTop]
    type = StitchedMeshGenerator
    inputs = 'meshTopBack meshTopFront'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'meshTopBack_front meshTopFront_back'
  []
  [renameMeshTop]
    type = RenameBoundaryGenerator
    input = meshTop
    old_boundary = '
      meshTopBack_top meshTopFront_top
      meshTopBack_right meshTopFront_right
      meshTopBack_left meshTopFront_left
      meshTopBack_bottom meshTopFront_bottom
    '
    new_boundary = '
      top top
      meshTop_right meshTop_right
      meshTop_left meshTop_left
      meshTop_bottom meshTop_bottom
    '
  []
  [meshBottom]
    type = StitchedMeshGenerator
    inputs = 'meshBottomBack meshBottomFront'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'meshBottomBack_front meshBottomFront_back'
  []
  [renameMeshBottom]
    type = RenameBoundaryGenerator
    input = meshBottom
    old_boundary = '
      meshBottomBack_top meshBottomFront_top
      meshBottomBack_right meshBottomFront_right
      meshBottomBack_left meshBottomFront_left
      meshBottomBack_bottom meshBottomFront_bottom
    '
    new_boundary = '
      meshBottom_top meshBottom_top
      meshBottom_right meshBottom_right
      meshBottom_left meshBottom_left
      bottom bottom
    '
  []
  [mesh]
    type = StitchedMeshGenerator
    inputs = 'renameMeshTop renameMeshBottom'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'meshTop_bottom meshBottom_top'
  []
  [renameMesh]
    type = RenameBoundaryGenerator
    input = mesh
    old_boundary = '
      meshBottomFront_front meshTopFront_front
      meshBottomBack_back meshTopBack_back
      meshBottom_left meshTop_left
      meshBottom_right meshTop_right
    '
    new_boundary = '
      front front
      back back
      left left
      right right
    '
  []
[]

[Functions]
  [velocityFunction]
    type = ParsedVectorFunction
    symbol_names = 'y_max z_max'
    symbol_values = '1     1'
    expression_x = '(9/4) * ${U_AVG} * (1 - (y * y) / (y_max * y_max)) * (1 - (z * z) / (z_max * z_max))'
    expression_y = '0'
    expression_z = '0'
  []
  [magneticFieldFunction]
    type = ParsedVectorFunction
    expression_x = '0'
    expression_y = '20'
    expression_z = '0'
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

[AuxVariables]
  [velocity]
    family = LAGRANGE_VEC
    order =  FIRST
  []
  [magneticField]
    family = LAGRANGE_VEC
    order = FIRST
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
  [currentDensityCoupling]
    type = IMHDADCurrentUxB
    variable = currentDensity
    velocity = velocity
    magneticField = magneticField
  []

  [divergenceFree]
    type = DivField
    variable = electricPotential
    coupled_vector_variable = currentDensity
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
  [current_wall_normal]
    # Trying to set J.n=0 on the walls.
    # Not sure this is the correct BC to use;
    # name suggests it is setting divJ=0 rather than J.n=0,
    # but divJ=0 is enforced by the equations
    # and having this BC gives a J field that looks right qualitatively
    type = VectorDivPenaltyDirichletBC
    variable = currentDensity
    function_x = 0
    function_y = 0
    function_z = 0
    penalty = 1e7
    boundary = 'front back left right top bottom'
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
  l_max_its = 1000
  nl_max_its = 1000
  petsc_options_iname = '-pc_type'
  petsc_options_value = ' cholesky'
[]

[Outputs]
  exodus = true
  execute_on = 'NONLINEAR'
[]