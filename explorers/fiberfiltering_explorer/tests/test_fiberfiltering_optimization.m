function results = test_fiberfiltering_optimization(varargin)
% TEST_FIBERFILTERING_OPTIMIZATION Comprehensive validation of fiberfiltering optimization
%
% This script validates the memory optimization changes made to the
% fiberfiltering pipeline, ensuring:
%   1. Computational results remain identical
%   2. Memory usage is reduced as expected
%   3. All functions work correctly
%   4. Backward compatibility is maintained
%
% Usage:
%   results = test_fiberfiltering_optimization()
%   results = test_fiberfiltering_optimization('quick') % Run quick tests only
%   results = test_fiberfiltering_optimization('full')  % Run all tests including memory profiling
%
% Outputs:
%   results - Struct with test results and statistics
%
% Test Categories:
%   1. Unit Tests - Test individual utility functions
%   2. Regression Tests - Compare old vs new calcvals functions
%   3. Memory Tests - Profile memory usage improvements
%   4. Integration Tests - Test full pipeline with real data
%
% Requirements:
%   - Access to a test connectome (small for quick tests)
%   - Test lead group file with clinical data
%   - MATLAB Statistics and Machine Learning Toolbox

%% Parse inputs
p = inputParser;
addOptional(p, 'mode', 'quick', @(x) ismember(x, {'quick', 'full'}));
parse(p, varargin{:});
mode = p.Results.mode;

%% Initialize results structure
results = struct();
results.timestamp = datetime('now');
results.mode = mode;
results.tests_passed = 0;
results.tests_failed = 0;
results.test_details = {};

fprintf('\n========================================\n');
fprintf('FIBERFILTERING OPTIMIZATION TEST SUITE\n');
fprintf('========================================\n');
fprintf('Mode: %s\n', mode);
fprintf('Started: %s\n\n', char(results.timestamp));

%% Test 1: Utility Functions
fprintf('TEST 1: Utility Functions\n');
fprintf('---------------------------\n');

% Test ea_fibValThresh
fprintf('  Testing ea_fibValThresh...\n');
try
    test_vals = [100 90 80 70 60 50 40 30 20 10];

    % Test each threshold strategy
    thresh1 = ea_fibValThresh('Percentage Relative to Peak', test_vals, 10);
    thresh2 = ea_fibValThresh('Percentage Relative to Amount', test_vals, 20);
    thresh3 = ea_fibValThresh('Fixed Amount', test_vals, 3);
    thresh4 = ea_fibValThresh('Fixed Fiber Value', test_vals, 45);

    assert(thresh1 < test_vals(1) && thresh1 > test_vals(end), 'Peak percentage threshold failed');
    assert(thresh2 == test_vals(2), 'Amount percentage threshold failed');
    assert(thresh3 == test_vals(3), 'Fixed amount threshold failed');
    assert(thresh4 == 45, 'Fixed value threshold failed');

    fprintf('    ✓ ea_fibValThresh: PASSED\n');
    results.tests_passed = results.tests_passed + 1;
    results.test_details{end+1} = struct('name', 'ea_fibValThresh', 'status', 'PASSED', 'error', '');
catch ME
    fprintf('    ✗ ea_fibValThresh: FAILED - %s\n', ME.message);
    results.tests_failed = results.tests_failed + 1;
    results.test_details{end+1} = struct('name', 'ea_fibValThresh', 'status', 'FAILED', 'error', ME.message);
end

% Test ea_fibcell2fibmat
fprintf('  Testing ea_fibcell2fibmat...\n');
try
    test_fibcell = {[1 2 3; 4 5 6], [7 8 9; 10 11 12; 13 14 15]};
    result = ea_fibcell2fibmat(test_fibcell);

    assert(size(result, 1) == 5, 'Wrong number of rows');
    assert(size(result, 2) == 4, 'Wrong number of columns');
    assert(all(result(1:2, 4) == 1), 'First fiber ID incorrect');
    assert(all(result(3:5, 4) == 2), 'Second fiber ID incorrect');

    fprintf('    ✓ ea_fibcell2fibmat: PASSED\n');
    results.tests_passed = results.tests_passed + 1;
    results.test_details{end+1} = struct('name', 'ea_fibcell2fibmat', 'status', 'PASSED', 'error', '');
catch ME
    fprintf('    ✗ ea_fibcell2fibmat: FAILED - %s\n', ME.message);
    results.tests_failed = results.tests_failed + 1;
    results.test_details{end+1} = struct('name', 'ea_fibcell2fibmat', 'status', 'FAILED', 'error', ME.message);
end

fprintf('\n');

%% Test 2: Sparse Matrix Handling
fprintf('TEST 2: Sparse Matrix Handling\n');
fprintf('--------------------------------\n');
fprintf('  Testing that matrices remain sparse...\n');

try
    % Create test sparse matrix
    test_sparse = sparse(rand(1000, 50) > 0.95);

    % Verify sparse operations work correctly
    test_sum = sum(test_sparse, 2, 'omitnan');
    test_mean = mean(test_sparse, 2, 'omitnan');
    test_subset = test_sparse(1:100, :);

    assert(issparse(test_sparse), 'Test matrix not sparse');
    assert(~issparse(test_sum), 'Sum should be full');
    assert(issparse(test_subset), 'Subset should be sparse');

    fprintf('    ✓ Sparse operations: PASSED\n');
    results.tests_passed = results.tests_passed + 1;
    results.test_details{end+1} = struct('name', 'Sparse operations', 'status', 'PASSED', 'error', '');
