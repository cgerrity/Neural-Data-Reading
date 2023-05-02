function [SacStructOut] = HcTask_SaccadeProcessing_mg3(eyeData, fsample, doPlot,PreSmoothed,trialIndices,Vel,Acc)
%A structure with the eye-position data is input, and a structure with all of
%the saccades extracted is output. 
%
%to plot the example, go to calcEndPoints.m, and change p to 1
%
% SacStructInput = [xdegrees,ydegrees,time]

%checks
if nargin < 3
    doPlot = 0;
end
if nargin < 4
    PreSmoothed = 0;
end
if nargin <5
    trialIndices = [1,size(eyeData,1)];
end
if nargin > 5 && ~isempty(Vel) && ~isempty(Acc)
    calcVelAcc = 0;
else
    calcVelAcc = 1;
end

fprintf('\n\n\tCLASSIFYING GAZE DATA\n')

saccade =  zeros(length(eyeData),1);
pso = zeros(length(eyeData),1);
fixation = zeros(length(eyeData),1);
smoothPursuit = zeros(length(eyeData),1);

%number of samples to exceed to count as a saccade (10ms)
%durationThresh = 4;
lambdaAcc = 6; %paper and ben used 6
tMinInterSac = ceil(0.02*fsample); % Ben used 20points at 500 Hz??? ie 40ms
durationThresh = ceil(0.01*fsample); %Ben used 4 poins at 500 Hz==8ms ms, paper said 6 ms
sacPadEnd = ceil(0.04*fsample); %i think hes padding saccades to calculate PSOs?
%sacPadStart = ceil(0.006*fsample); 
sacPadStart = max(4,ceil(0.006*fsample)); %cant have only 1-2 samples, calcEndpoint tends to fail

%the cells to hold the processed data before putting it into the array
TotalStartTime = NaN(1000,1);
TotalEndTime = NaN(1000,1);
TotalPeakTime = NaN(1000,1);
TotalPeakVelocity = NaN(1000,1);
StartPointX  = NaN(1000,1);
StartPointY = NaN(1000,1);
EndPointX  = NaN(1000,1);
EndPointY  = NaN(1000,1);
Amplitude  = NaN(1000,1);
Duration  = NaN(1000,1);
Direction  = NaN(1000,1);
PSOEndTotal = NaN(1000,1);
%the window for smoothing
% if 0 && fsample<250; wind = 10*[ -1 -1 0 1 1];
% else wind = 20*[-1 -1 -1 -1 0 1 1 1 1];
% end

wind = 20*[-1 -1 -1 -1 0 1 1 1 1];
%wind = (fsample/6)*[-1 -1 0 1 1]; %Engbert et al 2006, 2003
%wind = (fsample/10)*[-1 -1 -1 -1 0 1 1 1 1];
%wind = 1/(10/fsample) * [-1 -1 -1 -1 0 1 1 1 1];
%wind = [-1 0 1]/2;

wind = fliplr(wind);

%Tsac keeps track of the total saccades
Tsac = 0;
saccadesExist = 1;
EyeDataCopy = eyeData;

t = eyeData(:,3);

% % %added dilation data, so delete it here to work with the rest of the script
% % if size(eyeData,2)==4
% %     dil = eyeData(:,4);
% %     eyeData(:,4) = [];
% % else
% %     dil = nan(size(eyeData(:,4)));
% % end


while saccadesExist ==1
    %% Calculate the velocity Threshold
    %the position has already been smoothed, so just calculate the velocity
    %by the difference of the two vectors
    
    %Calculate the Velocity and the Acceleration for the trial
    if calcVelAcc
        if PreSmoothed
            Vel = [0 0; diff(eyeData(:,1:2))] ./...
                [0 0; diff(eyeData (:,3)), diff(eyeData(:,3)) ];
        else
            %Vel = abs( [conv(eyeData(:,1),wind,'same'),conv(eyeData(:,2),wind,'same')] );
            Vel = [conv(eyeData(:,1),wind,'same'),conv(eyeData(:,2),wind,'same')];
        end
        Acc = abs([conv(Vel(:,1),wind,'same'),conv(Vel(:,2),wind,'same')]);
        %Acc = [conv(Vel(:,1),wind,'same'),conv(Vel(:,2),wind,'same')];
    end
   
    %Calculate the threshold iteratively, taken from Larsson, L., Nystrom,
    %     M., & Stridh, M. (2013). Detection of saccades and postsaccadic
    %     oscillations in the presence of smooth pursuit. IEEE Transactions on
    %     Biomedical Engineering, 60(9), 2484?2493.
    %     http://doi.org/10.1109/TBME.2013.2258918
    
    %   goes through and gets the mean of all the points below the threshold,
    %   calculates a new threshold based on the new mean + 6* the standard
    %   deviation, and then iterates again.
    
    %initialize the values for the differences between iterations of the
    %threshold calculator, and an initial Peak Threshold value
    %BV: add ability to specify trial indices to allow adaptive threshold
    
    %take the absolute
    Acc = abs(Acc);
    
    %thresh calc
    AccThresh = nan(size(eyeData,1),2);
    AccStd = [];
    for it=1:size(trialIndices,1)
        st = trialIndices(it,1);
        fn = trialIndices(it,2);
        
        tmpAcc = Acc(st:fn,:);
        AccStd(it,:) = nanstd(tmpAcc);
        
        Threshdiff = [3,3];
        PeakThresh = [10000,10000];
        %PeakThresh = [50000,50000];
        for var = 1:2
            %subtract the mean, and then calc threshold
