
%settings
path = '/Users/ben/Desktop/prepare_test_datasets2_split';
cd(path)
copypath = '/Volumes/DATA_65/Data-postReplay_copy';

reclassify = 0;
gazeArgs = 'tx300';
[screenX,screenY,fsample] = get_experiment_parameters('tx300');

% reclassify, but dont over-write manual classification
targ = {'_milad','_marcus'};
if reclassify
    skipped = cell(numel(targ),1);

    track_bady = {};
    track_diffPreproc = {};
    ity = 0;
    itp = 0;
    
    
    for it=1:numel(targ)
        disp(['**********  ' targ{it} '  **********'])
        files = dir([path '/' targ{it} '/MonkeyGame*']);
        for id=1:numel(files)

%             if it==1 && id <4
%                 continue
%             end
            %load in the files
            name = files(id).name;
            disp(name)
            fullpath1 = [path '/' targ{it} '/' name];
            in1 = load(fullpath1);
            
            if ~isfield(in1,subjectData_orig)
                in1.subjectData_orig = in1.subjectData;
            end
            
            
            %check that manual classification exists....
            str = 'ManualClassification';
            if ~any( strncmp(in1.subjectData.ProcessedEyeData.GazeData.Properties.VariableNames,str,numel(str)) )
                warning('** NO manual classification: %s, %s',targ{it},name)
                nskip = numel(skipped{it})+1;
                skipped{it} = [skipped{it}, id];
                continue
            end
            
            %load in the new stuff
            fullpath2 = [copypath '/' name(1:end-23) '/ProcessedData/' name];
            in2 = load(fullpath2);

                   
            % downsample the new data, 
            disp('downsampling...')
            subjectData = in2.subjectData;
            t = subjectData.ProcessedEyeData.GazeData.EyetrackerTimestamp * 10^-6;
            toi = in1.subjectData.toi_downsample;
            selt = t >=toi(1) & t <= toi(2);
            subjectData.ProcessedEyeData.GazeData(~selt,:) = [];
            subjectData.ProcessedEyeData.EyeEvents.Saccade(~selt) = [];
            subjectData.ProcessedEyeData.EyeEvents.PSO(~selt) = [];
            subjectData.ProcessedEyeData.EyeEvents.Fixation(~selt) = [];
            subjectData.ProcessedEyeData.EyeEvents.SmoothPursuit(~selt) = [];
            subjectData.ProcessedEyeData.EyeEvents.Unclassified(~selt) = [];
            subjectData.ProcessedEyeData.EyeEvents.Time(~selt) = [];
            
            types = {'Fixation','Saccade','SmoothPursuit'};
            for itype=1:numel(types)
                dat = subjectData.ProcessedEyeData.EyeEvents.([types{itype} 'Info']);
                st = dat.StartTime;
                fn = dat.EndTime;
                sel = st>=toi(1) & fn <= toi(2);
                
                ff = fields(dat);
                for ii=1:numel(ff)
                   try
                       dat.(fields{ii})(~sel) = [];
                   end
                end
                
                subjectData.ProcessedEyeData.EyeEvents.([types{itype} 'Info']) = dat;
            end
            
            
            %check the -1*y problem
            tmpy = in1.subjectData.ProcessedEyeData.GazeData.YSmooth;
            if any(tmpy<0)
                warning('YSmooth has -1 probklem')
                in1.subjectData.ProcessedEyeData.GazeData.YSmooth = -1 * in1.subjectData.ProcessedEyeData.GazeData.YSmooth;
                ity = ity+1;
                track_bady(ity,:) = {targ{it},name};
                foo=1;
            end
            
            %check preproc differences
            disp('checking for prepproc differences...')
            a1 = isnan(in1.subjectData.ProcessedEyeData.GazeData.YSmooth);
            a2 = isnan(subjectData.ProcessedEyeData.GazeData.YSmooth);
            itp = itp+1;
            track_diffPreproc(itp,:) = {targ{it},name,...
                [sum(a1)./numel(a1), sum(a2) ./ numel(a2), sum(a1~=a2)./numel(a1)]};
            
            %add manual classification
            manclass = in1.subjectData.ProcessedEyeData.GazeData.ManualClassification;
            subjectData.ProcessedEyeData.GazeData.ManualClassification = manclass;
            subjectData.toi_downsample = in1.subjectData.toi_downsample;
            subjectData.warning = in1.subjectData.warning;
            
            %re-save
            disp('saving...')
            subjectData_orig = in1.subjectData_orig;
            save(fullpath1,'subjectData','subjectData_orig')

        end
    end
end

%% ====================================================================
% average agreement between algo and human
%% ====================================================================

label = {'sac','pso','fix','sm','uncl','wierd'};
trackerType = 'tx300';

