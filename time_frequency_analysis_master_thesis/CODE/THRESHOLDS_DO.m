PATH='/2_TF';cd(PATH);
GO=dir('PtP_S*.mat');FILES=extractfield(GO,'name');


P2P_RAW_K=[];P2P_1_K=[];P2P_2_K=[];P2P_3_K=[];P2P_4_K=[];P2P_5_K=[];
P2P_6_K=[];P2P_7_K=[];
for i=1:length(FILES)
P2P=load(FILES{i});P2P=P2P.P2P;P2P_J=P2P{1};P2P_J=reshape(P2P_J,1,[]);P2P_RAW=P2P_J';
P2P_J=P2P{2};P2P_1=[];P2P_1(:,:)=P2P_J(:,1,:);P2P_1=reshape(P2P_1,1,[]);P2P_1=P2P_1';
P2P_2=[];P2P_2(:,:)=P2P_J(:,2,:);P2P_2=reshape(P2P_2,1,[]);P2P_2=P2P_2';
P2P_3=[];P2P_3(:,:)=P2P_J(:,3,:);P2P_3=reshape(P2P_3,1,[]);P2P_3=P2P_3';
P2P_4=[];P2P_4(:,:)=P2P_J(:,4,:);P2P_4=reshape(P2P_4,1,[]);P2P_4=P2P_4';
P2P_5=[];P2P_5(:,:)=P2P_J(:,5,:);P2P_5=reshape(P2P_5,1,[]);P2P_5=P2P_5';
P2P_6=[];P2P_6(:,:)=P2P_J(:,6,:);P2P_6=reshape(P2P_6,1,[]);P2P_6=P2P_6';
P2P_7=[];P2P_7(:,:)=P2P_J(:,7,:);P2P_7=reshape(P2P_7,1,[]);P2P_7=P2P_7';

P2P_RAW_K=[P2P_RAW_K; P2P_RAW];P2P_1_K=[P2P_1_K; P2P_1];P2P_2_K=[P2P_2_K; P2P_2];
P2P_3_K=[P2P_3_K; P2P_3];P2P_4_K=[P2P_4_K; P2P_4];P2P_5_K=[P2P_5_K; P2P_5];
P2P_6_K=[P2P_6_K; P2P_6];P2P_7_K=[P2P_7_K; P2P_7];
end

P2P_RAW_THR=median(P2P_RAW_K)+3*std(P2P_RAW_K);
P2P_1_THR=median(P2P_1_K)+3*std(P2P_1_K);
P2P_2_THR=median(P2P_2_K)+3*std(P2P_2_K);
P2P_3_THR=median(P2P_3_K)+3*std(P2P_3_K);
P2P_4_THR=median(P2P_4_K)+3*std(P2P_4_K);
P2P_5_THR=median(P2P_5_K)+3*std(P2P_5_K);
P2P_6_THR=median(P2P_6_K)+3*std(P2P_6_K);
P2P_7_THR=median(P2P_7_K)+3*std(P2P_7_K);

THRSH=[P2P_RAW_THR P2P_1_THR P2P_2_THR P2P_3_THR P2P_4_THR P2P_5_THR P2P_6_THR P2P_7_THR];

P2P_1_THR=median(P2P_1_K)-3*std(P2P_1_K);
P2P_2_THR=median(P2P_2_K)-3*std(P2P_2_K);
P2P_3_THR=median(P2P_3_K)-3*std(P2P_3_K);
P2P_4_THR=median(P2P_4_K)-3*std(P2P_4_K);
P2P_5_THR=median(P2P_5_K)-3*std(P2P_5_K);
P2P_6_THR=median(P2P_6_K)-3*std(P2P_6_K);
P2P_7_THR=median(P2P_7_K)-3*std(P2P_7_K);

THRSHL=[P2P_RAW_THR P2P_1_THR P2P_2_THR P2P_3_THR P2P_4_THR P2P_5_THR P2P_6_THR P2P_7_THR];

THRS={THRSH THRSHL};
save('THR.mat','THRS')
