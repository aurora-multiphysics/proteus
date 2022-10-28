N_X = 50
N_Y_half = 10
INTEGRATE_BY_PARTS_P = true
ELEMENT_TYPE = QUAD4

[Mesh]
  [gmgTop]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${N_X}
    ny = ${N_Y_half}
    xmin = 0
    xmax = 20
    ymin = 0
    ymax = 1
		# bias_y = 0.8
    elem_type = ${ELEMENT_TYPE}
  []
	[gmgBottom]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${N_X}
    ny = ${N_Y_half}
    xmin = 0
    xmax = 20
    ymin = -1
    ymax = 0
		# bias_y = 1.25
    elem_type = ${ELEMENT_TYPE}
  []
	[mesh]
		type = StitchedMeshGenerator
		inputs = 'gmgTop gmgBottom'
		clear_stitched_boundary_ids = true
		stitch_boundaries_pairs = 'bottom top'
		# show_info = true
		
	[]
[]

[Variables]
  [velocity]
    family = LAGRANGE_VEC
    order = FIRST
  []
  [pressure]
    family = LAGRANGE
    order = FIRST
  []
  [electricPotential]
    family = LAGRANGE
    order = FIRST
  []
[]

[AuxVariables]
  [magneticField]
    order = FIRST
    family = LAGRANGE_VEC
  []
[]

[ICs]
  [velocityIC]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = 1e-15
    variable = velocity
  []
  # [velocityIC]
  #   type = VectorFunctionIC
  #   function = velocityFunction
  #   variable = velocity
  # []
  # [epotIC]
  #   type = FunctionIC
  #   function = epotFunction
  #   variable = electricPotential
  # []
[]

[BCs]
  [velocity_inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = left
    function = velocityFunction
  []
  [velocity_no_slip]
    type = VectorDirichletBC
    variable = velocity
    boundary = 'top bottom'
    values = '0 0 0'
  []
  [velocity_outlet]
    type = INSADMomentumNoBCBC
    variable = velocity
    pressure = pressure
    boundary = 'right'
    integrate_p_by_parts = ${INTEGRATE_BY_PARTS_P}
  []
  [pressure_reference]
    type = DirichletBC
    variable = pressure
    boundary = right
    value = 0
  []
  [epot_inlet_output]
    type = NeumannBC
    variable = electricPotential
    boundary = 'left right'
    value = 0
  []
  [epot_insulating_walls]
    type = NeumannBC
    variable = electricPotential
    boundary = 'top bottom'
    value = 0
  []
[]

[Materials]
  [const]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu  conductivity'
    prop_values = '1  1   1'
  []
  [ins_mat_tau]
    type = INSADTauMaterial
    velocity = velocity
    pressure = pressure
  []
  # [ins_mat]
  #   type = INSADMaterial
  #   velocity = velocity
  #   pressure = pressure
  # []
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

  # [momentum_time]
  #   type = INSADMomentumTimeDerivative
  #   variable = velocity
  # []
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
    integrate_p_by_parts = ${INTEGRATE_BY_PARTS_P}
  []
  [momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  []
  [lorentz_force_electrostatic]
    type = IRMINSADMomentumLorentzElectrostatic
    variable = velocity
    electricPotential = electricPotential
    magneticField = magneticField
  []
  [lorentz_force_flow]
    type = IRMINSADMomentumLorentzFlow
    variable = velocity
    velocity = velocity
    magneticField = magneticField
  []

  [epot_diffusion]
    type = ADDiffusion
    variable = electricPotential
  []
  [epot_production]
    type = IRMINSADElectricPotentialProduction
    variable = electricPotential
    velocity = velocity
    magneticField = magneticField
  []

[]

[AuxKernels]
  [magneticFieldKernel]
    type = VectorFunctionAux
    variable = magneticField
    function = magneticFieldFunction
    execute_on = INITIAL
  []
[]

[Functions]
  [velocityFunction]
    type = ParsedVectorFunction
    vars = 'u_max y_max z_max'
    vals = '2     1     1'
    value_x = 'u_max * (1 - (y*y)/(y_max*y_max))*(1-(z*z)/(z_max*z_max))'
    value_y = '0'
    value_z = '0'
  []
  [magneticFieldFunction]
    type = ParsedVectorFunction
    value_x = '0'
    value_y = '20'
    value_z = '0'
  []
  # [epotFunction]
  #   type = ParsedFunction
  #   value = '-4 * z'
  # []
[]

[Problem]
  type = FEProblem
[]

[Executioner]
  type = Steady
  # type = Transient
  # end_time = 0.2
  # dt = 0.005
  solve_type = NEWTON
  # automatic_scaling = true

  # petsc_options_iname = '-pc_type -pc_hypre_type'
  # petsc_options_value = 'hypre boomeramg'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'asm'
[]

[Outputs]
  exodus = true
  execute_on = 'nonlinear'
[]
