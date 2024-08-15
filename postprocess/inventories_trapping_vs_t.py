import numpy as np
import matplotlib
import matplotlib.pyplot as plt

t_bz_values = [1]
plt.rcParams["font.size"] = "14"
plt.style.use("seaborn-v0_8-deep")
# colors = ["b", "g", "r", "purple", "orange", "pink"]
for t_bz in t_bz_values:
    data = np.genfromtxt(
        f"data/inventories_w_trapping_tbr_fixed.csv",
        delimiter=",",
        names=True,
    )
    x = (data["time_s"] / 3600 / 24).T
    y = np.array(
        (
            data["blanket_inventory_kg"],
            data["TES_inventory_kg"],
            data["ISS_inventory_kg"],
            data["storage_inventory_kg"],
            # data["FW_inventory_kg"],
            # data["div_inventory_kg"],
        )
    ).T
    t_infl = x[np.argmin(data["storage_inventory_kg"])]
    t_d = x[(data["storage_inventory_kg"] > 2 * data["storage_inventory_kg"][0])][0]
    fig, ax = plt.subplots()
    # ax.set_prop_cycle("color", colors)
    ax.loglog(x, y)
    ax.vlines(
        t_d,
        ymin=0,
        ymax=1,
        colors="k",
        linestyles="--",
        transform=ax.get_xaxis_transform(),
    )
    ax.set_xlim(1e-1, 1.1 * t_d)
    ax.set_ylim(1e-3, 1e2)
    ax.set_xlabel("Time (days)")
    ax.set_ylabel("Inventory (kg)")
    ax.grid(True, which="both", alpha=0.1)
    ax.annotate(
        "Minimum point",
        xy=(t_infl, np.min(data["storage_inventory_kg"])),
        xycoords="data",
        xytext=(250, 190),
        textcoords="axes points",
        arrowprops=dict(arrowstyle="->", connectionstyle="arc3"),
        horizontalalignment="right",
        verticalalignment="top",
    )
    ax.legend(
        ["Breeding zone", "TES", "ISS", "Storage"],
        loc="upper left",
        ncol=2,
        fontsize=12,
    )
    ax.text(x=0.3 * t_d, y=50, s=f"$t_d = {t_d/365:.0f} y$")
    # ax.text(x=0.3 * t_d, y=50, s="$t_d = 2y$")
    ax.spines.right.set_visible(False)
    ax.spines.top.set_visible(False)
    plt.tight_layout()
    plt.show()
    # fig.savefig(
    #     f"inventories_wo_trapping_tbr_fixed.pdf",
    #     format="pdf",
    #     dpi=300,
    # )
