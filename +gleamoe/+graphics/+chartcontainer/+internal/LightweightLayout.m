classdef LightweightLayout < handle
    %LightweightLayout Minimal tiled-layout-like helper for chart containers.

    properties
        Parent
        GridSize = [1 1]
        Padding = 'compact'
        TileSpacing = 'compact'
        Position = [0.13 0.11 0.775 0.815]
    end

    properties (Access = private)
        Chart
        AxesByTile = {}
    end

    methods
        function this = LightweightLayout(chart)
            this.Chart = chart;
            this.Parent = chart.Parent;
            this.Position = chart.Position;
        end

        function set.GridSize(this, value)
            if ~isnumeric(value) || numel(value) ~= 2 || any(value(:) < 1)
                error('gleamoe:chartcontainer:LayoutGridSize', ...
                    'GridSize must be a two-element positive numeric vector.');
            end
            this.GridSize = round(reshape(double(value), 1, 2));
            updateRegisteredAxes(this);
        end

        function set.Position(this, value)
            this.Position = gleamoe.graphics.chartcontainer.internal.mustBeFourVector(value, 'Position');
            updateRegisteredAxes(this);
        end

        function pos = tilePosition(this, tile)
            if isempty(tile)
                tile = 1;
            end
            if numel(tile) == 1
                index = tile;
                row = ceil(index / this.GridSize(2));
                col = index - (row - 1) * this.GridSize(2);
            else
                row = tile(1);
                col = tile(2);
            end

            rows = this.GridSize(1);
            cols = this.GridSize(2);
            row = min(max(row, 1), rows);
            col = min(max(col, 1), cols);

            gap = tileGap(this);
            width = (this.Position(3) - gap * (cols - 1)) / cols;
            height = (this.Position(4) - gap * (rows - 1)) / rows;
            left = this.Position(1) + (col - 1) * (width + gap);
            bottom = this.Position(2) + (rows - row) * (height + gap);
            pos = [left bottom width height];
        end

        function registerAxes(this, ax, tile)
            if isempty(tile)
                tile = 1;
            end
            key = tileKey(tile);
            this.AxesByTile{end + 1, 1} = key;
            this.AxesByTile{end, 2} = ax;
            gleamoe.graphics.chartcontainer.internal.safeSet(ax, 'Position', tilePosition(this, tile));
        end

        function ax = nexttile(this, tile)
            if nargin < 2
                tile = numel(this.AxesByTile) + 1;
            end
            ax = gleamoe.graphics.chartcontainer.internal.createAxes(this.Chart.Parent, 'cartesian', ...
                'Units', this.Chart.Units, ...
                'Position', tilePosition(this, tile), ...
                'HandleVisibility', this.Chart.HandleVisibility, ...
                'Visible', this.Chart.Visible);
            registerAxes(this, ax, tile);
        end
    end

    methods (Access = private)
        function updateRegisteredAxes(this)
            for idx = 1:size(this.AxesByTile, 1)
                tile = this.AxesByTile{idx, 1};
                ax = this.AxesByTile{idx, 2};
                gleamoe.graphics.chartcontainer.internal.safeSet(ax, 'Position', tilePosition(this, tile));
            end
        end

        function gap = tileGap(this)
            switch lower(char(this.TileSpacing))
                case 'none'
                    gap = 0;
                case 'loose'
                    gap = 0.06;
                otherwise
                    gap = 0.035;
            end
        end
    end
end

function key = tileKey(tile)
    key = reshape(double(tile), 1, []);
end
