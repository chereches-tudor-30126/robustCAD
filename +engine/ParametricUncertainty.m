classdef ParametricUncertainty < handle
    properties
        DenominatorNominal
        DenominatorIntervals  
    end
    
    methods
        function obj = ParametricUncertainty(den_nom, den_min, den_max)
            if nargin > 0
                obj.DenominatorNominal = den_nom;
                obj.DenominatorIntervals.min = den_min;
                obj.DenominatorIntervals.max = den_max;
            end
        end
        
        function [stable, worstPoles] = checkKharitonov(obj)
            d_min = obj.DenominatorIntervals.min;
            d_max = obj.DenominatorIntervals.max;
            n = length(d_min);
            
            K1 = zeros(1,n);
            K2 = zeros(1,n);
            K3 = zeros(1,n);
            K4 = zeros(1,n);
            
            for i = 1:n
                if mod(i,2) == 1
                    K1(i) = d_min(i);
                    K2(i) = d_max(i);
                    K3(i) = d_min(i);
                    K4(i) = d_max(i);
                else
                    K1(i) = d_max(i);
                    K2(i) = d_min(i);
                    K3(i) = d_min(i);
                    K4(i) = d_max(i);
                end
            end
            
            stable = true;
            worstPoles = [];
            for poly = {K1, K2, K3, K4}
                r = roots(poly{1});
                if any(real(r) >= 0)
                    stable = false;
                    worstPoles = [worstPoles; r(real(r) >= 0)];
                end
            end
        end
        
        function plotUncertaintyRegion(obj, ax, k)
            if nargin < 3
                k = 1;
            end
            d_min = obj.DenominatorIntervals.min;
            d_max = obj.DenominatorIntervals.max;
            samples = 10;
            allPoles = [];
            for i = 1:samples
                alpha = (i-1)/(samples-1);
                d = d_min + alpha*(d_max - d_min);
                r = roots(d);
                allPoles = [allPoles; r];
            end
            if ~isempty(allPoles) && length(allPoles) >= 3
                try
                    k_conv = convhull(real(allPoles), imag(allPoles));
                    patch(ax, real(allPoles(k_conv)), imag(allPoles(k_conv)), ...
                        'r', 'FaceAlpha', 0.1, 'EdgeColor', 'r', 'LineStyle', '--');
                catch
                    % ignore
                end
            end
        end
    end
end