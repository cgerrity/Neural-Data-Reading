function varargout = gui_gaze_annotate(varargin)

% GUI_GAZE_ANNOTATE MATLAB code for gui_gaze_annotate.fig
%      GUI_GAZE_ANNOTATE, by itself, creates a new GUI_GAZE_ANNOTATE or raises the existing
%      singleton*.
%
%      H = GUI_GAZE_ANNOTATE returns the handle to a new GUI_GAZE_ANNOTATE or the handle to
%      the existing singleton*.
%
%      GUI_GAZE_ANNOTATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_GAZE_ANNOTATE.M with the given input arguments.
%
%      GUI_GAZE_ANNOTATE('Property','Value',...) creates a new GUI_GAZE_ANNOTATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_gaze_annotate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_gaze_annotate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_gaze_annotate

% Last Modified by GUIDE v2.5 20-Jan-2018 10:30:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_gaze_annotate_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_gaze_annotate_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_gaze_annotate is made visible.
function gui_gaze_annotate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_gaze_annotate (see VARARGIN)

% some visibility settings
useAlgoOutput = 0; %show what the algo classified
useOldManualClassification = 1;
allowAnimation = 0; %animation still buggy
plotOnlySmooth = 1;


%load in data
%[file,path] = uigetfile();
%file = 'SubjectTWH77_session2__20_06_2017__13_31_21__SubjectDataStruct.mat';
%file = 'MonkeyGamesB_1_4__Subject19__07_07_2017__15_01_06__SubjectDataStruct';
%path = '/Users/ben/Desktop/TWH_DATA/TWH77_Session2/SubjectTWH77_session2__20_06_2017__13_31_21/ProcessedData';
%path = '/Users/ben/Desktop/man_gaze_class';
%path = '/Users/ben/Downloads/300hz_static_and_dynamic_example_subjs/MonkeyGamesB_1_4__Subject19__07_07_2017__15_01_06/ProcessedData';

%path = '/Users/ben/Downloads/300hz_static_and_dynamic_example_subjs/MonkeyGamesB_1_4__Subject19__07_07_2017__15_01_06/ProcessedData';
%file = 'MonkeyGamesB_1_4__Subject19__07_07_2017__15_01_06__SubjectDataStruct.mat';
%path = '/users/ben/desktop/prepare_test_datasets';
% path = '/users/ben/desktop/prepare_test_datasets/_ben';
% subj = 'MonkeyGamesB_1_1__Subject1__13_06_2017__15_38_57';
% file = [subj '__SubjectDataStruct.mat'];
sessionFolderPath = '/Users/marcuswatson/Downloads/Session12__01_10_2020__10_31_31';
trackerType = 'spectrum';
user = 'Marcus1';

% fullpath = [path '/' file];
% load(fullpath)
rawPath = [sessionFolderPath filesep 'ProcessedData' filesep 'RawGazeData.Mat'];
processedPath = [sessionFolderPath filesep 'ProcessedData' filesep 'ProcessedGazeData.Mat'];
savePath = [sessionFolderPath filesep 'ProcessedData' filesep 'ManualGazeClassification_' user '.mat'];
load(rawPath);
if isfile(savePath)
    load(savePath);
else
    load(processedPath);
end

%savePath = [path '2/test_save.mat'];
%savePath = [path '/_ben/' file];
% savePath = fullpath;
%savePath = ['/Users/ben/Desktop/man_gaze_class/' file];

%loop through all handles and make sure the units are "normalized"
ff = fields(handles);
for ih=1:numel(ff)
   try
       set(handles.(ff{ih}),'units', 'normalized');
   end
end

%resize figure
set(gcf, 'units', 'normalized', 'position', [0 0 0.9 0.9])

% some hot-keys
% Add menus with Accelerators
%mymenu = uimenu('Parent',handles.figure1,'Label','Hot Keys');
%uimenu('Parent',mymenu,'Label','Zoom','Accelerator','z','Callback',@(src,evt)zoom(handles.figure1,'on'));

%settings
[screenX,screenY,fsample] = get_experiment_parameters(trackerType);

speed = 1;

%extract
dat = processedGazeData.GazeData;
eyeIn = rawGazeData;

if plotOnlySmooth
    x = dat.XSmooth;
    %y = -1*dat.YSmooth;
    y = dat.YSmooth;
    set(handles.bshowsmooth,'visible','off')
else
    x = dat.XMean;
    y = dat.YMean;
end


c = dat.Classification;
time = dat.EyetrackerTimestamp;
time = (time - time(1)) * 10^-6;

% d = nanmean([smoothDistance(eyeIn.('left_gaze_origin_in_user_coordinate_system')(:,3)),...
%     smoothDistance(eyeIn.('right_gaze_origin_in_user_coordinate_system')(:,3))], 2);
d = nanmean([smoothDistance([eyeIn.('left_origin_UCS_x') eyeIn.('left_origin_UCS_y') eyeIn.('left_origin_UCS_z')],fsample),...
    smoothDistance([eyeIn.('right_origin_UCS_x') eyeIn.('right_origin_UCS_y') eyeIn.('right_origin_UCS_z')],fsample)], 2);
[xscreen,yscreen] = acds2screen(x,y,screenX,screenY);
xdeg = pos2dva(xscreen,d);
ydeg = pos2dva(yscreen,d);

%v = [0; abs(complex(diff(x),diff(y))) ./ diff(time)];
v = [0; abs(complex(diff(xdeg),diff(ydeg))) ./ diff(time)];

