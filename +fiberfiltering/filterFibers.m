function result = filterFibers(fibers, varargin)
% FILTERFIBERS High-level interface for fiber filtering operations
%   Unified interface to filter fiber tractography data by various criteria.
%
%   Syntax:
%       result = filterFibers(fibers, 'Method', method, 'Param', value, ...)
%
%   Input Arguments:
%       fibers - Fiber data (matrix or struct)
%                Matrix format: [x, y, z, fiber_index]
%                Struct format: struct with 'fibers' and 'idx' fields
%
%   Name-Value Pairs:
%       'Method'      - Filtering method: 'roi', 'stimulation', 'length'
%       'ROI'         - Path to ROI NIfTI file (for method='roi')
%       'Coords'      - Contact coordinates (for method='stimulation')
%       'StimVector'  - Stimulation parameters (for method='stimulation')
%       'Model'       - VAT model: 'kuncel' or 'maedler' (default: 'kuncel')
%       'Factor'      - Radius scaling factor (default: 1)
%       'MinLength'   - Minimum fiber length in mm (for method='length')
%       'Output'      - Output file path (optional)
%
%   Output:
%       result - Filtered fiber data (format matches input)
%
%   Examples:
%       % Filter by ROI
%       filtered = filterFibers(fibers, 'Method', 'roi', 'ROI', 'roi.nii');
%
%       % Filter by length
%       filtered = filterFibers(fibers, 'Method', 'length', 'MinLength', 10);
%
%       % Filter by stimulation
%       coords = {[0,0,0; 0,0,3], []};
%       stim = [3.0, 0, 0, 0; 0, 0, 0, 0];
%       filtered = filterFibers(fibers, 'Method', 'stimulation', ...
%                               'Coords', coords, 'StimVector', stim);
%
%   See also: fiberfiltering.core.filterByROI,
%             fiberfiltering.core.filterByStimulation,
%             fiberfiltering.core.filterByLength

%   Author: Fiberfiltering Development Team
%   Version: 1.0

% Parse inputs
p = inputParser;
addRequired(p, 'fibers');
addParameter(p, 'Method', 'roi', @(x) ischar(x) || isstring(x));
addParameter(p, 'ROI', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'Coords', {}, @iscell);
addParameter(p, 'StimVector', [], @isnumeric);
addParameter(p, 'Model', 'kuncel', @(x) ischar(x) || isstring(x));
addParameter(p, 'Factor', 1, @isnumeric);
addParameter(p, 'MinLength', 10, @isnumeric);
addParameter(p, 'Output', '', @(x) ischar(x) || isstring(x));

parse(p, fibers, varargin{:});

method = lower(p.Results.Method);
output = p.Results.Output;

% Dispatch to appropriate filtering function
switch method
    case 'roi'
        if isempty(p.Results.ROI)
            error('fiberfiltering:missingROI', ...
                'ROI parameter required for method=''roi''');
        end
        result = fiberfiltering.core.filterByROI(fibers, p.Results.ROI, output);

    case {'stim', 'stimulation'}
        if isempty(p.Results.Coords) || isempty(p.Results.StimVector)
            error('fiberfiltering:missingStimParams', ...
                'Coords and StimVector required for method=''stimulation''');
        end
        result = fiberfiltering.core.filterByStimulation(...
            fibers, p.Results.Coords, p.Results.StimVector, ...
            p.Results.Model, p.Results.Factor);

    case {'len', 'length'}
        result = fiberfiltering.core.filterByLength(fibers, p.Results.MinLength);

    otherwise
        error('fiberfiltering:unknownMethod', ...
            'Unknown filtering method: %s', method);
end

end
