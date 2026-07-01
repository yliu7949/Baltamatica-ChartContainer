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
        TickRadius = 1.4625
        LabelRadius = 1.725
        FontName = 'Cambria'
        LabelFontSize = 21
        TickFontSize = 15
        Title = ''
        RibbonAlpha = 0.54
        Sep = 1/10
        InnerRadius = 1.25
        SquareRadius = [1.3125 1.4375]
        AxesLimit = [-1.725 1.725 -1.725 1.725]
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
            elseif ~isnumeric(value) || ~ismatrix(value) || size(value, 1) ~= size(value, 2)
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

        function set.Sep(this, value)
            this.Sep = boundedScalar(this, value, 'Sep', 0, 1/2);
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
            centerAxes(this, ax);
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

        function centerAxes(this, ax)
            try
                originalUnits = get(ax, 'Units');
                set(ax, 'Units', 'normalized');
                position = get(ax, 'Position');
                parentSize = parentPixelSize(this, ax);

                if all(parentSize > 0)
                    widthPixels = position(3) .* parentSize(1);
                    heightPixels = position(4) .* parentSize(2);
                    sidePixels = min(widthPixels, heightPixels);
                    newWidth = sidePixels ./ parentSize(1);
                    newHeight = sidePixels ./ parentSize(2);
                else
                    side = min(position(3:4));
                    newWidth = side;
                    newHeight = side;
                end

                position(1) = position(1) + (position(3) - newWidth) ./ 2;
                position(2) = position(2) + (position(4) - newHeight) ./ 2;
                position(3) = newWidth;
                position(4) = newHeight;
                set(ax, 'Position', position);
                set(ax, 'Units', originalUnits);
            catch
            end
        end

        function sizePixels = parentPixelSize(~, ax)
            sizePixels = [0, 0];
            try
                parent = get(ax, 'Parent');
                originalUnits = get(parent, 'Units');
                set(parent, 'Units', 'pixels');
                position = get(parent, 'Position');
                set(parent, 'Units', originalUnits);
                sizePixels = double(position(3:4));
            catch
                try
                    fig = ancestor(ax, 'figure');
                    originalUnits = get(fig, 'Units');
                    set(fig, 'Units', 'pixels');
                    position = get(fig, 'Position');
                    set(fig, 'Units', originalUnits);
                    sizePixels = double(position(3:4));
                catch
                end
            end
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

            adj = zeros(numel(labels), numel(labels));
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

        function geom = chordGeometry(this, adj)
            rowTotal = sum(adj, 2);
            colTotal = sum(adj, 1).';
            tickTotal = rowTotal + colTotal;
            spanWeight = tickTotal ./ 2;
            spanWeight(spanWeight <= 0) = eps;
            nodeCount = numel(spanWeight);
            gap = 2 * pi * this.Sep / nodeCount;
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
                    splitAngle(nodeIdx) = startAngle(nodeIdx) + ...
                        span(nodeIdx) .* colTotal(nodeIdx) ./ tickTotal(nodeIdx);
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

            % Coarse strips avoid transparent-patch artifacts without overloading Baltamatica.
            flowCount = 64;
            widthCount = 4;
            curveAB = quadraticBezier(this, pointA, control, pointB, flowCount);
            curveDC = quadraticBezier(this, pointD, control, pointC, flowCount);
            sourceArc = arcPoints(this, innerRadius, sourceStart, sourceEnd, widthCount);
            targetSection = resampledPolyline(this, targetArc, widthCount);

            [x, y] = ribbonMesh(this, curveAB, curveDC, sourceArc, targetSection);
            h = patch(ax, x, y, color, 'EdgeColor', 'none');
            gleamoe.graphics.chartcontainer.internal.safeSet(h, 'FaceAlpha', this.RibbonAlpha);
            remember(this, h);
        end

        function addNodeArc(this, ax, startAngle, endAngle, color)
            innerRadius = this.SquareRadius(1);
            outerRadius = this.SquareRadius(2);
            if endAngle < startAngle
                endAngle = endAngle + 2 * pi;
            end

            span = abs(endAngle - startAngle);
            pointCount = max(24, ceil(span / (pi / 360)) + 1);
            theta = linspace(startAngle, endAngle, pointCount).';

            outer = [outerRadius .* cos(theta), outerRadius .* sin(theta)];
            inner = [innerRadius .* cos(theta), innerRadius .* sin(theta)];
            vertices = [outer; inner];

            outerStart = (1:pointCount - 1).';
            outerEnd = outerStart + 1;
            innerStart = pointCount + outerStart;
            innerEnd = innerStart + 1;
            faces = [outerStart, outerEnd, innerEnd, innerStart];

            x = reshape(vertices(faces.', 1), 4, []);
            y = reshape(vertices(faces.', 2), 4, []);

            h = patch(ax, x, y, color, ...
                'EdgeColor', 'none');
            remember(this, h);
        end

        function addTicks(this, ax, geom, adj, outStart, outEnd, inStart, inEnd)
            tickColor = [0, 0, 0];
            tickScale = this.TickRadius ./ 1.17;
            tickLength = 0.02 .* tickScale;
            tickLabelOffset = 0.03 .* tickScale;
            nodeCount = numel(geom.Total);
            arcPointCount = 80;
            arcX = nan(1, nodeCount .* (arcPointCount + 1));
            arcY = nan(1, nodeCount .* (arcPointCount + 1));
            tickAngleCells = cell(1, nodeCount);
            tickValueCells = cell(1, nodeCount);

            for nodeIdx = 1:numel(geom.Total)
                thetaArc = linspace(geom.Start(nodeIdx), geom.End(nodeIdx), arcPointCount);
                arcRange = (nodeIdx - 1) .* (arcPointCount + 1) + (1:arcPointCount);
                arcX(arcRange) = cos(thetaArc) .* this.TickRadius;
                arcY(arcRange) = sin(thetaArc) .* this.TickRadius;

                [tickAngleCells{nodeIdx}, tickValueCells{nodeIdx}] = ...
                    nodeTickData(this, adj, nodeIdx, outStart, outEnd, inStart, inEnd);
            end

            h = line(ax, arcX, arcY, 'Color', tickColor, 'LineWidth', 0.8);
            remember(this, h);

            allTickAngles = [tickAngleCells{:}];
            allTickValues = [tickValueCells{:}];

            if isempty(allTickAngles)
                return
            end

            tickRadius = this.TickRadius;
            tickOuterRadius = this.TickRadius + tickLength;
            tickCos = cos(allTickAngles);
            tickSin = sin(allTickAngles);
            tickX = [tickCos .* tickRadius; tickCos .* tickOuterRadius; nan(size(allTickAngles))];
            tickY = [tickSin .* tickRadius; tickSin .* tickOuterRadius; nan(size(allTickAngles))];
            h = line(ax, tickX(:).', tickY(:).', 'Color', tickColor, 'LineWidth', 0.8);
            remember(this, h);

            if this.ShowTickLabels
                tickLabelRadius = this.TickRadius + tickLabelOffset;
                addTickLabels(this, ax, allTickAngles, allTickValues, ...
                    tickCos(:) .* tickLabelRadius, tickSin(:) .* tickLabelRadius, tickColor);
            end
        end

        function addLabels(this, ax, labels, geom)
            labelCount = numel(labels);
            theta = (geom.Start(1:labelCount) + geom.End(1:labelCount)) ./ 2;
            x = cos(theta(:)) .* this.LabelRadius;
            y = sin(theta(:)) .* this.LabelRadius;
            rotations = labelRotation(this, theta(:));
            textArgs = textPropertyArgs(this, [0, 0, 0], this.LabelFontSize, 'normal', 'center');

            try
                if hasUniformRotation(this, rotations)
                    h = text(ax, x, y, labels(:), textArgs{:}, 'Rotation', rotations(1));
                else
                    h = text(ax, x, y, labels(:), textArgs{:});
                    setTextRotations(this, h, rotations);
                end
                remember(this, h);
            catch
                for nodeIdx = 1:labelCount
                    h = text(ax, x(nodeIdx), y(nodeIdx), labels{nodeIdx}, ...
                        textArgs{:}, 'Rotation', rotations(nodeIdx));
                    remember(this, h);
                end
            end
        end

        function addTickLabels(this, ax, tickAngles, tickValues, x, y, tickColor)
            tickAngles = tickAngles(:);
            tickValues = tickValues(:);
            labels = compactNumbers(this, tickValues);
            [rotations, rightAlign] = tickLabelPlacementData(this, tickAngles);

            addTextGroup(this, ax, x(~rightAlign), y(~rightAlign), labels(~rightAlign), ...
                rotations(~rightAlign), 'left', tickColor, this.TickFontSize, 'normal');
            addTextGroup(this, ax, x(rightAlign), y(rightAlign), labels(rightAlign), ...
                rotations(rightAlign), 'right', tickColor, this.TickFontSize, 'normal');
        end

        function addTextGroup(this, ax, x, y, labels, rotations, align, color, fontSize, fontWeight)
            if isempty(labels)
                return
            end
            textArgs = textPropertyArgs(this, color, fontSize, fontWeight, align);

            try
                if hasUniformRotation(this, rotations)
                    h = text(ax, x(:), y(:), labels(:), textArgs{:}, 'Rotation', rotations(1));
                else
                    h = text(ax, x(:), y(:), labels(:), textArgs{:});
                    setTextRotations(this, h, rotations);
                end
                remember(this, h);
            catch
                for labelIdx = 1:numel(labels)
                    h = text(ax, x(labelIdx), y(labelIdx), labels{labelIdx}, ...
                        textArgs{:}, 'Rotation', rotations(labelIdx));
                    remember(this, h);
                end
            end
        end

        function args = textPropertyArgs(this, color, fontSize, fontWeight, align)
            args = { ...
                'Color', color, ...
                'FontName', this.FontName, ...
                'FontSize', fontSize, ...
                'FontWeight', fontWeight, ...
                'FontAngle', 'normal', ...
                'Interpreter', 'none', ...
                'HorizontalAlignment', align, ...
                'VerticalAlignment', 'middle'};
        end

        function tf = hasUniformRotation(~, rotations)
            rotations = rotations(:);
            tf = isempty(rotations) || all(abs(rotations - rotations(1)) < 1e-10);
        end

        function setTextRotations(~, textHandles, rotations)
            try
                set(textHandles(:), {'Rotation'}, num2cell(rotations(:)));
            catch
                for textIdx = 1:min(numel(textHandles), numel(rotations))
                    try
                        set(textHandles(textIdx), 'Rotation', rotations(textIdx));
                    catch
                    end
                end
            end
        end

        function [tickAngles, tickValues] = nodeTickData(~, adj, nodeIdx, outStart, outEnd, inStart, inEnd)
            rowTargets = find(adj(nodeIdx, :) > 0);
            colSources = find(adj(:, nodeIdx).' > 0);
            maxTickCount = numel(rowTargets) + double(~isempty(rowTargets)) + 2 .* numel(colSources);
            tickAngles = zeros(1, maxTickCount);
            tickValues = zeros(1, maxTickCount);
            tickCount = 0;
            currentValue = 0;
            for idx = 1:numel(rowTargets)
                targetIdx = rowTargets(idx);
                if tickCount == 0
                    tickCount = tickCount + 1;
                    tickAngles(tickCount) = outStart(nodeIdx, targetIdx);
                    tickValues(tickCount) = currentValue;
                end
                currentValue = currentValue + adj(nodeIdx, targetIdx);
                tickCount = tickCount + 1;
                tickAngles(tickCount) = outEnd(nodeIdx, targetIdx);
                tickValues(tickCount) = currentValue;
            end

            for idx = 1:numel(colSources)
                sourceIdx = colSources(idx);
                if tickCount == 0 || abs(tickAngles(tickCount) - inStart(sourceIdx, nodeIdx)) > eps
                    tickCount = tickCount + 1;
                    tickAngles(tickCount) = inStart(sourceIdx, nodeIdx);
                    tickValues(tickCount) = currentValue;
                end
                currentValue = currentValue + adj(sourceIdx, nodeIdx);
                tickCount = tickCount + 1;
                tickAngles(tickCount) = inEnd(sourceIdx, nodeIdx);
                tickValues(tickCount) = currentValue;
            end

            tickAngles = tickAngles(1:tickCount);
            tickValues = tickValues(1:tickCount);
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

        function points = resampledPolyline(~, controlPoints, count)
            if size(controlPoints, 1) == count
                points = controlPoints;
                return
            end

            if size(controlPoints, 1) == 1
                points = repmat(controlPoints, count, 1);
                return
            end

            segmentLength = sqrt(sum(diff(controlPoints, 1, 1).^2, 2));
            distance = [0; cumsum(segmentLength)];
            totalDistance = distance(end);
            if totalDistance <= eps
                points = repmat(controlPoints(1, :), count, 1);
                return
            end

            sampleDistance = linspace(0, totalDistance, count).';
            points = zeros(count, 2);
            segmentIdx = 1;
            for sampleIdx = 1:count
                while segmentIdx < numel(segmentLength) && sampleDistance(sampleIdx) > distance(segmentIdx + 1)
                    segmentIdx = segmentIdx + 1;
                end

                localLength = segmentLength(segmentIdx);
                if localLength <= eps
                    points(sampleIdx, :) = controlPoints(segmentIdx, :);
                else
                    localT = (sampleDistance(sampleIdx) - distance(segmentIdx)) ./ localLength;
                    points(sampleIdx, :) = (1 - localT) .* controlPoints(segmentIdx, :) + ...
                        localT .* controlPoints(segmentIdx + 1, :);
                end
            end
        end

        function [x, y] = ribbonMesh(~, leftBoundary, rightBoundary, sourceSection, targetSection)
            widthCount = size(sourceSection, 1);
            widthT = linspace(0, 1, widthCount);

            gridX = leftBoundary(:, 1) * (1 - widthT) + rightBoundary(:, 1) * widthT;
            gridY = leftBoundary(:, 2) * (1 - widthT) + rightBoundary(:, 2) * widthT;
            gridX(1, :) = sourceSection(:, 1).';
            gridY(1, :) = sourceSection(:, 2).';
            gridX(end, :) = targetSection(:, 1).';
            gridY(end, :) = targetSection(:, 2).';

            x = [ ...
                reshape(gridX(1:end - 1, 1:end - 1), 1, []); ...
                reshape(gridX(2:end, 1:end - 1), 1, []); ...
                reshape(gridX(2:end, 2:end), 1, []); ...
                reshape(gridX(1:end - 1, 2:end), 1, [])];
            y = [ ...
                reshape(gridY(1:end - 1, 1:end - 1), 1, []); ...
                reshape(gridY(2:end, 1:end - 1), 1, []); ...
                reshape(gridY(2:end, 2:end), 1, []); ...
                reshape(gridY(1:end - 1, 2:end), 1, [])];
        end

        function point = circlePoint(~, radius, theta)
            point = [radius .* cos(theta), radius .* sin(theta)];
        end

        function [rotation, rightAlign] = tickLabelPlacementData(~, theta)
            rotation = mod(theta(:) ./ pi .* 180, 360);
            rightAlign = rotation > 90 & rotation < 270;
            rotation(rightAlign) = rotation(rightAlign) + 180;
        end

        function rotation = labelRotation(~, theta)
            theta = mod(theta(:), 2 * pi);
            upperHalf = theta > 0 & theta < pi;
            rotation = -(1.5 * pi - theta) ./ pi .* 180;
            rotation(upperHalf) = -(0.5 * pi - theta(upperHalf)) ./ pi .* 180;
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

        function labels = compactNumbers(~, values)
            values = values(:);
            labels = cell(numel(values), 1);
            integerMask = abs(values - round(values)) < 1e-10;

            if any(integerMask)
                labels(integerMask) = cellstr(num2str(round(values(integerMask)), '%.0f'));
            end
            if any(~integerMask)
                labels(~integerMask) = cellstr(num2str(values(~integerMask), '%.1f'));
            end
        end
    end
end
