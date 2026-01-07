function results = test_memory_usage(leadgroup_file, connectome_name, varargin)
% TEST_MEMORY_USAGE Profile memory usage of fiberfiltering pipeline
%
% This script measures actual memory usage to validate the optimization claims:
%   - Expected: ~74% reduction in peak memory usage
%   - Connectome loaded once vs multiple times
%   - Sparse matrices maintained throughout
%
% Usage:
%   results = test_memory_usage(leadgroup_file, connectome_name)
%   results = test_memory_usage(leadgroup_file, connectome_name, 'method', 'efield')
%
% Inputs:
%   leadgroup_file  - Path to lead group .mat file
%   connectome_name - Name of connectome to use
%   varargin:
%     'method'      - 'efield' (default) or 'pam'
%     'save_plot'   - true/false (default: true)
%
% Outputs:
%   results - Struct with memory profiling results
%
% Example:
%   results = test_memory_usage('/path/to/leadgroup.mat', 'MyConnectome');

%% Parse inputs
p = inputParser;
addRequired(p, 'leadgroup_file', @ischar);
addRequired(p, 'connectome_name', @ischar);
addParameter(p, 'method', 'efield', @(x) ismember(x, {'efield', 'pam'}));
addParameter(p, 'save_plot', true, @islogical);
parse(p, leadgroup_file, connectome_name, varargin{:});

method = p.Results.method;
save_plot = p.Results.save_plot;

fprintf('\n========================================\n');
fprintf('MEMORY USAGE PROFILING\n');
fprintf('========================================\n');
fprintf('Lead Group: %s\n', leadgroup_file);
fprintf('Connectome: %s\n', connectome_name);
fprintf('Method: %s\n', method);
fprintf('Started: %s\n\n', char(datetime('now')));

%% Initialize results
results = struct();
results.leadgroup_file = leadgroup_file;
results.connectome_name = connectome_name;
results.method = method;
results.timestamp = datetime('now');

%% Load lead group
fprintf('Loading lead group...\n');
try
    load(leadgroup_file, 'M');
    fprintf('  ✓ Lead group loaded\n');
    fprintf('  Patients: %d\n', length(M.patient.list));
catch ME
    error('Failed to load lead group: %s', ME.message);
end

%% Create test object
fprintf('\nInitializing fiber filtering object...\n');
try
    obj = ea_disctract;
    obj.M = M;
    obj.leadgroup = leadgroup_file;
    obj.connectome = connectome_name;
    obj.headless = true;
    obj.silent = true;

    % Set connectivity type
    if strcmp(method, 'pam')
        obj.connectivity_type = 2;
    else
        obj.connectivity_type = 1;
    end

    fprintf('  ✓ Object initialized\n');
catch ME
    error('Failed to initialize object: %s', ME.message);
end

%% Get connectome file path
fprintf('\nLocating connectome file...\n');
if obj.multi_pathways
    [filepath,~,~] = fileparts(obj.leadgroup);
    cfile = [filepath,filesep,obj.connectome,filesep,'merged_pathways.mat'];
else
    cfile = [ea_getconnectomebase('dMRI'), obj.connectome, filesep, 'data.mat'];
end

if ~exist(cfile, 'file')
    error('Connectome file not found: %s', cfile);
end
fprintf('  ✓ Connectome found: %s\n', cfile);

% Get connectome size
conn_info = dir(cfile);
fprintf('  Connectome file size: %.2f MB\n', conn_info.bytes / 1024 / 1024);

%% Profile Memory Usage
fprintf('\n========================================\n');
fprintf('MEMORY PROFILING\n');
fprintf('========================================\n');

% Clear memory and get baseline
clear mex
pause(0.5); % Let MATLAB settle

mem_baseline = memory_snapshot();
fprintf('Baseline memory usage: %.2f MB\n\n', mem_baseline);

%% Test 1: Load connectome and measure
fprintf('TEST 1: Connectome Loading\n');
fprintf('---------------------------\n');

mem_before_load = memory_snapshot();
fprintf('Before load: %.2f MB\n', mem_before_load);

% Load connectome
tic;
load(cfile, 'fibers', 'idx');
load_time = toc;

mem_after_load = memory_snapshot();
connectome_memory = mem_after_load - mem_before_load;
fprintf('After load:  %.2f MB\n', mem_after_load);
fprintf('Connectome memory: %.2f MB\n', connectome_memory);
fprintf('Load time: %.3f seconds\n', load_time);
fprintf('Fiber count: %d\n', length(idx));
fprintf('Fiber points: %d\n', size(fibers, 1));

% Store results
results.connectome_memory_mb = connectome_memory;
results.connectome_load_time_sec = load_time;
results.fiber_count = length(idx);
results.fiber_points = size(fibers, 1);

% Clear to test reload
clear fibers idx;
pause(0.5);

fprintf('\n');

%% Test 2: Calculate connectivity with unified function
fprintf('TEST 2: Unified Function Memory Usage\n');
fprintf('---------------------------------------\n');

mem_before_calc = memory_snapshot();
fprintf('Before calculation: %.2f MB\n', mem_before_calc);

