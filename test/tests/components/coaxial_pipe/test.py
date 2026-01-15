"""Python test module for coaxial pipe."""

import unittest
import numpy as np

class TestCoaxialPipe(unittest.TestCase):
    """Test class for the coaxial pipe component."""
    def test_energy_balance(self):
        """Compares energy increase in pipes to heat flux input on shell exterior."""

        _, t_inner, t_outer, q = np.loadtxt("energy_balance_out.csv",
                                               skiprows=2,
                                               delimiter=',',
                                               unpack=True)[:,-1]

        # mass flow rate in pipe and annulus 0.1 kg/s
        m_dot = 0.1

        # cp for water
        cp = 4000

        # inlet temperature
        t_in = 50+273.15

        delta_t_inner = t_inner - t_in
        delta_t_outer = t_outer - t_in
        total_energy = m_dot*cp*(delta_t_inner + delta_t_outer)

        rel_diff = abs(total_energy - q)/q
        assert rel_diff < 0.00028, f"Rel. energy difference greater than 0.00025: {rel_diff}"

    def test_energy_balance_inner(self):
        """Compares energy increase in the inner pipe to heat flux input on shell exterior."""

        _, t_inner, _, q = np.loadtxt("energy_balance_inner_out.csv",
                                               skiprows=2,
                                               delimiter=',',
                                               unpack=True)[:,-1]

        # mass flow rate in pipe 0.1 kg/s
        m_dot = 0.1

        # cp
        cp = 4000

        # inlet temperature
        t_in = 50+273.15

        delta_t_inner = t_inner - t_in
        total_energy = m_dot*cp*delta_t_inner

        rel_diff = abs(total_energy - q)/q
        assert rel_diff < 0.00046, f"Rel. energy difference greater than 0.00046: {rel_diff}"

    def test_energy_balance_outer(self):
        """Compares energy increase in the outer annulus to heat flux input on shell exterior."""

        _, _, t_outer, q = np.loadtxt("energy_balance_outer_out.csv",
                                               skiprows=2,
                                               delimiter=',',
                                               unpack=True)[:,-1]

        # mass flow rate in annulus 0.1 kg/s
        m_dot = 0.1

        # cp
        cp = 4000

        # inlet temperature
        t_in = 50+273.15

        delta_t_outer = t_outer - t_in
        total_energy = m_dot*cp*delta_t_outer

        rel_diff = abs(total_energy - q)/q
        assert rel_diff < 0.00048, f"Rel. energy difference greater than 0.00046: {rel_diff}"
