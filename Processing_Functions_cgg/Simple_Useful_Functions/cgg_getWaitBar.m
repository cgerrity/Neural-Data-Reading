classdef cgg_getWaitBar < handle
    %CGG_GETWAITBAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        All_Iterations
        Iteration_Count
        Current_Progress
        Elapsed_Time
        Remaining_Time
        Current_Day
        Current_Time
        DisplayFormat
        DisplayIndents
        Current_Message
        Tic_Counter
        Queue
        NoDesktop
        NoDesktop_Progress
        NoDesktop_Progress_Threshold
    end

    properties (SetAccess = immutable, GetAccess = private, Transient)
        Listener = [] % (event.listener) Listener for DataQueue updates.
    end
    
    methods
        function waitbar = cgg_getWaitBar(args)
            %CGG_GENERATEWAITBAR Construct an instance of this class
            %   Detailed explanation goes here
            % Parse inputs
            arguments
                args.All_Iterations (1,1) {mustBeInteger} = 0
                args.Process (1,:) string {} = "-" 
                args.DisplayIndents (1,1) {mustBeInteger} = 0
                % name (1,1) string
                % InputSize
                % SplitDimension
                % args.NumNewSplits (1,1) {mustBeInteger} = 0
                % args.OutputNames (1,:) string {} = "-" 
                % Probably a better way to do this than "-"
            end
            %% Update Information Setup

