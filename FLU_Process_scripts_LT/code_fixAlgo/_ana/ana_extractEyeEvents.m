function [SacStructOut, processedGaze] = ana_extractEyeEvents(varargin)

%% load

if isempty(varargin)
    disp('loading...')

    if 0
        %path ='/Users/Ben/Desktop/_test_eyetracking/Eyetracker';
        %fname = 'eyetrackerTesting__Subject0__22_02_2017__11_28_57__Trial_1.csv';
        epath = '/Users/Ben/Desktop/PilotData/Data/Pilot1__Subject2__05_03_2017__15_58_50/PythonData/Eyetracker';
        %fname = '/eyetrackerPilot1__Subject3__05_03_2017__17_29_34__Trial_100.csv';
        fname = 'eyetrackerPilot1__Subject2__05_03_2017__15_58_50__Trial_194.csv';

        name = [epath '/' fname];
        eyeIn = tdfread(name,'\t');
        %s = readtable(name,'Delimiter','\t');
    else
        %concat all trial data
        %epath = '/Users/Ben/Desktop/PilotData/Data/Pilot1__Subject2__05_03_2017__15_58_50/PythonData/Eyetracker';
        %epath = '/Users/Ben/Desktop/PilotData/Data/Pilot1__Subject3__05_03_2017__17_29_34/PythonData/Eyetracker';
        epath = '/Users/marcus/Desktop/PilotData/Testing__Subject0__10_03_2017__12_40_51/PythonData/Eyetracker';
        %epath = '/Users/Ben/Desktop/Data Pilot 2/Testing__Subject0__10_03_2017__12_40_51/PythonData/Eyetracker';
        cd(epath)
        dd = dir('eyetracker*__Trial_*');

        %sort the names so theyre in order
        inds = [];
        for n=1:numel(dd)
           st = findstr(dd(n).name,'_');
           fn = findstr(dd(n).name,'.csv');

           inds(n) = str2num(dd(n).name(st(end)+1:fn-1));
        end
        [~,isort] = sort(inds,'ascend');
        dd = dd(isort);


        eyeIn = table;
        trialEndIndices = [];
        for n=1:numel(dd)
            %dotdotdot(n,ceil(numel(dd)*0.5),numel(dd))

            name = [epath '/' dd(n).name];
            disp([num2str(n) ': ' name])

            tmp = readtable(name,'Delimiter','\t');


            %concat it all
            trialEndIndices(size(trialEndIndices,1)+1,1) = size(tmp,1);
            eyeIn = cat(1,eyeIn,tmp);
        end
        trialEndIndices = cumsum(trialEndIndices);
        trialStartIndices = [1;trialEndIndices(1:end-1)+1];
    end
else
    eyeIn = varargin{1};
    epath = varargin{2};
end

%% defaults
screenX = 50.8*10; %mm
screenY = 28.7*10; %mm
fsample = 300; %Hz

sgFilt = 1;

plotFig = 0;
saveProcessedEyetrackerFile = 0;
interpolate = 1;
saveFixationAna = 1;


%% pre-processing
t = eyeIn.EyetrackerTimestamp;
t = t * 10^-6; %convert to seconds

%loop over both eyes
eyestr = {'Left','Right'};
for ieye=1:2
    eye = eyestr{ieye};

    Veye = eyeIn.([eye 'EyeValidity']);
    deye = smoothDistance( eyeIn.([eye 'EyePosition3DZ']) );
    xorig = eyeIn.([eye 'EyeGazePoint2DX']);
    yorig = eyeIn.([eye 'EyeGazePoint2DY']);
    dilat = eyeIn.([eye 'Pupil']);
    dilat (dilat <= 0) = NaN;
    if ieye==1
        fprintf('\n\tLEFT EYE ARTIFACT REMOVAL');
        [xleft,yleft,disturbLeft] = RemoveArtifacts(xorig,yorig,deye,Veye,screenX,screenY,fsample,t);
        dilat (disturbLeft(:,3) == 3) = NaN;
        dilatLeft = dilat;
    else
        fprintf('\n\tRIGHT EYE ARTIFACT REMOVAL');
        [xright,yright,disturbRight] = RemoveArtifacts(xorig,yorig,deye,Veye,screenX,screenY,fsample,t);
        dilat (disturbRight(:,3) == 3) = NaN;
        dilatRight = dilat;
    end
end
dilatRaw = nanmean([dilatLeft, dilatRight], 2);

xrawMean = nanmean( [xleft,xright], 2);
yrawMean = nanmean( [yleft,yright], 2);
d = nanmean( [smoothDistance(eyeIn.LeftEyePosition3DZ), smoothDistance(eyeIn.RightEyePosition3DZ)], 2);

