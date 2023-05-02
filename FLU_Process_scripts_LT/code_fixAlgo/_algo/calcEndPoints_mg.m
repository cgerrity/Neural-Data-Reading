
function [startPoint, endPoint,peakVel,peakPoint] = calcEndPoints_mg(pos,fsample,p,startPad,endPad)
%input the total positions, and calculate the start, end and peak times and
%output them for later calculation of total distance, start position and
%end position
%and end points

if nargin<2
    fsample = 500;
end
if nargin<3
    p=0;
end

MainDirThresh = 20; %ben used 20
SampleChangeThresh = 20; %ben used 20
maxMainDirDeviation = max(ceil(fsample*0.006),3);
maxInconsistentSampleDir = max(ceil(fsample*0.008),3);
startPoint = NaN;
endPoint = NaN;
peakVel = NaN;
peakPoint = NaN;

% for stamp = 1:length(SacStart);
%         pos =SacStructInput(SacStart(stamp):SacEnd(stamp),:);p=1
%% deviation of main direction
 saccade = 1;
while saccade == 1
    DX = diff(pos(:,1));
    DY = diff(pos(:,2));
    Angle = atan2d(DY,DX)+180;
    vel = sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2) ./ diff(pos(:,3));
    
    %make sure peak isnt in the padded region
    unpad = startPad+1:numel(vel)-endPad-1;
    [peakVel,peak] = max(vel(unpad));
    peak = peak + startPad;
    if peakVel<50
        saccade = 0;
        continue
    end
    velThresh = max(peakVel*.2,30);
    
%     %dont know what this does, this is what ben did:
%     % peak<8||peak>length(pos)-20
%     % enforcing some sort of minimum padding?
%     %  - nope, just making sure peak isnt in pad sections
%     if peak<ceil(0.016*fsample)||peak>length(pos)-ceil(0.04*fsample)
%         saccade = 2;
%         continue
%     end
    
    % length(AngleStart)+length(AngleEnd)
    % length(pos)
    %calculate the main direction, which is the mean over three points at the
    %peak
    MainDir = meanangle(Angle(peak-1:peak+1));
    MainDir360 = MainDir+360;
    AngleStart = min(abs(Angle(1:peak)-MainDir),abs(Angle(1:peak)-MainDir360));
    AngleEnd = min(abs(Angle(peak:end)-MainDir),abs(Angle(peak:end)-MainDir360));