%smoothed data
xsmooth = dat.XSmooth;
ysmooth = -1*dat.YSmooth;
[xtmp,ytmp] = acds2screen(xsmooth,ysmooth,screenX,screenY);
xtmp = pos2dva(xtmp,d);
ytmp = pos2dva(ytmp,d);
vsmooth = [0; abs(complex(diff(xtmp),diff(ytmp))) ./ diff(time)];


%check if there aleady exists a manclass
if useAlgoOutput
    manclass = c;
else
    if useOldManualClassification && any(strcmp('ManualClassification',dat.Properties.VariableNames))
        manclass = [dat.ManualClassification];
    else
        manclass = nan(size(c));
    end
end

%------------------------------------------------------------------------
%settings to be globally shared
%handles.hFig = hObject;
handles.speed = 0.5;
handles.winlen = 0.2; %sec
handles.winst = time(1);
handles.winend = handles.winst+handles.winlen;
handles.isplay = 1;
handles.t = time(1);
handles.it = 1;
handles.time = time;
handles.fsample = fsample;
handles.iskip = ceil(handles.winlen./fsample);
handles.x = x;
handles.y = y;
handles.xscreen = xscreen;
handles.yscreen = yscreen;
handles.xdeg = xdeg;
handles.ydeg = ydeg;
handles.v = v;
handles.manclass = manclass;
handles.b = 0;
handles.classEndpoints = [nan nan];
handles.hclassEndpoints = {nan nan};
handles.hclassified = nan(1,numel(time));
% handles.subjectData = subjectData;
handles.processedGazeData = processedGazeData;
handles.savePath = savePath;
handles.saved = 1;
%handles.target_ylim = get(all_timeaxes(handles),'ylim');
handles.animateGaze = 1;
handles.allowAnimation = allowAnimation;
handles.skipToEvent = [];
handles.currentMouse = [];
handles.hclass = [];
%handles.robot = rob;

% timer (in GUIDE, gigure handleVisbilit must be "on")
period = 1/fsample;
handles.timer = timer('TimerFcn',{@update_time,handles.figure1},...
            'ExecutionMode','fixedDelay',...
            'Period',period,...
            'TasksToExecute',Inf);
handles.tcount = 0;


%------------------------------------------------------------------------
% make some adjustments
set(all_timeaxes(handles),'NextPlot','add')

handles.editWin.String = num2str(handles.winlen);
handles.editStart.String = num2str(handles.winst);
handles.editEnd.String = num2str(handles.winend);
handles.editSpeed.String = num2str(handles.speed);

mn = time(1);
mx = time(end);
handles.timeslider.Min = mn;
handles.timeslider.Max = mx;
handles.timeslider.Value = time(1);
%handles.timeslider.SliderStep = [1,10]./(mx-mn); 
%handles.timeslider.SliderStep = [0.1, 1] ./ (mx-mn); 
handles.timeslider.SliderStep = [0.2 * handles.winlen, 10*handles.winlen] ./ (mx-mn); 

xlim = [handles.winst, handles.winend];
set(all_timeaxes(handles),'xlim',xlim)

handles.editSavepath.String = handles.savePath;

handles.banimate.Value = 1;

handles.lskip.String = {'none','fix','sac','sm','wierd'};
handles.lskip.Min = 1;
handles.lskip.Max = numel(handles.lskip.String)-1;

handles.manclass(1) = 0;

%handles.bgclass.SelectionChangedFcn = @change_classification;

%------------------------------------------------------------------------
%plot
mk = 12;
lw = 1;

hsmoothplot = [];
hrawplot = [];

ax = handles.axvel;
hrawplot(1) = plot(ax,time,v,'k-','hittest','off','linewidth',lw);
hold on
plot(ax,time,v,'k.','markersize',mk)
hsmoothplot(1) = plot(ax,time,vsmooth,'c','linewidth',lw);
%title(ax,'velocity')
%xlabel(ax,'time')
ylabel(ax,'vel (deg/s)')
set(handles.axvel,'ylim',[min(v)*0.90, max(v)*1.1])
grid(handles.axvel, 'on')

ax = handles.axx;
hrawplot(2) = plot(handles.axx,time,x,'k-','hittest','off','linewidth',lw);
hold on
plot(ax,time,x,'k.','markersize',mk)
hsmoothplot(2) = plot(ax,time,xsmooth,'c','linewidth',lw);
%title(ax,'x-pos')
%xlabel(ax,'time')
ylabel(ax,'x-pos (acds)')
%set(ax,'ylim',[min(x)*0.9, max(x)*1.1])
set(ax,'ylim',[0 1])
hold on
grid(handles.axx, 'on')

ax = handles.axy;
hrawplot(3) = plot(handles.axy,time,y,'k-','hittest','off','linewidth',lw);
hold on
plot(ax,time,y,'k.','markersize',mk)
hsmoothplot(3) = plot(ax,time,ysmooth,'c','linewidth',lw);
%title(ax,'y-pos')
%xlabel(ax,'time')
ylabel(ax,'y-pos (acds)')
% set(ax,'ylim',[min(y)*0.95, max(y)*1.05])
set(ax,'ylim',[0 1])
hold on
grid(handles.axy, 'on')

hl = plotcueline(all_timeaxes(handles),'xaxis',time(1));
handles.tticks = hl;
handles.hsmoothplot = hsmoothplot;
handles.hrawplot = hrawplot;
bshowsmooth_Callback(handles.bshowsmooth, eventdata, handles)
handles = guidata(hObject);

