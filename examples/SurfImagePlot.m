classdef SurfImagePlot < gleamoe.graphics.chartcontainer.ChartContainer & gleamoe.graphics.chartcontainer.mixin.Colorbar
    %SurfImagePlot Colorbar mixin example inspired by MathWorks documentation.
    % Source: https://www.mathworks.com/help/matlab/ref/matlab.graphics.chartcontainer.mixin.colorbar-class.html

    properties
        ZData = []
        ColormapName = 'parula'
    end

    properties (Access = private)
        Surface
    end

    methods
        function this = SurfImagePlot(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function delete(this)
            %#ok<INUSD>
        end

        function set.ZData(this, value)
            if ~isnumeric(value) || ~ismatrix(value)
                error('gleamoe:examples:ZData', 'ZData must be a numeric matrix.');
            end
            this.ZData = value;
            requestUpdate(this);
        end

        function set.ColormapName(this, value)
            this.ColormapName = gleamoe.graphics.chartcontainer.internal.mustBeText(value, 'ColormapName');
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            ax = getAxes(this);
            [x, y, z] = preparedData(this);
            recreateSurface(this, ax, x, y, z);
            view(ax, 2);
            axis(ax, 'tight');
            title(ax, 'SurfImagePlot');
        end

        function update(this)
            [x, y, z] = preparedData(this);
            try
                set(this.Surface, 'XData', x, 'YData', y, 'ZData', z);
                try
                    set(this.Surface, 'CData', z);
                catch
                end
            catch
                recreateSurface(this, getAxes(this), x, y, z);
            end

            ax = getAxes(this);
            axis(ax, 'tight');
            try
                colormap(ax, this.ColormapName);
            catch
                try
                    colormap(this.ColormapName);
                catch
                end
            end

            if strcmpi(this.ColorbarVisible, 'on')
                getColorbar(this);
            end
        end
    end

    methods (Access = private)
        function [x, y, z] = preparedData(this)
            z = this.ZData;
            if isempty(z)
                z = gleamoe.graphics.chartcontainer.internal.samplePeaks(40);
            end
            [rows, cols] = size(z);
            [x, y] = meshgrid(1:cols, 1:rows);
        end

        function recreateSurface(this, ax, x, y, z)
            gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.Surface);
            this.Surface = surf(ax, x, y, z, z, ...
                'EdgeColor', 'none', ...
                'FaceColor', 'interp');
        end
    end
end