%     
%     AngleStart = min(mod(Angle(1:peak)-MainDir, 360),mod(MainDir - Angle(1:peak), 360));
%     AngleEnd = min(mod(Angle(peak:end)-MainDir,360),mod(MainDir - Angle(peak:end), 360));
   
    if p==1
        figure('position',[200 200 1500 800])
        subplot(2,3,1)
        plot(pos(2:end,1),pos(2:end,2),'b-',pos(2:end,1),pos(2:end,2),'bx','LineWidth',3)
        xlabel('Horizontal Eye Position X (deg)')
        ylabel('Vertical Eye Position Y (deg)')
        title('Eye Position on Screen')
        ax = gca;
            ax.FontSize = 16;

        subplot(2,3,2)
        
        
        plot(pos(2:end,1),'LineWidth',3)
        xlabel('Samples (2ms)')
        ylabel('X Position (deg)')
        title('Eye Position in X Axis Over Time')
        ax = gca;
            ax.FontSize = 16;
    end
    %initialize default values
    MainDirStart = NaN;
    MainDirEnd = NaN;
    %see if there are more than three samples where the direction is more than
    %60 deg different than the main direction
    if any(AngleStart>MainDirThresh)
        %calculate startpoint, either above the threshold for 6 ms, or
        %above 3 times the threshold once
        singleMainDirStart = max([find(AngleStart>(3*MainDirThresh),1,'last'),NaN]);
        tripleMainDirStart = max([peak-strfind([flipud(AngleStart>MainDirThresh)]',ones(1,maxMainDirDeviation)),NaN]);
        MainDirStart = max(tripleMainDirStart,singleMainDirStart);
        %check that this value is below 20% of the total velocity - should this
        %be below the OnsetThreshold? if it never goes below, then there is
        %a problem, and we can't characterize this saccade
        if ~isnan(MainDirStart) && vel(MainDirStart)>velThresh
            MainDirStart = find(vel(1:peak)<velThresh,1,'last');
            if isempty(MainDirStart)
                saccade = 0;
                continue
            end
        end
        if p==1 && ~isnan(MainDirStart)
            line([MainDirStart MainDirStart],[min(pos(:,1)-2),max(pos(:,1)+2)],'color','r','LineWidth',3)
        end
    end
    if any(AngleEnd>MainDirThresh)
        %calculate endpoint
        %         MainDirEnd = find(AngleEnd>MainDirThresh,1);
        singleMainDirEnd = min([find(AngleEnd>3*MainDirThresh,1),NaN]);
        tripleMainDirEnd = min([strfind([AngleEnd>MainDirThresh]',ones(1,maxMainDirDeviation)),NaN]);
        MainDirEnd = min(singleMainDirEnd,tripleMainDirEnd);
        if ~isnan(MainDirEnd) && MainDirEnd+peak>length(vel)
            vel = [vel;vel(end)];
        end
        if ~isnan(MainDirEnd)&& vel(MainDirEnd+peak)>velThresh 
            MainDirEnd = find(vel(peak:end)<velThresh,1);
            if isempty(MainDirEnd)
                saccade = 0;
                continue
            end
        end
        if p==1 && ~isnan(MainDirEnd)
            line([MainDirEnd+peak MainDirEnd+peak],[min(pos(:,1)-2),max(pos(:,1)+2)],'color','r','LineWidth',3)
        end
    end
    %% Inconsistent sample-to-sample direction
    SampleDirectionStart = min(abs(diff(Angle(1:peak))),...
        min(abs(diff(Angle(1:peak))-360),abs(diff(Angle(1:peak))+360)));
    SampleDirectionEnd = min(abs(diff(Angle(peak:end))),...
        min(abs(diff(Angle(peak:end))-360),abs(diff(Angle(peak:end))+360)));
    %initialize default values
    IncDirStart = NaN;
    IncDirEnd = NaN;
    %calculate the places where the sample to sample changes are above the
    %threshold
    if any(SampleDirectionStart>SampleChangeThresh)
        %
        singleIncDirStart = max([find(SampleDirectionStart>3*SampleChangeThresh,1,'last'),NaN]);
        tripleIncDirStart = max([peak-strfind([flipud(SampleDirectionStart>...
            SampleChangeThresh)]',ones(1,maxInconsistentSampleDir)),NaN]);
        IncDirStart = max(singleIncDirStart,tripleIncDirStart);
        if ~isnan(IncDirStart)&& vel(IncDirStart)>velThresh 
            IncDirStart = find(vel(1:peak)<velThresh,1,'last');
            if isempty(IncDirStart)
                saccade = 0;
                continue
            end
        end
        if p==1 &&~isnan(IncDirStart)
            line([IncDirStart IncDirStart],[min(pos(:,1)-2),max(pos(:,1)+2)],'color','g','LineWidth',3)
        end
    end
    if any(SampleDirectionEnd>SampleChangeThresh)
        singleIncDirEnd = max([find(SampleDirectionEnd>SampleChangeThresh*3,1),NaN]);
        tripleIncDirEnd = min([strfind([SampleDirectionEnd>SampleChangeThresh]',ones(1,maxInconsistentSampleDir)),NaN]);
        IncDirEnd = min(singleIncDirEnd,tripleIncDirEnd);
        if ~isnan(IncDirEnd) && IncDirEnd+peak>length(vel)
            vel = [vel;vel(end)];
        end
        
        if ~isnan(IncDirEnd) && vel(IncDirEnd+peak)>velThresh
            IncDirEnd = find(vel(peak:end)<velThresh,1);
            if isempty(IncDirEnd)
                saccade = 0;
                continue
            end
        end
        if p==1 && ~isnan(IncDirEnd)
            line([IncDirEnd+peak IncDirEnd+peak],[min(pos(:,1)-2),max(pos(:,1)+2)],'color','g','LineWidth',3)
        end
        
    end
    if p==1
        %% plot Y
        subplot(2,3,3)
        plot(pos(2:end,2),'LineWidth',3)
        xlabel('Samples (2ms)')
        ylabel('Position in Y Axis (deg)')
        title('Eye Position in Y Axis Over Time')
        if any(AngleStart>MainDirThresh)
            %calculate startpoint
            line([MainDirStart MainDirStart],[min(pos(:,2)-2),max(pos(:,2)+2)],'color','r','LineWidth',3)
        end
        if any(AngleEnd>MainDirThresh)
            %calculate endpoint
            line([MainDirEnd+peak MainDirEnd+peak],[min(pos(:,2)-2),max(pos(:,2)+2)],'color','r','LineWidth',3)
        end
        if any(SampleDirectionStart>SampleChangeThresh);
            line([IncDirStart IncDirStart],[min(pos(:,2)-2),max(pos(:,2)+2)],'color','g','LineWidth',3)
        end
        if any(SampleDirectionEnd>SampleChangeThresh)
            line([IncDirEnd+peak IncDirEnd+peak],[min(pos(:,2)-2),max(pos(:,2)+2)],'color','g','LineWidth',3)
        end
        ax = gca;
            ax.FontSize = 16;
        %% plot Velocity
        subplot(2,3,4)
        plot(vel,'LineWidth',3)
        xlabel('Samples (2ms)')
        ylabel('Angular Velocity of Eye Position (deg/s)')
        title('Angular Velocity of Eye Position Over Time')
        if any(AngleStart>MainDirThresh)
            line([MainDirStart MainDirStart],[min(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002-2),...
                max(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002+2)],'color','r','LineWidth',3)
        end
        if any(AngleEnd>MainDirThresh)
            line([MainDirEnd+peak MainDirEnd+peak],[min(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002-2),...
                max(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002+2)],'color','r','LineWidth',3)
        end
        if any(SampleDirectionStart>SampleChangeThresh);
            line([IncDirStart IncDirStart],[min(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002-2),...
                max(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002+2)],'color','g','LineWidth',3)
        end
        if any(SampleDirectionEnd>SampleChangeThresh)
            line([IncDirEnd+peak IncDirEnd+peak],[min(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002-2),...
                max(sqrt(diff(pos(:,1)).^2+diff(pos(:,2)).^2)/.002+2)],'color','g','LineWidth',3)
        end
        ax = gca;
             ax.FontSize = 16;
         ax.YLim(1) = 0;
        subplot(2,3,5)
        plot([AngleStart;AngleEnd],'r','LineWidth',3)
        xlabel('Samples (2ms)')
        ylabel({'Absolute Difference from','the Main Direction (deg)'})
        title({'Absolute Difference from the Main direction','of the Saccade Over Time'})
        ax = gca;
            ax.FontSize = 16;
            
        subplot(2,3,6)
        plot([SampleDirectionStart;SampleDirectionEnd],'g','LineWidth',3)
        xlabel('Samples (2ms)')
        ylabel({'Absolute Sample to Sample Change',' in Direction (deg)'})
        title({'Absolute Sample to Sample Change',' in Direction Over Time'})
        ax = gca;
            ax.FontSize = 16;
        subplot(2,3,1)
        
        hold on
        %draw a line for scale that is 2 degrees to the left of the saccade trace,
        %and 6 degrees along the y axis
        line([min(pos(:,1))-2 min(pos(:,1))-2],...
            [mean([max(pos(:,2)),min(pos(:,2))])-3 mean([max(pos(:,2)),min(pos(:,2))])+3],'LineWidth',3);
        colors = [0 1 0;1 0 0];
        scatter([pos(1,1),pos(end,1)],...
            [pos(1,2),pos(end,2)],100,colors,'d','LineWidth',3)
        if ~isnan(IncDirStart)&& ~isnan(IncDirEnd)
            scatter([pos(IncDirStart,1),pos(peak+IncDirEnd,1)],...
                [pos(IncDirStart,2),pos(peak+IncDirEnd,2)],10,'g','LineWidth',3)
        end
        if ~isnan(MainDirStart) && ~isnan(MainDirEnd)
            scatter([pos(MainDirStart,1),pos(peak+MainDirEnd,1)],...
                [pos(MainDirStart,2),pos(peak+MainDirEnd,2)],10,'r','LineWidth',3)
        end
         pause
        close
    end%other Plots, cancelled if p==0
    
    if isnan(MainDirStart) && isnan(IncDirStart)
        bad =1;
    else
        MainDirStart = MainDirStart+1;
        IncDirStart = IncDirStart+1;
        startPoint = pos(max(MainDirStart,IncDirStart),3);
    end
    peakPoint = pos(peak,3);
    
    if isnan(MainDirEnd) && isnan(IncDirEnd)
        bad = 2;
    else
        MainDirEnd = min(MainDirEnd+1+peak,length(pos));
        IncDirEnd = min(IncDirEnd+1+peak,length(pos));
        endPoint = pos(min(MainDirEnd,IncDirEnd),3);
    end
    if endPoint-startPoint<.01
        bad = 3;
    end
    saccade = 2;
    
    if endPoint-startPoint < 0.02
        xxx=1;
    end
end
end

%%



