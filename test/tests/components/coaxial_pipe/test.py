"""Python test module for coaxial pipe."""

import unittest
import numpy as np


def ambient_convection_values(T_solid, T_ambient, length, gravity, vertical):
    """Independently evaluate the ambient convection correlations."""
    mu = 1.823e-5
    k = 0.02568
    gas_constant = 8.31446261815324 / 0.0289647
    gamma = 1.4
    cp = gamma * gas_constant / (gamma - 1)
    rho = 101325 / (gas_constant * T_ambient)
    beta = 1 / T_ambient

    prandtl = mu * cp / k
    thermal_diffusivity = k / (rho * cp)
    rayleigh = (rho * beta * abs(T_solid - T_ambient) * length**3 * gravity
                / (mu * thermal_diffusivity))

    base, prandtl_coefficient = (0.825, 0.492) if vertical else (0.6, 0.559)
    nusselt = (base + 0.387 * rayleigh ** (1 / 6)
               / (1 + (prandtl_coefficient / prandtl) ** (9 / 16)) ** (8 / 27)) ** 2

    return np.array([nusselt * k / length, nusselt, rayleigh])


def read_ambient_convection_output(file_name):
    """Read Hw, Nu, and Ra from an ambient convection CSV output."""
    data = np.genfromtxt(file_name, delimiter=",", names=True)
    return np.array([data["Hw"], data["Nu"], data["Ra"]])

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

    def assert_ambient_convection_values(
        self, file_name, T_solid, T_ambient, length, gravity, vertical
    ):
        """Compare computed correlation values against an independent evaluation."""
        actual = read_ambient_convection_output(file_name)
        expected = ambient_convection_values(
            T_solid, T_ambient, length, gravity, vertical
        )
        np.testing.assert_allclose(actual, expected, rtol=1e-12)

    def test_ambient_convection_horizontal(self):
        """Checks the diameter-based horizontal cylinder correlation."""
        self.assert_ambient_convection_values(
            "ambient_convection_horizontal.csv", 350, 300, 0.2, 9.81, False
        )

    def test_ambient_convection_vertical(self):
        """Checks the total-length-based vertical correlation."""
        self.assert_ambient_convection_values(
            "ambient_convection_vertical.csv", 350, 300, 1.0, 9.81, True
        )

    def test_ambient_convection_vertical_reversed(self):
        """Checks that reversing the vertical direction does not change the result."""
        self.assert_ambient_convection_values(
            "ambient_convection_vertical_reversed.csv", 350, 300, 1.0, 9.81, True
        )

    def test_ambient_convection_cold_surface(self):
        """Checks a pipe colder than its ambient environment."""
        self.assert_ambient_convection_values(
            "ambient_convection_cold_surface.csv", 250, 300, 0.2, 9.81, False
        )

    def test_ambient_convection_gravity_magnitude(self):
        """Checks that the configured gravity magnitude is used."""
        self.assert_ambient_convection_values(
            "ambient_convection_gravity_magnitude.csv", 350, 300, 0.2, 4.905, False
        )
