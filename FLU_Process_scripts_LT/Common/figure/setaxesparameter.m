function setaxesparameter(varargin)
% setaxesparameter(parameter)
% setaxesparameter(h,parameter)
% setaxesparameter(h,parameter,newval)
%
% if h is empty, then plots into all current axes

%assign inputs
if all( ishandle(varargin{1}(:)) ) || isempty(varargin{1})
    h = varargin{1};
    varargin(1) = [];
else
    h = [];
end

parameter = varargin{1};
if numel(varargin)>1; newval = varargin{2};
else newval = [];
end

if isempty(h); h = findobj(gcf,'type','axes'); end
h = h(:);

%get currentvalue
vals1 = get(h,parameter);

%set value
if any( strcmp(parameter,{'ylim','xlim','clim','zlim'}) )
    %disp( ['calculating ' parameter] )
    %get new value
    if ~isempty(newval)
        vals2 = newval;
    else
        if numel(h) > 1
            mn = min( cellfun(@min,vals1) );
            mx = max( cellfun(@max,vals1) );

            vals2 = [mn, mx];
        else
            vals2 = vals1;
        end
    end
    
    %set new value
    %disp( ['New ' parameter ': ' mat2str(vals2)] )
    set(h,parameter,vals2)
else
    error(['this parameter not coded for: ' parameter])
end
        