function [SacStructOut] = HcTask_SaccadeProcessing(SacStructInput,PreSmoothed)
%A structure with the eye-position data is input, and a structure with all of
%the saccades extracted is output. PreSmoothed allows you to output from
%the smoothed or unsmoothed data
%to plot the example, go to calcEndPoints.m, and change p to 1
%     SacStructInput =BigStruct.(Types{sessionType}).Trials.(trialIDs{trl}).PositionMatrix_deg2(:,4:6)
%   SacStructInput = XMazeStruct.Trials.
%   SacStructInput=BigStruct.(Types{sessionType}).Trials.(trialIDs{trl}).EyeDegrees
%    SacStructInput=BigStruct.(Types{sessionType}).Trials.(trialIDs{trl}).NonSmoothedEyes

%number of samples to exceed to count as a saccade (10ms)
durationThresh = 4;

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
wind = 20*[ -1 -1 -1 -1 0 1 1 1 1];
%Tsac keeps track of the total saccades
Tsac = 0;
saccadesExist = 1;
red = zeros(length(SacStructInput),1);
blue = zeros(length(SacStructInput),1);
green =  zeros(length(SacStructInput),1);
magenta = zeros(length(SacStructInput),1);
EyeDataCopy = SacStructInput;
while saccadesExist ==1
    %% Calculate the velocity Threshold
    %the position has already been smoothed, so just calculate the velocity
    %by the difference of the two vectors
    
    %Calculate the Velocity and the Acceleration for the trial
    if PreSmoothed ==1
        Vel = diff(SacStructInput(:,1:2))./...
            [diff(SacStructInput (:,3)),diff(SacStructInput(:,3))];
    else
        Vel = abs([conv(SacStructInput(:,1),wind,'same'),conv(SacStructInput(:,2),wind,'same')]);
    end
    Acc = abs([conv(Vel(:,1),wind,'same'),conv(Vel(:,2),wind,'same')]);
    
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
    Threshdiff = [3,3];
    PeakThresh = [10000,10000];
    for var = 1:2
        
        while Threshdiff(var)>1
            MeanVel(var) = mean(Acc(Acc(:,var)<PeakThresh(var),var));
            STD(var) = std(Acc(Acc(:,var)<PeakThresh(var),var));
            NewThresh = MeanVel(var)+(6*STD(var));
            Threshdiff(var) = PeakThresh(var)-NewThresh;
            PeakThresh(var) = NewThresh;
            
        end
        
    end
    
    %OnsetThresh = MeanVel+(3*STD);
    %define the portions that are above the threshold for each component
    isSac = Acc(:,1)>PeakThresh(1) | Acc(:,2)>PeakThresh(2);
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
    tooShort = find(d(:,3)<20);
    NonSacStart(tooShort) = [];
    NonSacEnd(tooShort) = [];
    %now to hiccups, where there isn't actually a saccade, because
    %it is too short
    if isempty(NonSacStart(2:end))||isempty(NonSacEnd(1:length(NonSacStart)-1))
        saccadesExist = 0;
        continue
    end
    e = [NonSacEnd(1:length(NonSacStart)-1) NonSacStart(2:end)];
    e(:,3) = diff(e,1,2);
    %get the times that are longer than 10ms
    SaccadeTimes = find(e(:,3)>durationThresh);
    if isempty(SaccadeTimes)
        saccadesExist = 0;
        continue
    end
    %use these as the start and end of the bad data
    %check that there is some room for the padding, remove saccades that
    %start too early, they canont be properly analyzed
    if e(SaccadeTimes(1),1)<5
        %check that the saccade doesn't end late and have to be removed as
        %well
        if e(SaccadeTimes(end),2)+20>length(SacStructInput)
            SacEnd = [e(SaccadeTimes(2:end-1),2)]+20;
            SacStart = [e(SaccadeTimes(2:end-1),1)]-4;
        else SacEnd = e(SaccadeTimes(2:end),2)+20;
            SacStart = [e(SaccadeTimes(2:end),1)]-4;
        end
        %if the start doesn't need to be modified, still check the end
    else
        if e(SaccadeTimes(end),2)+20>length(SacStructInput)
            SacEnd = [e(SaccadeTimes(1:end-1),2)]+20;
            SacStart = e(SaccadeTimes(1:end-1),1)-4;
            
        else SacEnd = e(SaccadeTimes,2)+20;
            SacStart = e(SaccadeTimes,1)-4;
        end
    end
    %initialize variables
    StartPoint = NaN(length(SacStart),1);
    EndPoint = NaN(length(SacStart),1);
    Peak = NaN(length(SacStart),1);
    PeakTime =  NaN(length(SacStart),1);
    %actual saccade counter
    saccadeCount = 0;
    %go through all of the  possible saccade periods
    for stamp = 1:length(SacStart);
        
        %make sure there aren't any NaNs in the sample, and if not,
        %increase the saccade counter by one, and calculate the pertinent
        %Points
        if ~any(isnan(SacStructInput(SacStart(stamp):SacEnd(stamp))))
            saccadeCount = saccadeCount+1;
            [StartPoint(saccadeCount),EndPoint(saccadeCount),Peak(saccadeCount),...
                PeakTime(saccadeCount)] = calcEndPoints(SacStructInput...
                (SacStart(stamp):SacEnd(stamp),:));
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
    for sac = 1:length(StartPoint)
        Tsac = Tsac+1;
        TotalStartTime(Tsac) = StartPoint(sac);
        TotalEndTime(Tsac) = EndPoint(sac);
        TotalPeakTime(Tsac) = PeakTime(sac);
        TotalPeakVelocity(Tsac) = Peak(sac);
        StartPointX(Tsac) = SacStructInput(SacStructInput(:,3)==StartPoint(sac),1);
        StartPointY(Tsac) = SacStructInput(SacStructInput(:,3)==StartPoint(sac),2);
        EndPointX(Tsac) = SacStructInput(SacStructInput(:,3)==EndPoint(sac),1);
        EndPointY(Tsac) = SacStructInput(SacStructInput(:,3)==EndPoint(sac),2);
        Amplitude(Tsac) = sqrt((StartPointX(Tsac)-EndPointX(Tsac)).^2 + ...
            (StartPointY(Tsac)-EndPointY(Tsac)).^2);
        Duration(Tsac) = EndPoint(sac)-StartPoint(sac);
        Direction(Tsac) = atan2d((EndPointY(Tsac)-StartPointY(Tsac)),...
            (EndPointX(Tsac)-StartPointX(Tsac)));
        %test for PSO's
        %CheckX
        % if the saccade is the last saccade, see if you need to use the
        % end of the trial as then end of this calculation
        if sac+1>length(StartPoint)
            calcLength = min(find(SacStructInput(:,3)==EndPoint(sac))+38,length(SacStructInput));
        else
            calcLength = min([find(SacStructInput(:,3)==EndPoint(sac))+38,...
                find(SacStructInput(:,3)==StartPoint(sac+1))-1]);
        end
        if calcLength >10 && [calcLength - find(SacStructInput(:,3)==EndPoint(sac))]>10
            PPSOX = SacStructInput(find(SacStructInput(:,3)==EndPoint(sac)):...
                calcLength,1:2:3);
            
            [PSOEndX,Rend] = PSOCalc(PPSOX);
            %CheckY
            PPSOY = SacStructInput(find(SacStructInput(:,3)==EndPoint(sac)):...
                calcLength,2:3);
            
            [PSOEndY, REnd] = PSOCalc(PPSOY);
            PSOEndTotal(sac) = max(PSOEndX,PSOEndY);
            
        end
        %define points where the signal is a saccade
        green(SacStructInput(:,3)>=StartPoint(sac)&SacStructInput(:,3)<=EndPoint(sac)) = 1;
        %define points where the signal is a PSO
        magenta(SacStructInput(:,3)>=EndPoint(sac)&SacStructInput(:,3)<=PSOEndTotal(sac)) = 1;
        
        SacStructInput(SacStructInput(:,3)>=StartPoint(sac)&...
            SacStructInput(:,3)<=PSOEndTotal(sac),1:2) = NaN;
        %     figure
    end
    
    saccadesExist = 2;
