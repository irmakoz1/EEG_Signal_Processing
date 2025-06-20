addpath('/MATLAB_TOOLBOXES/fieldtrip-20210212')
addpath('/MATLAB_TOOLBOXES/spm/spm12')

PATH='/analyses EEG/export/';%METTRE L'EXCEL ET LES DONNEES PATENT DANS CE FOLDER
% PATH='\1_CONVERTED';%METTRE L'EXCEL ET LES DONNEES PATENT DANS CE FOLDER
cd(PATH)
PAT='S07';%NOM DU FICHIER PATIENT QUE TU SOUHAITES OBTENIR
% BEH='S01.xlsx';%FICHIER COMPORTEMENT 

%% CONVERSION DU FICHIER BRUT
% matlabbatch{1}.spm.meeg.convert.dataset = { [PATH PAT '_Change Sampling Rate.dat']};
% matlabbatch{1}.spm.meeg.convert.mode.continuous.readall = 1;
% matlabbatch{1}.spm.meeg.convert.channels{1}.all = 'all';
% matlabbatch{1}.spm.meeg.convert.outfile = [PATH  PAT '.mat'];
% matlabbatch{1}.spm.meeg.convert.checkboundary = 1;
% matlabbatch{1}.spm.meeg.convert.saveorigheader = 0;
% matlabbatch{1}.spm.meeg.convert.inputformat = 'autodetect';
% spm('defaults', 'eeg');
% spm_jobman('run', matlabbatch);

D=spm_eeg_load([PAT '.mat'])
%%EPOCHING 
spm('defaults', 'eeg');
S = [];
S.D = [PATH filesep PAT];
S.fsample = 256;
S.timeonset = 0;
S.bc = 0;
S.inputformat = [];
S.pretrig = -7000;
S.posttrig = 7000;
S.timewin=[-7000 7000];
S.baselineevents=0;%option 0 = no baseline correction; other = -mean/std;
% S.baseline_tw=[-1000 -250];
for i=1:9
expr=['S.trialdef(' num2str(i) ').conditionlabel = ''S  ' num2str(i) ''';'];;eval(expr);
expr=['S.trialdef(' num2str(i) ').eventtype = ''Stimulus'';'];eval(expr);
expr=['S.trialdef(' num2str(i) ').eventvalue = ''S  ' num2str(i) ''';'];;eval(expr);
end
for i=10:108
expr=['S.trialdef(' num2str(i) ').conditionlabel = ''S ' num2str(i) ''';'];;eval(expr);
expr=['S.trialdef(' num2str(i) ').eventtype = ''Stimulus'';'];eval(expr);
expr=['S.trialdef(' num2str(i) ').eventvalue = ''S ' num2str(i) ''';'];;eval(expr);
end
D = spm_eeg_epochs(S);

cd(PATH)
% [A B BEHS]=xlsread(BEH);
% BEH_TOTAL=[];BEH_TOTAL.header=BEHS(1,:);BEHS(1,:)=[];
% BEH_TOTAL.data=BEHS;
DATA=spm2fieldtrip(D);



% DATA.BEHAVIOR=BEH_TOTAL;
save(['FT_'  PAT],'DATA','-v7.3');


D=DATA;
time=D.time;time=time{1};
timing=time;
timelist=timing(find(timing>=-7 & timing<=7));
ntimes   = length(timelist);
tim      = time;
tlim     = round([min(tim), max(tim)]); % this will not work if time lim are not integers 
if ~isfield(D,'fsample');D.fsample=256;end;
tdur     = numel(time)/D.fsample;  

   
freqlist=[ (2:1:40) (40:5:100)];
freqlist = round(freqlist*tdur)/tdur; % round to computable frequencies
nfreqs   = length(freqlist);

% define multitapering parameters
timwin = nan(size(freqlist));
tapsmofrq = nan(size(freqlist));
% low frequencies
i = find(freqlist <= 40);
timwin(i)    = 4./freqlist(i); % 7 cycles
% timwin(i) = 0.4.*ones(1,length(i)); % 250 ms
tapsmofrq(i) = freqlist(i)/3;  % 0.375*
% high frequenciesfreq_LOWFREQPW = 10*log10(freq_LOWFREQPW);freq_LOWFREQ.powspctrm=freq_LOWFREQPW;

i = find(freqlist >  40);
timwin(i) = 0.4.*ones(1,length(i)); % 400 ms
typsmofrq = 'fixed';
switch typsmofrq
    case 'fixed' % fixed
        tapsmofrq(i) = 10.*ones(1,length(i));
    case 'adapt' % adaptive
        tapsmofrq(i) = freqlist(i)/3;
        k = floor(2*timwin(i).*tapsmofrq(i)-1);
        tapsmofrq(i) = (k+1)/2./timwin(i);
    otherwise
        error('unknown type of frequency smoothing!');
end
toi=time(1):0.05:time(end);

% conds=condss(ft2);
%% multitapecondssr
% 
% 
cfg=[];
trial_number='all';
cfg.method     = 'mtmconvol';
cfg.output     = 'pow'  ;
cfg.taper      = 'hanning';
cfg.foi        = freqlist;
% cfg.tapsmofrq= tapsmofrq; %10 Hz frequency smoothing 
cfg.t_ftimwin=timwin;
cfg.toi=toi;
 cfg.trials     ='all';
%  cfg.trials     =1:5;
  cfg.channels     = 'all';
 cfg.keeptrials='yes';
[freq_LOWFREQ] = ft_freqanalysis(cfg, D)


cfg=[];
trial_number='all';
cfg.method     = 'mtmconvol';
cfg.output     = 'pow'  ;
cfg.taper      = 'dpss';
cfg.foi        = freqlist(40:52);
cfg.tapsmofrq= tapsmofrq(40:52); %10 Hz frequency smoothing 
cfg.t_ftimwin=timwin(40:52);
cfg.toi=toi;
 cfg.trials     ='all';
%   cfg.trials     =1:5;
  cfg.channels     = 'all';
 cfg.keeptrials='yes';
[freq_HIGHFREQ] = ft_freqanalysis(cfg, D)


POW1=freq_LOWFREQ.powspctrm;POW2=freq_HIGHFREQ.powspctrm;
POW1(:,:,40:52,:)=POW2;
POW1 = 10*log10(POW1);
freq_LOWFREQ.powspctrm=POW1;

save(['TF_FT_'  PAT '.mat'],'freq_LOWFREQ','-v7.3');
