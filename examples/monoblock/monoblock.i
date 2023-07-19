#-------------------------------------------------------------------------
# DESCRIPTION

# Input file for computing the von-mises stress between the coolant pipe of a
# tokamak divertor monoblock and its armour due to thermal expansion.
# The monoblock is comprised of a copper-chromium-zirconium (CuCrZr) pipe
# surrounded by tungsten armour with an OFHC copper pipe interlayer in between.
# The mesh uses second order elements with a nominal mesh refinement of one 
# division per millimetre.
# The incoming heat is modelled as a constant heat flux on the top surface of
# the block (i.e. the plasma-facing side). The outgoing heat is modelled as a
# convective heat flux on the internal surface of the copper pipe. Besides this
# heat flux, coolant flow is not modelled; the fluid region is treated as void.
# The boundary conditions are the stress-free temperature for the block, the
# incoming heat flux on the top surface, and the coolant temperature.
# The solve is steady state and outputs temperature, displacement (magnitude
# as well as the x, y, z components), and von mises stress.

#-------------------------------------------------------------------------
# PARAMETER DEFINITIONS 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# File handling
name=monoblock
outputDir=outputs

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Geometry
PI=3.141592653589793

pipeThick=1.5e-3     # m
pipeIntDiam=12e-3    # m
pipeExtDiam=${fparse pipeIntDiam + 2*pipeThick}

intLayerThick=1e-3   # m
intLayerIntDiam=${pipeExtDiam}
intLayerExtDiam=${fparse intLayerIntDiam + 2*intLayerThick}

monoBThick=3e-3      # m
monoBWidth=${fparse intLayerExtDiam + 2*monoBThick}
monoBArmHeight=8e-3  # m
monoBDepth=12e-3     # m

pipeIntCirc=${fparse PI * pipeIntDiam}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Mesh Sizing
meshRefFact=1
meshDens=1e3 # divisions per metre (nominal)

# Mesh Order
secondOrder=true
orderString=SECOND

# Note: some of the following values must be even integers. This is in some
# cases a requirement for the meshing functions used, else is is to ensure a
# division is present at the centreline, thus allowing zero-displacement
# boundary conditions to be applied to the centre node. These values are
# halved, rounded to int, then doubled to ensure the result is an even int.

# Number of divisions along the top section of the monoblock armour.
monoBArmDivs=${fparse int(monoBArmHeight * meshDens * meshRefFact)}

# Number of divisions around each quadrant of the circumference of the pipe,
# interlayer, and radial section of the monoblock armour.
pipeCircSectDivs=${fparse 2 * int(monoBWidth/2 * meshDens * meshRefFact / 2)}

# Number of radial divisions for the pipe, interlayer, and radial section of
# the monoblock armour respectively.
pipeRadDivs=${fparse max(int(pipeThick * meshDens * meshRefFact), 3)}
intLayerRadDivs=${fparse max(int(intLayerThick * meshDens * meshRefFact), 5)}
monoBRadDivs=${
  fparse max(int((monoBWidth-intLayerExtDiam)/2 * meshDens * meshRefFact), 5)
}

# Number of divisions along monoblock depth (i.e. z-dimension).
extrudeDivs=${fparse max(2 * int(monoBDepth * meshDens * meshRefFact / 2), 4)}

monoBElemSize=${fparse monoBDepth / extrudeDivs}
tol=${fparse monoBElemSize / 10}
ctol=${fparse pipeIntCirc / (8 * 4 * pipeCircSectDivs)}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Material Properties
# Mono-Block/Armour = Tungsten
# Interlayer = Oxygen-Free High-Conductivity (OFHC) Copper
# Cooling pipe = Copper Chromium Zirconium (CuCrZr)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Loads and BCs
stressFreeTemp=20   # degC
coolantTemp=150     # degC
surfHeatFlux=10e6   # W/m^2

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
    ring_radii = '
      ${fparse pipeIntDiam / 2}
      ${fparse pipeExtDiam / 2}
      ${fparse intLayerExtDiam / 2}
    '
    num_sectors_per_side = '
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
      ${pipeCircSectDivs}
    '
    ring_intervals = '1 ${pipeRadDivs} ${intLayerRadDivs}'
    background_intervals = ${monoBRadDivs}
    preserve_volumes = on
    flat_side_up = true
    ring_block_names = 'void pipe interlayer'
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

  [delete_void]
    type = BlockDeletionGenerator
    input = combine_meshes
    block = void
    new_boundary = internal_boundary
  []

  [merge_block_names]
    type = RenameBlockGenerator
    input = delete_void
    old_block = '4 0'
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

  [name_node_centre_x_bottom_y_back_z]
    type = BoundingBoxNodeSetGenerator
    input = extrude
    bottom_left = '${fparse -ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse -tol}'
    top_right = '${fparse ctol}
                 ${fparse (monoBWidth/-2)+ctol}
                 ${fparse tol}'
    new_boundary = centre_x_bottom_y_back_z
  []
  [name_node_centre_x_bottom_y_front_z]
    type = BoundingBoxNodeSetGenerator
    input = name_node_centre_x_bottom_y_back_z
    bottom_left = '${fparse -ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse monoBDepth-tol}'
    top_right = '${fparse ctol}
                 ${fparse (monoBWidth/-2)+ctol}
                 ${fparse monoBDepth+tol}'
    new_boundary = centre_x_bottom_y_front_z
  []
  [name_node_left_x_bottom_y_centre_z]
    type = BoundingBoxNodeSetGenerator
    input = name_node_centre_x_bottom_y_front_z
    bottom_left = '${fparse (monoBWidth/-2)-ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse (monoBDepth/2)-tol}'
    top_right = '${fparse (monoBWidth/-2)+ctol}
                 ${fparse (monoBWidth/-2)+ctol}
                 ${fparse (monoBDepth/2)+tol}'
    new_boundary = left_x_bottom_y_centre_z
  []
  [name_node_right_x_bottom_y_centre_z]
    type = BoundingBoxNodeSetGenerator
    input = name_node_left_x_bottom_y_centre_z
    bottom_left = '${fparse (monoBWidth/2)-ctol}
                   ${fparse (monoBWidth/-2)-ctol}
                   ${fparse (monoBDepth/2)-tol}'
    top_right = '${fparse (monoBWidth/2)+ctol}
                 ${fparse (monoBWidth/-2)+ctol}
                 ${fparse (monoBDepth/2)+tol}'
    new_boundary = right_x_bottom_y_centre_z
  []
