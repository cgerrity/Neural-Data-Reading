function cgg_plotSignificanceBar(Bar_Plot,Error_Plot,SignificanceTable,varargin)
%CGG_PLOTSIGNIFICANCEBAR Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SignificanceFontSize = CheckVararginPairs('SignificanceFontSize', 6, varargin{:});
else
if ~(exist('SignificanceFontSize','var'))
SignificanceFontSize=6;
end
end

if isfunction
WantHorizontal = CheckVararginPairs('WantHorizontal', false, varargin{:});
else
if ~(exist('WantHorizontal','var'))
WantHorizontal=false;
end
end

if isfunction
YRange = CheckVararginPairs('YRange', [], varargin{:});
else
if ~(exist('YRange','var'))
YRange=[];
end
end

GroupNames = {Bar_Plot(:).DisplayName};
BarNames = string(Bar_Plot(1).XData);

Y_Small = 0.02;
Asterisk_Bump = Y_Small/SignificanceFontSize*1.75;

%%
hold on

if isempty(YRange)
    Plot_EndPoints = [Bar_Plot(:).YEndPoints];
    if WantHorizontal
        Plot_ErrorPoints = [Error_Plot(:).XPositiveDelta];
    else
        Plot_ErrorPoints = [Error_Plot(:).YPositiveDelta];
    end
    Plot_ErrorPoints(isnan(Plot_ErrorPoints)) = 0;
    Plot_Values = Plot_EndPoints + Plot_ErrorPoints;
    PlotRange = max(Plot_Values);
else
PlotRange = range(YRange);
end

Y_Small = Y_Small * PlotRange;
Asterisk_Bump = Asterisk_Bump * PlotRange;

%%
for sidx = 1:height(SignificanceTable)
%%

this_P_Value = SignificanceTable{sidx,"P Value"};
this_GroupName1 = SignificanceTable{sidx,"Group Name 1"};
this_GroupName1 = this_GroupName1{1};
this_BarName1 = SignificanceTable{sidx,"Bar Name 1"};
this_BarName1 = this_BarName1{1};
this_GroupName2 = SignificanceTable{sidx,"Group Name 2"};
this_GroupName2 = this_GroupName2{1};
this_BarName2 = SignificanceTable{sidx,"Bar Name 2"};
this_BarName2 = this_BarName2{1};

% IsSingleBar = isempty(this_GroupName1) || isempty(this_BarName1) || isempty(this_GroupName2) || isempty(this_BarName2);
% IsSignificant = this_P_Value < 0.05;

this_GroupIDX1 = ismember(GroupNames,this_GroupName1);
this_BarIDX1 = ismember(BarNames,this_BarName1);
this_GroupIDX2 = ismember(GroupNames,this_GroupName2);
this_BarIDX2 = ismember(BarNames,this_BarName2);

this_Bar1 = Bar_Plot(this_GroupIDX1);
this_Bar2 = Bar_Plot(this_GroupIDX2);

this_Error1 = Error_Plot(this_GroupIDX1);
this_Error2 = Error_Plot(this_GroupIDX2);