%start plot for manual classification, and plot anything already there
%events = [1 3 4]; %plot these events
events = [mapclass('sac'), mapclass('fix'), mapclass('sm'), mapclass('wierd')];
handles.hclass.order = {'sac','fix','sm','wierd'};
    
axs = {'axx','axy','axvel'};
for ih=1:numel(axs)
    tmp = [];
    for ii=1:numel(events)
        sel = handles.manclass==events(ii);
        [~,col] = mapclass(events(ii));
        
        tmpy = get_ydata(handles,axs{ih});
        tmpy(~sel) = nan;
        
        tmp(ii) = plot(handles.(axs{ih}),time,tmpy,'color',col,'linewidth',3);
    end
    handles.hclass.(axs{ih}) = tmp;
end


%         sel = handles.manclass==events(jj);
%         st = find(diff(sel)==1)+1;
%         fn = find(diff(sel)==-1);
%         if fn(1) < st(1); st = [1;st]; end
%         if fn(end) < st(end); fn = [fn;numel(sel)]; end
% 
%         for ii=1:numel(st)
%             st2 = st(ii);
%             fn2 = fn(ii);
%             tmpy = handles.y(st2:fn2);
%             tmpx = handles.x(st2:fn2);
%             ic = handles.manclass(st2);
% 
%             handles = plot_classified_segment(handles,st2,fn2,ic);
%         end

%start animation pane
axes(handles.axanim)
ylim = [0 1];
xlim = [0 1];
hpatch = patch([xlim(1),xlim(1),xlim(2),xlim(2)],...
    [ylim(1),ylim(2),ylim(2),ylim(1)],[0 0 0],'FaceAlpha',0.1);
set(handles.axanim,'xlim',xlim,'ylim',ylim)
anline = animatedline('linestyle','none','marker','.','markersize',30,'MaximumNumPoints',7);
nonanline = plot(nan,nan,'k.','markersize',10);

handles.nonanline = nonanline;
handles.anline = anline;
handles.anpatch = hpatch;
ylabel('ypos')
xlabel('xpos')
grid on
%xx = screenX./screenY;
pbaspect([screenX,screenY, 1])

%change some stuff if were not allowing any animation   
if ~handles.allowAnimation
    set(handles.bplay,'visible','off')
    set(handles.bstop,'visible','off')
    set(handles.banimate,'visible','off')
    set(handles.editSpeed,'visible','off')

    handles.bstop.Value = 1;
    handles.bplay.Value = 0;
    handles.banimate.Value = 0;
    handles = banimate_Callback(handles.banimate,eventdata,handles);
end


% Choose default command line output for gui_gaze_annotate
handles = update_axes(handles);
handles.output = hObject;



% Update handles structure
guidata(hObject, handles);
%update_axes(handles);


% UIWAIT makes gui_gaze_annotate wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%% main functions

% for classification
function handles = set_classEndpoints(handles,t,flag)

%start or end point?
if nargin<3
    flag = handles.currentMouse;
end
if flag==1 %left click
    ipt = 1;
    c = 'g-';
elseif flag==3 %right click
    ipt = 2;
    c = 'r-';
end

% update the proper point
t = nearest_time(t,handles.time);
handles.classEndpoints(ipt) = t;
if isnan(handles.hclassEndpoints{ipt})
    handles.hclassEndpoints{ipt} = plotcueline(all_timeaxes(handles),'xaxis',t,c,'Tag','endpoint');
else
    set(handles.hclassEndpoints{ipt},'XData',[t t])
end

% for animation and redrawing
function varargout = toggleTimer(flag,handles)
if nargin<2
    handles = guidata(gcf);
end

if handles.allowAnimation
    if strcmp(flag,'on') && ~strcmp(handles.timer.Running,'on')
        start(handles.timer)
        handles.isplay = true;
    elseif strcmp(flag,'off') && ~strcmp(handles.timer.Running,'off')
        stop(handles.timer)
        handles.isplay = false;
    end
end

%guidata(handles.figure1,handles);
if nargout>0
    varargout{1} = handles;
end

function update_time(src,evt,hFig)
%handles = hFig.handles;
handles = guidata(hFig);

%change_t(handles.time(handles.it+1));
it = handles.it + 1;
handles.it = it;
handles.t = handles.time(it);
t = handles.t;
%disp(['timer: ' num2str(it) ', ' num2str(t)])

%dont overwrite any classification
if isnan(handles.manclass(it))
    handles.manclass(it) = 0;
end

handles = update_axes(handles);
handles.timeslider.Value = t;
handles.editT.String = num2str(t);

%update line animtion
fr = handles.speed / handles.fsample;
if handles.animateGaze
    x = handles.x(it);
    y = handles.y(it);
    if any(isnan([x,y]))
        x = 0; y = 0;
    end
    addpoints(handles.anline,x,y);
    
    %color patch
    if 0 && ~isnan(handles.manclass(it))
        [ic,col] = mapclass(handles.manclass(it));
        if ~isequal(handles.anpatch.FaceColor,col)
            handles.anpatch.FaceColor = col;
        end
    end
    
    %drawnow
    %pause(fr)
end

%force garbage collection
if handles.allowAnimation
    handles.tcount = handles.tcount+1;
    if mod(handles.tcount,1000)==1
        disp('forcing garbage collection')
        java.lang.System.gc()
    end
end

guidata(handles.figure1, handles);



function check_axes(handles)

%check x-axis
xlim = get(all_timeaxes(handles),'xlim');
xlim_target = [handles.winst,handles.winend];
if all(cellfun(@(x) isequal(x,xlim{1}),xlim )) || ~all(xlim_target==xlim{1})
    set(all_timeaxes(handles),'xlim',xlim_target)
