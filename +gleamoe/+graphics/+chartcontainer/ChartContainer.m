classdef (Abstract) ChartContainer < handle
    %ChartContainer Base class for MATLAB-style chart containers in Baltamatica.
    %
    %   Subclasses implement setup(this) and update(this). Constructors in
    %   subclasses should call:
    %
    %       this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
    %
    %   This implementation follows MATLAB's public ChartContainer contract
    %   where practical, while isolating Baltamatica graphics differences in
    %   +gleamoe.graphics.chartcontainer.internal.

    properties
        Parent
        Visible = 'on'
        HandleVisibility = 'on'
        Units = 'normalized'
        Position = [0.13 0.11 0.775 0.815]
        InnerPosition = [0.13 0.11 0.775 0.815]
        OuterPosition = [0 0 1 1]
        PositionConstraint = 'outerposition'
        Layout = []
    end

    properties (Access = protected)
        Axes
        LayoutHandle
        SetupComplete = false
        Constructing = false
        InUpdate = false
        UpdateQueued = false
        CtorArgs = {}
    end

    methods (Access = protected)
        function this = ChartContainer(varargin)
            this.CtorArgs = varargin;
            this.Constructing = true;

            [parent, args] = gleamoe.graphics.chartcontainer.internal.extractParent(varargin);
            if ~isempty(parent)
                this.Parent = parent;
            end

            doSetupInternal(this);
            gleamoe.graphics.chartcontainer.internal.applyNameValuePairs(this, args);

            this.Constructing = false;
            requestUpdate(this);
        end

        function ax = getAxes(this)
            if isempty(this.Axes) || ~gleamoe.graphics.chartcontainer.internal.isLiveGraphics(this.Axes)
                this.Axes = createAxes(this);
            end
            ax = this.Axes;
        end

        function layout = getLayout(this)
            needsLayout = isempty(this.LayoutHandle);
            if ~needsLayout
                try
                    needsLayout = ~isvalid(this.LayoutHandle);
                catch
                    needsLayout = false;
                end
            end
            if needsLayout
                this.LayoutHandle = gleamoe.graphics.chartcontainer.internal.LightweightLayout(this);
            end
            layout = this.LayoutHandle;
        end

        function theme = getTheme(this)
            theme = gleamoe.graphics.chartcontainer.internal.defaultTheme();
            try
                ax = getAxes(this);
                theme.AxesColor = get(ax, 'Color');
                theme.TextColor = get(ax, 'XColor');
                theme.GridColor = get(ax, 'GridColor');
                theme.ColorOrder = get(ax, 'ColorOrder');
            catch
            end
        end

        function ax = createAxes(this, varargin)
            opts = gleamoe.graphics.chartcontainer.internal.parseCreateAxesOptions(varargin);
            layout = [];
            if ~isempty(opts.Tile)
                layout = getLayout(this);
            end

            parent = this.Parent;
            if ~isempty(layout)
                pos = tilePosition(layout, opts.Tile);
            else
                pos = this.Position;
            end

            ax = gleamoe.graphics.chartcontainer.internal.createAxes(parent, opts.Type, ...
                'Units', this.Units, ...
                'Position', pos, ...
                'HandleVisibility', this.HandleVisibility, ...
                'Visible', this.Visible);

            if ~isempty(layout)
                registerAxes(layout, ax, opts.Tile);
            end
        end

        function requestUpdate(this)
            if this.Constructing || ~this.SetupComplete
                this.UpdateQueued = true;
                return
            end

            if this.InUpdate
                this.UpdateQueued = true;
                return
            end

            this.InUpdate = true;
            this.UpdateQueued = false;
            try
                update(this);
            catch err
                this.InUpdate = false;
                error(gleamoe.graphics.chartcontainer.internal.errorMessage(err));
            end
            this.InUpdate = false;

            if this.UpdateQueued
                this.UpdateQueued = false;
                requestUpdate(this);
            end
        end

        function doSetupInternal(this)
            if this.SetupComplete
                return
            end
            setup(this);
            this.SetupComplete = true;
        end
    end

    methods
        function delete(~)
            % Baltamatica community builds can lack the inherited handle
            % delete implementation. Managed graphics are owned by their
            % figure/axes parent, so chart deletion is intentionally minimal.
        end

        function set.Parent(this, value)
            this.Parent = value;
            gleamoe.graphics.chartcontainer.internal.safeSet(this.Axes, 'Parent', value); %#ok<*MCSUP>
            gleamoe.graphics.chartcontainer.internal.safeSet(this.LayoutHandle, 'Parent', value);
            requestUpdate(this);
        end

        function set.Visible(this, value)
            this.Visible = gleamoe.graphics.chartcontainer.internal.mustBeOnOff(value, 'Visible');
            gleamoe.graphics.chartcontainer.internal.safeSet(this.Axes, 'Visible', this.Visible);
            requestUpdate(this);
        end

        function set.HandleVisibility(this, value)
            this.HandleVisibility = gleamoe.graphics.chartcontainer.internal.mustBeChoice( ...
                value, {'on','off','callback'}, 'HandleVisibility');
            gleamoe.graphics.chartcontainer.internal.safeSet(this.Axes, 'HandleVisibility', this.HandleVisibility);
            requestUpdate(this);
        end

        function set.Units(this, value)
            this.Units = gleamoe.graphics.chartcontainer.internal.mustBeText(value, 'Units');
            gleamoe.graphics.chartcontainer.internal.safeSet(this.Axes, 'Units', this.Units);
            requestUpdate(this);
        end

        function set.Position(this, value)
            this.Position = gleamoe.graphics.chartcontainer.internal.mustBeFourVector(value, 'Position');
            this.InnerPosition = this.Position;
            gleamoe.graphics.chartcontainer.internal.safeSet(this.Axes, 'Position', this.Position);
            gleamoe.graphics.chartcontainer.internal.safeSet(this.LayoutHandle, 'Position', this.Position);
            requestUpdate(this);
        end

        function set.InnerPosition(this, value)
            this.InnerPosition = gleamoe.graphics.chartcontainer.internal.mustBeFourVector(value, 'InnerPosition');
            requestUpdate(this);
        end

        function set.OuterPosition(this, value)
            this.OuterPosition = gleamoe.graphics.chartcontainer.internal.mustBeFourVector(value, 'OuterPosition');
            requestUpdate(this);
        end

        function set.PositionConstraint(this, value)
            this.PositionConstraint = gleamoe.graphics.chartcontainer.internal.mustBeChoice( ...
                value, {'outerposition','innerposition'}, 'PositionConstraint');
            requestUpdate(this);
        end

        function set.Layout(this, value)
            this.Layout = value;
            requestUpdate(this);
        end
    end

    methods (Abstract, Access = protected)
        setup(this)
        update(this)
    end
end
