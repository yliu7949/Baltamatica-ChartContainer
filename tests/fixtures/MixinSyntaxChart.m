classdef MixinSyntaxChart < CounterChart & gleamoe.graphics.chartcontainer.mixin.Legend & gleamoe.graphics.chartcontainer.mixin.Colorbar
    %MixinSyntaxChart Verifies MATLAB-style mixin inheritance parses.

    methods
        function this = MixinSyntaxChart(varargin)
            this@CounterChart(varargin{:});
        end

        function delete(this)
            %#ok<INUSD>
        end
    end
end