%             tmp = Acc(st:fn,var);
%             Acc(st:fn,var) = tmp - nanmean(tmp);
%             AccThresh(st:fn,var) = nanstd(tmp) * lambdaAcc;
            
            pp = [];
            while Threshdiff(var)>1
                tmp = tmpAcc( tmpAcc(:,var) < PeakThresh(var), var );
                %tmp = tmpAcc( abs(tmpAcc(:,var)) < PeakThresh(var), var );
                MeanVel(var) = mean(tmp);
                STD(var) = std(tmp);
                NewThresh = MeanVel(var) + lambdaAcc*STD(var);
                Threshdiff(var) = abs( PeakThresh(var) - NewThresh );
                PeakThresh(var) = NewThresh;
                
                pp(numel(pp)+1,1) = PeakThresh(var);
            end
            
            AccThresh(st:fn,var) = PeakThresh(var);
        end
    end
    
    
    %check some strange periods
%    1.497383299388998   1.497383299502317
%    1.497383300122222   1.497383300292090
%    1.497383303204967   1.497383303275049
%    1.497383311847055   1.497383311960360
%    1.497383327454464   1.497383327501142
    toi = 1.0e+09 * [1.497383300122222   1.497383300292090];
    pad = 0.1;
    itoi = [nearest(t,toi(1) - pad), nearest(t,toi(2) + pad)];

    flag = 1;
    %flag = any(t>toi(1) & t< toi(2));
    if flag
        %PeakThresh = nanmean(Acc) + 3*nanstd(Acc);
        %error('gotta fix peak trhesh')
        
        %recalculate accelerationa and velcoity
        %Calculate the Velocity and the Acceleration for the trial
        if 0
            v = [0 0; diff(eyeData(:,1:2))] ./...
                    [0 0; diff(eyeData (:,3)), diff(eyeData(:,3)) ];
            v2 = [conv(eyeData(:,1),wind,'same'),conv(eyeData(:,2),wind,'same')];
                %Vel2 = [conv(eyeData(:,1),wind,'same'),conv(eyeData(:,2),wind,'same')];
            a = abs( [0 0; diff(v(:,1:2))] ./ [0 0; diff(eyeData(:,3)), diff(eyeData(:,3)) ] );
            a2 = abs([conv(v2(:,1),wind,'same'),conv(v2(:,2),wind,'same')]);
        else
            v = Vel;
            v2 = Vel;
            a = Acc;
            a2 = Acc;
        end

        ind = itoi(1):itoi(2);
        figure; nr = 3; nc = 2; mk = 10; arg = {'.-','markersize',mk}; strs = {'x','y'};
        ipk = find(t >= toi(1), 1);
        for ii=1:2
            ns = ii;
            subplot(nr,nc,ns); plot(t(ind),a(ind,ii),arg{:}); hold all; plot(t(ind),a2(ind,ii),arg{:});  title('acc')
            %plotcueline('yaxis',PeakThresh(ii))
            plotcueline('yaxis',AccThresh(ipk,ii))
            legend({'num diff','diff smooth'});
            subplot(nr,nc,ns+nc); plot(t(ind),v(ind,ii),arg{:}); hold all; plot(t(ind),v2(ind,ii),arg{:}); title('v')
            subplot(nr,nc,ns+2*nc); plot(t(ind),eyeData(ind,ii),arg{:}); title(strs{ii})
            plotcueline([],'xaxis',toi)
        end
        
        
    end
    
    
    %OnsetThresh = MeanVel+(3*STD);
    %define the portions that are above the threshold for each component
    %isSac = Acc(:,1)>PeakThresh(1) | Acc(:,2)>PeakThresh(2);
    isSac = abs(Acc(:,1)) > AccThresh(:,1) | abs(Acc(:,2)) > AccThresh(:,2);
    if isempty(isSac)
        saccadesExist = 0;
        continue
    end
    if diff(isSac(1:2))==-1 || isSac(1)==1
        %NonSacStart is all the points where isSac changes from 1 to 0, but
        %we have to check that it doesn't do this at the beginning
        NonSacStart = find(diff(isSac)==-1);
    else     NonSacStart = [1;find(diff(isSac)==-1)];
    end
    %NonSacEnd is at the points where a sacade starts, so where isSac
    %starts to go to 1
    NonSacEnd = [find(diff(isSac)==1);length(isSac)];
    %make a matrix and find the length of the subthreshold periods
    if isempty(NonSacStart)||isempty(NonSacEnd)
        saccadesExist = 0;
        continue
    end
    d = [NonSacStart NonSacEnd(1:length(NonSacStart))];
    d(:,3) = diff(d,1,2);
    %if the span of sub threshold is too short, remove the start and end points
    tooShort = find(d(:,3) <= tMinInterSac);
    NonSacStart(tooShort) = [];
    NonSacEnd(tooShort) = [];
    
    d2 = [NonSacStart NonSacEnd(1:length(NonSacStart))];
    d2(:,3) = diff(d2,1,2);
    
    %now to hiccups, where there isn't actually a saccade, because
    %it is too short
    if isempty(NonSacStart(2:end))||isempty(NonSacEnd(1:length(NonSacStart)-1))
        saccadesExist = 0;
        continue
    end
    e = [NonSacEnd(1:length(NonSacStart)-1) NonSacStart(2:end)];
    e(:,3) = diff(e,1,2);
    %get the times that are longer than minimum saccade duration
    SaccadeTimes = find(e(:,3)>durationThresh);
    if isempty(SaccadeTimes)
        saccadesExist = 0;
        continue
    end
    %use these as the start and end of the bad data
    %check that there is some room for the padding, remove saccades that
    %start too early, they canont be properly analyzed
    

    st = 1;
    fn = numel(SaccadeTimes);
    if e(SaccadeTimes(1),1) < sacPadStart + 1%<5
        st = 2;
    end
    if e(SaccadeTimes(end),2) + sacPadEnd>length(eyeData)
        fn = fn-1;
    end
    
    SacStart = (e(SaccadeTimes(st:fn),1)) - sacPadStart;
    SacEnd = (e(SaccadeTimes(st:fn),2)) + sacPadEnd;


    %{ 
    if e(SaccadeTimes(1),1) < sacPadStart + 1%e(SaccadeTimes(1),1)<5
        %check that the saccade doesn't end late and have to be removed as
        %well
        if e(SaccadeTimes(end),2) + sacPadEnd>length(SacStructInput)
            SacEnd = [e(SaccadeTimes(2:end-1),2)] + sacPadEnd;
            SacStart = [e(SaccadeTimes(2:end-1),1)] - sacPadStart;
        else SacEnd = e(SaccadeTimes(2:end),2) + sacPadEnd;
            SacStart = [e(SaccadeTimes(2:end),1)] - sacPadStart;
        end
        %if the start doesn't need to be modified, still check the end
    else
        if e(SaccadeTimes(end),2) + sacPadEnd>length(SacStructInput)
            SacEnd = [e(SaccadeTimes(1:end-1),2)] + sacPadEnd;
            SacStart = e(SaccadeTimes(1:end-1),1) - sacPadStart;
            
        else SacEnd = e(SaccadeTimes,2) + sacPadEnd;
            SacStart = e(SaccadeTimes,1) - sacPadStart;
        end
    end
    %}
  
    %initialize variables
    StartPoint = NaN(length(SacStart),1);
    EndPoint = NaN(length(SacStart),1);
    Peak = NaN(length(SacStart),1);
    PeakTime =  NaN(length(SacStart),1);
    %actual saccade counter
    saccadeCount = 0;
    %go through all of the  possible saccade periods
    
    workedSac = [];
    for stamp = 1:length(SacStart);
        
        %make sure there aren't any NaNs in the sample, and if not,
        %increase the saccade counter by one, and calculate the pertinent
        %Points
        