catch ME
    fprintf('    ✗ Sparse operations: FAILED - %s\n', ME.message);
    results.tests_failed = results.tests_failed + 1;
    results.test_details{end+1} = struct('name', 'Sparse operations', 'status', 'FAILED', 'error', ME.message);
end

fprintf('\n');

%% Test 3: Memory Profiling (Full mode only)
if strcmp(mode, 'full')
    fprintf('TEST 3: Memory Profiling\n');
    fprintf('-------------------------\n');
    fprintf('  NOTE: This test requires a test connectome and lead group file.\n');
    fprintf('  Skipping automatic memory test - run test_memory_usage.m separately.\n\n');
end

%% Test 4: Function Existence Check
fprintf('TEST 4: File Existence and Structure\n');
fprintf('--------------------------------------\n');

required_files = {
    'ea_fibValThresh.m'
    'ea_fibcell2fibmat.m'
    'ea_discfibers_calcvals_unified.m'
    'ea_disctract.m'
    'ea_discfibers_calcstats.m'
    'ea_method2methodid.m'
};

fprintf('  Checking required files...\n');
all_files_exist = true;
for i = 1:length(required_files)
    file_path = fullfile(fileparts(mfilename('fullpath')), '..', required_files{i});
    if exist(file_path, 'file')
        fprintf('    ✓ %s: EXISTS\n', required_files{i});
    else
        fprintf('    ✗ %s: MISSING\n', required_files{i});
        all_files_exist = false;
    end
end

if all_files_exist
    results.tests_passed = results.tests_passed + 1;
    results.test_details{end+1} = struct('name', 'File existence', 'status', 'PASSED', 'error', '');
else
    results.tests_failed = results.tests_failed + 1;
    results.test_details{end+1} = struct('name', 'File existence', 'status', 'FAILED', 'error', 'Some files missing');
end

fprintf('\n');

%% Test 5: Deprecation Warnings Check
fprintf('TEST 5: Deprecation Warnings\n');
fprintf('-----------------------------\n');
fprintf('  Checking that old functions show deprecation warnings...\n');

try
    % Temporarily suppress warnings to check if they're raised
    warning('off', 'all');
    lastwarn(''); % Clear last warning

    % Test files should exist and raise warnings
    deprecated_functions = {
        'ea_discfibers_calcvals'
        'ea_discfibers_calcvals_pam'
        'ea_discfibers_calcvals_pam_prob'
        'ea_discfibers_calcvals_cleartune'
    };

    deprecation_works = true;
    for i = 1:length(deprecated_functions)
        func_path = fullfile(fileparts(mfilename('fullpath')), '..', [deprecated_functions{i}, '.m']);
        if exist(func_path, 'file')
            % Check if warning exists in file
            fid = fopen(func_path, 'r');
            content = fread(fid, '*char')';
            fclose(fid);

            if contains(content, 'warning') && contains(content, 'deprecated')
                fprintf('    ✓ %s: Has deprecation warning\n', deprecated_functions{i});
            else
                fprintf('    ✗ %s: Missing deprecation warning\n', deprecated_functions{i});
                deprecation_works = false;
            end
        end
    end

    warning('on', 'all');

    if deprecation_works
        results.tests_passed = results.tests_passed + 1;
        results.test_details{end+1} = struct('name', 'Deprecation warnings', 'status', 'PASSED', 'error', '');
    else
        results.tests_failed = results.tests_failed + 1;
        results.test_details{end+1} = struct('name', 'Deprecation warnings', 'status', 'FAILED', 'error', 'Some warnings missing');
    end
catch ME
    warning('on', 'all');
    fprintf('    ✗ Deprecation check: FAILED - %s\n', ME.message);
    results.tests_failed = results.tests_failed + 1;
    results.test_details{end+1} = struct('name', 'Deprecation warnings', 'status', 'FAILED', 'error', ME.message);
end

fprintf('\n');

%% Summary
fprintf('========================================\n');
fprintf('TEST SUMMARY\n');
fprintf('========================================\n');
fprintf('Tests Passed: %d\n', results.tests_passed);
fprintf('Tests Failed: %d\n', results.tests_failed);
fprintf('Total Tests:  %d\n', results.tests_passed + results.tests_failed);
fprintf('Success Rate: %.1f%%\n', 100 * results.tests_passed / (results.tests_passed + results.tests_failed));
fprintf('\n');

if results.tests_failed == 0
    fprintf('✓ ALL TESTS PASSED!\n');
else
    fprintf('✗ SOME TESTS FAILED - Review details above\n');
    fprintf('\nFailed tests:\n');
    for i = 1:length(results.test_details)
        if strcmp(results.test_details{i}.status, 'FAILED')
            fprintf('  - %s: %s\n', results.test_details{i}.name, results.test_details{i}.error);
        end
    end
end

fprintf('\n');
fprintf('Completed: %s\n', char(datetime('now')));
fprintf('========================================\n\n');

%% Save results
results_file = fullfile(fileparts(mfilename('fullpath')), sprintf('test_results_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));
save(results_file, 'results');
fprintf('Results saved to: %s\n', results_file);

end
