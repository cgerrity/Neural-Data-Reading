function TimePoint = cgg_getTrialTimePointFromFrameData(FrameData,FrameDescriptor,DescriptorPlace)
%CGG_GETTRIALTIMEPOINT Summary of this function goes here
%   Detailed explanation goes here

if isequal(FrameDescriptor,'Fixation')
    %%
Frame_Logical=strcmp(FrameData.TrialEpoch,'SelectObject');
Fixation_FrameData=FrameData(Frame_Logical,:);
GazeTarget=Fixation_FrameData.SimpleGazeTarget;

IsRel1=any(strcmp(GazeTarget,'rel1'));
IsRel2=any(strcmp(GazeTarget,'rel2'));
IsRel3=any(strcmp(GazeTarget,'rel3'));

if IsRel1||IsRel2||IsRel3
[GazeGrouping,GazeGroups]=findgroups(GazeTarget);

IsRel1=strcmp(GazeGroups,'rel1');
IsRel2=strcmp(GazeGroups,'rel2');
IsRel3=strcmp(GazeGroups,'rel3');

ObjectGroups=[find(IsRel1),find(IsRel2),find(IsRel3)];

TotalGroups=length(ObjectGroups);

GroupSection=NaN(length(GazeGrouping),TotalGroups);
NumGroups=NaN(1,TotalGroups);

TimePointCounter=1;
TimePoint=NaN;
for gidx=1:TotalGroups
    this_GazeGrouping=GazeGrouping==ObjectGroups(gidx);
    this_GazeGrouping(length(GazeGrouping))=true;
    this_GazeGrouping=imclose(this_GazeGrouping,ones(6,1));
    this_GazeGrouping=imopen(this_GazeGrouping,ones(3,1));
[GroupSection(:,gidx),NumGroups(gidx)] = bwlabel(this_GazeGrouping);
for nidx=1:NumGroups(gidx)
    Fixation_Logical=GroupSection(:,gidx)==nidx;
    Fixation_Indices=find(Fixation_Logical==1);
    
    if strcmp(DescriptorPlace,'START')
    Fixation_IDX=Fixation_Indices(1);
    else
    Fixation_IDX=Fixation_Indices(end);
    end
    TimePoint(TimePointCounter)=Fixation_FrameData.recTime(Fixation_IDX);
    TimePointCounter=TimePointCounter+1;
end
end
else
    TimePoint=NaN;
end

else
    if strcmp('ChoiceToFB',FrameDescriptor)
        Frame_Logical=strcmp(FrameData.TrialEpoch,FrameDescriptor);
        if ~(any(Frame_Logical))
            FrameDescriptor='Feedback';
        end
    end
    if strcmp('Reward',FrameDescriptor)
        Frame_Logical=strcmp(FrameData.TrialEpoch,FrameDescriptor);
        if ~(any(Frame_Logical))
            FrameDescriptor='Feedback';
        end
    end
    if strcmp('SelectObject',FrameDescriptor)
        Frame_Logical=strcmp(FrameData.TrialEpoch,FrameDescriptor);
        if ~(any(Frame_Logical))
            FrameDescriptor='Calibration';
            warning('FrameDescriptor:Nonexistent',['FrameDescriptor '...
                '(SelectObject) does not exist in this trial, '...
                'switching to (Calibration)']);
        end
        Frame_Logical=strcmp(FrameData.TrialEpoch,FrameDescriptor);
        if ~(any(Frame_Logical))
            FrameDescriptor='BaselineNoFix';
            warning('FrameDescriptor:Nonexistent',['FrameDescriptor '...
                '(Calibration) does not exist in this trial, '...
                'switching to (BaselineNoFix)']);
        end
    end
Frame_Logical=strcmp(FrameData.TrialEpoch,FrameDescriptor);    
Frame_Indices=find(Frame_Logical==1);

if strcmp(DescriptorPlace,'START')
    Frame_IDX=Frame_Indices(1);
else
    Frame_IDX=Frame_Indices(end);
end

TimePoint=FrameData.recTime(Frame_IDX);

end

end

