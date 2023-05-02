function out = get_flanking_events(SacStructOut,modePad,targetEvents,plotSummary,processedGaze,savepath)
% out = get_flanking_events(SacStructOut)
% out = get_flanking_events(SacStructOut,modePad)
% out = get_flanking_events(SacStructOut,modePad,targetEvents)
% out = get_flanking_events(SacStructOut,modePad,targetEvents,plotSummary)
% out = get_flanking_events(SacStructOut,modePad,targetEvents,plotSummary,processedGaze)
% out = get_flanking_events(SacStructOut,modePad,targetEvents,plotSummary,processedGaze,savepath)
%
% for each gaze event, gets the mode of the flanking samples within 
% *modePad* samples (default=5)
%
% can do it only for TargetEvents, which index the event types:
% 1='Fixation', 2='Saccade', 3='SmoothPursuit'


%settings
if nargin<2 || isempty(modePad)
    modePad = 4; %should be even
end
if mod(modePad,2)~=0; modePad = modePad+1; warning('modePadding should be even, adding 1'); end

types = {'Fixation','Saccade','SmoothPursuit'};
if nargin < 3 || isempty(targetEvents)
   targetEvents = 1:numel(types);
end

if nargin < 4
    plotSummary = 0;
end

if nargin < 5
    plotBad = 0;
else
    plotBad = 1;
    
    t = processedGaze.EyetrackerTimestamp * 10^-6;
    d = processedGaze.Distance;
    [screenX,screenY] = get_experiment_parameters('tx300');
    [x,y] = acds2dva(processedGaze.XMean,processedGaze.YMean,d,screenX,screenY);
    [xs,ys] = acds2dva(processedGaze.XSmooth,-1*processedGaze.YSmooth,d,screenX,screenY);

%     toi_bad = nan(0,2);
end

if nargin < 6
    savepath = '';
    visible = 'on';
else
    if ~exist(savepath); mkdir(savepath); end
    visible = 'off';
end

   
%prepare output
out = [];
out.SacStructOut = SacStructOut;
out.flanks_all = {};

%prepare figure
if plotSummary
    figure;
    nr = numel(targetEvents); nc = 6;
end

%loop through all types
classTypes = get_class_map();
    
for itype=targetEvents
    typestr = [types{itype} 'Info'];
    disp(['getting flanking events for ' types{itype}])
    
    st = SacStructOut.(typestr).StartGazeRow;
    fn = SacStructOut.(typestr).EndGazeRow;

    %classification vector
    classification = -1*ones(size(SacStructOut.Saccade)); %never classified should be included in mode computation
    for iclass=1:size(classTypes,1)
        classification(SacStructOut.(classTypes{iclass,1})) = classTypes{iclass,2};
    end
    %classification( isnan(SacStructOut.Unclassified) ) = -1; 

    %loop through all current events
    flank = nan(numel(st),1);
    dur = flank;
    nearestEvent = flank;
    for n=1:numel(st)
%         dotdotdot(n,ceil(0.1*numel(st)),numel(st))

        %where does this start or end?
        ist = st(n);
        ifn = fn(n);

        %left flank
        if ist==1
            c1 = nan;
        else
            c1 = classification( max(ist-modePad,1):ist-1);
        end
        c1 = mode(c1);
        flank(n,1) = c1;

        %right flank
        if ifn==numel(classification)
            c2 = nan;
        else
            %if saccade, ignore PSO
%             if itype==2 && classification(ifn+1)==2
%                 psoEnd = find(classification(ifn:end)~=2,1);
%             else
%                 psoEnd = ifn;
%             end
            c2 = classification( ifn+1:min(ifn+modePad,numel(classification)) );
        end
        c2 = mode(c2);
        flank(n,2) = c2;
        
       
%         if c2==5
%             base = xs(ifn:ifn+30);
%             if any( abs(base(2:end) - base(1)) > 4)
%                 toi_bad(size(toi_bad,1)+1,:) = [t(ist) t(ifn)];
%             end
%             
%         end
        
if n==105
    foo=1;
end

        %plot some bad stuff
        if plotBad