%         sacoi = [434.282716000000;461.315716000000;594.721716000000;663.584716000000;1277.78171600000;1571.87571600000;1581.70371600000;1582.89771600000;1650.99371600000;1840.91371600000;1841.00271600000;2088.32471600000;2111.60971600000;2154.56171600000;2156.65271600000;2196.17871600000;2201.84371600000;2319.78571600000;2347.15071600000;2389.32471600000;2402.56071600000;2425.85671600000;2427.80471600000;2430.79171600000;2446.46671600000;2446.53971600000;2468.21371600000;2468.28171600000;2584.54871600000;2831.21471600000;2887.38271600000;3084.36271600000;3086.13671600000];
%         toi = [t(SacStart(stamp)), t(SacEnd(stamp))];
%         plotFlag = any(sacoi>=toi(1) & sacoi<=toi(2));
%         if plotFlag
%             xxx=1;
%         end
        plotFlag = 0;
        
        
        if ~any( sum( isnan( eyeData(SacStart(stamp):SacEnd(stamp),1:3) )))
            saccadeCount = saccadeCount+1;
            %saccadeCount = stamp;
            [StartPoint(saccadeCount),EndPoint(saccadeCount),Peak(saccadeCount),...
                PeakTime(saccadeCount)] = calcEndPoints_mg( eyeData(SacStart(stamp):SacEnd(stamp),:), fsample, plotFlag );
            workedSac(saccadeCount) = stamp;
            
        end
    end
    %remove any NaN from bad eye samples
    toremove = (isnan(StartPoint)|isnan(EndPoint)|isnan(Peak));
    RemovedStart = StartPoint(toremove);
    RemovedEndPoint = EndPoint(toremove);
    StartPoint(toremove) = [];
    EndPoint(toremove) = [];
    Peak(toremove) = [];
    PeakTime(toremove) = [];
    PSOEndTotal = NaN(length(StartPoint),1);
    
    %% Cycle through Saccades
    reverseStr = '';
    for sac = 1:length(StartPoint)

        if EndPoint(sac)-StartPoint(sac) < 0.02
            xxx=1;
        end
        
        %print percentage of processing
        percentDone = 100 * sac / length(StartPoint);
        msg = sprintf('\tFinding saccades and PSOs, %3.1f percent finished.', percentDone); 
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        Tsac = Tsac+1;
        TotalStartTime(Tsac) = StartPoint(sac);
        TotalEndTime(Tsac) = EndPoint(sac);
        TotalPeakTime(Tsac) = PeakTime(sac);
        TotalPeakVelocity(Tsac) = Peak(sac);
        StartPointX(Tsac) = eyeData(eyeData(:,3)==StartPoint(sac),1);
        StartPointY(Tsac) = eyeData(eyeData(:,3)==StartPoint(sac),2);
        EndPointX(Tsac) = eyeData(eyeData(:,3)==EndPoint(sac),1);
        EndPointY(Tsac) = eyeData(eyeData(:,3)==EndPoint(sac),2);
        Amplitude(Tsac) = sqrt((StartPointX(Tsac)-EndPointX(Tsac)).^2 + ...
            (StartPointY(Tsac)-EndPointY(Tsac)).^2);
        Duration(Tsac) = EndPoint(sac)-StartPoint(sac);
        Direction(Tsac) = atan2d((EndPointY(Tsac)-StartPointY(Tsac)),...
            (EndPointX(Tsac)-StartPointX(Tsac)));
        %test for PSO's
        %CheckX
        % if the saccade is the last saccade, see if you need to use the
        % end of the trial as then end of this calculation
        pso_offset = ceil(38/500*fsample); % what Ben used at 500hz rate
        if sac+1>length(StartPoint)
            calcLength = min(find(eyeData(:,3)==EndPoint(sac))+pso_offset,length(eyeData));
        else
            calcLength = min([find(eyeData(:,3)==EndPoint(sac))+pso_offset,...
                find(eyeData(:,3)==StartPoint(sac+1))-1]);
        end
        
        min_offset = ceil(10/500*fsample);
        if calcLength >min_offset && [calcLength - find(eyeData(:,3)==EndPoint(sac))]>min_offset
            PPSOX = eyeData(find(eyeData(:,3)==EndPoint(sac)):...
                calcLength,1:2:3);
            
            [PSOEndX,Rend] = PSOCalc_mg(PPSOX,fsample);
            %CheckY
            PPSOY = eyeData(find(eyeData(:,3)==EndPoint(sac)):...
                calcLength,2:3);
            
            [PSOEndY, REnd] = PSOCalc_mg(PPSOY,fsample);
            PSOEndTotal(sac) = max(PSOEndX,PSOEndY);
            
        end
        %define points where the signal is a saccade
        saccade(eyeData(:,3)>=StartPoint(sac)&eyeData(:,3)<=EndPoint(sac)) = 1;
        %define points where the signal is a PSO. add some time to makesure
        % saccade end isnt included in the PSO
        pso(eyeData(:,3)>=(EndPoint(sac)+1/fsample*0.5)&eyeData(:,3)<=PSOEndTotal(sac)) = 1;
        % nan all the defined points so that only the foveations are left
        % for further processing
        eyeData(eyeData(:,3)>=StartPoint(sac)&...
            eyeData(:,3)<=PSOEndTotal(sac),1:2) = NaN;
        %     figure
        
                
        if EndPoint(sac)-StartPoint(sac) < 0.02
            xxx=1;
        end
    end
    
    saccadesExist = 2;
