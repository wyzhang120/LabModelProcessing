import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# read first break picks from vista
fDir = 'C:\DFiles\Geophysics\Project\LabModel\LabMeasurement_062018\DelayTest_02282019'
fname = 'FBPicks.txt'
# row and col index both starts from 0
# use 'Trace' as the index for the table
df = pd.read_csv(os.path.join(fDir, fname), header=0, delim_whitespace=True, index_col=0)
tFB = df.FBP.values
fig, ax = plt.subplots()
offset = -df.OFF.values
ax.plot(offset[5:], tFB[5:], 'bo', label='First break picks')
sw, delay = np.polyfit(offset[5:], tFB[5:], 1)
vw = 1./sw
print('delay = {:.3f} ms; water vel = {:.3f} km/s'.format(delay, vw))
print('zero offset readings: {:s}'.format(' '.join([ '{:.3f}'.format(i) for i in tFB[:5]])))
xmax = 210
ymax = 150
ax.set_ylim([0, ymax])
ax.set_xlim([0, xmax])
ax.set_xlabel('Offset, x[m]')
ax.set_ylabel('Time, t[ms]')
ax.set_title('Delay test')
tAx = np.arange(0, xmax)
y = np.polyval([sw, delay], tAx)
ax.plot(tAx, y, 'k--', label='Fitted line, t={:.3f}x+{:.3f}'.format(sw, delay))
plt.legend()
plt.show()