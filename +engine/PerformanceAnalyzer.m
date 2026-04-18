classdef PerformanceAnalyzer < handle
    methods (Static)
        function metrics = analyze(T, L)
            % T: buclă închisă, L: buclă deschisă
            metrics = struct();
            
            % Răspuns indicial
            try
                info = stepinfo(T);
                metrics.RiseTime     = info.RiseTime;
                metrics.SettlingTime = info.SettlingTime;
                metrics.Overshoot    = info.Overshoot;
                metrics.PeakTime     = info.PeakTime;
            catch
                metrics.RiseTime     = NaN;
                metrics.SettlingTime = NaN;
                metrics.Overshoot    = NaN;
                metrics.PeakTime     = NaN;
            end
            
            % Eroare staționară la treaptă unitară
            Kv = dcgain(L);
            if isinf(Kv) || Kv == 0 || isnan(Kv)
                metrics.SteadyStateError = NaN;
            else
                metrics.SteadyStateError = 1 / (1 + Kv);
            end
            
            % Marje de stabilitate
            try
                [GM, PM, Wcg, Wcp] = margin(L);
                if isinf(GM)
                    metrics.GainMargin_dB = Inf;
                else
                    metrics.GainMargin_dB = 20*log10(GM);
                end
                metrics.PhaseMargin_deg = PM;
                metrics.GainCrossover   = Wcg;
                metrics.PhaseCrossover  = Wcp;
            catch
                metrics.GainMargin_dB   = NaN;
                metrics.PhaseMargin_deg = NaN;
                metrics.GainCrossover   = NaN;
                metrics.PhaseCrossover  = NaN;
            end
            
            % Stabilitate
            poles_T = pole(T);
            metrics.IsStable = all(real(poles_T) < 0);
        end
    end
end