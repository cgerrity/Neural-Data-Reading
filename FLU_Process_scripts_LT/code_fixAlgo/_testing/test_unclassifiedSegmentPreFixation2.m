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
[xdeg,ydeg] = acds2dva(processedGaze.XMean,processedGaze.YMean,d,screenX,screenY);
[xs,ys] = acds2dva(processedGaze.XSmooth,processedGaze.YSmooth,d,screenX,screenY);

%interpolate the data
interpType = 'pchip';
xdeg = interpolate_missingSegments(xdeg,2,interpType);
ydeg = interpolate_missingSegments(ydeg,2,interpType);
    

% Lowpass filter window length
smoothInt = 0.02; % in seconds
samplingFreq = 300;
resamplefs = 300;

% Span of filter
span = ceil(smoothInt*samplingFreq);

% Pixel values, velocities, and accelerations
N = 2;                 % Order of polynomial fit
F = 2*ceil(span)-1;    % Window length
[b,g] = sgolay(N,F);   % Calculate S-G coefficients
Nf = F;

%smooth pos, vel, acc
xdeg2 = conv(xdeg, g(:,1)', 'same');
xdeg2(1:(Nf-1)/2) = xdeg(1:(Nf-1)/2);
xdeg2(end-(Nf-3)/2:end) = xdeg(end-(Nf-3)/2:end);
ydeg2 = conv(ydeg, g(:,1)', 'same');
ydeg2(1:(Nf-1)/2) = ydeg(1:(Nf-1)/2);
ydeg2(end-(Nf-3)/2:end) = ydeg(end-(Nf-3)/2:end);

Vel(:,1) = conv(xdeg, -g(:,2)', 'same');
Vel(1:(Nf-1)/2,1) = xdeg(1:(Nf-1)/2);
Vel(end-(Nf-3)/2:end,1) = xdeg(end-(Nf-3)/2:end);
Vel(:,2) = conv(ydeg, -g(:,2)', 'same');
Vel(1:(Nf-1)/2,2) = ydeg(1:(Nf-1)/2);
Vel(end-(Nf-3)/2:end,2) = ydeg(end-(Nf-3)/2:end);
Vel = Vel * resamplefs;

Acc(:,1) = conv(xdeg, -g(:,3)', 'same');
Acc(1:(Nf-1)/2,1) = xdeg(1:(Nf-1)/2);
Acc(end-(Nf-3)/2:end,1) = xdeg(end-(Nf-3)/2:end);
Acc(:,2) = conv(ydeg, -g(:,3)', 'same');
Acc(1:(Nf-1)/2,2) = ydeg(1:(Nf-1)/2);
Acc(end-(Nf-3)/2:end,2) = ydeg(end-(Nf-3)/2:end);
Acc = Acc * resamplefs^2;
  
Acc = abs(Acc);

eyeData = [xdeg2,ydeg2,t];

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


%plots
%it = 1;
    
dat=out.SacStructOut.FixationInfo;
d = dat.SamplesToNearestEvent(:,2);
f=dat.FlankingEvents;
evt = dat.NearestEvent(:,2);

dsp = [];
drft = [];
for jj=1:size(evt,1)
   fn = dat.StartGazeRow(jj)-1;
   st = fn - 10;
   
   if ~isnan(st)
   
    ind = st:fn;
    xx = xdeg2(ind);
    yy = ydeg2(ind);

    dsp(jj) = (max(xx) - min(xx)) ./ (max(yy) - min(yy));
    %drft(ii) = max( abs(complex(xx-xx(1),yy-yy(1))) );
    drft(jj,1) = max(xx-xx(1));
    drft(jj,2) = max(yy-yy(1));
   else
       drft(jj,1) = nan;
        drft(jj,2) = nan;
   end
end

%selevt = find( abs(drft(:,1)) > 4  & (f(:,1)==-1 | f(:,1)==5));
selevt = find(d>3 & d<11);
%selevt = [1,2,3,4,8,11,13,14,15,17,18,21,23,25,26,27,31,32,41,43,45,46,48,50,51,52,54,56,57,58,60,63,66,67,68,70,72,73,75,76,79,82,87,89,90,91,92,96,97,100,102,105,108,110,111,112,114,117,118,119,123,125,126,128,129,130,131,135,137,139,143,144,147,151,152,156,158,160,162,163,166,167,168,169,170,171,172,176,177,179,180,182,183,185,187,191,192,193,195,197,199,200,201,202,204,206,207,208,209,212,215,216];
dat = sacOut.FixationInfo;
toi_all = [dat.StartTime(selevt), dat.EndTime(selevt)];
toi = toi_all(ismember(selevt,[105, 210, 270, 221]),:);

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



        %position
        ns = iax;
        subplot(nr,nc,ns)
        plot(t(selt),tmp(selt))
        hold all
        plot(t(selt),tmps(selt))
        title(['fix #' num2str(selevt(it)) ': ' posstr{iax}])
        legend({'raw','smooth'},'location','northeast')
        ax = gca;

        %velocity
        ns = ns + nc;
        subplot(nr,nc,ns)
        plot(t(selt),abs(Vel(selt,iax)))
        title('velocity')
        
        ylim = get(gca,'ylim');
        vt = VelThresh(ipk,iax);
        plotcueline('yaxis',vt)
        set(gca,'ylim',[ylim(1), max(vt*1.01, ylim(2))])

        %accelearation
        ns = ns + nc;
        subplot(nr,nc,ns)
        plot(t(selt),Acc(selt,iax))
        title('acceleration')

        ylim = get(gca,'ylim');
        at = AccThresh(ipk,iax);
        plotcueline('yaxis',at)
        set(gca,'ylim',[ylim(1), max(at*1.01, ylim(2))])
        
        % clasified points
        %plot the classification
        col = 'gmrbk';
        ylim = get(ax,'ylim');
        for cc=1:5
            selc = classification(selt)==cc;
            if ylim(2)==0; offset = 0.1;
            else offset = abs(ylim(2)) * 0.01;
            end
            tmp = (ylim(2) + offset) * ones(size(selc));
            tmp(~selc) = nan;
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