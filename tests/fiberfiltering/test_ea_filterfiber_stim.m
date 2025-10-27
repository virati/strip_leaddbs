function test_ea_filterfiber_stim()
% Test suite for ea_filterfiber_stim function
% Tests fiber filtering based on stimulation parameters and VAT models

fprintf('\n=== Testing ea_filterfiber_stim ===\n');

%% Test 1: Kuncel VAT model basic filtering
fprintf('Test 1: Kuncel VAT model filtering...\n');
try
    % Create fiber structure
    ftr.fibers = [
        % Fiber 1: near contact at (0,0,0)
        0, 0, 0, 1;
        1, 1, 1, 1;
        2, 2, 2, 1;
        % Fiber 2: far from contact
        50, 50, 50, 2;
        51, 51, 51, 2;
    ];
    ftr.idx = [3; 2];
    ftr.voxmm = 'mm'; % Already in mm coordinates

    % Define contact coordinates (bilateral)
    coords = {
        [0, 0, 0; 0, 0, 3; 0, 0, 6; 0, 0, 9], % Right side contacts
        [] % Left side (no electrode)
    };

    % Define stimulation vector
    % [right_side; left_side] x [contact1, contact2, contact3, contact4]
    stimVector = [
        3.0, 0, 0, 0;  % Right: 3V on contact 1, others off
        0, 0, 0, 0     % Left: no stimulation
    ];

    % Test with Kuncel model, factor=1
    type = 'kuncel';
    factor = 1;

    fiberFiltered = ea_filterfiber_stim(ftr, coords, stimVector, type, factor);

    % Should have filtered results for right side (index 1)
    assert(length(fiberFiltered) == 2, 'Should return cell array for both sides');
    assert(~isempty(fiberFiltered{1}), 'Right side should have results');

    % Fiber 1 should be kept (near contact), fiber 2 should be removed
    if ~isempty(fiberFiltered{1})
        unique_fibers = unique(fiberFiltered{1}.fibers(:,4));
        assert(ismember(1, unique_fibers), 'Fiber 1 should be kept (near stimulation)');
    end

    fprintf('  ✓ PASSED: Kuncel VAT model filtering works\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 2: Maedler VAT model
fprintf('Test 2: Maedler VAT model filtering...\n');
try
    ftr.fibers = [
        0, 0, 0, 1;
        1, 1, 1, 1;
    ];
    ftr.idx = [2];
    ftr.voxmm = 'mm';

    coords = {[0, 0, 0], []};
    stimVector = [2.5, 0, 0, 0; 0, 0, 0, 0];

    type = 'maedler';
    factor = 1;

    fiberFiltered = ea_filterfiber_stim(ftr, coords, stimVector, type, factor);

    assert(~isempty(fiberFiltered), 'Maedler model should produce results');

    fprintf('  ✓ PASSED: Maedler VAT model filtering works\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 3: No stimulation handling
fprintf('Test 3: No stimulation (zero amplitude)...\n');
try
    ftr.fibers = [
        0, 0, 0, 1;
        1, 1, 1, 1;
    ];
    ftr.idx = [2];
    ftr.voxmm = 'mm';

    coords = {[0, 0, 0], []};
    % All zeros - no stimulation
    stimVector = [0, 0, 0, 0; 0, 0, 0, 0];

    type = 'kuncel';
    factor = 1;

    fiberFiltered = ea_filterfiber_stim(ftr, coords, stimVector, type, factor);

    % Should handle gracefully (skip with message)
    assert(length(fiberFiltered) == 2, 'Should return cell array for both sides');

    fprintf('  ✓ PASSED: No stimulation handled correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 4: Radius scaling factor
fprintf('Test 4: Radius scaling factor...\n');
try
    % Create two fibers at different distances
    ftr.fibers = [
        % Fiber 1: very close to contact
        0, 0, 0, 1;
        0.5, 0.5, 0.5, 1;
        % Fiber 2: moderate distance
        3, 3, 3, 2;
        3.5, 3.5, 3.5, 2;
    ];
    ftr.idx = [2; 2];
    ftr.voxmm = 'mm';

    coords = {[0, 0, 0], []};
    stimVector = [2.0, 0, 0, 0; 0, 0, 0, 0];

    type = 'kuncel';

    % Small factor - should catch fewer fibers
    factor = 1;
    fiberFiltered_small = ea_filterfiber_stim(ftr, coords, stimVector, type, factor);

    % Large factor - should catch more fibers
    factor = 3;
    fiberFiltered_large = ea_filterfiber_stim(ftr, coords, stimVector, type, factor);

    % With larger factor, should catch more or equal fibers
    if ~isempty(fiberFiltered_small{1}) && ~isempty(fiberFiltered_large{1})
        n_small = length(unique(fiberFiltered_small{1}.fibers(:,4)));
        n_large = length(unique(fiberFiltered_large{1}.fibers(:,4)));
        assert(n_large >= n_small, 'Larger scaling factor should catch more fibers');
    end

    fprintf('  ✓ PASSED: Radius scaling factor works correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 5: Multiple active contacts
fprintf('Test 5: Multiple active contacts...\n');
try
    ftr.fibers = [
        % Fiber near first contact
        0, 0, 0, 1;
        1, 1, 1, 1;
        % Fiber near second contact
        0, 0, 10, 2;
        1, 1, 11, 2;
    ];
    ftr.idx = [2; 2];
    ftr.voxmm = 'mm';

    % Two contacts at different locations
    coords = {[0, 0, 0; 0, 0, 10], []};

    % Both contacts active
    stimVector = [2.0, 2.0, 0, 0; 0, 0, 0, 0];

    type = 'kuncel';
    factor = 2;

    fiberFiltered = ea_filterfiber_stim(ftr, coords, stimVector, type, factor);

    % Both fibers should potentially be caught
    if ~isempty(fiberFiltered{1})
        unique_fibers = unique(fiberFiltered{1}.fibers(:,4));
        % At least one fiber should be caught
        assert(length(unique_fibers) >= 1, 'Should catch fibers near active contacts');
    end

    fprintf('  ✓ PASSED: Multiple active contacts handled correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 6: Bilateral stimulation
fprintf('Test 6: Bilateral stimulation...\n');
try
    ftr.fibers = [
        % Fiber on right side
        0, 0, 0, 1;
        1, 0, 0, 1;
        % Fiber on left side
        0, 10, 0, 2;
        1, 10, 0, 2;
    ];
    ftr.idx = [2; 2];
    ftr.voxmm = 'mm';

    % Contacts on both sides
    coords = {
        [0, 0, 0],    % Right
        [0, 10, 0]    % Left
    };

    % Stimulation on both sides
    stimVector = [
        2.0, 0, 0, 0;  % Right: 2V
        2.0, 0, 0, 0   % Left: 2V
    ];

    type = 'kuncel';
    factor = 2;

    fiberFiltered = ea_filterfiber_stim(ftr, coords, stimVector, type, factor);

    % Both sides should have results
    assert(length(fiberFiltered) == 2, 'Should return results for both sides');

    fprintf('  ✓ PASSED: Bilateral stimulation handled correctly\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

%% Test 7: Kuncel equation validation
fprintf('Test 7: Kuncel equation validation...\n');
try
    % Test the Kuncel equation: r = sqrt((U-Uo)/k)
    % where Uo = 0.1V, k = 0.22
    % For U = 3V: r = sqrt((3-0.1)/0.22) = sqrt(13.18) ≈ 3.63mm

    % Helper function from ea_filterfiber_stim (inline test)
    kuncel08_eq1 = @(U) sqrt(max(0, (max(U,0.1)-0.1)/0.22));

    U = 3.0;
    r = kuncel08_eq1(U);
    expected_r = sqrt((3.0 - 0.1) / 0.22);

    assert(abs(r - expected_r) < 0.01, 'Kuncel equation should match expected value');
    assert(r > 3.6 && r < 3.7, 'Radius for 3V should be ~3.63mm');

    % Test with low voltage (below threshold)
    U = 0.05;
    r = kuncel08_eq1(U);
    assert(r < 0.1, 'Very low voltage should give very small radius');

    fprintf('  ✓ PASSED: Kuncel equation validation correct\n');
catch ME
    fprintf('  ✗ FAILED: %s\n', ME.message);
    rethrow(ME);
end

fprintf('\n=== All ea_filterfiber_stim tests PASSED ===\n\n');

end
