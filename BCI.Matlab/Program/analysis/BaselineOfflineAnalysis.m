GR_SNR_byC = squeeze(mean(GD_Baseline_SNR,2)); % SNR by control
GR_SNR_byP = squeeze(mean(GD_Baseline_SNR,3)); % SNR by cued position

Accuracy_byC = squeeze(mean(GD_Baseline_Accuracy.*100,2));
Accuracy_byP = squeeze(mean(GD_Baseline_Accuracy.*100,3));
DV = GD_Baseline_Accuracy.*100;
DV = reshape(DV,nPair,[]);
IV1 = repelem(categorical(str.control),n.checkerboardPos);
IV2 = repmat(categorical(str.checkerboardPos'),N.players+1,1);
IV = table(IV1,IV2,'VariableNames',{'control','checkerboardPos'});
tab = array2table(DV);
rm = fitrm(tab,'DV1-DV12~1','WithinDesign',IV);

% ANOVA
GR_accuracy.mainControl = grpstats(rm,'control',{'mean','std',@skewness,@kurtosis});
GR_accuracy.mainCue = grpstats(rm,'checkerboardPos',{'mean','std',@skewness,@kurtosis});
GR_accuracy.cellstats = grpstats(rm,{'control','checkerboardPos'},{'mean','std',@skewness,@kurtosis});
GR_accuracy.sphericity = mauchly(rm);
GR_accuracy.ranovatbl = ranova(rm,'WithinModel','control+checkerboardPos+control*checkerboardPos');
GR_accuracy.eta = [GR_accuracy.ranovatbl{3,1}/sum(GR_accuracy.ranovatbl{3:4,1}),...
    GR_accuracy.ranovatbl{5,1}/sum(GR_accuracy.ranovatbl{5:6,1}),...
    GR_accuracy.ranovatbl{7,1}/sum(GR_accuracy.ranovatbl{7:8,1})];
% Multiple Comparison
GR_accuracy.compareControl = multcompare(rm,'control','ComparisonType','bonferroni'); 
GR_accuracy.compareCue = multcompare(rm,'checkerboardPos','ComparisonType','bonferroni'); 

[~,GR_accuracy.HV.p,~,GR_accuracy.HV.t] = ttest(mean(Accuracy_byP(:,[1 3]),2,'omitnan'),mean(Accuracy_byP(:,[2 4]),2,'omitnan'));

[~,GR_accuracy.L_P.p,~,GR_accuracy.L_P.t] = ttest(Accuracy_byC(:,1),Accuracy_byC(:,3));
[~,GR_accuracy.H_P.p,~,GR_accuracy.H_P.t] = ttest(Accuracy_byC(:,2),Accuracy_byC(:,3));

%% Plot
Hzorder = [1 3 2 4];
picsize = [5 5 20 20];
TIT = 'Results_Accuracy';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

% Main effect of Cued Position
ctrs = 1:n.Hz;
ax1 = subplot(2,2,2);
acc_pos_avg = GR_accuracy.mainCue{[3 2 4 1],3};
acc_pos_sem = GR_accuracy.mainCue{[3 2 4 1],4}/sqrt(nPair);

bar(ctrs,acc_pos_avg,'FaceColor',[.8 .8 .8]);
hold on
errorbar(ctrs,acc_pos_avg,acc_pos_sem, '.k','LineWidth',2)

xlim([0.5 n.Hz+0.5])
xticklabels(str.checkerboardPos(Hzorder))
ylabel('Baseline Accuracy (%)')
xlabel('Checkerboard Position')
APAaxis(ax1);
box off
% Main effect of control
ctrs = 1:N.players+1;
ax2 = subplot(2,2,3);
acc_ag_avg = GR_accuracy.mainControl{[2 1 3],3};
acc_ag_sem = GR_accuracy.mainControl{[2 1 3],4}/sqrt(nPair);

bar(ctrs,acc_ag_avg,'FaceColor','flat','CData',colour.player);
hold on
errorbar(ctrs,acc_ag_avg,acc_ag_sem, '.k','LineWidth',2)

xlim([0.5 N.players+1.5])
xticklabels(str.control)
ylabel('Baseline Accuracy (%)')
xlabel('BCI Control')
APAaxis(ax2);
box off

% Interaction
ctrs = 1:n.Hz;
Acc_avg = squeeze(mean(GD_Baseline_Accuracy.*100));
Acc_avg = Acc_avg(Hzorder,:);
Acc_sem = squeeze(std(GD_Baseline_Accuracy.*100))./sqrt(nPair); % SEM
Acc_sem = Acc_sem(Hzorder,:);

ax3 = subplot(2,2,4);
hold on
for P = 1:N.players+1
    ln = errorbar(ctrs,Acc_avg(:,P), Acc_sem(:,P), 'Color',colour.player(P,:),'LineWidth',1,'Marker','o','MarkerSize',4,'MarkerFaceColor',colour.player(P,:));
    switch P
        case 1
            ln.LineStyle = '--';
        case 2
            ln.LineStyle = ':';
    end
end
xlim([0.5 n.Hz+0.5])
xticklabels(str.checkerboardPos(Hzorder))
legend(str.control,'Location','northeast')
ylabel('Baseline Accuracy (%)','FontWeight','bold')
xlabel('Checkerboard Position')
APAaxis(ax3);
box off

linkaxes([ax1 ax2 ax3],'y')
ylim([50 100])
yticks(0:10:100)
%%
saveas(h,[direct.groupRes TIT '.png'])
close(h)