"""Python test module for coaxial junction."""

import unittest
import numpy as np

def heat_flux(time: float,
              temp_cold: float,
              temp_hot: float,
              k1: float,
              k2: float,
              rho_cp1: float,
              rho_cp2: float) -> np.ndarray:
    """Computes boundary heat flux at junction."""

    numerator = (temp_hot - temp_cold) * np.sqrt(k2 * rho_cp2)
    denominator = np.sqrt(k1 * rho_cp1) + np.sqrt(k2 * rho_cp2)
    arg = 1 / (2 * np.sqrt(k1 / rho_cp1 * time))
    return k1*(numerator / denominator) * 2*arg/np.sqrt(np.pi)



class TestCoaxialJunction(unittest.TestCase):
    """Test class for the coaxial junction component."""
    def test_solid_continuity(self):
        """Checks the solid temperature is similar on both sides on the solid coupler."""

        time, t_shell_in2, t_shell_out1, t_tube_in2, t_tube_out1 = np.loadtxt(
                                               "junction_solid_out.csv",
                                               skiprows=2,
                                               delimiter=',',
                                               unpack=True
                                               )

        # The 2D coupling uses a HTC approach. Here we set it very high: 1e10.
        # This means that we should expect a small but finite difference between each
        # side of the coupler
        # The minimum difference should be delta_t = qw/HTC
        # qw can be calculated from the analytical solution
        qw = heat_flux(time, 300, 301, 1, 4, 1, 16)
        eps = 5e-9 # account numerical errors, set small but arbitrary
        expected_err = qw/1e10 + eps

        diff = abs(t_shell_out1 - t_shell_in2)

        idx = np.argmax(diff-expected_err)
        assert all(diff < expected_err), \
               f"shell temperature difference ({time[idx]}) " \
               f"greater than {expected_err[idx]}: {diff[idx]}"

        diff = abs(t_tube_out1 - t_tube_in2)

        idx = np.argmax(diff-expected_err)
        assert all(diff < expected_err), \
            f"tube temperature difference ({time[idx]}) " \
            f"greater than {expected_err[idx]}: {diff[idx]}"

    def test_fluid_mdot(self):
        """Checks the outlet mass flow rate of second coaxial pipe matches inlet."""
        _, mdot_inner, mdot_outer = np.loadtxt("junction_solid_out.csv",
                                               skiprows=1,
                                               delimiter=',',
                                               unpack=True)[:,-1]

        assert abs(mdot_inner -1) < 1e-4, "Inner mass flow rate incorrect."
        assert abs(mdot_outer -1) < 1e-4, "Outer mass flow rate incorrect."
