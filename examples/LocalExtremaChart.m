classdef LocalExtremaChart < gleamoe.graphics.chartcontainer.ChartContainer
    %LocalExtremaChart Dynamic graphics-count example inspired by MathWorks documentation.
    % Source: https://www.mathworks.com/help/matlab/creating_plots/chart-development-overview.html

    properties
        XData = 1:100
        YData = sin((1:100) / 8) + 0.25 * sin((1:100) / 2)
        ShowMinima = 'on'
        ShowMaxima = 'on'
    end

    properties (Access = private)
        DataLine
        MinimaLine
        MaximaLine
    end

    methods
        function this = LocalExtremaChart(varargin)
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

        function set.ShowMinima(this, value)
            this.ShowMinima = gleamoe.graphics.chartcontainer.internal.mustBeOnOff(value, 'ShowMinima');
            requestUpdate(this);
        end

        function set.ShowMaxima(this, value)
            this.ShowMaxima = gleamoe.graphics.chartcontainer.internal.mustBeOnOff(value, 'ShowMaxima');
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            ax = getAxes(this);
            hold(ax, 'on');
            [x, y, isMin, isMax] = preparedData(this);
            recreateLines(this, ax, x, y, isMin, isMax);
            grid(ax, 'on');
            title(ax, 'LocalExtremaChart');
        end

        function update(this)
            [x, y, isMin, isMax] = preparedData(this);
            try
                set(this.DataLine, 'XData', x, 'YData', y);
                set(this.MinimaLine, 'XData', x(isMin), 'YData', y(isMin), 'Visible', this.ShowMinima);
                set(this.MaximaLine, 'XData', x(isMax), 'YData', y(isMax), 'Visible', this.ShowMaxima);
            catch
                recreateLines(this, getAxes(this), x, y, isMin, isMax);
            end
        end
    end

    methods (Access = private)
        function [x, y, isMin, isMax] = preparedData(this)
            x = this.XData(:).';
            y = this.YData(:).';
            if numel(x) ~= numel(y)
                error('gleamoe:examples:DataSize', 'XData and YData must have the same number of elements.');
            end

            [isMin, isMax] = localExtrema(y);
        end

        function recreateLines(this, ax, x, y, isMin, isMax)
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.DataLine);
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.MinimaLine);
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.MaximaLine);
            this.DataLine = plot(ax, x, y, ...
                'LineWidth', 1.3, ...
                'Color', [0.0000 0.4470 0.7410], ...
                'DisplayName', 'Data');
            this.MaximaLine = plot(ax, x(isMax), y(isMax), '^', ...
                'MarkerFaceColor', [0.8500 0.3250 0.0980], ...
                'MarkerEdgeColor', [0.8500 0.3250 0.0980], ...
                'LineStyle', 'none', ...
                'Visible', this.ShowMaxima, ...
                'DisplayName', 'Local maxima');
            this.MinimaLine = plot(ax, x(isMin), y(isMin), 'v', ...
                'MarkerFaceColor', [0.4660 0.6740 0.1880], ...
                'MarkerEdgeColor', [0.4660 0.6740 0.1880], ...
                'LineStyle', 'none', ...
                'Visible', this.ShowMinima, ...
                'DisplayName', 'Local minima');
        end
    end
end

function [isMin, isMax] = localExtrema(y)
    isMin = false(size(y));
    isMax = false(size(y));
    if numel(y) < 3
        return
    end
    mid = 2:numel(y)-1;
    isMax(mid) = y(mid) >= y(mid - 1) & y(mid) > y(mid + 1);
    isMin(mid) = y(mid) <= y(mid - 1) & y(mid) < y(mid + 1);
end
