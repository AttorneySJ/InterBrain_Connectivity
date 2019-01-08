%% Trajectory
Trajectory = reshape(GD_Test_trajectory,[],n.targetLoc,N.players+1);

picsize = [5 5 32 12];
TIT = 'Trajectory';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';


for P = 1:N.players+1
    ax = subplot(1,3,P);
    set(ax,'Color','k','XTick',[],'YTick',[])
    xlim([-35 35])
    ylim([-35 35])
    pbaspect([1 1 1])
    
    hold on
    
    for TRIAL = 1:length(Trajectory)
        for LOC = 1:4
            X = Trajectory{TRIAL,LOC,P}(1,:);
            Y = Trajectory{TRIAL,LOC,P}(2,:);                
            C = colour.loc(LOC,:);
            patchline(X,Y,'edgecolor',C,'linewidth',1,'edgealpha',0.1);
        end
    end
end
clear Trajectory
%%
% saveas(h,[direct.groupRes TIT '.png'])
close(h)

%% Distance to target
% Stats (Two-way repeated-measures ANOVA, IV: control/checkerboardPos, DV: distance to target)

d2t = squeeze(mean(GD_Test_d2t,2,'omitnan'));
DV = reshape(d2t,nPair,[]);
IV1 = repelem(categorical(str.control),n.checkerboardPos);
IV2 = repmat(categorical(str.loc(idx.targetLoc)),N.players+1,1);
IV = table(IV1,IV2,'VariableNames',{'control','TargetLoc'});
tab = array2table(DV);
rm = fitrm(tab,'DV1-DV12~1','WithinDesign',IV);

% ANOVA
GR_D2T.mainControl = grpstats(rm,'control',{'mean','std',@skewness,@kurtosis});
GR_D2T.mainLoc = grpstats(rm,'TargetLoc',{'mean','std',@skewness,@kurtosis});
GR_D2T.cellstats = grpstats(rm,{'control','TargetLoc'},{'mean','std',@skewness,@kurtosis});
GR_D2T.sphericity = mauchly(rm);
GR_D2T.ranovatbl = ranova(rm,'WithinModel','control+TargetLoc+control*TargetLoc');
GR_D2T.eta = [GR_D2T.ranovatbl{3,1}/sum(GR_D2T.ranovatbl{3:4,1}),...
    GR_D2T.ranovatbl{5,1}/sum(GR_D2T.ranovatbl{5:6,1}),...
    GR_D2T.ranovatbl{7,1}/sum(GR_D2T.ranovatbl{7:8,1})];
% Multiple Comparison
[~,GR_D2T.L_P.p,~,GR_D2T.L_P.t] = ttest(mean(d2t(:,:,1),2,'omitnan'),mean(d2t(:,:,3),2,'omitnan'));
[~,GR_D2T.H_P.p,~,GR_D2T.H_P.t] = ttest(mean(d2t(:,:,2),2,'omitnan'),mean(d2t(:,:,3),2,'omitnan'));

%% Plot
picsize = [5 5 23 6];
TIT = 'Results_Trajectory_D2T';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

% Main effect of Target Location
ctrs = 1:n.targetLoc;
ax1 = subplot(1,3,1);
d2t_l_avg = GR_D2T.mainLoc{[1 3 2 4],3};
d2t_l_sem = GR_D2T.mainLoc{[1 3 2 4],4}/sqrt(nPair);
str.targetLoc = {'UR';'LR';'UL';'LL'};
bar(ctrs,d2t_l_avg,'FaceColor',[.8 .8 .8]);
hold on
errorbar(ctrs,d2t_l_avg,d2t_l_sem, '.k','LineWidth',2)

xlim([0.5 n.targetLoc+0.5])
xticklabels(str.targetLoc)
ylabel('Distance to Target (m)')
xlabel('Target Location')
APAaxis(ax1);
box off

% Main effect of control
ctrs = 1:N.players+1;
ax2 = subplot(1,3,2);
d2t_a_avg = GR_D2T.mainControl{[3 1 2],3};
d2t_a_sem = GR_D2T.mainControl{[3 1 2],4}/sqrt(nPair);

bar(ctrs,d2t_a_avg,'FaceColor','flat','CData',colour.player);
hold on
errorbar(ctrs,d2t_a_avg,d2t_a_sem, '.k','LineWidth',2)

xlim([0.5 N.players+1.5])
xticklabels(str.control)
xlabel('BCI Control')
APAaxis(ax2);
box off
% Interaction
ctrs = 1:n.targetLoc;
D2T_avg = squeeze(mean(d2t,1,'omitnan'));
D2T_avg = D2T_avg([1 4 2 3],:);
D2T_sem = squeeze(std(d2t,1,'omitnan'))./sqrt(nPair); % SEM
D2T_sem = D2T_sem([1 4 2 3],:);

ax3 = subplot(1,3,3);
hold on
for P = 1:N.players+1
    ln = errorbar(ctrs,D2T_avg(:,P), D2T_sem(:,P), 'Color',colour.player(P,:),'LineWidth',1,'Marker','o','MarkerSize',4,'MarkerFaceColor',colour.player(P,:));
    switch P
        case 1
            ln.LineStyle = '--';
        case 2
            ln.LineStyle = ':';
    end
