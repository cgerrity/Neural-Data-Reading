% load
if 0
path = '/Users/ben/Desktop/MonkeyGamesB_1_1__Subject1__13_06_2017__15_38_57/ProcessedData';
cd(path)
end

processedGaze = subjectData.ProcessedEyeData.GazeData;
sacOut = subjectData.ProcessedEyeData.EyeEvents;
classification = processedGaze.Classification;

trialIndices = sacOut.TrialIndices;
%trialIndices = [1 numel(classification)];

% settings
wind = 20*[-1 -1 -1 -1 0 1 1 1 1];
wind = fliplr(wind);
lambdaAcc = 6;

%extract data
t = processedGaze.EyetrackerTimestamp * 10^-6;
d = processedGaze.Distance;
[screenX,screenY] = get_experiment_parameters('tx300');
[x,y] = adcs2dva(processedGaze.XMean,processedGaze.YMean,d,screenX,screenY);
[xs,ys] = adcs2dva(processedGaze.XSmooth,-1*processedGaze.YSmooth,d,screenX,screenY);

eyeData = [x,y,t];
eyeDataSmooth = [xs,ys,t];

%velocity, accelerations
Vels = [conv(eyeDataSmooth(:,1),wind,'same'),conv(eyeDataSmooth(:,2),wind,'same')];
Accs = abs([conv(Vels(:,1),wind,'same'),conv(Vels(:,2),wind,'same')]);

Vel = [conv(eyeData(:,1),wind,'same'),conv(eyeData(:,2),wind,'same')];
Acc = abs([conv(Vel(:,1),wind,'same'),conv(Vel(:,2),wind,'same')]);


% Lowpass filter window length
smoothInt = 0.02; % in seconds
samplingFreq = 300;

% Span of filter
span = ceil(smoothInt*samplingFreq);

% Pixel values, velocities, and accelerations
N = 2;                 % Order of polynomial fit
F = 2*ceil(span)-1;    % Window length
[b,g] = sgolay(N,F);   % Calculate S-G coefficients

x1 = sgolayfilt(x,N,F);
x2 = conv(x,g(:,1)','same');

%v1 = [0; diff(x1)];
v1 = conv(x,wind,'same') ;
v2 = conv(x,-g(:,2)','same');


return
%accelration threshold
AccThresh = nan(size(eyeDataSmooth,1),2);
for it=1:size(trialIndices,1)
    st = trialIndices(it,1);
    fn = trialIndices(it,2);

    tmpAcc = Accs(st:fn,:);

    Threshdiff = [3,3];
    PeakThresh = [10000,10000];
    %PeakThresh = [50000,50000];
    for var = 1:2
        while Threshdiff(var)>1
            tmp = tmpAcc( tmpAcc(:,var) < PeakThresh(var), var );
            %tmp = Acc( abs(Acc(:,var)) < PeakThresh(var), var );
            MeanVel(var) = mean(tmp);
            STD(var) = std(tmp);
            NewThresh = MeanVel(var) + lambdaAcc*STD(var);
            Threshdiff(var) = abs( PeakThresh(var) - NewThresh );
            PeakThresh(var) = NewThresh;
        end

        AccThresh(st:fn,var) = PeakThresh(var);
    end
end
    

%plots
it = 1;

for it=1:size(toi_all,1)
    pad = 0.1;
    toi = toi_all(it,:);
    selt = t >=toi(1)-pad & t<=toi(2) + pad;

    %ipk = find( toi(1) >= t(trialIndices(:,1)), 1);
    ipk = nearest(t,mean(toi));

    figure
    nr = 3; nc=2;
    posstr = {'xpos','ypos'};
    for iax=1:2
        if iax==1; tmp = x; tmps = xs; 
        else tmp = y; tmps = ys; 
        end

        ns = iax;
        subplot(nr,nc,ns)

        %position
        plot(t(selt),tmp(selt))
        hold all
        plot(t(selt),tmps(selt))
        title(posstr{iax})
        legend({'raw','smooth'},'location','northeast')
        ax = gca;

        ns = ns + nc;
        subplot(nr,nc,ns)
        %velocity
        plot(t(selt),Vel(selt,iax))
        hold all
        plot(t(selt),Vels(selt,iax))
        title('velocity')

        ns = ns + nc;
        subplot(nr,nc,ns)
        %accelearation
        plot(t(selt),Acc(selt,iax))
        hold all
        plot(t(selt),Accs(selt,iax))
        title('acceleration')

        a = AccThresh(ipk,iax);
        plotcueline('yaxis',a)
        
        % clasified points
        %plot the classification
        col = 'gmrbk';
        for cc=1:5
            sel = classification(selt)==cc;
            ylim = get(ax,'ylim');
            offset = abs(ylim(2)) * 0.01;
            tmp = (ylim(2) + offset) * ones(size(sel));
            tmp(~sel) = nan;
            plot(ax,t(selt),tmp,[col(cc) 'o'])
        end
        set(ax,'ylim',[ylim(1),ylim(2) + offset*1.01])

    end

    xlim = [t(find(selt,1)), t(find(selt,1,'last'))];
    plotcueline([],'xaxis',toi)
    set_bigfig(gcf,[0.7 0.7])
    setaxesparameter('xlim',xlim)
    
    pause
    close(gcf)
end