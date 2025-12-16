"""Python test module for coaxial pipe."""

import unittest
import numpy as np

class TestCoaxialPipe(unittest.TestCase):
    """Test class for the coaxial pipe component."""
    def test_energy_balance(self):
        """Compares energy increase in pipes to heat flux input on shell exterior."""

        _, t_inner, t_outer, _, q = np.loadtxt("energy_balance_out.csv",
                                               skiprows=2,
                                               delimiter=',',
                                               unpack=True)[:,-1]

        # mass flow rate in pipe and annulus 0.1 kg/s
        m_dot = 0.1

        # cp for water
        cp = 4186

        # inlet temperature
        t_in = 50+273.15

        delta_t_inner = t_inner - t_in
        delta_t_outer = t_outer - t_in
        total_energy = m_dot*cp*(delta_t_inner + delta_t_outer)

        rel_diff = abs(total_energy - q)/q
        assert rel_diff < 0.00025, f"Rel. energy difference greater than 0.00025: {rel_diff}"
