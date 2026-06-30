classdef SankeyPlotChart < gleamoe.graphics.chartcontainer.ChartContainer
    %SankeyPlotChart ChartContainer implementation used by SankeyPlot.

    properties
        Source = {}
        Target = {}
        Value = []
        AdjMat = []
        Label = {}
        CData = [ ...
            65,140,240; 252,180,65; 224,64,10; 5,100,146; 191,191,191; ...
            26,59,105; 255,227,130; 18,156,221; 202,107,75; 0,92,219; ...
            243,210,136; 80,99,129; 241,185,168; 224,131,10; 120,147,190; ...
            127,91,93; 187,128,110; 197,173,143; 59,71,111; 104,95,126; ...
            76,103,86; 112,112,124; 72,39,24; 197,119,106; 160,126,88; ...
            238,208,146] ./ 255
        Arrow = 'on'
        ShowTicks = true
        ShowTickLabels = true
        TickRadius = 1.17
        LabelRadius = 1.38
        FontName = 'Cambria'
        LabelFontSize = 17
        TickFontSize = 11
        Title = ''
        RibbonAlpha = 0.32
        InnerRadius = 1.0
        SquareRadius = [1.05 1.15]
        AxesLimit = [-1.62 1.62 -1.62 1.62]
    end

    properties (Access = private)
        ChartObjects = {}
    end

    methods
        function this = SankeyPlotChart(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function set.Source(this, value)
            this.Source = normalizeTextVector(this, value, 'Source');
            requestUpdate(this);
        end

        function set.Target(this, value)
            this.Target = normalizeTextVector(this, value, 'Target');
            requestUpdate(this);
        end

        function set.Value(this, value)
            this.Value = normalizeValueVector(this, value);
            requestUpdate(this);
        end

        function set.AdjMat(this, value)
            if isempty(value)
                this.AdjMat = [];
            elseif ~isnumeric(value) || ndims(value) ~= 2 || size(value, 1) ~= size(value, 2)
                error('gleamoe:plot:SankeyPlot:AdjMat', 'AdjMat must be a square numeric matrix.');
            else
                this.AdjMat = double(value);
            end
            requestUpdate(this);
        end

        function set.Label(this, value)
            this.Label = normalizeTextVector(this, value, 'Label');
            requestUpdate(this);
        end

        function set.CData(this, value)
            if ~isnumeric(value) || size(value, 2) ~= 3
                error('gleamoe:plot:SankeyPlot:CData', 'CData must be an N-by-3 RGB matrix.');
            end
            this.CData = max(0, min(1, double(value)));
            requestUpdate(this);
        end

        function set.Arrow(this, value)
            this.Arrow = gleamoe.graphics.chartcontainer.internal.mustBeOnOff(value, 'Arrow');
            requestUpdate(this);
        end

        function set.ShowTicks(this, value)
            this.ShowTicks = logicalScalar(this, value, 'ShowTicks');
            requestUpdate(this);
        end

        function set.ShowTickLabels(this, value)
            this.ShowTickLabels = logicalScalar(this, value, 'ShowTickLabels');
            requestUpdate(this);
        end

        function set.TickRadius(this, value)
            this.TickRadius = positiveScalar(this, value, 'TickRadius');
            requestUpdate(this);
        end

        function set.LabelRadius(this, value)
            this.LabelRadius = positiveScalar(this, value, 'LabelRadius');
            requestUpdate(this);
        end

        function set.FontName(this, value)
            this.FontName = gleamoe.graphics.chartcontainer.internal.mustBeText(value, 'FontName');
            requestUpdate(this);
        end

        function set.LabelFontSize(this, value)
            this.LabelFontSize = positiveScalar(this, value, 'LabelFontSize');
            requestUpdate(this);
        end

        function set.TickFontSize(this, value)
            this.TickFontSize = positiveScalar(this, value, 'TickFontSize');
            requestUpdate(this);
        end

        function set.Title(this, value)
            this.Title = gleamoe.graphics.chartcontainer.internal.mustBeText(value, 'Title');
            requestUpdate(this);
        end

        function set.RibbonAlpha(this, value)
            this.RibbonAlpha = boundedScalar(this, value, 'RibbonAlpha', 0, 1);
            requestUpdate(this);
        end

        function set.InnerRadius(this, value)
            this.InnerRadius = positiveScalar(this, value, 'InnerRadius');
            requestUpdate(this);
        end

        function set.SquareRadius(this, value)
            if ~isnumeric(value) || numel(value) ~= 2 || any(value <= 0)
                error('gleamoe:plot:SankeyPlot:SquareRadius', ...
                    'SquareRadius must be a two-element positive numeric vector.');
            end
            this.SquareRadius = sort(double(value(:).'));
            requestUpdate(this);
        end

        function set.AxesLimit(this, value)
            if ~isnumeric(value) || numel(value) ~= 4
                error('gleamoe:plot:SankeyPlot:AxesLimit', 'AxesLimit must be a four-element numeric vector.');
            end
            this.AxesLimit = double(value(:).');
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            configureAxes(this, getAxes(this));
        end

        function update(this)
            redraw(this);
        end
    end

    methods (Access = private)
        function redraw(this)
            ax = getAxes(this);
            configureAxes(this, ax);
            clearChart(this);

            [labels, adj] = preparedData(this);
            if isempty(adj)
                return
            end

            geom = chordGeometry(this, adj);
            [outStart, outEnd, inStart, inEnd] = segmentAngles(this, adj, geom);

            for sourceIdx = 1:numel(labels)
                for targetIdx = 1:numel(labels)
                    if adj(sourceIdx, targetIdx) > 0
                        color = nodeColor(this, sourceIdx);
                        addRibbon(this, ax, outStart(sourceIdx, targetIdx), outEnd(sourceIdx, targetIdx), ...
                            inStart(sourceIdx, targetIdx), inEnd(sourceIdx, targetIdx), color);
                    end
                end
            end

            for nodeIdx = 1:numel(labels)
                addNodeArc(this, ax, geom.Start(nodeIdx), geom.End(nodeIdx), nodeColor(this, nodeIdx));
            end

            if this.ShowTicks
                addTicks(this, ax, geom, adj, outStart, outEnd, inStart, inEnd);
            end
            addLabels(this, ax, labels, geom);
        end

        function configureAxes(this, ax)
            cla(ax);
            hold(ax, 'on');
            axis(ax, 'equal');
            axis(ax, this.AxesLimit);
            axis(ax, 'off');
            title(ax, this.Title);
        end

        function clearChart(this)
            for objIdx = 1:numel(this.ChartObjects)
                gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.ChartObjects{objIdx});
            end
            this.ChartObjects = {};
        end

        function remember(this, graphicsObject)
            if ~isempty(graphicsObject)
                this.ChartObjects{end + 1} = graphicsObject;
            end
        end

        function [labels, adj] = preparedData(this)
            if ~isempty(this.AdjMat)
                adj = this.AdjMat;
                if isempty(this.Label)
                    labels = compose('node%d', 1:size(adj, 1));
                    labels = cellstr(labels);
                else
                    labels = this.Label(:);
                    if numel(labels) ~= size(adj, 1)
                        error('gleamoe:plot:SankeyPlot:Label', ...
                            'Label length must match the adjacency matrix size.');
                    end
                end
                return
            end

            source = this.Source(:);
            target = this.Target(:);
            value = this.Value(:);
            if isempty(source) && isempty(target) && isempty(value)
                labels = {};
                adj = [];
                return
            end
            if numel(source) ~= numel(target) || numel(source) ~= numel(value)
                error('gleamoe:plot:SankeyPlot:DataSize', ...
                    'Source, Target, and Value must have the same number of elements.');
            end

            if isempty(this.Label)
                labels = unique([source; target], 'stable');
            else
                labels = this.Label(:);
            end

            adj = zeros(numel(labels));
            for linkIdx = 1:numel(value)
                sourceIdx = find(strcmp(labels, source{linkIdx}), 1);
                targetIdx = find(strcmp(labels, target{linkIdx}), 1);
                if isempty(sourceIdx) || isempty(targetIdx)
                    error('gleamoe:plot:SankeyPlot:Label', ...
                        'Every source and target must be included in Label.');
                end
                adj(sourceIdx, targetIdx) = value(linkIdx);
            end
        end

        function geom = chordGeometry(~, adj)
            rowTotal = sum(adj, 2);
            colTotal = sum(adj, 1).';
            tickTotal = rowTotal + colTotal;
            spanWeight = tickTotal ./ 2;
            spanWeight(spanWeight <= 0) = eps;
            nodeCount = numel(spanWeight);
            gap = 2.4 * pi / 180;
            if nodeCount * gap > pi
                gap = pi / max(1, nodeCount * 2);
            end

            span = (2 * pi - nodeCount * gap) .* spanWeight ./ sum(spanWeight);
            startAngle = zeros(nodeCount, 1);
            endAngle = zeros(nodeCount, 1);
            splitAngle = zeros(nodeCount, 1);
            cursor = gap / 2;
            for nodeIdx = 1:nodeCount
                startAngle(nodeIdx) = cursor;
                endAngle(nodeIdx) = cursor + span(nodeIdx);
                if tickTotal(nodeIdx) > 0
                    splitAngle(nodeIdx) = startAngle(nodeIdx) + span(nodeIdx) .* colTotal(nodeIdx) ./ tickTotal(nodeIdx);
                else
                    splitAngle(nodeIdx) = (startAngle(nodeIdx) + endAngle(nodeIdx)) ./ 2;
                end
                cursor = endAngle(nodeIdx) + gap;
            end

            geom = struct('Start', startAngle, 'End', endAngle, 'Split', splitAngle, ...
                'Total', tickTotal, 'RowTotal', rowTotal, 'ColTotal', colTotal);
        end

        function [outStart, outEnd, inStart, inEnd] = segmentAngles(~, adj, geom)
            nodeCount = size(adj, 1);
            outStart = zeros(nodeCount);
            outEnd = zeros(nodeCount);
            inStart = zeros(nodeCount);
            inEnd = zeros(nodeCount);

            for nodeIdx = 1:nodeCount
                rowTotal = sum(adj(nodeIdx, :));
                if rowTotal > 0
                    cursor = geom.End(nodeIdx);
                    for targetIdx = 1:nodeCount
                        flowSpan = (geom.Split(nodeIdx) - geom.End(nodeIdx)) * adj(nodeIdx, targetIdx) / rowTotal;
                        outStart(nodeIdx, targetIdx) = cursor;
                        outEnd(nodeIdx, targetIdx) = cursor + flowSpan;
                        cursor = cursor + flowSpan;
                    end
                end

                colTotal = sum(adj(:, nodeIdx));
                if colTotal > 0
                    cursor = geom.Split(nodeIdx);
                    for sourceIdx = 1:nodeCount
                        flowSpan = (geom.Start(nodeIdx) - geom.Split(nodeIdx)) * adj(sourceIdx, nodeIdx) / colTotal;
                        inStart(sourceIdx, nodeIdx) = cursor;
                        inEnd(sourceIdx, nodeIdx) = cursor + flowSpan;
                        cursor = cursor + flowSpan;
                    end
                end
            end
        end

        function addRibbon(this, ax, sourceStart, sourceEnd, targetStart, targetEnd, color)
            innerRadius = this.InnerRadius;
            control = [0, 0];
            pointA = circlePoint(this, innerRadius, sourceStart);
            pointD = circlePoint(this, innerRadius, sourceEnd);

            if strcmp(this.Arrow, 'on')
                pointB = circlePoint(this, innerRadius * 0.96, targetEnd);
                pointC = circlePoint(this, innerRadius * 0.96, targetStart);
                targetMid = (targetStart + targetEnd) / 2;
                targetArc = [ ...
                    pointB; ...
                    circlePoint(this, innerRadius * 0.99, targetMid); ...
                    pointC];
            else
                pointB = circlePoint(this, innerRadius, targetEnd);
                pointC = circlePoint(this, innerRadius, targetStart);
                targetArc = arcPoints(this, innerRadius, targetEnd, targetStart, 60);
            end

            curveAB = quadraticBezier(this, pointA, control, pointB, 160);
            curveCD = quadraticBezier(this, pointC, control, pointD, 160);
            sourceArc = arcPoints(this, innerRadius, sourceEnd, sourceStart, 60);

            ribbon = [curveAB; targetArc; curveCD; sourceArc];
            h = patch(ax, ribbon(:, 1), ribbon(:, 2), color, 'EdgeColor', 'none');
            gleamoe.graphics.chartcontainer.internal.safeSet(h, 'FaceAlpha', this.RibbonAlpha);
            remember(this, h);
        end

        function addNodeArc(this, ax, startAngle, endAngle, color)
            innerRadius = this.SquareRadius(1);
            outerRadius = this.SquareRadius(2);
            theta = linspace(startAngle, endAngle, 100);
            x = [outerRadius .* cos(theta), innerRadius .* cos(fliplr(theta))];
            y = [outerRadius .* sin(theta), innerRadius .* sin(fliplr(theta))];
            h = patch(ax, x, y, color, 'EdgeColor', 'none');
            remember(this, h);
        end

        function addTicks(this, ax, geom, adj, outStart, outEnd, inStart, inEnd)
            tickColor = [0, 0, 0];
            for nodeIdx = 1:numel(geom.Total)
                thetaArc = linspace(geom.Start(nodeIdx), geom.End(nodeIdx), 100);
                h = line(ax, cos(thetaArc) .* this.TickRadius, sin(thetaArc) .* this.TickRadius, ...
                    'Color', tickColor, 'LineWidth', 0.8);
                remember(this, h);

                [tickAngles, tickValues] = nodeTickData(this, adj, nodeIdx, outStart, outEnd, inStart, inEnd);
                for tickIdx = 1:numel(tickAngles)
                    theta = tickAngles(tickIdx);
                    p0 = circlePoint(this, this.TickRadius, theta);
                    p1 = circlePoint(this, this.TickRadius + 0.02, theta);
                    h = line(ax, [p0(1), p1(1)], [p0(2), p1(2)], 'Color', tickColor, 'LineWidth', 0.8);
                    remember(this, h);

                    if this.ShowTickLabels
                        pt = circlePoint(this, this.TickRadius + 0.03, theta);
                        tickLabel = compactNumber(this, tickValues(tickIdx));
                        [rotation, align] = tickLabelPlacement(this, theta);
                        h = text(ax, pt(1), pt(2), tickLabel, 'Color', tickColor, ...
                            'FontName', this.FontName, 'FontSize', this.TickFontSize, ...
                            'Rotation', rotation, ...
                            'HorizontalAlignment', align, ...
                            'VerticalAlignment', 'middle');
                        remember(this, h);
                    end
                end
            end
        end

        function addLabels(this, ax, labels, geom)
            for nodeIdx = 1:numel(labels)
                theta = (geom.Start(nodeIdx) + geom.End(nodeIdx)) / 2;
                pt = circlePoint(this, this.LabelRadius, theta);
                rotation = labelRotation(this, theta);
                h = text(ax, pt(1), pt(2), labels{nodeIdx}, ...
                    'FontName', this.FontName, ...
                    'FontSize', this.LabelFontSize, ...
                    'FontWeight', 'bold', ...
                    'Color', [0.12, 0.13, 0.16], ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', ...
                    'Rotation', rotation);
                remember(this, h);
            end
        end

        function [tickAngles, tickValues] = nodeTickData(~, adj, nodeIdx, outStart, outEnd, inStart, inEnd)
            tickAngles = [];
            tickValues = [];
            currentValue = 0;
            rowTargets = find(adj(nodeIdx, :) > 0);
            for idx = 1:numel(rowTargets)
                targetIdx = rowTargets(idx);
                if isempty(tickAngles)
                    tickAngles(end + 1) = outStart(nodeIdx, targetIdx); %#ok<AGROW>
                    tickValues(end + 1) = currentValue; %#ok<AGROW>
                end
                currentValue = currentValue + adj(nodeIdx, targetIdx);
                tickAngles(end + 1) = outEnd(nodeIdx, targetIdx); %#ok<AGROW>
                tickValues(end + 1) = currentValue; %#ok<AGROW>
            end

            colSources = find(adj(:, nodeIdx).' > 0);
            for idx = 1:numel(colSources)
                sourceIdx = colSources(idx);
                if isempty(tickAngles) || abs(tickAngles(end) - inStart(sourceIdx, nodeIdx)) > eps
                    tickAngles(end + 1) = inStart(sourceIdx, nodeIdx); %#ok<AGROW>
                    tickValues(end + 1) = currentValue; %#ok<AGROW>
                end
                currentValue = currentValue + adj(sourceIdx, nodeIdx);
                tickAngles(end + 1) = inEnd(sourceIdx, nodeIdx); %#ok<AGROW>
                tickValues(end + 1) = currentValue; %#ok<AGROW>
            end
        end

        function color = nodeColor(this, idx)
            colorCount = size(this.CData, 1);
            color = this.CData(mod(idx - 1, colorCount) + 1, :);
        end

        function points = quadraticBezier(~, pointA, pointB, pointC, count)
            t = linspace(0, 1, count).';
            points = (1 - t).^2 .* pointA + 2 .* (1 - t) .* t .* pointB + t.^2 .* pointC;
        end

        function points = arcPoints(~, radius, startAngle, endAngle, count)
            theta = linspace(startAngle, endAngle, count).';
            points = [radius .* cos(theta), radius .* sin(theta)];
        end

        function point = circlePoint(~, radius, theta)
            point = [radius .* cos(theta), radius .* sin(theta)];
        end

        function [rotation, align] = tickLabelPlacement(~, theta)
            rotation = mod(theta ./ pi .* 180, 360);
            if rotation > 90 && rotation < 270
                rotation = rotation + 180;
                align = 'right';
            else
                align = 'left';
            end
        end

        function rotation = labelRotation(~, theta)
            theta = mod(theta, 2 * pi);
            if theta > 0 && theta < pi
                rotation = -(0.5 * pi - theta) ./ pi .* 180;
            else
                rotation = -(1.5 * pi - theta) ./ pi .* 180;
            end
        end

        function value = normalizeTextVector(~, value, propertyName)
            if isempty(value)
                value = {};
                return
            end
            if isstring(value)
                value = cellstr(value(:));
                return
            end
            if ischar(value)
                value = {value};
                return
            end
            if iscell(value)
                value = value(:);
                for idx = 1:numel(value)
                    if ~(ischar(value{idx}) || (isstring(value{idx}) && isscalar(value{idx})))
                        error('gleamoe:plot:SankeyPlot:TextVector', ...
                            '%s values must be text.', propertyName);
                    end
                    value{idx} = char(value{idx});
                end
                return
            end
            error('gleamoe:plot:SankeyPlot:TextVector', '%s must be a text vector.', propertyName);
        end

        function value = normalizeValueVector(~, value)
            if isempty(value)
                value = [];
                return
            end
            if iscell(value)
                if ~all(cellfun(@(x) isnumeric(x) && isscalar(x), value))
                    error('gleamoe:plot:SankeyPlot:Value', 'Value entries must be numeric scalars.');
                end
                value = cellfun(@double, value);
            end
            if ~isnumeric(value) || any(value(:) < 0)
                error('gleamoe:plot:SankeyPlot:Value', 'Value must contain nonnegative numbers.');
            end
            value = double(value(:));
        end

        function value = positiveScalar(~, value, propertyName)
            if ~isnumeric(value) || ~isscalar(value) || value <= 0
                error('gleamoe:plot:SankeyPlot:PositiveScalar', ...
                    '%s must be a positive numeric scalar.', propertyName);
            end
            value = double(value);
        end

        function value = boundedScalar(~, value, propertyName, lowerBound, upperBound)
            if ~isnumeric(value) || ~isscalar(value) || value < lowerBound || value > upperBound
                error('gleamoe:plot:SankeyPlot:BoundedScalar', ...
                    '%s must be a numeric scalar between %g and %g.', propertyName, lowerBound, upperBound);
            end
            value = double(value);
        end

        function value = logicalScalar(~, value, propertyName)
            if ~(islogical(value) || isnumeric(value)) || ~isscalar(value)
                error('gleamoe:plot:SankeyPlot:LogicalScalar', '%s must be a logical scalar.', propertyName);
            end
            value = logical(value);
        end

        function label = compactNumber(~, value)
            if abs(value - round(value)) < 1e-10
                label = sprintf('%.0f', value);
            else
                label = sprintf('%.1f', value);
            end
        end
    end
end
