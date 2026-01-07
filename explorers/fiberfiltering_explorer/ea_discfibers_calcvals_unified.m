function [fibsval, fibcell, connFiberInd, totalFibers] = ea_discfibers_calcvals_unified(method, inputlist, fibers, idx, obj, varargin)
% EA_DISCFIBERS_CALCVALS_UNIFIED Unified function for all fiber connectivity calculation methods
%
% This function consolidates the functionality of:
%   - ea_discfibers_calcvals.m (E-field/VAT method)
%   - ea_discfibers_calcvals_pam.m (PAM binary method)
%   - ea_discfibers_calcvals_pam_prob.m (PAM probabilistic method)
%   - ea_discfibers_calcvals_cleartune.m (Cleartune method)
%
% Inputs:
%   method      - String specifying calculation method:
%                 'efield'     - E-field/VAT based connectivity
%                 'pam_binary' - PAM binary activation (0/1)
%                 'pam_prob'   - PAM probabilistic activation (0-1)
%                 'cleartune'  - Cleartune optimization
%   inputlist   - Cell array of input files:
%                 For efield/cleartune: vatlist (VAT/E-field files)
%                 For pam_*: pamlist (PAM activation files)
%   fibers      - Connectome fibers matrix [x,y,z,fiber_id] (ALREADY LOADED)
%                 For cleartune: pass [] (uses fibcell_input instead)
%   idx         - Connectome fiber length indices (ALREADY LOADED)
%                 For cleartune: pass [] (uses fibcell_input instead)
%   obj         - ea_disctract object
%   varargin    - Method-specific parameters:
%                 For efield: varargin{1} = thresh (E-field threshold)
%                 For cleartune: varargin{1} = fibcell_input (pre-loaded fiber cell)
%                                varargin{2} = thresh (E-field threshold)
%
% Outputs:
%   fibsval     - Struct with connectivity matrices (all sparse):
%                 .bin   - Binary connectivity (all methods)
%                 .sum   - E-field sum (efield/cleartune only)
%                 .mean  - E-field mean (efield/cleartune only)
%                 .peak  - E-field peak (efield/cleartune only)
%                 .peak5 - E-field top 5% (efield/cleartune only)
%                 .prob  - Probabilistic PAM (pam_prob only)
%   fibcell     - Cell array {1,numSide} of connected fibers
%   connFiberInd - Cell array {1,numSide} of connected fiber indices
%   totalFibers - Total number of fibers in connectome
%
% Memory optimization notes:
%   - fibers and idx are passed as parameters (loaded once by caller)
%   - All output matrices are stored as SPARSE
%   - Caller should clear fibers/idx after this function returns
%
% Example usage:
%   % Load connectome once
%   load(cfile, 'fibers', 'idx');
%
%   % Call unified function
%   [fibsval, fibcell, connFiberInd, totalFibers] = ...
%       ea_discfibers_calcvals_unified('efield', vatlist, fibers, idx, obj, thresh);
%
%   % Free memory
%   clear fibers idx;

% Get preferences
prefs = ea_prefs;

% Method-specific initialization
switch method
    case 'efield'
        % E-field/VAT method
        if ~isempty(varargin)
            thresh = varargin{1};
        else
            thresh = prefs.machine.vatsettings.horn_ethresh*1000;
        end
        [numPatient, numSide] = size(inputlist);
        totalFibers = length(idx);
        useFibcell = false;

    case {'pam_binary', 'pam_prob'}
        % PAM methods
        % Check for mirroring support in connectome
        if exist('mirrored','var') && obj.multi_pathways
            numPatient = length(obj.allpatients) * 2;
        else
            numPatient = length(obj.allpatients);
        end
        numSide = 2;
        totalFibers = length(idx);
        useFibcell = false;
        thresh = []; % Not used for PAM

    case 'cleartune'
        % Cleartune method - uses pre-loaded fibcell
        fibcell_input = varargin{1};
        if length(varargin) >= 2
            thresh = varargin{2};
        else
            thresh = prefs.machine.vatsettings.horn_ethresh*1000;
        end
        [numPatient, numSide] = size(inputlist);
        totalFibers = 0; % Not applicable for cleartune
        useFibcell = true;

    otherwise
        error('Unknown method: %s. Must be efield, pam_binary, pam_prob, or cleartune', method);
