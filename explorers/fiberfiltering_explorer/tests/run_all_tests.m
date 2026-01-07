function run_all_tests(leadgroup_file, connectome_name)
% RUN_ALL_TESTS Execute complete test suite for fiberfiltering optimization
%
% This master script runs all validation tests for the fiberfiltering
% optimization in the correct sequence.
%
% Usage:
%   run_all_tests()  % Run basic tests only (no data required)
%   run_all_tests(leadgroup_file, connectome_name)  % Run full suite
%
% Example:
%   run_all_tests('/path/to/leadgroup.mat', 'MyConnectome')
%
% Test sequence:
%   1. Basic validation (no data required)
%   2. Regression tests (requires data)
%   3. Memory profiling (requires data)
%
% See README_TESTS.md for detailed information.

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  FIBERFILTERING OPTIMIZATION - COMPLETE TEST SUITE    ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n');
fprintf('\n');

test_results = struct();
test_results.start_time = datetime('now');

%% Test 1: Basic Validation (always run)
fprintf('═══════════════════════════════════════════════════════\n');
fprintf(' TEST 1: Basic Validation (No Data Required)\n');
fprintf('═══════════════════════════════════════════════════════\n\n');

try
    basic_results = test_fiberfiltering_optimization('quick');
    test_results.basic = basic_results;
    fprintf('\n');
catch ME
    fprintf('✗ Basic validation failed: %s\n\n', ME.message);
    test_results.basic_error = ME.message;
end

%% Tests requiring data
if nargin >= 2
    fprintf('═══════════════════════════════════════════════════════\n');
    fprintf(' TEST 2: Regression Testing\n');
    fprintf('═══════════════════════════════════════════════════════\n\n');

    try
        regression_results = test_calcvals_regression(leadgroup_file, connectome_name);
        test_results.regression = regression_results;
        fprintf('\n');
    catch ME
        fprintf('✗ Regression test failed: %s\n\n', ME.message);
        test_results.regression_error = ME.message;
    end

    fprintf('═══════════════════════════════════════════════════════\n');
    fprintf(' TEST 3: Memory Profiling\n');
    fprintf('═══════════════════════════════════════════════════════\n\n');

    try
        memory_results = test_memory_usage(leadgroup_file, connectome_name);
        test_results.memory = memory_results;
        fprintf('\n');
    catch ME
        fprintf('✗ Memory profiling failed: %s\n\n', ME.message);
        test_results.memory_error = ME.message;
    end
else
    fprintf('═══════════════════════════════════════════════════════\n');
    fprintf(' Skipping data-dependent tests\n');
    fprintf('═══════════════════════════════════════════════════════\n');
    fprintf('\nTo run regression and memory tests, provide arguments:\n');
    fprintf('  run_all_tests(leadgroup_file, connectome_name)\n\n');
end

%% Final Summary
fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════╗\n');
fprintf('║  FINAL TEST SUMMARY                                    ║\n');
fprintf('╚════════════════════════════════════════════════════════╝\n\n');

test_results.end_time = datetime('now');
test_results.duration = test_results.end_time - test_results.start_time;

fprintf('Started:  %s\n', char(test_results.start_time));
fprintf('Finished: %s\n', char(test_results.end_time));
fprintf('Duration: %s\n\n', char(test_results.duration));

% Count results
total_passed = 0;
total_failed = 0;

if isfield(test_results, 'basic') && ~isfield(test_results, 'basic_error')
    total_passed = total_passed + test_results.basic.tests_passed;
    total_failed = total_failed + test_results.basic.tests_failed;
    fprintf('Basic validation: %d/%d passed\n', test_results.basic.tests_passed, ...
        test_results.basic.tests_passed + test_results.basic.tests_failed);
end

if isfield(test_results, 'regression') && ~isfield(test_results, 'regression_error')
    total_passed = total_passed + test_results.regression.tests_passed;
    total_failed = total_failed + test_results.regression.tests_failed;
    fprintf('Regression tests: %d/%d passed\n', test_results.regression.tests_passed, ...
        test_results.regression.tests_passed + test_results.regression.tests_failed);
end

if isfield(test_results, 'memory') && ~isfield(test_results, 'memory_error')
    if test_results.memory.unified_test_passed
        fprintf('Memory profiling: PASSED (%.1f%% reduction)\n', test_results.memory.percent_reduction);
        total_passed = total_passed + 1;
    else
        fprintf('Memory profiling: FAILED\n');
        total_failed = total_failed + 1;
    end
end

fprintf('\n');
fprintf('─────────────────────────────────────────────────────────\n');
fprintf('OVERALL: %d tests passed, %d tests failed\n', total_passed, total_failed);
fprintf('─────────────────────────────────────────────────────────\n\n');

if total_failed == 0 && total_passed > 0
    fprintf('✓✓✓ ALL TESTS PASSED! ✓✓✓\n');
    fprintf('The optimization is working correctly.\n\n');
else
    fprintf('⚠ SOME TESTS FAILED OR INCOMPLETE ⚠\n');
    fprintf('Review the detailed output above.\n\n');
end

%% Save consolidated results
results_file = fullfile(fileparts(mfilename('fullpath')), sprintf('all_tests_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));
save(results_file, 'test_results');
fprintf('Complete results saved to:\n  %s\n\n', results_file);

fprintf('════════════════════════════════════════════════════════\n\n');

end
