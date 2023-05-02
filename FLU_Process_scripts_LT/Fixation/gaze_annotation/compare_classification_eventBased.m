function out = compare_classification_eventBased(dat1,class1,dat2,class2,events,...
    plotSummary,savepathIndividualEvents)

% out = compare_classification_eventBased(dat1,class1,dat2,class2,events)
% out = compare_classification_eventBased(dat1,class1,dat2,class2,events,plotSummary)
% out = compare_classification_eventBased(dat1,class1,dat2,class2,events,plotSummary,savepathIndividualEvents)

%settings
if nargin < 6
    plotSummary = 0;
end
if nargin < 7 || (strcmp(savepathIndividualEvents,''))
    plotIndividualEvents = 0;
else
    if ~exist(savepathIndividualEvents); mkdir(savepathIndividualEvents); end
    plotIndividualEvents = 1;
end

disp('event based gaze comparison...')

figVisible = 'off';

types = events(2,:);
events = [events{1,:}];

%testing
% dat1 = [xdeg,ydeg,gaze.EyetrackerTimestamp*10^-6];
% dat2 = dat1;
% 
% class1 = gaze.ManualClassification;
% class2 = gaze.Classification;

%events = [1 3 4];
%types = {'Saccade','Fixation','SmoothPurs'};


if plotSummary
    figSum = figure;
    nr = numel(events);
    nc = 5;
end

