[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 108
  ny = 22
  nz = 22
  xmax = 0.10
  ymax = 0.01
  zmax = 0.02
  elem_type = HEX20
  displacements = 'disp_x disp_y disp_z'
[]

[Variables]
  [./disp_x]
    order = SECOND
    family = LAGRANGE
  [../]
  [./disp_y]
    order = SECOND
    family = LAGRANGE
  [../]
  [./disp_z]
    order = SECOND
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'disp_x disp_y disp_z'
  [../]
[]

[AuxVariables]
  [./von_mises]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./von_mises_kernel]
    type = RankTwoScalarAux
    variable = von_mises
    rank_two_tensor = stress
    execute_on = timestep_end
    scalar_type = VonMisesStress
  [../]
[]

[BCs]
  [./anchor_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'left right'
    value = 0.0
  [../]
  [./anchor_y]
    type = DirichletBC
    variable = disp_y
    boundary = left
    value = 0.0
  [../]
  [./displace_y]
    type = DirichletBC
    variable = disp_y
    boundary = right
    value = -0.01
  [../]
  [./anchor_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'left right'
    value = 0.0
  [../]
[]

[Materials]
  active = 'density_steel stress strain elasticity_tensor_steel'
  [./elasticity_tensor_steel]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200e9
    poissons_ratio = 0.3
  [../]
  [./strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
  [./density_steel]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '7800'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre    boomeramg'
[]

[Outputs]
  [out]
    type = Exodus
    execute_on = 'initial final'
  []
[]