% %correct for constant x offset
% if 0
%     offset = nanmedian(xright-xleft)/2;
%     missingLeft = isnan(xleft) & ~isnan(xraw);
%     missingRight = isnan(xright) & ~isnan(xraw);
% 
%     xraw(missingLeft) = xraw(missingLeft) - offset;
%     xraw(missingRight) = xraw(missingRight) + offset;
% 
%     figure; plot(xraw); plotcueline('xaxis',ii)
% end
%figure; plot(d)


%figure; plot(xleft); hold all; plot(xright); plot(xraw); legend({'left','right','mean'}); title('xpos')
%figure; plot(yleft); hold all; plot(yright); plot(yraw); legend({'left','right','mean'}); title('ypos')
%figure; plot(s.Left_Eye_Gaze_Point_2D_X); hold all; plot(xleft,'linewidth',1.5); legend({'raw','artifact-free'})  

[xscreen,yscreen] = acds2screen(xrawMean,yrawMean,screenX,screenY);
xdeg = degreeVisualAngle(xscreen,d);
ydeg = degreeVisualAngle(yscreen,d);


if interpolate
    xdegOrig = xdeg;
    ydegOrig = ydeg;
    [xdeg, numInterpsX] = Interpolate(xdeg, t, 0.02, 0.1, fsample);
    [ydeg, numInterpsY] = Interpolate(ydeg, t, 0.02, 0.1, fsample);
    fprintf(['\n\t' num2str(numInterpsX(1)) ' single-sample and ' num2str(numInterpsX(2)) ' double-sample missing x data points interpolated.']);
    fprintf(['\n\t' num2str(numInterpsY(1)) ' single-sample and ' num2str(numInterpsY(2)) ' double sample missing y data points interpolated.']);
end

% smooth
% MARCUS NYSTRÖM AND KENNETH HOLMQVIST, Behaviour research methods, 2010
if sgFilt
    ord = 2;
    len = ceil(0.02*fsample); %20 ms
    if mod(len,2)==0; len = len+1; end
    
    xdeg2 = sgolayfilt(xdeg,ord,len);
    ydeg2 = sgolayfilt(ydeg,ord,len);
    
    %fc = (1/0.02)./(fsample/2);
    %[b,a] = butter(2,fc,'low');
    %xdeg = filtfilt(b,a,xdeg);
    %ydeg = filtfilt(b,a,ydeg);
    
    %figure; plot(xdeg); hold all; plot(xdeg2)
else
    xdeg2 = xdeg;
    ydeg2 = ydeg;
end


%% extract saccade, PSO, fixations, smooth pursuits

EyeData = [xdeg2,ydeg2,t, dilatRaw];
[SacStructOut] = HcTask_SaccadeProcessing_mg3(EyeData,fsample,0);


%% some variable things

%classificaitons
classification = nan(size(SacStructOut.Saccade));
classification(SacStructOut.Saccade) = 1;
classification(SacStructOut.PSO) = 2;
classification(SacStructOut.Fixation) = 3;
classification(SacStructOut.SmoothPursuit) = 4;
classification(SacStructOut.Unclassified) = 5;

%average x,y, convert back to unity units
%allbad = badleft & badright;
xout = xrawMean;
yout = yrawMean;
%xout(allbad) = nan;
%yout(allbad) = nan;

xtmp = visualangle2pos(circ_ang2rad(xdeg2),d);
ytmp = visualangle2pos(circ_ang2rad(ydeg2),d);

[xoutSmooth,youtSmooth] = screen2acds(xtmp,ytmp,screenX,screenY);
%figure; plot(xoutSmooth); hold all; plot(xraw)

%average fixation
fix = SacStructOut.Fixation==1;
st = find(diff(fix)==1)+1;
fn = find(diff(fix)==-1);

if fn(1) < st(1); st = [1;st]; end
if fn(end) < st(end); fn = [fn;numel(fix)]; end
%figure; plot(fix); hold all; plot(st,fix(st),'r*'); plot(fn,fix(fn),'b*')

fixx = nan(size(fix));
fixy = nan(size(fix));
for ff=1:numel(st)
    fixx(st(ff):fn(ff)) = nanmean(xout(st(ff):fn(ff)));
    fixy(st(ff):fn(ff)) = nanmean(yout(st(ff):fn(ff)));
end

