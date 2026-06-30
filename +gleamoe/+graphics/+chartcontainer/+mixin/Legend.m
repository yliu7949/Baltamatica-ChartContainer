classdef (Abstract) Legend < handle
    %Legend Mixin that adds a LegendVisible property and getLegend helper.

    properties
        LegendVisible = 'on'
    end

    properties (Access = private)
        LegendHandle
    end

    methods
        function set.LegendVisible(this, value)
            this.LegendVisible = gleamoe.graphics.chartcontainer.internal.mustBeOnOff(value, 'LegendVisible');
            syncLegend(this);
            try
                requestUpdate(this);
            catch
            end
        end
    end

    methods (Access = protected)
        function lgd = getLegend(this)
            if isempty(this.LegendHandle) || ~gleamoe.graphics.chartcontainer.internal.isLiveGraphics(this.LegendHandle)
                ax = [];
                try
                    ax = getAxes(this);
                catch
                end

                try
                    if isempty(ax)
                        lgd = legend('show');
                    else
                        lgd = legend(ax, 'show');
                    end
                    this.LegendHandle = lgd;
                catch err
                    error(['Unable to create a legend. Original error: ' ...
                        gleamoe.graphics.chartcontainer.internal.errorMessage(err)]);
                end
            else
                lgd = this.LegendHandle;
            end

            gleamoe.graphics.chartcontainer.internal.safeSet(lgd, 'Visible', this.LegendVisible);
        end
    end

    methods (Access = private)
        function syncLegend(this)
            if isempty(this.LegendHandle)
                return
            end
            gleamoe.graphics.chartcontainer.internal.safeSet(this.LegendHandle, 'Visible', this.LegendVisible);
        end
    end
end
