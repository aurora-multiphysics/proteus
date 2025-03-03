# Simple example of the TimeAverageAux
# ------------------------------------
# The example can be easily modified to test VectorTimeAverageAux by
# replacing the Kernels, Variables, ICs, AuxVariables and AuxKernels
# with the vector counterparts.

[Mesh]
  [gmg]
    type=GeneratedMeshGenerator
    dim=3
    nx = 10
    ny = 1
    nz = 1
  []
[]

[Kernels]
  [time_deriv]
    type=TimeDerivative
    variable=var1
  []
  [bodyf]
    type=BodyForce
    variable=var1
    function='-1'
  []
[]


[ICs]
  [ics]
    type=FunctionIC
    variable=var1
    function='x + y + z'
  []
[]

[BCs]
  [all]
    type=NeumannBC
    boundary = '0 1 2 3 4 5'
    variable=var1
    value=0
  []
[]

[Variables]
  [var1]
    order=FIRST
    family =LAGRANGE
  []
[]
[AuxVariables]
  [avg_mean]
    order=FIRST
    family =LAGRANGE
  []
  [avg_var]
    order=FIRST
    family =LAGRANGE
  []
[]

[AuxKernels]
  [mean]
    type=TimeAverageAux
    variable=avg_mean
    scalars=var1
    execute_on=TIMESTEP_END
  []
  [variance]
    type=TimeAverageAux
    variable=avg_var
    scalars='var1 var1'
    execute_on=TIMESTEP_END
  []
[]

[Executioner]
  type=Transient
  num_steps=1000
  dt=0.001
[]

[Outputs]
  exodus=true
[]
