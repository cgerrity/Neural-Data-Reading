function set_bigfig(f,ratio)
%set_bigfig
%set_bigfig(f)
%set_bigfig(f,[widthRatio,lengthRatio])

if nargin<1 || isempty(f); f=gcf; end
if nargin<2 || isempty(ratio); ratio = [1 1]; end
   
sz = get(0,'screensize');
sz(3:4) = sz(3:4) .* ratio;
set(f,'position',sz);
set(f, 'PaperPositionMode', 'auto');