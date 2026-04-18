classdef StateFeedbackController < models.Controller
    properties
        Name = 'State Feedback'
        Parameters = struct('K', [], 'P', [])
    end
    
    methods
        function D = getTransferFunction(obj)
            D = tf(0);
        end
        
        function updateParameters(obj, params)
            obj.Parameters.K = params.K;
            obj.Parameters.P = params.P;
        end
    end
end