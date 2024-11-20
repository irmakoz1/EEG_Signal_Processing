% Task: ERP study->3D source reconstruction (forward modeling)-> DCM (bayes
% inference/ define matrices for forward-backward connections in the cortex (regions mapped in the matrix as 0-1)
%predicting connections forward, backward is mostly prediction errors

D= spm_eeg_load('mfaeffspmeeg_example_data_proc.mat');
D.inv={};
D.save;

%template or mri / after ccoregister
D.conditions
%BATCH NEXT TO QUIT IN SPM (DCM-> DCM FOR EEG SELECT. TO ACCESS BATCH.