end

% %check y-axis
% if 0
%     targ = handles.target_ylim;
%     ha = all_timeaxes(handles);
%     if ~isequal(get(ha,'ylim'),targ)
%         for ii=1:numel(targ)
%             set(ha(ii),'ylim',targ{ii});
%         end
%     end
%     
% end


function handles = change_t(newtime,handles,forceUpdate)

if nargin<2
    handles = guidata(gcf);
end
if nargin<3
    forceUpdate = 0;
end

if ~isempty(newtime)
    handles.t = nearest_time(newtime,handles.time);
    handles.it = nearest(handles.time,handles.t);
    handles = update_axes(handles,forceUpdate);
    handles.editT.String = num2str(handles.t);
    handles.timeslider.Value = newtime;
end

%guidata(handles.figure1,handles)


function varargout = nearest_time(t,time)

[~,ii] = min(abs(time-t));
newt = time(ii);

varargout{1} = newt;
if nargout>1
    varargout{2} = ii;
end


function handles = update_axes(handles,forceUpdate)

if nargin<2
    forceUpdate = 0;
end
%forceUpdate = 1;

%handles = toggleTimer('off',handles); 

t = handles.time(handles.it);
handles.t = t;
set(handles.tticks,'XData', [t t]);

%disp([t,handles.winend])
justSwitched = 0;
if t>=handles.winend  || t<=handles.winst || forceUpdate
    %disp([t,handles.winst,handles.winend])
    
    handles.winst = t;
    handles.winend = t+handles.winlen;
    %update_axes(handles);
    
    %update the time axes
    xlim = [handles.winst, handles.winend];

    handles.axvel.XLim = xlim;
    handles.axx.XLim = xlim;
    handles.axy.XLim = xlim;

    %update the x-y plot, if were not animating
    if ~handles.allowAnimation || ~handles.animateGaze
        ist = nearest(handles.winst,handles.time);
        ifn = nearest(handles.winend,handles.time);
        
        handles.nonanline.XData = handles.x(ist:ifn);
        handles.nonanline.YData = handles.y(ist:ifn);
        %clear x y 
%         dl = findobj(handles.axanim,'Type','Line');
%         delete(dl)
%         plot_color_coded_points(handles.x(ist:ifn),handles.y(ist:ifn))
    end
    
    %update the info panels
    handles.editStart.String = num2str(xlim(1));
    handles.editEnd.String = num2str(xlim(2));
    justSwitched = 1;
end
   
if ~justSwitched
    check_axes(handles)
end

%guidata(handles.figure1,handles);




function varargout = mapclass(handles)
% mapping of classification type to id and color

% % -----  These re the ID for each gaze event
% % classification = nan(size(SacStructOut.Saccade));
% % classification(SacStructOut.Saccade) = 1;
% % classification(SacStructOut.PSO) = 2;
% % classification(SacStructOut.Fixation) = 3;
% % classification(SacStructOut.SmoothPursuit) = 4;
% % classification(SacStructOut.Unclassified) = 5;

%handles different inputs
flag = zeros(1,3);
if isstruct(handles)
    flag = [handles.bsac.Value,handles.bfix.Value,handles.bsm.Value,handles.bwierd.Value];
elseif ischar(handles)
    flag =[strcmp(handles,'sac'),strcmp(handles,'fix'),strcmp(handles,'sm'),strcmp(handles,'wierd')];
elseif isnumeric(handles) && numel(handles)==1
    flag = [handles==1, handles==3, handles==4, handles==5 | handles==99];
end

if flag(1)
    ic = 1; 
    col = [0 1 0]; %'g';
elseif flag(2)
    ic = 3;
    col = [1 0 0]; %'r';
elseif flag(3)
    ic = 4;
    col = [0 0 1]; %'b';
elseif flag(4)
    ic = 99;
    col = [0.8000    0.4745    0.6549]; %purpl-ish
else
    ic = 0;
    col = [0 0 0]; %'k';
end

varargout{1} = ic;
if nargout>1
    varargout{2} = col;
end



function out = all_timeaxes(h)
out = [h.axvel,h.axx,h.axy];

function [x,y,but] = class_tool()

[x,y,but] = ginput();


function handles = garbage_collection(handles)

%delete any extraneous classification endpoints
h = findobj(handles.axx,'Tag','endpoint');
h = [h; findobj(handles.axy,'Tag','endpoint')];
h = [h; findobj(handles.axvel,'Tag','endpoint')];

%delete the black lines from class deletion
h = [h; findobj(handles.axx,'Tag','delline')];
h = [h; findobj(handles.axy,'Tag','delline')];
h = [h; findobj(handles.axvel,'Tag','delline')];

%update the tags
handles = bdiscard_Callback([], [], handles);

delete(h)


%% callbacks ans stuff
 

% --- Outputs from this function are returned to the command line.
function varargout = gui_gaze_annotate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in bfix.
function bfix_Callback(hObject, eventdata, handles)
% hObject    handle to bfix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bfix
guidata(hObject,handles);


% --- Executes on button press in bsac.
function bsac_Callback(hObject, eventdata, handles)
% hObject    handle to bsac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bsac
guidata(hObject,handles);


% --- Executes on button press in bsm.
function bsm_Callback(hObject, eventdata, handles)
% hObject    handle to bsm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bsm
guidata(hObject,handles);


% --- Executes on button press in bwierd.
function bwierd_Callback(hObject, eventdata, handles)
% hObject    handle to bwierd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bwierd


