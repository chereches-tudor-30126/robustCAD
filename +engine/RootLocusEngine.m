classdef RootLocusEngine < handle
    properties (SetAccess = private)
        LoopGain                
        Branches                
        GainVector              
    end
    
    methods
        function obj = RootLocusEngine(L, numPoints)
          
            if nargin < 2
                numPoints = 600;
            end
            obj.LoopGain = L;
            
         
            k_min = 0.01;
            k_max = 100;
            obj.GainVector = logspace(log10(k_min), log10(k_max), numPoints);
            
           
            [r, ~] = rlocus(L, obj.GainVector);
            
          
            obj.Branches = obj.sortPolesIntoBranches(r);
        end
        
        function [poles, k_val] = getPolesAtGain(obj, alpha)
          
            idx = max(1, min(length(obj.GainVector), round(alpha * length(obj.GainVector))));
            poles = zeros(length(obj.Branches), 1);
            for b = 1:length(obj.Branches)
                poles(b) = obj.Branches{b}(idx);
            end
            k_val = obj.GainVector(idx);
        end
        
        function k_max = getMaxGain(obj)
            k_max = obj.GainVector(end);
        end
    end
    
    methods (Access = private)
        function branches = sortPolesIntoBranches(obj, r)
           
            [nPoles, nGains] = size(r);
            branches = cell(nPoles, 1);
            
          
            current = r(:, 1);
            for b = 1:nPoles
                branches{b} = zeros(nGains, 1);
                branches{b}(1) = current(b);
            end
            
           
            for kIdx = 2:nGains
                nextPoles = r(:, kIdx);
                assigned = false(nPoles, 1);
                
                for b = 1:nPoles
                    lastPole = branches{b}(kIdx-1);
                    bestIdx = 0;
                    bestDist = inf;
                    for p = 1:nPoles
                        if ~assigned(p)
                            dist = abs(nextPoles(p) - lastPole);
                            if dist < bestDist
                                bestDist = dist;
                                bestIdx = p;
                            end
                        end
                    end
                    assigned(bestIdx) = true;
                    branches{b}(kIdx) = nextPoles(bestIdx);
                end
            end
        end
    end
end