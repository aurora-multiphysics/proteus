[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 96
  ny = 96
  nz = 96
[]

[Variables]
  [u]
  []
[]

[Functions]
  [bc_func]
    type = ParsedFunction
    expression = "x*x + y*y + z*z - 2"
  []
  [f_func]
    type = ParsedFunction
    expression = "-6"
  []
[]

[Kernels]
  [diff]
    type = Diffusion
    variable = u
  []
  [f]
    type = BodyForce
    variable = u
    function = f_func
  []
[]

[BCs]
  [walls]
    type = FunctionDirichletBC
    variable = u
    boundary = '0 1 2 3 4 5'
    function = bc_func
  []
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = "-pc_type -pc_hypre_type"
  petsc_options_value = "hypre    boomeramg"
[]
