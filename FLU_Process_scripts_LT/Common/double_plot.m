function [p1,p2] = double_plot(t,z)
% [p1,p2] = double_plot(t,z)
%
% plot the single points and connectedlines individually

mk = 10;

p1 = plot(t,z,'-');
c = get(p1,'color');
hold all
p2 = plot(t,z,'.','markersize',mk,'color',c);