% --- Executes on button press in bstop.
function bstop_Callback(hObject, eventdata, handles)
% hObject    handle to bstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%stop
handles.bstop.Value = 1;
handles.bplay.Value = 0;
handles = toggleTimer('off',handles);
guidata(hObject,handles);

% --- Executes on button press in x.
function bplay_Callback(hObject, eventdata, handles)
% hObject    handle to bplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.bstop.Value = 0;
handles.bplay.Value = 1;
handles.bclassdel.Value = 0;
handles = toggleTimer('on',handles);
guidata(handles.figure1,handles);



% --- Executes on button press in brew.
function brew_Callback(hObject, eventdata, handles)
% hObject    handle to brew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = skip_time(handles,'rew');
guidata(hObject,handles);




% --- Executes on button press in bfwd.
function bfwd_Callback(hObject, eventdata, handles)
% hObject    handle to bfwd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = skip_time(handles,'fwd');
guidata(hObject,handles);



function handles = skip_time(handles,type)


handles = toggleTimer('off',handles);
if isempty(handles.skipToEvent) %skip to the next time window
    if strcmp(type,'fwd')
        handles.winst = handles.winend;
        handles.winend = handles.winst + handles.winlen;
        t = handles.winst;
    elseif strcmp(type,'rew')
        handles.winst = handles.winst - handles.winlen;
        handles.winend = handles.winst + handles.winlen;
        t = handles.winst;
    end
else
    %index according to rewind/forward
    if strcmp(type,'fwd')
        tmp = handles.manclass(handles.it:end);
        dtmp = diff(tmp);
        inds = find(dtmp~=0) + handles.it;
    elseif strcmp(type,'rew')
        tmp = handles.manclass(1:handles.it-1);
        dtmp = diff(tmp);
        inds = find(dtmp~=0) + 1;
        inds = inds(end:-1:1); %reverse so we look backwards
    end
    
    %figure out where the next event starts
    if ~isempty(inds)
        t = [];
        ii = 0;
        while isempty(t) && ii<numel(inds)
            ii=ii+1;
            if ismember(handles.manclass(inds(ii)),handles.skipToEvent)
                pad = 0.15;
                t = handles.time(inds(ii));
                handles.winst = t - pad;
                
                if handles.chresize.Value
                    sel = handles.manclass(inds(ii):end)==handles.manclass(inds(ii));
                    iw = find(diff(sel)==-1,1) + inds(ii);
                    winend = handles.time(iw) + pad;
                    handles.winend = winend;
                else
                    handles.winend = handles.winst + handles.winlen;
                end
            end
        end
        
        if ii==numel(inds)
            handles.textwin.String = 'no more events of selected type left!';
        end

    else
        t = [];
    end
end

handles = change_t(t,handles);
%disp([handles.winst,handles.winend])

%update_axes(handles);
if handles.bplay.Value==1; handles = toggleTimer('on',handles); end



% --- Executes on slider movement.
function timeslider_Callback(hObject, eventdata, handles)
% hObject    handle to timeslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%disp(hObject.Value)
if 0 && strcmp(handles.timer.Running,'on')
    handles.textwin.String = 'pause before moving the slider!';
else
    handles = toggleTimer('off');
    %handles = change_t(hObject.Value,handles);
    handles.t = hObject.Value;
    handles.winst = handles.t;
    handles.winend = handles.winst + handles.winlen;
    handles = change_t(handles.t,handles,1);
    if handles.bplay.Value; handles = toggleTimer('on'); end
end
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function timeslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editStart_Callback(hObject, eventdata, handles)
% hObject    handle to editStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStart as text
%        str2double(get(hObject,'String')) returns contents of editStart as a double

handles.winst = str2num(hObject.String);
update_axes(handles);
guidata(handles.figure1,handles);


% --- Executes during object creation, after setting all properties.
function editStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function editEnd_Callback(hObject, eventdata, handles)
% hObject    handle to editEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEnd as text
%        str2double(get(hObject,'String')) returns contents of editEnd as a double

handles.winend = str2num(hObject.String);
update_axes(handles);
guidata(handles.figure1,handles);

% --- Executes during object creation, after setting all properties.
function editEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editWin_Callback(hObject, eventdata, handles)
% hObject    handle to editWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWin as text
%        str2double(get(hObject,'String')) returns contents of editWin as a double

handles = toggleTimer('off',handles); 
v = str2num(hObject.String);
if ~isempty(v)
    handles.winlen = v;
    handles.winst = handles.t;
    handles.winend = handles.winst + handles.winlen;
    
    mn = handles.time(1);
    mx = handles.time(end);
    handles.timeslider.SliderStep = [0.5*handles.winlen, 10*handles.winlen] ./ (mx-mn); 

    handles = update_axes(handles,1);
else
    hObject.String = num2str(handles.winlen);
end
handles = toggleTimer('on',handles); 
guidata(handles.figure1,handles);


% --- Executes during object creation, after setting all properties.
function editWin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editT_Callback(hObject, eventdata, handles)
% hObject    handle to timetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timetext as text
%        str2double(get(hObject,'String')) returns contents of timetext as a double

v = str2num(hObject.String);
if ~isempty(v)
    handles = change_t(v,handles);
else
    hObject.String = handles.t;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function timetext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bclass.
