U_AVG = 1

[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 25
    ny = 10
    nz = 10
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 1
    zmin = -1
    zmax = 1
    elem_type = HEX20
  []
[]

[Variables]
  [velocity]
    family = LAGRANGE_VEC
    order = SECOND
  []
  [pressure]
  []
[]

[ICs]
  [velocity]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = 1e-15
    z_value = 1e-15
    variable = velocity
  []
[]

[Functions]
  [velocityInlet]
    type = ParsedVectorFunction
    vars = 'y_max z_max'
    vals = '1     1'
    value_x = '(9/4) * ${U_AVG} * (1 - (y * y) / (y_max * y_max)) * (1 - (z * z) / (z_max * z_max))'
    value_y = '0'
    value_z = '0'
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
    prop_names = 'rho mu'
    prop_values = '1  1'
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
    integrate_p_by_parts = true
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
  nl_max_its = 150
  automatic_scaling = true
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
[]

[Outputs]
  exodus = true
[]
