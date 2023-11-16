N_X = 100
N_Y_half = 20
N_Z_half = 10

INTEGRATE_BY_PARTS_P = true
ELEMENT_TYPE = HEX8
U_AVG = 1

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
    bias_y = 0.8
    bias_z = 1.25
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
    bias_y = 0.8
    bias_z = 0.8
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
    bias_y = 1.25
    bias_z = 1.25
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
    bias_y = 1.25
    bias_z = 0.8
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
  [velocity]
    family = LAGRANGE_VEC
    order = FIRST
  []
  [pressure]
    family = LAGRANGE
    order = FIRST
  []
[]

[ICs]
  [velocityIC]
    type = VectorConstantIC
    x_value = ${U_AVG}
    y_value = 1e-15
    z_value = 1e-15
    variable = velocity
  []
[]

[BCs]
  [velocity_inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = left
    function = velocityFunction
  []
  [velocity_no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'top bottom front back'
    values = '0 0 0'
  []
  [pressure_reference]
    type = DirichletBC
    variable = pressure
    boundary = right
    value = 0
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1  1'
  []
  [ins_mat_tau]
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
  [mass_pspg]
    type = INSADMassPSPG
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
    integrate_p_by_parts = ${INTEGRATE_BY_PARTS_P}
  []
  [momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
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
  l_max_its = 100
  nl_max_its = 150
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
[]

[Outputs]
  exodus = true
  execute_on = 'nonlinear'
[]
