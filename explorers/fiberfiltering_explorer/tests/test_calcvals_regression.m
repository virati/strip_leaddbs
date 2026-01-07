function results = test_calcvals_regression(leadgroup_file, connectome_name, varargin)
% TEST_CALCVALS_REGRESSION Compare old vs new calcvals implementations
%
% This script validates that the unified calcvals function produces identical
% results to the original separate functions, ensuring computational correctness.
%
% Usage:
%   results = test_calcvals_regression(leadgroup_file, connectome_name)
%   results = test_calcvals_regression(leadgroup_file, connectome_name, 'tolerance', 1e-10)
%
% Inputs:
%   leadgroup_file  - Path to lead group .mat file
%   connectome_name - Name of connectome to use
%   varargin:
%     'tolerance'   - Numerical tolerance for comparison (default: 1e-12)
%     'test_methods'- Cell array of methods to test (default: {'efield', 'pam_prob'})
%
% Outputs:
%   results - Struct with comparison results
%
% Tests performed:
%   1. E-field method: ea_discfibers_calcvals vs unified('efield')
%   2. PAM prob method: ea_discfibers_calcvals_pam_prob vs unified('pam_prob')
%   3. Matrix properties (sparse, size, non-zero elements)
%   4. Numerical equality within tolerance

%% Parse inputs
p = inputParser;
addRequired(p, 'leadgroup_file', @ischar);
addRequired(p, 'connectome_name', @ischar);
addParameter(p, 'tolerance', 1e-12, @isnumeric);
addParameter(p, 'test_methods', {'efield', 'pam_prob'}, @iscell);
parse(p, leadgroup_file, connectome_name, varargin{:});

tolerance = p.Results.tolerance;
test_methods = p.Results.test_methods;

fprintf('\n========================================\n');
fprintf('CALCVALS REGRESSION TEST\n');
fprintf('========================================\n');
fprintf('Lead Group: %s\n', leadgroup_file);
fprintf('Connectome: %s\n', connectome_name);
fprintf('Tolerance: %e\n', tolerance);
fprintf('Started: %s\n\n', char(datetime('now')));

%% Initialize results
results = struct();
results.leadgroup_file = leadgroup_file;
results.connectome_name = connectome_name;
results.tolerance = tolerance;
results.timestamp = datetime('now');
results.tests_passed = 0;
results.tests_failed = 0;
results.method_results = {};

%% Load lead group
fprintf('Loading lead group...\n');
try
    load(leadgroup_file, 'M');
    fprintf('  ✓ Lead group loaded (%d patients)\n\n', length(M.patient.list));
catch ME
    error('Failed to load lead group: %s', ME.message);
end

%% Setup
obj = ea_disctract;
obj.M = M;
obj.leadgroup = leadgroup_file;
obj.connectome = connectome_name;
obj.headless = true;
obj.silent = true;

% Get connectome file
if obj.multi_pathways
    [filepath,~,~] = fileparts(obj.leadgroup);
    cfile = [filepath,filesep,obj.connectome,filesep,'merged_pathways.mat'];
else
    cfile = [ea_getconnectomebase('dMRI'), obj.connectome, filesep, 'data.mat'];
end

if ~exist(cfile, 'file')
    error('Connectome file not found: %s', cfile);
end

