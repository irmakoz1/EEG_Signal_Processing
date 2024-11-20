
function batch_script_demo(data_files_cell)
% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'C:\Users\irmak\Downloads\DCM_for_ERPs-main\DCM_for_ERPs-main\DCM_output\DCM_BATCH_SCRIPT_DEMO_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(1, nrun);
for crun = 1:nrun
  inputs{crun, nrun} =cellstr(data_files_cell)
end
spm('defaults', 'EEG');
spm_jobman('run', jobs, inputs{:});

end

%batch format needs to be cell.
%then open your dcm model inn dcm load model. Below you can change
%parameters to access graphs.