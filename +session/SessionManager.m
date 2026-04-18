classdef SessionManager < handle
    properties (SetObservable)
        Plant
        Controller
        K           
    end
    properties (SetAccess = private)
        LoopGain
        Engine
    end
    
    events
        SystemChanged
        ControllerParamsChanged
        GainChanged
    end
    
    methods
        function obj = SessionManager()
            obj.K = 1;
        end
        
        function setPlant(obj, plant)
            obj.Plant = plant;
            obj.rebuildLoopGain();
            notify(obj, 'SystemChanged');
        end
        
        function setController(obj, ctrl)
            obj.Controller = ctrl;
            obj.rebuildLoopGain();
            notify(obj, 'SystemChanged');
        end
        
        function updateControllerParams(obj, params)
            if ~isempty(obj.Controller)
                obj.Controller.updateParameters(params);
                obj.rebuildLoopGain();
                notify(obj, 'ControllerParamsChanged');
            end
        end
        
        function setGain(obj, k)
            obj.K = k;
            notify(obj, 'GainChanged');
        end
        
        function rebuildLoopGain(obj)
            if isempty(obj.Plant)
                return;
            end
            G = obj.Plant.getTF();
            if ~isempty(obj.Controller)
                if isa(obj.Controller, 'models.StateFeedbackController')
                    D = 1;
                else
                    D = obj.Controller.getTransferFunction();
                end
            else
                D = 1;
            end
            obj.LoopGain = series(D, G);
            obj.Engine = engine.RootLocusEngine(obj.LoopGain);
        end
        
        function [poles, k] = getPolesAtAlpha(obj, alpha)
            [poles, k] = obj.Engine.getPolesAtGain(alpha);
        end
        
        function T = getClosedLoop(obj, k)
            if nargin < 2
                k = obj.K;
            end
            T = feedback(k * obj.LoopGain, 1);
        end
    end
end