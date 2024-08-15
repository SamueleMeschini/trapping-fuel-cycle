import numpy as np
import matplotlib.pyplot as plt
import matplotx

plt.rcParams["font.size"] = "14"

fp_values = [1e-4, 1e-3, 1e-2, 1e-1]  # %
TBE_values = [1, 2, 5]
fig, axs = plt.subplots(nrows=2, ncols=1, sharex=True)

for TBE in TBE_values:
    data = np.genfromtxt(f"data/f_p_trap/TBE={TBE:.1f}%.csv", delimiter=",", names=True)

    plt.sca(axs[0])  # sca stands for Set Current Axis (activates the top axis)
    plt.plot(
        data["f_p_trap"],
        data["TBR_req"],
        label="TBE = " + f"{TBE:.1f}%",
        marker=".",
    )
    plt.sca(axs[1])
    plt.plot(
        data["f_p_trap"],
        data["I_startup_kg"],
        label="TBE = " + f"{TBE:.1f}%",
        marker=".",
    )

axs[1].set_xlabel(r"Tritium ion fraction impingin on the wall, $f_p$")

for ax in axs:
    matplotx.line_labels(ax, fontsize=10)
    ax.spines["right"].set_visible(False)
    ax.spines["top"].set_visible(False)
    ax.grid(which="major", axis="y", alpha=0.1)


matplotx.ylabel_top("Required TBR", ax=axs[0])
matplotx.ylabel_top("Startup \n inventory (kg)", ax=axs[1])

# axs[0].set_ylim(bottom=1)
# axs[0].set_yticks(np.arange(1.0, 1.4, 0.1))
# axs[1].set_ylim(bottom=0)
# axs[1].set_yticks(np.arange(0, 8, 2))
# plt.xticks(np.arange(0.1, 1.0, 0.2))
axs[0].set_xscale("log")
axs[1].set_xscale("log")


plt.tight_layout()
plt.savefig("tbr_startup_inv_vs_fp_trap.pdf", format="pdf", dpi=300)
plt.show()
