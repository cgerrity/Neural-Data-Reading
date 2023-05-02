%path = '/Volumes/DATA_21/DATA_MG/Data-postReplay_copy';
path = '/Volumes/DATA_65/Data-postReplay_copy';
files = dir([path '/*Monkey*']);

savepath = '/users/ben/desktop/eye_discrepancy3';
if ~exist(savepath); mkdir(savepath); end

[screenX,screenY,fsample] = get_experiment_parameters('tx300');

%stuff to store data
% ctr_left = linspace(-30,30,1000);
% ctr_right = linspace(-30,30,1000);
% ctr_diff = linspace(-10,10,1000);

ctr_left = linspace(-0.5,0.5,1000);
ctr_right = linspace(-0.5,0.5,1000);
ctr_diff = linspace(-0.5,0.5,1000);

% ctr_left = 1000;
% ctr_right = 1000;
% ctr_diff = 1000;

if 1
    dat_all = [];

    for id=1:numel(files)

        try
            name = files(id).name;
            disp(name)
            str = [path '/' name '/ProcessedData/' name '__SubjectDataStruct.mat'];
            load(str);

            gaze = subjectData.ProcessedEyeData.GazeData;
            eyeIn = subjectData.Runtime.RawGazeData;
            t = eyeIn.device_time_stamp;

           %get data
            xleft = eyeIn.left_gaze_point_on_display_area(:,1);
            yleft = eyeIn.left_gaze_point_on_display_area(:,2);
            dleft = eyeIn.left_gaze_origin_in_user_coordinate_system(:,3);
            xright = eyeIn.right_gaze_point_on_display_area(:,1);
            yright = eyeIn.right_gaze_point_on_display_area(:,2);
            dright = eyeIn.right_gaze_origin_in_user_coordinate_system(:,3);

            % unsampled
            bad = xleft==-1 | xright==-1 | yleft==-1 | yright==-1;
            xleft(bad) = nan;
            yleft(bad) = nan;
            xright(bad) = nan;
            yright(bad) = nan;

            %convert to degrees
%             d = nanmean([smoothDistance(dleft,fsample), smoothDistance(dright,fsample)]);
%             [xleft,yleft] = acds2dva(xleft,yleft,smoothDistance(dleft,fsample),screenX,screenY);
%             [xright,yright] = acds2dva(xright,yright,smoothDistance(dright,fsample),screenX,screenY);

            % mean centre acds
            xleft = xleft - 0.5;
            xright = xright - 0.5;
            yleft = yleft - 0.5;
            yright = yright - 0.5;
            
            dx = xleft-xright;
            dy = yleft-yright;

%             %cull a bit for visualization
%             dx(abs(dx)>0.5) = []; %acds
%             dy(abs(dy)>0.5) = [];
%             xthresh = pos2dva(screenX/2,nanmean(d));
%             ythresh = pos2dva(screenY/2,nanmean(d));
            xthresh = 0.5;
            ythresh = 0.5;
            xbad = abs(dx) > xthresh | abs(xleft) > xthresh | abs(xright) > xthresh;
            ybad = abs(dy) > ythresh | abs(yleft) > ythresh | abs(yright) > ythresh;
            xleft(xbad) = [];
            xright(xbad) = [];
            dx(xbad) = [];
            yleft(ybad) = [];
            yright(ybad) = [];
            dy(ybad) = [];


            %mean centre
            dx = dx-nanmean(dx);
            dy = dy-nanmean(dy);


            %plot
            figure('name',name)
            nr=3; nc=2;
            axstr = {'x','y'};
            idat = size(dat_all,1)+1;
            for ix=1:2
                if ix==1; 
                    tmpl = xleft;
                    tmpr = xright;
                    tmpd = dx;
                else
                    tmpl = yleft;
                    tmpr = yright;
                    tmpd = dy;
                end

                ns = ix;
                subplot(nr,nc,ns)
                [N,C] = hist(tmpl,ctr_left);
                dat_all(idat,:,ix,1) = N ./ sum(N);
                bar(C,N ./ sum(N))
                title([axstr{ix} ' left'])
                grid minor
                set(gca,'xlim',[ctr_left(1), ctr_left(end)])

                ns = ix+nc;
                subplot(nr,nc,ns)
                [N,C]=hist(tmpr,ctr_right);
                dat_all(idat,:,ix,2) = N ./ sum(N);
                bar(C,N ./ sum(N))
                title([axstr{ix} ' right'])
                grid minor
                set(gca,'xlim',[ctr_right(1), ctr_right(end)])

                ns = ix+nc*2;
                subplot(nr,nc,ns)
                [N,C]=hist(tmpd,ctr_diff);
                dat_all(idat,:,ix,3) = N ./ sum(N);
                bar(C,N ./ sum(N))
                title([axstr{ix} 'left - ' axstr{ix} 'right'])
                grid minor
                set(gca,'xlim',[ctr_diff(1), ctr_diff(end)])

            end

            set_bigfig(gcf,[0.7 0.7])
            fooo=1;

            %save
            sname = [savepath '/' name '_eyeDiscrepancy'];
            print(sname,'-dpng')
            close(gcf)

        end
    end
    
end

% plot all
axtsr = {'x','y'};
for ix=1:2
    for ii=1:3
        if ii==1; 
            c = ctr_left;
            str = 'left (deg)';
        elseif ii==2; 
            c = ctr_right;
            str = 'right (deg)';
        else
            c = ctr_diff;
            str = 'diff (left-right)';
        end
        
        tmp = dat_all(:,:,ix,ii)';
        xx=repmat(ctr_diff,size(dat_all,1),1)';
        
        figure
        plot(xx,tmp)
        ylabel('prop')
        xlabel('bin centre')
        str2 = sprintf('%s - %s',axstr{ix},str);
        title(str2)
        set(gca,'fontsize',15)
        axis square
        plotcueline('x',0)
        
        set_bigfig(gcf,[0.5,0.9])
        sname = [savepath '/summary_' axstr{ix} str(1:4)];
        print(sname,'-dpng')
    end
end