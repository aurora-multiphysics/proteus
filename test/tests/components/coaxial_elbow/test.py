"""Python test module for coaxial elbows."""

import unittest

import numpy as np


class TestCoaxialElbow(unittest.TestCase):
    """Test class for the coaxial elbow component."""

    def test_inner_pressure_loss(self):
        """Compares pressure drop with expected value for inner pipe."""
        r_c = 0.1

        delta_p_inner, rho, vel_inlet = np.loadtxt("elbow_test_out.csv",
                                                    delimiter=',',
                                                    skiprows=1,
                                                    usecols=(1, 7, 9),
                                                    unpack=True)[:,-1]
        k = 0.21/np.sqrt(r_c/0.05)
        expected = k* 0.5*rho*vel_inlet*vel_inlet

        diff = abs((expected - delta_p_inner)/expected)
        assert diff < 5e-3, (
            f"Inner pressure loss wrong {expected} vs {delta_p_inner}. Diff {diff}"
        )

    def test_outer_pressure_loss(self):
        """Compares pressure drop with expected value for outer pipe."""

        r_c = 0.1

        delta_p_inner, rho, vel_inlet = np.loadtxt("elbow_test_out.csv",
                                                    delimiter=',',
                                                    skiprows=1,
                                                    usecols=(2, 8, 10),
                                                    unpack=True)[:,-1]
        k = 0.21/np.sqrt(r_c/0.05)
        expected = k* 0.5*rho*vel_inlet*vel_inlet

        diff = abs((expected - delta_p_inner)/expected)
        assert diff < 5e-3, (
            f"Inner pressure loss wrong {expected} vs {delta_p_inner}. Diff {diff}"
        )
