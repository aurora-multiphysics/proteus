"""compare_averages.py
Python script to verify the time averaging in the TimeAverageAux
class.

Equation being solved
   df/dt = -1
Initial conditions
  f(0) = x + y + z
Analytical solution
  f = f(0) - t
Analytical mean
  \bar{f} = \frac{1}{T}\int_0^T f(0) - t dt = f(0) - T/2
Analytical variance
  \overline{f^2} = \frac{1}{T}\int_0^T (f(0) - t)^2 dt = f(0)^2 - f(0)T  + T^2/3
"""

# requires vtk
import vtk
from vtkmodules.numpy_interface.dataset_adapter import VTKArray


def main():
    # read data using the vtkExodusIIReader
    reader = vtk.vtkExodusIIReader()
    reader.SetFileName("scalar_time_averaging_out.e")
    reader.UpdateInformation()

    # Use the last time step
    tstep = reader.GetNumberOfTimeSteps() - 1
    reader.SetTimeStep(tstep)

    # Extract the avg_mean variable
    reader.SetPointResultArrayStatus("avg_mean", 1)
    reader.SetPointResultArrayStatus("avg_var", 1)
    reader.Update()  # Read file

    # Extract Unstructured grid
    multiblock: vtk.vtkMultiBlockDataSet = reader.GetOutputDataObject(0)
    data: vtk.vtkUnstructuredGrid = multiblock.GetBlock(0).GetBlock(0)

    # Get the average and variance array and coordinates and wrap
    avg_mean = VTKArray(data.GetPointData().GetAbstractArray("avg_mean"))
    avg_var = VTKArray(data.GetPointData().GetAbstractArray("avg_var"))
    coords = VTKArray(data.GetPoints().GetData())

    # Determine time dynamically
    pipeline = vtk.vtkStreamingDemandDrivenPipeline()
    key = pipeline.TIME_STEPS()
    vtkinfo = reader.GetOutputInformation(0)
    time = vtkinfo.Get(key, tstep)

    # use same initial conditions as MOOSE
    x, y, z = coords.T
    f0 = x + y + z

    # analytical means and variances
    f_bar = f0 - 0.5 * time
    f_var = f0 * f0 - f0 * time + time * time / 3.0

    # output absolute and relative error for the mean
    abs_error = abs(f_bar - avg_mean)
    rel_error = abs_error[f_bar != 0] / f_bar[f_bar != 0]
    print("avg_mean:")
    print("\tRelative error: ", rel_error.max())
    print("\tAbsolute error: ", abs_error.max())

    # output absolute and relative error for the variance
    abs_error = abs(f_var - avg_var)
    rel_error = abs_error / f_var
    print("avg_var:")
    print("\tRelative error: ", rel_error.max())
    print("\tAbsolute error: ", abs_error.max())


if __name__ == "__main__":
    main()
