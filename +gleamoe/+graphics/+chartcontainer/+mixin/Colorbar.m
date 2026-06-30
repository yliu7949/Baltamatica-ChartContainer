classdef Colorbar < handle
    %Colorbar Mixin that adds a ColorbarVisible property and getColorbar helper.

    properties
        ColorbarVisible = 'on'
    end

    properties (Access = private)
        ColorbarHandle
    end

    methods
        function set.ColorbarVisible(this, value)
            this.ColorbarVisible = gleamoe.graphics.chartcontainer.internal.mustBeOnOff(value, 'ColorbarVisible');
            syncColorbar(this);
            try
                requestUpdate(this);
            catch
            end
        end
    end

    methods (Access = protected)
        function cb = getColorbar(this)
            if isempty(this.ColorbarHandle) || ~gleamoe.graphics.chartcontainer.internal.isLiveGraphics(this.ColorbarHandle)
                ax = [];
                try
                    ax = getAxes(this);
                catch
                end

                try
                    if isempty(ax)
                        cb = colorbar;
                    else
                        cb = colorbar(ax);
                    end
                    this.ColorbarHandle = cb;
                catch err
                    error(['Unable to create a colorbar. Original error: ' ...
                        gleamoe.graphics.chartcontainer.internal.errorMessage(err)]);
                end
            else
                cb = this.ColorbarHandle;
            end

            gleamoe.graphics.chartcontainer.internal.safeSet(cb, 'Visible', this.ColorbarVisible);
        end
    end

    methods (Access = private)
        function syncColorbar(this)
            if isempty(this.ColorbarHandle)
                return
            end
            gleamoe.graphics.chartcontainer.internal.safeSet(this.ColorbarHandle, 'Visible', this.ColorbarVisible);
        end
    end
end
