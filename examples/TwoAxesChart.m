classdef TwoAxesChart < gleamoe.graphics.chartcontainer.ChartContainer
    %TwoAxesChart Degraded multi-axes example for platforms without tiledlayout.

    properties
        XData = linspace(0, 10, 120)
        LeftData = sin(linspace(0, 10, 120))
        RightData = exp(linspace(0, 2, 120))
    end

    properties (Access = private)
        LeftAxes
        RightAxes
        LeftLine
        RightLine
    end

    methods
        function this = TwoAxesChart(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function set.XData(this, value)
            this.XData = value(:).';
            requestUpdate(this);
        end

        function set.LeftData(this, value)
            this.LeftData = value(:).';
            requestUpdate(this);
        end

        function set.RightData(this, value)
            this.RightData = value(:).';
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            layout = getLayout(this);
            layout.GridSize = [1 1];
            this.LeftAxes = createAxes(this, 'Tile', 1);
            this.RightAxes = createAxes(this, 'Tile', 1);
            hold(this.LeftAxes, 'on');

            recreateLines(this);
            gleamoe.graphics.chartcontainer.internal.safeSet(this.RightAxes, 'Color', 'none');
            gleamoe.graphics.chartcontainer.internal.safeSet(this.RightAxes, 'YAxisLocation', 'right');
            title(this.LeftAxes, 'TwoAxesChart');
        end

        function update(this)
            if numel(this.XData) ~= numel(this.LeftData) || numel(this.XData) ~= numel(this.RightData)
                error('gleamoe:examples:DataSize', 'All data vectors must have the same number of elements.');
            end
            try
                set(this.LeftLine, 'XData', this.XData, 'YData', this.LeftData);
                set(this.RightLine, 'XData', this.XData, 'YData', this.RightData);
            catch
                recreateLines(this);
            end
            gleamoe.graphics.chartcontainer.internal.safeSet(this.RightAxes, 'XLim', get(this.LeftAxes, 'XLim'));
        end
    end

    methods (Access = private)
        function recreateLines(this)
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.LeftLine);
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.RightLine);
            this.LeftLine = plot(this.LeftAxes, this.XData, this.LeftData, ...
                'LineWidth', 1.5, ...
                'Color', [0.0000 0.4470 0.7410]);
            this.RightLine = plot(this.RightAxes, this.XData, this.RightData, ...
                'LineWidth', 1.5, ...
                'Color', [0.8500 0.3250 0.0980]);
            gleamoe.graphics.chartcontainer.internal.safeSet(this.RightAxes, 'Color', 'none');
            gleamoe.graphics.chartcontainer.internal.safeSet(this.RightAxes, 'YAxisLocation', 'right');
        end
    end
end
