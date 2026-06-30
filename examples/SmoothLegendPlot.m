classdef SmoothLegendPlot < gleamoe.graphics.chartcontainer.ChartContainer & gleamoe.graphics.chartcontainer.mixin.Legend
    %SmoothLegendPlot Legend mixin example inspired by MathWorks documentation.
    % Source: https://www.mathworks.com/help/matlab/ref/matlab.graphics.chartcontainer.mixin.legend-class.html

    properties
        XData = 1:80
        YData = sin((1:80) / 7) + 0.18 * cos((1:80) / 2)
        SmoothSpan = 9
    end

    properties (Access = private)
        RawLine
        SmoothLine
    end

    methods
        function this = SmoothLegendPlot(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function delete(~)
        end

        function set.XData(this, value)
            this.XData = value(:).';
            requestUpdate(this);
        end

        function set.YData(this, value)
            this.YData = value(:).';
            requestUpdate(this);
        end

        function set.SmoothSpan(this, value)
            if ~isnumeric(value) || ~isscalar(value) || value < 1
                error('gleamoe:examples:SmoothSpan', 'SmoothSpan must be a positive scalar.');
            end
            this.SmoothSpan = round(double(value));
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            ax = getAxes(this);
            hold(ax, 'on');
            [x, y, smoothed] = preparedData(this);
            recreateLines(this, ax, x, y, smoothed);
            grid(ax, 'on');
            xlabel(ax, 'Sample');
            ylabel(ax, 'Value');
            title(ax, 'SmoothLegendPlot');
        end

        function update(this)
            [x, y, smoothed] = preparedData(this);
            try
                set(this.RawLine, 'XData', x, 'YData', y);
                set(this.SmoothLine, 'XData', x, 'YData', smoothed);
            catch
                recreateLines(this, getAxes(this), x, y, smoothed);
            end

            if strcmpi(this.LegendVisible, 'on')
                getLegend(this);
            end
        end
    end

    methods (Access = private)
        function [x, y, smoothed] = preparedData(this)
            x = this.XData(:).';
            y = this.YData(:).';
            if numel(x) ~= numel(y)
                error('gleamoe:examples:DataSize', 'XData and YData must have the same number of elements.');
            end

            smoothed = localMovingAverage(y, this.SmoothSpan);
        end

        function recreateLines(this, ax, x, y, smoothed)
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.RawLine);
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.SmoothLine);
            this.RawLine = plot(ax, x, y, ...
                'LineStyle', '-', ...
                'Color', [0.55 0.55 0.55], ...
                'DisplayName', 'Raw');
            this.SmoothLine = plot(ax, x, smoothed, ...
                'LineWidth', 2.0, ...
                'Color', [0.8500 0.3250 0.0980], ...
                'DisplayName', 'Smoothed');
        end
    end
end

function y = localMovingAverage(x, span)
    span = max(1, min(numel(x), round(span)));
    kernel = ones(1, span) / span;
    y = conv(x, kernel, 'same');
end