%             x = processedGaze.XMean;
%             xs = processedGaze.XSmooth;
%             y = processedGaze.YMean;
%             ys = -1*processedGaze.YSmooth;

            pad = 30;
            if c1==-1 || c1==5 % || c2==-1 || c2==5
                fig = figure('visible',visible);

                ind = max(1,ist-pad) : min(ifn+pad,numel(classification));
                
                t2 = t(ind)-t(ind(1));
                xx = {x(ind),xs(ind)};
                yy = {y(ind),ys(ind)};
                tt = {t2,t2};
                gt = plot_gaze_trace(tt,xx,yy,[t(ist) t(ifn)]-t(ind(1)),{'raw','smooth'},2,fig);
                
                %plot the classification
                col = 'cgmrbk';
                cind = [-1, 1:5];
                for cc=1:numel(col)
                    sel = classification(ind)==cind(cc);
                    ylim = get(gt.hy,'ylim');
                    if ylim(2)==0; offset = 0.1;
                    else offset = abs(ylim(2)) * 0.01;
                    end
                    tmp = (ylim(2) + offset) * ones(size(sel));
                    tmp(~sel) = nan;
                    plot(gt.hy,t2,tmp,[col(cc) 'o'])
                end
                set(gt.hy,'ylim',[ylim(1),ylim(2) + offset*1.01])

                if ~strcmp(savepath,'')
                    name = [savepath '/' types{itype} '_' num2str(n)];
                    print(name,'-dpng')
                else
                    pause
                end
                close(gt.fig)

            end
        end
        
        %figure out what the nearest event is and how dar away it is
        
        % index of other events, exclusing non-classified/nans
        otherEvent = classification ~= 5 & classification ~= -1;
    
        %left flank
        tmp1 = otherEvent(1:ist-1);
        ii1 = find(tmp1,1,'last');
        if ~isnan(c1) && ~isempty(ii1)
            nearestEvent(n,1) = classification(ii1);
            dur(n,1) = ist - ii1;
        else
            nearestEvent(n,1) = nan;
            dur(n,1) = nan;
        end

        %right flank
        tmp2 = otherEvent(ifn+1:end);
        ii2 = find(tmp2,1);
        if ~isnan(c2) && ~isempty(ii2)
            nearestEvent(n,2) = classification(ii2+ifn);
            dur(n,2) = ii2;
        else
            nearestEvent(n,2) = nan;
            dur(n,2) = nan;
        end
    end

    %append
    out.SacStructOut.(typestr).FlankingEvents = flank;
    out.SacStructOut.(typestr).NearestEvent = nearestEvent;
    out.SacStructOut.(typestr).SamplesToNearestEvent = dur;

    out.flanks_all{itype,1} = types{itype};
    out.flanks_all{itype,2} = flank;
    
    %plot reults
    N = size(dur,1);
    flankstr = {'before','after'};
    xtick = {};
    for ic=1:size(classTypes,1)
        xtick{ic} = classTypes{ic,1}(1:3);
    end
    %xtick{ic+1} = 'nan';
    if plotSummary
        itype2 = find(targetEvents==itype);
        for iflank=1:2
            if iflank==1
                ns = (itype2-1)*nc + 1;
            else
                ns = (itype2-1)*nc + 4;
            end
            good = dur(:,iflank) < ceil(modePad/2);
            
            %plot durations
            subplot(nr,nc,ns)
            d = dur(:,iflank);
            d(good) = [];
            [c,b] = hist(d,100);
            c = c ./ N;
            bar(b,c)
            xlabel('duration')
            ylabel('percent')
            str = sprintf('samples to next\nclassified event\n%s %s\nexlcud. adj,\ntotal=%g/%g',...
                flankstr{iflank},types{itype},numel(d),N);
            title(str)
            
            %plot proportion of events
            ns = ns+1;
            subplot(nr,nc,ns)
            nclass = size(classTypes,1);
            p = [];
            for ic=1:nclass
                ii = classTypes{ic,2};
                p(ic) = sum(nearestEvent(~good,iflank)==ii);
            end
            p = p ./ N;
            bar(p)
            set(gca,'xticklabel',xtick)
            ylabel('proportion')
            str = sprintf('porportion of\nnearest events\n%s %s\nexlcud. adj,\ntotal=%g/%g',...
                flankstr{iflank},types{itype},numel(d),N);
            title(str)
            
            % plot porportion of directly flanking events
            %plot proportion of events
            ns = ns+1;
            subplot(nr,nc,ns)
            nclass = size(classTypes,1);
            p = [];
            for ic=1:nclass
                ii = classTypes{ic,2};
                p(ic) = sum(flank(:,iflank)==ii);
            end
            p = p ./ N;
            bar(p)
            set(gca,'xticklabel',xtick)
            ylabel('proportion')
            str = sprintf('porportion of\nflanking samples(mode w/in %g smp)\n%s %s',...
                modePad,flankstr{iflank},types{itype});
            title(str)
        end
        
        set_bigfig(gcf,[0.8 0.8])
    end
end



% %check
% for ii=1:5
% str = sprintf('%g, %s',ii,mat2str(sum(flank==ii) ./ size(flank,1),3));
% disp(str)
% end