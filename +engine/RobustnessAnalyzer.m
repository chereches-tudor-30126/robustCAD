classdef RobustnessAnalyzer < handle
    methods (Static)
        function [stable, worstPoles] = kharitonovStability(num_interval, den_interval)
            % Această metodă este păstrată pentru compatibilitate,
            % dar recomandăm utilizarea clasei ParametricUncertainty.
            d_min = den_interval.min;
            d_max = den_interval.max;
            unc = engine.ParametricUncertainty([], d_min, d_max);
            [stable, worstPoles] = unc.checkKharitonov();
        end
    end
end