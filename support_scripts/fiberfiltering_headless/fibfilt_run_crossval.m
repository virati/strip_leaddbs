function [I, Ihat, stats] = fibfilt_run_crossval(fibfilt_path, cv_type, varargin)
% FIBFILT_RUN_CROSSVAL - Run cross-validation on fiber filtering model
%
% Syntax:
%   [I, Ihat, stats] = fibfilt_run_crossval(fibfilt_path, cv_type)
%   [I, Ihat, stats] = fibfilt_run_crossval(..., 'Name', Value)
%
% Inputs:
%   fibfilt_path - Path to .fibfilt file
%   cv_type - 'loocv', 'lococv', 'kfold', or 'lno'
%
% Optional Parameters:
%   'kfold' - Number of folds for k-fold CV (default: 5)
%   'kIter' - Number of iterations for k-fold (default: 1)
%   'silent' - Suppress output (default: false)
%   'save_results' - Save CV results (default: true)
%
% Outputs:
%   I - Actual clinical scores
%   Ihat - Predicted scores from fiber model
%   stats - Structure with correlation statistics

% Parse inputs
p = inputParser;
addRequired(p, 'fibfilt_path', @ischar);
addRequired(p, 'cv_type', @ischar);
addParameter(p, 'kfold', 5, @isnumeric);
addParameter(p, 'kIter', 1, @isnumeric);
addParameter(p, 'silent', false, @islogical);
addParameter(p, 'save_results', true, @islogical);
parse(p, fibfilt_path, cv_type, varargin{:});
opts = p.Results;

% Load fiber filtering object
if ~opts.silent
    fprintf('Loading fiber filtering model: %s\n', opts.fibfilt_path);
end
load(opts.fibfilt_path, '-mat', 'tractset');
tractset.headless = true;
tractset.silent = opts.silent;
tractset.cvlivevisualize = 0; % Disable live visualization

% Configure CV parameters
tractset.kfold = opts.kfold;
tractset.kIter = opts.kIter;

% Run appropriate CV method
if ~opts.silent
    fprintf('Running %s cross-validation...\n', upper(opts.cv_type));
end

switch lower(opts.cv_type)
    case 'loocv'
        [I, Ihat] = tractset.loocv(opts.silent);

    case 'lococv'
        [I, Ihat] = tractset.lococv(opts.silent);

    case 'kfold'
        [I, Ihat, val_struct] = tractset.kfoldcv(opts.silent);

    case 'lno'
        [I, Ihat, val_struct] = tractset.lno([], opts.silent);

    otherwise
        error('Unknown CV type: %s. Use loocv, lococv, kfold, or lno', opts.cv_type);
end

% Calculate statistics
stats.r = corr(I, Ihat, 'rows', 'pairwise', 'type', tractset.corrtype);
[~, stats.p] = corr(I, Ihat, 'rows', 'pairwise', 'type', tractset.corrtype);
stats.rmse = sqrt(mean((I - Ihat).^2, 'omitnan'));
stats.mae = mean(abs(I - Ihat), 'omitnan');

if ~opts.silent
    fprintf('Cross-validation complete!\n');
    fprintf('  R = %.4f (p = %.4f)\n', stats.r, stats.p);
    fprintf('  RMSE = %.4f\n', stats.rmse);
    fprintf('  MAE = %.4f\n', stats.mae);
end

% Save results
if opts.save_results
    [dir_path, name, ~] = fileparts(opts.fibfilt_path);
    cv_results_path = fullfile(dir_path, sprintf('%s_%s_results.mat', name, opts.cv_type));
    save(cv_results_path, 'I', 'Ihat', 'stats', 'tractset');
    if ~opts.silent
        fprintf('Results saved to: %s\n', cv_results_path);
    end
end

end