function varargout = bclass_Callback(hObject, eventdata, handles)
% hObject    handle to bclass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check if were ready to classify
if all(~isnan(handles.classEndpoints))
    %check that theyre in the right order
    if diff(handles.classEndpoints)<0
        handles.textwin.String = 'Cant calssify... start point has to be before end point!';
    else
        %classify this shiz
        [ic,~] = mapclass(handles);
        st = nearest(handles.time,handles.classEndpoints(1));
        fn = nearest(handles.time,handles.classEndpoints(2));
        handles.manclass(st:fn) = ic;
        
        handles = plot_classified_segment(handles,st,fn);
        
        %clear the points
        handles = bdiscard_Callback(handles.bdiscard,eventdata,handles);
        handles.saved = 0;
        
        %start the next classification
        try
            %bad = isnan(handles.x);
            %fn2 = min(fn + 1, fn + find(bad(fn+1:end),1));
            if ~isnan(handles.x(fn+1))
                handles = set_classEndpoints(handles,handles.time(fn2),1);
            end
        catch
            handles = bdiscard_Callback(handles.bdiscard,eventdata,handles);
        end
    end
else
    handles.textwin.String = 'Cant classify yet...';
end

guidata(hObject,handles)

if nargout>0
    varargout{1} = handles;
end
   
function handles = plot_classified_segment(handles,st,fn,classType)

%plot that shiz
if nargin<4
    [ic,col] = mapclass(handles);
else
    [ic,col] = mapclass(classType);
end

%loop over each x,y,v axis
axs = {'axx','axy','axvel'};
for ih=1:numel(axs)
    h = handles.hclass.(axs{ih});
    %iv = mapclass(handles.hclass.order)==ic;
    
    %check for each classification type
    for iv=1:numel(h)
        h2 = h(iv);
        if h2==0; continue; end
        ydata = get(h2,'YData');
        
        %visualze this segment if its of the right type
        if mapclass(handles.hclass.order{iv})==ic
            tmpy = get_ydata(handles,axs{ih});
            ydata(st:fn) = tmpy(st:fn);

        else %otherwise delete it
            ydata(st:fn) = nan;
        end
        
        set(h2,'YData',ydata)
    end
end

% t = handles.time(st:fn);
% handles.hclassified(1,st:fn) = plot(handles.axvel,t,handles.v(st:fn),'color',col,'linewidth',3);
% handles.hclassified(2,st:fn) = plot(handles.axx,t,handles.x(st:fn),'color',col,'linewidth',3);
% handles.hclassified(3,st:fn) = plot(handles.axy,t,handles.y(st:fn),'color',col,'linewidth',3);


% --- Executes on button press in bclassdel.
function bclassdel_Callback(hObject, eventdata, handles)
% hObject    handle to bclassdel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~handles.bclassdel.Value
    handles.bclassdel.Value = 1;
end

%draw a line, if it intersects a classified segment, delete that segment
hl = gline();
hl.Tag = 'delline';
%wit for two button clicks, because matlab is dumb and oesnt wait forgline...
nbut = 0;
while nbut<2
    b = waitforbuttonpress;
    if b==0; nbut=nbut+1; end
end
 
    
%pause
% hl = []; [hl.XData,hl.YData] = ginput(2);
tag = hl.Parent.Tag;

m = diff(hl.YData)./diff(hl.XData);
b = hl.YData(1) - m*hl.XData(1);
[~,st] = nearest_time(hl.XData(1),handles.time);
[~,fn] = nearest_time(hl.XData(2),handles.time);
if fn<st; tmp=st; st=fn; fn=tmp; end
if st==fn; fn=fn+1; end
x = handles.time(st:fn);
y1 = m * x + b;
%y2 = handles.(axtag)(st:fn);
ydata = get_ydata(handles,tag);
y2 = ydata(st:fn);

%interp to increase resolution
x2 = interpn(x,2);
y1 = interpn(y1,2); 
y2 = interpn(y2,2);
d =  y2./y1 - 1; %percent change

%if intersection (with some error), delete that segment
try
    [mn,imn] = min(abs(d));
    [~,imn] = nearest_time(x2(imn),handles.time);
    
    %if within some percent, delete this segment
    if mn<0.05
        axs = all_timeaxes(handles);
        ic = handles.manclass(imn);
        
        %figuer out where this segment starts and ends
        sel = handles.manclass==ic;
        if isrow(sel); sel = sel'; end
        dtmp = [0;diff(sel)];
        if imn==1 || ~sel(imn-1); st2 = imn;
        else st2 = find(dtmp(1:imn-1)==1,1,'last');
        end
        if imn==numel(sel) || ~sel(imn+1); fn2 = imn;
        else fn2 = find(dtmp(imn:end)==-1,1) + imn - 2;
        end
        if isempty(st2); st2 = 1; end
        if isempty(fn2); fn2 = numel(sel); end
        
        handles.manclass(st2:fn2) = 0;
        
        %update the plots
        for ii=1:numel(axs)
            tag = get(axs(ii),'Tag');
            hall = handles.hclass.(tag);
            for ih=1:numel(hall)
                if hall(ih)==0; continue; end
                yy = get(hall(ih),'Ydata');
                yy(st2:fn2) = nan;
                set(hall(ih),'YData',yy)
            end
        end
     
        handles.saved = 0;
    end
    
catch err
    throw(err)
end

%update
try, delete(hl); end
handles = garbage_collection(handles);
handles.bclassdel.Value = 0;
guidata(hObject,handles)

fred=1;


function tmpy = get_ydata(handles,tag)

if strcmp(tag,'axx'); tmpy = handles.x;
elseif strcmp(tag,'axy'); tmpy = handles.y;
else tmpy = handles.v;
end



function editSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to editSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSpeed as text
%        str2double(get(hObject,'String')) returns contents of editSpeed as a double
handles = toggleTimer('off',handles); 
speed = str2double(hObject.String);
per = 1./handles.fsample/speed;
if per<0.001; 
    handles.textwin.String = 'cant set speed faster than 0.001ms';
    speed = handles.fsample./(1/0.001);
end
handles.speed = speed;
handles.timer.Period = per;
handles = toggleTimer('on',handles); 
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function editSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes when selected object is changed in bgclass.
function bgclass_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgclass 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over bstop.
function pushbutton_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to bstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if hObject.Value==1
%     hObject.Value==0;
%     hObject.BackgroundColor=[1 1 1];
% else
%     hObject.Value=1;
% end


% --- Executes on mouse press over axes background.
function timeaxis_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%if we clicked in the axis, we want to pause
%bstop_Callback(hObject,eventdata,handles)

%if we're deleteing an object, then we dont want this functionality
if handles.bclassdel.Value
    return
end

%current pt
cp = get(gca,'CurrentPoint');
if isempty(handles.currentMouse)
    handles.currentMouse = eventdata.Button;
end

% if eventdata.Button==1 %left click
%     handles.classEndpoints(1) = cp(1);
% elseif eventdata.Button==3
%     handles.classEndpoints(2) = cp(1);
% end
handles = set_classEndpoints(handles,cp(1));
guidata(hObject,handles)

