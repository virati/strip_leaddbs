function [vals,fibcell,usedidx] = ea_discfibers_loadModel_calcstats(obj,vals_connected)

% vals_connected are defined in the subspace of connected fiber for the
% particular lead-group loaded in Fiber Filtering Explorer


switch obj.multitractmode
    case 'Split & Color By Group'
        groups = unique(obj.M.patient.group)';
        dogroups = 1;
        dosubscores = 0;
    case 'Split & Color By Subscore'
        if ~isempty(obj.subscore.vars) %this will be empty when user
            %initializes the split by subscore button
           groups = 1:length(obj.subscore.vars);
           dosubscores = 1;
           dogroups = 0;
        else
            obj.multitractmode = 'Single Tract Analysis';
            groups = 1;
            dogroups = 0;
            dosubscores = 0;
        end
    case 'Split & Color By PCA'
        groups = 1:length(obj.subscore.pcavars);
        dosubscores = 1;
        dogroups = 0;
    otherwise
        groups=1;
        dogroups = 0;
        dosubscores = 0;
end


% vals does not contain zero entries
vals = cell(size(vals_connected));
usedidx = cell(size(vals_connected));
for group = 1:size(vals,1)
    for side=1:size(vals,2)

        usedidx{group,side}=find(vals_connected{group,side});
        vals{group,side}=vals_connected{group,side}(usedidx{group,side}); % final weights for surviving fibers

        %fibcell{group,side}=obj.results.(ea_conn2connid(obj.connectome)).fibcell{side}(~isnan(vals{group,side}));
        fibcell{group,side}=obj.results.(ea_conn2connid(obj.connectome)).fibcell{side}(usedidx{group,side});

        %if exist('pvals','var')
        %    pvals{group,side}=pvals{group,side}(usedidx{group,side}); % final weights for surviving fibers
        %end


        switch obj.threshstrategy
            case 'Fixed Amount' % here we want to create threshs for each side separately.
                posvals = sort(vals{group,side}(vals{group,side}>0),'descend');
                negvals = sort(vals{group,side}(vals{group,side}<0),'ascend');
            otherwise % in other cases, we want to apply the same thresh to both sides.
                allvals = vertcat(vals{group,:});
                posvals = sort(allvals(allvals>0),'descend');
                negvals = sort(allvals(allvals<0),'ascend');
        end
        % positive thresholds
        if dosubscores || dogroups
            if obj.subscore.special_case
                if ~obj.posvisible || ~obj.showposamount(side) || isempty(posvals)
                    posthresh = inf;
                else
                    posthresh = ea_fibValThresh(obj.threshstrategy, posvals, obj.showposamount(side));
                end
            else
                if ~obj.subscore.posvisible(group) || ~obj.subscore.vis.showposamount(group,side) || isempty(posvals)
                    posthresh = inf;
                else
                    posthresh = ea_fibValThresh(obj.threshstrategy, posvals, obj.subscore.vis.showposamount(group,side));
                end
            end
        else
            if ~obj.posvisible || ~obj.showposamount(side) || isempty(posvals)
                posthresh = inf;
            else
                posthresh = ea_fibValThresh(obj.threshstrategy, posvals, obj.showposamount(side));
            end
        end

        % negative thresholds
        if dosubscores || dogroups
            if obj.subscore.special_case
                if ~obj.negvisible || ~obj.shownegamount(side) || isempty(negvals)
                    negthresh = -inf;
                else
                    negthresh = ea_fibValThresh(obj.threshstrategy, negvals, obj.shownegamount(side));
                end
            else
                if ~obj.subscore.negvisible(group) || ~obj.subscore.vis.shownegamount(group,side) || isempty(negvals)
                    negthresh = -inf;
                else
                    negthresh = ea_fibValThresh(obj.threshstrategy, negvals, obj.subscore.vis.shownegamount(group,side));
                end
            end
        else
            if ~obj.negvisible || ~obj.shownegamount(side) || isempty(negvals)
                negthresh = -inf;
            else
                negthresh = ea_fibValThresh(obj.threshstrategy, negvals, obj.shownegamount(side));
            end
        end

        % Remove vals and fibers outside the thresholding range (set by
        % sliders)
        remove = logical(logical(vals{group,side}<posthresh) .* logical(vals{group,side}>negthresh));
        vals{group,side}(remove)=[];
        fibcell{group,side}(remove)=[];
        usedidx{group,side}(remove)=[];

    end
end