end
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

 
%store saccade info
saccadeInfo = struct('StartTime',TotalStartTime,'EndTime',TotalEndTime,...
    'PeakTime',TotalPeakTime,'PeakVelocity',TotalPeakVelocity,'Duration',...
    Duration,'Amplitude',Amplitude,'StartPointX',StartPointX,'EndPointX',...
    EndPointX,'StartPointY',StartPointY,'EndPointY',EndPointY,...
    'Direction',Direction,'PostSaccadicOscillationEnd',PSOEndTotal);


fixation(fixClassifications==1) = 1;
smoothPursuit(fixClassifications==2) = 1;
fixInfo = get_fixation_smoothPursuit_info(eyeData,fixation==1, fsample);
smInfo = get_fixation_smoothPursuit_info(eyeData,smoothPursuit==1,fsample);
unclassified = isnan(EyeDataCopy(:,1));

unclassified = ~(smoothPursuit | fixation| pso | saccade | unclassified);

d1 = [fixInfo.EndTime] - [fixInfo.StartTime];
d2 = [smInfo.EndTime] - [smInfo.StartTime];
figure; 
subplot(1,2,1); hist(d1,100)
subplot(1,2,2); hist(d2,100)

fprintf('\n\t%g saccades identified, %g gaze samples in total (%.3g).', length(saccadeInfo.StartTime), sum(saccade), sum(saccade)/length(EyeDataCopy));
fprintf('\n\t%g PSO gaze samples (%.3g).', sum(pso), sum(pso)/length(EyeDataCopy));
fprintf('\n\t%g fixations identified, %g gaze samples in total (%.3g).', length(fixInfo.StartTime), sum(fixation), sum(fixation)/length(EyeDataCopy));
fprintf('\n\t%g smooth pursuits identified, %g gaze samples in total (%.3g).', length(smInfo.StartTime), sum(smoothPursuit), sum(smoothPursuit)/length(EyeDataCopy));
fprintf('\n\t%g unclassifiable gaze samples (%.3g).', sum(unclassified), sum(unclassified)/length(EyeDataCopy));

%% Output
SacStructOut = struct('SaccadeInfo',saccadeInfo,'FixationInfo',fixInfo,'SmoothPursuitInfo',smInfo,...
    'Saccade',logical(saccade),'PSO',logical(pso),'Fixation',logical(fixation),'SmoothPursuit',logical(smoothPursuit),'Unclassified',logical(unclassified));

end