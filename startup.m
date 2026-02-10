function startup()
% STARTUP Initialize fiberfiltering environment
%   This script sets up the MATLAB path and environment for the
%   fiberfiltering toolbox. Run this once per MATLAB session.
%
%   Usage:
%       startup  % Run from the fiberfiltering root directory
%
%   This will:
%       1. Add all necessary directories to the MATLAB path
%       2. Check for required toolboxes
%       3. Display version information
%       4. Check for external dependencies (SPM12)

% Get the root directory (where this script lives)
rootDir = fileparts(mfilename('fullpath'));

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  Fiberfiltering Toolbox Initialization                    ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

%% Add paths
fprintf('Setting up paths...\n');

% Add package directory (contains +fiberfiltering)
addpath(rootDir);

% Add src directories
addpath(genpath(fullfile(rootDir, 'src')));

% Add legacy helpers (for backward compatibility)
addpath(genpath(fullfile(rootDir, 'helpers')));

% Add external dependencies
externalDir = fullfile(rootDir, 'external');
if exist(externalDir, 'dir')
    addpath(genpath(externalDir));
end

% Add resources
resourceDir = fullfile(rootDir, 'resources');
if exist(resourceDir, 'dir')
    addpath(resourceDir);
end

% Add config
configDir = fullfile(rootDir, 'config');
if exist(configDir, 'dir')
    addpath(configDir);
end

fprintf('  ✓ Paths configured\n\n');

%% Check required toolboxes
fprintf('Checking MATLAB toolboxes...\n');

requiredToolboxes = {
    'Image Processing Toolbox', 'Image_Toolbox'
    'Statistics and Machine Learning Toolbox', 'Statistics_Toolbox'
    'Signal Processing Toolbox', 'Signal_Toolbox'
};

allPresent = true;
for i = 1:size(requiredToolboxes, 1)
    toolboxName = requiredToolboxes{i, 1};
    toolboxID = requiredToolboxes{i, 2};

    hasToolbox = license('test', toolboxID);
    if hasToolbox
        fprintf('  ✓ %s\n', toolboxName);
    else
        fprintf('  ✗ %s (optional - some features may not work)\n', toolboxName);
        allPresent = false;
    end
end

fprintf('\n');

%% Check for SPM12
fprintf('Checking external dependencies...\n');

if exist('spm', 'file')
    try
        spmVer = spm('ver');
        fprintf('  ✓ SPM %s found\n', spmVer);
    catch
        fprintf('  ⚠ SPM found but version check failed\n');
    end
else
    fprintf('  ✗ SPM12 not found (REQUIRED for NIfTI I/O)\n');
    fprintf('    Download from: https://www.fil.ion.ucl.ac.uk/spm/\n');
end

fprintf('\n');

%% Display version info
versionFile = fullfile(rootDir, 'version.txt');
if exist(versionFile, 'file')
    fid = fopen(versionFile, 'r');
    version = fgetl(fid);
    fclose(fid);
    fprintf('Fiberfiltering Toolbox v%s\n', version);
else
    fprintf('Fiberfiltering Toolbox (development version)\n');
end

fprintf('\n');

%% Quick start info
fprintf('Quick Start:\n');
fprintf('  • Documentation:  help +fiberfiltering\n');
fprintf('  • Examples:       examples/\n');
fprintf('  • Run tests:      scripts/run_tests.m\n');
fprintf('  • Main package:   fiberfiltering.*\n');
fprintf('\n');

fprintf('Core Functions:\n');
fprintf('  fiberfiltering.core.filterByROI          - Filter by ROI\n');
fprintf('  fiberfiltering.core.filterByStimulation  - Filter by stimulation\n');
fprintf('  fiberfiltering.core.filterByLength       - Filter by length\n');
fprintf('\n');

fprintf('For GUI: open src/gui/ea_discfiberexplorer.mlapp\n');
fprintf('\n');

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  Initialization Complete                                   ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

end