end
xlim([0.5 n.targetLoc+0.5])
xticks(1:4)
xticklabels(str.targetLoc)
legend(str.control,'Location','southeast')
xlabel('Target Location')
APAaxis(ax3);
box off

linkaxes([ax1 ax2 ax3],'y')
ylim([0 30])
%%
saveas(h,[direct.groupRes TIT '.png'])
close(h)

%% Dispersion
% Stats (Two-way repeated-measures ANOVA, IV: control/checkerboardPos, DV: dispersion)

d2l = squeeze(mean(GD_Test_d2l,2,'omitnan'));
DV = reshape(d2l,nPair,[]);
IV1 = repelem(categorical(str.control),n.checkerboardPos);
IV2 = repmat(categorical(str.loc(idx.targetLoc)),N.players+1,1);
IV = table(IV1,IV2,'VariableNames',{'control','TargetLoc'});
tab = array2table(DV);
rm = fitrm(tab,'DV1-DV12~1','WithinDesign',IV);

% ANOVA
GR_D2L.mainControl = grpstats(rm,'control',{'mean','std',@skewness,@kurtosis});
GR_D2L.mainLoc = grpstats(rm,'TargetLoc',{'mean','std',@skewness,@kurtosis});
GR_D2L.cellstats = grpstats(rm,{'control','TargetLoc'},{'mean','std',@skewness,@kurtosis});
GR_D2L.sphericity = mauchly(rm);
GR_D2L.ranovatbl = ranova(rm,'WithinModel','control+TargetLoc+control*TargetLoc');
GR_D2L.eta = [GR_D2L.ranovatbl{3,1}/sum(GR_D2L.ranovatbl{3:4,1}),...
    GR_D2L.ranovatbl{5,1}/sum(GR_D2L.ranovatbl{5:6,1}),...
    GR_D2L.ranovatbl{7,1}/sum(GR_D2L.ranovatbl{7:8,1})];
% Multiple Comparison
[~,GR_D2L.L_P.p,~,GR_D2L.L_P.t] = ttest(mean(d2l(:,:,1),2,'omitnan'),mean(d2l(:,:,3),2,'omitnan'));
[~,GR_D2L.H_P.p,~,GR_D2L.H_P.t] = ttest(mean(d2l(:,:,2),2,'omitnan'),mean(d2l(:,:,3),2,'omitnan'));

%% Plot
picsize = [5 5 23 6];
TIT = 'Results_Trajectory_Dispersion';
h = figure('WindowStyle','normal','Units','centimeters','Position',picsize);
h.Color = 'w';

% Main effect of Target Location
ax1 = subplot(1,3,1);
d2l_l_avg = GR_D2L.mainLoc{[1 3 2 4],3};
d2l_l_sem = GR_D2L.mainLoc{[1 3 2 4],4}/sqrt(nPair);
bar(ctrs,d2l_l_avg,'FaceColor',[.8 .8 .8]);
hold on
errorbar(ctrs,d2l_l_avg,d2l_l_sem, '.k','LineWidth',2)

xlim([0.5 n.targetLoc+0.5])
xticklabels(str.targetLoc)
ylabel('Trajectory Dispersion (m)')
xlabel('Target Location')
APAaxis(ax1);
box off
% Main effect of control
ctrs = 1:N.players+1;
ax2 = subplot(1,3,2);
d2l_a_avg = GR_D2L.mainControl{[3 1 2],3};
d2l_a_sem = GR_D2L.mainControl{[3 1 2],4}/sqrt(nPair);

bar(ctrs,d2l_a_avg,'FaceColor','flat','CData',colour.player);
hold on
errorbar(ctrs,d2l_a_avg,d2l_a_sem, '.k','LineWidth',2)

xlim([0.5 N.players+1.5])
xticklabels(str.control)
xlabel('BCI Control')
APAaxis(ax2);
box off
% Interaction
ctrs = 1:n.targetLoc;
D2L_avg = squeeze(mean(d2l,1,'omitnan'));
D2L_avg = D2L_avg([1 4 2 3],:);
D2L_sem = squeeze(std(d2l,1,'omitnan'))./sqrt(nPair); % SEM
D2L_sem = D2L_sem([1 4 2 3],:);

ax3 = subplot(1,3,3);
hold on
for P = 1:N.players+1
    ln = errorbar(ctrs,D2L_avg(:,P), D2L_sem(:,P), 'Color',colour.player(P,:),'LineWidth',1,'Marker','o','MarkerSize',4,'MarkerFaceColor',colour.player(P,:));
    switch P
        case 1
            ln.LineStyle = '--';
        case 2
            ln.LineStyle = ':';
    end
end
xlim([0.5 n.targetLoc+0.5])
xticks(1:4)
xticklabels(str.targetLoc)
legend(str.control,'Location','southeast')
xlabel('Target Location')
APAaxis(ax3);
box off

linkaxes([ax1 ax2 ax3],'y')
ylim([0 13])
%%
saveas(h,[direct.groupRes TIT '.png'])
close(h)