this_XEndPoints1 = cell2mat({this_Bar1(:).XEndPoints}');
this_XEndPoints2 = cell2mat({this_Bar2(:).XEndPoints}');

if ~isempty(this_XEndPoints1)
    X_Location1 = this_XEndPoints1(:,this_BarIDX1);
else
    X_Location1 = [];
end
if ~isempty(this_XEndPoints2)
    X_Location2 = this_XEndPoints2(:,this_BarIDX2);
else
    X_Location2 = [];
end

X_Location1 = mean(X_Location1);
X_Location2 = mean(X_Location2);

this_YEndPoints1 = cell2mat({this_Bar1(:).YEndPoints}');
this_YEndPoints2 = cell2mat({this_Bar2(:).YEndPoints}');

if WantHorizontal
this_YErrorPoints1 = cell2mat({this_Error1(:).XPositiveDelta}');
this_YErrorPoints2 = cell2mat({this_Error2(:).XPositiveDelta}');
else
this_YErrorPoints1 = cell2mat({this_Error1(:).YPositiveDelta}');
this_YErrorPoints2 = cell2mat({this_Error2(:).YPositiveDelta}');
end

this_YErrorPoints1(isnan(this_YErrorPoints1)) = 0;
this_YErrorPoints2(isnan(this_YErrorPoints2)) = 0;

if ~isempty(this_YEndPoints1) && ~isempty(this_YErrorPoints1)
    Y_Location1 = this_YEndPoints1(:,this_BarIDX1)+this_YErrorPoints1(:,this_BarIDX1);
else
    Y_Location1 = [];
end
if ~isempty(this_YEndPoints2) && ~isempty(this_YErrorPoints2)
    Y_Location2 = this_YEndPoints2(:,this_BarIDX2)+this_YErrorPoints2(:,this_BarIDX2);
else
    Y_Location2 = [];
end

NumBars1 = length(Y_Location1);
NumBars2 = length(Y_Location2);

% Y_Location1 = max(Y_Location1 + Y_Small);
% Y_Location2 = max(Y_Location2 + Y_Small);

Y_Location1 = max(Y_Location1);
Y_Location2 = max(Y_Location2);

% Max_Y_Location = max([Y_Location1,Y_Location2])+ Y_Small*(NumBars1^2 - 1);
Max_Y_Location = max([Y_Location1,Y_Location2]);
% Max_NumBars = max([NumBars1,NumBars2]);
Min_NumBars = min([NumBars1,NumBars2]);
%% Vertical

% this_X = [X_Location1,X_Location1];
% this_Y = [Y_Location1 + Y_Small*(NumBars1^2 - 1),Max_Y_Location + Y_Small];
% 
% plot(this_X,this_Y,"Color","k");
% 
% this_X = [X_Location2,X_Location2];
% this_Y = [Y_Location2 + Y_Small*(NumBars2^2 - 1),Max_Y_Location + Y_Small];
% 
% plot(this_X,this_Y,"Color","k");
if Min_NumBars > 0
this_X = [X_Location1,X_Location1];
this_Y = [Y_Location1 + Y_Small*(3*NumBars1-1),Max_Y_Location + Y_Small*(3*Min_NumBars)];

if WantHorizontal
plot(this_Y,this_X,"Color","k");
else
plot(this_X,this_Y,"Color","k");
end

this_X = [X_Location2,X_Location2];
this_Y = [Y_Location2 + Y_Small*(3*NumBars2-1),Max_Y_Location + Y_Small*(3*Min_NumBars)];

if WantHorizontal
plot(this_Y,this_X,"Color","k");
else
plot(this_X,this_Y,"Color","k");
end
end
%% Horizontal

% this_X = [X_Location1,X_Location2];
% this_Y = [Max_Y_Location + Y_Small,Max_Y_Location + Y_Small];
% 
% plot(this_X,this_Y,"Color","k");
if Min_NumBars > 0
this_X = [X_Location1,X_Location2];
this_Y = [Max_Y_Location + Y_Small*(3*Min_NumBars),Max_Y_Location + Y_Small*(3*Min_NumBars)];

if WantHorizontal
plot(this_Y,this_X,"Color","k");
else
plot(this_X,this_Y,"Color","k");
end
end
%% Astrerisk

this_X = mean([X_Location1,X_Location2],"omitmissing");
% this_Y = Max_Y_Location + Y_Small*2;
% this_Y = Max_Y_Location + Y_Small+Y_Small*(NumBars1+1/2);
this_Y = Max_Y_Location + Y_Small*(3*Min_NumBars+1) + Asterisk_Bump;

this_Text = string();

if this_P_Value < 0.05
    this_Text = this_Text + "\ast";
end
if this_P_Value < 0.01
    this_Text = this_Text + "\ast";
end
if this_P_Value < 0.001
    this_Text = this_Text + "\ast";
end
if this_P_Value < 0.0001
    this_Text = this_Text + "\ast";
end

if WantHorizontal
text(this_Y, this_X, this_Text,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',SignificanceFontSize,'Rotation',-90);
else
text(this_X, this_Y, this_Text,'HorizontalAlignment','center','VerticalAlignment','middle','FontSize',SignificanceFontSize);
end
end
hold off
end