end

% Initialize output cells
fibsvalBin = cell(1, numSide);
fibsvalSum = cell(1, numSide);
fibsvalMean = cell(1, numSide);
fibsvalPeak = cell(1, numSide);
fibsval5Peak = cell(1, numSide);
fibsvalProb = cell(1, numSide);

fibcell = cell(1, numSide);
connFiberInd = cell(1, numSide);

% Process each hemisphere
for side = 1:numSide
    % Initialize matrices based on method
    if useFibcell
        % Cleartune: size based on pre-loaded fibcell
        numFibers = length(fibcell_input{side});
    else
        % Other methods: size based on connectome
        numFibers = length(idx);
    end

    fibsvalBin{side} = zeros(numFibers, numPatient);
    if strcmp(method, 'efield') || strcmp(method, 'cleartune')
        fibsvalSum{side} = zeros(numFibers, numPatient);
        fibsvalMean{side} = zeros(numFibers, numPatient);
        fibsvalPeak{side} = zeros(numFibers, numPatient);
        fibsval5Peak{side} = zeros(numFibers, numPatient);
    elseif strcmp(method, 'pam_prob')
        fibsvalProb{side} = zeros(numFibers, numPatient);
    end

    % Convert fibcell to fibmat for cleartune
    if useFibcell
        fibers_side = ea_fibcell2fibmat(fibcell_input{side});
    else
        fibers_side = fibers;
    end

    disp(['Calculate for side ', num2str(side), ':']);

    % Process each patient
    for pt = 1:numPatient
        disp(['Processing ', num2str(pt, ['%0',num2str(numel(num2str(numPatient))),'d']), '/', num2str(numPatient), '...']);

        switch method
            case {'efield', 'cleartune'}
                % E-field/VAT based methods
                % Load VAT
                if isstruct(inputlist)
                    vat = inputlist(pt,side);
                elseif iscell(inputlist)
                    if strcmp(method, 'efield') && strcmp(inputlist{pt,side},"skip")
                        continue
                    elseif strcmp(method, 'efield') && ~isfile(inputlist{pt,side})
                        ea_cprintf('CmdWinWarnings', 'Skipping: VTA doesn''t exist!\n');
                        continue
                    end
                    vat = ea_load_nii(inputlist{pt,side});
                end

                % Threshold VAT
                vatInd = find(abs(vat.img(:)) > thresh);
                if isempty(vatInd)
                    continue
                end

                % Trim fibers to VAT bounding box
                [xvox, yvox, zvox] = ind2sub(size(vat.img), vatInd);
                vatmm = ea_vox2mm([xvox, yvox, zvox], vat.mat);
                if isempty(vatmm)
                    continue
                end

                filter = all(fibers_side(:,1:3)>=min(vatmm),2) & all(fibers_side(:,1:3)<=max(vatmm), 2);
                if ~any(filter)
                    continue
                end

                trimmedFiber = fibers_side(filter,:);

                % Map fibers to VAT voxel space
                [trimmedFiberInd, ~, trimmedFiberID] = unique(trimmedFiber(:,4), 'stable');
                fibVoxInd = splitapply(@(fib) {ea_mm2uniqueVoxInd(fib, vat)}, trimmedFiber(:,1:3), trimmedFiberID);

                % Remove outliers
                fibVoxInd(cellfun(@(x) any(isnan(x)), fibVoxInd)) = [];
                trimmedFiberInd(cellfun(@(x) any(isnan(x)), fibVoxInd)) = [];

                % Find connected fibers
                connected = cellfun(@(fib) any(ismember(fib, vatInd)), fibVoxInd);

                % Binary connectivity
                fibsvalBin{side}(trimmedFiberInd(connected), pt) = 1;

                % Extract E-field values at intersections
                vals = cellfun(@(fib) vat.img(intersect(fib, vatInd)), fibVoxInd(connected), 'Uni', 0);

                % Calculate E-field metrics
                fibsvalSum{side}(trimmedFiberInd(connected), pt) = cellfun(@sum, vals);
                fibsvalMean{side}(trimmedFiberInd(connected), pt) = cellfun(@mean, vals);
                fibsvalPeak{side}(trimmedFiberInd(connected), pt) = cellfun(@max, vals);
                fibsval5Peak{side}(trimmedFiberInd(connected), pt) = cellfun(@(x) mean(maxk(x,ceil(0.05*numel(x)))), vals);

            case 'pam_binary'
                % PAM binary activation method
                if obj.multi_pathways == 1
                    fib_state_raw = load(char(inputlist(pt,side)));
                    total_fibers = length(fib_state_raw.idx);
                    fib_state = zeros(total_fibers,1);
                    last_loc_i = 1;

                    for fib_i = 1:total_fibers
                        fib_state(fib_i) = fib_state_raw.fibers(last_loc_i,5);
                        last_loc_i = fib_state_raw.idx(fib_i)+last_loc_i;
                    end
                else
                    total_fibers = fibers_side(end,4);
                    fib_state = zeros(total_fibers,1);

                    try
                        fib_state_raw = load(char(inputlist(pt,side)));
                    catch
                        warning('fiberActivation not found for patient %d, side %d', pt, side);
                        continue
                    end

                    last_loc_i = 1;
                    sub_i = 1;
                    for fib_i = 1:total_fibers
                        if fib_i > fib_state_raw.fibers(end,4)
                            fib_state(fib_i) = 0;
                        else
                            if fib_state_raw.fibers(last_loc_i,4) == fib_i
                                fib_state(fib_i) = fib_state_raw.fibers(last_loc_i,5);
                                last_loc_i = fib_state_raw.idx(sub_i)+last_loc_i;
                                sub_i = sub_i + 1;
                            else
                                fib_state(fib_i) = 0;
                            end
                        end
                    end
                end

                if ~any(fib_state)
                    continue
                end

                % Find activated fibers (binary: ==1)
                activated = find(fib_state == 1);
                fibsvalBin{side}(activated, pt) = 1;

            case 'pam_prob'
                % PAM probabilistic activation method
                if obj.multi_pathways == 1
                    % Multi-pathway with potential mirroring
                    if strcmp(char(inputlist(pt,side)), 'skip')
                        continue
                    else
                        try
                            fib_state_raw = load(char(inputlist(pt,side)));
                        catch
                            warning('No merged fiberActivation file for patient %d', pt);
                            continue
                        end
                    end

                    total_fibers = length(fib_state_raw.idx);
                    fib_state = zeros(total_fibers,1);
                    last_loc_i = 1;

                    if pt <= length(obj.allpatients)
                        % Original activations
                        for fib_i = 1:total_fibers
                            fib_state(fib_i) = fib_state_raw.fibers(last_loc_i,5);
                            last_loc_i = fib_state_raw.idx(fib_i)+last_loc_i;
                        end
                    else
                        % Mirrored activations
                        fib_state_non_mirror = zeros(total_fibers,1);
                        for fib_i = 1:total_fibers
                            fib_state_non_mirror(fib_i) = fib_state_raw.fibers(last_loc_i,5);
                            last_loc_i = fib_state_raw.idx(fib_i)+last_loc_i;
                        end

                        % Mirror using pathway map
                        for pathway_i = 1:length(obj.map_list)
                            path_start = obj.map_list(pathway_i);

                            if pathway_i ~= length(obj.map_list)
                                path_end = obj.map_list(pathway_i+1) - 1;
                            end

                            if rem(pathway_i,2)
                                path_start_counter = obj.map_list(pathway_i+1);
                                if pathway_i == length(obj.map_list)-1
                                    % Second to last pathway
                                else
                                    path_end_counter = obj.map_list(pathway_i+2) - 1;
                                end
                            else
                                path_start_counter = obj.map_list(pathway_i-1);
                                path_end_counter = obj.map_list(pathway_i) - 1;
                            end

                            % Copy fiber state to counterpart
                            if pathway_i == length(obj.map_list)-1
                                fib_state(path_start:path_end) = fib_state_non_mirror(path_start_counter:end);
                            elseif pathway_i == length(obj.map_list)
                                fib_state(path_start:end) = fib_state_non_mirror(path_start_counter:path_end_counter);
                            else
                                fib_state(path_start:path_end) = fib_state_non_mirror(path_start_counter:path_end_counter);
                            end
                        end
                    end
                else
                    % Non-multi-pathway
                    total_fibers = fibers_side(end,4);
                    fib_state = zeros(total_fibers,1);

                    try
                        fib_state_raw = load(char(inputlist(pt,side)));
                    catch
                        warning('fiberActivation not found for patient %d, side %d', pt, side);
                        continue
                    end

                    last_loc_i = 1;
                    sub_i = 1;
                    for fib_i = 1:total_fibers
                        if fib_i > fib_state_raw.fibers(end,4)
                            fib_state(fib_i) = 0;
                        else
                            if fib_state_raw.fibers(last_loc_i,4) == fib_i
                                fib_state(fib_i) = fib_state_raw.fibers(last_loc_i,5);
                                last_loc_i = fib_state_raw.idx(sub_i)+last_loc_i;
                                sub_i = sub_i + 1;
                            else
                                fib_state(fib_i) = 0;
                            end
                        end
                    end
                end

                if ~any(fib_state)
                    continue
                end

                % Find activated fibers (probabilistic: >=0.05 threshold)
                activated = find(fib_state >= 0.05);
                fibsvalBin{side}(activated, pt) = 1;
                fibsvalProb{side}(activated, pt) = fib_state(activated);
        end
    end

    % Convert to sparse matrices and extract connected fibers
    switch method
        case 'efield'
            % E-field: remove unconnected fibers
            fibIsConnected = any(fibsvalBin{side}, 2);
            fibsvalBin{side} = sparse(fibsvalBin{side}(fibIsConnected, :));
            fibsvalSum{side} = sparse(fibsvalSum{side}(fibIsConnected, :));
            fibsvalMean{side} = sparse(fibsvalMean{side}(fibIsConnected, :));
            fibsvalPeak{side} = sparse(fibsvalPeak{side}(fibIsConnected, :));
            fibsval5Peak{side} = sparse(fibsval5Peak{side}(fibIsConnected, :));

            connFiberInd{side} = find(fibIsConnected);
            connFiber = fibers(ismember(fibers(:,4), connFiberInd{side}), 1:3);
            fibcell{side} = mat2cell(connFiber, idx(connFiberInd{side}));

        case 'cleartune'
            % Cleartune: keep all fibers
            fibsvalBin{side} = sparse(fibsvalBin{side});
            fibsvalSum{side} = sparse(fibsvalSum{side});
            fibsvalMean{side} = sparse(fibsvalMean{side});
            fibsvalPeak{side} = sparse(fibsvalPeak{side});
            fibsval5Peak{side} = sparse(fibsval5Peak{side});
            % fibcell remains as input
            connFiberInd{side} = [];

        case {'pam_binary', 'pam_prob'}
            % PAM: remove unconnected fibers
            fibIsConnected = any(fibsvalBin{side}, 2);
            fibsvalBin{side} = sparse(fibsvalBin{side}(fibIsConnected, :));
            if strcmp(method, 'pam_prob')
                fibsvalProb{side} = sparse(fibsvalProb{side}(fibIsConnected, :));
            end

            connFiberInd{side} = find(fibIsConnected);
            connFiber = fibers(ismember(fibers(:,4), connFiberInd{side}), 1:3);
            fibcell{side} = mat2cell(connFiber, idx(connFiberInd{side}));
    end
end

% For cleartune, use input fibcell
if useFibcell
    fibcell = fibcell_input;
end

% Package outputs into struct
fibsval.bin = fibsvalBin;
if strcmp(method, 'efield') || strcmp(method, 'cleartune')
    fibsval.sum = fibsvalSum;
    fibsval.mean = fibsvalMean;
    fibsval.peak = fibsvalPeak;
    fibsval.peak5 = fibsval5Peak;
end
if strcmp(method, 'pam_prob')
    fibsval.prob = fibsvalProb;
end
