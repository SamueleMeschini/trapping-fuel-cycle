# 25 g inventory in W
import festim as F
import fenics as fx
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from scipy.interpolate import interp1d
import matplotlib.cm as cm
import matplotx
import matplotlib.colors as colors
from labellines import labelLines

temperatures = [900, 1500, 2100, 2700, 3300]
solutions = []
for T in temperatures:
    N_A = 6.022e23

    PM_tritium = 3  # g/mol

    # Geometry
    my_problem = F.Simulation()
    e = 1e-3 # m
    vertices = np.concatenate(
        [
            np.linspace(0, 5e-6, 500),
            np.linspace(0, e/2, 1000)
        ]
    )
    my_problem.mesh = F.MeshFromVertices(vertices)
    V = 0.17  # m3
    cross_sectional_area = V / e  # m3

    # Inventories
    I_mobile = 1e-3  # g
    n_mobile = I_mobile / PM_tritium * N_A / V # atoms/m3
    I_trapped = 25  # g
    n_trapped = I_trapped / PM_tritium * N_A / V  # atoms/m3

    # Temperature
    my_problem.T = F.Temperature(T)

    # BC in vacuum
    my_problem.boundary_conditions = [
        F.DirichletBC(surfaces=[1], value=0, field="solute")
    ]

    IC_m = F.InitialCondition(field="solute", value=n_mobile)
    IC_t = F.InitialCondition(field=1, value=n_trapped)
    my_problem.initial_conditions = [IC_m, IC_t]

    tungsten = F.Material(
        id=1,
        D_0=4.1e-07,  # m2/s
        E_D=0.39,  # eV
    )

    my_problem.materials = tungsten
    w_atom_density = 6.3e28  # atom/m3

    n_intrinsic = 1.3e-3 * w_atom_density  # atom/m3
    n_ions = 4.75e25  # atom/m3
    E_dt_ions = 1.15  # eV
    n_neutrons_1 = 3.2e25  # atom/m3
    E_dt_neutrons_1 = 1.35  # eV
    n_neutrons_2 = 2.5e25  # atom/m3
    E_dt_neutrons_2 = 1.65  # eV
    n_neutrons_3 = 6.3e25  # atom/m3
    E_dt_neutrons_3 = 1.85  # eV

    my_problem.traps = [
        F.Trap(
            k_0=tungsten.D_0 / (1.1e-10**2 * 6 * w_atom_density),
            E_k=tungsten.E_D,
            p_0=1e13,
            E_p=0.87,
            density=n_intrinsic,
            materials=tungsten,
            id=1
        ),
        F.Trap(
            k_0=tungsten.D_0 / (1.1e-10**2 * 6 * w_atom_density),
            E_k=tungsten.E_D,
            p_0=1e13,
            E_p=E_dt_ions,
            density=n_ions,
            materials=tungsten,
            id=2
        ),
        F.Trap(
            k_0=tungsten.D_0 / (1.1e-10**2 * 6 * w_atom_density),
            E_k=tungsten.E_D,
            p_0=1e13,
            E_p=E_dt_neutrons_1,
            density=n_neutrons_1,
            materials=tungsten,
        ),
        F.Trap(
            k_0=tungsten.D_0 / (1.1e-10**2 * 6 * w_atom_density),
            E_k=tungsten.E_D,
            p_0=1e13,
            E_p=E_dt_neutrons_2,
            density=n_neutrons_2,
            materials=tungsten,
        ),
        F.Trap(
            k_0=tungsten.D_0 / (1.1e-10**2 * 6 * w_atom_density),
            E_k=tungsten.E_D,
            p_0=1e13,
            E_p=E_dt_neutrons_3,
            density=n_neutrons_3,
            materials=tungsten,
        ),
    ]
    final_time = 3e7
    my_problem.settings = F.Settings(
        absolute_tolerance=1e18,
        relative_tolerance=1e-10,
        final_time=final_time,
    )

    my_problem.dt = F.Stepsize(initial_value=0.1, stepsize_change_ratio=1.01, dt_min=1e-6)
    total_solute = F.TotalVolume("solute", volume=1) # Total volume is misleading! It is the integral over the domain
    total_retained = F.TotalVolume('retention', volume=1)
    total_trapped_1 = F.TotalVolume(1, volume=1)
    total_trapped_2 = F.TotalVolume(2, volume=1)
    total_trapped_3 = F.TotalVolume(3, volume=1)
    total_trapped_4 = F.TotalVolume(4, volume=1)
    total_trapped_5 = F.TotalVolume(5, volume=1)
    flux_left = F.HydrogenFlux(surface=1)
    flux_right = F.HydrogenFlux(surface=2)
    derived_quantities = F.DerivedQuantities(
        [total_solute, total_retained, total_trapped_1, total_trapped_2, total_trapped_3, total_trapped_4, total_trapped_5, flux_left, flux_right]
    )
    results_folder = f"results/results_{T}K"
    my_problem.exports = F.Exports([
    F.TXTExport(field="solute", times=[0.1, final_time], label="solute", folder=results_folder),
    F.TXTExport(field="1", times=[0.1, final_time], label="1", folder=results_folder),
    F.TXTExport(field="2", times=[0.1, final_time], label="2", folder=results_folder),
    F.TXTExport(field="3", times=[0.1, final_time], label="3", folder=results_folder),
    F.TXTExport(field="4", times=[0.1, final_time], label="4", folder=results_folder),
    F.TXTExport(field="5", times=[0.1, final_time], label="5", folder=results_folder),
    F.TXTExport(field="retention", times=[0.1, final_time], label="retention", folder=results_folder),
    derived_quantities
])
    
    my_problem.initialise()
    my_problem.run()
    solutions.append(derived_quantities)

norm = colors.LogNorm(vmin=500, vmax=4000)

for T, solution in zip(temperatures, solutions):
    transposed_data = [list(column) for column in zip(*solution.data)]
    header = solution.data[0]
    # Create a structured array with the header as field names
    # Skip the first element (header) when converting to array
    arrays = [np.array(column[1:], dtype=float) for column in transposed_data]
    structured_array = np.core.records.fromarrays(arrays, names=header)
    np.savetxt(f"retained_fraction_T_{T}_I_{I_trapped}g.csv", structured_array, delimiter=",")
    plt.plot(structured_array['t(s)'], structured_array['Total retention volume 1']/(e/2)/(n_mobile+n_trapped), label=f"{T} K", color=cm.Reds(norm(T)))

plt.xscale("log")
# plt.yscale("log")
labelLines(plt.gca().get_lines(), zorder=2.5, xvals=[15, 5, 3, 3, 3])
plt.gca().spines.right.set_visible(False)
plt.gca().spines.top.set_visible(False)
plt.xlabel('Time (s)')
plt.ylabel('Tritium retained fraction')
plt.grid(alpha=0.2, which='both')
plt.savefig('retained_fraction_1mm.pdf', dpi=300)