PATH='/home/benis/Irmak/2_TF';cd(PATH);
PATH_SEPFILES='/home/benis/Irmak/3_CONDITIONS_TF';
GO=dir('TF_FT*.mat');FILES=extractfield(GO,'name');
EPOCKES=dir('eS*.mat');FILES_EP=extractfield(EPOCKES,'name');load('LABELS.mat');
THRS=load('THR.mat');cd(PATH);D=load(FILES{1});D=D.freq_LOWFREQ;TRIALINFO=D.trialinfo;
CHANNELS=D.label;FREQ_A=round(D.freq);THRS=THRS.THRS;
THRH=THRS{1};THRL=THRS{2};

    BFs={find(FREQ_A==4):find(FREQ_A==8) ...
        find(FREQ_A==9):find(FREQ_A==12) find(FREQ_A==13):find(FREQ_A==20) ...
        find(FREQ_A==21):find(FREQ_A==30) find(FREQ_A==31):find(FREQ_A==40) ...
        find(FREQ_A==60):find(FREQ_A==80) find(FREQ_A==80):find(FREQ_A==100)};

for CHAN_id=1:length(CHANNELS)
    POW_ALL=[];EVENTS_ALL=[];PAT_ALL=[];
    for i=1:length(FILES)
        cd(PATH);D=load(FILES{i});
        D2=load(FILES_EP{i});D2=D2.D;TRIALINFO2=D2.trials;D=D.freq_LOWFREQ;
        TRIALINFOEP=extractfield(TRIALINFO2,'label');
    TRIALINFOEP2=str2num(cell2mat(strrep(TRIALINFOEP,'S','')));
    YO=find(ismember(TRIALINFOEP2,1:3:108));
    TRIALINFOEP=TRIALINFOEP(YO);   TIMED=D.time; TIME_TF_BAS=find(TIMED>-2.5 & TIMED<-1);

        FILE_SAV=strrep(FILES{i},'TF_FT','PtP');P2P=load(FILE_SAV);P2P=P2P.P2P;
        POW=D.powspctrm;POW=POW(YO,:,:,:);
        BAD=P2P{1};BAD=BAD(CHAN_id,:);BAD_1=find(BAD>THRH(1));
        BAD2=P2P{2};for bfgs=1:7;BAD=[];BAD(:,:)=BAD2(:,bfgs,:);
        BAD=BAD(CHAN_id,:);BAD_2H=find(BAD>THRH(2));BAD_2L=find(BAD<THRL(2));
        BAD_1=unique([BAD_1 BAD_2H BAD_2L]);end;
        POWs=[];POWs(:,:,:)=POW(:,CHAN_id,:,:);POWs(BAD_1,:,:,:)=[];
        BAS_C=mean(POWs(:,:,TIME_TF_BAS),3);
        for tr=1:size(POWs,1)
            for fr=1:size(POWs,2)
                POWsTP=[];POWsTP(:,:)=POWs(tr,fr,:);
                BAS_CTP=BAS_C(tr,fr);POWsTP=POWsTP-BAS_CTP;%baseline correction absolute
                POWs(tr,fr,:)=POWsTP;
            end
        end
        
        TRIALINFO_K=TRIALINFOEP;TRIALINFO_K(BAD_1)=[];
        POW_ALL=[POW_ALL; POWs];EVENTS_ALL=[EVENTS_ALL; TRIALINFO_K'];PAT_ALL=[PAT_ALL; repmat(FILES(i),length(TRIALINFO_K),1)];
    end
            cd(PATH_SEPFILES);ALL={POW_ALL EVENTS_ALL PAT_ALL};
save([CHANNELS{CHAN_id} '.mat'],'ALL','-v7.3')
end