%check if we have both points, now we can classify
% if ~all(isnan([handles.classStart,handles.classEnd


% --- Executes on button press in bdiscard.
function varargout = bdiscard_Callback(hObject, eventdata, handles)
% hObject    handle to bdiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for ii=1:2
    if ~isnan(handles.hclassEndpoints{ii})
        delete(handles.hclassEndpoints{ii})
    end
    handles.hclassEndpoints{ii} = nan;
end
handles.classEndpoints = [nan nan];

if ~isempty(hObject)
    guidata(hObject,handles)
end

if nargout>0
    varargout{1} = handles;
end


% --- Executes on button press in bsave.
function bsave_Callback(hObject, eventdata, handles)
% hObject    handle to bsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bstop_Callback(handles.bstop,eventdata,handles);

%check path 
%savePath = '/Users/ben/Desktop/test_save.mat';
savePath = handles.savePath;
if strcmp(savePath(end),'/')
    handles.textwin.String = 'provide filename (with .mat)';
    guidata(hObject,handles)
    return
end
% ii = findstr(savePath,filesep);
% path = savePath(1:ii(end)-1);
% if ~exist(path)
%     handles.textwin.String = ['making directory: ' path];
%     mkdir(path)
% end
    
%check 
tmp = handles.processedGazeData.GazeData;
head = 'ManualClassification';
if ~ismember(head,tmp.Properties.VariableNames)
    tmp.(head) = nan(size(tmp,1),1);
end

%add what weve done so far
tmp.(head) = handles.manclass;
handles.processedGazeData.GazeData = tmp;
processedGazeData = handles.processedGazeData;
% subjectData = handles.subjectData;

%save it
disp('saving...')
handles.textwin.String = 'Saving...';
guidata(hObject,handles);

% 
try
    if 0 && exist(savePath,'file')~=0
        handles.textwin.String =...
            ['Appending to existing file: ' savePath];
        save(savePath,'processedGazeData','-append')
    else
        handles.textwin.String = ... 
            ['Saving new file file: ' savePath];
        save(savePath,'processedGazeData')
    end
    
    handles.saved = 1;
catch err
    display(err);
    handles.saved = 0;
end

disp('...saved')
handles.textwin.String = ['Saved: ' savePath];
guidata(hObject,handles);



function editSavepath_Callback(hObject, eventdata, handles)
% hObject    handle to editSavepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSavepath as text
%        str2double(get(hObject,'String')) returns contents of editSavepath as a double

savePath = hObject.String;
%should we update the savePath?
if numel(savePath)<4
    hObject.String = handles.savePath;
else
    if ~strcmp(savePath(end-3:end),'.mat')
        handles.textwin.String = 'added ".mat" extension';
        savePath = [savePath '.mat'];
    end
    hObject.String = savePath;
    handles.savePath = savePath;
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editSavepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSavepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check if work has been saved
if ~handles.saved
   b = questdlg('Work isnt saved. Continue exit??', ...
	'Warning', ...
	'yes','no','no');
   switch b
       case 'yes'
           done = 1;
       case 'no'
           done = 0;
   end
else 
    done = 1;
end
    
    
%close the figure
if done
    handles = toggleTimer('off',handles);
    delete(handles.timer);
    delete(handles.figure1)
end



% --- Executes on button press in bdelwin.
function bdelwin_Callback(hObject, eventdata, handles)
% hObject    handle to bdelwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%window
st = nearest(handles.time,handles.winst);
fn = nearest(handles.time,handles.winend);

% delete endpoints, classifications, plots
nans = isnan(handles.manclass);
handles.manclass(st:fn) = 0;
handles.manclass(nans) = nan;

handles = bdiscard_Callback(hObject, eventdata, handles); %delete an endpoints
     
ic = 1;
ax = handles.hclassified(ic,st:fn);
ax(isnan(ax)) = [];
ax = unique(ax);
ax(ax==0) = [];
for ii=1:numel(ax)
    sel = handles.hclassified(ic,:)==ax(ii);
    ax_all = handles.hclassified(:,sel); %get the other axes too 
    ax_all = unique(ax_all);
    handles.hclassified(:,sel) = nan;
    delete(ax_all)
end
handles.saved = 0;

%update
guidata(hObject,handles)


% --- Executes on button press in bresetaxes.
function bresetaxes_Callback(hObject, eventdata, handles)
% hObject    handle to bresetaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uizoomin_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uizoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in bshowsmooth.
function bshowsmooth_Callback(hObject, eventdata, handles)
% hObject    handle to bshowsmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bshowsmooth

if hObject.Value
    set(handles.hsmoothplot,'visible','on')
else
    set(handles.hsmoothplot,'visible','off')
end

guidata(hObject,handles)
    


% --- Executes on button press in banimate.
function varargout = banimate_Callback(hObject, eventdata, handles)
% hObject    handle to banimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of banimate
handles.animateGaze = hObject.Value;

if hObject.Value==1
    handles.anline.Visible = 'on';
    handles.nonanline.Visible = 'off';
else
    handles.anline.Visible = 'off';
    handles.nonanline.Visible = 'on';
end

if nargout==1
    varargout{1} = handles;
else
    guidata(hObject,handles)
end


% --- Executes on selection change in lskip.
function lskip_Callback(hObject, eventdata, handles)
% hObject    handle to lskip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lskip contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lskip

handles = toggleTimer('off',handles);
if any(hObject.Value==1) %selected none
    hObject.Value = 1;
    handles.skipToEvent = [];
else
    %gotta map the list options to the classification ID
    tmp = [];
    if any(hObject.Value==2) %fix
       tmp = [tmp,mapclass('fix')];
    end
    if any(hObject.Value==3) %sac
       tmp = [tmp,mapclass('sac')];
    end
    if any(hObject.Value==4) %sm
       tmp = [tmp,mapclass('sm')];
    end
    if any(hObject.Value==5) %sm
       tmp = [tmp,mapclass('wierd')];
    end
    handles.skipToEvent = tmp;
end
if handles.bplay.Value; handles = toggleTimer('on',handles); end

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function lskip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lskip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.currentMouse)
    timeaxis_ButtonDownFcn(hObject, eventdata, handles)
end
%disp(get(gcf,'selectiontype'))


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.currentMouse = [];
guidata(hObject,handles)


% --- Executes on button press in chresize.
function chresize_Callback(hObject, eventdata, handles)
% hObject    handle to chresize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chresize



%% subfunctions
function ind = nearest(x,v)

[~,ind] = min(abs(v-x));


% --- Executes on button press in bylim.
function bylim_Callback(hObject, eventdata, handles)
% hObject    handle to bylim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%choose the axis
groupTag = hObject.Parent.Tag;
if groupTag(3)=='x'
    ax = handles.axx;
    tmp = handles.x;
elseif groupTag(3)=='y'
    ax = handles.axy;
    tmp = handles.y;
elseif groupTag(3)=='v'
    ax = handles.axvel;
    tmp = handles.v;
else
    error('what axis?')
end

%update th ylim
ylim = get(ax,'ylim');
offset = (max(tmp)-min(tmp))*0.05;

if strcmp(groupTag(end-3:end),'down')
    ii = 1;
else
    ii = 2;
end

if strcmp(hObject.String,'v')
    ylim(ii) = ylim(ii) - offset;
elseif strcmp(hObject.String,'^')
    ylim(ii) = ylim(ii) + offset;
end

set(ax,'ylim',ylim)

guidata(hObject,handles)


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(src, evt, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



%disp(evt.Key)

%keys: https://docs.oracle.com/javase/7/docs/api/java/awt/event/KeyEvent.html

% if were classoifying and press the enter key, ends ginput
% if 0 %handles.classfying && strcmp(evt.Key,'return')
%     k = KeyEvent.VK_RETURN;
%     handles.robot.keyPress(k);
%     handles.robot.keyRelease(k);
% end

%MISC
% if strcmp(evt.Key,'return')
%     try
%         g = gco;
%         if strcmp(g.Style,'edit')
%             gco = handles.figure1;
%         end
%     end
% end

%play controls
if strcmp(evt.Key,'space')
    if handles.bstop.Value==1
        bplay_Callback(src, evt, handles);
        handles.bplay.Value = 1;

    elseif handles.bplay.Value==1
        bstop_Callback(src, evt, handles);
        handles.bstop.Value = 1;
    end
    guidata(src,handles)

end

if strcmp(evt.Key,'leftarrow'); 
    %handles.brew.Value = 1; 
    brew_Callback(src,evt,handles); 
end
if strcmp(evt.Key,'rightarrow'); 
    %handles.bfwd.Value = 1; 
    bfwd_Callback(src,evt,handles); 
end

%classification controls
if strcmp(evt.Key,'c')
    handles = bclass_Callback(src,evt,handles);
    guidata(src,handles)
end
if strcmp(evt.Key,'d')
    handles = bdiscard_Callback(src,evt,handles);
    guidata(src,handles)
end
% if strcmp(evt.Key,'backspace') %delete on mac
%     %error('huhuh')
%     bclassdel_Callback(src,evt,handles);
% end
if strcmp(evt.Key,'1'); 
    handles.bsac.Value = 1;
    bsac_Callback(src,evt,handles);
end
if strcmp(evt.Key,'2'); 
    handles.bfix.Value = 1;
    bfix_Callback(src,evt,handles);
end
if strcmp(evt.Key,'3'); 
    handles.bsm.Value = 1;
    bsm_Callback(src,evt,handles);
end

if strcmp(evt.Key,'4')
    handles.bwierd.Value = 1;
    bwierd_Callback(src,evt,handles)
end