% Set the number of iterations for the loop.
% Change the value of All_Iterations to the total number of iterations for
% the proper progress update. Change this for specific uses
%                VVVVVVV
waitbar.All_Iterations = args.All_Iterations; %<<<<<<<<<
%                ^^^^^^^
% Iteration count starts at 0... seems self explanatory ¯\_(ツ)_/¯
waitbar.Iteration_Count = 0;
% Initialize the time elapsed and remaining
waitbar.Elapsed_Time=seconds(0); waitbar.Elapsed_Time.Format='hh:mm:ss';
waitbar.Remaining_Time=seconds(0); waitbar.Remaining_Time.Format='hh:mm:ss';
waitbar.Current_Day=datetime('now','TimeZone','local','Format','MMM-d');
waitbar.Current_Time=datetime('now','TimeZone','local','Format','HH:mm:ss');
waitbar.Current_Progress=waitbar.Iteration_Count/waitbar.All_Iterations*100;
% Sometimes the display is more readable if it has an indent. This value
% will porvide a number of indents to make it more readable
waitbar.DisplayIndents = args.DisplayIndents;
IndentFormat = repmat(sprintf(' '),1,waitbar.DisplayIndents);
% This is the format specification for the message that is displayed.
% Change this to get a different message displayed. The % at the end is 4
% since sprintf and fprintf takes the 4 to 2 to 1. Use 4 if you want to
% display a percent sign otherwise remove them (!!! if removed the delete
% message should no longer be '-1' at the end but '-0'. '\n' is 
%            VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
formatSpec = [IndentFormat, '=== Current [%%s at %%s] %s Progress is: %%.2f%s\n', IndentFormat, '=== Time Elapsed: %%s, Estimated Total Time: %%s, Estimated Time Remaining: %%s\n']; %<<<<<
formatSpec = sprintf(formatSpec,args.Process,'%%%%');
waitbar.DisplayFormat = formatSpec;
%            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

% Get the message with the specified percent
waitbar.Current_Message=sprintf(waitbar.DisplayFormat,waitbar.Current_Day,waitbar.Current_Time,0,waitbar.Elapsed_Time,'N/A','N/A');
% Display the message
fprintf(waitbar.Current_Message);
waitbar.Tic_Counter = tic;

%%
waitbar.NoDesktop = ~usejava('desktop');
waitbar.NoDesktop_Progress = 0;
waitbar.NoDesktop_Progress_Threshold = 20;
%%
        % Setting up the DataQueue to receive messages during the parfor loop and
        % have it run the update function
        waitbar.Queue = parallel.pool.DataQueue;
        % waitbar.Queue.afterEach(@(x) waitbar.nUpdateWaitbar(x));
        waitbar.Listener = waitbar.Queue.afterEach(@(x) waitbar.nUpdateWaitbar(x));
        % q = parallel.pool.DataQueue;
        % afterEach(q, @(x) waitbar.nUpdateWaitbar(x));
        % waitbar.Queue = q;
        % gcp;
        end
        
        % function outputArg = method1(obj,inputArg)
        %     %METHOD1 Summary of this method goes here
        %     %   Detailed explanation goes here
        %     outputArg = obj.Property1 + inputArg;
        % end

        function nUpdateWaitbar(waitbar,~)
        % Update global iteration count
        waitbar.Iteration_Count = waitbar.Iteration_Count + 1;
        % Get percentage for progress
        waitbar.Current_Progress=waitbar.Iteration_Count/waitbar.All_Iterations*100;
        % Get the amount of time that has passed and how much remains
        waitbar.Elapsed_Time=seconds(toc(waitbar.Tic_Counter)); waitbar.Elapsed_Time.Format='hh:mm:ss';
        waitbar.Remaining_Time=waitbar.Elapsed_Time/waitbar.Current_Progress*(100-waitbar.Current_Progress);
        waitbar.Remaining_Time.Format='hh:mm:ss';
        Total_Time = waitbar.Elapsed_Time + waitbar.Remaining_Time;
        waitbar.Current_Day=datetime('now','TimeZone','local','Format','MMM-d');
        waitbar.Current_Time=datetime('now','TimeZone','local','Format','HH:mm:ss');
        % Generate deletion message to remove previous progress update. The
        % '-1' comes from fprintf converting the two %% to one % so the
        % original message is one character longer than what needs to be
        % deleted.
        Delete_Message=repmat(sprintf('\b'),1,length(waitbar.Current_Message)-1);
        WaitBarUpdate = true;
        if waitbar.NoDesktop
            % If terminal is used, use ANSI codes to move cursor.
            %system('tput cuu1;tput el');
            % system('printf "\033[1A"'); % Move cursor up.
            % system('printf "\033[K"'); % Erase line.
            % system('printf "\033[1A"'); % Move cursor up.
            % system('printf "\033[K"'); % Erase line.
            waitbar.NoDesktop_Progress = waitbar.NoDesktop_Progress + (1/waitbar.All_Iterations)*100;
            if waitbar.NoDesktop_Progress >= waitbar.NoDesktop_Progress_Threshold
                WaitBarUpdate = true;
                waitbar.NoDesktop_Progress = waitbar.NoDesktop_Progress - waitbar.NoDesktop_Progress_Threshold;
            elseif waitbar.Iteration_Count == waitbar.All_Iterations
                WaitBarUpdate = true;
            elseif waitbar.Iteration_Count == 1
                WaitBarUpdate = true;
            else
                WaitBarUpdate = false;
            end
            Delete_Message = '';
        else
            % If desktop is used, print backspaces to rewind the cursor.
            % fprintf(Delete_Message);
        end
        % Generate the update message using the formate specification
        % constructed earlier
        waitbar.Current_Message=sprintf(waitbar.DisplayFormat,waitbar.Current_Day,waitbar.Current_Time,...
            waitbar.Current_Progress,waitbar.Elapsed_Time,Total_Time,waitbar.Remaining_Time);
        % Display the update message
        % fprintf([Delete_Message,waitbar.Current_Message]);
        if WaitBarUpdate
        fprintf([Delete_Message,waitbar.Current_Message]);
        end

        if waitbar.Iteration_Count == waitbar.All_Iterations
            delete(waitbar);
        end
        end

        function update(waitbar)
            waitbar.Queue.send(1);
        end

        function delete(waitbar)
            % If UseQueue=true, delete queue and listener. If UseQueue=false, delete temporary update file.
                delete(waitbar.Listener);
                delete(waitbar.Queue);
        end

        % function waitbar = setupListenter(waitbar)
        % % Setting up the DataQueue to receive messages during the parfor loop and
        % % have it run the update function
        % q = parallel.pool.DataQueue;
        % afterEach(q, @(x) waitbar.nUpdateWaitbar(x));
        % waitbar.Queue = q;
        % gcp;
        % end
        % function waitbar = ParallelUpdate(waitbar)
        %     q = waitbar.Queue;
        %     send(q, waitbar);
        % end
    end
end

