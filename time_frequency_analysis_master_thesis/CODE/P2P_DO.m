PATH='/2_TF';cd(PATH);
GO=dir('TF_FT_S*.mat');FILES=extractfield(GO,'name');
EPOCKES=dir('eS*.mat');FILES_EP=extractfield(EPOCKES,'name');load('LABELS.mat');
RAW=dir('FT_*.mat');FILES_RAW=extractfield(RAW,'name');




for i=1:length(FILES)
    D=load(FILES{i});D=D.freq_LOWFREQ;TRIALINFO=D.trialinfo;
    D2=load(FILES_EP{i});D2=D2.D;TRIALINFO2=D2.trials;
    TRIALINFOEP=extractfield(TRIALINFO2,'label');TRIALINFOEP=TRIALINFOEP';
    TRIALINFOEP2=str2num(cell2mat(strrep(TRIALINFOEP,'S','')));
    YO=find(ismember(TRIALINFOEP2,1:3:108));
    RAW_DER=load(FILES_RAW{i});RAW_DER=RAW_DER.DATA;
    RAW_DER=RAW_DER.trial;
    FREQ_A=round(D.freq);TIME=D.time;DATA=D2.data;TIMED=D.time;
    TIME_F=find(TIME>-1 & TIME<3);
    BFs={find(FREQ_A==4):find(FREQ_A==8) ...
        find(FREQ_A==9):find(FREQ_A==12) find(FREQ_A==13):find(FREQ_A==20) ...
        find(FREQ_A==21):find(FREQ_A==30) find(FREQ_A==31):find(FREQ_A==40) ...
        find(FREQ_A==60):find(FREQ_A==80) find(FREQ_A==80):find(FREQ_A==100)};
    
    TIME_TF=find(TIMED>-2.5 & TIMED<3);
    TIME_TF_BAS=find(TIMED>-2.5 & TIMED<-1);
    
    
    RAW_DER=RAW_DER(YO);
    P2Ps=[];;for z=1:length(RAW_DER);
        TP=RAW_DER{z};TP=TP(:,TIME_F);P2P_L=peak2peak(TP');P2Ps=[P2Ps P2P_L'];
    end
    
    POW=D.powspctrm; POW=POW(YO,:,:,:);
    POW_TPR=zeros(size(POW,2),length(BFs),size(POW,1));
    
    for ch=1:size(POW,2)
        for bf=1:length(BFs)
            BFd=BFs{bf};DATA_TP=[];DATA_TP(:,:)=mean(POW(:,ch,BFd,TIME_TF),3);
            DATA_BAS=[];DATA_BAS(:,:)=mean(POW(:,ch,BFd,TIME_TF_BAS),3);
            DATA_TP=mean(DATA_TP,2);DATA_BAS=mean(DATA_BAS,2);
            DATA_TP=DATA_TP-DATA_BAS;
            POW_TPR(ch,bf,:)=DATA_TP;
        end
    end

    P2P={P2Ps POW_TPR};
    FILE_SAV=strrep(FILES{i},'TF_FT','PtP');
    save(FILE_SAV,'P2P')
end