end
fprintf('\n');
TotalStartTime(isnan(TotalStartTime)) = [];
TotalEndTime(isnan(TotalEndTime)) = [];
TotalPeakTime(isnan(TotalPeakTime)) = [];
TotalPeakVelocity(isnan(TotalPeakVelocity)) = [];
StartPointX(isnan(StartPointX)) = [];
StartPointY(isnan(StartPointY)) = [];
EndPointX(isnan(EndPointX)) = [];
EndPointY(isnan(EndPointY)) = [];
Amplitude(isnan(Amplitude)) = [];
Duration(isnan(Duration)) = [];
Direction(isnan(Direction)) = [];
PSOEndTotal(isnan(PSOEndTotal)) = [];
StartGazeRow = find(ismember(eyeData(:,3),TotalStartTime));
EndGazeRow = find(ismember(eyeData(:,3),TotalEndTime));

%store saccade info
saccadeInfo = struct('StartTime',TotalStartTime,'EndTime',TotalEndTime,...
    'StartGazeRow',StartGazeRow,'EndGazeRow',EndGazeRow,...
    'PeakTime',TotalPeakTime,'PeakVelocity',TotalPeakVelocity,'Duration',...
    Duration,'Amplitude',Amplitude,'StartPointX',StartPointX,'EndPointX',...
    EndPointX,'StartPointY',StartPointY,'EndPointY',EndPointY,...
    'Direction',Direction,'PostSaccadicOscillationEnd',PSOEndTotal);



