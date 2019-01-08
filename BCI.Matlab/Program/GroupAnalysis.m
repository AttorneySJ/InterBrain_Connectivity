clear
addpath('function','stats','analysis')
addpath('..\CommonMatlabFunctions\RealtimeToolbox\gtecTopo')
direct.group = '..\Group\';
load([direct.group 'groupData.mat'])
load('common.mat')
%% Make Results Folder
nPair = length(GD_LoHi);
direct.groupRes = [direct.group 'GroupResults\'];
mkdir(direct.groupRes)
%% FFT & topography
% FFT
FFT = permute(GD_Baseline_FFT(:,:,:,:),[1 4 2 3]);
STFT = permute(GD_Baseline_STFT(:,:,:,:),[1 4 2 3]);
FFT = reshape(FFT,nPair*N.players,length(freq.trial),n.Hz);
STFT = reshape(STFT,nPair*N.players,length(freq.seg),n.Hz);

FFT_avg = squeeze(mean(FFT,'omitnan')); % amp x Hz
STFT_avg = squeeze(mean(STFT,'omitnan')); % amp x Hz

picsize = [5 5 13 10];
TIT = 'FFT';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

ax1 = subplot(2,1,1,'Parent',h);
hold on
for HH = 1:n.Hz
    pl = plot(freq.trial,FFT_avg(:,HH),'LineWidth',1,'Color',colour.flicker(HH,:));
    if ceil(HH/2)==1
        pl.LineStyle = '--';
    end
    text(Hz.fundamental(HH), FFT_avg(idx.freqTrial(HH,1),HH), str.Hz{HH}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', 'color', 'k' )
end
ylabel('FFT Amplitude (\muV)','FontWeight','bold')
legend(str.checkerboardPos,'Location','northeast')

ax2 = subplot(2,1,2,'Parent',h);
hold on
for HH = 1:n.Hz
    pl = plot(freq.seg,STFT_avg(:,HH),'LineWidth',3-ceil(HH/2),'Color',colour.flicker(HH,:));
    if ceil(HH/2)==1
        pl.LineStyle = '--';
    end
    text(Hz.fundamental(HH), STFT_avg(idx.freqSeg(HH,1),HH), str.Hz{HH}, 'horizontalalignment', 'center', 'verticalalignment', 'bottom', 'color', 'k' )
end
ylabel('FFT Amplitude (\muV)','FontWeight','bold')

linkaxes([ax1 ax2],'x')
xlim([1 23])
xlabel('Frequency (Hz)','FontWeight','bold')
legend(str.checkerboardPos,'Location','northeast')
APAaxis(ax1);APAaxis(ax2);

saveas(h,[direct.groupRes TIT '.png'])
close(h)

% Topography
TIT = 'Topography';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

Head = permute(GD_Baseline_Head,[1 4 2 3]);
Head = reshape(Head,nPair*N.players,n.Hz,N.channelPlayer);
Head_avg = squeeze(mean(Head,'omitnan'));
c_min = min(Head_avg(:));
c_max = max(Head_avg(:));
zoom.x = [681  1107];
zoom.y = [127  517];
Hzorder = [1 3 2 4];

for HH = 1:n.Hz
    subplot(1,4,Hzorder(HH),'Parent',h)
    c = Head_avg(Hzorder(HH),1:N.channelsOIPlayer);
    hc = gtecTopo( c, gtecChanlocs, 'on', 1:4, flipud(colormap('hot')), [c_min, c_max], 5, zoom );
    if HH~=n.Hz
        delete(hc)
    else
        hc.Ticks = [c_min c_max];
        hc.TickLabels = [round(c_min,2),round(c_max,2)];
        hc.Location = 'east';
    end
    title(str.checkerboardPos{HH})
end

% saveas(h,[direct.groupRes TIT '.png'])
close(h)

GR_SNR = squeeze(mean(GD_Baseline_SNR,1,'omitnan'));
GR_SNR = mean(GR_SNR,2);
%% Baseline Accuracy
BaselineOfflineAnalysis

%% Behavioural Outcomes
BehaviouralAnalysis
TrajectoryAnalysis

%% Connectivity Outcomes
ConnectivityAnalysis

%% Save
disp('-------- saving group results ---------')
save([direct.groupRes 'groupResults.mat'],'GR*');