function results = run_tests()
% RUN_TESTS Execute all fiberfiltering tests
%   Runs the complete test suite and reports results.
%
%   Usage:
%       run_tests         % Run all tests
%       results = run_tests  % Return results struct
%
%   Output:
%       results - Struct with test results and statistics

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  Fiberfiltering Test Suite                                ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% Get root directory
rootDir = fileparts(fileparts(mfilename('fullpath')));

% Add test directory to path
testDir = fullfile(rootDir, 'test');
addpath(genpath(testDir));

% Initialize results
results = struct();
results.total = 0;
results.passed = 0;
results.failed = 0;
results.tests = {};

% Find test directory
if exist(fullfile(testDir, 'fiberfiltering'), 'dir')
    % Old test structure
    oldTestDir = fullfile(testDir, 'fiberfiltering');
    testFiles = dir(fullfile(oldTestDir, 'test_*.m'));

    for i = 1:length(testFiles)
        testName = testFiles(i).name(1:end-2);  % Remove .m extension
        fprintf('Running %s...\n', testName);

        results.total = results.total + 1;
        try
            % Change to test directory and run
            cd(oldTestDir);
            eval(testName);

            results.passed = results.passed + 1;
            results.tests{end+1} = struct('name', testName, 'status', 'PASSED');
            fprintf('  ✓ PASSED\n\n');
        catch ME
            results.failed = results.failed + 1;
            results.tests{end+1} = struct('name', testName, 'status', 'FAILED', 'error', ME.message);
            fprintf('  ✗ FAILED: %s\n\n', ME.message);
        end
    end
else
    fprintf('No tests found in %s\n', testDir);
end

% Return to root
cd(rootDir);

% Print summary
fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('Test Summary:\n');
fprintf('  Total:  %d\n', results.total);
fprintf('  Passed: %d\n', results.passed);
fprintf('  Failed: %d\n', results.failed);

if results.failed == 0
    fprintf('\n✓ All tests passed!\n');
else
    fprintf('\n✗ Some tests failed\n');
end

fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('\n');

end