processedGaze = table(eyeIn.EyetrackerTimestamp, xout, yout, xoutSmooth, youtSmooth, fixx, fixy, classification, dilatRaw, disturbLeft, disturbRight, 'VariableNames', ...
    {'EyetrackerTimestamp', 'XMean', 'YMean', 'XSmooth', 'YSmooth', 'XFix', 'YFix', 'Classification', 'Dilation', 'LeftDisturbance', 'RightDisturbance'});

bothEyeDisturb = sum(disturbLeft,2) > 0 & sum(disturbRight,2) >0;

fprintf('\n\t%g invalid, missing, or artifactual gaze samples (%.3g).\n', sum(bothEyeDisturb), sum(bothEyeDisturb) / length(xout));

    %% save file for replayer
if saveProcessedEyetrackerFile
    
    
    savepath = [epath '/ProcessedEyeData'];
    if ~exist(savepath); mkdir(savepath); end

    %split up into trials, add soem columns
%     for id=1:numel(dd)
%         savename = [savepath '/' dd(id).name(1:end-4) '_procFix.csv'];
%         disp([num2str(id) ': saving ' savename])
% 
%         trlsel = trialStartIndices(id):trialEndIndices(id);
%         
%         tmpOut = eyeIn(trlsel,:);
%         tmpOut.meanX = xout(trlsel);
%         tmpOut.meanY = yout(trlsel);
%         tmpOut.smoothX = xoutSmooth(trlsel);
%         tmpOut.smoothY = youtSmooth(trlsel);
%         tmpOut.classification = classification(trlsel);
%         tmpOut.averageFixX = fixx(trlsel);
%         tmpOut.averageFixY = fixy(trlsel);
% 
%         %save
%         writetable(tmpOut,savename,'Delimiter','\t')
%     end
end

%% save data for analysis
if 0%saveFixationAna
    savepath = [epath '/ana_fix'];
    if ~exist(savepath); mkdir(savepath); end
end

%% animation
if 0
    itrl = 1;
    trlsel = trialStartIndices(itrl):trialEndIndices(itrl);
    classification = zeros(size(SacStructOut.Saccade));
    classification(SacStructOut.Fixation) = 1;
    classification(SacStructOut.SmoothPursuit) = 2;
    classification(SacStructOut.Saccade) = 3;
    classification(SacStructOut.PSO) = 4;
    classification = classification(trlsel);
    xx = xscreen(trlsel);
    yy = yscreen(trlsel);
    time = EyeData(trlsel,3);
    time = time - time(1);
    
    animate_gaze(xx,yy,time,classification,1)
end

%% plot everything
if plotFig
    figure

    itrl = 1;
    trlsel = 1:80000; %trialStartIndices(itrl):trialEndIndices(itrl);
    x = EyeData(trlsel,1);
    y = EyeData(trlsel,2);
    time = EyeData(trlsel,3) - EyeData(1,3);
    vel = [0; abs(complex(diff(x),diff(y))) ./ diff(time)];
    unc = SacStructOut.Unclassified(trlsel);
    
    
    events = {'Saccade','PSO','Fixation','SmoothPursuit'};
    cols = 'gmrb';
    lgnd = ['raw',events,'unclassified'];
    
    subplot(3,1,1)
    plot(time,vel,'k-')
    hold all
    for n=1:numel(events)
        sel = SacStructOut.(events{n})(trlsel);
        vel2 = nan(size(vel));
        vel2(sel) = vel(sel);
        plot(time,vel2,[cols(n) '-'],'markersize',2)
    end
    uu = ones(1,numel(unc)) * max(vel)*1.1;
    plot(time(unc),uu(unc),'ko','markersize',3)
    title('velocity')
    ylabel('vel (deg/s)')
    
    subplot(3,1,2)
    plot(time,x,'k-')
    hold all
    for n=1:numel(events)
        sel = SacStructOut.(events{n})(trlsel);
        plot(time(sel),x(sel),[cols(n) 'o'],'markersize',5)
    end
    uu = ones(1,numel(unc)) * max(x)*1.1;
    plot(time(unc),uu(unc),'ko','markersize',3)
    title('xpos')
    ylabel('xpos (deg)')
    
    subplot(3,1,3)
    plot(time,y,'k-')
    hold all
    for n=1:numel(events)
        sel = SacStructOut.(events{n})(trlsel);
        plot(time(sel),y(sel),[cols(n) 'o'],'markersize',5)
    end
    uu = ones(1,numel(unc)) * max(y)*1.1;
    plot(time(unc),uu(unc),'ko','markersize',3)
    title('ypos')
    ylabel('ypos (deg)')
    
    legend(lgnd)
    
    set_bigfig(gcf,[0.8,0.8])
end


