import matplotlib.pyplot as plt
import numpy as np

T = 3300

fig, ((ax1, ax2), (ax3, ax4), (ax5, ax6), (ax7,ax8)) = plt.subplots(4, 2, sharex=True, figsize=(10, 10))
max_values = []
for species, ax in zip(["solute", "1", "2", '3', '4','5', "retention"] , [ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8]):
    data = np.genfromtxt(f'results/results_{T}K/{species}.txt', delimiter=',', names=True)
    axis_label = data.dtype.names
    ax.plot(data[axis_label[0]], data[axis_label[1]], label="0.1 s")
    ax.plot(data[axis_label[0]], data[axis_label[2]], label="1e8 s")
    max_value = max(np.max(data[axis_label[1]]), np.max(data[axis_label[2]]))
    max_values.append(max_value)
    ax.set_ylim(0, max_value + 0.1 * max_value)  # Add some margin to the top of the plot

ax1.set_ylabel("H density (m$^{-3}$)")
ax3.set_ylabel("H density (m$^{-3}$)")
ax5.set_ylabel("H density (m$^{-3}$)")
ax7.set_ylabel("H density (m$^{-3}$)")
ax7.set_xlabel("x (m)")
ax8.set_xlabel("x (m)")
plt.legend()
plt.show()