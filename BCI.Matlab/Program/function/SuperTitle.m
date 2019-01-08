function [f,p] = SuperTitle(title,visible,picsize)
% Create a figure with super title
if nargin < 3
    picsize = [0.15 0.1 0.7 0.8];
    if nargin < 2
    visible = 'on';
    end
end
f = figure('WindowStyle','normal','Units','normalized','Position',picsize,'visible',visible);
p = uipanel('Parent',f,'BorderType','none'); 
p.Title = title; 
p.TitlePosition = 'centertop'; 
p.FontSize = 14;
p.FontName = 'Arial';
p.FontWeight = 'bold';
end