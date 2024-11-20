# Imports

import numpy as np
import mne
import os
import matplotlib.pyplot as plt
# from mne_bids.copyfiles import copyfile_brainvision
from mne.epochs import combine_event_ids
from mne.time_frequency import psd_welch
from pathlib import Path
os.chdir('C:\\Users\\irmak\\Desktop\\')

data_dir = "export"
# subject_file = "S01_Ocular Correction ICA.vhdr"
subject_file = "S05_Ocular Correction ICA.vhdr"
subject_path = Path(os.path.join(data_dir,subject_file))


raw = mne.io.read_raw_brainvision(subject_path, eog=('VEOG','HEOG'), 
                                  misc='auto', scale=1.0, 
                                  preload=True, verbose=None)


raw_info = raw.info
raw_channels = raw.info['ch_names']

raw.set_montage('standard_1005')
raw.plot_sensors(show_names=True);

raw.resample(512)

raw_resampled_info = raw.info

events_from_annot, event_dict = mne.events_from_annotations(raw)

event_dict_interest = [2,5,56,59,19,22,73,76,37,40,91,94]

# event_dict_interest = {'Stimulus/S  2':2,'Stimulus/S  5':5,'Stimulus/S 56':56,'Stimulus/S 59':59,

#                        'Stimulus/S 19':19, 'Stimulus/S 22':22, 'Stimulus/S 73':73, 'Stimulus/S 76':76,

#                        'Stimulus/S 37':37, 'Stimulus/S 40':40, 'Stimulus/S 91':91, 'Stimulus/S 94':94}

 

epochs = mne.Epochs(raw, events_from_annot, event_id=event_dict_interest, 
                    tmin= - 3, tmax= 0, baseline=(-3, -2.5), picks=('C3', 'Cz', 'C4'), 
                    preload=True, event_repeated = 'merge')

epochs.set_eeg_reference(ref_channels='average')

 
# epochs = combine_event_ids(epochs,

#                                  ['Stimulus/S  2', 'Stimulus/S  5', 'Stimulus/S 56', 'Stimulus/S 59'],

#                                  {'Anger': 200})


# epochs = combine_event_ids(epochs,

#                                  ['Stimulus/S 19', 'Stimulus/S 22', 'Stimulus/S 73', 'Stimulus/S 76'],

#                                  {'Neutral': 300})

 

# epochs = combine_event_ids(epochs,

#                                  ['Stimulus/S 37', 'Stimulus/S 40', 'Stimulus/S 91', 'Stimulus/S 94'],

#                                  {'Joy': 400})

epochs_combined = combine_event_ids(epochs,['2','5','56','59'],{'Anger':1})
epochs_combined = combine_event_ids(epochs_combined,['19','22','73','76'],{'Neutral':2})
epochs_combined = combine_event_ids(epochs_combined,['37','40','91','94'],{'Joy':3})

 
epochs_combined.plot_psd(picks=['C3', 'Cz', 'C4'], fmin=0, fmax=30)


# this averages across each epoch .....
psds,freqs = psd_welch(epochs,fmin=8,fmax=13,window='hann')

from matplotlib.colors import TwoSlopeNorm
from mne.time_frequency import tfr_multitaper
from mne.stats import permutation_cluster_1samp_test as pcluster_test
import pandas as pd
import seaborn as sns

# ERD using multitaper tfr
freqs = np.arange(8, 14)  # frequencies from 2-35Hz
vmin, vmax = -1, 1.5  # set min and max ERDS values in plot
baseline = (-3, -2.5)  # baseline interval (in s)
cnorm = TwoSlopeNorm(vmin=vmin, vcenter=0, vmax=vmax)  # min, center & max ERDS

 
kwargs = dict(n_permutations=100, step_down_p=0.05, seed=1,
              buffer_size=None, out_type='mask')  # for cluster test


tfr = tfr_multitaper(epochs_combined, freqs=freqs, n_cycles=freqs, use_fft=True,
                     return_itc=False, average=False, decim=2)
tfr.crop(-3, 0).apply_baseline(baseline, mode="percent")

event_ids_combined = {'Anger':1,'Neutral':2,'Joy':3}

for event in event_ids_combined:
    # select desired epochs for visualization
    tfr_ev = tfr[event]
    fig, axes = plt.subplots(1, 4, figsize=(12, 4),
                             gridspec_kw={"width_ratios": [10, 10, 10, 1]})
    for ch, ax in enumerate(axes[:-1]):  # for each channel
        # positive clusters
        _, c1, p1, _ = pcluster_test(tfr_ev.data[:, ch], tail=1, **kwargs)
        # negative clusters
        _, c2, p2, _ = pcluster_test(tfr_ev.data[:, ch], tail=-1, **kwargs)

        # note that we keep clusters with p <= 0.05 from the combined clusters
        # of two independent tests; in this example, we do not correct for
        # these two comparisons
        c = np.stack(c1 + c2, axis=2)  # combined clusters
        p = np.concatenate((p1, p2))  # combined p-values
        mask = c[..., p <= 0.05].any(axis=-1)

        # plot TFR (ERDS map with masking)
        tfr_ev.average().plot([ch], cmap="RdBu", cnorm=cnorm, axes=ax,
                              colorbar=False, show=False, mask=mask,
                              mask_style="mask")

        ax.set_title(epochs.ch_names[ch], fontsize=10)
        ax.axvline(0, linewidth=1, color="black", linestyle=":")  # event
        if ch != 0:
            ax.set_ylabel("")
            ax.set_yticklabels("")
    fig.colorbar(axes[0].images[-1], cax=axes[-1]).ax.set_yscale("linear")
    fig.suptitle(f"ERDS ({event})")
    plt.show()
    
df = tfr.to_data_frame(time_format=None, long_format=True)

# Map to frequency bands:
freq_bounds = {'_': 0,
               'delta': 3,
               'theta': 7,
               'alpha/mu': 13,
               'beta': 35,
               'gamma': 140}
df['band'] = pd.cut(df['freq'], list(freq_bounds.values()),
                    labels=list(freq_bounds)[1:])

# Filter to retain only relevant frequency bands:
freq_bands_of_interest = ['delta', 'theta', 'alpha/mu', 'beta']

df = df[df.band.isin(freq_bands_of_interest)]
df['band'] = df['band'].cat.remove_unused_categories()

# Order channels for plotting:
df['channel'] = df['channel'].cat.reorder_categories(('C3', 'Cz', 'C4'),
                                                     ordered=True)

g = sns.FacetGrid(df, row='band', col='channel', margin_titles=True)
g.map(sns.lineplot, 'time', 'value', 'condition', n_boot=10)
axline_kw = dict(color='black', linestyle='dashed', linewidth=0.5, alpha=0.5)
g.map(plt.axhline, y=0, **axline_kw)
g.map(plt.axvline, x=0, **axline_kw)
g.set(ylim=(None, 10.))
g.set_axis_labels("Time (s)", "ERDS (%)")
g.set_titles(col_template="{col_name}", row_template="{row_name}")
g.add_legend(ncol=3,loc='lower center')
g.fig.subplots_adjust(left=0.1, right=0.9, top=0.9, bottom=0.25)
# g.fig.tight_layout()


