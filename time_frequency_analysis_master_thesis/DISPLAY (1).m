clear all
close all

cd('D:\SWITCH\IRMAK\4_AVG\')
load('D:\SWITCH\IRMAK\4_AVG\MADE_AVERAGE_COND.mat')


cfg = []; 
cfg.linewidth=2;cfg.linecolor='brk'; cfg.showlegend='yes';cfg.title=0; cfg.fontsize=25;
cfg.marker       = 'on';
cfg.xlim         = [-2.5 3];cfg.ylim         = [4 100];cfg.zlim         = [-3 3];
cfg.colormap         = 'jet';
cfg.layout       = 'biosemi64.lay';cfg.showlabels='yes';
ft_multiplotTFR(cfg,A_I_COND);

POW=N_N_COND.powspctrm-N_I_COND.powspctrm;
D_COND=A_N_COND;
D_COND.powspctrm=POW;

cfg = []; cfg.channel = {'C1' 'C2' 'Cz','CP1','CP2','CPz'}; 
cfg.linewidth=2;cfg.linecolor='brk'; cfg.showlegend='yes';cfg.title=0; cfg.fontsize=25;
cfg.marker       = 'on';
cfg.xlim         = [-2.5 3];cfg.ylim         = [4 100];cfg.zlim         = [-2 2];
cfg.colormap         = 'jet';
cfg.layout       = 'biosemi64.lay';cfg.showlabels='yes';
ft_singleplotTFR(cfg,D_COND);



POW=A_COND.powspctrm-N_COND.powspctrm;
D_COND=N_COND;D_COND.powspctrm=POW; %compute difference between condition

cfg = []; cfg.channel = {'Fp1' 'Fpz' 'Fp2','AF3','AFz','AF4','Fz','F1','F2'}; 
cfg.linewidth=2;cfg.linecolor='brk'; cfg.showlegend='yes';cfg.title=0; cfg.fontsize=25;
cfg.marker       = 'on';
cfg.xlim         = [-2.5 3];cfg.ylim         = [4 100];cfg.zlim         = [-2 2];
cfg.colormap         = 'jet';
cfg.layout       = 'biosemi64.lay';cfg.showlabels='yes';
ft_singleplotTFR(cfg,N_I_COND);
