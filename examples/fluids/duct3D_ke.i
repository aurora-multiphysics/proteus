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

[Variables]
  [velocity]
    order = FIRST
    family = LAGRANGE_VEC
  []
  [p]
  []
  [k]
  []
  [epsilon]
  []
[]

[ICs]
  [velocity_ic]
    type = VectorFunctionIC
    function_x = '1.5*2.25*(1-(y-0.005)^2/0.005^2)*(1-(z-0.01)^2/0.01^2)'
    variable = velocity
  []
  [k_ic]
    type = ConstantIC
    variable = k
    value = 1.71e-3 # 1% TI
  []
  [eps_ic]
    type = ConstantIC
    variable = epsilon
    value = 2.63 # 10% TVR
  []
[]

[Kernels]
  [mass]
    type = INSADMass
    variable = p
  []
  [mass_pspg]
    type = INSADMassPSPG
    variable = p
  []

  [momentum_advection]
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
    pressure = p
    integrate_p_by_parts = false
  []
  [supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  []

  [k_adv]
    type = INSADScalarAdvection
    variable = k
    velocity = velocity
  []
  [k_diff]
    type = INSADScalarDiffusion
    variable = k
    sigma = 1.0
  []
  [k_prod]
    type = INSADKProduction
    variable = k
    velocity = velocity
  []
  [k_diss]
    type = INSADKDissipation
    variable = k
    epsilon = epsilon
  []

  [eps_adv]
    type = INSADScalarAdvection
    variable = epsilon
    velocity = velocity
  []
  [eps_diff]
    type = INSADScalarDiffusion
    variable = epsilon
    sigma = 1.3
  []
  [eps_prod]
    type = INSADEpsilonProduction
    variable = epsilon
    velocity = velocity
    k = k
  []
  [eps_diss]
    type = INSADEpsilonDissipation
    variable = epsilon
    k = k
  []
[]

[BCs]
  [no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'top bottom front back'
    values = '0 0 0'
  []
  [inlet_bc]
    type = ADVectorFunctionDirichletBC
    variable = velocity
    boundary = 'left'
    function_x = '1.5*2.25*(1-(y-0.005)^2/0.005^2)*(1-(z-0.01)^2/0.01^2)'
  []
  [outlet_bc]
    type = ADDirichletBC
    variable = p
    boundary = 'right'
    value = 0
  []

  [inlet_k]
    type = ADDirichletBC
    variable = k
    boundary = 'left'
    value = 1.71e-3
  []
  [inlet_eps]
    type = ADDirichletBC
    variable = epsilon
    boundary = 'left'
    value = 2.63
  []
  [walls_k]
    type = ADDirichletBC
    variable = k
    boundary = 'top bottom front back'
    value = 0
  []
  [walls_eps]
    type = ADDirichletBC
    variable = epsilon
    boundary = 'top bottom front back'
    value = 0
  []
[]

[Materials]
  [water]
    type = INSADKEpsilonMaterial
    k = k
    epsilon = epsilon
    mu = 0.001
    rho = 1000
  []
  [insad]
   type = INSADTauMaterial
    pressure = p
    velocity = velocity
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
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre    euclid'
[]

[Outputs]
  [out]
    type = Exodus
    execute_on = 'initial failed final'
  []
[]
