#-------------------------------------------------------------------------
# PARAMETER DEFINITIONS

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Geometry
# PI=3.141592653589793

# pipeIntDiam=12e-3    # m
pipeExtDiam=15e-3    # m

intLayerThick=1e-3   # m
# intLayerIntDiam=${pipeExtDiam}
intLayerExtDiam=${fparse pipeExtDiam + 2*intLayerThick}

monoBWidth=23e-3     # m
monoBThick=12e-3     # m
monoBArmHeight=8e-3  # m
# monoBSpacing=0.5e-3  # m

# pipeIntCirc=${fparse PI * pipeIntDiam}
# pipeExtCirc=${fparse PI * pipeExtDiam}
# intLayerExtCirc=${fparse PI * intLayerExtDiam}

# monoBArmSide=${fparse (monoBWidth - intLayerExtDiam) / 2}
# monoBHeight=${fparse monoBArmHeight + intLayerExtDiam + monoBArmSide}
# monoBSquareL=${fparse intLayerExtDiam/2 + monoBArmSide}
# monoBTopSurfY=${fparse monoBArmHeight + intLayerExtDiam/2}
# monoBTileHeight=${fparse monoBTopSurfY - monoBSquareL}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mesh Sizing
# MeshRefFact=1

# sweepDivs=10*${MeshRefFact}
# monoBArmDivs=8*${MeshRefFact}
# monoBRadDivs=5*${MeshRefFact}
# pipeCircSectDivs=12*${MeshRefFact}
# pipeRadDivs=3
# intLayerRadDivs=5*${MeshRefFact}

# monoBElemSize=${monoBThick/sweepDivs}
# tol=${monoBElemSize/10}
# ctol=${pipeIntCirc/(8*4*pipeCircSectDivs)}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Material Properties
# Mono-Block/Armour = Tungsten
# Interlayer = Copper
# Cooling pipe = CuCrZr

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loads and BCs
stressFreeTemp=20   # degC
blockTemp=100       # degC

#-------------------------------------------------------------------------

[GlobalParams]
  # displacements = 'disp_x disp_y'  # 2D
  displacements = 'disp_x disp_y disp_z'  # 3D
[]

[Mesh]
  [pccmg]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    polygon_size = ${fparse monoBWidth / 2}
    polygon_size_style = apothem  # i.e. distance from centre to edge
    ring_radii = ${fparse intLayerExtDiam / 2}
    num_sectors_per_side = '12 12 12 12'
    ring_intervals = 5
    background_intervals = 5
    # quad_center_elements = true
    # center_quad_factor = 8
    preserve_volumes = on
    flat_side_up = true
    ring_block_names = 'pipe_tri pipe'
    background_block_names = monoblock
    interface_boundary_id_shift = 1000
    interface_boundary_names = pipe_boundary
    external_boundary_name = monoblock_boundary
  []

  [gmg]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = ${fparse monoBWidth /-2}
    xmax = ${fparse monoBWidth / 2}
    ymin = ${fparse monoBWidth / 2}
    ymax = ${fparse monoBWidth / 2 + monoBArmHeight}
    nx = 12
    ny = 8
    boundary_name_prefix = armour
  []

  [smg]
    type = StitchedMeshGenerator
    inputs = 'pccmg gmg'
    stitch_boundaries_pairs = 'monoblock_boundary armour_bottom'
    clear_stitched_boundary_ids = true
    parallel_type = replicated
  []

  [merge_blocks]
    type = RenameBlockGenerator
    input = smg
    old_block = '3 0'
    new_block = 'armour armour'
  []

  [merge_boundaries]
    type = RenameBoundaryGenerator
    input = merge_blocks
    old_boundary = 'armour_top
                    armour_left 10002 15002
                    armour_right 10004 15004
                    10003 15003'
    new_boundary = 'top
                    left left left
                    right right right
                    bottom bottom'
  []

  [extrude]
    type = FancyExtruderGenerator
    input = merge_boundaries
    direction = '0 0 1'
    heights = ${monoBThick}
    num_layers = 10
  []
[]

[Variables]
  [temperature]
    family = LAGRANGE
    order = FIRST
    initial_condition = ${blockTemp}
  []
[]

[Kernels]
  [heat-conduction]
    type = HeatConduction
    variable = temperature
  []
  # [time_derivative]
  #   type = HeatConductionTimeDerivative
  #   variable = temperature
  # []
  # [heat_source]
  #   type = HeatSource
  #   variable = temperature
  #   value = ${blockTemp}
  # []
[]

[Modules/TensorMechanics/Master]
  [all]
    add_variables = true
    strain = FINITE
    automatic_eigenstrain_names = true
    generate_output = 'vonmises_stress'
  []
[]

[Materials]
  [copper-density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 8900  # kg/m^3
    block = 'pipe_tri pipe'
  []
  [tungsten-density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 19250  # kg/m^3
    block = 'armour'
  []
  [copper-conduction]
    type = HeatConductionMaterial
    specific_heat = 385  # J/(kg.K)
    thermal_conductivity = 400  # W/(m.K)
    block = 'pipe_tri pipe'
  []
  [tungsten-conduction]
    type = HeatConductionMaterial
    specific_heat = 134  # J/(kg.K)
    thermal_conductivity = 164  # W/(m.K)
    block = 'armour'
  []
  [copper-elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e11  # N/m^2
    poissons_ratio = 0.32  # dimensionless
    block = 'pipe_tri pipe'
  []
  [tungsten-elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 2e11  # N/m^2
    poissons_ratio = 0.3  # dimensionless 
    block = 'armour'
  []
  [copper-expansion]
    type = ComputeThermalExpansionEigenstrain
    temperature = temperature
    stress_free_temperature = ${stressFreeTemp}
    thermal_expansion_coeff = 16.7
    eigenstrain_name = thermal_expansion
    block = 'pipe_tri pipe'
  []
  [tungsten-expansion]
    type = ComputeThermalExpansionEigenstrain
    temperature = temperature
    stress_free_temperature = ${stressFreeTemp}
    thermal_expansion_coeff = 4.5
    eigenstrain_name = thermal_expansion
    block = 'armour'
  []
  [stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[BCs]
  # [block-temp]
  #   type = DirichletBC
  #   variable = temperature
  #   boundary = 'top'
  #   value = ${blockTemp}
  # []
  [fixed_x]
    type = DirichletBC
    variable = disp_x
    boundary = ''
    value = 0
  []
  [fixed_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  []
  [fixed_z]
    type = DirichletBC
    variable = disp_z
    boundary = ''
    value = 0
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  # solve_type = 'NEWTON'
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'lu'
  # start_time = 0
  # end_time = 5
  # dt = 1
[]

[Outputs]
  exodus = true
[]
