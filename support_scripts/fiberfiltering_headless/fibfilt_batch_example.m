%% Batch Fiber Filtering Analysis Example
% This script demonstrates headless batch processing of fiber filtering
% analyses across multiple Lead Group projects

clear all;

% Add Lead-DBS to path (adjust if needed)
% addpath('/path/to/lead-dbs');

%% Configuration
config = struct();

% Input files
config.leadgroup_files = {
    'C:\path\to\cohort1\leadgroup.mat'
    'C:\path\to\cohort2\leadgroup.mat'
    'C:\path\to\cohort3\leadgroup.mat'
};

% Analysis parameters
config.connectome = 'HCP_MGH_32fold_100k';
config.connectivity_type = 1; % 1=VAT, 2=PAM
config.statmetric = 'Correlations / E-fields (Irmen 2020)';
config.responsevar_idx = 1;
config.covars_idx = [2, 3]; % Use variables 2 and 3 as covariates
config.cv_type = 'kfold';
config.kfold = 5;

%% Run analyses
results = cell(length(config.leadgroup_files), 1);

for i = 1:length(config.leadgroup_files)
    fprintf('\n========================================\n');
    fprintf('Processing file %d/%d: %s\n', i, length(config.leadgroup_files), ...
            config.leadgroup_files{i});
    fprintf('========================================\n');

    try
        % Run main analysis
        results{i} = fibfilt_run_analysis(...
            config.leadgroup_files{i}, ...
            config.connectome, ...
            'connectivity_type', config.connectivity_type, ...
            'statmetric', config.statmetric, ...
            'responsevar_idx', config.responsevar_idx, ...
            'covars_idx', config.covars_idx, ...
            'silent', false, ...
            'save_results', true);

        % Get the saved .fibfilt path
        output_dir = fileparts(config.leadgroup_files{i});
        fibfilt_path = fullfile(output_dir, 'fiberfiltering', ...
                                [results{i}.ID, '.fibfilt']);

        % Run cross-validation
        [I, Ihat, stats] = fibfilt_run_crossval(...
            fibfilt_path, ...
            config.cv_type, ...
            'kfold', config.kfold, ...
            'silent', false);

        results{i}.cv_stats = stats;

        % Export results
        fibfilt_export_results(fibfilt_path, ...
            'threshold', 0.05, ...
            'fiberset', 'both');

        fprintf('Analysis %d complete!\n', i);

    catch ME
        fprintf('ERROR processing file %d: %s\n', i, ME.message);
        results{i} = ME;
    end
end

%% Summary
fprintf('\n========================================\n');
fprintf('BATCH PROCESSING COMPLETE\n');
fprintf('========================================\n');

for i = 1:length(results)
    if isobject(results{i}) && isa(results{i}, 'ea_disctract')
        fprintf('File %d: SUCCESS (R=%.4f, p=%.4f)\n', i, ...
                results{i}.cv_stats.r, results{i}.cv_stats.p);
    else
        fprintf('File %d: FAILED\n', i);
    end
end
