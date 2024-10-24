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

[Variables]
  [velocity_x]
    family = LAGRANGE
    order = SECOND
  []
  [velocity_y]
    family = LAGRANGE
    order = SECOND
  []
  [velocity_z]
    family = LAGRANGE
    order = SECOND
  []
  [pressure]
    family = MONOMIAL
    order = FIRST
  []
[]

[ICs]
  [velocityIC_x]
    type = ConstantIC
    value = ${U_AVG}
    variable = velocity_x
  []
  [velocityIC_y]
    type = ConstantIC
    value = 1e-15
    variable = velocity_y
  []
  [velocityIC_z]
    type = ConstantIC
    value = 1e-15
    variable = velocity_z
  []
[]

[Functions]
  [velocityInlet]
    type = ParsedFunction
    symbol_names = 'y_max z_max'
    symbol_values = '1     1'
    expression = '(9/4) * ${U_AVG} * (1 - (y * y) / (y_max * y_max)) * (1 - (z * z) / (z_max * z_max))'
  []
[]

[BCs]
  [inlet_x]
    type = FunctionDirichletBC
    variable = velocity_x
    boundary = left
    function = velocityInlet
  []
  [inlet_y]
    type = DirichletBC
    variable = velocity_y
    boundary = left
    value = 0.0
  []
  [inlet_z]
    type = DirichletBC
    variable = velocity_z
    boundary = left
    value = 0.0
  []
  [no_slip_x]
    type = DirichletBC
    variable = velocity_x
    boundary = 'top bottom front back'
    value = 0.0
  []
  [no_slip_y]
    type = DirichletBC
    variable = velocity_y
    boundary = 'top bottom front back'
    value = 0.0
  []
  [no_slip_z]
    type = DirichletBC
    variable = velocity_z
    boundary = 'top bottom front back'
    value = 0.0
  []
  # [pressure_set]
  #   type = DirichletBC
  #   variable = pressure
  #   boundary = right
  #   value = 0.0
  # []
  [pressure_set]
    type = PenaltyDirichletBC
    variable = pressure
    value = 0
    boundary = 'right'
    penalty = 1e5
  []
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1  1'
  []
[]

[Kernels]
  [mass]
    type = INSMass
    variable = pressure
    u = velocity_x
    v = velocity_y
    w = velocity_z
    pressure = pressure
  []
  [x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = velocity_x
    u = velocity_x
    v = velocity_y
    w = velocity_z
    pressure = pressure
    component = 0
  []
  [y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = velocity_y
    u = velocity_x
    v = velocity_y
    w = velocity_z
    pressure = pressure
    component = 1
  []
  [z_momentum_space]
    type = INSMomentumLaplaceForm
    variable = velocity_z
    u = velocity_x
    v = velocity_y
    w = velocity_z
    pressure = pressure
    component = 2
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
  automatic_scaling = true
  l_max_its = 1000
  nl_max_its = 1000
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'bjacobi'
[]

[Outputs]
  exodus = true
  execute_on = 'nonlinear'
[]
