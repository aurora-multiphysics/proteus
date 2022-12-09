N_X = 200
N_Y_half = 10
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
    order = FIRST
  []
  [pressure]
  []
[]

[ICs]
  [velocity]
    type = VectorFunctionIC
    variable = velocity
    function = velocityInlet
  []
[]

[Functions]
  [velocityInlet]
    type = ParsedVectorFunction
    vars = 'y_max'
    vals = '1'
    value_x = '(3/2) * ${U_AVG} * (1 - (y * y) / (y_max * y_max))'
    value_y = '0'
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
    boundary = 'top bottom'
    values = '0 0 0'
    []
  [pressure_set]
    type = DirichletBC
    variable = pressure
    boundary = 'right'
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
  l_max_its = 30
  nl_max_its = 150
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre euclid'
[]

[Outputs]
  exodus = true
[]
