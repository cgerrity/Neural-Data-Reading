function lp = FindLp(outcome, lpType, varargin)
%can institute any Lp definitions we want, defined by first string in
%varargin

%outcome: vector, accuracy per trial
%lpType: string, identifies lp calculation to perform

%slidingwindow:
%looks for first correct trial where forward-looking sliding window acc is
%greater than some threshold.
%varargin: 1 = window size (integer), 2 = threshold
%(proportion correct)

%futureacc:
%looks for first correct trial where future accuracy is greater than
%threshold
%varargin: 1 = threshold (proportion correct)

%em:
%uses expentancy maximization function to find point where choices are
%reliably > chance

if strcmpi(lpType, 'slidingwindow')
    accForward = SlidingWindowForward(outcome,varargin{1});
    lp = find(accForward >= varargin{2} & outcome == 1 & (1:length(outcome))' <= (length(outcome) - varargin{1} + 1),1);
elseif strcmpi(lpType, 'futureacc')
    accForward = SlidingWindowForward(outcome,length(outcome));
    lp = find(outcome==1 & accForward > varargin{1},1);
    if length(outcome) - lp < 5
        lp = NaN;
    end
elseif strcmpi(lpType, 'em')
    M.Responses = outcome;
    M = get_learningCurveStat_01(M);
    lp = find(M.p05>0.5,1);
end

if isempty(lp)
    lp = NaN;
end