U_AVG = 1

[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 50
    ny = 20
    nz = 10
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
    order = FIRST
  []
  # [lorentzForce]
  #   family = LAGRANGE_VEC
  #   order = FIRST
  # []
[]

[AuxVariables]
  [magneticField]
    order = FIRST
    family = LAGRANGE_VEC
  []
  [electricPotential]
    order = FIRST
    family = LAGRANGE
  []
[]

[ICs]
  [velocity]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = 1e-15
    variable = velocity
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
    type = DirichletBC
    variable = pressure
    boundary = right
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

  [lorentz_force]
    type = IRMINSADMomentumLorentzElectrostatic
    variable = velocity
    electricPotential = electricPotential
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
  [epotKernel]
    type = FunctionAux
    variable = electricPotential
    function = epotFunction
    execute_on = INITIAL
  []
[]

[Functions]
  [magneticFieldFunction]
    type = ParsedVectorFunction
    value_x = '0'
    value_y = '20'
    value_z = '0'
  []
  [velocityFunction]
    type = ParsedVectorFunction
    vars = 'y_max z_max'
    vals = '1     1'
    value_x = '(9/4) * ${U_AVG} * (1 - (y * y) / (y_max * y_max)) * (1 - (z * z) / (z_max * z_max))'
    value_y = '0'
    value_z = '0'
  []
  [epotFunction]
    type = ParsedFunction
    value = '20 * z'
  []
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  l_max_its = 100
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre euclid'
[]

[Outputs]
  exodus = true
  execute_on = 'nonlinear'
[]
