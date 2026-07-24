% =========================================================================
%  SimulationsAndPlots.m
% -------------------------------------------------------------------------
%  Reproduction script for the figures reported in the manuscript:
%
%      "Reinforcement learning optimization of automated insulin 
%       delivery in type 1 and type 2 diabetes mellitus"
%      <Nelida E. Lopez-Palau1, Pablo Naranjo-Meneses, 
%       Julia Szendroedi, Roland Eils, Stefan M. Kallenberger>, 
%       submitted to PLOS Digital Health (2026).
%
%  This single script regenerates the three main-text figures that compare
%  a Reinforcement Learning (RL) glucose-control policy against classical
%  controllers (PID, MPC) for in silico Type 1 (T1DM) and Type 2 (T2DM)
%  diabetes cohorts.
%
%  Figure map
%  ----------
%    Task_showBoxplot       -> Fig 2  Cumulative-reward boxplots
%                                      (untrained vs. optimal RL policy,
%                                      training vs. validation environment)
%    Task_showAvgSubjectBG  -> Fig 3  Exemplary glucose/insulin time series
%                                      (PID / MPC / RL, T1DM and T2DM)
%    Task_showScatterPlot   -> Fig 4  RL-vs-PID and RL-vs-MPC scatter plots
%                                      for TIR / TAR / TBR metrics
%  Usage
%  -----
%    1. Place the .mat data files in the structure shown above.
%    2. Run this script from its own folder in MATLAB.
%    3. Each enabled task produces one figure and prints the corresponding
%       statistical test results to the Command Window.
%    You can enable/disable each figure via the flags in "Task definition".
% =========================================================================

clc
clearvars

%% Task definition
Task_showBoxplot         = 1;          % Article Fig 2
Task_showAvgSubjectBG    = 1;          % Article Fig 3
Task_showScatterPlot     = 1;          % Article Fig 4

