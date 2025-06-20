addpath('/home/benis/MATLAB_TOOLBOXES/fieldtrip-20220104')
addpath('/home/benis/MATLAB_TOOLBOXES/spm/spm12')

clear all
PATH='/home/benis/Irmak/3_CONDITIONS_TF';%METTRE L'EXCEL ET LES DONNEES PATENT DANS CE FOLDER
% PATH='M:\NEAD\Irmak\1_CONVERTED';%METTRE L'EXCEL ET LES DONNEES PATENT DANS CE FOLDER
cd(PATH)
load('AVERAGES.mat'); load(['VEOG.mat']);
EVENT=ALL{2};load('LABELS.mat');LAB_EV=load('LABELS.mat');LAB_EV=LAB_EV.LABEL;
GOGON=unique(EVENT);
for i =1:length(GOGON)
    FILE=[strrep(GOGON{i},' ','')];
    EXP=[FILE '=TEMPLATE;'];eval(EXP);
end


for i=3:length(LABEL)
    CHANO=LABEL{i};load([CHANO '.mat']);POW_ALL=ALL{1};EVENT=ALL{2};CHANO
    for j =1:length(GOGON)
        EVENT_TP=GOGON(j);
        FILE=[strrep(GOGON{j},' ','')];
        expr=['POW=' FILE '.powspctrm;'];eval(expr); 
        WHERE=find(strcmp(EVENT,EVENT_TP));
        POW_TP2=POW_ALL(WHERE,:,:);POW_TP=[];POW_TP(:,:)=mean(POW_TP2);
        POW_TP(39,:)=[];POW(i,:,:)=POW_TP;
        expr=[FILE '.powspctrm=POW;'];eval(expr); 
    end
end

save('MADE_AVERAGE.mat','-v7.3');
