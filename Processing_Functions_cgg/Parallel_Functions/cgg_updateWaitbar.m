function cgg_updateWaitbar(Iteration_Count,All_Iterations,Current_Message,formatSpec)

%CGG_UPDATEWAITBAR Summary of this function goes here
%   Detailed explanation goes here

% Update global iteration count
Iteration_Count = Iteration_Count + 1;
% Get percentage for progress
Current_Progress=Iteration_Count/All_Iterations*100;
% Get the amount of time that has passed and how much remains
Elapsed_Time=seconds(toc); Elapsed_Time.Format='hh:mm:ss';
Remaining_Time=Elapsed_Time/Current_Progress*(100-Current_Progress);
Remaining_Time.Format='hh:mm:ss';
Current_Day=datetime('now','TimeZone','local','Format','MMM-d');
Current_Time=datetime('now','TimeZone','local','Format','HH:mm:ss');
% Generate deletion message to remove previous progress update. The
% '-1' comes from fprintf converting the two %% to one % so the
% original message is one character longer than what needs to be
% deleted.
Delete_Message=repmat(sprintf('\b'),1,length(Current_Message)-1);
% Generate the update message using the formate specification
% constructed earlier
Current_Message=sprintf(formatSpec,Current_Day,Current_Time,...
    Current_Progress,Elapsed_Time,Remaining_Time);
% Display the update message
fprintf([Delete_Message,Current_Message]);


assignin("base","Iteration_Count",Iteration_Count);
assignin("base","Current_Message",Current_Message);


end