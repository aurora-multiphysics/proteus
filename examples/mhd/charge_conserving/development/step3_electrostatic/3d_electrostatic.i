[Mesh]
  [gmg]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 16
    ny = 16
    nz = 16
    xmax =  1
    ymax =  1
    zmax =  1
    xmin = -1
    ymin = -1
    zmin = -1
    elem_type = HEX27
  []
[]

[Variables]
  [currentDensity]
    family = RAVIART_THOMAS
    order = FIRST
  []
  [electricPotential]
    family = MONOMIAL
    order = CONSTANT
    # order = FIRST
  []
[]

[Kernels]
  [currentDensityConductivity]
    type = IMHDADCurrentDensity
    variable = currentDensity
  []
  [electricField]
    type = GradField
    variable = currentDensity
    coupled_scalar_variable = electricPotential
    coeff = -1
  []
  [divergenceFree]
    type = DivField
    variable = electricPotential
    coupled_vector_variable = currentDensity
  []
[]

[BCs]
  # [epot_live]
  #   type = PenaltyDirichletBC
  #   variable = electricPotential
  #   value = 100
  #   boundary = 'left'
  #   penalty = 1e5
  # []
  # [epot_ground]
  #   type = PenaltyDirichletBC
  #   variable = electricPotential
  #   value = 0
  #   boundary = 'right'
  #   penalty = 1e5
  # []
  [current_wall_in]
    type = VectorDivPenaltyDirichletBC
    variable = currentDensity
    function_x = cos(y*3.14159/2)*cos(z*3.14159/2)
    penalty = 1e8
    boundary = 'left'
  []
  [current_wall_out]
    type = VectorDivPenaltyDirichletBC
    variable = currentDensity
    function_x = 0
    penalty = 1e8
    boundary = 'right'
  []
[]

# [Postprocessors]
#   [L2Error]
#     type = ElementVectorL2Error
#     variable = u
#     function = f
#   []
#   [HDivSemiError]
#     type = ElementHDivSemiError
#     variable = u
#     function = f
#   []
#   [HDivError]
#     type = ElementHDivError
#     variable = u
#     function = f
#   []
# []

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names =  'conductivity'
    prop_values = '1'
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
  petsc_options_iname = '-pc_type -ksp_rtol -ksp_norm_type'
  petsc_options_value = '  jacobi     1e-12 preconditioned'
[]

[Outputs]
  exodus = true
[]