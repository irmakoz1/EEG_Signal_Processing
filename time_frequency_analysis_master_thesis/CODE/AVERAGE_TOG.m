addpath('/MATLAB_TOOLBOXES/fieldtrip-20220104')
addpath('/MATLAB_TOOLBOXES/spm/spm12')

clear all
PATH='/3_CONDITIONS_TF';%METTRE L'EXCEL ET LES DONNEES PATENT DANS CE FOLDER
% PATH='\1_CONVERTED';%METTRE L'EXCEL ET LES DONNEES PATENT DANS CE FOLDER
cd(PATH)
load('AVERAGES.mat'); load(['VEOG.mat']);
EVENT=ALL{2};load('LABELS.mat');LAB_EV=load('LABELS_EV.mat');LAB_EV=LAB_EV.LABEL;

ACC=[0 1 0];

[OUT, CONDITIONS_TO_COMP]=generate_permute(LAB_EV,ACC)

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



function [OUT, CONDITIONS_TO_COMP]=generate_permute(LAB_EV,ACC)

EMOS=unique(LAB_EV(:,1));COND=unique(LAB_EV(:,2));FEED=unique(LAB_EV(:,3));

if ACC(1)==1 && ACC(2)==0 && ACC(3)==0
    OUT=EMOS;CONDITIONS_TO_COMP=[];
    for i=1:length(OUT);
        LACOND=OUT(i);LAQUELLE=find(strcmp(LAB_EV(:,1),LACOND));
        CONDITIONS_TO_COMP=[CONDITIONS_TO_COMP; {LAB_EV(LAQUELLE,4)}];
    end
elseif ACC(1)==0 && ACC(2)==1 && ACC(3)==0
    OUT=COND;CONDITIONS_TO_COMP=[];
    for i=1:length(OUT);
        LACOND=OUT(i);LAQUELLE=find(strcmp(LAB_EV(:,2),LACOND));
        CONDITIONS_TO_COMP=[CONDITIONS_TO_COMP; {LAQUELLE}];
    end
elseif ACC(1)==0 && ACC(2)==0 && ACC(3)==1
    OUT=FEED;CONDITIONS_TO_COMP=[];
    for i=1:length(OUT);
        LACOND=OUT(i);LAQUELLE=find(strcmp(LAB_EV(:,3),LACOND));
        CONDITIONS_TO_COMP=[CONDITIONS_TO_COMP; {LAQUELLE}];
    end    
elseif ACC(1)==1 && ACC(2)==1 && ACC(3)==0
   [Ax,Bx] = ndgrid(1:numel(EMOS),1:numel(COND));
    D = strcat(EMOS(Ax(:)),'-',COND(Bx(:)));
    OUT=D ;CONDITIONS_TO_COMP=[];
    for i=1:length(OUT);
        LACOND=OUT(i);AS=strsplit(cell2mat(LACOND),'-');      
        LAQUELLE1=find(strcmp(LAB_EV(:,1),AS{1}));
        LAQUELLE2=find(strcmp(LAB_EV(:,2),AS{2}));

        
        CONDITIONS_TO_COMP=[CONDITIONS_TO_COMP; {LAQUELLE}];
    end        
    
end
end
