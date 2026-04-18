classdef FrequencyAnalyzer < handle
    methods (Static)
        function [mag, phase, wout] = bode(L, k)
            if nargin < 2
                k = 1;
            end
            [mag, phase, wout] = bode(L * k);
            mag = squeeze(mag);
            phase = squeeze(phase);
        end
        
        function [GM, PM, Wcg, Wcp] = margins(L)
            [GM, PM, Wcg, Wcp] = margin(L);
        end
        
        function [re, im, wout] = nyquist(L, k)
            if nargin < 2
                k = 1;
            end
            [re, im, wout] = nyquist(L * k);
            re = squeeze(re);
            im = squeeze(im);
        end
    end
end