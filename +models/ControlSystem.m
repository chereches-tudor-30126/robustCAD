classdef ControlSystem < handle
    properties (SetAccess = private)
        Name
        G_tf
        G_ss
        Type
    end
    
    methods
        function obj = ControlSystem(name, varargin)
            obj.Name = name;
            if nargin == 3      % num, den
                num = varargin{1};
                den = varargin{2};
                obj.G_tf = tf(num, den);
                obj.G_ss = ss(obj.G_tf);
                obj.Type = 'tf';
            elseif nargin == 5  % A, B, C, D
                A = varargin{1}; B = varargin{2};
                C = varargin{3}; D = varargin{4};
                obj.G_ss = ss(A, B, C, D);
                obj.G_tf = tf(obj.G_ss);
                obj.Type = 'ss';
            else
                error('Număr incorect de argumente.');
            end
        end
        
        function tf_out = getTF(obj)
            tf_out = obj.G_tf;
        end
        
        function ss_out = getSS(obj)
            ss_out = obj.G_ss;
        end
    end
end