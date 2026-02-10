function run_all_tests()
% Master test runner for all fiberfiltering tests
% Runs all test suites and reports overall status

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  LEAD-DBS Fiberfiltering Test Suite                       ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Add paths
test_dir = fileparts(mfilename('fullpath'));
addpath(test_dir);
addpath(fullfile(test_dir, '..', '..', 'helpers'));
addpath(fullfile(test_dir, '..', '..', 'explorers', 'fiberfiltering_explorer'));

% Track test results
all_passed = true;
test_results = struct();

% Test 1: ea_filterfiber_len
fprintf('═══════════════════════════════════════════════════════════════\n');
try
    test_ea_filterfiber_len();
    test_results.filterfiber_len = 'PASSED';
catch ME
    fprintf('\n❌ FAILED: test_ea_filterfiber_len\n');
    fprintf('   Error: %s\n', ME.message);
    test_results.filterfiber_len = 'FAILED';
    all_passed = false;
end

% Test 2: ea_filterfiber_roi
fprintf('═══════════════════════════════════════════════════════════════\n');
try
    test_ea_filterfiber_roi();
    test_results.filterfiber_roi = 'PASSED';
catch ME
    fprintf('\n❌ FAILED: test_ea_filterfiber_roi\n');
    fprintf('   Error: %s\n', ME.message);
    test_results.filterfiber_roi = 'FAILED';
    all_passed = false;
end

% Test 3: ea_filterfiber_stim
fprintf('═══════════════════════════════════════════════════════════════\n');
try
    test_ea_filterfiber_stim();
    test_results.filterfiber_stim = 'PASSED';
catch ME
    fprintf('\n❌ FAILED: test_ea_filterfiber_stim\n');
    fprintf('   Error: %s\n', ME.message);
    test_results.filterfiber_stim = 'FAILED';
    all_passed = false;
end

% Print summary
fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  TEST SUMMARY                                              ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

fields = fieldnames(test_results);
for i = 1:length(fields)
    status = test_results.(fields{i});
    if strcmp(status, 'PASSED')
        fprintf('  ✓ %-30s  %s\n', fields{i}, status);
    else
        fprintf('  ✗ %-30s  %s\n', fields{i}, status);
    end
end

fprintf('\n');
if all_passed
    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║  ✓ ALL TESTS PASSED                                       ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n');
else
    fprintf('╔════════════════════════════════════════════════════════════╗\n');
    fprintf('║  ✗ SOME TESTS FAILED                                      ║\n');
    fprintf('╚════════════════════════════════════════════════════════════╝\n');
    error('Test suite failed');
end

fprintf('\n');

end
