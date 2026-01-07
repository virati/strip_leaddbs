function fibfilt_export_results(fibfilt_path, varargin)
% FIBFILT_EXPORT_RESULTS - Export fiber filtering results
%
% Syntax:
%   fibfilt_export_results(fibfilt_path)
%   fibfilt_export_results(fibfilt_path, 'Name', Value)
%
% Inputs:
%   fibfilt_path - Path to .fibfilt file
%
% Optional Parameters:
%   'export_nifti' - Export to NIfTI format (default: true)
%   'export_trk' - Export to .trk format (default: true)
%   'export_model' - Export fiber score model (default: true)
%   'threshold' - Threshold for fiber selection (default: 0.05)
%   'fiberset' - 'positive', 'negative', or 'both' (default: 'both')
%   'output_dir' - Output directory (default: same as fibfilt)
%   'silent' - Suppress output (default: false)

% Parse inputs
p = inputParser;
addRequired(p, 'fibfilt_path', @ischar);
addParameter(p, 'export_nifti', true, @islogical);
addParameter(p, 'export_trk', true, @islogical);
addParameter(p, 'export_model', true, @islogical);
addParameter(p, 'threshold', 0.05, @isnumeric);
addParameter(p, 'fiberset', 'both', @ischar);
addParameter(p, 'output_dir', '', @ischar);
addParameter(p, 'silent', false, @islogical);
parse(p, fibfilt_path, varargin{:});
opts = p.Results;

% Load fiber filtering object
if ~opts.silent
    fprintf('Loading fiber filtering model: %s\n', opts.fibfilt_path);
end
load(opts.fibfilt_path, '-mat', 'tractset');

% Set output directory
if isempty(opts.output_dir)
    output_dir = fileparts(opts.fibfilt_path);
else
    output_dir = opts.output_dir;
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
end

[~, base_name, ~] = fileparts(opts.fibfilt_path);

% Get fiber data
[vals, fibcell, usedidx] = ea_discfibers_calcstats(tractset, tractset.patientselection);

% Save intermediate .mat with fibers
fiber_mat_path = fullfile(output_dir, [base_name, '_fibers.mat']);
save(fiber_mat_path, 'vals', 'fibcell', 'usedidx', '-v7.3');
if ~opts.silent
    fprintf('Saved fiber data to: %s\n', fiber_mat_path);
end

% Export to NIfTI
if opts.export_nifti
    if ~opts.silent
        fprintf('Exporting to NIfTI format...\n');
    end
    nifti_path = fullfile(output_dir, [base_name, '_', opts.fiberset, '.nii']);
    ea_discfibers2nifti(fiber_mat_path, opts.threshold, opts.fiberset, nifti_path);
    if ~opts.silent
        fprintf('  Saved: %s\n', nifti_path);
    end
end

% Export to TRK
if opts.export_trk
    if ~opts.silent
        fprintf('Exporting to TRK format...\n');
    end
    trk_path = fullfile(output_dir, [base_name, '_', opts.fiberset]);
    ea_discfibers2trk(fiber_mat_path, opts.fiberset, trk_path);
    if ~opts.silent
        fprintf('  Saved: %s.trk\n', trk_path);
    end
end

% Export fiber score model
if opts.export_model
    if ~opts.silent
        fprintf('Exporting fiber score model...\n');
    end
    model_path = fullfile(output_dir, [base_name, '_model.mat']);
    ea_save_fibscore_model(tractset, model_path);
    if ~opts.silent
        fprintf('  Saved: %s\n', model_path);
    end
end

if ~opts.silent
    fprintf('Export complete!\n');
end

end
