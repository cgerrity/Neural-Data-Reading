% load
if 0
    
path = '/Users/ben/Desktop/MonkeyGamesData/MonkeyGamesB_1_1__Subject1__13_06_2017__15_38_57/ProcessedData';
cd(path)
d = dir('*__SubjectDataStruct.mat');
load(d(1).name)

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
    

%add this to test
ii = 1635;
ii=ii:ii+30;
nsmp = 3;
mx = 4;
offset = linspace(0,4,nsmp);
offset = 1 * [offset, mx*ones(1,numel(ii)-nsmp*2),fliplr(offset)]';
xdeg(ii) = xdeg(ii) + offset;

% Lowpass filter window length
smoothInt = 0.02; % in seconds
samplingFreq = 300;

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

Vel = [];
Vel(:,1) = conv(xdeg, -g(:,2)', 'same');
Vel(1:(Nf-1)/2,1) = xdeg(1:(Nf-1)/2);
Vel(end-(Nf-3)/2:end,1) = xdeg(end-(Nf-3)/2:end);
Vel(:,2) = conv(ydeg, -g(:,2)', 'same');
Vel(1:(Nf-1)/2,2) = ydeg(1:(Nf-1)/2);
Vel(end-(Nf-3)/2:end,2) = ydeg(end-(Nf-3)/2:end);
Vel = Vel * samplingFreq;

Acc = [];
Acc(:,1) = conv(xdeg, -g(:,3)', 'same');
Acc(1:(Nf-1)/2,1) = xdeg(1:(Nf-1)/2);
Acc(end-(Nf-3)/2:end,1) = xdeg(end-(Nf-3)/2:end);
Acc(:,2) = conv(ydeg, -g(:,3)', 'same');
Acc(1:(Nf-1)/2,2) = ydeg(1:(Nf-1)/2);
Acc(end-(Nf-3)/2:end,2) = ydeg(end-(Nf-3)/2:end);
Acc = Acc * samplingFreq^2;


% test it out on one trial
itrl=1;
st = trialIndices(itrl,1);
fn = trialIndices(itrl,2);
sel = st:fn;
%sel = sel(1300:1700);

x = Acc(sel,1);
x = x-nanmean(x);
x(isnan(x))=0;

% get signal parameters for filtering:
sp=get_signal_parameters(...
    'sampling_rate',samplingFreq,... % sampling rate
    'number_points_time_domain',length(x));

plotTarget=1;
if plotTarget
    figure
end

lab = {};
test = 1:20;
freq = 1:100; %10:1:70; %10:1:100;
tmp = nan(numel(freq),numel(x));
for n=1:numel(freq)
    g = [];
    g.center_frequency = freq(n); % Hz
    g.fractional_bandwidth = 1; %test(n);
    g.chirp_rate=0;
    g=make_chirplet(...
      'chirplet_structure',g,...
      'signal_parameters',sp);

  if plotTarget
    target = -imag(g.time_domain);  
    %plot(g.ptime,abs(g.time_domain),':k');
    %hold on;
    plot(g.ptime,target);
    hold all;
    xlabel('Time (sec)');
  end
    

    fsignal=gabor_filter(x',sp.sampling_rate,g.center_frequency,g.fractional_bandwidth);
    trace=abs(fsignal);
    
    tmp(n,:) = trace;
    
    if 0
        figure
        %ind = 1:1000;
        ind = 1:numel(sel);
%         tt = t(sel);
        tt = ind;
        plot(tt(ind),abs(x(ind)))
        hold all
        plot(tt(ind),trace(ind),'r')
    end

    foo=1;
end

%plot results
if 1
    figure
    ind = 1000:2000;
    sel2 = sel(ind);
    tt = t(sel2) - t(sel2(1));
    imagesc(tt,freq,tmp(:,ind))
    set(gca,'ydir','normal')
    hold all

    %xtmp = xdeg2(sel2);
    xtmp = xdeg(sel2);
    xtmp = normalizerange(xtmp,[freq(3), freq(end-3)]);
    plot(tt,xtmp,'w','linewidth',3)

    xtmp = normalizerange(x(ind),[freq(3), freq(end-3)]);
    plot(tt,xtmp,'r','linewidth',3)

    xlabel('time(s)')
    ylabel('freq')
    set(gca,'fontsize',14)
end


%get the threshold
tmp2 = sum(tmp);
thresh = iterativeThreshold(tmp2,max(tmp2)*0.8,1,3);
%thresh = nanstd(tmp2)*3;

ind = 3300:3700;
tmp2 = tmp2(ind);
figure
% plotyy(ind,xdeg2(sel(ind)),ind,tmp2)
plot(tmp2)
plotcueline('y',thresh)