%loop over all events
for iv=1:numel(events)
    evt=events(iv);
    
    %extract the info (but we only careabout times really
    sel1 = class1==evt;
    info1 = get_fixation_smoothPursuit_info(dat1,sel1);
    
    sel2 = class2==evt;
    info2 = get_fixation_smoothPursuit_info(dat2,sel2);
    
    % compare
    trueLabel = ones(size(info1.StartTime));
    estLabel = zeros(size(trueLabel));
    
    trueTime = {};
    for is=1:numel(info1.StartTime)
        st = info1.StartGazeRow(is);
        fn = info1.EndGazeRow(is);
        if isnan(st) || isnan(fn)
            trueTime{is} = [];
        else
            trueTime{is} = dat1(st:fn,3);
        end
    end
    
    estTime = {};
    for is=1:numel(info2.StartTime)
        st = info2.StartGazeRow(is);
        fn = info2.EndGazeRow(is);
        if isnan(st) || isnan(fn)
            estTime{is} = [];
        else
            estTime{is} = dat2(st:fn,3);
        end
    end
        
    found = [];
    for is=1:numel(trueTime)
        %metric is this: n_overlap./(ndat1+ndat2)-->0.5 indicates perfect
        %overlap
        
        %find a saccade that overlaps
        t = trueTime{is};
        ii = find( cellfun(@(x) numel(intersect(x,t)),estTime) );
        
        if ~isempty(ii)
            %ii = ii(1); %only consider the first fond segment
            
            %include all samples
            for jj=1:numel(ii)
                ii2 = ii(jj);
                n1 = numel(t);
                n2 = numel(estTime{ii2});
                c = numel(intersect(estTime{ii2},t));
                found(size(found,1)+1,:) = [is,ii2,n1,n2,c./n1,c./n2,c./(n1+n2),n2-n1];
            end
        end
    end
    
    if isempty(found)
        onlyInTrue = 1:numel(trueTime);
        onlyInEst = 1:numel(estTime);
    else
        onlyInTrue = setxor(1:numel(trueTime),found(:,1))';
        onlyInEst = setxor(1:numel(estTime),found(:,2))';
    end
    
    con = [size(found,1),numel(onlyInTrue);
            numel(onlyInEst), 0];
        
    sensitivity = con(1) ./ sum(con(:,1));
    
    %output
    out.(types{iv}).found = found;
    out.(types{iv}).onlyInTrue = onlyInTrue;
    out.(types{iv}).onlyInEst = onlyInEst;
    out.(types{iv}).confusion = con;
    out.(types{iv}).sensitivity = sensitivity;

    
    %plot results
    if plotSummary
        ns = nc*(iv-1)+1;
        subplot(nr,nc,ns)
        imagesc(con)

        ticklabel = {'yes','no'};
        set(gca,'xtick',1:2,'xticklabels',ticklabel)
        set(gca,'ytick',1:2,'yticklabel',ticklabel)
        xlabel('human detection')
        ylabel('algo detection')
        title(types{iv})
        axis square

        for ii=1:size(con,1)
            for jj=1:size(con,2)
                text(jj,ii,num2str(con(ii,jj)))
            end
        end

        %plot porportion of pverlap
        if ~isempty(found)
            tstrs = {'prop overlap relative to true',...
                'prop overlap relative to est',...
                'prop union/total(0.5=max)',...
                'difference in #samples(=est-true'};
            lims = [0 1; 0 1; 0 0.5;nan nan];
            for jj=1:4
                ns = ns+1;
                subplot(nr,nc,ns)

                hist(found(:,4+jj))
                title(tstrs{jj})
                if ~isnan(lims(jj,1))
                    set(gca,'xlim',lims(jj,:))
                end
            end
        end

        set_bigfig(gcf,[1,0.5])
        
        out.summaryfig = figSum;
    end
    
    foo=1;
    
    % plot the individual events
    if plotIndividualEvents
        pad = 10;
        
        
        %plot the agreed events
        for ii=1:size(found,1)
            fig = figure('visible',figVisible);

            try
                ii1 = found(ii,1);
                ii2 = found(ii,2);
                st1 = info1.StartGazeRow(ii1); 
                fn1 = info1.EndGazeRow(ii1); 
                st2 = info2.StartGazeRow(ii2); 
                fn2 = info2.EndGazeRow(ii2); 

                st = min(st1,st2);
                fn = max(fn1,fn2);

                ind = max(1,st-pad):min(fn+pad,numel(class1));
                offset = mean(diff(dat1(ind,3)))*0.1;
                toi1 = [dat1(st1,3), dat1(fn1,3)] - dat1(ind(1),3);
                toi2 = [dat2(st2,3), dat2(fn2,3)] - dat2(ind(1),3) + offset;

                tt = {dat1(ind,3)-dat1(ind(1),3),dat2(ind,3)-dat2(ind(1),3)};
                xx = {dat1(ind,1), dat2(ind,1)};
                yy = {dat1(ind,2), dat2(ind,2)};

                hp = plot_gaze_trace(tt,xx,yy,[],[],2,fig);
                hh = [hp.hv,hp.hx,hp.hy];

                c1 = get(hp.hlines(1,1),'color');
                c2 = get(hp.hlines(2,1),'color');
                h1 = plotcueline(hh,'x',toi1,'color',c1);
                h2 = plotcueline(hh,'x',toi2,'color',c2);
                legend([h1(1),h2(1)],{'true','est'})

                sname = sprintf('%s/%s_trueInd%g_estInd%g',savepathIndividualEvents,types{iv},ii1,ii2);
                print(sname,'-dpng')
                close(fig)
            catch
                close(fig)
            end
        end
        
        %plot whats left over
        for ii=1
            if ii==1
                this = onlyInTrue;
                info = info1;
                str = 'detec bu human, undeteced by algo';
                savestr = 'true_notEst';
                dat = dat1;
            else
                this = onlyInEst;
                info = info2;
                str = 'detect by algo, undeteced by human';
                savestr = 'est_notTrue';
                dat = dat2;
            end

            for is=this
                fig = figure('visible',figVisible);
                try
                    st = info.StartGazeRow(is);
                    fn = info.EndGazeRow(is);

                    ind = max(1,st-pad):min(fn+pad,numel(class1));
                    toi = [dat(st,3),dat(fn,3)] - dat(ind(1),3);


                    plot_gaze_trace(dat(ind,3)-dat(ind(1),3),dat(ind,1),dat(ind,2),toi,[],[],fig)

                    title(str)

                    sname = sprintf('%s/%s_%s_%g',savepathIndividualEvents,types{iv},savestr,is);
                    print(sname,'-dpng')
                    close(fig)
                catch
                    close(fig)
                end
            end
        end
    end

    
    foo=1;
end


