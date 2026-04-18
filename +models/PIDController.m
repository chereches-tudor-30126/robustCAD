classdef PIDController < models.Controller
    properties
        Name = 'PID'
        Parameters = struct('Kp', 1, 'Ki', 0, 'Kd', 0, 'N', 100)
    end
    
    methods
        function D = getTransferFunction(obj)
            s = tf('s');
            Kp = obj.Parameters.Kp;
            Ki = obj.Parameters.Ki;
            Kd = obj.Parameters.Kd;
            N  = obj.Parameters.N;
            D = Kp + Ki/s + Kd * s/(1 + s/N);
        end
        
        function updateParameters(obj, params)
            obj.Parameters.Kp = params.Kp;
            obj.Parameters.Ki = params.Ki;
            obj.Parameters.Kd = params.Kd;
            if isfield(params, 'N')
                obj.Parameters.N = params.N;
            end
        end
    end
end