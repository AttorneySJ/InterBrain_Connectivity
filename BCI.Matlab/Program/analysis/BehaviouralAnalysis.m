%% Figure 3: Behavioural Performance
Success = reshape(GD_Test_success,nPair,n.testTrials/n.taskType,N.players+1);
Success = squeeze(sum(Success,2));
Success = Success./(n.testTrials/n.taskType).*100;

Time = reshape(GD_Test_time,nPair,n.testTrials/n.taskType,N.players+1);
Time(Time>20)=NaN;
Time = squeeze(mean(Time,2,'omitnan'));
%%
picsize = [5 5 9 16];
TIT = 'Results_Behaviour';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

% 1) Success Rate
ax = subplot(2,1,1);
ctrs = 1:N.players+1;
Success_avg = mean(Success);
Success_std = std(Success)./sqrt(nPair);
bar(ctrs,Success_avg,'FaceColor','flat','CData',colour.player);
hold on
errorbar(ctrs,Success_avg,Success_std, '.k','LineWidth',2)

ylim([0 100])
xlim([0.5 3.5])
xticks(1:3)
xticklabels(str.control)
ylabel('Success Rate (%)')
APAaxis(ax);
box off

% Stats (One-way repeated-measures ANOVA, IV: control, DV: success rate)
DV = Success;
IV = table(categorical(str.control),'VariableNames',{'control'});
tab = table(DV(:,1),DV(:,2),DV(:,3),'VariableNames',{'LP','HP','Pair'});
rm = fitrm(tab,'LP-Pair~1','WithinDesign',IV);

% ANOVA
GR_success.statstbl = grpstats(rm,'control',{'mean','std',@skewness,@kurtosis});
GR_success.sphericity = mauchly(rm);
GR_success.ranovatbl = ranova(rm);
GR_success.eta = GR_success.ranovatbl{1,1}/sum(GR_success.ranovatbl{:,1});
% Multiple Comparison
[~,GR_success.L_P.p,~, GR_success.L_P.t] = ttest(Success(:,1),Success(:,3));
[~,GR_success.H_P.p,~, GR_success.H_P.t] = ttest(Success(:,2),Success(:,3));

% 2) Time
ax = subplot(2,1,2);
Time_avg = mean(Time,'omitnan');
Time_std = std(Time,'omitnan')./sqrt(nPair);

bar(ctrs,Time_avg,'FaceColor','flat','CData',colour.player);
hold on
errorbar(ctrs,Time_avg,Time_std, '.k','LineWidth',2)
xlim([0.5 3.5])
xticks(1:3)
xticklabels(str.control)
ylim([8 14])
ylabel('Movement Time (s)')
xlabel('BCI Control')
APAaxis(ax);
box off

% Stats (One-way repeated-measures ANOVA, IV: control, DV: movement time)
DV = Time;
tab = table(DV(:,1),DV(:,2),DV(:,3),'VariableNames',{'LP','HP','Pair'});
rm = fitrm(tab,'LP-Pair~1','WithinDesign',IV);

% ANOVA
GR_Time.statstbl = grpstats(rm,'control',{'mean','std',@skewness,@kurtosis});
GR_Time.sphericity = mauchly(rm);
GR_Time.ranovatbl = ranova(rm);
GR_Time.eta = GR_Time.ranovatbl{1,1}/sum(GR_Time.ranovatbl{:,1});
% Multiple Comparison
[~,GR_Time.L_P.p,~, GR_Time.L_P.t] = ttest(Time(:,1),Time(:,3));
[~,GR_Time.H_P.p,~, GR_Time.H_P.t] = ttest(Time(:,2),Time(:,3));
%%
saveas(h,[direct.groupRes TIT '.png'])
close(h)