[]

[Variables]
  [temperature]
    family = LAGRANGE
    order = ${orderString}
    initial_condition = ${coolantTemp}
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
  [cucrzr_thermal_expansion_func]
    type = PiecewiseLinear
    data_file = ./data/cucrzr_cte.csv
    format = columns
  []
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

  [cucrzr_thermal_conductivity_func]
    type = PiecewiseLinear
    data_file = ./data/cucrzr_conductivity.csv
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

  [cucrzr_density_func]
    type = PiecewiseLinear
    data_file = ./data/cucrzr_density.csv
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

  [cucrzr_elastic_modulus_func]
    type = PiecewiseLinear
    data_file = ./data/cucrzr_elastic_modulus.csv
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

  [cucrzr_specific_heat_func]
    type = PiecewiseLinear
    data_file = ./data/cucrzr_specific_heat.csv
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
  [cucrzr_thermal_conductivity]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = thermal_conductivity
    function = cucrzr_thermal_conductivity_func
    block = 'pipe'
  []
  [copper_thermal_conductivity]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = thermal_conductivity
    function = copper_thermal_conductivity_func
    block = 'interlayer'
  []
  [tungsten_thermal_conductivity]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = thermal_conductivity
    function = tungsten_thermal_conductivity_func
    block = 'armour'
  []

  [cucrzr_density]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = density
    function = cucrzr_density_func
    block = 'pipe'
  []
  [copper_density]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = density
    function = copper_density_func
    block = 'interlayer'
  []
  [tungsten_density]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = density
    function = tungsten_density_func
    block = 'armour'
  []

  [cucrzr_elastic_modulus]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = elastic_modulus
    function = cucrzr_elastic_modulus_func
    block = 'pipe'
  []
  [copper_elastic_modulus]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = elastic_modulus
    function = copper_elastic_modulus_func
    block = 'interlayer'
  []
  [tungsten_elastic_modulus]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = elastic_modulus
    function = tungsten_elastic_modulus_func
    block = 'armour'
  []

  [cucrzr_specific_heat]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = specific_heat
    function = cucrzr_specific_heat_func
    block = 'pipe'
  []
  [copper_specific_heat]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = specific_heat
    function = copper_specific_heat_func
    block = 'interlayer'
  []
  [tungsten_specific_heat]
    type = CoupledValueFunctionMaterial
    v = temperature
    prop_name = specific_heat
    function = tungsten_specific_heat_func
    block = 'armour'
  []

  [cucrzr_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    args = temperature
    youngs_modulus = elastic_modulus
    poissons_ratio = 0.33
    block = 'pipe'
  []
  [copper_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    args = temperature
    youngs_modulus = elastic_modulus
    poissons_ratio = 0.33
    block = 'interlayer'
  []
  [tungsten_elasticity]
    type = ComputeVariableIsotropicElasticityTensor
    args = temperature
    youngs_modulus = elastic_modulus
    poissons_ratio = 0.29
    block = 'armour'
  []

  [cucrzr_expansion]
    type = ComputeInstantaneousThermalExpansionFunctionEigenstrain
    temperature = temperature
    stress_free_temperature = ${stressFreeTemp}
    thermal_expansion_function = cucrzr_thermal_expansion_func
    eigenstrain_name = thermal_expansion_eigenstrain
    block = 'pipe'
  []
  [copper_expansion]
    type = ComputeInstantaneousThermalExpansionFunctionEigenstrain
    temperature = temperature
    stress_free_temperature = ${stressFreeTemp}
    thermal_expansion_function = copper_thermal_expansion_func
    eigenstrain_name = thermal_expansion_eigenstrain
    block = 'interlayer'
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

  [coolant_heat_transfer_coefficient]
    type = PiecewiseLinearInterpolationMaterial
    xy_data = '
      1 4
      100 109.1e3
      150 115.9e3
      200 121.01e3
      250 128.8e3
      295 208.2e3
    '
    variable = temperature
    property = heat_transfer_coefficient
    boundary = 'internal_boundary'
  []
[]

[BCs]
  [heat_flux_in]
    type = NeumannBC
    variable = temperature
    boundary = 'top'
    value = ${surfHeatFlux}
  []
  [heat_flux_out]
    type = ConvectiveHeatFluxBC
    variable = temperature
    boundary = 'internal_boundary'
    T_infinity = ${coolantTemp}
    heat_transfer_coefficient = heat_transfer_coefficient
  []
  [fixed_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'centre_x_bottom_y_back_z centre_x_bottom_y_front_z'
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
    boundary = 'left_x_bottom_y_centre_z right_x_bottom_y_centre_z'
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
