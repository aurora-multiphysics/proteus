#-------------------------------------------------------------------------
# DESCRIPTION

# Input file for computing the von-mises stress between the coolant pipe of a
# tokamak divertor monoblock and its armour due to thermal expansion.
# The monoblock is typically comprised of a copper-chromium-zirconium (CuCrZr)
# pipe surrounded by tungsten armour with an OFHC copper pipe interlayer in
# between. This simplified model is comprised of a solid/filled OFHC copper
# cylinder by surrounded by tungsten armour; the CuCrZr pipe is not included
# and coolant flow is not modelled.
# The mesh uses first order elements with a nominal mesh refinement of one 
# division per millimetre.
# The boundary conditions are the stress-free temperature and the block
# temperature to which the block is uniformly heated.
# The solve is steady state and outputs temperature, displacement (magnitude
# as well as the x, y, z components), and von mises stress.

#-------------------------------------------------------------------------
# PARAMETER DEFINITIONS

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# File handling
name=simple_monoblock
outputDir=outputs

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Geometry
PI=3.141592653589793

intLayerExtDiam=17e-3 # m
intLayerExtCirc=${fparse PI * intLayerExtDiam}

monoBThick=3e-3     # m
monoBWidth=${fparse intLayerExtDiam + 2*monoBThick}
monoBDepth=12e-3      # m
monoBArmHeight=8e-3   # m

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mesh Sizing
meshRefFact=1
meshDens=1e3 # divisions per metre (nominal)

# Mesh Order
secondOrder=false
orderString=FIRST

# Note: some of the following values must be even integers. This is in some
# cases a requirement for the meshing functions used, else is is to ensure a
# division is present at the centreline, thus allowing zero-displacement
# boundary conditions to be applied to the centre node. These values are
# halved, rounded to int, then doubled to ensure the result is an even int.

# Number of divisions along the top section of the monoblock armour.
monoBArmDivs=${fparse int(monoBArmHeight * meshDens * meshRefFact)}

# Number of divisions around each quadrant of the circumference of the cylinder
# and radial section of the monoblock armour.
pipeCircSectDivs=${fparse 2 * int(monoBWidth/2 * meshDens * meshRefFact / 2)}

# Number of radial divisions for the interlayer and radial section of the
# monoblock armour respectively.
intLayerRadDivs=${
  fparse max(int(intLayerExtDiam/2 * meshDens * meshRefFact), 5)
}
monoBRadDivs=${
  fparse max(int((monoBWidth-intLayerExtDiam)/2 * meshDens * meshRefFact), 5)
}

# Number of divisions along monoblock depth (i.e. z-dimension).
extrudeDivs=${fparse max(2 * int(monoBDepth * meshDens * meshRefFact / 2), 4)}

monoBElemSize=${fparse monoBDepth / extrudeDivs}
tol=${fparse monoBElemSize / 10}
ctol=${fparse intLayerExtCirc / (8 * 4 * pipeCircSectDivs)}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Material Properties
# Mono-Block/Armour = Tungsten
# Interlayer = Oxygen-Free High-Conductivity (OFHC) Copper

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loads and BCs
stressFreeTemp=20   # degC
blockTemp=100       # degC

#-------------------------------------------------------------------------

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  second_order = ${secondOrder}

  [mesh_monoblock]
    type = PolygonConcentricCircleMeshGenerator
    num_sides = 4
    polygon_size = ${fparse monoBWidth / 2}
    polygon_size_style = apothem  # i.e. distance from centre to edge
    ring_radii = ${fparse intLayerExtDiam / 2}
    num_sectors_per_side = '
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
    '
    ring_intervals = ${intLayerRadDivs}
    background_intervals = ${monoBRadDivs}
    preserve_volumes = on
    flat_side_up = true
    ring_block_names = 'interlayer_tri interlayer'
    background_block_names = monoblock
    interface_boundary_id_shift = 1000
    external_boundary_name = monoblock_boundary
    generate_side_specific_boundaries = true
  []

  [mesh_armour]
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

  [combine_meshes]
    type = StitchedMeshGenerator
    inputs = 'mesh_monoblock mesh_armour'
    stitch_boundaries_pairs = 'monoblock_boundary armour_bottom'
    clear_stitched_boundary_ids = true
  []

  [merge_block_names]
    type = RenameBlockGenerator
    input = combine_meshes
    old_block = '3 0'
    new_block = 'armour armour'
  []

  [merge_boundary_names]
    type = RenameBoundaryGenerator
    input = merge_block_names
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
    input = merge_boundary_names
    direction = '0 0 1'
    heights = ${monoBDepth}
    num_layers = ${extrudeDivs}
  []

  [pin_x]
    type = BoundingBoxNodeSetGenerator
    input = extrude
    bottom_left = '${fparse -ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse -tol}'
    top_right = '${fparse ctol}
                 ${fparse (monoBWidth/-2)+ctol}
                 ${fparse (monoBDepth)+tol}'
    new_boundary = bottom_x0
  []
  [pin_z]
    type = BoundingBoxNodeSetGenerator
    input = pin_x
    bottom_left = '${fparse (monoBWidth/-2)-ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse (monoBDepth/2)-tol}'
    top_right = '${fparse (monoBWidth/2)+ctol}
                 ${fparse (monoBWidth/-2)+ctol}
                 ${fparse (monoBDepth/2)+tol}'
    new_boundary = bottom_z0
  []
  [define_full_volume_nodeset]
    type = BoundingBoxNodeSetGenerator
    input = pin_z
    bottom_left = '
      ${fparse (monoBWidth/-2)-ctol}
      ${fparse (monoBWidth/-2)-ctol}
      ${fparse -tol}
    '
    top_right = '
      ${fparse (monoBWidth/2)+ctol}
      ${fparse (monoBWidth/2)+monoBArmHeight+ctol}
      ${fparse monoBDepth+tol}
    '
    new_boundary = volume
  []
