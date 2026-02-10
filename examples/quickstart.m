%% Fiberfiltering Quickstart Guide
% This script demonstrates basic usage of the fiberfiltering toolbox.
%
% Before running, ensure you've run startup.m from the root directory.

%% Setup
% Run startup if not already done
% startup

%% Example 1: Filter Fibers by ROI
% Create synthetic fiber data
fprintf('Example 1: Filter by ROI\n');
fprintf('========================\n\n');

% Synthetic fibers: [x, y, z, fiber_index]
fibers = [
    % Fiber 1: passes through origin
    0, 0, 0, 1;
    5, 5, 5, 1;
    10, 10, 10, 1;
    % Fiber 2: far away
    50, 50, 50, 2;
    55, 55, 55, 2;
];

fprintf('Original fibers: %d points across %d fibers\n', ...
    size(fibers, 1), length(unique(fibers(:,4))));

% Using the high-level API
% filtered = fiberfiltering.filterFibers(fibers, ...
%     'Method', 'roi', ...
%     'ROI', 'path/to/roi.nii');

% Or use the core function directly
% filtered = fiberfiltering.core.filterByROI(fibers, 'roi.nii');

fprintf('\nNote: Requires actual ROI file to run\n\n');

%% Example 2: Filter by Length
fprintf('Example 2: Filter by Length\n');
fprintf('===========================\n\n');

% Create fibers of different lengths
fibers_struct.fibers = [
    % Short fiber (length ~8.66mm)
    0, 0, 0, 1;
    5, 5, 5, 1;
    % Long fiber (length ~34.64mm)
    0, 0, 0, 2;
    10, 10, 10, 2;
    20, 20, 20, 2;
];
fibers_struct.idx = [2; 3]; % Points per fiber

% Filter: keep only fibers >= 15mm
minLength = 15;
filtered = fiberfiltering.core.filterByLength(fibers_struct, minLength);

fprintf('Minimum length: %.1f mm\n', minLength);
fprintf('Fibers retained: %d out of %d\n', ...
    length(filtered{1}.idx), length(fibers_struct.idx));

fprintf('\n');

%% Example 3: Filter by Stimulation
fprintf('Example 3: Filter by Stimulation\n');
fprintf('=================================\n\n');

% Define electrode contacts (bilateral)
coords = {
    [0, 0, 0; 0, 0, 3; 0, 0, 6; 0, 0, 9],  % Right hemisphere
    []                                       % Left hemisphere (no electrode)
};

% Define stimulation parameters
% [right_side; left_side] x [contact1, contact2, contact3, contact4]
stimVector = [
    3.0, 0, 0, 0;  % Right: 3V on contact 1
    0, 0, 0, 0     % Left: no stimulation
];

% Prepare fiber data
ftr.fibers = [
    0, 0, 0, 1;
    2, 2, 2, 1;
];
ftr.idx = [2];
ftr.voxmm = 'mm';  % Coordinates in mm

% Filter using Kuncel model with radius factor=1
% filtered = fiberfiltering.core.filterByStimulation(...
%     ftr, coords, stimVector, 'kuncel', 1);

fprintf('Stimulation: 3.0V on contact 1\n');
fprintf('Model: Kuncel 2008\n');
fprintf('Note: Requires space/template files to run\n\n');

%% Example 4: Using the Unified API
fprintf('Example 4: Unified API\n');
fprintf('======================\n\n');

% The filterFibers() function provides a single interface
fprintf('High-level API examples:\n\n');

fprintf('  1. Filter by ROI:\n');
fprintf('     filtered = fiberfiltering.filterFibers(fibers, ...\n');
fprintf('         ''Method'', ''roi'', ...\n');
fprintf('         ''ROI'', ''roi.nii'');\n\n');

fprintf('  2. Filter by length:\n');
fprintf('     filtered = fiberfiltering.filterFibers(fibers, ...\n');
fprintf('         ''Method'', ''length'', ...\n');
fprintf('         ''MinLength'', 10);\n\n');

fprintf('  3. Filter by stimulation:\n');
fprintf('     filtered = fiberfiltering.filterFibers(fibers, ...\n');
fprintf('         ''Method'', ''stimulation'', ...\n');
fprintf('         ''Coords'', coords, ...\n');
fprintf('         ''StimVector'', stim, ...\n');
fprintf('         ''Model'', ''kuncel'');\n\n');

%% Summary
fprintf('Summary\n');
fprintf('=======\n\n');
fprintf('The fiberfiltering toolbox provides:\n');
fprintf('  • ROI-based filtering\n');
fprintf('  • Length-based filtering\n');
fprintf('  • Stimulation-based filtering (VAT models)\n');
fprintf('  • High-level unified API\n');
fprintf('  • Low-level core functions\n\n');
fprintf('For more examples, see examples/\n');
fprintf('For documentation, use: help +fiberfiltering\n\n');
