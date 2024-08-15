import numpy as np
import matplotlib.pyplot as plt
import matplotx
from matplotlib.patches import Rectangle

plt.rcParams["font.size"] = "14"
T  = [500, 700, 900, 1000]
TBR_vcrti = [1.135, 1.105, 1.090, 1.087]
TBR_eurofer = [1.15, 1.105, 1.095, 1.091]
TBR_inconel = [1.158, 1.106, 1.095, 1.093]
I_startup_vcrti = [2.45, 2.05, 1.89, 1.85]
I_startup_eurofer = [2.8, 2.14, 1.96, 1.91]
I_startup_inconel = [3.03, 2.16, 1.98, 1.95]
TBR = [TBR_vcrti, TBR_eurofer, TBR_inconel]
I_startup = [I_startup_vcrti, I_startup_eurofer, I_startup_inconel]
labels = ['V-Cr-Ti', 'Eurofer 97', 'Inconel 718']
I_blanket_vcrti = [1.5, 0.658, 0.490, 0.440] #kg
I_blanket_eurofer = [1.72, 0.753, 0.545, 0.513] #kg
I_blanket_inconel = [1.79, 0.782, 0.582, 0.543] #kg
I_FW_vcrti = [0.135, 0.053, 0.039, 0.035] #kg
I_FW_eurofer = [0.135, 0.053, 0.039, 0.035] #kg
I_FW_inconel = [0.135, 0.053, 0.039, 0.035] #kg

fig, axs = plt.subplots(nrows=2, ncols=1, sharex=True)

plt.sca(axs[0])  # sca stands for Set Current Axis (activates the top axis)

for TBR, I_startup, label in zip(TBR, I_startup, labels):
    axs[0].plot(
        T,
        TBR,
        marker=".", label=label
    )
    plt.sca(axs[1])
    axs[1].plot(
        T,
        I_startup,
        marker=".", label=label
    )

axs[1].set_xlabel("T (K)")

for ax in axs:
    # matplotx.line_labels(ax, fontsize=10)
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.grid(which="major", axis="y", alpha=0.1)




axs[0].axhline(y=1.067, linestyle='--', c='tab:green', label='Baseline w/o trapping')
# axs[0].set_ylim(bottom=1, top=1.25)
axs[0].set_yticks(np.arange(1., 1.25, 0.05))
# axs[1].set_ylim(bottom=0, top = 4)
axs[1].set_yticks(np.arange(0, 5, 1))
axs[1].axhline(y=1.45, linestyle='--', c='tab:green')
# axs[0].legend(fontsize=9, loc='upper right')
matplotx.ylabel_top("Required TBR", ax=axs[0])
matplotx.ylabel_top("Startup \n inventory (kg)", ax=axs[1])
handles, labels = axs[0].get_legend_handles_labels()
fig.legend(
    handles[::-1], labels[::-1],
    fontsize=9, 
    bbox_to_anchor=(1., 1)
) 
# plt.xticks(np.arange(0.1, 1., 0.2))
# rect = Rectangle((500,1.1),500,0.2,linewidth=1,edgecolor='r',facecolor='none')
# axs[0].add_patch(rect)

plt.tight_layout()
plt.savefig("tbr_startup_inv_vs_T.pdf", format='pdf', dpi=300)
plt.show()
