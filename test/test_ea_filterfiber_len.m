function test_ea_filterfiber_len()
% Test suite for ea_filterfiber_len function
% Tests fiber filtering based on fiber length threshold

fprintf('\n=== Testing ea_filterfiber_len ===\n');

%% Test 1: Basic length filtering
fprintf('Test 1: Basic length filtering...\n');
try
    % Create fibers of different lengths
    % Fiber 1: length ~1.73mm (sqrt(3))
    % Fiber 2: length ~17.3mm (10*sqrt(3))
    % Fiber 3: length ~34.6mm (20*sqrt(3))
    ftr.fibers = [
        % Short fiber (~1.73mm)
        0, 0, 0, 1;
        1, 1, 1, 1;
        % Medium fiber (~17.3mm total)
        0, 0, 0, 2;
        5, 5, 5, 2;
        10, 10, 10, 2;
        % Long fiber (~34.6mm total)
        0, 0, 0, 3;
        10, 10, 10, 3;
        20, 20, 20, 3;
    ];
    ftr.idx = [2; 3; 3]; % Number of points per fiber

    % Filter with 10mm threshold - should keep fibers 2 and 3
    minFibLen = 10;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);

    % Verify results
    assert(length(fiberFiltered) == 1, 'Should return cell array with 1 element');
    unique_fibers = unique(fiberFiltered{1}.fibers(:,4));

    assert(~ismember(1, unique_fibers), 'Short fiber should be removed');
    assert(ismember(2, unique_fibers), 'Medium fiber should be kept');
    assert(ismember(3, unique_fibers), 'Long fiber should be kept');

    fprintf('  ✓ PASSED: Basic length filtering works correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 2: All fibers too short
fprintf('Test 2: All fibers below threshold...\n');
try
    % Create only short fibers
    ftr.fibers = [
        0, 0, 0, 1;
        1, 1, 1, 1;
        0, 0, 0, 2;
        0.5, 0.5, 0.5, 2;
    ];
    ftr.idx = [2; 2];

    % Very high threshold - should remove all
    minFibLen = 100;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);

    assert(isempty(fiberFiltered{1}.fibers), 'All fibers should be removed');
    assert(isempty(fiberFiltered{1}.idx), 'idx should be empty');

    fprintf('  ✓ PASSED: All fibers removed when below threshold\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 3: All fibers above threshold
fprintf('Test 3: All fibers above threshold...\n');
try
    % Create long fibers
    ftr.fibers = [
        0, 0, 0, 1;
        10, 10, 10, 1;
        20, 20, 20, 1;
        0, 0, 0, 2;
        15, 15, 15, 2;
    ];
    ftr.idx = [3; 2]; % 2 fibers

    % Low threshold - should keep all
    minFibLen = 1;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);

    unique_fibers = unique(fiberFiltered{1}.fibers(:,4));
    assert(length(unique_fibers) == 2, 'Both fibers should be kept');

    fprintf('  ✓ PASSED: All fibers kept when above threshold\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 4: Empty input handling
fprintf('Test 4: Empty input handling...\n');
try
    % Empty fiber structure
    ftr.fibers = [];
    ftr.idx = [];

    minFibLen = 10;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);

    assert(isempty(fiberFiltered{1}.fibers), 'Empty input should give empty output');

    fprintf('  ✓ PASSED: Empty input handled correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 5: Cell array input with multiple connectomes
fprintf('Test 5: Multiple connectome (cell array) input...\n');
try
    % Create two separate fiber sets
    ftr1.fibers = [
        0, 0, 0, 1;
        10, 10, 10, 1; % Length ~17mm
    ];
    ftr1.idx = [2];

    ftr2.fibers = [
        0, 0, 0, 1;
        1, 1, 1, 1; % Length ~1.7mm
    ];
    ftr2.idx = [2];

    % Pass as cell array
    minFibLen = 5;
    fiberFiltered = ea_filterfiber_len({ftr1, ftr2}, minFibLen);

    % First set should keep the fiber, second should remove it
    assert(~isempty(fiberFiltered{1}.fibers), 'Long fiber should be kept');
    assert(isempty(fiberFiltered{2}.fibers), 'Short fiber should be removed');

    fprintf('  ✓ PASSED: Multiple connectome input works correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 6: Precise length calculation
fprintf('Test 6: Precise length calculation...\n');
try
    % Create fiber with known length
    % Total length = sqrt((3-0)^2 + (4-0)^2 + (0-0)^2) = 5mm exactly
    ftr.fibers = [
        0, 0, 0, 1;
        3, 4, 0, 1;
    ];
    ftr.idx = [2];

    % Test with threshold at exactly 5mm
    minFibLen = 5.0;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);

    % Should keep it (>= threshold)
    assert(~isempty(fiberFiltered{1}.fibers), 'Fiber at exact threshold should be kept');

    % Test with threshold just above 5mm
    minFibLen = 5.1;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);

    % Should remove it
    assert(isempty(fiberFiltered{1}.fibers), 'Fiber below threshold should be removed');

    fprintf('  ✓ PASSED: Precise length calculation correct\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 7: Multi-segment fiber length
fprintf('Test 7: Multi-segment fiber length calculation...\n');
try
    % Create fiber with multiple segments
    % Segment 1: (0,0,0) to (3,0,0) = 3mm
    % Segment 2: (3,0,0) to (3,4,0) = 4mm
    % Total: 7mm
    ftr.fibers = [
        0, 0, 0, 1;
        3, 0, 0, 1;
        3, 4, 0, 1;
    ];
    ftr.idx = [3];

    % Test with threshold of 6mm (should keep)
    minFibLen = 6;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);
    assert(~isempty(fiberFiltered{1}.fibers), 'Multi-segment fiber should be kept');

    % Test with threshold of 8mm (should remove)
    minFibLen = 8;
    fiberFiltered = ea_filterfiber_len(ftr, minFibLen);
    assert(isempty(fiberFiltered{1}.fibers), 'Multi-segment fiber should be removed');

    fprintf('  ✓ PASSED: Multi-segment length calculation correct\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

fprintf('\n=== All ea_filterfiber_len tests PASSED ===\n\n');

end
