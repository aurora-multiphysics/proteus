#-------------------------------------------------------------------------
# DESCRIPTION

# Input file for computing the von-mises stress between the coolant pipe of a
# tokamak divertor monoblock and its armour due to thermal expansion.
# This simplified model is comprised of a solid OFHC copper cylinder surrounded
# by tungsten armour; no interlayer is included and coolant flow is not
# modelled. The boundary conditions are the stress-free temperature and the
# block temperature to which the block is uniformly heated.
# The solve is steady state and outputs temperature, displacement, and von
# mises stress.

#-------------------------------------------------------------------------
# PARAMETER DEFINITIONS

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Geometry
PI=3.141592653589793

pipeIntDiam=12e-3    # m
pipeExtDiam=15e-3    # m

intLayerThick=1e-3   # m
# intLayerIntDiam=${pipeExtDiam}
intLayerExtDiam=${fparse pipeExtDiam + 2*intLayerThick}

monoBWidth=23e-3     # m
monoBThick=12e-3     # m
monoBArmHeight=8e-3  # m
# monoBSpacing=0.5e-3  # m

pipeIntCirc=${fparse PI * pipeIntDiam}
# pipeExtCirc=${fparse PI * pipeExtDiam}
# intLayerExtCirc=${fparse PI * intLayerExtDiam}

# monoBArmSide=${fparse (monoBWidth - intLayerExtDiam) / 2}
# monoBHeight=${fparse monoBArmHeight + intLayerExtDiam + monoBArmSide}
# monoBSquareL=${fparse intLayerExtDiam/2 + monoBArmSide}
# monoBTopSurfY=${fparse monoBArmHeight + intLayerExtDiam/2}
# monoBTileHeight=${fparse monoBTopSurfY - monoBSquareL}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mesh Sizing
MeshRefFact=1

# Number of divisions along the top section of the monoblock armour.
monoBArmDivs=${fparse 8*MeshRefFact}

# Number of divisions around each quadrant of the circumference of the pipe,
# interlater, and radial section of the monoblock armour.
pipeCircSectDivs=${fparse 12*MeshRefFact}

# Number of radial divisions for the pipe, interlayer, and radial section of
# the monoblock armour respectively.
pipeRadDivs=${fparse 5*MeshRefFact}
# intLayerRadDivs=${fparse 5*MeshRefFact}
monoBRadDivs=${fparse 5*MeshRefFact}

# Number of divisions along monoblock thickness (i.e. z-dimension).
extrudeDivs=${fparse 10*MeshRefFact}

monoBElemSize=${fparse monoBThick/extrudeDivs}
tol=${fparse monoBElemSize/10}
ctol=${fparse pipeIntCirc/(8*4*pipeCircSectDivs)}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Material Properties
# Mono-Block/Armour = Tungsten
# Cooling pipe = OFHC Copper 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loads and BCs
stressFreeTemp=20   # degC
blockTemp=100       # degC

#-------------------------------------------------------------------------

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [pccmg]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    polygon_size = ${fparse monoBWidth / 2}
    polygon_size_style = apothem  # i.e. distance from centre to edge
    ring_radii = ${fparse intLayerExtDiam / 2}
    num_sectors_per_side = '
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}'
    ring_intervals = ${pipeRadDivs}
    background_intervals = ${monoBRadDivs}
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
    nx = ${pipeCircSectDivs}
    ny = ${monoBArmDivs}
    boundary_name_prefix = armour
  []

  [smg]
    type = StitchedMeshGenerator
    inputs = 'pccmg gmg'
    stitch_boundaries_pairs = 'monoblock_boundary armour_bottom'
    clear_stitched_boundary_ids = true
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
    type = AdvancedExtruderGenerator
    input = merge_boundaries
    direction = '0 0 1'
    heights = ${monoBThick}
    num_layers = ${extrudeDivs}
  []

  [pin_x0]
    type = BoundingBoxNodeSetGenerator
    input = extrude
    bottom_left = '${fparse -ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse -tol}'
    top_right = '${fparse ctol}
                ${fparse (monoBWidth/-2)+ctol}
                ${fparse (monoBThick)+tol}'
    new_boundary = bottom_x0
  []
  [pin_z0]
    type = BoundingBoxNodeSetGenerator
    input = pin_x0
    bottom_left = '${fparse (monoBWidth/-2)-ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse (monoBThick/2)-tol}'
    top_right = '${fparse (monoBWidth/2)+ctol}
                 ${fparse (monoBWidth/-2)+ctol}
                 ${fparse (monoBThick/2)+tol}'
    new_boundary = bottom_z0
  []
  [full_volume]
    type = BoundingBoxNodeSetGenerator
    input = pin_z0
    bottom_left = '
      ${fparse (monoBWidth/-2)-ctol}
      ${fparse (monoBWidth/-2)-ctol}
      ${fparse -tol}
    '
    top_right = '
      ${fparse (monoBWidth/2)+ctol}
      ${fparse (monoBWidth/2)+monoBArmHeight+ctol}
      ${fparse monoBThick+tol}
    '
    new_boundary = volume
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
  [heat_conduction]
    type = HeatConduction
    variable = temperature
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    add_variables = true
    strain = FINITE
    automatic_eigenstrain_names = true
    generate_output = 'vonmises_stress'
  []
[]

