[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 50
    ny = 20
    nz = 20
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 1
    zmin = -1
    zmax = 1
    # elem_type = HEX20
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
    order = FIRST
    family = LAGRANGE_VEC
  []
[]

[ICs]
  # [velocityIC]
  #   type = VectorConstantIC
  #   x_value = 1e-15
  #   y_value = 1e-15
  #   variable = velocity
  # []
  [velocityIC]
    type = VectorFunctionIC
    function = velocityFunction
    variable = velocity
  []
  # [epotIC]
  #   type = FunctionIC
  #   function = epotFunction
  #   variable = electricPotential
  # []
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
  [velocity_outlet]
    type = INSADMomentumNoBCBC
    variable = velocity
    pressure = pressure
    boundary = 'right'
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
  [mass_pspg]
    type = INSADMassPSPG
    variable = pressure
  []

  # [momentum_time]
  #   type = INSADMomentumTimeDerivative
  #   variable = velocity
  # []
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
  [momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
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
    vars = 'u_max y_max z_max'
    vals = '2     1     1'
    value_x = 'u_max * (1 - (y*y)/(y_max*y_max))*(1-(z*z)/(z_max*z_max))'
    value_y = '0'
    value_z = '0'
  []
  [magneticFieldFunction]
    type = ParsedVectorFunction
    value_x = '0'
    value_y = '20'
    value_z = '0'
  []
  # [epotFunction]
  #   type = ParsedFunction
  #   value = '-4 * z'
  # []
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Steady
  # type = Transient
  # num_steps = 5
  # dt = 0.5
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
[]

[Outputs]
  exodus = true
  execute_on = 'nonlinear'
[]