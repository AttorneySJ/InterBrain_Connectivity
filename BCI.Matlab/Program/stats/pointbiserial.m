function [r,h,p,ci] = pointbiserial(d,x,tail,alpha)
if nargin < 3
    tail = [];
end

if nargin < 4
    alpha = 0.5;
end
n = length(d);

% Lengths of groups 0 and 1
n1 = sum(d);
n0 = sum(~d);
if(n0==0)
    error('There are no data with x=0!');
elseif(n1==0)
    error('There are no data with x=1!');
end

% Mean of groups 0 and 1
x1 = mean(x(d));
x0 = mean(x(~d));
sx  = std(x);

% Correlation coefficient
r = (x1-x0)/sx*sqrt (n0*n1/n^2);

if(isempty(tail))
    [h,p,ci] = ttest2(x(d),x(~d));
elseif(strcmp(tail,'np'))
    [p,h,ci] = ranksum(x(d),x(~d),alpha);    
else
    [h,p,ci] = ttest2(x(d),x(~d),alpha,tail);    
end