plotSampleConfusionMatrix = 1;
plotEventSummary = 1;
plotIndividualEventComparison = 1;

savepath = [path '/_fig2'];
if ~exist(savepath); mkdir(savepath); end

targ = {'_milad','_marcus'};

if 0
    disp('==================================================================')
    disp('average performance')
    disp('==================================================================')


    if 1
        iout = 0;
        out_all = [];
        out_event_all = [];
        for it=1:numel(targ)
            disp(['**********  ' targ{it} '  **********'])
            files = dir([path '/' targ{it} '/MonkeyGame*']);
            for id=1:numel(files)

    %             %skip these
    %             if ismember(id,skipped{it})
    %                 continue
    %             end

                 %load in the files
                name = files(id).name;
                disp(name)
                fullpath1 = [path '/' targ{it} '/' name];
                in1 = load(fullpath1);


                str = 'ManualClassification';
                if ~any( strncmp(in1.subjectData.ProcessedEyeData.GazeData.Properties.VariableNames,str,numel(str)) )
                    continue
                end

                %extract
                dat = in1.subjectData.ProcessedEyeData;
                gaze_new = dat.GazeData;
                gaze_orig = in1.subjectData_orig.ProcessedEyeData.GazeData;
                manclass = gaze_new.ManualClassification;
                aclass = gaze_new.Classification;

                %results
                iout = iout+1;
                out = compare_classification(manclass,aclass,1:4,plotSampleConfusionMatrix,label);
                if iout==1
                    out_all = out;
                else
                    out_all(iout) = out;
                end

                %clen the figure, and save it
                if plotSampleConfusionMatrix
                    str = get(gca,'title');
                    str = str.String;
                    str = sprintf('%s\n%s',name(1:end-23),str);
                    title(str)
                    sname = [savepath '/' targ{it} '_' name(1:end-23) '_sampleConfusionMatrix'];
                    print(sname,'-dpng')
                    close(gcf)
                end

                %plot event based agreement
                try
                    if plotIndividualEventComparison
                        savepathSegments = [savepath '/' targ{it} '_' name(1:end-23)];
                    else
                        savepathSegments = '';
                    end

                    event_map = {1 3 4;'Saccade','Fixation','SmoothPursuit'};
                    [xdeg1,ydeg1] = acds2dva(gaze_orig.XSmooth,gaze_orig.YSmooth,gaze_orig.Distance,screenX,screenY);
                    [xdeg2,ydeg2] = acds2dva(gaze_new.XSmooth,gaze_new.YSmooth,gaze_new.Distance,screenX,screenY);
                    dat1 = [xdeg1,ydeg1,gaze_orig.EyetrackerTimestamp*10^-6];
                    dat2 = [xdeg2,ydeg2,gaze_new.EyetrackerTimestamp*10^-6];

                    class1 = gaze_new.ManualClassification;
                    class2 = gaze_new.Classification;
                    out_event = compare_classification_eventBased(dat1,class1,dat2,class2,event_map,plotEventSummary,savepathSegments);

                    if iout==1;
                        out_event_all = out_event;
                    else
                        out_event_all(iout) = out_event;
                    end

                    if plotEventSummary
                        sname = [savepath '/' targ{it} '_' name(1:end-23) '_eventBasedSummary'];
                        print(sname,'-dpng')
                        close(gcf)
                    end
                end
            end
        end
    end

    %plot average event-based results
    mu = [];
    se = [];
    labels = {'Saccade','Fixation','SmoothPursuit'};
    for iv=1:3
        tmp = [out_event_all.(labels{iv})];
        tmp = [tmp.sensitivity];
        mu(iv) = mean(tmp);
        se(iv) = nanstd(tmp)./sqrt(numel(tmp));
    end
    
    figure
    barwitherr(se,mu)
    set(gca,'xticklabel',labels)
    ylabel('mean sensitivity')
    title('mean sensitivity ( =tp/(tp+fn)')
    set_bigfig(gcf,[0.5 0.5])
    
    sname = [savepath '/average_eventBased_agreement'];
    save2pdf(sname,gcf)
    
    
    %plot average sample-based results
    strs = {'sensitivity','specificity','accuracy','ppv','npv'};
    labels = out.label(1:4);

    figure
    nr = 2; nc = 3; ns = 0;
    for is=1:numel(strs)
        tmp = [out_all(:).(strs{is})];
        n = size(tmp,2);

        mu = nanmean(tmp,2);            
        se = nanstd(tmp,[],2) ./ sqrt(n);            

        ns = ns+1;
        subplot(nr,nc,ns)
        barwitherr(se,mu)
        ylabel(['mean ' strs{is}])
        title(strs{is})
        set(gca,'xticklabel',labels)
    end
    
    sname = [savepath '/average_agreement_sampleBased'];
    print(sname,'-dpng')
    
    %cohen K summary
    k = [];
    kp = [];
    for ii=1:numel(out_all)
        k(ii) = out_all(ii).cohenk.kappa;
        kp(ii) = out_all(ii).cohenk.p;
    end
    
    
    N = numel(k);
    mu = nanmean(k);
    se = nanstd(k)./sqrt(N);
    prop = sum(kp<0.05) ./ N;
    
    str = sprintf('--------------- cohen Kappa, sample based ---------------\nmu =%.3g+%.3gSE\nn=%g, prop sign=%.3g',...
        mu,se,N,prop);
    disp(str)
    
    
    %-------- event based summary
    % porportion all detected 
    
    
    N = numel(out_event_all);
    sen = [];
    types = {'Saccade','Fixation','SmoothPursuit'};
    for itype=1:numel(types)
        for jj=1:N
            sen(itype,jj) = out_event_all(jj).(types{itype}).sensitivity;
        end
    end
    
    %only consider one rater
    isel = 1:N;
    %isel=6:11; %1:5=milad, 6:11=marcus
    %isel = 1:5;
    
    figure
    nr = 1; nc = numel(types);
    
    for ii=1:numel(types)
       ns = ii;
       subplot(nr,nc,ns)
       tmp = sen(ii,isel);
       mu = nanmean(tmp);
       se = nanstd(tmp)./sqrt(numel(tmp));
       hist(tmp)
       plotcueline('x',mu,'r')
       plotcueline('x',median(tmp),'g')
       str = sprintf('%s,n=%g\nmu=%.3g+%.3gSE\nred=mean,green=median',...
           types{ii},numel(tmp),mu,se);
       title(str)
    end
    
    sname = [savepath '/average_agreement_eventBased_sensitivity'];
    print(sname,'-dpng')
    
    