[]

[Variables]
  [temperature]
    family = LAGRANGE
    order = ${orderString}
    initial_condition = ${blockTemp}
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = temperature
  []
[]

[Modules]
  [TensorMechanics]
    [Master]
      [all]
        add_variables = true
        strain = FINITE
        automatic_eigenstrain_names = true
        generate_output = 'vonmises_stress'
      []
    []
  []
[]

[Functions]
  [copper_thermal_expansion_func]
    type = PiecewiseLinear
    data_file = ./data/copper_cte.csv
    format = columns
  []
  [tungsten_thermal_expansion_func]
    type = PiecewiseLinear
    data_file = ./data/tungsten_cte.csv
    format = columns
  []

  [copper_thermal_conductivity_func]
    type = PiecewiseLinear
    data_file = ./data/copper_conductivity.csv
    format = columns
  []
  [tungsten_thermal_conductivity_func]
    type = PiecewiseLinear
    data_file = ./data/tungsten_conductivity.csv
    format = columns
  []

  [copper_density_func]
    type = PiecewiseLinear
    data_file = ./data/copper_density.csv
    format = columns
  []
  [tungsten_density_func]
    type = PiecewiseLinear
    data_file = ./data/tungsten_density.csv
    format = columns
  []

  [copper_elastic_modulus_func]
    type = PiecewiseLinear
    data_file = ./data/copper_elastic_modulus.csv
    format = columns
  []
  [tungsten_elastic_modulus_func]
    type = PiecewiseLinear
    data_file = ./data/tungsten_elastic_modulus.csv
    format = columns
  []

  [copper_specific_heat_func]
    type = PiecewiseLinear
    data_file = ./data/copper_specific_heat.csv
    format = columns
  []
  [tungsten_specific_heat_func]
    type = PiecewiseLinear
    data_file = ./data/tungsten_specific_heat.csv
    format = columns
  []
[]

[Materials]
  [copper_thermal_conductivity]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = thermal_conductivity
    function = copper_thermal_conductivity_func
    block = 'interlayer_tri interlayer'
  []
  [tungsten_thermal_conductivity]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = thermal_conductivity
    function = tungsten_thermal_conductivity_func
    block = 'armour'
  []

  [copper_density]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = density
    function = copper_density_func
    block = 'interlayer_tri interlayer'
  []
  [tungsten_density]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = density
    function = tungsten_density_func
    block = 'armour'
  []

  [copper_elastic_modulus]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = elastic_modulus
    function = copper_elastic_modulus_func
    block = 'interlayer_tri interlayer'
  []
  [tungsten_elastic_modulus]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = elastic_modulus
    function = tungsten_elastic_modulus_func
    block = 'armour'
  []

  [copper_specific_heat]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = specific_heat
    function = copper_specific_heat_func
    block = 'interlayer_tri interlayer'
  []
  [tungsten_specific_heat]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = specific_heat
    function = tungsten_specific_heat_func
    block = 'armour'
  []

  [copper_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    args = temperature
    youngs_modulus = elastic_modulus
    poissons_ratio = 0.33
    block = 'interlayer_tri interlayer'
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
    thermal_expansion_function = copper_thermal_expansion_func
    eigenstrain_name = thermal_expansion_eigenstrain
    block = 'interlayer_tri interlayer'
  []
  [tungsten_expansion]
    type = ComputeInstantaneousThermalExpansionFunctionEigenstrain
    temperature = temperature
    stress_free_temperature = ${stressFreeTemp}
    thermal_expansion_function = tungsten_thermal_expansion_func
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
  [write_to_file]
    type = CSV
    show = 'max_stress'
    file_base = '${outputDir}/${name}_out'
  []
[]