[Functions]
  [copper_thermal_expansion]
    type = PiecewiseLinear
    xy_data = '
      20 1.67e-05
      50 1.7e-05
      100 1.72e-05
      150 1.75e-05
      200 1.77e-05
      250 1.78e-05
      300 1.8e-05
      350 1.81e-05
      400 1.82e-05
      450 1.84e-05
      500 1.85e-05
      550 1.87e-05
      600 1.88e-05
      650 1.9e-05
      700 1.91e-05
      750 1.93e-05
      800 1.96e-05
      850 1.98e-05
      900 2.01e-05
    '
  []
  [tungsten_thermal_expansion]
    type = PiecewiseLinear
    xy_data = '
      20 4.5e-06
      100 4.5e-06
      200 4.53e-06
      300 4.58e-06
      400 4.63e-06
      500 4.68e-06
      600 4.72e-06
      700 4.76e-06
      800 4.81e-06
      900 4.85e-06
      1000 4.89e-06
      1200 4.98e-06
      1400 5.08e-06
      1600 5.18e-06
      1800 5.3e-06
      2000 5.43e-06
      2200 5.57e-06
      2400 5.74e-06
      2600 5.93e-06
      2800 6.15e-06
      3000 6.4e-06
      3200 6.67e-06
    '
  []
[]

[Materials]
  [copper_thermal_conductivity]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 401
      50 398
      100 395
      150 391
      200 388
      250 384
      300 381
      350 378
      400 374
      450 371
      500 367
      550 364
      600 360
      650 357
      700 354
      750 350
      800 347
      850 344
      900 340
      950 337
      1000 334
    '
    variable = temperature
    property = thermal_conductivity
    block = 'pipe_tri pipe'
  []
  [copper_density]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 8940
      50 8926
      100 8903
      150 8879
      200 8854
      250 8829
      300 8802
      350 8774
      400 8744
      450 8713
      500 8681
      550 8647
      600 8612
      650 8575
      700 8536
      750 8495
      800 8453
      850 8409
      900 8363
    '
    variable = temperature
    property = density
    block = 'pipe_tri pipe'
  []
  [copper_elastic_modulus]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 117000000000.0
      50 116000000000.0
      100 114000000000.0
      150 112000000000.0
      200 110000000000.0
      250 108000000000.0
      300 105000000000.0
      350 102000000000.0
      400 98000000000.0
    '
    variable = temperature
    property = elastic_modulus
    block = 'pipe_tri pipe'
  []
  [copper_specific_heat]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 388
      50 390
      100 394
      150 398
      200 401
      250 406
      300 410
      350 415
      400 419
      450 424
      500 430
      550 435
      600 441
      650 447
      700 453
      750 459
      800 466
      850 472
      900 479
      950 487
      1000 494
    '
    variable = temperature
    property = specific_heat
    block = 'pipe_tri pipe'
  []

  [tungsten_thermal_conductivity]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 173
      50 170
      100 165
      150 160
      200 156
      250 151
      300 147
      350 143
      400 140
      450 136
      500 133
      550 130
      600 127
      650 125
      700 122
      750 120
      800 118
      850 116
      900 114
      950 112
      1000 110
      1100 108
      1200 105
    '
    variable = temperature
    property = thermal_conductivity
    block = 'armour'
  []
  [tungsten_density]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 19300
      50 19290
      100 19280
      150 19270
      200 19250
      250 19240
      300 19230
      350 19220
      400 19200
      450 19190
      500 19180
      550 19170
      600 19150
      650 19140
      700 19130
      750 19110
      800 19100
      850 19080
      900 19070
      950 19060
      1000 19040
      1100 19010
      1200 18990
    '
    variable = temperature
    property = density
    block = 'armour'
  []
  [tungsten_elastic_modulus]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 398000000000.0
      50 398000000000.0
      100 397000000000.0
      150 397000000000.0
      200 396000000000.0
      250 396000000000.0
      300 395000000000.0
      350 394000000000.0
      400 393000000000.0
      450 391000000000.0
      500 390000000000.0
      550 388000000000.0
      600 387000000000.0
      650 385000000000.0
      700 383000000000.0
      750 381000000000.0
      800 379000000000.0
      850 376000000000.0
      900 374000000000.0
      950 371000000000.0
      1000 368000000000.0
      1100 362000000000.0
      1200 356000000000.0
    '
    variable = temperature
    property = elastic_modulus
    block = 'armour'
  []
  [tungsten_specific_heat]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      20 129
      50 130
      100 132
      150 133
      200 135
      250 136
      300 138
      350 139
      400 141
      450 142
      500 144
      550 145
      600 147
      650 148
      700 150
      750 151
      800 152
      850 154
      900 155
      950 156
      1000 158
      1100 160
      1200 163
    '
    variable = temperature
    property = specific_heat
    block = 'armour'
  []

  [copper_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    args = temperature
    youngs_modulus = elastic_modulus
    poissons_ratio = 0.33
    block = 'pipe_tri pipe'
  []
  [tungsten_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    args = temperature
    youngs_modulus = elastic_modulus
    poissons_ratio = 0.29
    block = 'armour'
  []

  [copper_expansion]
    type = ComputeInstantaneousThermalExpansionFunctionEigenstrain
    temperature = temperature
    stress_free_temperature = ${stressFreeTemp}
    thermal_expansion_function = copper_thermal_expansion
    eigenstrain_name = thermal_expansion_eigenstrain
    block = 'pipe_tri pipe'
  []
  [tungsten_expansion]
    type = ComputeInstantaneousThermalExpansionFunctionEigenstrain
    temperature = temperature
    stress_free_temperature = ${stressFreeTemp}
    thermal_expansion_function = tungsten_thermal_expansion
    eigenstrain_name = thermal_expansion_eigenstrain
    block = 'armour'
  []

  [stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[BCs]
  [block-temp]
    type = DirichletBC
    variable = temperature
    boundary = 'volume'
    value = ${blockTemp}
  []
  [fixed_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom_x0'
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
    boundary = 'bottom_z0'
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
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre    boomeramg'
[]

[Postprocessors]
  [max_stress]
    type = ElementExtremeValue
    variable = vonmises_stress
  []
[]

[Outputs]
  exodus = true
[]
