sigma = 1

U_AVG = 1

N_X = 50
N_Y_half = 20
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
  [velocity]
    family = LAGRANGE_VEC
    order = SECOND
  []
  [pressure]
    family = LAGRANGE
    order = FIRST
  []
  [currentDensity]
    family = RAVIART_THOMAS
    order = FIRST
  []
  [electricPotential]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[ICs]
  [velocityIC]
    # type = VectorConstantIC
    # x_value = ${U_AVG}
    # y_value = 1e-15
    # z_value = 1e-15
    type = VectorFunctionIC
    function = velocityFunction
    variable = velocity
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
  [momentum_lorentz]
    type = IMHDADMomentumLorentz
    variable = velocity
    currentDensity = currentDensity
    magneticFieldFunction = magneticFieldFunction
  []

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
    magneticFieldFunction = magneticFieldFunction
  []

  [divergenceFree]
    type = DivField
    variable = electricPotential
    coupled_vector_variable = currentDensity
  []
[]

[BCs]
  [inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = left
    function = velocityFunction
  []
  [no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'top bottom front back'
    values = '0 0 0'
  []
  [pressure_set]
    type = PenaltyDirichletBC
    variable = pressure
    value = 0
    boundary = 'right'
    penalty = 1e5
  []
  [current_wall_normal]
    # Setting J.n=0 on the walls, inlet and outlet.
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
    prop_names = 'rho mu conductivity'
    prop_values = '1  1  ${sigma}'
  []
  [ins_mat]
    type = INSADTauMaterial
    velocity = velocity
    pressure = pressure
  []
[]

[Preconditioning]
  active = 'SMP'
  # active = 'FSP'
  [SMP]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type'
    petsc_options_value = ' lu'
  []
  [FSP]
    type = FSP
    topsplit = 'splitting'
    [splitting]
      splitting = 'velocity pressure currentDensity electricPotential'
      splitting_type = additive
    []
    [velocity]
      vars = 'velocity'
      petsc_options_iname = '-pc_type'
      petsc_options_value = ' cholesky'
    []
    [pressure]
      vars = 'pressure'
      petsc_options_iname = '-pc_type'
      petsc_options_value = ' cholesky'
    []
    [currentDensity]
      vars = 'currentDensity'
      petsc_options_iname = '-pc_type'
      petsc_options_value = ' cholesky'
    []
    [electricPotential]
      vars = 'electricPotential'
      petsc_options_iname = '-pc_type'
      petsc_options_value = ' cholesky'
    []
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  automatic_scaling = false
  l_max_its = 1000
  nl_max_its = 1000
[]

[Outputs]
  exodus = true
  execute_on = 'NONLINEAR'
[]
