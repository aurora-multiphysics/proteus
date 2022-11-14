[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 200
    ny = 20
    nz = 20
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 1
    zmin = -1
    zmax = 1
  []
[]

[Variables]
  [velocity]
    family = LAGRANGE_VEC
    order = FIRST
  []
  [pressure]
  []
[]

[ICs]
  [velocity]
    type = VectorConstantIC
    x_value = 1
    y_value = 1e-15
    z_value = 1e-15
    variable = velocity
  []
[]


[Functions]
  [velocityInlet]
  type = ParsedVectorFunction
  vars = 'u_max y_max z_max'
  vals = '2     1     1'
  value_x = 'u_max * (1 - (y*y)/(y_max*y_max))*(1-(z*z)/(z_max*z_max))'
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
    # integrate_p_by_parts = false
  []

  [momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
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
  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre    euclid'
[]

[Outputs]
  exodus = true
[]
