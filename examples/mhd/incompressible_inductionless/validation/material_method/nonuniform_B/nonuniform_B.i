INTEGRATE_BY_PARTS_P = true
U_AVG = 0.01

exp_factor = 12.7416
power_exp = -2.7845
B_max = 0.5

[Mesh]
  [mesh]
    type = FileMeshGenerator
    file = nonuniform_B_mesh.e
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
    x_value = 1e-15
    y_value = ${U_AVG}
    z_value = 1e-15
    variable = velocity
  []
[]

[BCs]
  [velocity_inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = inlet
    function = velocityFunction
  []
  [velocity_no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = walls
    values = '0 0 0'
  []
  [pressure_reference]
    type = DirichletBC
    variable = pressure
    boundary = outlet
    value = 0
  []
  [epot_inlet_output]
    type = NeumannBC
    variable = electricPotential
    boundary = 'inlet outlet'
    value = 0
  []
  [epot_insulating_walls]
    type = NeumannBC
    variable = electricPotential
    boundary = 'inlet outlet walls'
    value = 0
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names =  'rho  mu        conductivity'
    prop_values = '870  9.4e-4    2.6e6'
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
    value_x = '0'
    value_y = '${U_AVG}'
    value_z = '0'
  []
  [magneticFieldFunction]
    type = ParsedVectorFunction
    value_x = '0'
    value_y = '0'
    value_z = '${B_max}*pow((1.0 + exp(${exp_factor}*y)), ${power_exp})'
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
  nl_max_its = 1000
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
[]

[Outputs]
  exodus = true
[]