%% Test E-field method
if ismember('efield', test_methods)
    fprintf('========================================\n');
    fprintf('TEST: E-field Method\n');
    fprintf('========================================\n');

    method_result = struct('method', 'efield', 'passed', false);

    try
        % Get VAT list
        obj.connectivity_type = 1;
        obj.initialize();
        [vatlist, ~] = ea_discfibers_getvats(obj);

        fprintf('Running old ea_discfibers_calcvals...\n');
        warning('off', 'ea_discfibers_calcvals:deprecated');
        tic;
        [fibsvalBin_old, fibsvalSum_old, fibsvalMean_old, fibsvalPeak_old, ...
         fibsval5Peak_old, fibcell_old, connFiberInd_old, totalFibers_old] = ...
            ea_discfibers_calcvals(vatlist, cfile, obj.calcthreshold);
        time_old = toc;
        warning('on', 'ea_discfibers_calcvals:deprecated');
        fprintf('  Old method completed in %.3f sec\n', time_old);

        fprintf('Running new ea_discfibers_calcvals_unified...\n');
        load(cfile, 'fibers', 'idx');
        tic;
        [fibsval_new, fibcell_new, connFiberInd_new, totalFibers_new] = ...
            ea_discfibers_calcvals_unified('efield', vatlist, fibers, idx, obj, obj.calcthreshold);
        time_new = toc;
        clear fibers idx;
        fprintf('  New method completed in %.3f sec\n', time_new);

        % Compare results
        fprintf('\nComparing results...\n');
        all_match = true;

        % Compare totalFibers
        if totalFibers_old == totalFibers_new
            fprintf('  ✓ totalFibers match: %d\n', totalFibers_old);
        else
            fprintf('  ✗ totalFibers differ: %d vs %d\n', totalFibers_old, totalFibers_new);
            all_match = false;
        end

        % Compare matrices for each side
        for side = 1:length(fibsvalBin_old)
            fprintf('\n  Side %d:\n', side);

            % Binary connectivity
            match = compare_matrices(fibsvalBin_old{side}, fibsval_new.bin{side}, tolerance, '    Binary');
            all_match = all_match && match;

            % Sum
            match = compare_matrices(fibsvalSum_old{side}, fibsval_new.sum{side}, tolerance, '    Sum');
            all_match = all_match && match;

            % Mean
            match = compare_matrices(fibsvalMean_old{side}, fibsval_new.mean{side}, tolerance, '    Mean');
            all_match = all_match && match;

            % Peak
            match = compare_matrices(fibsvalPeak_old{side}, fibsval_new.peak{side}, tolerance, '    Peak');
            all_match = all_match && match;

            % Peak5
            match = compare_matrices(fibsval5Peak_old{side}, fibsval_new.peak5{side}, tolerance, '    Peak5');
            all_match = all_match && match;

            % ConnFiberInd
            if isequal(connFiberInd_old{side}, connFiberInd_new{side})
                fprintf('    ✓ connFiberInd match (%d indices)\n', length(connFiberInd_old{side}));
            else
                fprintf('    ✗ connFiberInd differ\n');
                all_match = false;
            end

            % Fibcell (just check sizes match)
            if length(fibcell_old{side}) == length(fibcell_new{side})
                fprintf('    ✓ fibcell size match (%d fibers)\n', length(fibcell_old{side}));
            else
                fprintf('    ✗ fibcell size differ: %d vs %d\n', length(fibcell_old{side}), length(fibcell_new{side}));
                all_match = false;
            end
        end

        % Performance comparison
        fprintf('\n  Performance:\n');
        fprintf('    Old method: %.3f sec\n', time_old);
        fprintf('    New method: %.3f sec\n', time_new);
        fprintf('    Speedup: %.2fx\n', time_old / time_new);

        method_result.passed = all_match;
        method_result.time_old = time_old;
        method_result.time_new = time_new;

        if all_match
            fprintf('\n✓ E-field method: ALL CHECKS PASSED\n');
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('\n✗ E-field method: SOME CHECKS FAILED\n');
            results.tests_failed = results.tests_failed + 1;
        end

    catch ME
        fprintf('\n✗ E-field test FAILED with error: %s\n', ME.message);
        method_result.error = ME.message;
        results.tests_failed = results.tests_failed + 1;
    end

    results.method_results{end+1} = method_result;
    fprintf('\n');
end