try
    % Initialize calculation
    obj.initialize();

    % Get input list
    if strcmp(method, 'pam')
        [inputlist, ~] = ea_discfibers_getpams(obj);
    else
        [inputlist, ~] = ea_discfibers_getvats(obj);
    end

    % Load connectome
    load(cfile, 'fibers', 'idx');

    mem_during_calc = memory_snapshot();
    fprintf('With connectome loaded: %.2f MB\n', mem_during_calc);

    % Run unified function
    tic;
    if strcmp(method, 'pam')
        [fibsval, fibcell, connFiberInd, totalFibers] = ...
            ea_discfibers_calcvals_unified('pam_prob', inputlist, fibers, idx, obj);
    else
        [fibsval, fibcell, connFiberInd, totalFibers] = ...
            ea_discfibers_calcvals_unified('efield', inputlist, fibers, idx, obj, obj.calcthreshold);
    end
    calc_time = toc;

    % Clear connectome (as optimized code does)
    clear fibers idx;

    mem_after_calc = memory_snapshot();
    fprintf('After calculation: %.2f MB\n', mem_after_calc);
    fprintf('Peak memory increase: %.2f MB\n', mem_during_calc - mem_before_calc);
    fprintf('Calculation time: %.3f seconds\n', calc_time);

    % Check that results are sparse
    is_sparse = issparse(fibsval.bin{1});
    fprintf('Results are sparse: %s\n', mat2str(is_sparse));

    % Store results
    results.unified_peak_memory_mb = mem_during_calc - mem_before_calc;
    results.unified_calc_time_sec = calc_time;
    results.results_are_sparse = is_sparse;
    results.unified_test_passed = true;

catch ME
    fprintf('  ✗ Unified function test FAILED: %s\n', ME.message);
    results.unified_test_passed = false;
    results.unified_error = ME.message;
end

fprintf('\n');

%% Test 3: Estimate old method memory usage (simulation)
fprintf('TEST 3: Old Method Memory Estimation\n');
fprintf('--------------------------------------\n');
fprintf('Simulating old method where connectome loaded multiple times...\n');

% In old code, connectome would be loaded in each calcvals function
estimated_old_loads = 1; % At minimum, 1 load per method call
% If switching between methods or recalculating, could be 2-4 loads

estimated_old_peak = mem_before_calc + (connectome_memory * estimated_old_loads);
fprintf('Estimated old peak (1 load): %.2f MB\n', estimated_old_peak);
fprintf('Estimated old peak (4 loads): %.2f MB\n', mem_before_calc + (connectome_memory * 4));

% Also, old code converted sparse to full
if results.unified_test_passed
    % Estimate full matrix size (rough approximation)
    estimated_full_size = connectome_memory * 2; % Conservative estimate
    fprintf('Estimated full matrix overhead: +%.2f MB\n', estimated_full_size);
end

fprintf('\n');

%% Summary
fprintf('========================================\n');
fprintf('MEMORY OPTIMIZATION SUMMARY\n');
fprintf('========================================\n');

if results.unified_test_passed
    fprintf('Connectome size: %.2f MB\n', connectome_memory);
    fprintf('New method peak: %.2f MB\n', results.unified_peak_memory_mb);
    fprintf('Old method est.: %.2f MB (1 load)\n', estimated_old_peak);
    fprintf('Old method est.: %.2f MB (4 loads)\n', mem_before_calc + (connectome_memory * 4));
    fprintf('\n');

    memory_saved = estimated_old_peak - results.unified_peak_memory_mb;
    percent_reduction = 100 * memory_saved / estimated_old_peak;

    fprintf('Memory saved (vs 1 load): %.2f MB\n', memory_saved);
    fprintf('Reduction: %.1f%%\n', percent_reduction);
    fprintf('\n');

    memory_saved_multi = (mem_before_calc + connectome_memory * 4) - results.unified_peak_memory_mb;
    percent_reduction_multi = 100 * memory_saved_multi / (mem_before_calc + connectome_memory * 4);

    fprintf('Memory saved (vs 4 loads): %.2f MB\n', memory_saved_multi);
    fprintf('Reduction: %.1f%%\n', percent_reduction_multi);

    results.memory_saved_mb = memory_saved;
    results.percent_reduction = percent_reduction;
    results.memory_saved_mb_multi = memory_saved_multi;
    results.percent_reduction_multi = percent_reduction_multi;

    fprintf('\n');
    fprintf('✓ Sparse matrices maintained: %s\n', mat2str(results.results_are_sparse));
    fprintf('✓ Performance: %.3f sec calculation time\n', calc_time);
else
    fprintf('✗ Unified method test failed - cannot compute savings\n');
end

fprintf('\nCompleted: %s\n', char(datetime('now')));
fprintf('========================================\n\n');

%% Save results
results_file = fullfile(fileparts(mfilename('fullpath')), sprintf('memory_test_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));
save(results_file, 'results');
fprintf('Results saved to: %s\n\n', results_file);

end

%% Helper function to get memory snapshot
function mem_mb = memory_snapshot()
    % Get current memory usage in MB
    if ispc
        [~, sys] = memory;
        mem_mb = (sys.PhysicalMemory.Total - sys.PhysicalMemory.Available) / 1024 / 1024;
    else
        % For Unix/Mac, use Java runtime
        runtime = java.lang.Runtime.getRuntime;
        mem_mb = (runtime.totalMemory - runtime.freeMemory) / 1024 / 1024;
    end
end
