function [SacStructOut] = HcTask_SaccadeProcessing_mg5(eyeData, fsample, doPlot,PreSmoothed,trialIndices,Vel,Acc)
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
lambdaAcc = 3; %paper and ben used 6
tMinInterSac = ceil(0.02*fsample); % Ben used 20points at 500 Hz??? ie 40ms
durationThresh = ceil(0.01*fsample); %Ben used 4 poins at 500 Hz==8ms ms, paper said 6 ms
sacPadEnd = ceil(0.04*fsample); %i think hes padding saccades to calculate PSOs?
%sacPadStart = ceil(0.006*fsample); 
sacPadStart = max(8,ceil(0.01*fsample)); %cant have only 1-2 samples, calcEndpoint tends to fail

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
    
    %{
    %make sure we take absolute
    Acc = abs(Acc);
    Vel = abs(Vel);
    
    %calculate both acceleration and velocity threshold
    AccThresh = nan(size(eyeData,1),2);
    VelThresh = AccThresh;
    for it=1:size(trialIndices,1)
        st = trialIndices(it,1);
        fn = trialIndices(it,2);
        
        for ii=1:2
            %acceleration threshold
            tmpa = abs(Acc(st:fn,ii));
            AccThresh(st:fn,ii) = iterativeThreshold(tmpa,10000,1,lambdaAcc);
            
            %velocity
            tmpv = Vel(st:fn,ii);
            VelThresh(st:fn,ii) = iterativeThreshold(tmpv,1000,1,lambdaAcc);
        end
    end
     isSac = abs(Vel) > VelThresh;    
    isSac = any(isSac,2); %combine estimation for x and y
    if ~any(isSac); continue; end
    
    %}
    