fixClassifications = FixVsSPAnalysis_mg(eyeData,fsample);

% %add dilation data in here
% if size(eyeData,2)==3
%     eyeData = cat(2,eyeData,dil);
% end
    
fixation(fixClassifications==1) = 1;
smoothPursuit(fixClassifications==2) = 1;
fixInfo = get_fixation_smoothPursuit_info(eyeData,fixation==1, fsample);
smInfo = get_fixation_smoothPursuit_info(eyeData,smoothPursuit==1,fsample);
unclassified = isnan(EyeDataCopy(:,1));

unclassified = ~(smoothPursuit | fixation| pso | saccade | unclassified);

% d1 = [fixInfo.EndTime] - [fixInfo.StartTime];
% d2 = [smInfo.EndTime] - [smInfo.StartTime];
% figure; 
% subplot(1,2,1); hist(d1,100)
% subplot(1,2,2); hist(d2,100)

fprintf('\n\t%g saccades identified, %g gaze samples in total (%.3g).', length(saccadeInfo.StartTime), sum(saccade), sum(saccade)/length(EyeDataCopy));
fprintf('\n\t%g PSO gaze samples (%.3g).', sum(pso), sum(pso)/length(EyeDataCopy));
fprintf('\n\t%g fixations identified, %g gaze samples in total (%.3g).', length(fixInfo.StartTime), sum(fixation), sum(fixation)/length(EyeDataCopy));
fprintf('\n\t%g smooth pursuits identified, %g gaze samples in total (%.3g).', length(smInfo.StartTime), sum(smoothPursuit), sum(smoothPursuit)/length(EyeDataCopy));
fprintf('\n\t%g unclassifiable gaze samples (%.3g).', sum(unclassified), sum(unclassified)/length(EyeDataCopy));

