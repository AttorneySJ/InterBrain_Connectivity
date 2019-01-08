function [ax] = APAaxis(ax)
set(ax,'FontName','Arial','FontSize',10, 'LabelFontSizeMultiplier',1,...
    'TitleFontSizeMultiplier',1.4,'TitleFontWeight','normal',...
    'TickDir','out','TickLength',[0.01 0.025]);
set(ax.XLabel,'FontWeight','bold');
set(ax.YLabel,'FontWeight','bold');
end

