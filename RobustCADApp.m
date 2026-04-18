classdef RobustCADApp < handle
    properties (Access = private)
        UIFigure
        Grid
        Sidebar

        SystemDropDown
        CustomSystemPanel
        NumEditField
        DenEditField

        ControllerDropDown
        ControllerParamsPanel
        ParamSliders

        TabGroup
        RootTab
        FreqTab
        PerfTab
        RobustTab

        UIAxes
        Slider
        KLabel

        BodeAxesMag
        BodeAxesPhase
        NyquistAxes

        MetricsTable

        ParamMinTable
        ParamMaxTable
        RunRobustButton
        RobustAxes
        RobustTextArea

        Session
        PolePlot
        PredefinedSystems
        PredefinedControllers
        CurrentAlpha = 0.5
        IsDragging = false
    end

    methods (Access = public)
        function app = RobustCADApp
            app.createComponents();
            app.startupFcn();
            app.UIFigure.Visible = 'on';
        end
    end

    methods (Access = private)

      
        function createComponents(app)
            app.UIFigure = uifigure('Name', 'RobustCAD Pro', ...
                'Position', [100 100 1400 950], 'Visible', 'off');

            app.Grid = uigridlayout(app.UIFigure, [1 2]);
            app.Grid.ColumnWidth = {300, '1x'};
            app.Grid.Padding = [5 5 5 5];

           
            app.Sidebar = uipanel(app.Grid, 'Title', 'Control Panel', 'FontWeight', 'bold');

            sideLayout = uigridlayout(app.Sidebar, [5 1], ...
                'RowHeight', {90, 'fit', 70, '1x', 70}, ...
                'Scrollable', 'off');

            
            sysPanel = uipanel(sideLayout, 'Title', 'System', 'FontWeight', 'bold');
            sysLayout = uigridlayout(sysPanel, [2 1], 'RowHeight', {25, 25});
            uilabel(sysLayout, 'Text', 'Select system:');
            app.SystemDropDown = uidropdown(sysLayout, ...
                'Items', {'System 1', 'System 2', 'Custom'}, ...
                'ValueChangedFcn', @(s,e) app.systemChanged());

            
            app.CustomSystemPanel = uipanel(sideLayout, ...
                'Title', 'Custom System', 'Visible', 'off');
            customLayout = uigridlayout(app.CustomSystemPanel, [3 2], ...
                'RowHeight', {25, 25, 30}, 'ColumnWidth', {'1x', '2x'});
            uilabel(customLayout, 'Text', 'Num:');
            app.NumEditField = uieditfield(customLayout, 'text', 'Value', '[1 2]');
            uilabel(customLayout, 'Text', 'Den:');
            app.DenEditField = uieditfield(customLayout, 'text', 'Value', '[1 3 2 5 0]');
            uibutton(customLayout, 'Text', 'Load', ...
                'ButtonPushedFcn', @(s,e) app.loadCustomSystem());
            uibutton(customLayout, 'Text', 'Import WS', ...
                'ButtonPushedFcn', @(s,e) app.importFromWorkspace());

           
            ctrlPanel = uipanel(sideLayout, 'Title', 'Controller', 'FontWeight', 'bold');
            ctrlLayout = uigridlayout(ctrlPanel, [1 1]);
            app.ControllerDropDown = uidropdown(ctrlLayout, ...
                'Items', {'None', 'PID', 'Lead-Lag'}, ...
                'ValueChangedFcn', @(s,e) app.controllerChanged());

            
            app.ControllerParamsPanel = uipanel(sideLayout, ...
                'Title', 'Parameters', ...
                'Scrollable', 'on');

           
            btnPanel = uipanel(sideLayout);
            btnLayout = uigridlayout(btnPanel, [1 3], 'Padding', [5 5 5 5]);
            uibutton(btnLayout, 'Text', 'Export', ...
                'ButtonPushedFcn', @(s,e) app.exportToSimulink());
            uibutton(btnLayout, 'Text', 'Save', ...
                'ButtonPushedFcn', @(s,e) app.saveSession());
            uibutton(btnLayout, 'Text', 'Load', ...
                'ButtonPushedFcn', @(s,e) app.loadSession());

            
            app.TabGroup = uitabgroup(app.Grid);

            
            app.RootTab = uitab(app.TabGroup, 'Title', 'Root Locus');
            rootLayout = uigridlayout(app.RootTab, [2 1], ...
                'RowHeight', {'1x', 60});
            app.UIAxes = uiaxes(rootLayout);
            bottom = uigridlayout(rootLayout, [1 2], ...
                'ColumnWidth', {'1x', 100});
            app.Slider = uislider(bottom, 'Limits', [0 1], ...
                'ValueChangingFcn', @(s,e) app.sliderChanging(e.Value), ...
                'ValueChangedFcn', @(s,e) app.sliderChanged(e.Value));
            app.KLabel = uilabel(bottom, 'Text', 'k = 0', ...
                'HorizontalAlignment', 'center');

            
            app.FreqTab = uitab(app.TabGroup, 'Title', 'Frequency');
            freqLayout = uigridlayout(app.FreqTab, [2 2], ...
                'RowHeight', {'1x', '1x'}, 'ColumnWidth', {'1x', '1x'});
            app.BodeAxesMag = uiaxes(freqLayout);
            title(app.BodeAxesMag, 'Bode Magnitude'); grid(app.BodeAxesMag, 'on');
            app.BodeAxesPhase = uiaxes(freqLayout);
            title(app.BodeAxesPhase, 'Bode Phase'); grid(app.BodeAxesPhase, 'on');
            app.NyquistAxes = uiaxes(freqLayout);
            title(app.NyquistAxes, 'Nyquist'); grid(app.NyquistAxes, 'on');
            axis(app.NyquistAxes, 'equal');

            app.PerfTab = uitab(app.TabGroup, 'Title', 'Performance');
            perfLayout = uigridlayout(app.PerfTab, [1 1]);
            app.MetricsTable = uitable(perfLayout, ...
                'ColumnName', {'Metric', 'Value'}, ...
                'ColumnWidth', {150, 100}, 'RowName', {});

           
            app.RobustTab = uitab(app.TabGroup, 'Title', 'Robustness');
            robustLayout = uigridlayout(app.RobustTab, [2 2], ...
                'RowHeight', {200, '1x'}, 'ColumnWidth', {'1x', '1x'});
            leftPanel = uipanel(robustLayout, 'Title', 'Parametric Intervals');
            leftGrid = uigridlayout(leftPanel, [3 1], 'RowHeight', {30, '1x', 40});
            app.ParamMinTable = uitable(leftGrid, ...
                'ColumnName', {'Coeff', 'Min'}, 'ColumnEditable', [false true]);
            app.ParamMaxTable = uitable(leftGrid, ...
                'ColumnName', {'Coeff', 'Max'}, 'ColumnEditable', [false true]);
            app.RunRobustButton = uibutton(leftGrid, 'push', ...
                'Text', 'Analyze Uncertainty', ...
                'ButtonPushedFcn', @(s,e) app.runRobustnessAnalysis());
            app.RobustAxes = uiaxes(robustLayout);
            title(app.RobustAxes, 'Uncertainty Region'); grid(app.RobustAxes, 'on');
            axis(app.RobustAxes, 'equal');
            app.RobustTextArea = uitextarea(robustLayout, 'Editable', 'off');
        end

        
        function startupFcn(app)
            s = tf('s');

            app.PredefinedSystems.S1 = models.ControlSystem('System 1', [1 2], [1 3 2 5 0]);
            app.PredefinedSystems.S2 = models.ControlSystem('System 2', 1, [1 2 1 0]);

            app.PredefinedControllers.None = [];
            app.PredefinedControllers.PID = models.PIDController();
            app.PredefinedControllers.Lead = models.LeadLagController();

            app.Session = session.SessionManager();
            addlistener(app.Session, 'SystemChanged', @(src,evt) app.onSystemChanged());
            addlistener(app.Session, 'ControllerParamsChanged', @(src,evt) app.onControllerParamsChanged());
            addlistener(app.Session, 'GainChanged', @(src,evt) app.onGainChanged());

            app.Session.setPlant(app.PredefinedSystems.S1);
            app.updateSliderFromGain(1);
            app.initPlots();
            app.createControllerParamsUI();   % creează slidere după ce Session are controller (None inițial)
        end

        function initPlots(app)
            app.initRootLocusPlot();
            app.updatePlot(app.CurrentAlpha);
            app.updatePerformanceMetrics(app.CurrentAlpha);
            app.updateFrequencyPlots();
        end

        function initRootLocusPlot(app)
            cla(app.UIAxes);
            hold(app.UIAxes, 'on');
            grid(app.UIAxes, 'on');
            axis(app.UIAxes, 'equal');
            xlabel(app.UIAxes, 'Real'); ylabel(app.UIAxes, 'Imaginar');
            title(app.UIAxes, 'Root Locus');

            branches = app.Session.Engine.Branches;
            for b = 1:length(branches)
                col = utils.ColorProvider.getBranchColor(b);
                plot(app.UIAxes, real(branches{b}), imag(branches{b}), ...
                    'Color', col, 'LineWidth', 1.8);
            end
            p_ol = pole(app.Session.LoopGain);
            plot(app.UIAxes, real(p_ol), imag(p_ol), 'x', ...
                'Color', '#a32d2d', 'MarkerSize', 8, 'LineWidth', 2);
            z_ol = zero(app.Session.LoopGain);
            plot(app.UIAxes, real(z_ol), imag(z_ol), 'o', ...
                'Color', '#0f6e56', 'MarkerSize', 8, 'LineWidth', 2);

            [p0, ~] = app.Session.getPolesAtAlpha(0);
            app.PolePlot = plot(app.UIAxes, real(p0), imag(p0), 'o', ...
                'MarkerSize', 9, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'LineWidth', 2);
            hold(app.UIAxes, 'off');
            app.UIAxes.ButtonDownFcn = @(src, evt) app.axesButtonDown(evt);
        end

        function updatePlot(app, alpha)
            [poles, k_val] = app.Session.getPolesAtAlpha(alpha);
            app.PolePlot.XData = real(poles);
            app.PolePlot.YData = imag(poles);
            if all(real(poles) < 0)
                state = 'Stabil'; col = [0 0.6 0];
            elseif any(real(poles) > 0)
                state = 'Instabil'; col = [0.8 0 0];
            else
                state = 'Marginal'; col = [0.9 0.5 0];
            end
            title(app.UIAxes, sprintf('k = %.3f | %s', k_val, state), 'Color', col);
            app.KLabel.Text = sprintf('k = %.3f', k_val);
            app.Session.setGain(k_val);
        end

        function updatePerformanceMetrics(app, alpha)
            [~, k_val] = app.Session.getPolesAtAlpha(alpha);
            T = app.Session.getClosedLoop(k_val);
            L = app.Session.LoopGain;
            metrics = engine.PerformanceAnalyzer.analyze(T, L);
            data = {
                'Rise Time', app.formatNumber(metrics.RiseTime, '%.4f'); ...
                'Settling Time', app.formatNumber(metrics.SettlingTime, '%.4f'); ...
                'Overshoot (%)', app.formatNumber(metrics.Overshoot, '%.2f'); ...
                'Peak Time', app.formatNumber(metrics.PeakTime, '%.4f'); ...
                'Steady-State Error', app.formatNumber(metrics.SteadyStateError, '%.4f'); ...
                'Gain Margin (dB)', app.formatNumber(metrics.GainMargin_dB, '%.2f'); ...
                'Phase Margin (deg)', app.formatNumber(metrics.PhaseMargin_deg, '%.2f'); ...
                'Stable', app.boolToYesNo(metrics.IsStable)
            };
            app.MetricsTable.Data = data;
        end

        function updateFrequencyPlots(app)
            L = app.Session.LoopGain;
            k = app.Session.K;
            [mag, phase, w] = engine.FrequencyAnalyzer.bode(L, k);
            semilogx(app.BodeAxesMag, w, 20*log10(mag)); grid(app.BodeAxesMag, 'on');
            semilogx(app.BodeAxesPhase, w, phase); grid(app.BodeAxesPhase, 'on');
            [re, im] = engine.FrequencyAnalyzer.nyquist(L, k);
            plot(app.NyquistAxes, re, im, 'b-', re, -im, 'b--');
            hold(app.NyquistAxes, 'on');
            plot(app.NyquistAxes, -1, 0, 'rx', 'MarkerSize', 10);
            hold(app.NyquistAxes, 'off'); grid(app.NyquistAxes, 'on');
        end

        function str = formatNumber(~, val, fmt)
            if isnan(val), str = 'NaN';
            elseif isinf(val)
                if val > 0, str = 'Inf'; else, str = '-Inf'; end
            else, str = num2str(val, fmt); end
        end

        function str = boolToYesNo(~, val)
            if val, str = 'Yes'; else, str = 'No'; end
        end

        
        function createControllerParamsUI(app)
            delete(app.ControllerParamsPanel.Children);

            ctrl = app.Session.Controller;
            if isempty(ctrl)
                return;
            end

            params = ctrl.Parameters;
            names = fieldnames(params);
            n = length(names);

            
            inner = uipanel(app.ControllerParamsPanel);
            inner.Units = 'pixels';
            inner.Position = [0 0 260 max(300, n*50)];

            layout = uigridlayout(inner, [n 2], ...
                'RowHeight', repmat({40}, 1, n), ...
                'ColumnWidth', {'1x', '2x'}, ...
                'Padding', [10 10 10 10]);

            app.ParamSliders = struct();

            for i = 1:n
                name = names{i};
                val = params.(name);

                uilabel(layout, 'Text', name, 'HorizontalAlignment', 'right');

                lims = app.getParamLimits(name, val);
                sld = uislider(layout, 'Limits', lims, 'Value', val, ...
                    'ValueChangedFcn', @(s,e) app.onParamSliderChanged(name, e.Value));
                app.ParamSliders.(name) = sld;
            end
        end

        function lims = getParamLimits(~, name, val)
            if contains(name, 'K')
                lims = [0, max(10, 5*abs(val)+1)];
            elseif contains(name, 'z') || contains(name, 'p')
                lims = [-20, 0];
            elseif contains(name, 'N')
                lims = [1, 1000];
            else
                lims = [0, 10];
            end
        end

        function onParamSliderChanged(app, name, value)
            params = app.Session.Controller.Parameters;
            params.(name) = value;
            app.Session.updateControllerParams(params);
            if isfield(app.ParamSliders, name)
                app.ParamSliders.(name).Value = value;
            end
        end

      
        function controllerChanged(app)
            switch app.ControllerDropDown.Value
                case 'None'
                    app.Session.setController([]);
                case 'PID'
                    app.Session.setController(app.PredefinedControllers.PID);
                case 'Lead-Lag'
                    app.Session.setController(app.PredefinedControllers.Lead);
            end
            app.createControllerParamsUI();
        end

        function systemChanged(app)
            if strcmp(app.SystemDropDown.Value, 'Custom')
                app.CustomSystemPanel.Visible = 'on';
            else
                app.CustomSystemPanel.Visible = 'off';
                switch app.SystemDropDown.Value
                    case 'System 1'
                        app.Session.setPlant(app.PredefinedSystems.S1);
                    case 'System 2'
                        app.Session.setPlant(app.PredefinedSystems.S2);
                end
            end
        end

        function loadCustomSystem(app)
            try
                num = eval(app.NumEditField.Value);
                den = eval(app.DenEditField.Value);
                plant = models.ControlSystem('Custom', num, den);
                app.Session.setPlant(plant);
            catch ME
                uialert(app.UIFigure, ME.message, 'Error');
            end
        end

        function importFromWorkspace(app)
            vars = evalin('base', 'who');
            [sel, ok] = listdlg('ListString', vars, 'SelectionMode', 'single', ...
                'PromptString', 'Select TF/SS object:');
            if ok
                obj = evalin('base', vars{sel});
                if isa(obj, 'tf')
                    [num, den] = tfdata(obj, 'v');
                    plant = models.ControlSystem(vars{sel}, num, den);
                elseif isa(obj, 'ss')
                    plant = models.ControlSystem(vars{sel}, obj.A, obj.B, obj.C, obj.D);
                else
                    uialert(app.UIFigure, 'Must be tf or ss.', 'Error');
                    return;
                end
                app.Session.setPlant(plant);
            end
        end

        function sliderChanging(app, val)
            app.updatePlot(val);
            app.CurrentAlpha = val;
        end

        function sliderChanged(app, val)
            app.updatePerformanceMetrics(val);
            app.updateFrequencyPlots();
        end

        function onSystemChanged(app)
            app.initRootLocusPlot();
            app.updatePlot(app.CurrentAlpha);
            app.updatePerformanceMetrics(app.CurrentAlpha);
            app.updateFrequencyPlots();
        end

        function onControllerParamsChanged(app)
            app.initRootLocusPlot();
            app.updatePlot(app.CurrentAlpha);
            app.updatePerformanceMetrics(app.CurrentAlpha);
            app.updateFrequencyPlots();
        end

        function onGainChanged(app)
           
        end

       
        function axesButtonDown(app, ~)
            cp = app.UIAxes.CurrentPoint;
            click = cp(1,1) + 1i*cp(1,2);
            poles = app.PolePlot.XData + 1i*app.PolePlot.YData;
            [md, idx] = min(abs(poles - click));
            if md < 0.1*(app.UIAxes.XLim(2) - app.UIAxes.XLim(1))
                app.IsDragging = true;
                app.UIFigure.WindowButtonMotionFcn = @(s,e) app.draggingPole(idx);
                app.UIFigure.WindowButtonUpFcn = @(s,e) app.stopDragging();
            end
        end

        function draggingPole(app, idx)
            cp = app.UIAxes.CurrentPoint;
            target = cp(1,1) + 1i*cp(1,2);
            alpha = app.findAlphaForPole(idx, target);
            if ~isnan(alpha)
                app.Slider.Value = alpha;
                app.updatePlot(alpha);
                app.CurrentAlpha = alpha;
            end
        end

        function stopDragging(app)
            app.IsDragging = false;
            app.UIFigure.WindowButtonMotionFcn = '';
            app.UIFigure.WindowButtonUpFcn = '';
            app.updatePerformanceMetrics(app.CurrentAlpha);
            app.updateFrequencyPlots();
        end

        function alpha = findAlphaForPole(app, branchIdx, target)
            nPts = length(app.Session.Engine.GainVector);
            bestAlpha = NaN;
            bestDist = inf;
            for a = linspace(0, 1, nPts)
                [poles, ~] = app.Session.getPolesAtAlpha(a);
                d = abs(poles(branchIdx) - target);
                if d < bestDist
                    bestDist = d;
                    bestAlpha = a;
                end
            end
            alpha = bestAlpha;
        end

       
        function runRobustnessAnalysis(app)
            den_nom = cell2mat(app.Session.Plant.G_tf.Denominator);
            n = length(den_nom);
            if isempty(app.ParamMinTable.Data)
                coeffs = arrayfun(@(i) sprintf('a_%d',i-1), 1:n, 'UniformOutput', false)';
                app.ParamMinTable.Data = [coeffs, num2cell(den_nom')];
                app.ParamMaxTable.Data = [coeffs, num2cell(den_nom')];
            end
            dmin = cell2mat(app.ParamMinTable.Data(:,2))';
            dmax = cell2mat(app.ParamMaxTable.Data(:,2))';
            unc = engine.ParametricUncertainty(den_nom, dmin, dmax);
            [stable, worst] = unc.checkKharitonov();
            cla(app.RobustAxes);
            unc.plotUncertaintyRegion(app.RobustAxes, app.Session.K);
            if stable
                app.RobustTextArea.Value = 'Robustly stable.';
            else
                app.RobustTextArea.Value = sprintf('Possible instability. Poles: %s', mat2str(worst,3));
            end
        end

       
        function exportToSimulink(app)
            mdl = 'RobustCAD_Model';
            if bdIsLoaded(mdl), close_system(mdl,0); end
            new_system(mdl); open_system(mdl);
            add_block('simulink/Sources/Step', [mdl '/Step']);
            add_block('simulink/Continuous/Transfer Fcn', [mdl '/Plant']);
            add_block('simulink/Continuous/Transfer Fcn', [mdl '/Controller']);
            add_block('simulink/Math Operations/Sum', [mdl '/Sum']);
            add_block('simulink/Sinks/Scope', [mdl '/Scope']);
            set_param([mdl '/Plant'], 'Numerator', mat2str(cell2mat(app.Session.Plant.G_tf.Numerator)));
            set_param([mdl '/Plant'], 'Denominator', mat2str(cell2mat(app.Session.Plant.G_tf.Denominator)));
            if ~isempty(app.Session.Controller)
                D = app.Session.Controller.getTransferFunction();
                set_param([mdl '/Controller'], 'Numerator', mat2str(cell2mat(D.Numerator)));
                set_param([mdl '/Controller'], 'Denominator', mat2str(cell2mat(D.Denominator)));
            else
                set_param([mdl '/Controller'], 'Numerator', '[1]', 'Denominator', '[1]');
            end
            add_line(mdl, 'Step/1', 'Sum/1');
            add_line(mdl, 'Sum/1', 'Controller/1');
            add_line(mdl, 'Controller/1', 'Plant/1');
            add_line(mdl, 'Plant/1', 'Scope/1');
            add_line(mdl, 'Plant/1', 'Sum/2');
            save_system(mdl);
            msgbox('Model exported.', 'Success');
        end

        function saveSession(app)
            data.Plant = app.Session.Plant;
            data.Controller = app.Session.Controller;
            [f, p] = uiputfile('*.mat', 'Save Session');
            if ischar(f)
                save(fullfile(p, f), 'data');
            end
        end

        function loadSession(app)
            [f, p] = uigetfile('*.mat', 'Load Session');
            if ischar(f)
                ld = load(fullfile(p, f), 'data');
                if isfield(ld.data, 'Plant')
                    app.Session.setPlant(ld.data.Plant);
                end
                if isfield(ld.data, 'Controller')
                    app.Session.setController(ld.data.Controller);
                  
                    if isa(ld.data.Controller, 'models.PIDController')
                        app.ControllerDropDown.Value = 'PID';
                    elseif isa(ld.data.Controller, 'models.LeadLagController')
                        app.ControllerDropDown.Value = 'Lead-Lag';
                    else
                        app.ControllerDropDown.Value = 'None';
                    end
                    app.createControllerParamsUI();
                end
                app.updateSliderFromGain(app.Session.K);
            end
        end

        function updateSliderFromGain(app, k)
            gv = app.Session.Engine.GainVector;
            [~, idx] = min(abs(gv - k));
            alpha = (idx-1) / (length(gv)-1);
            app.Slider.Value = alpha;
            app.CurrentAlpha = alpha;
        end
    end
end