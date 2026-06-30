classdef ConfidenceChart < gleamoe.graphics.chartcontainer.ChartContainer
    %ConfidenceChart Confidence band chart inspired by MathWorks ChartContainer examples.
    % Source: https://www.mathworks.com/help/matlab/creating_plots/writing-constructors-for-chart-classes.html

    properties
        XData = 1:20
        YData = sin((1:20) / 3)
        ConfidenceMargin = 0.2
        LineColor = [0.0000 0.4470 0.7410]
    end

    properties (Access = private)
        MainLine
        ConfidencePatch
    end

    methods
        function this = ConfidenceChart(varargin)
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

        function set.ConfidenceMargin(this, value)
            if ~isnumeric(value) || isempty(value) || any(value(:) < 0)
                error('gleamoe:examples:ConfidenceMargin', ...
                    'ConfidenceMargin must be a nonnegative numeric value.');
            end
            this.ConfidenceMargin = value;
            requestUpdate(this);
        end

        function set.LineColor(this, value)
            if ~isnumeric(value) || numel(value) ~= 3
                error('gleamoe:examples:LineColor', 'LineColor must be a 1-by-3 RGB vector.');
            end
            this.LineColor = reshape(double(value), 1, 3);
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            ax = getAxes(this);
            hold(ax, 'on');
            [x, y, upper, lower] = preparedData(this);
            recreateGraphics(this, ax, x, y, upper, lower);
            grid(ax, 'on');
            xlabel(ax, 'X');
            ylabel(ax, 'Y');
            title(ax, 'ConfidenceChart');
        end

        function update(this)
            [x, y, upper, lower] = preparedData(this);
            try
                set(this.ConfidencePatch, ...
                    'XData', [x fliplr(x)], ...
                    'YData', [upper fliplr(lower)], ...
                    'FaceColor', this.LineColor);
                set(this.MainLine, 'XData', x, 'YData', y, 'Color', this.LineColor);
            catch
                recreateGraphics(this, getAxes(this), x, y, upper, lower);
            end
        end
    end

    methods (Access = private)
        function [x, y, upper, lower] = preparedData(this)
            x = this.XData(:).';
            y = this.YData(:).';
            if numel(x) ~= numel(y)
                error('gleamoe:examples:DataSize', 'XData and YData must have the same number of elements.');
            end

            margin = this.ConfidenceMargin;
            if isscalar(margin)
                margin = repmat(margin, size(y));
            else
                margin = margin(:).';
                if numel(margin) ~= numel(y)
                    error('gleamoe:examples:DataSize', ...
                        'ConfidenceMargin must be scalar or match YData length.');
                end
            end

            upper = y + margin;
            lower = y - margin;
        end

        function recreateGraphics(this, ax, x, y, upper, lower)
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.ConfidencePatch);
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.MainLine);
            this.ConfidencePatch = patch(ax, [x fliplr(x)], [upper fliplr(lower)], this.LineColor, ...
                'FaceAlpha', 0.18, ...
                'EdgeColor', 'none', ...
                'DisplayName', 'Confidence band');
            this.MainLine = plot(ax, x, y, ...
                'LineWidth', 1.8, ...
                'Color', this.LineColor, ...
                'DisplayName', 'Mean');
        end
    end
end