end

%% ====================================================================
% average agreement between humans
% ====================================================================

if 1
    disp('==================================================================')
    disp('compare humans')
    disp('==================================================================')

    path1 = [path '/' targ{1}];
    path2 = [path '/' targ{2}];
    
    files1 = dir([path1 '/Monkey*']);
    files2 = dir([path2 '/Monkey*']);
    
    overlap = intersect({files1.name},{files2.name});
    
    iout=0;
    out_all_human = [];
    for id=1:numel(overlap)
        name = overlap{id};
        disp(name)
        
        in1 = load([path1 '/' name]);
        in2 = load([path2 '/' name]);
    
        class1 = in1.subjectData.ProcessedEyeData.GazeData.ManualClassification;
        class2 = in2.subjectData.ProcessedEyeData.GazeData.ManualClassification;
        
        %results
        iout = iout+1;
        out = compare_classification(class1,class2,1:4,plotSampleConfusionMatrix,label);
        if iout==1
            out_all_human = out;
        else
            out_all_human(iout) = out;
        end

        %clen the figure, and save it
        if plotSampleConfusionMatrix
            str = get(gca,'title');
            str = str.String;
            str = sprintf('%s\n%s',name(1:end-23),str);
            title(str)
            xlabel(targ{2})
            ylabel(targ{1})
            sname = [savepath '/' targ{1} 'VS' targ{2} '_' name(1:end-23)];
            print(sname,'-dpng')
            close(gcf)
        end
    end
end


%test concordance of old and new algo
if 0
    gaze_new=in1.subjectData_orig.ProcessedEyeData.GazeData;
    gaze_orig=in1.subjectData.ProcessedEyeData.GazeData;
    [xdeg1,ydeg1] = acds2dva(gaze_new.XSmooth,gaze_new.YSmooth,gaze_new.Distance,screenX,screenY);
    [xdeg2,ydeg2] = acds2dva(gaze_orig.XSmooth,gaze_orig.YSmooth,gaze_orig.Distance,screenX,screenY);
    v1=[0;abs(complex(diff(xdeg1),diff(ydeg1)))./diff(t1)];
    v2=[0;abs(complex(diff(xdeg2),diff(ydeg2)))./diff(t2)];
    t1=gaze_new.EyetrackerTimestamp;
    t2=gaze_orig.EyetrackerTimestamp;

    for ii=1:500:8500
        ind = ii:ii+499;
        figure

        subplot(3,1,1)
        plot(t1(ind),v1(ind))
        hold all
        plot(t2(ind),v2(ind))
        title('vel')

        subplot(3,1,2)
        plot(t1(ind),xdeg1(ind))
        hold all
        plot(t2(ind),xdeg2(ind))
        title('x')


        subplot(3,1,3)
        plot(t1(ind),ydeg1(ind))
        hold all
        plot(t2(ind),ydeg2(ind))
        title('vel')

        set_bigfig
        pause
        close(gcf)



    end
end
