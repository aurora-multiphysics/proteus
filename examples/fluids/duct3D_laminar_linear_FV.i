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

[GlobalParams]
  rhie_chow_user_object = 'rc'
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = u_x
    v = u_y
    w = u_z
    pressure = p
  []
[]

[Variables]
  [u_x]
    type = INSFVVelocityVariable
    initial_condition = 0.05
  []
  [u_y]
    type = INSFVVelocityVariable
  []
  [u_z]
    type = INSFVVelocityVariable
  []
  [p]
    type = INSFVPressureVariable
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = p
    advected_interp_method = 'average'
    velocity_interp_method = 'rc'
    rho = 1000
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = u_x
    advected_interp_method = 'average'
    velocity_interp_method = 'rc'
    rho = 1000
    momentum_component = 'x'
  []
  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = u_x
    mu = 0.001
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u_x
    momentum_component = 'x'
    pressure = p
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = u_y
    advected_interp_method = 'average'
    velocity_interp_method = 'rc'
    rho = 1000
    momentum_component = 'y'
  []
  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = u_y
    mu = 0.001
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = u_y
    momentum_component = 'y'
    pressure = p
  []

  [w_advection]
    type = INSFVMomentumAdvection
    variable = u_z
    advected_interp_method = 'average'
    velocity_interp_method = 'rc'
    rho = 1000
    momentum_component = 'z'
  []
  [w_viscosity]
    type = INSFVMomentumDiffusion
    variable = u_z
    mu = 0.001
    momentum_component = 'z'
  []
  [w_pressure]
    type = INSFVMomentumPressure
    variable = u_z
    momentum_component = 'y'
    pressure = p
  []
[]

[FVBCs]
  [x_walls]
    type = INSFVNoSlipWallBC
    variable = u_x
    boundary = 'top bottom front back'
    function = '0.0'
  []
  [y_walls]
    type = INSFVNoSlipWallBC
    variable = u_y
    boundary = 'top bottom front back'
    function = '0.0'
  []
  [z_walls]
    type = INSFVNoSlipWallBC
    variable = u_z
    boundary = 'top bottom front back'
    function = '0.0'
  []
  [inlet_bc_x]
    type = INSFVInletVelocityBC
    variable = u_x
    boundary = 'left'
    functor = '0.05'
  []
  [inlet_bc_y]
    type = INSFVInletVelocityBC
    variable = u_y
    boundary = 'left'
    functor = '0.0'
  []
  [inlet_bc_z]
    type = INSFVInletVelocityBC
    variable = u_z
    boundary = 'left'
    functor = '0.0'
  []
  [outlet_bc]
    type = INSFVOutletPressureBC
    variable = p
    boundary = 'right'
    function = '0.0'
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
  nl_rel_tol = 1e-12
  automatic_scaling = true
  petsc_options_iname = '-pc_type -ksp_gmres_restart -sub_pc_type -pc_factor_shift_type'
  petsc_options_value = 'asm      100                lu           NONZERO'
[]

[Outputs]
  [out]
    type = Exodus
    execute_on = 'initial failed final'
  []
[]
