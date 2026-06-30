classdef CounterChart < gleamoe.graphics.chartcontainer.ChartContainer
    %CounterChart Non-graphics test fixture for ChartContainer lifecycle.

    properties
        Value = 0
        Label = 'counter'
    end

    properties (SetAccess = private)
        SetupCount = 0
        UpdateCount = 0
    end

    methods
        function this = CounterChart(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function set.Value(this, value)
            if ~isnumeric(value) || ~isscalar(value)
                error('gleamoe:tests:Value', 'Value must be a numeric scalar.');
            end
            this.Value = value;
            requestUpdate(this);
        end

        function set.Label(this, value)
            this.Label = gleamoe.graphics.chartcontainer.internal.mustBeText(value, 'Label');
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            this.SetupCount = this.SetupCount + 1;
        end

        function update(this)
            this.UpdateCount = this.UpdateCount + 1;
        end
    end
end
