function equalize_scale(ax)
% equalize_scale()
% equalize_scale(ax)
%
% scales the smaller axis to match the larger one

if nargin < 1
    ax = gca;
end

xlim = get(ax,'xlim');
ylim = get(ax,'ylim');
dx = diff(xlim);
dy = diff(ylim);
dd = abs(dx-dy);

if dd>0
    pad = dd/2;
    if dx < dy
        xlim = xlim + [-pad pad];
        set(ax,'xlim',xlim)
    elseif dy 
        ylim = ylim + [-pad pad];
        set(ax,'ylim',ylim)
    end

end