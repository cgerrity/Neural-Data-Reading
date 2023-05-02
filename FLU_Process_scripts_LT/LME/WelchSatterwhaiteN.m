function df = WelchSatterwhaiteN(stds,ns)
% File name : 'WelchSatterwhaite.m'. This file can be used 
% for calculating the degrees of freedom  for a 
% Student's t-distribution according to the Welch-Satterwhaite equation
% 
% Four input values :   'std1', 'st2', 'n1', 'n2'
% One output value:     'df'
%
% stds:     Vector of standard deviations of groups
% ns:       Number of data points of groups
% df :      Degrees of freedom
%
% Developed by Joris Meurs BASc (2016)

% Limitations
if nargin < 2, error('Not enough input arguments');end
if nargin > 2, error('Too many input arguments');end
if sum(stds <= 0) > 0, error('Irregular value');end
if sum(ns <= 0) > 0, error('Irregular value');end
if length(stds) ~= length(ns), error('Different vector lengths');end

% Calculation
df1 = 0;
df2 = 0;

for i = length(stds)
    df1 = df1 + stds(i)^2/ns(i);
    df2 = df2 + stds(i)^4/(ns(i)^2*(ns(i)-1));
end
df = df1^2/df2;