%     tmpa = abs( complex(Acc(:,1), Acc(:,1)) );
%     tmpv = abs( complex(Vel(:,1), Vel(:,1)) );
% 
%     AccThresh = nan(size(eyeData,1),1);
%     VelThresh = AccThresh;
%     for it=1:size(trialIndices,1)
%         st = trialIndices(it,1);
%         fn = trialIndices(it,2);
%         
%         %acceleration threshold
%         AccThresh(st:fn,1) = iterativeThreshold(tmpa(st:fn),10000,1,lambdaAcc);
% 
%         %velocity
%         VelThresh(st:fn,1) = iterativeThreshold(tmpv(st:fn),1000,1,lambdaAcc);
%     end
%     
%     isSac = tmpv > VelThresh;


    filtAcc = nan(size(Acc));
    filtAccThresh = filtAcc;
    for ii=1:2
        for it=1:size(trialIndices,1)
            st = trialIndices(it,1);
            fn = trialIndices(it,2);
            a = Acc(st:fn,ii);
            a = a-nanmean(a);
            a(isnan(a)) = 0;

            % get signal parameters for filtering:
            sp=get_signal_parameters(...
                'sampling_rate',fsample,... % sampling rate
                'number_points_time_domain',length(a));

            freq = 1:100; %10:1:70; %10:1:100;
            tmp = nan(numel(freq),numel(a));
            for n=1:numel(freq)
                g = [];
                g.center_frequency = freq(n); % Hz
                g.fractional_bandwidth = 1; %test(n);
                g.chirp_rate=0;
                g=make_chirplet(...
                  'chirplet_structure',g,...
                  'signal_parameters',sp);

                fsignal=gabor_filter(a',sp.sampling_rate,g.center_frequency,g.fractional_bandwidth);
                trace=abs(fsignal);

                tmp(n,:) = trace;
            end

            tmp = sum(tmp);
            filtAcc(st:fn,ii) = tmp;
            filtAccThresh(st:fn,ii) = iterativeThreshold(tmp,max(tmp)*0.8,1,lambdaAcc);
        end
    end
    
    isSac = filtAcc > filtAccThresh;
    isSac = any(isSac,2);
    if ~any(isSac); continue; end
    
    


   
    
    %estimated saccade start and end
    [SacStart,SacEnd] = find_borders(isSac);
    
    % delete saccades at edges
    if SacStart(1)==1
        SacStart(1) = [];
        SacEnd(1) = [];
    end
    if SacEnd(end)==size(eyeData,1)
        SacStart(end) = [];
        SacEnd(end) = [];
    end
    
    %combine saccades that are too close together
    d1 = diff([SacEnd(1:end-1), SacStart(2:end)],[],2);
    tooClose = find(d1 < tMinInterSac);
    SacStart(tooClose+1) = [];
    SacEnd(tooClose) = [];
    if isempty(SacStart) || isempty(SacEnd); continue; end
    
    %delete Saccades that are too short
    d2 = diff([SacStart, SacEnd]);
    tooShort = find( d2 <= durationThresh );
    SacStart(tooShort) = [];
    SacEnd(tooShort) = [];
    if isempty(SacStart) || isempty(SacEnd); continue; end   
    
    %add padding to feed into calcEndpoints
    SacStart = SacStart - sacPadStart;
    SacEnd = SacEnd + sacPadEnd;
        
    
     %check what we found
    if 0
        for is=1:size(SacStart,1)
            ind=SacStart(is):SacEnd(is);
            toi = []; %[t(ind(1)), t(ind(end))];
            hax = plot_gaze_derivatives(t(ind)-t(ind(1)),eyeData(ind,1:2),abs(Vel(ind,:)),abs(Acc(ind,:)),toi,{'x','y'});
            for ii=1:2
                plotcueline(hax(2,ii),'y',VelThresh(ind(2),ii));
                plotcueline(hax(3,ii),'y',AccThresh(ind(2),ii));
            end
            set_bigfig(gcf,[0.7 0.7])
            pause
            close gcf
        end
    end
    
    %double check that we didnt accidently overlow
    if SacStart(1)<1
        SacStart(1) = [];
        SacEnd(1) = [];
    end
    if SacEnd(end)>size(eyeData,1)
        SacStart(end) = [];
        SacEnd(end) = [];
    end
    
    fred=1;
  
    

    %check some strange periods
%     1.497383342128957   1.497383342412245
%    1.497383423219547   1.497383423329533
%    1.497383432414669   1.497383432764713
%    1.497383464939551   1.497383465086199

    toi = 1.0e+09 * [1.498593572051181   1.498593572077835];
    pad = 0.1;
    itoi = [nearest(t,toi(1) - pad), nearest(t,toi(2) + pad)];

    flag = 0;
    %flag = any(t>toi(1) & t< toi(2));
    if flag
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
            v = abs(Vel);
            v2 = abs(Vel);
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
            plotcueline('yaxis',VelThresh(ipk,ii))
            subplot(nr,nc,ns+2*nc); plot(t(ind),eyeData(ind,ii),arg{:}); title(strs{ii})
            plotcueline([],'xaxis',toi)
        end
    end
    
    
  
    

    %% initialize variables
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
    end
    
%     %nan anywhere where velocity/acceleration crossed the threshold...
%     %these are probably saccades we missed
%     vbad = abs(Vel) > VelThresh;
%     abad = abs(Acc) > AccThresh;
    
    

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


%classify fixations
fixClassifications = FixVsSPAnalysis_mg(eyeData,fsample,Vel);

% %add dilation data in here
% if size(eyeData,2)==3
%     eyeData = cat(2,eyeData,dil);
% end
    
fixation(fixClassifications==1) = 1;
smoothPursuit(fixClassifications==2) = 1;
fixInfo = get_fixation_smoothPursuit_info(eyeData,fixation==1, fsample);
smInfo = get_fixation_smoothPursuit_info(eyeData,smoothPursuit==1,fsample);
% unclassified = isnan(EyeDataCopy(:,1));
unclassified = ~(smoothPursuit | fixation| pso | saccade);

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