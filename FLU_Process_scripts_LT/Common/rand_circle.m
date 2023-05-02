function [x,y] = rand_circle(N,R)
% [x,y] = rand_circle(N)
% [x,y] = rand_circle(N,R)
%
%generates N random points on a circle, with radius R (default==1)

if nargin<2
    R = 1;
end

th = rand(1,N)*2*pi; %random angles
x = R.*sin(th);
y = R.*cos(th);

