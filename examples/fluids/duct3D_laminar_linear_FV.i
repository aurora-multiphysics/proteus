mu = 2.6
rho = 1.0
advected_interp_method = 'average'

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

[Problem]
  linear_sys_names = 'u_x_system u_y_system u_z_system pressure_system'
  previous_nl_solution_required = true
[]

[UserObjects]
  [rc]
    type = RhieChowMassFlux
    u = u_x
    v = u_y
    w = u_z
    pressure = pressure
    rho = ${rho}
    p_diffusion_kernel = p_diffusion
  []
[]

[Variables]
  [u_x]
    type = MooseLinearVariableFVReal
    initial_condition = 0.05
    solver_sys = u_x_system
  []
  [u_y]
    type = MooseLinearVariableFVReal
    solver_sys = u_y_system
  []
  [u_z]
    type = MooseLinearVariableFVReal
    solver_sys = u_z_system
  []
  [pressure]
    type = MooseLinearVariableFVReal
    solver_sys = pressure_system
  []
[]


[LinearFVKernels]
  [u_advection_stress]
    type = LinearWCNSFVMomentumFlux
    variable = u_x
    advected_interp_method = ${advected_interp_method}
    mu = ${mu}
    u = u_x
    v = u_y
    w = u_z
    momentum_component = 'x'
    rhie_chow_user_object = 'rc'
    use_nonorthogonal_correction = false
  []
  [v_advection_stress]
    type = LinearWCNSFVMomentumFlux
    variable = u_y
    advected_interp_method = ${advected_interp_method}
    mu = ${mu}
    u = u_x
    v = u_y
    w = u_z
    momentum_component = 'y'
    rhie_chow_user_object = 'rc'
    use_nonorthogonal_correction = false
  []
  [w_advection_stress]
    type = LinearWCNSFVMomentumFlux
    variable = u_z
    advected_interp_method = ${advected_interp_method}
    mu = ${mu}
    u = u_x
    v = u_y
    w = u_z
    momentum_component = 'z'
    rhie_chow_user_object = 'rc'
    use_nonorthogonal_correction = false
  []
  [u_pressure]
    type = LinearFVMomentumPressure
    variable = u_x
    pressure = pressure
    momentum_component = 'x'
  []
  [v_pressure]
    type = LinearFVMomentumPressure
    variable = u_y
    pressure = pressure
    momentum_component = 'y'
  []
  [w_pressure]
    type = LinearFVMomentumPressure
    variable = u_z
    pressure = pressure
    momentum_component = 'z'
  []
  [p_diffusion]
    type = LinearFVAnisotropicDiffusion
    variable = pressure
    diffusion_tensor = Ainv
    use_nonorthogonal_correction = false
  []
  [HbyA_divergence]
    type = LinearFVDivergence
    variable = pressure
    face_flux = HbyA
    force_boundary_execution = true
  []
[]

[LinearFVBCs]
  [x_walls]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = u_x
    boundary = 'top bottom front back'
    functor = '0.0'
  []
  [y_walls]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = u_y
    boundary = 'top bottom front back'
    functor = '0.0'
  []
  [z_walls]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = u_z
    boundary = 'top bottom front back'
    functor = '0.0'
  []
  [inlet_bc_x]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = u_x
    boundary = 'left'
    functor = '0.05'
  []
  [inlet_bc_y]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = u_y
    boundary = 'left'
    functor = '0.0'
  []
  [inlet_bc_z]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    variable = u_z
    boundary = 'left'
    functor = '0.0'
  []
  [outlet_p]
    type = LinearFVAdvectionDiffusionFunctorDirichletBC
    boundary = 'right'
    variable = pressure
    functor = 1.4 # previously had function='0.0' in old INSFVOutletPressureBC
  []
  [outlet_u]
    type = LinearFVAdvectionDiffusionOutflowBC
    variable = u_x
    use_two_term_expansion = false
    boundary = right
  []
  [outlet_v]
    type = LinearFVAdvectionDiffusionOutflowBC
    variable = u_y
    use_two_term_expansion = false
    boundary = right
  []
  [outlet_w]
    type = LinearFVAdvectionDiffusionOutflowBC
    variable = u_z
    use_two_term_expansion = false
    boundary = right
  []
[]

[Executioner]
  type = SIMPLE
  momentum_l_abs_tol = 1e-10
  pressure_l_abs_tol = 1e-10
  momentum_l_tol = 0
  pressure_l_tol = 0
  rhie_chow_user_object = 'rc'
  momentum_systems = 'u_x_system u_y_system u_z_system'
  pressure_system = 'pressure_system'
  momentum_equation_relaxation = 0.8
  pressure_variable_relaxation = 0.3
  num_iterations = 100
  pressure_absolute_tolerance = 1e-10
  momentum_absolute_tolerance = 1e-10
  momentum_petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_interp_type'
  momentum_petsc_options_value = 'hypre boomeramg 4 1 0.1 0.6 HMIS ext+i'
  pressure_petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_agg_nl -pc_hypre_boomeramg_agg_num_paths -pc_hypre_boomeramg_truncfactor -pc_hypre_boomeramg_strong_threshold -pc_hypre_boomeramg_coarsen_type -pc_hypre_boomeramg_interp_type'
  pressure_petsc_options_value = 'hypre boomeramg 2 1 0.1 0.6 HMIS ext+i'
  print_fields = false
[]

[Outputs]
  exodus = true
[]