% =========================================================================
% FIG 2 - Boxplots: untrained vs. trained policies on training and
%          validation datasets (1500 virtual patients)
% =========================================================================
if Task_showBoxplot
    load("Policies_simulations.mat")
    
    % Reward comparison in RL and DM
    fig          = figure(1);
    fig.Units    = "centimeters";
    fig.Position = [1,5,40,20];
    
    TickLabel  = {'$\pi_{T1DM}^{0}$',...
                  '$\pi_{T1DM}^{*}$',...
                  '$\pi_{T1DM}^{*}$',...
                  '$\pi_{T2DM}^{0}$',...
                  '$\pi_{T2DM}^{*}$',...
                  '$\pi_{T2DM}^{*}$'};
    
    De         = {'Untrained RL policy\n Training environment\n',... 
                  'Optimal RL policy\n Training environment\n',... 
                  'Optimal RL policy\n Validation environment\n',... 
                  'Untrained RL policy\n Training environment\n',... 
                  'Optimal RL policy\n Training environment\n',... 
                  'Optimal RL policy\n Validation environment\n' };
    
   % Variable naming key:
   %   T1_ag0_env   -> T1 agent, untrained  (training environment)
   %   T1_ag5_env   -> T1 agent, trained    (training environment)
   %   T1_ag5_envT  -> T1 agent, validated  (validation environment)
   %   T2_ag0_env   -> T2 agent, untrained  (training environment)
   %   T2_ag9_env   -> T2 agent, trained    (training environment)
   %   T2_ag9_envT  -> T2 agent, validated  (validation environment)

    num_env            = size(T1_ag0_env,1); 
    num_envT           = size(T1_ag5_envT,1);
    
    RLAgent_T1DM       = zeros(1,num_env);
    RLAgent_T1DM_T     = zeros(1,num_env);
    RLAgent_T1DM_V     = zeros(1,num_envT);
    RLAgent_T2DM       = zeros(1,num_env);
    RLAgent_T2DM_T     = zeros(1,num_env);
    RLAgent_T2DM_V     = zeros(1,num_envT);
    
    % Cumulative reward per virtual patient (sum of the reward signal)
    for i = 1:num_env
        RLAgent_T1DM(1,i)   = sum(T1_ag0_env(i).Reward.Data);
        RLAgent_T1DM_T(1,i) = sum(T1_ag5_env(i).Reward.Data);
        RLAgent_T2DM(1,i)   = sum(T2_ag0_env(i).Reward.Data);
        RLAgent_T2DM_T(1,i) = sum(T2_ag9_env(i).Reward.Data);
    end
    
    for i = 1:num_envT
        RLAgent_T1DM_V(1,i) = sum(T1_ag5_envT(i).Reward.Data);
        RLAgent_T2DM_V(1,i) = sum(T2_ag9_envT(i).Reward.Data);
    end
    
    y = {RLAgent_T1DM; RLAgent_T1DM_T; RLAgent_T1DM_V;...
        RLAgent_T2DM; RLAgent_T2DM_T; RLAgent_T2DM_V};
    
    % Wilcoxon signed-rank test
    % Only performed between groups with the same number of elements and
    % the same controller.
    num_tests = 4;
    alpha          = 0.05;          % significance level
    pvalue = zeros(num_tests, 1);
    
    [pvalue(1), hh, ~] = signrank(y{1}, y{2}, 'alpha', alpha);
    fprintf('T1DM untrained vs T1DM optimal in training environment. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(1));
    
    [pvalue(2), hh, ~] = ranksum(y{1}, y{3}, 'alpha', alpha);
    fprintf('T1DM untrained vs T1DM optimal in validation environment. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(2));
    
    [pvalue(3), hh, ~] = signrank(y{4}, y{5}, 'alpha', alpha);
    fprintf('T2DM untrained vs T2DM optimal in training environment. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(3));
    
    [pvalue(4), hh, ~] = ranksum(y{4}, y{6}, 'alpha', alpha);
    fprintf('T2DM untrained vs T2DM optimal in validation environment. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(4));
     
    % Bonferroni correction for multiple test
    alpha_bonf  = alpha / num_tests;     % Bonferroni-corrected significance level
    significant = pvalue < alpha_bonf;   % significant results after correction
    for i = 1:num_tests
        if significant(i)
            result = 'Significative';
        else
            result = 'No significative';
        end
        fprintf('Test %d: p = %.3e -> %s\n', i, pvalue(i), result);
    end
    
    % Compute per-group statistics
    stats = zeros(6, 1);                 % matrix holding [std] per group
    for m = 1:6
        groupData = y{m};                % extract group data
        stats(m, 1) = std(groupData);    % standard deviation
    end
    
    x = 1:6;
    point = [0, 0, 1; 0, 0, 1; 0, 0, 1;...
             0, 1, 1; 0, 1, 1; 0, 1, 1];
    pairedcolor = [0.7, 0.7, 0.7];
    marker=['.', '.', '.','.', '.', '.'];
    markersize = [10,10,10,10,10,10];
    ax = axes();
    hold(ax);
    spread=0.35;
    x_pos = cell(1,6); % store the X positions of each group
    for i=1:6
        x_pos{i} = rand(size(y{i}))*spread - (spread/2) + i;
    end
    
    % Connect paired points with dashed lines (untrained -> optimal)
    for j = 1:length(y{1})
        q(j)=line([x_pos{1}(j), x_pos{2}(j)], [y{1}(j), y{2}(j)],...
            'Color', pairedcolor, 'LineStyle', '--');
    end
    
    for j = 1:length(y{4})
        line([x_pos{4}(j), x_pos{5}(j)], [y{4}(j), y{5}(j)],...
            'Color', pairedcolor, 'LineStyle', '--');
    end
    
    for i=1:6
        pl(i) = plot(x_pos{i}, y{i}, marker(i), ...
                'MarkerSize', markersize(i), ...
                'Color', point(i,:), ...
                'MarkerEdgeColor', point(i,:),...
                'MarkerFaceColor', 'none');
        hold on
        boxchart(x(i)*ones(size(y{i})), y{i}, ...
                'BoxEdgeColor', [0 0 0], ...
                'BoxFaceColor', [0 0 0], ...
                'BoxFaceAlpha', 0.05, ...
                'BoxWidth', 0.9, ...
                'WhiskerLineColor', [0 0 0], ...
                'BoxMedianLineColor', [0 0 0], ...
                'LineWidth', 1.5, ...
                'JitterOutliers', 'off', ...
                'MarkerStyle', 'none');
        ytxt1 = 1.15;
        statText = sprintf(['n= %.0f\n' 'sd= %.2f\n'], numel(y{i}), stats(i, 1));
        text(i, ytxt1, statText, ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 12, ...
                'Color', 'k', ...
                'FontName', 'Arial');
    
        ytxt2 = -2.15;
        text(i, ytxt2, TickLabel{i}, ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 17, ...
                'Color', 'k', ...
                'FontName', 'Arial','Interpreter','latex');
    
        endText = sprintf(De{i});
        % Place the description text at the same height for every box
    
        ytxt2 = -2.45;
        text(i, ytxt2, endText, ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 12, ...
                'Color', 'k', ...
                'FontName', 'Arial');
    end
    set(gca,"XGrid","off","YGrid","on")
    ylabel([sprintf('Cumulative reward ') '$r_{total}$ [a.u.]'],...
        "FontSize",15,"Interpreter","latex")
    set(gca,"XGrid","off","YGrid","on",...
        "GridLineStyle","--","GridColor",[0.5 0.5 0.5])
    ax.FontSize = 19;
    ax.Box="on";
    ax.XTick=[0 1 2 3 4 5 6 7];
    ax.XLim = [0 7];
    ax.YLim = [-2 2];
    ax.TickLabelInterpreter="latex";
    ax.XTickLabel= {};
end


% =========================================================================
%  FIG 3 - Exemplary time-span glucose control
%  PID / MPC / RL comparison  -  T1DM and T2DM
%  1 figure, 4 subplots with manual positions:
%    Subplot 1 -> Glucose  T1DM  (no X axis labels)
%    Subplot 2 -> Insulin  T1DM  (X axis labels shown)
%    [extra vertical gap]
%    Subplot 3 -> Glucose  T2DM  (no X axis labels)
%    Subplot 4 -> Insulin  T2DM  (X axis labels shown)
% =========================================================================
if Task_showAvgSubjectBG
    MainPath = "Controllers\";
     
    % Data loading
    load(MainPath + "T1_SimulationResults_AvgSubject\T1_PIDResults.mat");
    T1_PID = PopulationPIDResults;
    load(MainPath + "T1_SimulationResults_AvgSubject\T1_MPCResults.mat");
    T1_MPC = PopulationMPCResults;
    load(MainPath + "T1_SimulationResults_AvgSubject\T1_RLResults.mat");
    T1_RL  = PopulationRLResults;
     
    load(MainPath + "T2_SimulationResults_AvgSubject\T2_PIDResults.mat");
    T2_PID = PopulationPIDResults;
    load(MainPath + "T2_SimulationResults_AvgSubject\T2_MPCResults.mat");
    T2_MPC = PopulationMPCResults;
    load(MainPath + "T2_SimulationResults_AvgSubject\T2_RLResults.mat");
    T2_RL  = PopulationRLResults;
     
    ControllerInfo = {T1_PID, T1_MPC, T1_RL, T2_PID, T2_MPC, T2_RL};
 
    % Metadata (T1_PID used as reference: all share the same meal plan)
    RefData      = T1_PID{1,1};
    TOGC0        = [RefData.meals.OGC_mg];
    T0           = [RefData.meals.T0];
    timeVec      = RefData.time;
    simStartTime = timeVec(1);
    simEndTime   = timeVec(end);
 
    % Signal extraction
    nTime   = numel(timeVec);
    nCtrl   = numel(ControllerInfo);
    Glucose = zeros(nTime, nCtrl);
    Insulin = zeros(nTime, nCtrl);
    Bolus   = zeros(nTime, nCtrl);
 
    for ii = 1:nCtrl
        Data = ControllerInfo{ii};
        D    = Data{1,1};
        Glucose(:, ii) = D.glucose_mgdL;
     
        % RL updates every 15 min: repeat each value 3 times + append last value
        isRL = (mod(ii-1, 3) == 2);   % columns 3 and 6 are RL
        if isRL
            Insulin(:, ii) = [repelem(D.rivi_total_mUmin, 3); ...
                              D.rivi_total_mUmin(end)];
        else
            Insulin(:, ii) = D.rivi_ctrl_mUmin;
            Bolus(:, ii)   = D.rivi_bolus_mUmin;
        end
    end
 
    % Line styles
    LW = [1.5, 2.0, 2.0];       % LineWidth per controller: PID, MPC, RL
    LS = {"-", "-", "-"};       
 
    % Color palette and per-type configuration
    typeConfig(1).cols   = 1:3;
    typeConfig(1).colors = [0.902, 0.624, 0.000;   % PID  T1  
                            0.749, 0.224, 0.169;   % MPC  T1  
                            0,     0,     1.000];  % RL   T1  
     
    typeConfig(2).cols   = 4:6;
    typeConfig(2).colors = [0.902, 0.624, 0.000;   % PID  T2  
                            0.749, 0.224, 0.169;   % MPC  T2  
                            0,     1.000, 1.000];  % RL   T2  
 
    % Normoglycemic range lines
    TIR_lo    = 70;                      % mg/dL lower bound
    TIR_hi    = 180;                     % mg/dL upper bound
    TIR_color = [0, 0, 0];               % black for range lines
    TIR_lw    = 1.5;                     % line width
 
    % Figure with 4 manually-positioned axes
    fig = figure(2);
    clf;
    fig.Units    = "centimeters";
    fig.Position = [1, 2, 30, 20];
     
    fontsize = 10;
    left     = 0.11;   % left margin (normalized)
    wAx      = 0.80;   % axes width  (normalized)
    gap      = 0.015;  % vertical gap between adjacent subplots
    spacer   = 0.2;    % extra vertical gap between T1DM and T2DM groups
    hAx      = (1 - 0.05 - 0.04 - spacer - 3*gap) / 4;  % height of each axes
     
    % Y positions (bottom edge), computed bottom-to-top
    y_ins2  = 0.04;
    y_gluc2 = y_ins2  + hAx + gap;
    y_ins1  = y_gluc2 + hAx + gap + spacer;   
    y_gluc1 = y_ins1  + hAx + gap;
     
    % Create the 4 axes (stored in typeConfig for access inside the loop)
    typeConfig(1).axGluc = axes('Position', [left, y_gluc1, wAx, hAx]);
    typeConfig(1).axIns  = axes('Position', [left, y_ins1,  wAx, hAx]);
    typeConfig(2).axGluc = axes('Position', [left, y_gluc2, wAx, hAx]);
    typeConfig(2).axIns  = axes('Position', [left, y_ins2,  wAx, hAx]);
 
    % Time axis tick labels (HH:00 format)
    tickTimes  = simStartTime : 60 : simEndTime;
    tickLabels = arrayfun(@(t) sprintf('%02d:00', mod(floor(t/60), 24)), ...
                          tickTimes, 'UniformOutput', false);
 
    % Main rendering loop
    for t = 1:2     % 1 = T1DM,  2 = T2DM
        cfg  = typeConfig(t);
        cols = cfg.cols;
        axG  = cfg.axGluc;
        axI  = cfg.axIns;
     
        % Glucose subplot
        hold(axG, 'on');
     
        % Normoglycemic range: dashed horizontal lines (no filled patch)
        yline(axG, TIR_hi, ':', 'Above range (>180 mg/dL)', ...
              'FontSize',fontsize, 'FontName','Arial', 'LineWidth',TIR_lw, ...
              'Color',TIR_color, 'LabelHorizontalAlignment','right', ...
              'HandleVisibility','off');
        yline(axG, TIR_lo, ':', 'In range (70-180 mg/dL)', ...
              'FontSize',fontsize, 'FontName','Arial', 'LineWidth',TIR_lw, ...
              'Color',[0, 0.6, 0], 'LabelHorizontalAlignment','right', ...
              'HandleVisibility','off');
        yline(axG, 0, ':', 'Below range (<70 mg/dL)', ...
              'FontSize',fontsize, 'FontName','Arial', 'LineWidth',0.5, ...
              'Color',TIR_color, 'LabelHorizontalAlignment','right', ...
              'HandleVisibility','off');
     
        % Glucose curves: PID, MPC, RL
        pG = gobjects(1, 4);
        for i = 1:3
            pG(i) = plot(axG, timeVec, Glucose(:, cols(i)), ...
                         'Color',     cfg.colors(i,:), ...
                         'LineWidth', LW(i), ...
                         'LineStyle', LS{i});
        end
     
        % Vertical meal markers
        for m = 1:numel(T0)
            lbl = ['Meal ' num2str(m) ' (' num2str(TOGC0(m)/1e3, '%.0f') ' g)'];
            xl  = xline(axG, T0(m) + simStartTime, '--', lbl, ...
                        'FontSize',fontsize, 'FontName','Arial', ...
                        'LineWidth',1, 'Color',[0 0 0]);
            if m == 1
                pG(4) = xl;   % keep first meal handle for legend
            end
        end
     
        % Axes decoration (no X tick labels on glucose subplots)
        ylabel(axG, sprintf("Measured blood\nglucose BG_m [mg/dL]"), 'FontName','Arial');
        ylim(axG,[0 250]);
        decorateAx(axG, tickTimes, tickLabels, simStartTime, simEndTime, false);
     
        hold(axG, 'off');
     
        % Insulin subplot
        % Left Y axis: IVI infusion rate
        yyaxis(axI, 'left');
        hold(axI, 'on');
     
        pI = gobjects(1, 4);
        for i = 1:3
            isRL = (i == 3);
            if isRL
                % RL delivers in steps (15-min resolution)
                pI(i) = stairs(axI, timeVec, Insulin(:, cols(i)), ...
                               'Color',     cfg.colors(i,:), ...
                               'LineWidth', LW(i), ...
                               'LineStyle', LS{i});
            else
                pI(i) = plot(axI, timeVec, Insulin(:, cols(i)), ...
                             'Color',     cfg.colors(i,:), ...
                             'LineWidth', LW(i), ...
                             'LineStyle', LS{i});
            end
        end
        ylabel(axI, sprintf("Insulin infusion\nrate [mU/min]"), 'FontName','Arial', 'FontSize',fontsize);
     
        % Right Y axis: insulin bolus (null pulses excluded)
        yyaxis(axI, 'right');
        hold(axI, 'on');
     
        bolusStemPlotted = false;
        for i = 1:2   % only PID and MPC deliver bolus
            bolusVec  = Bolus(:, cols(i));
            bolusMask = bolusVec > 0;       % filter out zero-valued pulses
     
            if any(bolusMask)
                s = stem(axI, timeVec(bolusMask), bolusVec(bolusMask), ...
                         'Color',            cfg.colors(i,:), ...
                         'LineWidth',        LW(i), ...
                         'LineStyle',        '--',...
                         'MarkerFaceColor',  cfg.colors(i,:), ...
                         'MarkerSize',       5);
                if ~bolusStemPlotted
                    pI(4) = s;              % keep first bolus handle for legend
                    bolusStemPlotted = true;
                end
            end
        end
        ylabel(axI, sprintf("Insulin bolus\ndistributed over step\n[mU/min]"), 'FontName','Arial', 'FontSize',fontsize);
     
        % Force both Y axes to black (yyaxis auto-colors them otherwise)
        axI.YAxis(1).Color = [0 0 0];
        axI.YAxis(2).Color = [0 0 0];
     
        % Axes decoration (X tick labels shown on insulin subplots only)
        decorateAx(axI, tickTimes, tickLabels, simStartTime, simEndTime, true);
     
        yyaxis(axI, 'left');
        hold(axI, 'off');
    end
end

% =========================================================================
% FIG 4 - Scatter plots (RL vs PID / RL vs MPC)
%  Generates a 3×2 figure comparing RL vs PID (left column)
%  and RL vs MPC (right column) for metrics TIR, TAR, TBR.
%  Rows: TIR (top), TAR (middle), TBR (bottom).
%  Both T1 and T2 patients are shown in each subplot.
% =========================================================================
if Task_showScatterPlot    
    % Data loading 
    MainPath = "Controllers\";
    
    load(MainPath + "T1_SimulationResults\T1_PIDResults.mat", "TIR", "TAR", "TBR");
    T1_PID = [TIR, TAR, TBR];
    
    load(MainPath + "T1_SimulationResults\T1_MPCResults.mat", "TIR", "TAR", "TBR");
    T1_MPC = [TIR, TAR, TBR];
    
    load(MainPath + "T1_SimulationResults\T1_RLResults.mat",  "TIR", "TAR", "TBR");
    T1_RL  = [TIR, TAR, TBR];
    
    load(MainPath + "T2_SimulationResults\T2_PIDResults.mat", "TIR", "TAR", "TBR");
    T2_PID = [TIR, TAR, TBR];
    
    load(MainPath + "T2_SimulationResults\T2_MPCResults.mat", "TIR", "TAR", "TBR");
    T2_MPC = [TIR, TAR, TBR];
    
    load(MainPath + "T2_SimulationResults\T2_RLResults.mat",  "TIR", "TAR", "TBR");
    T2_RL  = [TIR, TAR, TBR];
    
    % Significance test for T1DM (paired Wilcoxon signed-rank)
    num_tests = 2;
    alpha          = 0.05;          % significance level

    [pvalue(1), hh, ~] = signrank(T1_RL(:,1), T1_PID(:,1), 'alpha', alpha);
    fprintf('TIR T1DM: RL vs PID. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(1));

    [pvalue(2), hh, ~] = signrank(T1_RL(:,1), T1_MPC(:,1), 'alpha', alpha);
    fprintf('TIR T1DM: RL vs MPC. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(2));

    [pvalue(3), hh, ~] = signrank(T1_RL(:,2), T1_PID(:,2), 'alpha', alpha);
    fprintf('TAR T1DM: RL vs PID. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(3));

    [pvalue(4), hh, ~] = signrank(T1_RL(:,2), T1_MPC(:,2), 'alpha', alpha);
    fprintf('TAR T1DM: RL vs MPC. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(4));

    [pvalue(5), hh, ~] = signrank(T1_RL(:,3), T1_PID(:,3), 'alpha', alpha);
    fprintf('TBR T1DM: RL vs PID. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(5));

    [pvalue(6), hh, ~] = signrank(T1_RL(:,3), T1_MPC(:,3), 'alpha', alpha);
    fprintf('TBR T1DM: RL vs MPC. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(6));

    % Significance test for T2DM (paired Wilcoxon signed-rank)
    [pvalue(7), hh, ~] = signrank(T2_RL(:,1), T2_PID(:,1), 'alpha', alpha);
    fprintf('TIR T2DM: RL vs PID. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(7));

    [pvalue(8), hh, ~] = signrank(T2_RL(:,1), T2_MPC(:,1), 'alpha', alpha);
    fprintf('TIR T2DM: RL vs MPC. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(8));

    [pvalue(9), hh, ~] = signrank(T2_RL(:,2), T2_PID(:,2), 'alpha', alpha);
    fprintf('TAR T2DM: RL vs PID. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(9));

    [pvalue(10), hh, ~] = signrank(T2_RL(:,2), T2_MPC(:,2), 'alpha', alpha);
    fprintf('TAR T2DM: RL vs MPC. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(10));

    [pvalue(11), hh, ~] = signrank(T2_RL(:,3), T2_PID(:,3), 'alpha', alpha);
    fprintf('TBR T2DM: RL vs PID. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(11));

    [pvalue(12), hh, ~] = signrank(T2_RL(:,3), T2_MPC(:,3), 'alpha', alpha);
    fprintf('TBR T2DM: RL vs MPC. Result H: %.1f, Valor p: %.8f\n',hh,pvalue(12));


    % Figure setup 
    fig          = figure(3);
    clf;
    fig.Units    = "centimeters";
    fig.Position = [1, 2, 30, 20];
    axHandles    = gobjects(2, 3);  % 2 rows x 3 cols
    
    % Marker / style definitions 
    T1.color = [0,   0,   1  ];     % color for T1DM
    T1.size  = 170;                 % marker size
    T1.style = '.';                 % marker type
    T1.Alpha = 0.02;                % transparency
    T1.Marker= 'x';                 % marker for mean value
    
    T2.color = [0,   1,   1  ];     % color for T2DM
    T2.size  = 60;                  % marker size
    T2.style = '.';                 % marker type
    T2.Alpha = 0.25;                % transparency
    T2.Marker= '+';                 % marker for mean value
    
    % Metric labels and column labels 
    metricLabels = {'Time in range (TIR) [%%]', 'Time above range (TAR) [%%]', 'Time below range (TBR) [%%]'};   % row labels
    colLabels    = {'Optimal RL policy vs PID', 'Optimal RL policy vs MPC'};           % column labels
    
    % Significance symbol helper 
    getSigSym = @(pval) sigSymbol(pval);
    
    % Build subplot layout
    % Layout:  3 col (TIR, TAR, TBR) × 2 rows (PID, MPC)
    % Pair definitions: {xData_T1, yData_T1, xData_T2, yData_T2, betterLabel}
    comparisons = { ...
        T1_PID, T1_RL, T2_PID, T2_RL, 'PID better'; ...   % row 1
        T1_MPC, T1_RL, T2_MPC, T2_RL, 'MPC better'  };    % row 2
    
    metricIdx = [1, 2, 3];         % columns of [TIR TAR TBR]
    
    for row = 1:2
        xT1_all   = comparisons{row, 1};
        yT1_all   = comparisons{row, 2};
        xT2_all   = comparisons{row, 3};
        yT2_all   = comparisons{row, 4};
        betterLbl = comparisons{row, 5};
    
        for col = 1:3    % 1 TIR, 2 TAR, 3 TBR
            m = metricIdx(col);
    
            % Extract the column for this metric
            xT1 = xT1_all(:, m);
            yT1 = yT1_all(:, m);
            xT2 = xT2_all(:, m);
            yT2 = yT2_all(:, m);
    
            % Create subplot 
            spIdx = (row - 1)*3 + col;
            ax = subplot(2, 3, spIdx);
            hold(ax, 'on');
    
            % Determine axis limits from all data
            allVals = [xT1; yT1; xT2; yT2];
            allVals = allVals(~isnan(allVals));
            axMin   = floor(min(allVals))- 0.01*max(allVals);
            axMax   = ceil( max(allVals))+ 0.01*max(allVals);
            axLim   = [axMin, axMax];
    
            % 45-degree reference line
            plot(ax, axLim, axLim, '-', 'Color', 'k', ...
                 'LineWidth', 0.5, 'HandleVisibility', 'off');
    
            % "RL better" / "<Controller> better" labels
            midX     = mean(axLim);
            offset   = (axMax - axMin) * 0.07;
            if col == 1
                text(ax, midX - offset*2.5, midX + offset*1.5, 'RL better', ...
                     'FontSize', 10, 'Color', 'k', ...
                     'Rotation', 45, 'HorizontalAlignment', 'center');
                text(ax, midX + offset*1.5, midX - offset*2.5, betterLbl, ...
                     'FontSize', 10, 'Color', 'k', ...
                     'Rotation', 45, 'HorizontalAlignment', 'center');
            else
                text(ax, midX - offset*2.5, midX + offset*1.5, betterLbl, ...
                    'FontSize', 10, 'Color', 'k', ...
                    'Rotation', 45, 'HorizontalAlignment', 'center');
                text(ax, midX + offset*1.5, midX - offset*2.5, 'RL better', ...
                    'FontSize', 10, 'Color', 'k', ...
                    'Rotation', 45, 'HorizontalAlignment', 'center');
            end
    
            % Helper: plot scatter + trend + CI for one group
            plotGroup(ax, xT1, yT1, T1, axLim);
            plotGroup(ax, xT2, yT2, T2, axLim);

            % Mean values
            plot(mean(xT1), mean(yT1), 'Marker', T1.Marker,'MarkerSize',9,'MarkerEdgeColor','#FF00FF','LineWidth',1.5)
            plot(mean(xT2), mean(yT2), 'Marker', T2.Marker,'MarkerSize',9,'MarkerEdgeColor','#FFC000','LineWidth',1.5)

            % Pearson correlation labels (bottom-right)
            addPearsonText(ax, xT1, yT1, T1.color, axLim, 1);
            addPearsonText(ax, xT2, yT2, T2.color, axLim, 2);
    
            % Axes formatting
            xlim(ax, axLim);
            ylim(ax, axLim);
            axis(ax, 'square');
            set(ax, 'XTick', get(ax, 'YTick'));
            box(ax, 'on');
            ax.FontSize = 10;
    
            % X-axis label: controller name + metric
            ctrlName = strtok(betterLbl, ' ');   % 'PID' or 'MPC'
            xlabel(ax, sprintf([ctrlName, '\n', metricLabels{col}]), 'FontSize', 12);
    
            % Y-axis label: RL + metric
            ylabel(ax, sprintf(['RL optimal policy\n',  metricLabels{col}]), 'FontSize', 12);
            axHandles(row, col) = ax;
            hold(ax, 'off');
        end
    end
    rowThreshold = mean([axHandles(1,1).Position(2), axHandles(2,1).Position(2)]);
    for col = 1:3
        % Row 1 — move up
        pos = axHandles(1, col).Position;
        axHandles(1, col).Position(2) = pos(2) + 0.02;
    end
    
    % Adjust layout
    set(gcf, 'Color', 'w');
    % Tighten spacing between subplots
    set(gcf, 'Units', 'normalized');
end


% =========================================================================
% Auxiliar Functions
% =========================================================================

% DECORATEAX     Apply common formatting to an axes object.
%   showXLabel = true  -> show tick labels and X axis title
%   showXLabel = false -> hide tick labels (tick marks kept), no title
function decorateAx(ax, tickTimes, tickLabels, simStartTime, simEndTime, showXLabel)
    ax.XLim                 = [simStartTime, simEndTime];
    ax.XTick                = tickTimes;
    ax.FontSize             = 10;
    ax.FontName             = "Arial";
    ax.Box                  = "off";
    ax.XGrid                = "off";
    ax.YGrid                = "off";
    if showXLabel
        ax.XTickLabel = tickLabels;
        xlabel(ax, "Time [h]", 'FontName','Arial');
    else
        ax.XTickLabel = {};
        xlabel(ax, '');
    end
end

% PLOTGROUP  Scatter plot + trend line + 95% confidence band
%   ax     - target axes
%   x, y   - data vectors (controller vs RL)
%   style  - struct with fields: color, size, style, Alpha
%   axLim  - [min max] for generating the trend line range
function plotGroup(ax, x, y, style, axLim)
    if numel(x) < 2, return; end
    % Scatter
    scatter(ax, x, y, style.size, style.color, style.style, ...
        'filled', 'MarkerEdgeColor', 'none');
    
    if sum(x) == 0, return; end
    if numel(x) < 10 || var(x) < 1e-2, return; end

    % Trend line coefficients
    [g, S]          = polyfit(x, y, 1);
    xRange          = linspace(axLim(1), axLim(2), 200)';
    [y_fit, delta]  = polyval(g, xRange, S);
    
    % 95% confidence band
    ci_upper = y_fit + 1.96 * delta;
    ci_lower = y_fit - 1.96 * delta;
    
    fill(ax, [xRange; flipud(xRange)], ...
        [ci_upper; flipud(ci_lower)], ...
        style.color, 'FaceAlpha', style.Alpha, ...
        'EdgeColor', 'none', 'HandleVisibility', 'off');
    
    % Trend line
    plot(ax, xRange, y_fit, '-', 'Color', style.color, ...
        'LineWidth', 1, 'HandleVisibility', 'off');
end

% ADDPEARSONTEXT  Prints Pearson r and significance in the bottom-right corner
%   ax      – target axes
%   x, y    – data vectors
%   color   – text color
%   axLim   – [min max] axis limits
%   lineNum – vertical stacking order (1 = higher, 2 = lower)
function addPearsonText(ax, x, y, color, axLim, lineNum)    
    if numel(x) < 3, return; end
    
    [r, pval] = corr(x, y, 'Rows', 'complete');
     
    if isnan(r) , return; end
    % Significance symbol
    sym = sigSymbol(pval);
    
    % Build label string using ρ (rho) character
    txt = sprintf('\\rho = %.2f%s', r, sym);
    
    % Position: bottom-right corner, stacked vertically
    xPos  = axLim(2) - (axLim(2) - axLim(1)) * 0.02;
    range = axLim(2) - axLim(1);
    yPos  = axLim(1) + range * (0.45 + (2- lineNum) * 0.08);
    
    text(ax, xPos, yPos, txt, ...
        'FontSize', 10, 'Color', color, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment',   'bottom');
end

% SIGSYMBOL  Returns asterisk string for a given p-value
%     p ≤ 0.05   →  *
function sym = sigSymbol(pval)
    if pval <= 0.05
        sym = '*';
    else
        sym = ' ';
    end
end