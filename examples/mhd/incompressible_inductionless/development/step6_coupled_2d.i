N_X = 100
N_Y_half = 10
INTEGRATE_BY_PARTS_P = true
ELEMENT_TYPE = QUAD9
U_AVG = 1

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
    elem_type = ${ELEMENT_TYPE}
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
    elem_type = ${ELEMENT_TYPE}
  []
  [meshComplete]
    type = StitchedMeshGenerator
    inputs = 'meshTop meshBottom'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'bottom top'
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
  [electricPotential]
    family = LAGRANGE
    order = FIRST
  []
[]

[AuxVariables]
  [magneticField]
    order = FIRST
    family = LAGRANGE_VEC
  []
[]

[ICs]
  [velocityIC]
    type = VectorConstantIC
    x_value = ${U_AVG}
    y_value = 1e-15
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
    boundary = 'top bottom'
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
    boundary = 'top bottom'
    value = 0
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu  conductivity'
    prop_values = '1  1   1'
  []
  [ins_mat]
    type = INSADMaterial
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
    integrate_p_by_parts = ${INTEGRATE_BY_PARTS_P}
  []
  [lorentz_force_electrostatic]
    type = IRMINSADMomentumLorentzElectrostatic
    variable = velocity
    electricPotential = electricPotential
    magneticField = magneticField
  []
  [lorentz_force_flow]
    type = IRMINSADMomentumLorentzFlow
    variable = velocity
    velocity = velocity
    magneticField = magneticField
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
  petsc_options_value = 'ilu'
[]

[Outputs]
  exodus = true
  execute_on = 'nonlinear'
[]
