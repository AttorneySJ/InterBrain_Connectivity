load('G:\My Projects\MATLAB Projects\SynchronyBCI_Full_SJ2\Data\S21.18.Aug.24.10.15.54\S21.18.Aug.24.10.15.54.realtime.mat')
%% Connectivity Diagram
FS = fs/NumberOfScans; % sampling rate for selectivity scores
trialLen = min(trialM(:,[T.time1,T.time2]),[],2);
trialSeg = floor((trialLen - s.seg) .* FS);
%%
TRIAL = 9;
tmp = squeeze(rt.selectivity(1:trialSeg(TRIAL),:,TRIAL+n.trialsBlock,:)); % seg x dimension x player
    
nDP = size(tmp,1);
nbin = 1+round(log2(nDP));

dat = squeeze(tmp(:,1,:)) + 1i*squeeze(tmp(:,2,:)); % construct velocity vectors (seg x player)
dat(any(isnan(dat), 2), :) = []; % remove nan

ang_dat = angle(dat); % get movement direction
mag_dat = abs(dat); % get speed

CC1 = circ_corrcc(ang_dat(:,1), ang_dat(:,2));

angMI = mutualinformationx(ang_dat(:,1), ang_dat(:,2),nbin);
CC2 = angMI - (nbin - 1)^2 / ( 2*nDP*log(2) ); % correct for length

CC3 = corr(mag_dat(:,1), mag_dat(:,2),'rows','complete');

magMI = mutualinformationx(mag_dat(:,1), mag_dat(:,2),nbin);
CC4 = magMI - (nbin - 1)^2 / ( 2*nDP*log(2) ); % correct for length

%% Plot
TIT = 'Figure6_An exemplar of connectivity (Part1)';
picsize = [5 5 16 8];
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

for ii = 1:2
    pax = subplot(1,2,ii);
    ln = compass(pax,dat(3.5*FS,:));
    for P = 1:N.players
      ln(P).Color = colour.player(P,:);
      switch ii
          case 1
              ln(P).LineStyle = '--';
          case 2 
              ln(P).LineWidth = 2;
      end
    end
end

saveas(h,[direct.groupNow TIT '.png'])
close(h)
%%
TIT = 'Figure6_An exemplar of connectivity (Part2)';
picsize = [5 5 16 8];
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

for P = 1:N.players
   polaraxes(h,'OuterPosition',[(P-1)*0.5 0 0.5 1]) 
   polarhistogram(ang_dat(:,P),nbin,'FaceColor',colour.player(P,:),'FaceAlpha',.5);
   rlim([0 500])
end
%%
TIT = 'Figure6_An exemplar of connectivity (Part3)';
picsize = [5 5 16 8];
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

for P = 1:N.players
   ax(P) = subplot(1,2,P); 
   histogram(mag_dat(:,P),nbin,'FaceColor',colour.player(P,:),'FaceAlpha',.5);
   ylim([0 460])
end