[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 200
  ny = 10
  nz = 20
  xmax = 0.20
  ymax = 0.01
  zmax = 0.02
[]

[GlobalParams]
  gravity = '0 0 0'
  supg = true
  pspg = true
  integrate_p_by_parts = false
[]

[Variables]
  [u_x]
    [InitialCondition]
      type = ConstantIC
      value = 0.05
    []
  []
  [u_y]
  []
  [u_z]
  []
  [p]
  []
[]

[Kernels]
  [mass]
    type = INSMass
    variable = p
    u = u_x
    v = u_y
    w = u_z
    pressure = p
  []

  [x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = u_x
    u = u_x
    v = u_y
    w = u_z
    pressure = p
    component = 0
  []

  [y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = u_y
    u = u_x
    v = u_y
    w = u_z
    pressure = p
    component = 1
  []

  [z_momentum_space]
    type = INSMomentumLaplaceForm
    variable = u_z
    u = u_x
    v = u_y
    w = u_z
    pressure = p
    component = 2
  []

[]

[ICs]
[]

[BCs]
  [x_walls]
    type = DirichletBC
    variable = u_x
    boundary = 'top bottom front back'
    value = 0.0
  []
  [y_walls]
    type = DirichletBC
    variable = u_y
    boundary = 'left right top bottom front back'
    value = 0.0
  []
  [z_walls]
    type = DirichletBC
    variable = u_z
    boundary = 'left right top bottom front back'
    value = 0.0
  []
  [inlet_bc]
    type = DirichletBC
    variable = u_x
    boundary = 'left'
    value = 0.05
  []
  [outlet_bc]
    type = DirichletBC
    variable = p
    boundary = 'right'
    value = 0
  []
[]

[Materials]
  [water]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1000 0.001'
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
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'ilu'
  l_max_its = 30
  automatic_scaling = true
[]

[Outputs]
  [out]
    type = Exodus
    execute_on = 'initial failed final'
  []
[]
