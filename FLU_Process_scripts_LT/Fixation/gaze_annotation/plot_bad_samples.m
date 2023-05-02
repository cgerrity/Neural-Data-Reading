path = '/Users/ben/Desktop/TWH_DATA/TWH77_Session2/SubjectTWH77_session2__20_06_2017__13_31_21/ProcessedData';
name = 'SubjectTWH77_session2__20_06_2017__13_31_21__SubjectDataStruct.mat';

fullname = [path '/' name];
if 0
load(fullname)
end

savepath = '/users/ben/desktop/bad_samples';
checkmakedir(savepath)

types = {'Fixation','Saccade','SmoothPursuit'};
itype = 1;
type = types{itype};

%X-120 + Acer monitor
screenX = 47.2 * 10;
screenY = 26.5 * 10;
fsample = 120;

 %extract data
dat = subjectData.ProcessedEyeData.EyeEvents.([type 'Info']);
gaze = subjectData.ProcessedEyeData.GazeData;
eyeIn = subjectData.Runtime.RawGazeData;

N = numel(dat.StartTime);
x = gaze.XMean;
y = gaze.YMean;
t = gaze.EyetrackerTimestamp * 10^-6;
d = nanmean([smoothDistance(eyeIn.('left_gaze_origin_in_user_coordinate_system')(:,3)), smoothDistance(eyeIn.('right_gaze_origin_in_user_coordinate_system')(:,3))], 2);
c = gaze.Classification;

[xscreen,yscreen] = acds2screen(x,y,screenX,screenY);
x = degreeVisualAngle(xscreen,d);
y = degreeVisualAngle(yscreen,d);

%smoothed x,y
xs = gaze.XSmooth;
ys = -1 * gaze.YSmooth; %flip the sign cuz... dunno why

[xscreen2,yscreen2] = acds2screen(xs,ys,screenX,screenY);
xs = degreeVisualAngle(xscreen2,d);
ys = degreeVisualAngle(yscreen2,d);

v = [0; abs(complex(diff(x),diff(y))) ./ diff(t)];
vs = [0; abs(complex(diff(xs),diff(ys))) ./ diff(t)];

%plot it all, will move along later
figure
nr = 3; nc=1;
cols = {'g','m','r','b'};
h = [];
for ii=1:3
    subplot(nr,nc,ii)
    if ii==1; tmp = xs; str = 'xpos'; 
    elseif ii==2; tmp = ys; str = 'ypos'; 
    else  tmp = vs; str = 'velocity'; 
    end
    
    plot(t,tmp,'k-');
    hold all
    plot(t,tmp,'k.','markersize',20);
    
    %pllot all the classifications
    for jj=1:4
        sel = c==jj;
        tmp2 = tmp;
        tmp2(~sel) = nan;
        
        plot(t,tmp2,[cols{jj} '-'],'linewidth',2)
    end
    h(ii) = gca;
end

%find all the bad samples
thresh = 0.04;
d = dat.EndTime - dat.StartTime;
bad = find( d < thresh )';
%bad = find(d>0.04 & d<0.06)';
pad = ceil(fsample*0.07);
for ib=bad
    
    st = nearest(t,dat.StartTime(ib));
    fn = nearest(t,dat.EndTime(ib));
    
    st2 = max(st-pad,1);
    fn2 = min(fn+pad,numel(t));

    for ih=1:numel(h)
        if ih==1; tmp = xs; str = 'xpos'; 
        elseif ih==2; tmp = ys; str = 'ypos'; 
        else  tmp = vs; str = 'velocity'; 
        end
        tmp = tmp(st2:fn2);
        ylim = [min(tmp) - abs(min(tmp))*0.05, max(tmp) + abs(max(tmp))*0.05];
        set(h(ih),'ylim',ylim)
        
        str = sprintf('%s, nsmp=%g, dt=%.3g',str,fn-st,d(ib));
        title(h(ih),str)
    end
    set(h,'xlim',[t(st2),t(fn2)])
    
    pl1 = plotcueline(h,'xaxis',t(st),'g');
    pl2 = plotcueline(h,'xaxis',t(fn),'r');
    
    sname = [savepath '/' type num2str(ib) '.png'];
    print(sname,'-dpng')
    xxx=1;
end

