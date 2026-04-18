classdef LeadLagController < models.Controller
    properties
        Name = 'Lead-Lag'
        Parameters = struct('Kc', 1, 'z', -1, 'p', -5)
    end
    
    methods
        function D = getTransferFunction(obj)
            s = tf('s');
            Kc = obj.Parameters.Kc;
            z  = obj.Parameters.z;
            p  = obj.Parameters.p;
            D = Kc * (s - z) / (s - p);
        end
        
        function updateParameters(obj, params)
            obj.Parameters.Kc = params.Kc;
            obj.Parameters.z  = params.z;
            obj.Parameters.p  = params.p;
        end
    end
end