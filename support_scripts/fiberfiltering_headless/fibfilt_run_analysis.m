function results = fibfilt_run_analysis(leadgroup_path, connectome_name, varargin)
% FIBFILT_RUN_ANALYSIS - Headless fiber filtering analysis
%
% Syntax:
%   results = fibfilt_run_analysis(leadgroup_path, connectome_name)
%   results = fibfilt_run_analysis(..., 'Name', Value)
%
% Inputs:
%   leadgroup_path - Path to Lead Group .mat file
%   connectome_name - Name of dMRI connectome
%
% Optional Parameters (as name-value pairs):
%   'connectivity_type' - 1 (VAT, default) or 2 (PAM)
%   'statmetric' - Statistical test to use (default: 'Two-Sample T-Tests...')
%   'native' - Calculate in native (1) or template (0) space (default: 1)
%   'patientselection' - Indices of patients to include (default: all)
%   'responsevar_idx' - Index of clinical variable to use (default: 1)
%   'covars_idx' - Indices of covariates (default: [])
%   'calcthreshold' - Threshold for calculations (default: 0.05)
%   'corrtype' - 'Spearman' or 'Pearson' (default: 'Spearman')
%   'silent' - Suppress output (default: false)
%   'save_results' - Save .fibfilt file (default: true)
%   'output_dir' - Where to save results (default: leadgroup dir)
%
% Output:
%   results - ea_disctract object with computed results
%
% Example:
%   obj = fibfilt_run_analysis('/path/to/leadgroup.mat', 'MyConnectome', ...
%                              'connectivity_type', 1, ...
%                              'statmetric', 'Correlations / E-fields (Irmen 2020)');

% Parse inputs
p = inputParser;
addRequired(p, 'leadgroup_path', @ischar);
addRequired(p, 'connectome_name', @ischar);
addParameter(p, 'connectivity_type', 1, @isnumeric);
addParameter(p, 'statmetric', 'Two-Sample T-Tests / VTAs (Baldermann 2019) / PAM (OSS-DBS)', @ischar);
addParameter(p, 'native', 1, @isnumeric);
addParameter(p, 'patientselection', [], @isnumeric);
addParameter(p, 'responsevar_idx', 1, @isnumeric);
addParameter(p, 'covars_idx', [], @isnumeric);
addParameter(p, 'calcthreshold', 0.05, @isnumeric);
addParameter(p, 'corrtype', 'Spearman', @ischar);
addParameter(p, 'silent', false, @islogical);
addParameter(p, 'save_results', true, @islogical);
addParameter(p, 'output_dir', '', @ischar);
parse(p, leadgroup_path, connectome_name, varargin{:});
opts = p.Results;

% Initialize headless object
if ~opts.silent
    fprintf('Initializing fiber filtering in headless mode...\n');
end
obj = ea_disctract();
obj.headless = true;
obj.silent = opts.silent;

% Load Lead Group project
obj.initialize(opts.leadgroup_path, []);

% Configure analysis
obj.connectome = opts.connectome_name;
obj.connectivity_type = opts.connectivity_type;
obj.statmetric = opts.statmetric;
obj.native = opts.native;
obj.calcthreshold = opts.calcthreshold;
obj.corrtype = opts.corrtype;

% Set patient selection
if isempty(opts.patientselection)
    obj.patientselection = 1:length(obj.M.patient.list);
else
    obj.patientselection = opts.patientselection;
end

% Set response variable
obj.responsevar = obj.M.clinical.vars{opts.responsevar_idx};
obj.responsevarlabel = obj.M.clinical.labels{opts.responsevar_idx};

% Set covariates
if ~isempty(opts.covars_idx)
    for i = 1:length(opts.covars_idx)
        obj.covars{i} = obj.M.clinical.vars{opts.covars_idx(i)};
        obj.covarlabels{i} = obj.M.clinical.labels{opts.covars_idx(i)};
    end
end

% Run calculation
if ~opts.silent
    fprintf('Running fiber filtering calculation...\n');
end
obj.calculate();

% Save results
if opts.save_results
    if isempty(opts.output_dir)
        output_dir = fileparts(opts.leadgroup_path);
    else
        output_dir = opts.output_dir;
    end

    save_path = fullfile(output_dir, 'fiberfiltering', [obj.ID, '.fibfilt']);
    if ~opts.silent
        fprintf('Saving results to: %s\n', save_path);
    end
    tractset = obj;
    save(save_path, 'tractset', '-v7.3');
end

results = obj;
if ~opts.silent
    fprintf('Analysis complete!\n');
end

end
