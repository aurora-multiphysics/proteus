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
[]

[ICs]
  [velocity_ic]
    type = VectorFunctionIC
    function_x = '0.05'
    variable = velocity
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
    function_x = '0.05'
  []
  [outlet_bc]
    type = ADDirichletBC
    variable = p
    boundary = 'right'
    value = 0
  []

[]

[Materials]
  [water]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1000 0.001'
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