%% Output
SacStructOut = struct('SaccadeInfo',saccadeInfo,...
    'FixationInfo',fixInfo,'SmoothPursuitInfo',smInfo,...
    'Saccade',logical(saccade),'PSO',logical(pso),...
    'Fixation',logical(fixation),'SmoothPursuit',logical(smoothPursuit),...
    'Unclassified',logical(unclassified),...
    'Time',t,'TrialIndices',trialIndices);

%% figures
if doPlot
    
    EyeDataCopy(:,3) = EyeDataCopy(:,3) - EyeDataCopy(1,3);
    
    figure('Position',[0,400,1600,800])
    subplot(2,1,1)
    hold on
    bigdata = [EyeDataCopy(saccade,3),EyeDataCopy(saccade,1),ones(length(EyeDataCopy(saccade)),1);...
        EyeDataCopy(pso,3),EyeDataCopy(pso,1),ones(length(EyeDataCopy(pso)),1).*4;...
        EyeDataCopy(fixation,3),EyeDataCopy(fixation,1),ones(length(EyeDataCopy(fixation,1)),1).*2;...
        EyeDataCopy(smoothPursuit,3),EyeDataCopy(smoothPursuit,1),ones(length(EyeDataCopy(smoothPursuit)),1).*3;...
            ];
    gscatter(bigdata(:,1),bigdata(:,2),bigdata(:,3),'grbm','oooo',[5,5,5,5])
    plot(EyeDataCopy(:,3),EyeDataCopy(:,1),'k','LineWidth',1)
    hold all
    
    y = (max(EyeDataCopy(:,1)) + 5) * ones(size(EyeDataCopy(:,3)));
    y(~unclassified) = nan;
    plot(EyeDataCopy(:,3),y,'ko','markersize',5)
    
    %    
    legend({'Saccade','Fixation', 'Smooth Pusuit','Post-saccadic Osscilation'    })
    ylabel('Degrees visual angle X')
    bigfig = gca;
    trialLength = EyeDataCopy(end)-EyeDataCopy(1,3);
    quarters = round(length(EyeDataCopy(:,3))/4);
%     bigfig.XTick = [EyeDataCopy(1,3) EyeDataCopy(quarters,3) ...
%         EyeDataCopy((2*quarters),3) EyeDataCopy(3*quarters,3) EyeDataCopy(end,3)];
%     bigfig.XTickLabel= {'0', num2str(length(EyeDataCopy(:,1))/2) num2str(length(EyeDataCopy(:,1))) ...
%         num2str(length(EyeDataCopy(:,1))*1.5) num2str(length(EyeDataCopy(:,1))*2)};
    %bigfig.YLim = [-20 20];
    xlims = bigfig.XLim;
    subplot(2,1,2)
    hold on
    scatter(EyeDataCopy(saccade,3),EyeDataCopy(saccade,2),20,'go','LineWidth',2)
    scatter(EyeDataCopy(fixation,3),EyeDataCopy(fixation,2),20,'ro')
    scatter(EyeDataCopy(smoothPursuit,3),EyeDataCopy(smoothPursuit,2),20,'bo')
    scatter(EyeDataCopy(pso,3),EyeDataCopy(pso,2),20,'mo')
    plot(EyeDataCopy(:,3),EyeDataCopy(:,2),'k','LineWidth',1)
    hold all
    plot(EyeDataCopy(:,3),y,'ko','markersize',5)

    y = (max(EyeDataCopy(:,2)) + 5) * ones(size(EyeDataCopy(:,3)));
    y(~unclassified) = nan;
    plot(EyeDataCopy(:,3),y,'ko','markersize',5)
    
    % legend({'Fixation', 'Smooth Pusuit','Post-saccadic Osscilation',...
    %             'Saccade'})
    xlabel('Time (ms)')
    ylabel('Degrees visual angle Y')
    bigfig = gca;
    trialLength = EyeDataCopy(end)-EyeDataCopy(1,3);
    quarters = round(length(EyeDataCopy(:,3))/4);
%     bigfig.XTick = [EyeDataCopy(1,3) EyeDataCopy(quarters,3) ...
%         EyeDataCopy((2*quarters),3) EyeDataCopy(3*quarters,3) EyeDataCopy(end,3)];
%     bigfig.XTickLabel= {'0', num2str(length(EyeDataCopy(:,1))/2) num2str(length(EyeDataCopy(:,1))) ...
%         num2str(length(EyeDataCopy(:,1))*1.5) num2str(length(EyeDataCopy(:,1))*2)};
    %bigfig.YLim = [-15 15];
    bigfig.XLim = xlims;

end


end