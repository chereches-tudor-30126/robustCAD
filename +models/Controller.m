classdef (Abstract) Controller < handle
    properties (Abstract)
        Name
        Parameters
    end
    
    methods (Abstract)
        D = getTransferFunction(obj)
        updateParameters(obj, params)
    end
end