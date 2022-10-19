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
  []
[]

[Variables]
  [electricPotential]
    family = LAGRANGE
  []
[]

[Kernels]
  [diffusion]
    type = ADDiffusion
    variable = electricPotential
  []
[]

[BCs]
  [inlet]
  type = NeumannBC
  variable = electricPotential
  boundary = left
  value = 0
  []
  [outlet]
  type = NeumannBC
  variable = electricPotential
  boundary = right
  value = 0
  []
  [topWall]
  type = DirichletBC
  variable = electricPotential
  boundary = top
  value = 4000
  []
  [bottomWall]
  type = DirichletBC
  variable = electricPotential
  boundary = bottom
  value = 0
  []
  [frontWall]
  type = NeumannBC
  variable = electricPotential
  boundary = front
  value = 0
  []
  [backWall]
    type = NeumannBC
    variable = electricPotential
    boundary = back
    value = 0
  []
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Steady
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
[]
