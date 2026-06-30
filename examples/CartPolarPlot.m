classdef CartPolarPlot < gleamoe.graphics.chartcontainer.ChartContainer
    %CartPolarPlot Multi-axes layout example inspired by MathWorks getLayout examples.
    % Source: https://www.mathworks.com/help/matlab/ref/matlab.graphics.chartcontainer.chartcontainer.getlayout.html

    properties
        XData = linspace(0, 2*pi, 160)
        YData = sin(linspace(0, 2*pi, 160))
        ThetaData = linspace(0, 2*pi, 160)
        RhoData = 1 + 0.35 * sin(4 * linspace(0, 2*pi, 160))
    end

    properties (Access = private)
        CartesianAxes
        PolarAxes
        CartesianLine
        PolarLine
    end

    methods
        function this = CartPolarPlot(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function set.XData(this, value)
            this.XData = value(:).';
            requestUpdate(this);
        end

        function set.YData(this, value)
            this.YData = value(:).';
            requestUpdate(this);
        end

        function set.ThetaData(this, value)
            this.ThetaData = value(:).';
            requestUpdate(this);
        end

        function set.RhoData(this, value)
            this.RhoData = value(:).';
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            layout = getLayout(this);
            layout.GridSize = [1 2];

            this.CartesianAxes = createAxes(this, 'Tile', 1);
            this.PolarAxes = createAxes(this, 'Type', 'polar', 'Tile', 2);

            recreateCartesianLine(this);
            grid(this.CartesianAxes, 'on');
            title(this.CartesianAxes, 'Cartesian');

            recreatePolarLine(this);
        end

        function update(this)
            if numel(this.XData) ~= numel(this.YData)
                error('gleamoe:examples:DataSize', 'XData and YData must have the same number of elements.');
            end
            if numel(this.ThetaData) ~= numel(this.RhoData)
                error('gleamoe:examples:DataSize', 'ThetaData and RhoData must have the same number of elements.');
            end

            try
                set(this.CartesianLine, 'XData', this.XData, 'YData', this.YData);
            catch
                recreateCartesianLine(this);
            end

            try
                set(this.PolarLine, 'ThetaData', this.ThetaData, 'RData', this.RhoData);
            catch
                x = this.RhoData .* cos(this.ThetaData);
                y = this.RhoData .* sin(this.ThetaData);
                try
                    set(this.PolarLine, 'XData', x, 'YData', y);
                    axis(this.PolarAxes, 'equal');
                catch
                    recreatePolarLine(this);
                end
            end
        end
    end

    methods (Access = private)
        function recreateCartesianLine(this)
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.CartesianLine);
            this.CartesianLine = plot(this.CartesianAxes, this.XData, this.YData, ...
                'LineWidth', 1.6, ...
                'Color', [0.0000 0.4470 0.7410]);
        end

        function recreatePolarLine(this)
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.PolarLine);
            try
                this.PolarLine = polarplot(this.PolarAxes, this.ThetaData, this.RhoData, ...
                    'LineWidth', 1.6, ...
                    'Color', [0.8500 0.3250 0.0980]);
                title(this.PolarAxes, 'Polar');
            catch
                x = this.RhoData .* cos(this.ThetaData);
                y = this.RhoData .* sin(this.ThetaData);
                this.PolarLine = plot(this.PolarAxes, x, y, ...
                    'LineWidth', 1.6, ...
                    'Color', [0.8500 0.3250 0.0980]);
                axis(this.PolarAxes, 'equal');
                title(this.PolarAxes, 'Polar fallback');
            end
        end
    end
end
