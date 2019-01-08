mydirect = 'C:\Users\labpc\Desktop\sasha\July2018\SynchronyBCI_Full_SJ2\Figures';
threshold = 18;
colour.player = [111 48 197; 65 158 33; 247 147 30]./255; % P1,P2,joint

colour.hz = [255 123 172;0 255 255;195 68 120;0 197 198;]./255; % right,up,left,down

% ---- Selectivity
h = figure;
ax2 = polaraxes;
ax2.ThetaTick = [0 90 180 270];
ax2.ThetaTickLabel = {'7 Hz';'11 Hz';'5 Hz';'9 Hz'};
ax2.RTick = threshold;
ax2.RLimMode = 'manual';
ax2.RLim = [0 100];
theta = [0 0 pi/2 pi/2];
ax2.NextPlot = 'replacechildren';

TIT ='Selectivity';
ax2.Title.String = TIT;



sel = [76 45;-10 -35];

cla
hold(ax2,'on')
for P = 1:2
    polarplot(ax2,theta,[0, sel(1,P),0, sel(2,P)],'Color',colour.player(P,:),'LineWidth',6-P)
end
legend({'P1';'P2'},'Location','northeast')
saveas(h,[mydirect TIT '.eps'],'epsc')
%% -------- direction
h = figure;
ax3 = polaraxes;
TIT = 'Direction';
ax3.Title.String = TIT;
ax3.ThetaTick = 0:45:315;
ax3.ThetaTickLabel = {'E';'NE';'N';'NW';'W';'SW';'S';'SE'};
ax3.RTick = [];
ax3.RLim = [0 15];
ax3.NextPlot = 'replacechildren';
hold on
cla
d = NaN(3,1);
feedbackSig = sel;
feedbackSig(abs(sel) < threshold)=0;

for P = 1:2
    d(P) = feedbackSig(1,P) + 1i*feedbackSig(2,P);
end

d(3) = mean(feedbackSig(1,:)) + 1i*mean(feedbackSig(2,:));

d = d .* 0.15;

for D = 1:3
    polarplot(ax3,[0, d(D)],'Color',colour.player(D,:),'LineWidth',3)
end
legend({'Solo P1';'Solo P2';'Joint'},'Location','northeast')
saveas(h,[mydirect TIT '.eps'],'epsc')

%% Signal
f = [3.5 5.5 2.5 4.5];
t = 0:1/144:1;
ctrl = {'right'; 'up';'left';'down'};

figure
for ii = 1:4
subplot(4,1,ii)
x = sign(sin(2*pi*f(ii)*t));
x(x==-1)=0;
plot(t,x,'LineWidth',3,'Color',colour.hz(ii,:))
ylim([-0.1 1.1])
xlim([0 1])
title(ctrl{ii})
yticks([])
xticks([])
end
