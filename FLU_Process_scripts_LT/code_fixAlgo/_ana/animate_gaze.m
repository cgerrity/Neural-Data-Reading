function animate_gaze(xx,yy,time,classification,speed)
% animate_gaze(xx,yy,time)
% animate_gaze(xx,yy,time,classification)
% animate_gaze(xx,yy,time,classification,speed)


% id = 1;
% trlsel = trialStartIndices(id):trialEndIndices(id);
% time = EyeData(trlsel,3);
% time = time - time(1);
%          
% classification = zeros(size(SacStructOut.Saccade));
% classification(SacStructOut.Fixation) = 1;
% classification(SacStructOut.SmoothPursuit) = 2;
% classification(SacStructOut.Saccade) = 3;
% classification(SacStructOut.PSO) = 4;
% 
% classification = classification(trlsel);
% xx = xscreen(trlsel);
% yy = yscreen(trlsel);

%defaults
if nargin < 4 || isempty(classification)
    classification = zeros(size(xx));
end

if nargin < 5 || isempty(speed)
    speed = 1;
end

mxpoints = 7; %more points slows it down
screenX = 50.8*10; %mm
screenY = 28.7*10; %mm
fsample = 300;
fr = 1/fsample / speed;

%cols = 'krbgm';
cols= [0 0 0;
        1 0 0;
        0 0 1;
        0 1 0;
        1 0 1];
    
      
%start the figure and adjust the axis size
w = screenX./(screenX+screenY);
h = screenY./(screenX+screenY)*1.6374; %x1.6374 because t roughly scales it to the right size on my mac
%sc = w./oldpos(end);
%sz = get(gcf,'position');


figure
sz = get(0,'screensize');
sz(3:4) = sz(3:4) .* [w h];
set(gcf,'position',sz)

for ii=1:mxpoints
    hp{ii} = scatter(nan,nan);
    hp{ii}.Marker = 'o';
    hp{ii}.SizeData = 50;
    hp{ii}.MarkerFaceColor = 'flat'; 
    hp{ii}.MarkerEdgeColor = 'none';

%     hp{ii} = plot(nan,nan);
%     hp{ii}.Marker = '.';
%     hp{ii}.MarkerSize = 20;

    hold all
end

hax = gca;
ylim = [-screenY/2,screenY/2];
xlim = [-screenX/2,screenX/2];
set(hax,'ylim',ylim,'xlim',xlim);
hax.Title.HorizontalAlignment = 'left';

tmpx = nan(0,1);
tmpy= nan(0,1);
tmpc = nan(0,1);
for n=1:numel(xx)
    
    %store with soem history
    ii = size(tmpx,1)+1;
    tmpx(ii,1) = xx(n);
    tmpy(ii,1) = yy(n);
    tmpc(ii,1) = classification(n)+1;
        
    if numel(tmpx) > mxpoints
        tmpx(1) = [];
        tmpy(1) = [];
        tmpc(1) = [];
    end
    
    %plot all the points
    for jj=1:size(tmpx,1)
        a = jj./size(tmpx,1);
        hp{jj}.XData = tmpx(jj);
        hp{jj}.YData = tmpy(jj);
        hp{jj}.CData = cols(tmpc(jj),:);% * a;
        hp{jj}.MarkerFaceAlpha = a;
        %hp{jj}.Color =cols(tmpc(jj),:);
        
        %alpha(h{jj},a);
    end
    
    set(hax,'ylim',ylim,'xlim',xlim)
    
    str = sprintf('sample %g\ntime= %.2g',n,time(n));
    hax.Title.String = str;

    %drawnow

    pause(fr)
end
