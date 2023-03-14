INTEGRATE_BY_PARTS_P = true
U_AVG = 1

N_X = 100
N_Y_half = 20
N_Z_half = 10
ELEMENT_TYPE = HEX8

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
  []
  [meshTop]
    type = StitchedMeshGenerator
    inputs = 'meshTopBack meshTopFront'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'front back'
  []
  [meshBottom]
    type = StitchedMeshGenerator
    inputs = 'meshBottomBack meshBottomFront'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'front back'
  []
  [mesh]
    type = StitchedMeshGenerator
    inputs = 'meshTop meshBottom'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'bottom top'
    show_info = true
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
  [electricPotential]
    family = LAGRANGE
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
  [epot_inlet_output]
    type = NeumannBC
    variable = electricPotential
    boundary = 'left right'
    value = 0
  []
  [epot_insulating_walls]
    type = NeumannBC
    variable = electricPotential
    boundary = 'top bottom front back'
    value = 0
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu  conductivity'
    prop_values = '1  1   1'
  []
  [irmins_mat_tau]
    type = IRMINSADTauMaterial
    velocity = velocity
    pressure = pressure
    magneticField = magneticField
    electricPotential = electricPotential
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

  [momentum_time_derivative]
    type = INSADMomentumTimeDerivative
    variable = velocity
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
  [lorentz_force]
    type = IRMINSADMomentumLorentz
    variable = velocity
  []

  [epot_diffusion]
    type = ADDiffusion
    variable = electricPotential
  []
  [epot_production]
    type = IRMINSADElectricPotentialProduction
    variable = electricPotential
    velocity = velocity
    magneticField = magneticField
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

[Functions]
  [velocityFunction]
    type = ParsedVectorFunction
    vars = 'y_max z_max'
    vals = '1     1'
    value_x = '(9/4) * ${U_AVG} * (1 - (y * y) / (y_max * y_max)) * (1 - (z * z) / (z_max * z_max))'
    value_y = '0'
    value_z = '0'
  []
  [magneticFieldFunction]
    type = ParsedVectorFunction
    value_x = '0'
    value_y = '20'
    value_z = '0'
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
  type = Transient
  dt = 0.005
  start_time = 0.0
  end_time = 0.2
  solve_type = NEWTON
  automatic_scaling = true
  l_max_its = 100
  nl_max_its = 1000
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
[]

[Outputs]
  exodus = true
  execute_on = 'timestep_end'
[]
