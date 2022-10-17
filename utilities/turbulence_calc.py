#!/usr/bin/python3
"""
turbulence_calc.

A utility to calculate turbulence quantities.
Will also give an estimated LES grid size and time step.

(c) UK Atomic Energy Authority, 2022
"""
import argparse
import sys

TRANSITION_RE = 2300
C_MU = 0.09

parser = argparse.ArgumentParser(
    description='Calculate turbulence quantities.')
parser.add_argument('velocity', metavar='velocity', type=float,
                    help='Velocity in m/s.')
parser.add_argument('length', metavar='length', type=float,
                    help='Characteristic length scale in m.')
parser.add_argument('density', metavar='density', type=float,
                    help='Density in kg/m³.')
parser.add_argument('viscosity', metavar='viscosity', type=float,
                    help='Dynamic viscosity in kg/m.s.')
parser.add_argument('intensity', metavar='intensity', type=float,
                    help='Turbulence intensity, default 0.1.',
                    nargs='?', default=0.1)
parser.add_argument('ratio', metavar='ratio', type=float,
                    help='Turbulence viscosity ratio, default 0.1.',
                    nargs='?', default=0.1)

args = parser.parse_args()

# Extract arguments
U = args.velocity
l = args.length
rho = args.density
mu = args.viscosity
I_tau = args.intensity
tvr = args.ratio
nu = mu/rho

# Echo inputs to user
print("---------------------------------------------------------")

print("Velocity,                             U = {} m/s.".format(U))
print("Length scale,                         l = {} m.".format(l))
print("Density,                              ρ = {} kg/m³.".format(rho))
print("Viscosity,                            μ = {} kg/m.s.".format(mu))
print("Turbulence intensity,               I_τ = {} %.".format(I_tau*100))
print("Turbulence viscosity ratio,         TVR = {} %.".format(tvr*100))

print("---------------------------------------------------------")

# Calculate Reynolds number
Re = args.density*args.velocity*args.length/args.viscosity

if Re > TRANSITION_RE:
    print("Reynolds number,                     Re = {:,}.".format(int(Re)))
    print("    Turbulent flow expected.")
elif Re > 0:
    print("Reynolds number,                     Re = {:,}.".format(int(Re)))
    print("    Laminar flow expected.")
else:
    sys.exit("Invalid Reynolds number.")

# Calculate turbulent kinetic energy from turbulence intensity
k = 1.5*(I_tau*U)**2

if k > 0:
    print("Turbulent kinetic energy,             k = {:.2e} m²/s².".format(k))
else:
    sys.exit("Invalid turbulent kinetic energy.")

# Calculate turbulent kinetic energy dissipation from tvr
mu_tau = tvr*mu
epsilon = rho*C_MU*k**2/mu_tau

if epsilon > 0:
    print("Turbulent kinetic energy dissipation, " +
          "ε = {:.2e} m²/s³.".format(epsilon))
else:
    sys.exit("Invalid turbulent kinetic energy dissipation.")

# Calculate specific dissipation rate from k and epsilon
omega = epsilon / (C_MU*k)

print("Specific dissipation rate,            ω = {:.2e} /s.".format(omega))

print("---------------------------------------------------------")

# Calculate turbulent length scale from k and epsilon
l_tau = k**1.5/epsilon

print("Turbulent length scale,             l_τ = {:.2e} m.".format(l_tau))

# Calculate Taylor microscale
l_mu = (10*k*mu/(epsilon*rho))**0.5

if l_mu >= 0:
    print("Taylor microscale,                  l_μ = {:.2e} m.".format(l_mu))
else:
    sys.exit("Invalid Taylor microscale.")

# Calculate Kolmogorov scale
eta = l_tau*Re**-0.75

print("Kolmogorov scale,                     η = {:.2e} m.".format(eta))

print("---------------------------------------------------------")

# Estimate LES resolution
Delta = max(l_mu, 0.1*l_tau)

print("Estimated LES resolution,             Δ = {:.2e} m.".format(Delta))

# Suggest timestep based on Delta
dt = Delta/U

if dt > 0:
    print("Suggested time step,                 δt = {:.2e} s.".format(dt))
else:
    sys.exit("Invalid timestep.")
