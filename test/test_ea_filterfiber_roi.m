function test_ea_filterfiber_roi()
% Test suite for ea_filterfiber_roi function
% Tests fiber filtering based on ROI intersection
%
% This test creates synthetic fiber data and ROI to verify filtering logic

fprintf('\n=== Testing ea_filterfiber_roi ===\n');

%% Test 1: Basic ROI filtering with synthetic data
fprintf('Test 1: Basic ROI filtering...\n');
try
    % Create synthetic fibers
    % Format: [x, y, z, fiber_index]
    % Create 3 fibers: one inside ROI, one outside, one partially through
    fibers = [
        % Fiber 1: passes through center (should be kept)
        0, 0, 0, 1;
        1, 1, 1, 1;
        2, 2, 2, 1;
        % Fiber 2: far away (should be removed)
        50, 50, 50, 2;
        51, 51, 51, 2;
        % Fiber 3: crosses ROI edge (should be kept)
        -5, -5, -5, 3;
        0, 0, 0, 3;
        5, 5, 5, 3;
    ];

    % Create synthetic ROI NIfTI file
    % ROI centered at origin with 10mm radius
    roi_img = zeros(20, 20, 20);
    [X, Y, Z] = meshgrid(-9.5:9.5, -9.5:9.5, -9.5:9.5);
    roi_img(sqrt(X.^2 + Y.^2 + Z.^2) <= 5) = 1;

    % Create NIfTI structure
    roi_nii.img = roi_img;
    roi_nii.mat = [1 0 0 -9.5; 0 1 0 -9.5; 0 0 1 -9.5; 0 0 0 1]; % 1mm isotropic
    roi_nii.dim = size(roi_img);
    roi_nii.dt = [16 0]; % float32
    roi_nii.n = [1 1];
    roi_nii.descrip = 'Test ROI';

    % Save test ROI
    test_dir = fileparts(mfilename('fullpath'));
    roi_path = fullfile(test_dir, 'test_roi.nii');
    ea_write_nii(roi_nii, roi_path);

    % Test filtering with matrix input
    fiberFiltered = ea_filterfiber_roi(fibers, roi_path);

    % Verify results
    unique_fibers = unique(fiberFiltered(:,4));
    assert(ismember(1, unique_fibers), 'Fiber 1 should be kept (passes through ROI)');
    assert(~ismember(2, unique_fibers), 'Fiber 2 should be removed (outside ROI)');

    % Clean up
    delete(roi_path);

    fprintf('  ✓ PASSED: Basic ROI filtering works correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 2: Empty fiber set handling
fprintf('Test 2: Empty fiber handling...\n');
try
    % Create ROI far from any fibers
    roi_img = zeros(20, 20, 20);
    roi_img(1:5, 1:5, 1:5) = 1;
    roi_nii.img = roi_img;
    roi_nii.mat = [1 0 0 100; 0 1 0 100; 0 0 1 100; 0 0 0 1]; % Offset far away

    test_dir = fileparts(mfilename('fullpath'));
    roi_path = fullfile(test_dir, 'test_roi_empty.nii');
    ea_write_nii(roi_nii, roi_path);

    % Small fiber set nowhere near ROI
    fibers = [0, 0, 0, 1; 1, 1, 1, 1];

    fiberFiltered = ea_filterfiber_roi(fibers, roi_path);

    % Should return empty or no fibers
    if isempty(fiberFiltered)
        fprintf('  ✓ PASSED: Empty result handled correctly\n');
    else
        assert(isempty(unique(fiberFiltered(:,4))), 'Should have no fibers');
        fprintf('  ✓ PASSED: Empty result handled correctly\n');
    end

    delete(roi_path);
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 3: Struct input/output
fprintf('Test 3: Struct input/output...\n');
try
    % Create fiber struct
    ftr_struct.fibers = [
        0, 0, 0, 1;
        1, 1, 1, 1;
        2, 2, 2, 1;
    ];
    ftr_struct.idx = [3]; % One fiber with 3 points
    ftr_struct.ea_fibformat = '1.1';

    % Create ROI
    roi_img = ones(10, 10, 10); % All ones - keep everything
    roi_nii.img = roi_img;
    roi_nii.mat = [1 0 0 -5; 0 1 0 -5; 0 0 1 -5; 0 0 0 1];

    test_dir = fileparts(mfilename('fullpath'));
    roi_path = fullfile(test_dir, 'test_roi_struct.nii');
    ea_write_nii(roi_nii, roi_path);

    % Test with struct input
    fiberFiltered = ea_filterfiber_roi(ftr_struct, roi_path);

    % Verify struct output
    assert(isstruct(fiberFiltered), 'Output should be struct');
    assert(isfield(fiberFiltered, 'fibers'), 'Output should have fibers field');
    assert(isfield(fiberFiltered, 'idx'), 'Output should have idx field');
    assert(size(fiberFiltered.fibers, 1) == 3, 'Should keep all 3 points');

    delete(roi_path);

    fprintf('  ✓ PASSED: Struct input/output works correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 4: Fiber index renumbering
fprintf('Test 4: Fiber index renumbering...\n');
try
    % Create fibers with gaps in numbering (fiber 1, 3, 5 - missing 2, 4)
    fibers = [
        0, 0, 0, 1;
        1, 1, 1, 1;
        0, 1, 0, 3;
        1, 2, 1, 3;
        0, 0, 1, 5;
        1, 1, 2, 5;
    ];

    % ROI that keeps all fibers
    roi_img = ones(20, 20, 20);
    roi_nii.img = roi_img;
    roi_nii.mat = [1 0 0 -10; 0 1 0 -10; 0 0 1 -10; 0 0 0 1];

    test_dir = fileparts(mfilename('fullpath'));
    roi_path = fullfile(test_dir, 'test_roi_renumber.nii');
    ea_write_nii(roi_nii, roi_path);

    fiberFiltered = ea_filterfiber_roi(fibers, roi_path);

    % Check that indices are renumbered sequentially
    unique_indices = unique(fiberFiltered(:,4));
    expected_indices = (1:length(unique_indices))';
    assert(isequal(unique_indices, expected_indices), ...
        'Fiber indices should be renumbered to 1,2,3...');

    delete(roi_path);

    fprintf('  ✓ PASSED: Fiber index renumbering works correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

fprintf('\n=== All ea_filterfiber_roi tests PASSED ===\n\n');

end