%% Test PAM probabilistic method
if ismember('pam_prob', test_methods)
    fprintf('========================================\n');
    fprintf('TEST: PAM Probabilistic Method\n');
    fprintf('========================================\n');

    method_result = struct('method', 'pam_prob', 'passed', false);

    try
        % Get PAM list
        obj.connectivity_type = 2;
        obj.initialize();
        [pamlist, ~] = ea_discfibers_getpams(obj);

        fprintf('Running old ea_discfibers_calcvals_pam_prob...\n');
        warning('off', 'ea_discfibers_calcvals_pam_prob:deprecated');
        tic;
        [fibsvalBin_old, fibsvalProb_old, ~, ~, ~, fibcell_old, connFiberInd_old, totalFibers_old] = ...
            ea_discfibers_calcvals_pam_prob(pamlist, obj, cfile);
        time_old = toc;
        warning('on', 'ea_discfibers_calcvals_pam_prob:deprecated');
        fprintf('  Old method completed in %.3f sec\n', time_old);

        fprintf('Running new ea_discfibers_calcvals_unified...\n');
        load(cfile, 'fibers', 'idx');
        tic;
        [fibsval_new, fibcell_new, connFiberInd_new, totalFibers_new] = ...
            ea_discfibers_calcvals_unified('pam_prob', pamlist, fibers, idx, obj);
        time_new = toc;
        clear fibers idx;
        fprintf('  New method completed in %.3f sec\n', time_new);

        % Compare results
        fprintf('\nComparing results...\n');
        all_match = true;

        % Compare totalFibers
        if totalFibers_old == totalFibers_new
            fprintf('  ✓ totalFibers match: %d\n', totalFibers_old);
        else
            fprintf('  ✗ totalFibers differ: %d vs %d\n', totalFibers_old, totalFibers_new);
            all_match = false;
        end

        % Compare matrices for each side
        for side = 1:length(fibsvalBin_old)
            fprintf('\n  Side %d:\n', side);

            % Binary connectivity
            match = compare_matrices(fibsvalBin_old{side}, fibsval_new.bin{side}, tolerance, '    Binary');
            all_match = all_match && match;

            % Probabilistic
            match = compare_matrices(fibsvalProb_old{side}, fibsval_new.prob{side}, tolerance, '    Probabilistic');
            all_match = all_match && match;

            % ConnFiberInd
            if isequal(connFiberInd_old{side}, connFiberInd_new{side})
                fprintf('    ✓ connFiberInd match (%d indices)\n', length(connFiberInd_old{side}));
            else
                fprintf('    ✗ connFiberInd differ\n');
                all_match = false;
            end
        end

        % Performance comparison
        fprintf('\n  Performance:\n');
        fprintf('    Old method: %.3f sec\n', time_old);
        fprintf('    New method: %.3f sec\n', time_new);
        fprintf('    Speedup: %.2fx\n', time_old / time_new);

        method_result.passed = all_match;
        method_result.time_old = time_old;
        method_result.time_new = time_new;

        if all_match
            fprintf('\n✓ PAM probabilistic method: ALL CHECKS PASSED\n');
            results.tests_passed = results.tests_passed + 1;
        else
            fprintf('\n✗ PAM probabilistic method: SOME CHECKS FAILED\n');
            results.tests_failed = results.tests_failed + 1;
        end

    catch ME
        fprintf('\n✗ PAM probabilistic test FAILED with error: %s\n', ME.message);
        method_result.error = ME.message;
        results.tests_failed = results.tests_failed + 1;
    end

    results.method_results{end+1} = method_result;
    fprintf('\n');
end

%% Summary
fprintf('========================================\n');
fprintf('REGRESSION TEST SUMMARY\n');
fprintf('========================================\n');
fprintf('Tests Passed: %d/%d\n', results.tests_passed, results.tests_passed + results.tests_failed);
fprintf('Tests Failed: %d/%d\n', results.tests_failed, results.tests_passed + results.tests_failed);

if results.tests_failed == 0
    fprintf('\n✓ ALL REGRESSION TESTS PASSED!\n');
    fprintf('The unified function produces identical results.\n');
else
    fprintf('\n✗ SOME REGRESSION TESTS FAILED\n');
    fprintf('Review the details above for discrepancies.\n');
end

fprintf('\nCompleted: %s\n', char(datetime('now')));
fprintf('========================================\n\n');

%% Save results
results_file = fullfile(fileparts(mfilename('fullpath')), sprintf('regression_test_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')));
save(results_file, 'results');
fprintf('Results saved to: %s\n\n', results_file);

end

%% Helper function to compare matrices
function match = compare_matrices(mat1, mat2, tolerance, label)
    match = true;

    % Check sparse property
    if issparse(mat1) ~= issparse(mat2)
        fprintf('%s: ✗ Sparsity mismatch (old: %s, new: %s)\n', ...
            label, mat2str(issparse(mat1)), mat2str(issparse(mat2)));
        match = false;
    end

    % Check size
    if ~isequal(size(mat1), size(mat2))
        fprintf('%s: ✗ Size mismatch (old: %s, new: %s)\n', ...
            label, mat2str(size(mat1)), mat2str(size(mat2)));
        match = false;
        return;
    end

    % Check non-zero count
    nnz1 = nnz(mat1);
    nnz2 = nnz(mat2);
    if nnz1 ~= nnz2
        fprintf('%s: ✗ Non-zero count mismatch (old: %d, new: %d)\n', ...
            label, nnz1, nnz2);
        match = false;
    end

    % Check numerical equality
    max_diff = max(abs(mat1(:) - mat2(:)));
    if max_diff > tolerance
        fprintf('%s: ✗ Values differ (max diff: %e > tolerance: %e)\n', ...
            label, max_diff, tolerance);
        match = false;
    else
        fprintf('%s: ✓ Match (max diff: %e, nnz: %d, sparse: %s)\n', ...
            label, max_diff, nnz1, mat2str(issparse(mat1)));
    end
end
