function fibValThreshold = ea_fibValThresh(threshstrategy, vals, threshold)
% EA_FIBVALTHRESH Calculate fiber value threshold based on strategy
%
% Inputs:
%   threshstrategy - String specifying threshold strategy:
%                    'Percentage Relative to Peak'
%                    'Percentage Relative to Amount'
%                    'Fixed Amount'
%                    'Histogram (CDF)'
%                    'Fixed Fiber Value'
%   vals          - Sorted array of fiber values
%   threshold     - Threshold value (interpretation depends on strategy)
%
% Output:
%   fibValThreshold - Calculated threshold value
%
% This function was extracted from ea_discfibers_calcstats.m and
% ea_discfibers_loadModel_calcstats.m to eliminate code duplication.

switch threshstrategy
    case 'Percentage Relative to Peak'
        range = vals(1) - vals(end);
        fibValThreshold = vals(1) - threshold/100 * range;
        if range == 0
            if vals(1) > 0
                fibValThreshold = fibValThreshold - eps*10;
            else
                fibValThreshold = fibValThreshold + eps*10;
            end
        end
    case 'Percentage Relative to Amount'
        index = round((threshold/100)*length(vals));
        if index <=0
            fibValThreshold = vals(1);
        else
            fibValThreshold = vals(index);
        end
    case 'Fixed Amount'
        if length(vals)>round(threshold)
            fibValThreshold=vals(round(threshold));
        else
            fibValThreshold=vals(end);
        end
    case 'Histogram (CDF)'
        if vals(1) > 0
            [fx, x] = ecdf(vals);
            fibValThreshold = x(find(fx>=(1-threshold), 1));
        else
            [fx, x] = ecdf(-vals);
            fibValThreshold = -x(find(fx>=(1-threshold), 1));
        end
    case 'Fixed Fiber Value'
        fibValThreshold = threshold;
end
